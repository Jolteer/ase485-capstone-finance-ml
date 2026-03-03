"""Transaction CRUD routes.

GET/POST /transactions; GET accepts optional ?category=. PUT/DELETE /transactions/:id.
Every endpoint requires a valid JWT (user_id from token scopes all operations).
"""

from fastapi import APIRouter, Depends, HTTPException, Query, status

from app.auth import get_current_user_id
from app.database import execute, query
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
    """Create a transaction. date defaults to now if omitted."""
    row = execute(
        """INSERT INTO transactions (user_id, amount, category, description, date)
           VALUES (%s, %s, %s, %s, COALESCE(%s, now()))
           RETURNING *""",
        (user_id, body.amount, body.category, body.description, body.date),
    )
    return row


@router.put("/{transaction_id}", response_model=TransactionResponse)
def update_transaction(
    transaction_id: str,
    body: TransactionUpdate,
    user_id: str = Depends(get_current_user_id),
):
    """Partially update a transaction. Only send fields that should change; 404 if not found."""
    updates = {
        k: v
        for k, v in body.model_dump(exclude_unset=True).items()
        if k in _TRANSACTION_UPDATABLE
    }
    if not updates:
        raise HTTPException(status_code=400, detail="No fields to update")

    set_clause = ", ".join(f"{k} = %s" for k in updates)
    values = list(updates.values()) + [transaction_id, user_id]

    row = execute(
        f"UPDATE transactions SET {set_clause} "
        "WHERE id = %s AND user_id = %s RETURNING *",
        tuple(values),
    )
    if row is None or (isinstance(row, int) and row == 0):
        raise HTTPException(status_code=404, detail="Transaction not found")
    return row


@router.delete("/{transaction_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_transaction(
    transaction_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """Delete a transaction. Returns 204 on success; 404 if id not found or not owned by user."""
    affected = execute(
        "DELETE FROM transactions WHERE id = %s AND user_id = %s",
        (transaction_id, user_id),
    )
    if affected == 0:
        raise HTTPException(status_code=404, detail="Transaction not found")
