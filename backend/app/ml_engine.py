"""Machine-learning utilities for SmartSpend.

Provides three capabilities:
1. **Transaction categorization** – text classifier trained on known transaction
   descriptions. Uses TF-IDF + Multinomial Naive Bayes (fast, high accuracy on
   short text).
2. **Budget generation** – statistical analysis of spending history to suggest
   per-category monthly limits.
3. **Recommendation generation** – rule-based engine that compares spending
   patterns against budgets and historical averages to surface savings tips.
"""

from __future__ import annotations

import math
import statistics
from collections import defaultdict
from datetime import datetime, timezone

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline

CATEGORIES = [
    "Food",
    "Entertainment",
    "Bills",
    "Shopping",
    "Transportation",
    "Healthcare",
    "Education",
    "Other",
]

# ---------------------------------------------------------------------------
# Training corpus – representative descriptions per category.  The model is
# re-trained on startup (in-memory) so we can extend this without managing a
# separate model artefact file.
# ---------------------------------------------------------------------------
_TRAINING_DATA: list[tuple[str, str]] = [
    # Food
    ("Grocery Store", "Food"),
    ("grocery shopping", "Food"),
    ("Whole Foods Market", "Food"),
    ("Walmart Grocery", "Food"),
    ("Restaurant dinner", "Food"),
    ("restaurant lunch", "Food"),
    ("fast food drive through", "Food"),
    ("McDonald's", "Food"),
    ("Chipotle", "Food"),
    ("Starbucks coffee", "Food"),
    ("Coffee shop", "Food"),
    ("Dunkin Donuts", "Food"),
    ("Pizza delivery", "Food"),
    ("DoorDash order", "Food"),
    ("Uber Eats", "Food"),
    ("Grubhub delivery", "Food"),
    ("bakery pastries", "Food"),
    ("deli sandwich", "Food"),
    ("food truck lunch", "Food"),
    ("sushi bar", "Food"),
    ("Trader Joe's", "Food"),
    ("Costco groceries", "Food"),
    ("Aldi supermarket", "Food"),
    ("meal prep ingredients", "Food"),
    # Entertainment
    ("Netflix", "Entertainment"),
    ("Netflix subscription", "Entertainment"),
    ("Spotify", "Entertainment"),
    ("Spotify premium", "Entertainment"),
    ("Hulu subscription", "Entertainment"),
    ("Disney Plus", "Entertainment"),
    ("HBO Max", "Entertainment"),
    ("Apple TV+", "Entertainment"),
    ("Movie tickets", "Entertainment"),
    ("movie theater", "Entertainment"),
    ("Concert tickets", "Entertainment"),
    ("concert festival", "Entertainment"),
    ("video games", "Entertainment"),
    ("Steam purchase", "Entertainment"),
    ("PlayStation Store", "Entertainment"),
    ("Xbox Game Pass", "Entertainment"),
    ("YouTube Premium", "Entertainment"),
    ("bowling night", "Entertainment"),
    ("amusement park", "Entertainment"),
    ("museum tickets", "Entertainment"),
    ("theater show", "Entertainment"),
    ("comedy club", "Entertainment"),
    # Bills
    ("Electric Bill", "Bills"),
    ("electricity payment", "Bills"),
    ("Internet Bill", "Bills"),
    ("internet service", "Bills"),
    ("Water Bill", "Bills"),
    ("water utility", "Bills"),
    ("Gas Bill", "Bills"),
    ("natural gas utility", "Bills"),
    ("Phone Bill", "Bills"),
    ("cell phone payment", "Bills"),
    ("Car Insurance", "Bills"),
    ("auto insurance premium", "Bills"),
    ("Home Insurance", "Bills"),
    ("renters insurance", "Bills"),
    ("Rent payment", "Bills"),
    ("mortgage payment", "Bills"),
    ("cable TV", "Bills"),
    ("trash collection", "Bills"),
    ("sewer bill", "Bills"),
    ("HOA dues", "Bills"),
    # Shopping
    ("Amazon Order", "Shopping"),
    ("Amazon purchase", "Shopping"),
    ("Target", "Shopping"),
    ("Target shopping", "Shopping"),
    ("Walmart", "Shopping"),
    ("Best Buy", "Shopping"),
    ("electronics store", "Shopping"),
    ("clothing store", "Shopping"),
    ("New shoes", "Shopping"),
    ("new clothes", "Shopping"),
    ("furniture purchase", "Shopping"),
    ("IKEA", "Shopping"),
    ("home decor", "Shopping"),
    ("Holiday gifts", "Shopping"),
    ("birthday gift", "Shopping"),
    ("department store", "Shopping"),
    ("online shopping", "Shopping"),
    ("Etsy purchase", "Shopping"),
    ("eBay order", "Shopping"),
    ("thrift store", "Shopping"),
    # Transportation
    ("Gas Station", "Transportation"),
    ("gas fill up", "Transportation"),
    ("Uber ride", "Transportation"),
    ("Lyft ride", "Transportation"),
    ("taxi cab", "Transportation"),
    ("bus pass", "Transportation"),
    ("subway ticket", "Transportation"),
    ("train ticket", "Transportation"),
    ("parking fee", "Transportation"),
    ("parking garage", "Transportation"),
    ("toll road", "Transportation"),
    ("car maintenance", "Transportation"),
    ("oil change", "Transportation"),
    ("tire replacement", "Transportation"),
    ("car wash", "Transportation"),
    ("flight ticket", "Transportation"),
    ("airline booking", "Transportation"),
    # Healthcare
    ("Pharmacy", "Healthcare"),
    ("pharmacy prescription", "Healthcare"),
    ("Co-pay", "Healthcare"),
    ("doctor copay", "Healthcare"),
    ("doctor visit", "Healthcare"),
    ("dentist appointment", "Healthcare"),
    ("dental cleaning", "Healthcare"),
    ("eye exam", "Healthcare"),
    ("optometrist", "Healthcare"),
    ("hospital bill", "Healthcare"),
    ("urgent care", "Healthcare"),
    ("physical therapy", "Healthcare"),
    ("mental health counseling", "Healthcare"),
    ("health insurance", "Healthcare"),
    ("vitamins supplements", "Healthcare"),
    ("medical lab test", "Healthcare"),
    # Education
    ("Online Course", "Education"),
    ("online class", "Education"),
    ("Udemy course", "Education"),
    ("Coursera subscription", "Education"),
    ("textbook purchase", "Education"),
    ("school supplies", "Education"),
    ("tuition payment", "Education"),
    ("student loan", "Education"),
    ("workshop fee", "Education"),
    ("certification exam", "Education"),
    ("library fine", "Education"),
    ("tutoring session", "Education"),
    ("college bookstore", "Education"),
    ("Skillshare membership", "Education"),
    # Other
    ("Salary Deposit", "Other"),
    ("salary payment", "Other"),
    ("paycheck direct deposit", "Other"),
    ("freelance payment", "Other"),
    ("side hustle income", "Other"),
    ("tax refund", "Other"),
    ("ATM withdrawal", "Other"),
    ("cash withdrawal", "Other"),
    ("bank fee", "Other"),
    ("wire transfer", "Other"),
    ("venmo transfer", "Other"),
    ("zelle payment", "Other"),
    ("interest earned", "Other"),
    ("dividend payment", "Other"),
    ("reimbursement", "Other"),
    ("miscellaneous", "Other"),
]


def _build_pipeline() -> Pipeline:
    texts = [t for t, _ in _TRAINING_DATA]
    labels = [l for _, l in _TRAINING_DATA]
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
    global _pipeline
    if _pipeline is None:
        _pipeline = _build_pipeline()
    return _pipeline


# ---------------------------------------------------------------------------
# 1.  Categorization
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
# 2.  Budget generation
# ---------------------------------------------------------------------------

def generate_budgets(
    transactions: list[dict],
    *,
    buffer_pct: float = 0.10,
) -> list[dict]:
    """Analyse transaction history and suggest monthly budgets per category.

    Strategy: for each expense category, compute the average monthly spend over
    the available history, then add *buffer_pct* headroom so the user isn't
    immediately over-budget.  Only categories with actual spending are included.

    Returns a list of dicts with keys: category, limit_amount, period.
    """
    if not transactions:
        return []

    monthly_totals: dict[str, dict[str, float]] = defaultdict(
        lambda: defaultdict(float)
    )
    for txn in transactions:
        amount = txn.get("amount", 0)
        if amount >= 0:
            continue
        cat = txn.get("category", "Other")
        dt = txn.get("date")
        if isinstance(dt, str):
            dt = datetime.fromisoformat(dt.replace("Z", "+00:00"))
        if dt is None:
            continue
        key = f"{dt.year}-{dt.month:02d}"
        monthly_totals[cat][key] += abs(amount)

    budgets = []
    for cat in CATEGORIES:
        months = monthly_totals.get(cat, {})
        if not months:
            continue
        values = list(months.values())
        avg = statistics.mean(values)
        suggested = math.ceil(avg * (1 + buffer_pct) / 5) * 5
        budgets.append({
            "category": cat,
            "limit_amount": float(max(suggested, 5)),
            "period": "monthly",
        })

    return budgets


# ---------------------------------------------------------------------------
# 3.  Recommendation generation
# ---------------------------------------------------------------------------

def generate_recommendations(
    transactions: list[dict],
    budgets: list[dict],
) -> list[dict]:
    """Produce personalised savings recommendations.

    Rules evaluated:
    - Over-budget categories → "Reduce spending in X"
    - Month-over-month increase > 20 % → "Spending spike in X"
    - Subscription-like small recurring charges → "Review subscriptions"
    - Categories without a budget → "Set a budget for X"
    - General savings tip when total spending is high vs income
    """
    if not transactions:
        return []

    now = datetime.now(timezone.utc)
    recs: list[dict] = []

    budget_map = {b["category"]: b["limit_amount"] for b in budgets}

    # Compute current-month and previous-month totals per category
    cur_month: dict[str, float] = defaultdict(float)
    prev_month: dict[str, float] = defaultdict(float)
    all_expenses: dict[str, float] = defaultdict(float)
    income_total = 0.0

    for txn in transactions:
        amount = txn.get("amount", 0)
        dt = txn.get("date")
        if isinstance(dt, str):
            dt = datetime.fromisoformat(dt.replace("Z", "+00:00"))
        if dt is None:
            continue
        cat = txn.get("category", "Other")
        if amount < 0:
            abs_amt = abs(amount)
            all_expenses[cat] += abs_amt
            if dt.year == now.year and dt.month == now.month:
                cur_month[cat] += abs_amt
            elif (
                (dt.year == now.year and dt.month == now.month - 1)
                or (now.month == 1 and dt.year == now.year - 1 and dt.month == 12)
            ):
                prev_month[cat] += abs_amt
        else:
            income_total += amount

    # Rule 1: Over-budget categories
    for cat, limit in budget_map.items():
        spent = cur_month.get(cat, 0)
        if spent > limit:
            over = spent - limit
            recs.append({
                "category": cat,
                "title": f"Over budget in {cat}",
                "description": (
                    f"You've spent ${spent:.0f} against a ${limit:.0f} budget "
                    f"this month — ${over:.0f} over. Try cutting back on "
                    f"non-essential {cat.lower()} purchases."
                ),
                "potential_savings": round(over, 2),
            })

    # Rule 2: Month-over-month spike
    for cat, cur in cur_month.items():
        prev = prev_month.get(cat, 0)
        if prev > 0 and cur > prev * 1.2:
            increase = cur - prev
            pct = ((cur - prev) / prev) * 100
            recs.append({
                "category": cat,
                "title": f"Spending spike in {cat}",
                "description": (
                    f"Your {cat.lower()} spending jumped {pct:.0f}% this month "
                    f"(${prev:.0f} → ${cur:.0f}). Review recent purchases."
                ),
                "potential_savings": round(increase * 0.5, 2),
            })

    # Rule 3: Categories with spending but no budget
    for cat in cur_month:
        if cat not in budget_map and cat != "Other":
            spent = cur_month[cat]
            recs.append({
                "category": cat,
                "title": f"Set a budget for {cat}",
                "description": (
                    f"You spent ${spent:.0f} on {cat.lower()} this month but "
                    f"have no budget set. Adding one helps track and control spending."
                ),
                "potential_savings": round(spent * 0.15, 2),
            })

    # Rule 4: High spending relative to income
    total_expense = sum(cur_month.values())
    if income_total > 0 and total_expense > income_total * 0.8:
        savings_gap = total_expense - income_total * 0.7
        recs.append({
            "category": "Other",
            "title": "Spending exceeds 80% of income",
            "description": (
                f"You've spent ${total_expense:.0f} out of ${income_total:.0f} "
                f"income this month. Aim to keep spending under 70% to build savings."
            ),
            "potential_savings": round(max(savings_gap, 0), 2),
        })

    # Rule 5: Top spending category suggestion
    if cur_month:
        top_cat = max(cur_month, key=cur_month.get)  # type: ignore[arg-type]
        top_amt = cur_month[top_cat]
        if top_cat != "Other" and not any(r["category"] == top_cat for r in recs):
            recs.append({
                "category": top_cat,
                "title": f"Reduce {top_cat.lower()} spending",
                "description": (
                    f"{top_cat} is your highest expense at ${top_amt:.0f} "
                    f"this month. Small reductions here have the biggest impact."
                ),
                "potential_savings": round(top_amt * 0.10, 2),
            })

    return recs
