"""Domain-level exceptions that services and repositories raise.

The HTTP layer (``app.api``) is the only place that knows about
``fastapi.HTTPException``; everywhere else raises one of these typed errors and
the global exception handlers in :mod:`app.main` translate them to the right
status codes.

Why this matters: services and repositories can be reused from CLI scripts,
background jobs, or tests without having to deal with the FastAPI request
context. They also become trivial to mock in unit tests because the failure
modes are explicit Python types instead of "something raised an HTTPException
deep inside SQL execution".
"""

from __future__ import annotations


class DomainError(Exception):
    """Base class for errors that should map cleanly to HTTP responses.

    Subclasses set ``status_code`` and ``default_message`` so the global
    handler can produce a consistent JSON body (``{"detail": "..."}``) without
    coupling business logic to FastAPI types.
    """

    status_code: int = 500
    default_message: str = "Internal server error"

    def __init__(self, message: str | None = None) -> None:
        super().__init__(message or self.default_message)
        self.message = message or self.default_message


class NotFoundError(DomainError):
    """Resource does not exist or is not visible to the current user.

    We deliberately use the same error for "doesn't exist" and "exists but
    belongs to someone else" so callers cannot probe for other users' IDs.
    """

    status_code = 404
    default_message = "Resource not found"


class ConflictError(DomainError):
    """A conflicting resource already exists (e.g. duplicate email)."""

    status_code = 409
    default_message = "Conflict"


class ValidationFailedError(DomainError):
    """Caller supplied data that the domain rejected (e.g. nothing to update)."""

    status_code = 400
    default_message = "Invalid request"


class UnauthorizedError(DomainError):
    """Authentication failed or wasn't provided for a protected operation."""

    status_code = 401
    default_message = "Unauthorized"
