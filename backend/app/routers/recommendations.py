"""Recommendation routes (read-only for the client)."""

from fastapi import APIRouter, Depends

from app.auth import get_current_user_id
from app.database import query
from app.schemas import RecommendationResponse

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.get("", response_model=list[RecommendationResponse])
def list_recommendations(
    user_id: str = Depends(get_current_user_id),
):
    """Return all recommendations for the authenticated user."""
    return query(
        "SELECT * FROM recommendations WHERE user_id = %s ORDER BY created_at DESC",
        (user_id,),
    )
