"""Goal use cases."""

from __future__ import annotations

from datetime import datetime
from typing import Any

from app.repositories import goals as repo


def list_goals(user_id: str) -> list[dict[str, Any]]:
    return repo.list_for_user(user_id)


def create_goal(
    *,
    user_id: str,
    target_amount: float,
    target_date: datetime,
    description: str,
    progress: float,
    category: str,
) -> dict[str, Any]:
    return repo.create(
        user_id=user_id,
        target_amount=target_amount,
        target_date=target_date,
        description=description,
        progress=progress,
        category=category,
    )


def update_goal(
    *,
    goal_id: str,
    user_id: str,
    payload: dict[str, Any],
) -> dict[str, Any]:
    return repo.update(goal_id=goal_id, user_id=user_id, payload=payload)


def delete_goal(*, goal_id: str, user_id: str) -> None:
    repo.delete(goal_id=goal_id, user_id=user_id)
