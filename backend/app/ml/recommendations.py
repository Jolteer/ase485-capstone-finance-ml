"""Rule-based savings recommendation engine.

Given a transaction list and a budget list, applies a fixed set of rules and
returns a flat list of recommendation dicts ready for persistence.

Each rule reads from a pre-computed :class:`_SpendingContext` so they don't
re-scan the transaction list. Rules return a list (possibly empty) of
recommendation dicts; the orchestrator concatenates them in order. The "top
category" rule is applied last and dedupes against earlier rules so we don't
double-flag the same category.

All thresholds are imported from :mod:`app.ml.constants`; tweak there.
"""

from __future__ import annotations

from collections import defaultdict
from datetime import datetime, timezone
from typing import Callable

from app.ml._dates import parse_iso_date
from app.ml.constants import (
    HIGH_EXPENSE_RATIO,
    NO_BUDGET_SAVINGS_FRACTION,
    SPIKE_SAVINGS_FRACTION,
    SPIKE_THRESHOLD_PCT,
    TARGET_EXPENSE_RATIO,
    TOP_CATEGORY_SAVINGS_FRACTION,
)

__all__ = ["generate_recommendations"]


class _SpendingContext:
    """Pre-aggregated totals shared between recommendation rules.

    Computed once per :func:`generate_recommendations` call so each rule can
    read summed values rather than iterating raw rows again.
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


def _is_in_previous_month(dt: datetime, now: datetime) -> bool:
    """True when ``dt`` falls in the calendar month immediately before ``now``.

    Handles the January edge case where the previous month belongs to the
    previous year.
    """
    if now.month == 1:
        return dt.year == now.year - 1 and dt.month == 12
    return dt.year == now.year and dt.month == now.month - 1


def _summarize(
    transactions: list[dict],
    budgets: list[dict],
    *,
    now: datetime,
) -> _SpendingContext:
    """Roll up transactions into per-category current- and previous-month totals."""
    cur_month: dict[str, float] = defaultdict(float)
    prev_month: dict[str, float] = defaultdict(float)
    income_total = 0.0

    for txn in transactions:
        amount = txn.get("amount", 0)
        dt = parse_iso_date(txn.get("date"))
        if dt is None:
            continue
        cat = txn.get("category", "Other")
        if amount < 0:
            abs_amt = abs(amount)
            if dt.year == now.year and dt.month == now.month:
                cur_month[cat] += abs_amt
            elif _is_in_previous_month(dt, now):
                prev_month[cat] += abs_amt
        else:
            income_total += amount

    return _SpendingContext(
        budget_map={b["category"]: b["limit_amount"] for b in budgets},
        cur_month=cur_month,
        prev_month=prev_month,
        income_total=income_total,
    )


# Each rule consumes the context and returns zero or more recommendations.
_RuleFn = Callable[[_SpendingContext], list[dict]]


def _rule_over_budget(ctx: _SpendingContext) -> list[dict]:
    """Categories where current-month spend exceeds the user's budget."""
    out: list[dict] = []
    for cat, limit in ctx.budget_map.items():
        spent = ctx.cur_month.get(cat, 0)
        if spent > limit:
            over = spent - limit
            out.append(
                {
                    "category": cat,
                    "title": f"Over budget in {cat}",
                    "description": (
                        f"You've spent ${spent:.0f} against a ${limit:.0f} budget "
                        f"this month - ${over:.0f} over. Try cutting back on "
                        f"non-essential {cat.lower()} purchases."
                    ),
                    "potential_savings": round(over, 2),
                }
            )
    return out


def _rule_spending_spike(ctx: _SpendingContext) -> list[dict]:
    """Categories where current month is materially higher than previous month."""
    out: list[dict] = []
    threshold_multiplier = 1 + SPIKE_THRESHOLD_PCT
    for cat, cur in ctx.cur_month.items():
        prev = ctx.prev_month.get(cat, 0)
        if prev > 0 and cur > prev * threshold_multiplier:
            increase = cur - prev
            pct = ((cur - prev) / prev) * 100
            out.append(
                {
                    "category": cat,
                    "title": f"Spending spike in {cat}",
                    "description": (
                        f"Your {cat.lower()} spending jumped {pct:.0f}% this month "
                        f"(${prev:.0f} -> ${cur:.0f}). Review recent purchases."
                    ),
                    "potential_savings": round(increase * SPIKE_SAVINGS_FRACTION, 2),
                }
            )
    return out


def _rule_set_a_budget(ctx: _SpendingContext) -> list[dict]:
    """Categories with current spending but no budget configured.

    "Other" is excluded because it's the catch-all; suggesting a budget there
    would just lump unrelated purchases together.
    """
    out: list[dict] = []
    for cat, spent in ctx.cur_month.items():
        if cat in ctx.budget_map or cat == "Other":
            continue
        out.append(
            {
                "category": cat,
                "title": f"Set a budget for {cat}",
                "description": (
                    f"You spent ${spent:.0f} on {cat.lower()} this month but "
                    f"have no budget set. Adding one helps track and control spending."
                ),
                "potential_savings": round(spent * NO_BUDGET_SAVINGS_FRACTION, 2),
            }
        )
    return out


def _rule_high_expense_ratio(ctx: _SpendingContext) -> list[dict]:
    """Total expenses exceed the configured share of income (general nudge)."""
    if ctx.income_total <= 0:
        return []
    total_expense = sum(ctx.cur_month.values())
    if total_expense <= ctx.income_total * HIGH_EXPENSE_RATIO:
        return []
    savings_gap = total_expense - ctx.income_total * TARGET_EXPENSE_RATIO
    return [
        {
            "category": "Other",
            "title": "Spending exceeds 80% of income",
            "description": (
                f"You've spent ${total_expense:.0f} out of ${ctx.income_total:.0f} "
                f"income this month. Aim to keep spending under 70% to build savings."
            ),
            "potential_savings": round(max(savings_gap, 0), 2),
        }
    ]


def _rule_top_category(ctx: _SpendingContext, prior: list[dict]) -> list[dict]:
    """Nudge about the highest-spend category, unless an earlier rule already did."""
    if not ctx.cur_month:
        return []
    top_cat = max(ctx.cur_month, key=lambda c: ctx.cur_month[c])
    # "Other" is the catch-all bucket; pointing the user there isn't actionable.
    if top_cat == "Other":
        return []
    # Don't double-flag a category we already covered with a sharper rule.
    if any(r["category"] == top_cat for r in prior):
        return []
    top_amt = ctx.cur_month[top_cat]
    return [
        {
            "category": top_cat,
            "title": f"Reduce {top_cat.lower()} spending",
            "description": (
                f"{top_cat} is your highest expense at ${top_amt:.0f} "
                f"this month. Small reductions here have the biggest impact."
            ),
            "potential_savings": round(top_amt * TOP_CATEGORY_SAVINGS_FRACTION, 2),
        }
    ]


# Rules whose output is independent of each other; applied in order.
# ``_rule_top_category`` runs after these so it can dedupe against them.
_INDEPENDENT_RULES: list[_RuleFn] = [
    _rule_over_budget,
    _rule_spending_spike,
    _rule_set_a_budget,
    _rule_high_expense_ratio,
]


def generate_recommendations(
    transactions: list[dict],
    budgets: list[dict],
    *,
    now: datetime | None = None,
) -> list[dict]:
    """Produce personalised savings recommendations.

    Args:
        transactions: User's transaction history. Empty list returns ``[]``.
        budgets: User's current budgets, used by the over-budget and "set a
            budget" rules.
        now: Reference datetime for "current" vs "previous" month. Defaults
            to UTC now; tests inject a fixed clock here.

    Rules evaluated:
      - Over-budget categories.
      - Month-over-month spending spikes.
      - Categories with spending but no budget.
      - General savings nudge when total spending vs income is high.
      - Top-category nudge (only if not already mentioned).
    """
    if not transactions:
        return []

    reference = now or datetime.now(timezone.utc)
    ctx = _summarize(transactions, budgets, now=reference)

    recs: list[dict] = []
    for rule in _INDEPENDENT_RULES:
        recs.extend(rule(ctx))
    recs.extend(_rule_top_category(ctx, recs))
    return recs
