"""Schemas for the goals endpoints."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class GoalCreate(BaseModel):
    """Payload for ``POST /goals``.

    ``progress`` is the amount already saved toward the goal at creation time
    (defaults to 0). ``category`` is a free-form label - "Vacation",
    "Emergency Fund", etc. - and is intentionally separate from the
    transaction category enum.
    """

    target_amount: float = Field(..., gt=0)
    target_date: datetime
    description: str = Field("", max_length=200)
    progress: float = Field(0, ge=0)
    category: str = Field("Other", max_length=50)


class GoalUpdate(BaseModel):
    """Payload for ``PUT /goals/{id}`` (partial update)."""

    model_config = ConfigDict(extra="forbid")

    target_amount: float | None = Field(None, gt=0)
    target_date: datetime | None = None
    description: str | None = Field(None, max_length=200)
    progress: float | None = Field(None, ge=0)
    category: str | None = Field(None, max_length=50)


class GoalResponse(BaseModel):
    """Goal row as returned by the API."""

    id: str
    user_id: str
    target_amount: float
    target_date: datetime
    description: str
    progress: float
    category: str
