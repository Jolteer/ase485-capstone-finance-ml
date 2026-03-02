"""Goal CRUD routes."""

from fastapi import APIRouter, Depends, HTTPException, status

from app.auth import get_current_user_id
from app.database import execute, query
from app.schemas import GoalCreate, GoalResponse, GoalUpdate

router = APIRouter(prefix="/goals", tags=["goals"])

# Columns that may be updated dynamically.
_GOAL_UPDATABLE = {"target_amount", "target_date", "description", "progress"}


@router.get("", response_model=list[GoalResponse])
def list_goals(user_id: str = Depends(get_current_user_id)):
    """Return all goals for the authenticated user."""
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
    """Create a new savings goal."""
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
    """Partially update a goal (only provided fields)."""
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
    """Delete a goal by ID."""
    affected = execute(
        "DELETE FROM goals WHERE id = %s AND user_id = %s",
        (goal_id, user_id),
    )
    if affected == 0:
        raise HTTPException(status_code=404, detail="Goal not found")
