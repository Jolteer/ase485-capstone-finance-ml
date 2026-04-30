"""Schemas for the budgets endpoints."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field

from app.schemas.common import BudgetPeriod


class BudgetCreate(BaseModel):
    """Payload for ``POST /budgets`` (per-category spending limit)."""

    category: str = Field(..., min_length=1, max_length=50)
    limit_amount: float = Field(..., gt=0, description="Maximum spending allowed.")
    period: BudgetPeriod = BudgetPeriod.monthly


class BudgetUpdate(BaseModel):
    """Payload for ``PUT /budgets/{id}`` (partial update)."""

    model_config = ConfigDict(extra="forbid")

    category: str | None = Field(None, min_length=1, max_length=50)
    limit_amount: float | None = Field(None, gt=0)
    period: BudgetPeriod | None = None


class BudgetResponse(BaseModel):
    """Budget row as returned by the API."""

    id: str
    user_id: str
    category: str
    limit_amount: float
    period: str
    created_at: datetime
