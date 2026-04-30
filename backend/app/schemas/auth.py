"""Schemas for the auth endpoints (register, login, current-user response)."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, EmailStr, Field

# Bcrypt's effective input limit is 72 bytes, but most clients send shorter
# passwords. We accept up to 128 chars and rely on bcrypt's truncation while
# enforcing a sensible minimum.
_PASSWORD_MIN = 8
_PASSWORD_MAX = 128


class RegisterRequest(BaseModel):
    """Payload for ``POST /auth/register``."""

    name: str = Field(..., min_length=1, max_length=100)
    email: EmailStr
    password: str = Field(..., min_length=_PASSWORD_MIN, max_length=_PASSWORD_MAX)


class LoginRequest(BaseModel):
    """Payload for ``POST /auth/login``."""

    email: EmailStr
    password: str = Field(..., min_length=1, max_length=_PASSWORD_MAX)


class UserResponse(BaseModel):
    """Public user object embedded inside :class:`TokenResponse`.

    NB: never load this from a raw ``SELECT *`` row - the repository projects
    only the safe columns so the password hash can never leak even if a future
    code path accidentally splats the row into the response model.
    """

    id: str
    email: str
    name: str
    created_at: datetime


class TokenResponse(BaseModel):
    """Response for ``/auth/register`` and ``/auth/login``: JWT + user."""

    token: str
    user: UserResponse
