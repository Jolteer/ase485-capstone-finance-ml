"""Pydantic schemas grouped per domain.

Each submodule owns its own request/response models; this barrel exists only
so callers can keep ``from app.schemas import BudgetCreate`` style imports.
"""

from app.schemas.auth import (
    LoginRequest,
    RegisterRequest,
    TokenResponse,
    UserResponse,
)
from app.schemas.budgets import BudgetCreate, BudgetResponse, BudgetUpdate
from app.schemas.common import BudgetPeriod, TransactionCategory
from app.schemas.goals import GoalCreate, GoalResponse, GoalUpdate
from app.schemas.ml import CategorizeRequest, CategorizeResponse
from app.schemas.recommendations import RecommendationResponse
from app.schemas.transactions import (
    TransactionCreate,
    TransactionResponse,
    TransactionUpdate,
)

__all__ = [
    "BudgetPeriod",
    "TransactionCategory",
    "LoginRequest",
    "RegisterRequest",
    "TokenResponse",
    "UserResponse",
    "TransactionCreate",
    "TransactionResponse",
    "TransactionUpdate",
    "BudgetCreate",
    "BudgetResponse",
    "BudgetUpdate",
    "GoalCreate",
    "GoalResponse",
    "GoalUpdate",
    "RecommendationResponse",
    "CategorizeRequest",
    "CategorizeResponse",
]
