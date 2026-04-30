"""Application settings loaded from environment variables.

A tiny wrapper around environment variables. We intentionally keep this
hand-rolled (instead of pulling in ``pydantic-settings``) so importing the
module is cheap during tests and so the precise list of supported variables is
visible in one place.

Add new settings here rather than calling :func:`os.getenv` from scattered
modules; that keeps the configuration surface auditable.
"""

from __future__ import annotations

import os
from dataclasses import dataclass, field
from functools import lru_cache


def _split_csv(value: str | None) -> list[str]:
    """Parse a comma-separated environment value into a list of trimmed strings."""
    if not value:
        return []
    return [item.strip() for item in value.split(",") if item.strip()]


@dataclass(frozen=True)
class Settings:
    """Immutable bundle of resolved environment configuration.

    The dataclass is frozen so a stray ``settings.foo = ...`` somewhere in the
    code base raises instead of silently mutating shared state.
    """

    # ── Database ──────────────────────────────────────────────────────────
    postgres_host: str = "db"
    postgres_port: int = 5432
    postgres_db: str = "smartspend"
    postgres_user: str = "smartspend"
    postgres_password: str = "smartspend_dev"
    db_pool_min: int = 1
    db_pool_max: int = 10

    # ── Security ──────────────────────────────────────────────────────────
    jwt_secret: str = "dev-secret-change-in-production"
    jwt_algorithm: str = "HS256"
    jwt_expire_hours: int = 24

    # ── HTTP / CORS ───────────────────────────────────────────────────────
    # Browsers reject ``Access-Control-Allow-Origin: *`` together with
    # credentialed requests, so ship a sensible default origin list and let
    # operators override via CORS_ALLOWED_ORIGINS=...
    cors_allowed_origins: list[str] = field(
        default_factory=lambda: [
            "http://localhost",
            "http://localhost:3000",
            "http://localhost:8080",
            "http://127.0.0.1",
            "http://127.0.0.1:3000",
            "http://127.0.0.1:8080",
        ]
    )

    # ── Misc ──────────────────────────────────────────────────────────────
    environment: str = "development"


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return the resolved ``Settings`` for this process (cached).

    Reads environment variables on first call. Subsequent calls return the
    cached instance so tests can ``get_settings.cache_clear()`` to pick up
    monkey-patched env vars.
    """
    cors = _split_csv(os.getenv("CORS_ALLOWED_ORIGINS"))
    defaults = Settings()
    return Settings(
        postgres_host=os.getenv("POSTGRES_HOST", defaults.postgres_host),
        postgres_port=int(os.getenv("POSTGRES_PORT", str(defaults.postgres_port))),
        postgres_db=os.getenv("POSTGRES_DB", defaults.postgres_db),
        postgres_user=os.getenv("POSTGRES_USER", defaults.postgres_user),
        postgres_password=os.getenv("POSTGRES_PASSWORD", defaults.postgres_password),
        db_pool_min=int(os.getenv("DB_POOL_MIN", str(defaults.db_pool_min))),
        db_pool_max=int(os.getenv("DB_POOL_MAX", str(defaults.db_pool_max))),
        jwt_secret=os.getenv("JWT_SECRET", defaults.jwt_secret),
        jwt_algorithm=os.getenv("JWT_ALGORITHM", defaults.jwt_algorithm),
        jwt_expire_hours=int(
            os.getenv("JWT_EXPIRE_HOURS", str(defaults.jwt_expire_hours))
        ),
        cors_allowed_origins=cors or defaults.cors_allowed_origins,
        environment=os.getenv("APP_ENV", defaults.environment),
    )
