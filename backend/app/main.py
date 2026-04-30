"""SmartSpend API - FastAPI application entry point.

Layered structure:

- :mod:`app.api`  - HTTP routers, request/response shape only.
- :mod:`app.services` - use cases (register user, regenerate budgets, …).
- :mod:`app.repositories` - SQL.
- :mod:`app.ml` - categorization + recommendation engines.
- :mod:`app.core` - cross-cutting infrastructure (DB pool, JWT, exceptions).

The root app at this module exposes ``GET /health`` and mounts the v1
sub-app at ``/api/v1``. CORS is configured from environment-driven settings
(see :mod:`app.core.config`) instead of the legacy ``allow_origins=["*"]``
which is invalid alongside ``allow_credentials=True`` in browsers.
"""

from __future__ import annotations

from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.api.v1 import build_v1_app
from app.core.config import get_settings
from app.core.db import close_pool
from app.core.exceptions import DomainError
from app.core.logging import get_logger

logger = get_logger(__name__)


@asynccontextmanager
async def lifespan(_app: FastAPI):
    """Startup/shutdown hook: close the database pool when the process exits."""
    logger.info("SmartSpend API starting")
    yield
    close_pool()
    logger.info("SmartSpend API shut down")


def _register_exception_handlers(target: FastAPI) -> None:
    """Map :class:`DomainError` to consistent JSON responses.

    Mounted on both the root app and the v1 sub-app so errors raised inside
    a route or one of its dependencies surface with the right status code
    regardless of which app is handling the request.
    """

    @target.exception_handler(DomainError)
    async def _domain_error_handler(_req: Request, exc: DomainError) -> JSONResponse:
        return JSONResponse(
            status_code=exc.status_code,
            content={"detail": exc.message},
        )


def create_app() -> FastAPI:
    """Build and configure the root FastAPI application.

    Pulled into a factory so tests can build fresh instances with monkey-patched
    settings if they ever need to.
    """
    settings = get_settings()

    root = FastAPI(
        title="SmartSpend API",
        version="1.0.0",
        lifespan=lifespan,
    )

    root.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_allowed_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    v1 = build_v1_app()
    _register_exception_handlers(root)
    _register_exception_handlers(v1)
    root.mount("/api/v1", v1)

    @root.get("/health")
    def health() -> dict[str, str]:
        """Simple liveness probe used by Docker HEALTHCHECK / uptime monitors."""
        return {"status": "ok"}

    return root


app = create_app()

# Backwards-compatible alias: tests and earlier docs imported the v1 app as
# ``app.main.api`` for ``dependency_overrides``. Expose it the same way.
api = next(
    (route.app for route in app.routes if getattr(route, "path", "") == "/api/v1"),
    None,
)
