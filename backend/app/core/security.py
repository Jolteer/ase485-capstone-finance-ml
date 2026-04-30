"""JWT issuance/verification and FastAPI auth dependency.

Centralises everything related to "who is the caller":

- :func:`create_token` mints a short-lived JWT for a known user id.
- :func:`get_current_user_id` is a FastAPI ``Depends`` that extracts and
  verifies the Bearer token; protected routes use it to scope queries.
- :func:`hash_password` / :func:`verify_password` wrap ``passlib``'s bcrypt
  helpers so callers don't import bcrypt directly.

We use HS256 with a configurable secret. The default secret is intentionally
obvious so a missing ``JWT_SECRET`` at deploy time is loud during smoke tests
rather than silently using a "real" key.
"""

from __future__ import annotations

from datetime import datetime, timedelta, timezone

import bcrypt
import jwt
from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.core.config import get_settings
from app.core.exceptions import UnauthorizedError

# Bearer extraction. ``auto_error=False`` would let us return our own 401
# message but the default behaviour is fine here: missing/invalid header
# triggers HTTPBearer's own 403, which the global handler can normalize.
_bearer = HTTPBearer()


def create_token(user_id: str) -> str:
    """Build a JWT for the given user id.

    Payload: ``sub`` = user id, ``exp`` = expiry, ``iat`` = issued-at.
    """
    s = get_settings()
    now = datetime.now(timezone.utc)
    payload = {
        "sub": user_id,
        "iat": now,
        "exp": now + timedelta(hours=s.jwt_expire_hours),
    }
    return jwt.encode(payload, s.jwt_secret, algorithm=s.jwt_algorithm)


def decode_token(token: str) -> str:
    """Verify a JWT and return the subject (user id).

    Raises :class:`UnauthorizedError` when the token is missing the subject,
    expired, or otherwise invalid. Callers in the API layer let the global
    handler convert this to HTTP 401.
    """
    s = get_settings()
    try:
        payload = jwt.decode(token, s.jwt_secret, algorithms=[s.jwt_algorithm])
    except jwt.ExpiredSignatureError as exc:
        raise UnauthorizedError("Token expired") from exc
    except jwt.InvalidTokenError as exc:
        raise UnauthorizedError("Invalid token") from exc
    user_id = payload.get("sub")
    if not user_id:
        raise UnauthorizedError("Invalid token")
    return str(user_id)


def get_current_user_id(
    creds: HTTPAuthorizationCredentials = Depends(_bearer),
) -> str:
    """FastAPI dependency: validate the Bearer JWT and return the user id."""
    return decode_token(creds.credentials)


# ── Passwords ───────────────────────────────────────────────────────────────

# bcrypt only consumes the first 72 bytes of input; bcrypt 4.x raises
# ValueError on longer inputs instead of silently truncating like the older
# versions passlib was written against. Schemas already cap password length
# at 128 chars, so explicit truncation only clips multi-byte UTF-8 strings.
_BCRYPT_MAX_BYTES = 72


def _truncate_for_bcrypt(plaintext: str) -> bytes:
    return plaintext.encode("utf-8")[:_BCRYPT_MAX_BYTES]


def hash_password(plaintext: str) -> str:
    """Hash a plaintext password using bcrypt (UTF-8 + safe 72-byte truncation)."""
    return bcrypt.hashpw(_truncate_for_bcrypt(plaintext), bcrypt.gensalt()).decode(
        "utf-8"
    )


def verify_password(plaintext: str, hashed: str) -> bool:
    """Constant-time check that ``plaintext`` matches the stored bcrypt hash."""
    try:
        return bcrypt.checkpw(_truncate_for_bcrypt(plaintext), hashed.encode("utf-8"))
    except ValueError:
        # Hash wasn't a valid bcrypt string; treat as a bad password.
        return False
