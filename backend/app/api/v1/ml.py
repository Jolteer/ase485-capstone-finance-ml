"""ML-powered routes (``/ml/categorize``, ``/ml/budgets/generate``, ``/ml/recommendations/generate``)."""

from __future__ import annotations

from fastapi import APIRouter, Depends

from app.core.security import get_current_user_id
from app.schemas import (
    BudgetResponse,
    CategorizeRequest,
    CategorizeResponse,
    RecommendationResponse,
)
from app.services import ml_orchestration

router = APIRouter(prefix="/ml", tags=["ml"])


@router.post("/categorize", response_model=CategorizeResponse)
def categorize_transaction(
    body: CategorizeRequest,
    _user_id: str = Depends(get_current_user_id),
) -> CategorizeResponse:
    """Predict a category for a transaction description.

    Auth is required to keep usage scoped to logged-in users (and to give us a
    place to add per-user rate limiting later) but the response doesn't depend
    on which user is asking.
    """
    category, confidence = ml_orchestration.categorize(body.description)
    return CategorizeResponse(category=category, confidence=confidence)


@router.post("/budgets/generate", response_model=list[BudgetResponse])
def generate_budget_suggestions(
    user_id: str = Depends(get_current_user_id),
):
    """Replace the user's budgets with ML-derived suggestions from history.

    400 if the user has no transactions or no expense data; 200 with the new
    list otherwise.
    """
    return ml_orchestration.regenerate_budgets(user_id)


@router.post(
    "/recommendations/generate",
    response_model=list[RecommendationResponse],
)
def generate_recommendation_suggestions(
    user_id: str = Depends(get_current_user_id),
):
    """Replace the user's recommendations with freshly generated ones."""
    return ml_orchestration.regenerate_recommendations(user_id)
