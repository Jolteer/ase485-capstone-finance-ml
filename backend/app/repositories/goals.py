"""Goal repository - SQL for the goals table."""

from __future__ import annotations

from datetime import datetime
from typing import Any

from app.core import db as core_db
from app.repositories._partial_update import delete_owned, update_owned

UPDATABLE_COLUMNS: set[str] = {
    "target_amount",
    "target_date",
    "description",
    "progress",
    "category",
}


def list_for_user(user_id: str) -> list[dict[str, Any]]:
    """Return the user's goals, soonest target date first."""
    rows = core_db.query(
        "SELECT * FROM goals WHERE user_id = %s ORDER BY target_date ASC",
        (user_id,),
    )
    return rows or []


def create(
    *,
    user_id: str,
    target_amount: float,
    target_date: datetime,
    description: str,
    progress: float,
    category: str,
) -> dict[str, Any]:
    """Insert a goal and return the new row."""
    row = core_db.execute(
        """INSERT INTO goals
               (user_id, target_amount, target_date, description, progress, category)
           VALUES (%s, %s, %s, %s, %s, %s)
           RETURNING *""",
        (user_id, target_amount, target_date, description, progress, category),
    )
    assert isinstance(row, dict)
    return row


def update(
    *,
    goal_id: str,
    user_id: str,
    payload: dict[str, Any],
) -> dict[str, Any]:
    """Partial update; raises :class:`NotFoundError` if not owned."""
    return update_owned(
        table="goals",
        allowed_columns=UPDATABLE_COLUMNS,
        row_id=goal_id,
        user_id=user_id,
        payload=payload,
        not_found_detail="Goal not found",
    )


def delete(*, goal_id: str, user_id: str) -> None:
    """Delete; raises :class:`NotFoundError` if not owned."""
    delete_owned(
        table="goals",
        row_id=goal_id,
        user_id=user_id,
        not_found_detail="Goal not found",
    )
