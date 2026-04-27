"""API endpoint tests using FastAPI TestClient.

These tests mock the database layer so they run without PostgreSQL.
The auth dependency is overridden on the v1 sub-application since all
authenticated routes are mounted there.
"""

from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient

from app.auth import get_current_user_id
from app.main import api, app

client = TestClient(app)

MOCK_USER_ID = "test-user-001"


@pytest.fixture(autouse=True)
def _mock_auth():
    """Override the auth dependency so all requests appear authenticated."""
    api.dependency_overrides[get_current_user_id] = lambda: MOCK_USER_ID
    yield
    api.dependency_overrides.clear()


class TestHealthAndDocs:
    def test_health(self):
        res = client.get("/health")
        assert res.status_code == 200
        assert res.json() == {"status": "ok"}

    def test_openapi_schema(self):
        res = client.get("/api/v1/openapi.json")
        assert res.status_code == 200
        assert "paths" in res.json()


class TestTransactions:
    @patch("app.routers.transactions.query")
    def test_list_transactions(self, mock_query):
        mock_query.return_value = [
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
        data = res.json()
        assert len(data) == 1
        assert data[0]["category"] == "Food"

    @patch("app.routers.transactions.execute")
    def test_create_transaction(self, mock_execute):
        mock_execute.return_value = {
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

    @patch("app.routers.transactions.execute")
    def test_create_transaction_auto_categorize(self, mock_execute):
        mock_execute.return_value = {
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

    @patch("app.routers.transactions.execute")
    def test_delete_transaction(self, mock_execute):
        mock_execute.return_value = 1
        res = client.delete("/api/v1/transactions/t1")
        assert res.status_code == 204

    @patch("app.routers.transactions.execute")
    def test_delete_nonexistent_returns_404(self, mock_execute):
        mock_execute.return_value = 0
        res = client.delete("/api/v1/transactions/nonexistent")
        assert res.status_code == 404


class TestBudgets:
    @patch("app.routers.budgets.query")
    def test_list_budgets(self, mock_query):
        mock_query.return_value = [
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

    @patch("app.routers.budgets.execute")
    def test_create_budget(self, mock_execute):
        mock_execute.return_value = {
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


class TestGoals:
    @patch("app.routers.goals.query")
    def test_list_goals(self, mock_query):
        mock_query.return_value = [
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


class TestRecommendations:
    @patch("app.routers.recommendations.query")
    def test_list_recommendations(self, mock_query):
        mock_query.return_value = [
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

    @patch("app.routers.ml.execute")
    @patch("app.routers.ml.query")
    def test_generate_budgets(self, mock_query, mock_execute):
        mock_query.return_value = [
            {"amount": -100, "category": "Food", "date": "2026-03-10T00:00:00Z"},
            {"amount": -50, "category": "Food", "date": "2026-03-20T00:00:00Z"},
        ]
        mock_execute.side_effect = [
            None,  # DELETE
            {
                "id": "bg1",
                "user_id": MOCK_USER_ID,
                "category": "Food",
                "limit_amount": 170.0,
                "period": "monthly",
                "created_at": "2026-04-01T00:00:00+00:00",
            },
        ]
        res = client.post("/api/v1/ml/budgets/generate")
        assert res.status_code == 200

    @patch("app.routers.ml.execute")
    @patch("app.routers.ml.query")
    def test_generate_recommendations(self, mock_query, mock_execute):
        mock_query.side_effect = [
            [{"amount": -600, "category": "Food", "date": "2026-04-10T00:00:00Z"}],
            [{"category": "Food", "limit_amount": 500}],
        ]
        mock_execute.side_effect = [
            None,  # DELETE
            {
                "id": "rg1",
                "user_id": MOCK_USER_ID,
                "category": "Food",
                "title": "Over budget in Food",
                "description": "You spent too much.",
                "potential_savings": 100.0,
                "created_at": "2026-04-01T00:00:00+00:00",
            },
        ]
        res = client.post("/api/v1/ml/recommendations/generate")
        assert res.status_code == 200

    @patch("app.routers.ml.query")
    def test_generate_budgets_no_transactions(self, mock_query):
        mock_query.return_value = []
        res = client.post("/api/v1/ml/budgets/generate")
        assert res.status_code == 400
