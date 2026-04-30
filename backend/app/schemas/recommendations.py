"""Schemas for the recommendations endpoints (read-only)."""

from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel


class RecommendationResponse(BaseModel):
    """Recommendation row as returned by the API.

    Recommendations are produced by :mod:`app.ml.recommendations`; clients only
    read them.
    """

    id: str
    user_id: str
    category: str
    title: str
    description: str
    potential_savings: float
    created_at: datetime
