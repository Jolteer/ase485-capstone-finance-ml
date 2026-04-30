"""User repository.

Reads always project a deliberate column list - never ``SELECT *`` for the
users table - because the row contains the bcrypt password hash and we don't
want it leaking into a response model by accident.
"""

from __future__ import annotations

from typing import Any

from app.core import db as core_db

# Columns that are safe to surface beyond the auth flows. The password hash is
# intentionally excluded; ``find_with_password_for_login`` returns it
# explicitly when needed.
_PUBLIC_COLUMNS = "id, email, name, created_at"


def find_by_email(email: str) -> dict[str, Any] | None:
    """Return ``{id}`` for a user with the given email, or ``None``.

    Used by the registration flow to check uniqueness without loading the
    password hash.
    """
    rows = core_db.query(
        "SELECT id FROM users WHERE email = %s",
        (email,),
    )
    return rows[0] if rows else None


def find_with_password_for_login(email: str) -> dict[str, Any] | None:
    """Return the row needed to validate a login attempt: id, email, name, password, created_at.

    The password hash is included here only because ``passlib.bcrypt.verify``
    needs it; callers must not pass the returned dict to ``UserResponse``.
    """
    rows = core_db.query(
        "SELECT id, email, name, password, created_at FROM users WHERE email = %s",
        (email,),
    )
    return rows[0] if rows else None


def create(*, email: str, name: str, password_hash: str) -> dict[str, Any]:
    """Insert a new user and return the public columns only."""
    row = core_db.execute(
        f"INSERT INTO users (email, name, password) "
        f"VALUES (%s, %s, %s) RETURNING {_PUBLIC_COLUMNS}",
        (email, name, password_hash),
    )
    # Insert with RETURNING is guaranteed to produce a row; assert for
    # static-analysis-friendly narrowing.
    assert isinstance(row, dict), "INSERT … RETURNING must produce a row"
    return row
