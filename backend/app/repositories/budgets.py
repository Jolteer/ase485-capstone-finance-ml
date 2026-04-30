"""Budget repository - SQL for the budgets table."""

from __future__ import annotations

from typing import Any

from app.core import db as core_db
from app.repositories._partial_update import delete_owned, update_owned

UPDATABLE_COLUMNS: set[str] = {"category", "limit_amount", "period"}


def list_for_user(user_id: str) -> list[dict[str, Any]]:
    """Return the user's budgets, newest first."""
    rows = core_db.query(
        "SELECT * FROM budgets WHERE user_id = %s ORDER BY created_at DESC",
        (user_id,),
    )
    return rows or []


def create(
    *,
    user_id: str,
    category: str,
    limit_amount: float,
    period: str,
) -> dict[str, Any]:
    """Insert a budget and return the new row."""
    row = core_db.execute(
        """INSERT INTO budgets (user_id, category, limit_amount, period)
           VALUES (%s, %s, %s, %s)
           RETURNING *""",
        (user_id, category, limit_amount, period),
    )
    assert isinstance(row, dict)
    return row


def update(
    *,
    budget_id: str,
    user_id: str,
    payload: dict[str, Any],
) -> dict[str, Any]:
    """Partial update; raises :class:`NotFoundError` if not owned."""
    return update_owned(
        table="budgets",
        allowed_columns=UPDATABLE_COLUMNS,
        row_id=budget_id,
        user_id=user_id,
        payload=payload,
        not_found_detail="Budget not found",
    )


def delete(*, budget_id: str, user_id: str) -> None:
    """Delete; raises :class:`NotFoundError` if not owned."""
    delete_owned(
        table="budgets",
        row_id=budget_id,
        user_id=user_id,
        not_found_detail="Budget not found",
    )


# ── Bulk helpers used by the ML regenerate flow ─────────────────────────────


def replace_all_for_user(user_id: str, suggestions: list[dict[str, Any]]) -> list[dict[str, Any]]:
    """Atomically replace every budget for the user with the given suggestions.

    ``DELETE`` and the per-suggestion ``INSERT``s share one transaction so a
    failure mid-loop rolls back the delete; the user never ends up with zero
    budgets due to a partial regenerate.
    """
    created: list[dict[str, Any]] = []
    with core_db.transaction() as tx:
        tx.execute("DELETE FROM budgets WHERE user_id = %s", (user_id,))
        for s in suggestions:
            row = tx.execute(
                """INSERT INTO budgets (user_id, category, limit_amount, period)
                   VALUES (%s, %s, %s, %s)
                   RETURNING *""",
                (user_id, s["category"], s["limit_amount"], s["period"]),
            )
            assert isinstance(row, dict)
            created.append(row)
    return created
