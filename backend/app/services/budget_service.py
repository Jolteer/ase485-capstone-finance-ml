"""Budget use cases."""

from __future__ import annotations

from typing import Any

from app.repositories import budgets as repo


def list_budgets(user_id: str) -> list[dict[str, Any]]:
    return repo.list_for_user(user_id)


def create_budget(
    *,
    user_id: str,
    category: str,
    limit_amount: float,
    period: str,
) -> dict[str, Any]:
    return repo.create(
        user_id=user_id,
        category=category,
        limit_amount=limit_amount,
        period=period,
    )


def update_budget(
    *,
    budget_id: str,
    user_id: str,
    payload: dict[str, Any],
) -> dict[str, Any]:
    return repo.update(budget_id=budget_id, user_id=user_id, payload=payload)


def delete_budget(*, budget_id: str, user_id: str) -> None:
    repo.delete(budget_id=budget_id, user_id=user_id)
