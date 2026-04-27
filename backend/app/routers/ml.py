"""ML-powered endpoints: categorization, budget generation, recommendation generation.

All endpoints require a valid JWT. These supplement the existing CRUD routers with
intelligent features backed by app.ml_engine.
"""

from fastapi import APIRouter, Depends, HTTPException

from app.auth import get_current_user_id
from app.database import execute, query
from app.ml_engine import (
    generate_budgets,
    generate_recommendations,
    predict_category_with_confidence,
)
from app.schemas import (
    BudgetResponse,
    CategorizeRequest,
    CategorizeResponse,
    RecommendationResponse,
)

router = APIRouter(prefix="/ml", tags=["ml"])


@router.post("/categorize", response_model=CategorizeResponse)
def categorize_transaction(
    body: CategorizeRequest,
    _user_id: str = Depends(get_current_user_id),
):
    """Predict the category for a transaction description using the ML model."""
    category, confidence = predict_category_with_confidence(body.description)
    return CategorizeResponse(category=category, confidence=round(confidence, 4))


@router.post("/budgets/generate", response_model=list[BudgetResponse])
def generate_budget_suggestions(
    user_id: str = Depends(get_current_user_id),
):
    """Analyse the user's transaction history and generate suggested budgets.

    Deletes existing budgets and replaces them with ML-generated ones.
    """
    rows = query(
        "SELECT * FROM transactions WHERE user_id = %s ORDER BY date DESC",
        (user_id,),
    )
    if not rows:
        raise HTTPException(status_code=400, detail="No transactions to analyse")

    suggestions = generate_budgets(rows)
    if not suggestions:
        raise HTTPException(
            status_code=400,
            detail="Not enough expense data to generate budgets",
        )

    execute("DELETE FROM budgets WHERE user_id = %s", (user_id,))

    created: list[dict] = []
    for s in suggestions:
        row = execute(
            """INSERT INTO budgets (user_id, category, limit_amount, period)
               VALUES (%s, %s, %s, %s)
               RETURNING *""",
            (user_id, s["category"], s["limit_amount"], s["period"]),
        )
        created.append(row)

    return created


@router.post("/recommendations/generate", response_model=list[RecommendationResponse])
def generate_recommendation_suggestions(
    user_id: str = Depends(get_current_user_id),
):
    """Analyse spending patterns and generate personalised savings recommendations.

    Deletes old recommendations and replaces them with freshly generated ones.
    """
    txn_rows = query(
        "SELECT * FROM transactions WHERE user_id = %s ORDER BY date DESC",
        (user_id,),
    )
    budget_rows = query(
        "SELECT * FROM budgets WHERE user_id = %s",
        (user_id,),
    )
    if not txn_rows:
        raise HTTPException(status_code=400, detail="No transactions to analyse")

    suggestions = generate_recommendations(txn_rows, budget_rows or [])

    execute("DELETE FROM recommendations WHERE user_id = %s", (user_id,))

    created: list[dict] = []
    for s in suggestions:
        row = execute(
            """INSERT INTO recommendations
                   (user_id, category, title, description, potential_savings)
               VALUES (%s, %s, %s, %s, %s)
               RETURNING *""",
            (user_id, s["category"], s["title"], s["description"],
             s["potential_savings"]),
        )
        created.append(row)

    return created
