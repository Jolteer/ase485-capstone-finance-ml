"""Pydantic schemas for request / response validation."""

from datetime import datetime
from pydantic import BaseModel, EmailStr


# ── Auth ────────────────────────────────────────────────────────────────────
class RegisterRequest(BaseModel):
    name: str
    email: EmailStr
    password: str


class LoginRequest(BaseModel):
    email: str
    password: str


class UserResponse(BaseModel):
    id: str
    email: str
    name: str
    created_at: datetime


class TokenResponse(BaseModel):
    token: str
    user: UserResponse


# ── Transactions ────────────────────────────────────────────────────────────
class TransactionCreate(BaseModel):
    amount: float
    category: str
    description: str = ""
    date: datetime | None = None


class TransactionResponse(BaseModel):
    id: str
    user_id: str
    amount: float
    category: str
    description: str
    date: datetime


# ── Budgets ─────────────────────────────────────────────────────────────────
class BudgetCreate(BaseModel):
    category: str
    limit_amount: float
    period: str = "monthly"


class BudgetUpdate(BaseModel):
    category: str | None = None
    limit_amount: float | None = None
    period: str | None = None


class BudgetResponse(BaseModel):
    id: str
    user_id: str
    category: str
    limit_amount: float
    period: str
    created_at: datetime


# ── Goals ───────────────────────────────────────────────────────────────────
class GoalCreate(BaseModel):
    target_amount: float
    target_date: datetime
    description: str = ""
    progress: float = 0


class GoalUpdate(BaseModel):
    target_amount: float | None = None
    target_date: datetime | None = None
    description: str | None = None
    progress: float | None = None


class GoalResponse(BaseModel):
    id: str
    user_id: str
    target_amount: float
    target_date: datetime
    description: str
    progress: float


# ── Recommendations ─────────────────────────────────────────────────────────
class RecommendationResponse(BaseModel):
    id: str
    user_id: str
    category: str
    title: str
    description: str
    potential_savings: float
    created_at: datetime
