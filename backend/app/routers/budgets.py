"""Budget CRUD routes.

GET/POST /budgets, PUT/DELETE /budgets/:id. All require a valid JWT; operations
are scoped to the authenticated user.
"""

from fastapi import APIRouter, Depends, HTTPException, status

from app.auth import get_current_user_id
from app.database import execute, query
from app.schemas import BudgetCreate, BudgetResponse, BudgetUpdate

router = APIRouter(prefix="/budgets", tags=["budgets"])

# Allowed request body fields for PUT; only these columns are updated.
_BUDGET_UPDATABLE = {"category", "limit_amount", "period"}


@router.get("", response_model=list[BudgetResponse])
def list_budgets(user_id: str = Depends(get_current_user_id)):
    """List all budgets for the current user, newest first."""
    return query(
        "SELECT * FROM budgets WHERE user_id = %s ORDER BY created_at DESC",
        (user_id,),
    )


@router.post(
    "",
    response_model=BudgetResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_budget(
    body: BudgetCreate,
    user_id: str = Depends(get_current_user_id),
):
    """Create a category budget (e.g. monthly limit for Food, Entertainment)."""
    row = execute(
        """INSERT INTO budgets (user_id, category, limit_amount, period)
           VALUES (%s, %s, %s, %s)
           RETURNING *""",
        (user_id, body.category, body.limit_amount, body.period),
    )
    return row


@router.put("/{budget_id}", response_model=BudgetResponse)
def update_budget(
    budget_id: str,
    body: BudgetUpdate,
    user_id: str = Depends(get_current_user_id),
):
    """Partially update a budget. Only include fields to change; 404 if not found."""
    updates = {
        k: v
        for k, v in body.model_dump(exclude_unset=True).items()
        if k in _BUDGET_UPDATABLE
    }
    if not updates:
        raise HTTPException(status_code=400, detail="No fields to update")

    set_clause = ", ".join(f"{k} = %s" for k in updates)
    values = list(updates.values()) + [budget_id, user_id]

    row = execute(
        f"UPDATE budgets SET {set_clause} "
        "WHERE id = %s AND user_id = %s RETURNING *",
        tuple(values),
    )
    if row is None or (isinstance(row, int) and row == 0):
        raise HTTPException(status_code=404, detail="Budget not found")
    return row


@router.delete("/{budget_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_budget(
    budget_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """Delete a budget. 204 on success; 404 if id not found or not owned by user."""
    affected = execute(
        "DELETE FROM budgets WHERE id = %s AND user_id = %s",
        (budget_id, user_id),
    )
    if affected == 0:
        raise HTTPException(status_code=404, detail="Budget not found")
