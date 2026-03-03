"""SmartSpend API – FastAPI application entry point.

- Root app: CORS middleware, /health endpoint, and a lifespan that closes the
  database pool on shutdown.
- All v1 endpoints live under /api/v1: auth, transactions, budgets, goals,
  recommendations. Each router defines its own prefix and tags.
"""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import close_pool
from app.routers import auth, budgets, goals, recommendations, transactions


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Run on startup (yield) and shutdown: close the PostgreSQL connection pool."""
    yield
    close_pool()


app = FastAPI(
    title="SmartSpend API",
    version="1.0.0",
    lifespan=lifespan,
)

# Allow browser and mobile clients (e.g. Flutter) to call this API from any origin.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# v1 API: separate FastAPI app so all routes are under /api/v1/*.
api = FastAPI(title="SmartSpend API v1")
api.include_router(auth.router)           # /api/v1/auth
api.include_router(transactions.router)  # /api/v1/transactions
api.include_router(budgets.router)       # /api/v1/budgets
api.include_router(goals.router)        # /api/v1/goals
api.include_router(recommendations.router)  # /api/v1/recommendations

app.mount("/api/v1", api)


@app.get("/health")
def health():
    """Simple liveness/readiness check (e.g. for Docker HEALTHCHECK or load balancers)."""
    return {"status": "ok"}
