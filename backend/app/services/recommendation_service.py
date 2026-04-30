"""Recommendation use case (read-only)."""

from __future__ import annotations

from typing import Any

from app.repositories import recommendations as repo


def list_recommendations(user_id: str) -> list[dict[str, Any]]:
    """Return the user's recommendations, newest first."""
    return repo.list_for_user(user_id)
