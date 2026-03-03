"""Pydantic schemas for request body and response validation.

Used by FastAPI for request body parsing and response_model serialization. Field
names use snake_case to match the API and database. Sections: Auth, Transactions,
Budgets, Goals, Recommendations.
"""

from datetime import datetime
from pydantic import BaseModel, EmailStr


# ── Auth ────────────────────────────────────────────────────────────────────

class RegisterRequest(BaseModel):
    """Request body for POST /auth/register."""

    name: str
    email: EmailStr
    password: str


class LoginRequest(BaseModel):
    """Request body for POST /auth/login."""

    email: str
    password: str


class UserResponse(BaseModel):
    """User object in API responses (e.g. inside TokenResponse)."""

    id: str
    email: str
    name: str
    created_at: datetime


class TokenResponse(BaseModel):
    """Response for register and login: JWT string and user object."""

    token: str
    user: UserResponse


# ── Transactions ────────────────────────────────────────────────────────────

class TransactionCreate(BaseModel):
    """Request body for POST /transactions. amount: positive = income, negative = expense."""

    amount: float
    category: str
    description: str = ""
    date: datetime | None = None  # Defaults to now on the server if omitted


class TransactionUpdate(BaseModel):
    """Request body for PUT /transactions/:id. Only include fields to change (partial update)."""

    amount: float | None = None
    category: str | None = None
    description: str | None = None
    date: datetime | None = None


class TransactionResponse(BaseModel):
    """Transaction as returned by the API (includes id and user_id)."""

    id: str
    user_id: str
    amount: float
    category: str
    description: str
    date: datetime


# ── Budgets ─────────────────────────────────────────────────────────────────

class BudgetCreate(BaseModel):
    """Request body for POST /budgets. period is typically 'monthly' or 'weekly'."""

    category: str
    limit_amount: float
    period: str = "monthly"


class BudgetUpdate(BaseModel):
    """Request body for PUT /budgets/:id. Only include fields to change."""

    category: str | None = None
    limit_amount: float | None = None
    period: str | None = None


class BudgetResponse(BaseModel):
    """Budget as returned by the API."""

    id: str
    user_id: str
    category: str
    limit_amount: float
    period: str
    created_at: datetime


# ── Goals ───────────────────────────────────────────────────────────────────

class GoalCreate(BaseModel):
    """Request body for POST /goals. progress is current amount saved toward the goal."""

    target_amount: float
    target_date: datetime
    description: str = ""
    progress: float = 0


class GoalUpdate(BaseModel):
    """Request body for PUT /goals/:id. Only include fields to change."""

    target_amount: float | None = None
    target_date: datetime | None = None
    description: str | None = None
    progress: float | None = None


class GoalResponse(BaseModel):
    """Savings goal as returned by the API."""

    id: str
    user_id: str
    target_amount: float
    target_date: datetime
    description: str
    progress: float


# ── Recommendations ─────────────────────────────────────────────────────────

class RecommendationResponse(BaseModel):
    """Recommendation as returned by the API. Read-only; created by backend/ML, not by client."""

    id: str
    user_id: str
    category: str
    title: str
    description: str
    potential_savings: float
    created_at: datetime
