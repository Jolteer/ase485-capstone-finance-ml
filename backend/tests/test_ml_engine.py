"""Unit tests for the ML engine (no database required)."""

from app.ml_engine import (
    generate_budgets,
    generate_recommendations,
    predict_category,
    predict_category_with_confidence,
)


class TestCategorization:
    """Tests for the transaction categorization model."""

    def test_food_descriptions(self):
        assert predict_category("Grocery Store") == "Food"
        assert predict_category("Restaurant dinner") == "Food"
        assert predict_category("Coffee shop") == "Food"

    def test_entertainment_descriptions(self):
        assert predict_category("Netflix subscription") == "Entertainment"
        assert predict_category("Movie tickets") == "Entertainment"
        assert predict_category("Spotify") == "Entertainment"

    def test_bills_descriptions(self):
        assert predict_category("Electric Bill") == "Bills"
        assert predict_category("Internet Bill") == "Bills"
        assert predict_category("Car Insurance") == "Bills"

    def test_shopping_descriptions(self):
        assert predict_category("Amazon Order") == "Shopping"
        assert predict_category("Target shopping") == "Shopping"

    def test_transportation_descriptions(self):
        assert predict_category("Gas Station") == "Transportation"
        assert predict_category("Uber ride") == "Transportation"

    def test_healthcare_descriptions(self):
        assert predict_category("Pharmacy") == "Healthcare"
        assert predict_category("doctor visit") == "Healthcare"

    def test_education_descriptions(self):
        assert predict_category("Online Course") == "Education"
        assert predict_category("textbook purchase") == "Education"

    def test_empty_description_returns_other(self):
        assert predict_category("") == "Other"
        assert predict_category("   ") == "Other"

    def test_confidence_returns_tuple(self):
        category, confidence = predict_category_with_confidence("Grocery Store")
        assert category == "Food"
        assert 0.0 < confidence <= 1.0

    def test_novel_description_returns_valid_category(self):
        valid_categories = {
            "Food", "Entertainment", "Bills", "Shopping",
            "Transportation", "Healthcare", "Education", "Other",
        }
        result = predict_category("random office supplies from staples")
        assert result in valid_categories


class TestBudgetGeneration:
    """Tests for the ML budget generation."""

    def test_empty_transactions_returns_empty(self):
        assert generate_budgets([]) == []

    def test_income_only_returns_empty(self):
        txns = [
            {"amount": 3000, "category": "Other", "date": "2026-03-15T08:00:00Z"},
        ]
        assert generate_budgets(txns) == []

    def test_generates_budgets_for_expense_categories(self):
        txns = [
            {"amount": -100, "category": "Food", "date": "2026-03-10T10:00:00Z"},
            {"amount": -50, "category": "Food", "date": "2026-03-20T10:00:00Z"},
            {"amount": -30, "category": "Entertainment", "date": "2026-03-15T10:00:00Z"},
        ]
        result = generate_budgets(txns)
        categories = {b["category"] for b in result}
        assert "Food" in categories
        assert "Entertainment" in categories
        for b in result:
            assert b["limit_amount"] > 0
            assert b["period"] == "monthly"

    def test_budget_has_buffer_above_average(self):
        txns = [
            {"amount": -100, "category": "Food", "date": "2026-03-01T00:00:00Z"},
        ]
        result = generate_budgets(txns, buffer_pct=0.10)
        food_budget = next(b for b in result if b["category"] == "Food")
        assert food_budget["limit_amount"] >= 100


class TestRecommendationGeneration:
    """Tests for the ML recommendation generation."""

    def test_empty_transactions_returns_empty(self):
        assert generate_recommendations([], []) == []

    def test_over_budget_generates_recommendation(self):
        txns = [
            {"amount": -600, "category": "Food", "date": "2026-04-10T00:00:00Z"},
        ]
        budgets = [{"category": "Food", "limit_amount": 500}]
        result = generate_recommendations(txns, budgets)
        assert any("over budget" in r["title"].lower() for r in result)

    def test_category_without_budget_suggests_one(self):
        txns = [
            {"amount": -200, "category": "Shopping", "date": "2026-04-10T00:00:00Z"},
        ]
        result = generate_recommendations(txns, [])
        assert any("set a budget" in r["title"].lower() for r in result)

    def test_recommendations_have_required_fields(self):
        txns = [
            {"amount": -100, "category": "Food", "date": "2026-04-05T00:00:00Z"},
        ]
        result = generate_recommendations(txns, [])
        for r in result:
            assert "category" in r
            assert "title" in r
            assert "description" in r
            assert "potential_savings" in r
