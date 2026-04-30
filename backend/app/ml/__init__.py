"""Machine-learning utilities for SmartSpend.

Three independent capabilities:

- :mod:`app.ml.categorizer` - TF-IDF + Multinomial Naive Bayes text classifier
  that infers a transaction's category from its description.
- :mod:`app.ml.budgets` - statistical budget generator that recommends a
  monthly spending limit per category from history.
- :mod:`app.ml.recommendations` - rule-based engine that compares spending
  against budgets and previous months to surface savings tips.

Tunable thresholds live in :mod:`app.ml.constants` so the rules can be
adjusted without code changes to the core logic.
"""

from app.ml.budgets import generate_budgets
from app.ml.categorizer import (
    predict_category,
    predict_category_with_confidence,
)
from app.ml.constants import CATEGORIES
from app.ml.recommendations import generate_recommendations

__all__ = [
    "CATEGORIES",
    "predict_category",
    "predict_category_with_confidence",
    "generate_budgets",
    "generate_recommendations",
]
