"""Shared partial-update / ownership-delete helpers.

The transactions, budgets, and goals tables all use the same
``UPDATE table SET … WHERE id = %s AND user_id = %s RETURNING *`` and
``DELETE … WHERE id = %s AND user_id = %s`` patterns. Centralising them
removes duplication and makes the ownership scoping impossible to forget.

These helpers raise :class:`app.core.exceptions.NotFoundError` /
:class:`ValidationFailedError` (instead of FastAPI ``HTTPException``) so they
remain reusable from CLI scripts, background jobs, and tests. The global
exception handler in :mod:`app.main` translates them to HTTP responses.
"""

from __future__ import annotations

from typing import Any, Callable

from app.core import db as core_db
from app.core.exceptions import NotFoundError, ValidationFailedError

# Defense in depth - even though every caller currently passes a hardcoded
# constant, the allowlist prevents accidents if a future caller is sloppy.
_ALLOWED_TABLES = {"transactions", "budgets", "goals"}

ExecuteFn = Callable[..., Any]


def _check_table(table: str) -> None:
    """Reject calls against tables this helper isn't designed for."""
    if table not in _ALLOWED_TABLES:
        raise ValueError(f"Partial-update helper used with disallowed table: {table!r}")


def update_owned(
    *,
    table: str,
    allowed_columns: set[str],
    row_id: str,
    user_id: str,
    payload: dict[str, Any],
    not_found_detail: str,
    execute: ExecuteFn | None = None,
) -> dict[str, Any]:
    """Apply a partial UPDATE scoped to ``(id, user_id)``.

    Args:
        table: One of the allowlisted table names.
        allowed_columns: Columns that may be updated; anything else in
            ``payload`` is silently ignored.
        row_id: Primary key of the row to update.
        user_id: Owner of the row; rows belonging to other users are treated
            as if they don't exist (returns 404, not 403, to avoid leaking ID
            existence).
        payload: Field-by-field updates (typically ``model_dump(exclude_unset=True)``).
        not_found_detail: Human-readable message used in the not-found error.
        execute: Optional override of the :func:`app.core.db.execute` function;
            tests use this to inject mocks. Defaults to the real executor.

    Returns:
        The updated row as a dict.

    Raises:
        ValidationFailedError: ``payload`` produced no valid fields to update.
        NotFoundError: no row matched ``(id, user_id)``.
    """
    _check_table(table)
    updates = {k: v for k, v in payload.items() if k in allowed_columns}
    if not updates:
        raise ValidationFailedError("No fields to update")

    runner: ExecuteFn = execute if execute is not None else core_db.execute

    set_clause = ", ".join(f"{k} = %s" for k in updates)
    values = list(updates.values()) + [row_id, user_id]

    row = runner(
        f"UPDATE {table} SET {set_clause} "
        "WHERE id = %s AND user_id = %s RETURNING *",
        tuple(values),
    )
    # ``row is None`` is the canonical "no row matched" signal from
    # ``core.db.execute``; the integer-zero branch covers any caller that
    # injected a mocked ``execute`` returning a row count.
    if row is None or (isinstance(row, int) and row == 0):
        raise NotFoundError(not_found_detail)
    return row


def delete_owned(
    *,
    table: str,
    row_id: str,
    user_id: str,
    not_found_detail: str,
    execute: ExecuteFn | None = None,
) -> None:
    """DELETE a row scoped to ``(id, user_id)``.

    Raises :class:`NotFoundError` if nothing matched (returns 404 from the
    API). Otherwise returns ``None``.
    """
    _check_table(table)
    runner: ExecuteFn = execute if execute is not None else core_db.execute
    affected = runner(
        f"DELETE FROM {table} WHERE id = %s AND user_id = %s",
        (row_id, user_id),
    )
    if affected == 0:
        raise NotFoundError(not_found_detail)
