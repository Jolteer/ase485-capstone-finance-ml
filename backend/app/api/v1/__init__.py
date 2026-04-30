"""Aggregator for v1 API routers.

:func:`build_v1_app` wires every router into a single FastAPI sub-application
mounted at ``/api/v1`` by :mod:`app.main`. Keeping the wiring in a builder
function makes it trivial to mount the same routes under a test client without
re-declaring CORS or exception handlers.
"""

from __future__ import annotations

from fastapi import FastAPI

from app.api.v1 import auth, budgets, goals, ml, recommendations, transactions


def build_v1_app() -> FastAPI:
    """Return a FastAPI sub-application with every v1 router included."""
    api = FastAPI(title="SmartSpend API v1")
    api.include_router(auth.router)
    api.include_router(transactions.router)
    api.include_router(budgets.router)
    api.include_router(goals.router)
    api.include_router(recommendations.router)
    api.include_router(ml.router)
    return api
