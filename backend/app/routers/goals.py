"""Savings goal CRUD routes.

GET/POST /goals, PUT/DELETE /goals/:id. All require a valid JWT; goals are
scoped to the authenticated user. Goals are ordered by target_date ascending.
"""

from fastapi import APIRouter, Depends, status

from app.auth import get_current_user_id
from app.database import execute, query
from app.routers._crud import delete_owned, update_owned
from app.schemas import GoalCreate, GoalResponse, GoalUpdate

router = APIRouter(prefix="/goals", tags=["goals"])

# Allowed request body fields for PUT; only these columns are updated.
_GOAL_UPDATABLE = {"target_amount", "target_date", "description", "progress", "category"}


@router.get("", response_model=list[GoalResponse])
def list_goals(user_id: str = Depends(get_current_user_id)):
    """List all savings goals for the current user, ordered by target date (soonest first)."""
    return query(
        "SELECT * FROM goals WHERE user_id = %s ORDER BY target_date ASC",
        (user_id,),
    )


@router.post(
    "",
    response_model=GoalResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_goal(
    body: GoalCreate,
    user_id: str = Depends(get_current_user_id),
):
    """Create a savings goal (target amount, date, description, optional initial progress)."""
    return execute(
        """INSERT INTO goals (user_id, target_amount, target_date, description, progress, category)
           VALUES (%s, %s, %s, %s, %s, %s)
           RETURNING *""",
        (
            user_id,
            body.target_amount,
            body.target_date,
            body.description,
            body.progress,
            body.category,
        ),
    )


@router.put("/{goal_id}", response_model=GoalResponse)
def update_goal(
    goal_id: str,
    body: GoalUpdate,
    user_id: str = Depends(get_current_user_id),
):
    """Partially update a goal (e.g. bump progress). Only include fields to change; 404 if not found."""
    return update_owned(
        table="goals",
        allowed_columns=_GOAL_UPDATABLE,
        row_id=goal_id,
        user_id=user_id,
        payload=body.model_dump(exclude_unset=True),
        not_found_detail="Goal not found",
        execute=execute,
    )


@router.delete("/{goal_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_goal(
    goal_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """Delete a goal. 204 on success; 404 if id not found or not owned by user."""
    delete_owned(
        table="goals",
        row_id=goal_id,
        user_id=user_id,
        not_found_detail="Goal not found",
        execute=execute,
    )
