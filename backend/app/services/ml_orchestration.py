"""ML use cases that read history, run an engine, then persist results.

These flows are destructive by design: they replace every existing budget
(or recommendation) for the user with freshly generated ones. The repository
helpers wrap the delete + inserts in a single transaction so a failure in the
middle of the loop rolls back cleanly.
"""

from __future__ import annotations

from typing import Any

from app.core.exceptions import ValidationFailedError
from app.ml.budgets import generate_budgets
from app.ml.categorizer import predict_category_with_confidence
from app.ml.recommendations import generate_recommendations
from app.repositories import budgets as budgets_repo
from app.repositories import recommendations as recs_repo
from app.repositories import transactions as transactions_repo


def categorize(description: str) -> tuple[str, float]:
    """Predict ``(category, confidence)`` for a transaction description."""
    category, confidence = predict_category_with_confidence(description)
    return category, round(confidence, 4)


def regenerate_budgets(user_id: str) -> list[dict[str, Any]]:
    """Replace the user's budgets with ML-derived suggestions.

    Raises :class:`ValidationFailedError` (400) when the user has no
    transactions, or when no expense category produced enough data to
    suggest a budget.
    """
    txns = transactions_repo.list_for_user(user_id)
    if not txns:
        raise ValidationFailedError("No transactions to analyse")

    suggestions = generate_budgets(txns)
    if not suggestions:
        raise ValidationFailedError("Not enough expense data to generate budgets")

    return budgets_repo.replace_all_for_user(user_id, suggestions)


def regenerate_recommendations(user_id: str) -> list[dict[str, Any]]:
    """Replace the user's recommendations with freshly generated ones.

    Returns an empty list if the rule engine produced nothing, but always
    clears the previous recommendations so the user doesn't see stale tips.
    """
    txns = transactions_repo.list_for_user(user_id)
    if not txns:
        raise ValidationFailedError("No transactions to analyse")
    budgets = budgets_repo.list_for_user(user_id)

    suggestions = generate_recommendations(txns, budgets)
    return recs_repo.replace_all_for_user(user_id, suggestions)
