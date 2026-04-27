"""Transaction CRUD routes.

GET/POST /transactions; GET accepts optional ?category=. PUT/DELETE /transactions/:id.
Every endpoint requires a valid JWT (user_id from token scopes all operations).
"""

from fastapi import APIRouter, Depends, Query, status

from app.auth import get_current_user_id
from app.database import execute, query
from app.ml_engine import predict_category
from app.routers._crud import delete_owned, update_owned
from app.schemas import TransactionCreate, TransactionResponse, TransactionUpdate

router = APIRouter(prefix="/transactions", tags=["transactions"])

# Fields that may be updated via PUT; id and user_id are never accepted from the body.
_TRANSACTION_UPDATABLE = {"amount", "category", "description", "date"}


@router.get("", response_model=list[TransactionResponse])
def list_transactions(
    category: str | None = Query(None, description="Filter by category name"),
    user_id: str = Depends(get_current_user_id),
):
    """List the current user's transactions, newest first. Optional category filter."""
    sql = "SELECT * FROM transactions WHERE user_id = %s"
    params: list = [user_id]
    if category:
        sql += " AND category = %s"
        params.append(category)
    sql += " ORDER BY date DESC"
    return query(sql, tuple(params))


@router.post(
    "",
    response_model=TransactionResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_transaction(
    body: TransactionCreate,
    user_id: str = Depends(get_current_user_id),
):
    """Create a transaction. date defaults to now if omitted.

    When category is empty the ML model auto-categorises from description.
    """
    category = body.category or predict_category(body.description)

    return execute(
        """INSERT INTO transactions (user_id, amount, category, description, date)
           VALUES (%s, %s, %s, %s, COALESCE(%s, now()))
           RETURNING *""",
        (user_id, body.amount, category, body.description, body.date),
    )


@router.put("/{transaction_id}", response_model=TransactionResponse)
def update_transaction(
    transaction_id: str,
    body: TransactionUpdate,
    user_id: str = Depends(get_current_user_id),
):
    """Partially update a transaction. Only send fields that should change; 404 if not found."""
    return update_owned(
        table="transactions",
        allowed_columns=_TRANSACTION_UPDATABLE,
        row_id=transaction_id,
        user_id=user_id,
        payload=body.model_dump(exclude_unset=True),
        not_found_detail="Transaction not found",
        execute=execute,
    )


@router.delete("/{transaction_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_transaction(
    transaction_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """Delete a transaction. Returns 204 on success; 404 if id not found or not owned by user."""
    delete_owned(
        table="transactions",
        row_id=transaction_id,
        user_id=user_id,
        not_found_detail="Transaction not found",
        execute=execute,
    )
