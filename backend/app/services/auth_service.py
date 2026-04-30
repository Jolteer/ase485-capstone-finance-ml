"""Authentication use cases: register and login."""

from __future__ import annotations

from typing import Any

from app.core.exceptions import ConflictError, UnauthorizedError
from app.core.security import create_token, hash_password, verify_password
from app.repositories import users as users_repo


def register(*, name: str, email: str, password: str) -> tuple[str, dict[str, Any]]:
    """Create a new user account.

    Returns ``(jwt_token, public_user_row)``. Raises :class:`ConflictError`
    if the email is already registered.

    The repository projects only public columns so the caller cannot
    accidentally surface the bcrypt hash.
    """
    if users_repo.find_by_email(email):
        raise ConflictError("Email already registered")
    user_row = users_repo.create(
        email=email,
        name=name,
        password_hash=hash_password(password),
    )
    token = create_token(user_row["id"])
    return token, user_row


def login(*, email: str, password: str) -> tuple[str, dict[str, Any]]:
    """Authenticate by email/password and return ``(jwt_token, public_user_row)``.

    Uses the same generic 401 message for both unknown email and bad password
    so callers cannot enumerate registered accounts via the error text.
    """
    row = users_repo.find_with_password_for_login(email)
    if row is None or not verify_password(password, row["password"]):
        raise UnauthorizedError("Invalid credentials")
    token = create_token(row["id"])
    public = {
        "id": row["id"],
        "email": row["email"],
        "name": row["name"],
        "created_at": row["created_at"],
    }
    return token, public
