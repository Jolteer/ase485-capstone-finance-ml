"""SmartSpend API – FastAPI entry point."""

from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import close_pool
from app.routers import auth, budgets, goals, recommendations, transactions


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    close_pool()


app = FastAPI(
    title="SmartSpend API",
    version="1.0.0",
    lifespan=lifespan,
)

# Allow Flutter web / mobile to call the API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount all routers under /api/v1
api = FastAPI(title="SmartSpend API v1")
api.include_router(auth.router)
api.include_router(transactions.router)
api.include_router(budgets.router)
api.include_router(goals.router)
api.include_router(recommendations.router)

app.mount("/api/v1", api)


@app.get("/health")
def health():
    return {"status": "ok"}
