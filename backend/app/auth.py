"""JWT helpers for authentication.

- create_token(user_id): issues a signed JWT containing sub (user id), exp, iat.
- get_current_user_id: FastAPI dependency that reads the Bearer token from the
  Authorization header, verifies it, and returns the user id. Use as
  Depends(get_current_user_id) on protected routes.

Uses HS256 and a configurable secret (JWT_SECRET env var; default is for dev only).
"""

import os
from datetime import datetime, timedelta, timezone

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

# Signing key; must match between token creation and validation. Set in production.
SECRET_KEY = os.getenv("JWT_SECRET", "dev-secret-change-in-production")
ALGORITHM = "HS256"
TOKEN_EXPIRE_HOURS = 24

# Injects Authorization: Bearer <token> into dependency; 401 if missing or invalid.
_bearer = HTTPBearer()


def create_token(user_id: str) -> str:
    """Build a JWT for the given user_id. Payload: sub=user_id, exp, iat."""
    payload = {
        "sub": user_id,
        "exp": datetime.now(timezone.utc) + timedelta(hours=TOKEN_EXPIRE_HOURS),
        "iat": datetime.now(timezone.utc),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)


def get_current_user_id(
    creds: HTTPAuthorizationCredentials = Depends(_bearer),
) -> str:
    """FastAPI dependency: validate Bearer JWT and return the subject (user id)."""
    try:
        payload = jwt.decode(
            creds.credentials, SECRET_KEY, algorithms=[ALGORITHM]
        )
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token",
            )
        return user_id
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expired",
        )
    except jwt.InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
        )
