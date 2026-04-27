"""Budget CRUD routes.

GET/POST /budgets, PUT/DELETE /budgets/:id. All require a valid JWT; operations
are scoped to the authenticated user.
"""

from fastapi import APIRouter, Depends, status

from app.auth import get_current_user_id
from app.database import execute, query
from app.routers._crud import delete_owned, update_owned
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
    return execute(
        """INSERT INTO budgets (user_id, category, limit_amount, period)
           VALUES (%s, %s, %s, %s)
           RETURNING *""",
        (user_id, body.category, body.limit_amount, body.period),
    )


@router.put("/{budget_id}", response_model=BudgetResponse)
def update_budget(
    budget_id: str,
    body: BudgetUpdate,
    user_id: str = Depends(get_current_user_id),
):
    """Partially update a budget. Only include fields to change; 404 if not found."""
    return update_owned(
        table="budgets",
        allowed_columns=_BUDGET_UPDATABLE,
        row_id=budget_id,
        user_id=user_id,
        payload=body.model_dump(exclude_unset=True),
        not_found_detail="Budget not found",
        execute=execute,
    )


@router.delete("/{budget_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_budget(
    budget_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """Delete a budget. 204 on success; 404 if id not found or not owned by user."""
    delete_owned(
        table="budgets",
        row_id=budget_id,
        user_id=user_id,
        not_found_detail="Budget not found",
        execute=execute,
    )
