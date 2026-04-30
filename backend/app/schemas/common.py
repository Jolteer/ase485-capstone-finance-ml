"""Enumerations shared by multiple request/response schemas."""

from __future__ import annotations

from enum import Enum


class TransactionCategory(str, Enum):
    """Canonical category labels used by transactions, budgets, and the ML model.

    The ML training corpus in :mod:`app.ml.training_data` emits the same
    capitalised labels; keeping a single Enum avoids the historical drift
    where transactions were ``"Other"`` while goals defaulted to ``"other"``.
    """

    food = "Food"
    entertainment = "Entertainment"
    bills = "Bills"
    shopping = "Shopping"
    transportation = "Transportation"
    healthcare = "Healthcare"
    education = "Education"
    other = "Other"


class BudgetPeriod(str, Enum):
    """How long a budget limit applies for."""

    monthly = "monthly"
    weekly = "weekly"
    yearly = "yearly"
