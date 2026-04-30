"""Shared pytest fixtures.

The :func:`mock_auth` fixture overrides ``get_current_user_id`` on both the
root app and the v1 sub-app so every authenticated request in the suite
appears to come from a known test user without going near the real JWT path.
"""

from __future__ import annotations

import pytest
from fastapi.testclient import TestClient

from app.core.security import get_current_user_id
from app.main import api, app

MOCK_USER_ID = "test-user-001"


@pytest.fixture
def client() -> TestClient:
    """Return a TestClient against the root FastAPI app."""
    return TestClient(app)


@pytest.fixture(autouse=True)
def mock_auth():
    """Make every authenticated request appear to come from ``MOCK_USER_ID``."""
    apps = [a for a in (app, api) if a is not None]
    for a in apps:
        a.dependency_overrides[get_current_user_id] = lambda: MOCK_USER_ID
    yield
    for a in apps:
        a.dependency_overrides.clear()
