"""Transaction use cases.

The thin wrapper around the repository exists so the create flow can call the
ML categorizer when the client omits an explicit category. Putting that logic
here (rather than the router) keeps the router free of business decisions.
"""

from __future__ import annotations

from datetime import datetime
from typing import Any

from app.ml.categorizer import predict_category
from app.repositories import transactions as repo


def list_transactions(
    user_id: str,
    *,
    category: str | None = None,
) -> list[dict[str, Any]]:
    """Return the user's transactions, newest first."""
    return repo.list_for_user(user_id, category=category)


def create_transaction(
    *,
    user_id: str,
    amount: float,
    category: str,
    description: str,
    date: datetime | None,
) -> dict[str, Any]:
    """Create a transaction; auto-categorize from description when category is empty."""
    resolved_category = category or predict_category(description)
    return repo.create(
        user_id=user_id,
        amount=amount,
        category=resolved_category,
        description=description,
        date=date,
    )


def update_transaction(
    *,
    transaction_id: str,
    user_id: str,
    payload: dict[str, Any],
) -> dict[str, Any]:
    """Partial update."""
    return repo.update(
        transaction_id=transaction_id,
        user_id=user_id,
        payload=payload,
    )


def delete_transaction(*, transaction_id: str, user_id: str) -> None:
    """Delete; raises :class:`NotFoundError` if not owned."""
    repo.delete(transaction_id=transaction_id, user_id=user_id)
