"""Transaction repository - SQL for the transactions table."""

from __future__ import annotations

from datetime import datetime
from typing import Any

from app.core import db as core_db
from app.repositories._partial_update import delete_owned, update_owned

# Columns the API exposes via ``PUT /transactions/{id}``. Anything outside
# this set in the request payload is ignored.
UPDATABLE_COLUMNS: set[str] = {"amount", "category", "description", "date"}


def list_for_user(
    user_id: str,
    *,
    category: str | None = None,
) -> list[dict[str, Any]]:
    """Return the user's transactions, newest first; optional category filter."""
    sql = "SELECT * FROM transactions WHERE user_id = %s"
    params: list[Any] = [user_id]
    if category:
        sql += " AND category = %s"
        params.append(category)
    sql += " ORDER BY date DESC"
    rows = core_db.query(sql, tuple(params))
    return rows or []  # core_db.query returns None only for non-SELECT misuse.


def create(
    *,
    user_id: str,
    amount: float,
    category: str,
    description: str,
    date: datetime | None,
) -> dict[str, Any]:
    """Insert a transaction and return the new row.

    ``date`` may be ``None``; PostgreSQL's ``COALESCE`` defaults it to ``now()``.
    """
    row = core_db.execute(
        """INSERT INTO transactions (user_id, amount, category, description, date)
           VALUES (%s, %s, %s, %s, COALESCE(%s, now()))
           RETURNING *""",
        (user_id, amount, category, description, date),
    )
    assert isinstance(row, dict)
    return row


def update(
    *,
    transaction_id: str,
    user_id: str,
    payload: dict[str, Any],
) -> dict[str, Any]:
    """Partial update; raises :class:`NotFoundError` if not owned."""
    return update_owned(
        table="transactions",
        allowed_columns=UPDATABLE_COLUMNS,
        row_id=transaction_id,
        user_id=user_id,
        payload=payload,
        not_found_detail="Transaction not found",
    )


def delete(*, transaction_id: str, user_id: str) -> None:
    """Delete; raises :class:`NotFoundError` if not owned."""
    delete_owned(
        table="transactions",
        row_id=transaction_id,
        user_id=user_id,
        not_found_detail="Transaction not found",
    )
