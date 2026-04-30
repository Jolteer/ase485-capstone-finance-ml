"""Recommendation routes (``/recommendations``).

Read-only at this URL; recommendations are produced via the ML endpoints.
"""

from __future__ import annotations

from fastapi import APIRouter, Depends

from app.core.security import get_current_user_id
from app.schemas import RecommendationResponse
from app.services import recommendation_service

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.get("", response_model=list[RecommendationResponse])
def list_recommendations(user_id: str = Depends(get_current_user_id)):
    """List the user's recommendations, newest first."""
    return recommendation_service.list_recommendations(user_id)
