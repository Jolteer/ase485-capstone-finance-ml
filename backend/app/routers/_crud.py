"""Internal CRUD helpers shared by transactions, budgets, and goals routers.

These deduplicate the partial-update + ownership-delete pattern. Callers pass
their module-level ``execute`` reference so test patches on
``app.routers.<feature>.execute`` continue to intercept the call.
"""

from typing import Any, Callable

from fastapi import HTTPException, status

# Tables this module is allowed to touch. Defense in depth: even though callers
# only pass hardcoded strings today, the allowlist prevents accidents if a
# future caller passes user-controlled input.
_ALLOWED_TABLES = {"transactions", "budgets", "goals"}

ExecuteFn = Callable[..., Any]


def _check_table(table: str) -> None:
    if table not in _ALLOWED_TABLES:
        raise ValueError(f"CRUD helper used with disallowed table: {table!r}")


def update_owned(
    *,
    table: str,
    allowed_columns: set[str],
    row_id: str,
    user_id: str,
    payload: dict[str, Any],
    not_found_detail: str,
    execute: ExecuteFn,
) -> dict[str, Any]:
    """Apply a partial UPDATE scoped to (id, user_id); return the row or raise.

    Only keys in *allowed_columns* are written. Raises 400 if no valid fields
    remain after filtering, 404 if no row matches.
    """
    _check_table(table)
    updates = {k: v for k, v in payload.items() if k in allowed_columns}
    if not updates:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No fields to update",
        )

    set_clause = ", ".join(f"{k} = %s" for k in updates)
    values = list(updates.values()) + [row_id, user_id]

    row = execute(
        f"UPDATE {table} SET {set_clause} "
        "WHERE id = %s AND user_id = %s RETURNING *",
        tuple(values),
    )
    if row is None or (isinstance(row, int) and row == 0):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=not_found_detail,
        )
    return row


def delete_owned(
    *,
    table: str,
    row_id: str,
    user_id: str,
    not_found_detail: str,
    execute: ExecuteFn,
) -> None:
    """DELETE a row scoped to (id, user_id); raise 404 if nothing matched."""
    _check_table(table)
    affected = execute(
        f"DELETE FROM {table} WHERE id = %s AND user_id = %s",
        (row_id, user_id),
    )
    if affected == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=not_found_detail,
        )
