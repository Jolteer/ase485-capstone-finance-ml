"""Tests for :mod:`app.core.db`.

We exercise :func:`execute` end-to-end against an in-memory psycopg2-style
mock so the RETURNING-with-zero-rows behaviour can be verified without a
real database. The contract we're protecting is:

- ``execute("UPDATE … RETURNING *")`` matching no rows must return ``None``,
  not raise. Repository helpers translate ``None`` into a 404; the previous
  implementation crashed with ``TypeError`` from ``dict(None)``.
"""

from __future__ import annotations

from contextlib import contextmanager
from unittest.mock import MagicMock

import pytest

from app.core import db as core_db
from app.core.exceptions import NotFoundError
from app.repositories._partial_update import update_owned


def _patched_pool(monkeypatch, *, fetchone_value, has_description=True, rowcount=0):
    """Patch ``core_db.get_pool`` so SQL execution is fully mocked.

    Returns a configurable cursor whose ``description`` and ``fetchone`` can
    simulate any ``RETURNING`` outcome we want to test.
    """
    cur = MagicMock()
    cur.description = ["col"] if has_description else None
    cur.fetchone.return_value = fetchone_value
    cur.fetchall.return_value = [fetchone_value] if fetchone_value else []
    cur.rowcount = rowcount

    @contextmanager
    def _cur_ctx(*_, **__):
        yield cur

    conn = MagicMock()
    conn.cursor.side_effect = _cur_ctx

    @contextmanager
    def _conn_ctx(*_, **__):
        yield conn

    monkeypatch.setattr(core_db, "_connection", _conn_ctx)
    return cur


def test_execute_returning_none_when_no_row(monkeypatch):
    """``UPDATE … RETURNING *`` matching zero rows must return ``None``."""
    _patched_pool(monkeypatch, fetchone_value=None)
    result = core_db.execute(
        "UPDATE budgets SET limit_amount = %s WHERE id = %s RETURNING *",
        (100, "missing"),
    )
    assert result is None


def test_execute_returning_dict_on_match(monkeypatch):
    """When a row matches, the returned dict carries the columns."""
    _patched_pool(monkeypatch, fetchone_value={"id": "b1", "limit_amount": 100})
    result = core_db.execute(
        "UPDATE budgets SET limit_amount = %s WHERE id = %s RETURNING *",
        (100, "b1"),
    )
    assert result == {"id": "b1", "limit_amount": 100}


def test_execute_returns_rowcount_when_no_returning(monkeypatch):
    """Statements without RETURNING (e.g. plain DELETE) return the row count."""
    _patched_pool(
        monkeypatch,
        fetchone_value=None,
        has_description=False,
        rowcount=2,
    )
    result = core_db.execute("DELETE FROM budgets WHERE user_id = %s", ("u1",))
    assert result == 2


def test_update_owned_raises_not_found_on_zero_rows():
    """Repository helper translates ``None`` into a domain ``NotFoundError``."""
    fake_execute = MagicMock(return_value=None)
    with pytest.raises(NotFoundError):
        update_owned(
            table="budgets",
            allowed_columns={"limit_amount"},
            row_id="missing",
            user_id="u1",
            payload={"limit_amount": 100},
            not_found_detail="Budget not found",
            execute=fake_execute,
        )
