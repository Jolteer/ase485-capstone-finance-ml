"""Recommendation repository - SQL for the recommendations table."""

from __future__ import annotations

from typing import Any

from app.core import db as core_db


def list_for_user(user_id: str) -> list[dict[str, Any]]:
    """Return the user's recommendations, newest first."""
    rows = core_db.query(
        "SELECT * FROM recommendations WHERE user_id = %s ORDER BY created_at DESC",
        (user_id,),
    )
    return rows or []


def replace_all_for_user(
    user_id: str,
    suggestions: list[dict[str, Any]],
) -> list[dict[str, Any]]:
    """Atomically replace every recommendation for the user.

    Wrapped in a transaction so a failure during the per-row INSERT loop
    rolls back the upfront DELETE.
    """
    created: list[dict[str, Any]] = []
    with core_db.transaction() as tx:
        tx.execute("DELETE FROM recommendations WHERE user_id = %s", (user_id,))
        for s in suggestions:
            row = tx.execute(
                """INSERT INTO recommendations
                       (user_id, category, title, description, potential_savings)
                   VALUES (%s, %s, %s, %s, %s)
                   RETURNING *""",
                (
                    user_id,
                    s["category"],
                    s["title"],
                    s["description"],
                    s["potential_savings"],
                ),
            )
            assert isinstance(row, dict)
            created.append(row)
    return created
