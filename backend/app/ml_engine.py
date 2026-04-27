"""Machine-learning utilities for SmartSpend.

Provides three capabilities:
1. **Transaction categorization** - text classifier trained on known transaction
   descriptions. Uses TF-IDF + Multinomial Naive Bayes (fast, high accuracy on
   short text).
2. **Budget generation** - statistical analysis of spending history to suggest
   per-category monthly limits.
3. **Recommendation generation** - rule-based engine that compares spending
   patterns against budgets and historical averages to surface savings tips.

The training corpus lives in :mod:`app.ml_data` so this module stays focused
on logic.
"""

from __future__ import annotations

import math
import statistics
from collections import defaultdict
from datetime import datetime, timezone
from typing import Callable

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline

from app.ml_data import CATEGORIES, TRAINING_DATA

__all__ = [
    "CATEGORIES",
    "predict_category",
    "predict_category_with_confidence",
    "generate_budgets",
    "generate_recommendations",
]


# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------

def _parse_iso_date(value: object) -> datetime | None:
    """Coerce a transaction's *date* field to :class:`datetime` or None.

    Accepts datetime instances unchanged, parses ISO-8601 strings (including
    the trailing-Z form psycopg2/json round-trips often produce), and returns
    None for anything else so callers can skip undated rows.
    """
    if isinstance(value, datetime):
        return value
    if isinstance(value, str):
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    return None


# ---------------------------------------------------------------------------
# Model pipeline (lazy)
# ---------------------------------------------------------------------------

def _build_pipeline() -> Pipeline:
    texts = [t for t, _ in TRAINING_DATA]
    labels = [label for _, label in TRAINING_DATA]
    pipe = Pipeline([
        ("tfidf", TfidfVectorizer(
            lowercase=True,
            ngram_range=(1, 2),
            max_features=5000,
        )),
        ("clf", MultinomialNB(alpha=0.1)),
    ])
    pipe.fit(texts, labels)
    return pipe


_pipeline: Pipeline | None = None


def _get_pipeline() -> Pipeline:
    # Train lazily so importing this module is cheap (matters for tests).
    global _pipeline
    if _pipeline is None:
        _pipeline = _build_pipeline()
    return _pipeline


# ---------------------------------------------------------------------------
# 1. Categorization
# ---------------------------------------------------------------------------

def predict_category(description: str) -> str:
    """Return the predicted category label for a transaction description."""
    if not description or not description.strip():
        return "Other"
    pipe = _get_pipeline()
    return pipe.predict([description])[0]


def predict_category_with_confidence(description: str) -> tuple[str, float]:
    """Return (category, confidence) where confidence is the max class probability."""
    if not description or not description.strip():
        return ("Other", 1.0)
    pipe = _get_pipeline()
    probs = pipe.predict_proba([description])[0]
    idx = probs.argmax()
    return (pipe.classes_[idx], float(probs[idx]))


# ---------------------------------------------------------------------------
# 2. Budget generation
# ---------------------------------------------------------------------------

def generate_budgets(
    transactions: list[dict],
    *,
    buffer_pct: float = 0.10,
) -> list[dict]:
    """Analyse transaction history and suggest monthly budgets per category.

    Strategy: for each expense category, compute the average monthly spend over
    the available history, then add *buffer_pct* headroom so the user isn't
    immediately over-budget. Only categories with actual spending are included.

    Returns a list of dicts with keys: category, limit_amount, period.
    """
    if not transactions:
        return []

    # category -> "YYYY-MM" -> total expense for that month
    monthly_totals: dict[str, dict[str, float]] = defaultdict(
        lambda: defaultdict(float)
    )
    for txn in transactions:
        amount = txn.get("amount", 0)
        if amount >= 0:
            continue
        dt = _parse_iso_date(txn.get("date"))
        if dt is None:
            continue
        cat = txn.get("category", "Other")
        key = f"{dt.year}-{dt.month:02d}"
        monthly_totals[cat][key] += abs(amount)

    budgets: list[dict] = []
    for cat in CATEGORIES:
        months = monthly_totals.get(cat, {})
        if not months:
            continue
        avg = statistics.mean(months.values())
        # Round up to the nearest $5 to give the user a tidy limit.
        suggested = math.ceil(avg * (1 + buffer_pct) / 5) * 5
        budgets.append({
            "category": cat,
            "limit_amount": float(max(suggested, 5)),
            "period": "monthly",
        })

    return budgets


# ---------------------------------------------------------------------------
# 3. Recommendation generation
# ---------------------------------------------------------------------------

class _SpendingContext:
    """Aggregates needed by every recommendation rule.

    Computed once from the transaction list so each rule can read pre-summed
    totals instead of iterating the raw rows again.
    """

    __slots__ = ("budget_map", "cur_month", "prev_month", "income_total")

    def __init__(
        self,
        *,
        budget_map: dict[str, float],
        cur_month: dict[str, float],
        prev_month: dict[str, float],
        income_total: float,
    ) -> None:
        self.budget_map = budget_map
        self.cur_month = cur_month
        self.prev_month = prev_month
        self.income_total = income_total


def _summarize(
    transactions: list[dict],
    budgets: list[dict],
    *,
    now: datetime,
) -> _SpendingContext:
    cur_month: dict[str, float] = defaultdict(float)
    prev_month: dict[str, float] = defaultdict(float)
    income_total = 0.0

    for txn in transactions:
        amount = txn.get("amount", 0)
        dt = _parse_iso_date(txn.get("date"))
        if dt is None:
            continue
        cat = txn.get("category", "Other")
        if amount < 0:
            abs_amt = abs(amount)
            if dt.year == now.year and dt.month == now.month:
                cur_month[cat] += abs_amt
            elif (
                (dt.year == now.year and dt.month == now.month - 1)
                or (now.month == 1 and dt.year == now.year - 1 and dt.month == 12)
            ):
                prev_month[cat] += abs_amt
        else:
            income_total += amount

    return _SpendingContext(
        budget_map={b["category"]: b["limit_amount"] for b in budgets},
        cur_month=cur_month,
        prev_month=prev_month,
        income_total=income_total,
    )


# Each rule returns a list of recommendation dicts (possibly empty).
_RuleFn = Callable[[_SpendingContext], list[dict]]


def _rule_over_budget(ctx: _SpendingContext) -> list[dict]:
    """Categories where current-month spend exceeds the user's budget."""
    out: list[dict] = []
    for cat, limit in ctx.budget_map.items():
        spent = ctx.cur_month.get(cat, 0)
        if spent > limit:
            over = spent - limit
            out.append({
                "category": cat,
                "title": f"Over budget in {cat}",
                "description": (
                    f"You've spent ${spent:.0f} against a ${limit:.0f} budget "
                    f"this month - ${over:.0f} over. Try cutting back on "
                    f"non-essential {cat.lower()} purchases."
                ),
                "potential_savings": round(over, 2),
            })
    return out


def _rule_spending_spike(ctx: _SpendingContext) -> list[dict]:
    """Categories where current month is >20% higher than previous month."""
    out: list[dict] = []
    for cat, cur in ctx.cur_month.items():
        prev = ctx.prev_month.get(cat, 0)
        if prev > 0 and cur > prev * 1.2:
            increase = cur - prev
            pct = ((cur - prev) / prev) * 100
            out.append({
                "category": cat,
                "title": f"Spending spike in {cat}",
                "description": (
                    f"Your {cat.lower()} spending jumped {pct:.0f}% this month "
                    f"(${prev:.0f} -> ${cur:.0f}). Review recent purchases."
                ),
                "potential_savings": round(increase * 0.5, 2),
            })
    return out


def _rule_set_a_budget(ctx: _SpendingContext) -> list[dict]:
    """Categories with current spending but no budget configured."""
    out: list[dict] = []
    for cat, spent in ctx.cur_month.items():
        if cat in ctx.budget_map or cat == "Other":
            continue
        out.append({
            "category": cat,
            "title": f"Set a budget for {cat}",
            "description": (
                f"You spent ${spent:.0f} on {cat.lower()} this month but "
                f"have no budget set. Adding one helps track and control spending."
            ),
            "potential_savings": round(spent * 0.15, 2),
        })
    return out


def _rule_high_expense_ratio(ctx: _SpendingContext) -> list[dict]:
    """Total expenses exceed 80% of income (general savings nudge)."""
    if ctx.income_total <= 0:
        return []
    total_expense = sum(ctx.cur_month.values())
    if total_expense <= ctx.income_total * 0.8:
        return []
    savings_gap = total_expense - ctx.income_total * 0.7
    return [{
        "category": "Other",
        "title": "Spending exceeds 80% of income",
        "description": (
            f"You've spent ${total_expense:.0f} out of ${ctx.income_total:.0f} "
            f"income this month. Aim to keep spending under 70% to build savings."
        ),
        "potential_savings": round(max(savings_gap, 0), 2),
    }]


def _rule_top_category(ctx: _SpendingContext, prior: list[dict]) -> list[dict]:
    """Suggest reductions in the single highest-spend category (if not already covered)."""
    if not ctx.cur_month:
        return []
    top_cat = max(ctx.cur_month, key=lambda c: ctx.cur_month[c])
    if top_cat == "Other":
        return []
    if any(r["category"] == top_cat for r in prior):
        return []
    top_amt = ctx.cur_month[top_cat]
    return [{
        "category": top_cat,
        "title": f"Reduce {top_cat.lower()} spending",
        "description": (
            f"{top_cat} is your highest expense at ${top_amt:.0f} "
            f"this month. Small reductions here have the biggest impact."
        ),
        "potential_savings": round(top_amt * 0.10, 2),
    }]


# Independent rules, applied in order. _rule_top_category needs the others'
# output to dedupe, so it's applied as a final pass below.
_INDEPENDENT_RULES: list[_RuleFn] = [
    _rule_over_budget,
    _rule_spending_spike,
    _rule_set_a_budget,
    _rule_high_expense_ratio,
]


def generate_recommendations(
    transactions: list[dict],
    budgets: list[dict],
) -> list[dict]:
    """Produce personalised savings recommendations.

    Rules evaluated:
    - Over-budget categories -> "Reduce spending in X"
    - Month-over-month increase > 20% -> "Spending spike in X"
    - Categories without a budget -> "Set a budget for X"
    - General savings tip when total spending is high vs income
    - Top spending category nudge (only if not already mentioned)
    """
    if not transactions:
        return []

    ctx = _summarize(transactions, budgets, now=datetime.now(timezone.utc))

    recs: list[dict] = []
    for rule in _INDEPENDENT_RULES:
        recs.extend(rule(ctx))
    recs.extend(_rule_top_category(ctx, recs))
    return recs
