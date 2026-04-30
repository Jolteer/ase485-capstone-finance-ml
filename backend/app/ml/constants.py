"""Tunable constants for the ML rules.

Pulling these into a single module makes it obvious where the "magic numbers"
in :mod:`app.ml.budgets` and :mod:`app.ml.recommendations` come from. Tweak
here to change recommendation behaviour without touching the rule code.
"""

from __future__ import annotations

# Category list re-exported so callers can ``from app.ml.constants import
# CATEGORIES`` instead of digging into the training data module. The order
# defines the iteration order used by the budget generator.
from app.ml.training_data import CATEGORIES

# ── Budget generation ───────────────────────────────────────────────────────

# Headroom added on top of the historical monthly average. Default 10% means
# a category averaging $100/mo gets a $110 budget.
DEFAULT_BUFFER_PCT: float = 0.10

# Round suggested limits up to the nearest multiple of this dollar amount so
# users see tidy figures ($45 instead of $44.37).
ROUND_TO_NEAREST_DOLLARS: int = 5

# Floor on suggested limits; categories with negligible historical spend still
# get a non-zero budget so the user has a starting target.
MIN_BUDGET_DOLLARS: float = 5.0

# ── Recommendation rules ────────────────────────────────────────────────────

# Threshold for the "spending spike" rule: current month must exceed previous
# month by this much to trigger.
SPIKE_THRESHOLD_PCT: float = 0.20  # i.e. >20% MoM increase

# When a category exceeds last month, half of the increase is shown as the
# headline "potential savings" - reverting to the previous month's habits
# saves ~50% of the increase on a longer horizon (gut estimate).
SPIKE_SAVINGS_FRACTION: float = 0.50

# Suggested savings shown when the user has spending in a category but no
# budget configured: 15% of current spend feels like an achievable target.
NO_BUDGET_SAVINGS_FRACTION: float = 0.15

# General savings nudge: warn when total expenses exceed this share of income.
HIGH_EXPENSE_RATIO: float = 0.80

# Target spending share once the warning fires. Difference between current
# expenses and ``income * TARGET_EXPENSE_RATIO`` is shown as the savings gap.
TARGET_EXPENSE_RATIO: float = 0.70

# Suggested potential savings when nudging the user about their top category.
TOP_CATEGORY_SAVINGS_FRACTION: float = 0.10
