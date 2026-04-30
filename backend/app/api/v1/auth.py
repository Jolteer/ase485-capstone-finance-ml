"""Authentication routes (``/auth/register``, ``/auth/login``).

Both endpoints return a JWT plus the public user object. They are unauthenticated
- the returned token is what's used to authorize subsequent calls.
"""

from __future__ import annotations

from fastapi import APIRouter, status

from app.schemas import (
    LoginRequest,
    RegisterRequest,
    TokenResponse,
    UserResponse,
)
from app.services import auth_service

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post(
    "/register",
    response_model=TokenResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(body: RegisterRequest) -> TokenResponse:
    """Create a new account; returns a JWT and the new user.

    Returns 409 if the email is already in use (raised by the service via
    :class:`ConflictError` and translated by the global handler).
    """
    token, user_row = auth_service.register(
        name=body.name,
        email=body.email,
        password=body.password,
    )
    return TokenResponse(token=token, user=UserResponse(**user_row))


@router.post("/login", response_model=TokenResponse)
def login(body: LoginRequest) -> TokenResponse:
    """Authenticate by email + password; returns a JWT and the user object.

    Returns 401 ``Invalid credentials`` for both unknown email and bad
    password so the response does not leak which accounts exist.
    """
    token, user_row = auth_service.login(email=body.email, password=body.password)
    return TokenResponse(token=token, user=UserResponse(**user_row))
