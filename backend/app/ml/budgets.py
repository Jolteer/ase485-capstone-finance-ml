"""Statistical budget generator.

Strategy: for each expense category, compute the average monthly spend over
the user's history, then add a configurable buffer so they don't immediately
land over budget. Round up to a tidy multiple of $5 so the suggestion looks
like a deliberate target rather than the raw output of an algorithm.

Categories with no historical expense in the data are skipped - the goal is
to prompt the user about real spending patterns, not to suggest budgets for
behaviours they don't have.
"""

from __future__ import annotations

import math
import statistics
from collections import defaultdict

from app.ml._dates import parse_iso_date
from app.ml.constants import (
    CATEGORIES,
    DEFAULT_BUFFER_PCT,
    MIN_BUDGET_DOLLARS,
    ROUND_TO_NEAREST_DOLLARS,
)

__all__ = ["generate_budgets"]


def generate_budgets(
    transactions: list[dict],
    *,
    buffer_pct: float = DEFAULT_BUFFER_PCT,
) -> list[dict]:
    """Suggest monthly budgets per category from a transaction history.

    Args:
        transactions: List of transaction-shaped dicts with ``amount``,
            ``category``, and ``date`` fields. Income (``amount >= 0``) is
            ignored - we only budget expenses.
        buffer_pct: Headroom added on top of the monthly average. Defaults to
            :data:`app.ml.constants.DEFAULT_BUFFER_PCT` (10%).

    Returns:
        List of dicts ``{"category": ..., "limit_amount": ..., "period":
        "monthly"}``, one per category that had any expense in the input.
        Returned in the canonical category order from
        :data:`app.ml.constants.CATEGORIES`.
    """
    if not transactions:
        return []

    # category -> "YYYY-MM" -> total expense for that month.
    monthly_totals: dict[str, dict[str, float]] = defaultdict(
        lambda: defaultdict(float)
    )
    for txn in transactions:
        amount = txn.get("amount", 0)
        # Income lines (positive amounts) don't contribute to spending budgets.
        if amount >= 0:
            continue
        dt = parse_iso_date(txn.get("date"))
        if dt is None:
            continue
        cat = txn.get("category", "Other")
        bucket = f"{dt.year}-{dt.month:02d}"
        monthly_totals[cat][bucket] += abs(amount)

    budgets: list[dict] = []
    for cat in CATEGORIES:
        months = monthly_totals.get(cat, {})
        if not months:
            continue
        avg = statistics.mean(months.values())
        # Round up to the nearest multiple of $5 so the suggestion looks
        # like an intentional target, not the raw algorithm output.
        rounding = ROUND_TO_NEAREST_DOLLARS
        rounded = math.ceil(avg * (1 + buffer_pct) / rounding) * rounding
        suggested = max(rounded, MIN_BUDGET_DOLLARS)
        budgets.append(
            {
                "category": cat,
                "limit_amount": float(suggested),
                "period": "monthly",
            }
        )

    return budgets
