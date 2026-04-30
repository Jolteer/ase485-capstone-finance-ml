"""Schemas for the transactions endpoints."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class TransactionCreate(BaseModel):
    """Payload for ``POST /transactions``.

    ``amount`` follows the convention used throughout the app: positive values
    are income, negative values are expenses.

    When ``category`` is omitted or empty the ML categorizer infers one from
    ``description``. ``date`` defaults to ``now()`` in PostgreSQL when omitted.
    """

    amount: float = Field(..., description="Positive = income, negative = expense.")
    category: str = Field("", max_length=50)
    description: str = Field("", max_length=500)
    date: datetime | None = None


class TransactionUpdate(BaseModel):
    """Payload for ``PUT /transactions/{id}`` (partial update; only send what changes)."""

    model_config = ConfigDict(extra="forbid")

    amount: float | None = None
    category: str | None = Field(None, max_length=50)
    description: str | None = Field(None, max_length=500)
    date: datetime | None = None


class TransactionResponse(BaseModel):
    """Transaction row as returned by the API."""

    id: str
    user_id: str
    amount: float
    category: str
    description: str
    date: datetime
