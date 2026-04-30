"""Schemas for the ML endpoints (categorize, regenerate budgets/recommendations)."""

from __future__ import annotations

from pydantic import BaseModel, Field


class CategorizeRequest(BaseModel):
    """Payload for ``POST /ml/categorize`` - free-form transaction description."""

    description: str = Field(..., min_length=1, max_length=500)


class CategorizeResponse(BaseModel):
    """Predicted category and the model's confidence (max class probability)."""

    category: str
    confidence: float = Field(..., ge=0.0, le=1.0)
