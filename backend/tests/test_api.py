"""End-to-end API tests using FastAPI's TestClient.

Repository functions are mocked so the suite runs without PostgreSQL. The
auth dependency is overridden in :mod:`tests.conftest` so every request
appears authenticated as ``MOCK_USER_ID``.
"""

from __future__ import annotations

from unittest.mock import patch

from fastapi.testclient import TestClient

from app.core.exceptions import NotFoundError
from app.main import app

from tests.conftest import MOCK_USER_ID

client = TestClient(app)


# ── Health & docs ───────────────────────────────────────────────────────────


class TestHealthAndDocs:
    def test_health(self):
        res = client.get("/health")
        assert res.status_code == 200
        assert res.json() == {"status": "ok"}

    def test_openapi_schema(self):
        res = client.get("/api/v1/openapi.json")
        assert res.status_code == 200
        assert "paths" in res.json()


# ── Auth ────────────────────────────────────────────────────────────────────


class TestAuth:
    @patch("app.services.auth_service.users_repo.create")
    @patch("app.services.auth_service.users_repo.find_by_email")
    def test_register_success(self, mock_find, mock_create):
        mock_find.return_value = None
        mock_create.return_value = {
            "id": "u1",
            "email": "new@example.com",
            "name": "New",
            "created_at": "2026-04-01T00:00:00+00:00",
        }
        res = client.post(
            "/api/v1/auth/register",
            json={
                "name": "New",
                "email": "new@example.com",
                "password": "supersecret",
            },
        )
        assert res.status_code == 201
        body = res.json()
        assert body["user"]["email"] == "new@example.com"
        assert "token" in body
        assert "password" not in body["user"]

    @patch("app.services.auth_service.users_repo.find_by_email")
    def test_register_duplicate_returns_409(self, mock_find):
        mock_find.return_value = {"id": "u1"}
        res = client.post(
            "/api/v1/auth/register",
            json={
                "name": "Dup",
                "email": "dup@example.com",
                "password": "supersecret",
            },
        )
        assert res.status_code == 409
        assert "already" in res.json()["detail"].lower()

    @patch("app.services.auth_service.users_repo.find_with_password_for_login")
    def test_login_success(self, mock_find):
        from app.core.security import hash_password

        mock_find.return_value = {
            "id": "u1",
            "email": "user@example.com",
            "name": "User",
            "password": hash_password("supersecret"),
            "created_at": "2026-04-01T00:00:00+00:00",
        }
        res = client.post(
            "/api/v1/auth/login",
            json={"email": "user@example.com", "password": "supersecret"},
        )
        assert res.status_code == 200
        assert res.json()["user"]["email"] == "user@example.com"

    @patch("app.services.auth_service.users_repo.find_with_password_for_login")
    def test_login_unknown_email_returns_401(self, mock_find):
        mock_find.return_value = None
        res = client.post(
            "/api/v1/auth/login",
            json={"email": "missing@example.com", "password": "supersecret"},
        )
        assert res.status_code == 401

    @patch("app.services.auth_service.users_repo.find_with_password_for_login")
    def test_login_bad_password_returns_401(self, mock_find):
        from app.core.security import hash_password

        mock_find.return_value = {
            "id": "u1",
            "email": "user@example.com",
            "name": "User",
            "password": hash_password("rightpassword"),
            "created_at": "2026-04-01T00:00:00+00:00",
        }
        res = client.post(
            "/api/v1/auth/login",
            json={"email": "user@example.com", "password": "wrongpassword"},
        )
        assert res.status_code == 401

    def test_register_short_password_rejected(self):
        res = client.post(
            "/api/v1/auth/register",
            json={"name": "X", "email": "x@example.com", "password": "short"},
        )
        # Pydantic length validation -> 422
        assert res.status_code == 422


# ── Transactions ────────────────────────────────────────────────────────────


class TestTransactions:
    @patch("app.repositories.transactions.list_for_user")
    def test_list_transactions(self, mock_list):
        mock_list.return_value = [
            {
                "id": "t1",
                "user_id": MOCK_USER_ID,
                "amount": -50.0,
                "category": "Food",
                "description": "Grocery",
                "date": "2026-04-01T00:00:00+00:00",
            }
        ]
        res = client.get("/api/v1/transactions")
        assert res.status_code == 200
        assert res.json()[0]["category"] == "Food"

    @patch("app.repositories.transactions.create")
    def test_create_transaction(self, mock_create):
        mock_create.return_value = {
            "id": "t2",
            "user_id": MOCK_USER_ID,
            "amount": -25.0,
            "category": "Food",
            "description": "Coffee shop",
            "date": "2026-04-01T00:00:00+00:00",
        }
        res = client.post(
            "/api/v1/transactions",
            json={"amount": -25.0, "category": "Food", "description": "Coffee shop"},
        )
        assert res.status_code == 201
        assert res.json()["id"] == "t2"

    @patch("app.repositories.transactions.create")
    def test_create_transaction_auto_categorize(self, mock_create):
        mock_create.return_value = {
            "id": "t3",
            "user_id": MOCK_USER_ID,
            "amount": -15.0,
            "category": "Entertainment",
            "description": "Netflix subscription",
            "date": "2026-04-01T00:00:00+00:00",
        }
        res = client.post(
            "/api/v1/transactions",
            json={"amount": -15.0, "description": "Netflix subscription"},
        )
        assert res.status_code == 201

    @patch("app.repositories.transactions.delete")
    def test_delete_transaction(self, mock_delete):
        mock_delete.return_value = None
        res = client.delete("/api/v1/transactions/t1")
        assert res.status_code == 204

    @patch("app.repositories.transactions.delete")
    def test_delete_nonexistent_returns_404(self, mock_delete):
        mock_delete.side_effect = NotFoundError("Transaction not found")
        res = client.delete("/api/v1/transactions/nonexistent")
        assert res.status_code == 404

    @patch("app.repositories.transactions.update")
    def test_update_nonexistent_returns_404(self, mock_update):
        mock_update.side_effect = NotFoundError("Transaction not found")
        res = client.put(
            "/api/v1/transactions/missing",
            json={"amount": -10.0},
        )
        assert res.status_code == 404


# ── Budgets ─────────────────────────────────────────────────────────────────


class TestBudgets:
    @patch("app.repositories.budgets.list_for_user")
    def test_list_budgets(self, mock_list):
        mock_list.return_value = [
            {
                "id": "b1",
                "user_id": MOCK_USER_ID,
                "category": "Food",
                "limit_amount": 500.0,
                "period": "monthly",
                "created_at": "2026-04-01T00:00:00+00:00",
            }
        ]
        res = client.get("/api/v1/budgets")
        assert res.status_code == 200
        assert res.json()[0]["limit_amount"] == 500.0

    @patch("app.repositories.budgets.create")
    def test_create_budget(self, mock_create):
        mock_create.return_value = {
            "id": "b2",
            "user_id": MOCK_USER_ID,
            "category": "Entertainment",
            "limit_amount": 200.0,
            "period": "monthly",
            "created_at": "2026-04-01T00:00:00+00:00",
        }
        res = client.post(
            "/api/v1/budgets",
            json={"category": "Entertainment", "limit_amount": 200.0},
        )
        assert res.status_code == 201

    def test_create_budget_invalid_period_returns_422(self):
        res = client.post(
            "/api/v1/budgets",
            json={
                "category": "Food",
                "limit_amount": 100,
                "period": "fortnightly",  # not in BudgetPeriod enum
            },
        )
        assert res.status_code == 422


# ── Goals ───────────────────────────────────────────────────────────────────


class TestGoals:
    @patch("app.repositories.goals.list_for_user")
    def test_list_goals(self, mock_list):
        mock_list.return_value = [
            {
                "id": "g1",
                "user_id": MOCK_USER_ID,
                "target_amount": 3000.0,
                "target_date": "2026-06-01T00:00:00+00:00",
                "description": "Vacation Fund",
                "progress": 1800.0,
                "category": "vacation",
            }
        ]
        res = client.get("/api/v1/goals")
        assert res.status_code == 200
        assert res.json()[0]["description"] == "Vacation Fund"


# ── Recommendations ─────────────────────────────────────────────────────────


class TestRecommendations:
    @patch("app.repositories.recommendations.list_for_user")
    def test_list_recommendations(self, mock_list):
        mock_list.return_value = [
            {
                "id": "r1",
                "user_id": MOCK_USER_ID,
                "category": "Food",
                "title": "Reduce dining out",
                "description": "Spend less on restaurants.",
                "potential_savings": 85.0,
                "created_at": "2026-04-01T00:00:00+00:00",
            }
        ]
        res = client.get("/api/v1/recommendations")
        assert res.status_code == 200
        assert res.json()[0]["title"] == "Reduce dining out"


# ── ML endpoints ────────────────────────────────────────────────────────────


class TestMLEndpoints:
    def test_categorize(self):
        res = client.post(
            "/api/v1/ml/categorize",
            json={"description": "Grocery Store"},
        )
        assert res.status_code == 200
        data = res.json()
        assert data["category"] == "Food"
        assert 0 < data["confidence"] <= 1.0

    @patch("app.repositories.budgets.replace_all_for_user")
    @patch("app.repositories.transactions.list_for_user")
    def test_generate_budgets(self, mock_list, mock_replace):
        mock_list.return_value = [
            {"amount": -100, "category": "Food", "date": "2026-03-10T00:00:00Z"},
            {"amount": -50, "category": "Food", "date": "2026-03-20T00:00:00Z"},
        ]
        mock_replace.return_value = [
            {
                "id": "bg1",
                "user_id": MOCK_USER_ID,
                "category": "Food",
                "limit_amount": 170.0,
                "period": "monthly",
                "created_at": "2026-04-01T00:00:00+00:00",
            }
        ]
        res = client.post("/api/v1/ml/budgets/generate")
        assert res.status_code == 200
        assert res.json()[0]["category"] == "Food"

    @patch("app.repositories.recommendations.replace_all_for_user")
    @patch("app.repositories.budgets.list_for_user")
    @patch("app.repositories.transactions.list_for_user")
    def test_generate_recommendations(
        self,
        mock_txns,
        mock_budgets,
        mock_replace,
    ):
        mock_txns.return_value = [
            {"amount": -600, "category": "Food", "date": "2026-04-10T00:00:00Z"},
        ]
        mock_budgets.return_value = [{"category": "Food", "limit_amount": 500}]
        mock_replace.return_value = [
            {
                "id": "rg1",
                "user_id": MOCK_USER_ID,
                "category": "Food",
                "title": "Over budget in Food",
                "description": "You spent too much.",
                "potential_savings": 100.0,
                "created_at": "2026-04-01T00:00:00+00:00",
            }
        ]
        res = client.post("/api/v1/ml/recommendations/generate")
        assert res.status_code == 200

    @patch("app.repositories.transactions.list_for_user")
    def test_generate_budgets_no_transactions(self, mock_list):
        mock_list.return_value = []
        res = client.post("/api/v1/ml/budgets/generate")
        assert res.status_code == 400
