"""Transaction CRUD routes (``/transactions``)."""

from __future__ import annotations

from fastapi import APIRouter, Depends, Query, status

from app.core.security import get_current_user_id
from app.schemas import TransactionCreate, TransactionResponse, TransactionUpdate
from app.services import transaction_service

router = APIRouter(prefix="/transactions", tags=["transactions"])


@router.get("", response_model=list[TransactionResponse])
def list_transactions(
    category: str | None = Query(None, description="Filter by category name"),
    user_id: str = Depends(get_current_user_id),
):
    """List the current user's transactions, newest first; optional category filter."""
    return transaction_service.list_transactions(user_id, category=category)


@router.post(
    "",
    response_model=TransactionResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_transaction(
    body: TransactionCreate,
    user_id: str = Depends(get_current_user_id),
):
    """Create a transaction; ML categorizes from description when category is empty."""
    return transaction_service.create_transaction(
        user_id=user_id,
        amount=body.amount,
        category=body.category,
        description=body.description,
        date=body.date,
    )


@router.put("/{transaction_id}", response_model=TransactionResponse)
def update_transaction(
    transaction_id: str,
    body: TransactionUpdate,
    user_id: str = Depends(get_current_user_id),
):
    """Partial update; 404 when the row is not owned by the user."""
    return transaction_service.update_transaction(
        transaction_id=transaction_id,
        user_id=user_id,
        payload=body.model_dump(exclude_unset=True),
    )


@router.delete("/{transaction_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_transaction(
    transaction_id: str,
    user_id: str = Depends(get_current_user_id),
):
    """Delete a transaction. 204 on success; 404 if id not owned by the user."""
    transaction_service.delete_transaction(
        transaction_id=transaction_id,
        user_id=user_id,
    )
