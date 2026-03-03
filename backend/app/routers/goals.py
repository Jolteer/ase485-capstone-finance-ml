"""Savings goal CRUD routes.

GET/POST /goals, PUT/DELETE /goals/:id. All require a valid JWT; goals are
scoped to the authenticated user. Goals are ordered by target_date ascending.
"""

from fastapi import APIRouter, Depends, HTTPException, status

from app.auth import get_current_user_id
from app.database import execute, query
from app.schemas import GoalCreate, GoalResponse, GoalUpdate

router = APIRouter(prefix="/goals", tags=["goals"])

# Allowed request body fields for PUT; only these columns are updated.
_GOAL_UPDATABLE = {"target_amount", "target_date", "description", "progress"}


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
    row = execute(
        """INSERT INTO goals (user_id, target_amount, target_date, description, progress)
           VALUES (%s, %s, %s, %s, %s)
           RETURNING *""",
        (user_id, body.target_amount, body.target_date, body.description, body.progress),
    )
    return row


@router.put("/{goal_id}", response_model=GoalResponse)
def update_goal(
    goal_id: str,
    body: GoalUpdate,
    user_id: str = Depends(get_current_user_id),
):
    """Partially update a goal (e.g. bump progress). Only include fields to change; 404 if not found."""
    updates = {
        k: v
        for k, v in body.model_dump(exclude_unset=True).items()
        if k in _GOAL_UPDATABLE
    }
    if not updates:
        raise HTTPException(status_code=400, detail="No fields to update")

    set_clause = ", ".join(f"{k} = %s" for k in updates)
    values = list(updates.values()) + [goal_id, user_id]

    row = execute(
        f"UPDATE goals SET {set_clause} "
        "WHERE id = %s AND user_id = %s RETURNING *",
        tuple(values),
    )
    if row is None or (isinstance(row, int) and row == 0):
        raise HTTPException(status_code=404, detail="Goal not found")
    return row


@router.delete("/{goal_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_goal(
    goal_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """Delete a goal. 204 on success; 404 if id not found or not owned by user."""
    affected = execute(
        "DELETE FROM goals WHERE id = %s AND user_id = %s",
        (goal_id, user_id),
    )
    if affected == 0:
        raise HTTPException(status_code=404, detail="Goal not found")
