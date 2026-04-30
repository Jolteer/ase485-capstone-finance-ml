"""Budget CRUD routes (``/budgets``)."""

from __future__ import annotations

from fastapi import APIRouter, Depends, status

from app.core.security import get_current_user_id
from app.schemas import BudgetCreate, BudgetResponse, BudgetUpdate
from app.services import budget_service

router = APIRouter(prefix="/budgets", tags=["budgets"])


@router.get("", response_model=list[BudgetResponse])
def list_budgets(user_id: str = Depends(get_current_user_id)):
    """List the user's budgets, newest first."""
    return budget_service.list_budgets(user_id)


@router.post(
    "",
    response_model=BudgetResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_budget(
    body: BudgetCreate,
    user_id: str = Depends(get_current_user_id),
):
    """Create a per-category budget."""
    return budget_service.create_budget(
        user_id=user_id,
        category=body.category,
        limit_amount=body.limit_amount,
        period=body.period.value,
    )


@router.put("/{budget_id}", response_model=BudgetResponse)
def update_budget(
    budget_id: str,
    body: BudgetUpdate,
    user_id: str = Depends(get_current_user_id),
):
    """Partial update; 404 if not owned by the user."""
    payload = body.model_dump(exclude_unset=True)
    if "period" in payload and payload["period"] is not None:
        # Pydantic gave us the enum; the SQL layer wants the string value.
        payload["period"] = payload["period"].value
    return budget_service.update_budget(
        budget_id=budget_id,
        user_id=user_id,
        payload=payload,
    )


@router.delete("/{budget_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_budget(
    budget_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """Delete a budget. 204 on success; 404 if not owned by the user."""
    budget_service.delete_budget(budget_id=budget_id, user_id=user_id)
