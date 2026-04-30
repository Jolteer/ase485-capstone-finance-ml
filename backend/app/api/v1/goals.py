"""Savings goal CRUD routes (``/goals``)."""

from __future__ import annotations

from fastapi import APIRouter, Depends, status

from app.core.security import get_current_user_id
from app.schemas import GoalCreate, GoalResponse, GoalUpdate
from app.services import goal_service

router = APIRouter(prefix="/goals", tags=["goals"])


@router.get("", response_model=list[GoalResponse])
def list_goals(user_id: str = Depends(get_current_user_id)):
    """List the user's goals, soonest target date first."""
    return goal_service.list_goals(user_id)


@router.post(
    "",
    response_model=GoalResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_goal(
    body: GoalCreate,
    user_id: str = Depends(get_current_user_id),
):
    """Create a savings goal."""
    return goal_service.create_goal(
        user_id=user_id,
        target_amount=body.target_amount,
        target_date=body.target_date,
        description=body.description,
        progress=body.progress,
        category=body.category,
    )


@router.put("/{goal_id}", response_model=GoalResponse)
def update_goal(
    goal_id: str,
    body: GoalUpdate,
    user_id: str = Depends(get_current_user_id),
):
    """Partial update (e.g. bump progress); 404 if not owned by the user."""
    return goal_service.update_goal(
        goal_id=goal_id,
        user_id=user_id,
        payload=body.model_dump(exclude_unset=True),
    )


@router.delete("/{goal_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_goal(
    goal_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """Delete a goal. 204 on success; 404 if not owned by the user."""
    goal_service.delete_goal(goal_id=goal_id, user_id=user_id)
