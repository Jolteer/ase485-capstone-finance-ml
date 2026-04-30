"""PostgreSQL connection pool, query/execute helpers, and transaction support.

Three public entry points:

- :func:`query` - run a SELECT, get back a list of dicts (or a single dict).
- :func:`execute` - run an INSERT/UPDATE/DELETE; with ``RETURNING`` returns the
  first row as a dict (or ``None`` when no row matches), otherwise returns the
  affected row count.
- :func:`transaction` - context manager that yields a ``Tx`` object with its
  own ``query``/``execute`` methods all sharing one connection. Use this when
  multiple writes must succeed or fail atomically (e.g. ML regenerate flows).

Connections are borrowed from a module-level :class:`psycopg2.pool.SimpleConnectionPool`
and use :class:`psycopg2.extras.RealDictCursor` so rows arrive as dicts keyed
by column name, matching the existing codebase conventions.

Bug history note: the previous implementation of :func:`execute` did
``dict(cur.fetchone())`` for any statement with a result description. When an
``UPDATE ... RETURNING *`` matched zero rows, ``fetchone()`` returned ``None``
and the wrapper raised ``TypeError`` instead of a clean ``None``. Repository
helpers can now reliably treat ``None`` as "no row matched".
"""

from __future__ import annotations

from contextlib import contextmanager
from typing import Any, Iterator

from psycopg2 import pool
from psycopg2.extras import RealDictCursor

from app.core.config import get_settings

# Module-level pool; created on first ``get_pool()`` call, reused thereafter.
# We keep it module-level (rather than per-request) so the pool's connections
# survive across requests; FastAPI's lifespan handler closes it on shutdown.
#
# We use ``ThreadedConnectionPool`` (not ``SimpleConnectionPool``) because
# FastAPI dispatches sync route handlers on Starlette's thread pool, so
# ``getconn()``/``putconn()`` are called from many threads concurrently.
# Per psycopg2's own docs, ``SimpleConnectionPool`` "is useful only for
# single-threaded applications," whereas ``ThreadedConnectionPool`` "can be
# safely used in multi-threaded applications".
# Ref: https://github.com/psycopg/psycopg2/blob/master/doc/src/pool.rst
_pool: pool.ThreadedConnectionPool | None = None


def get_pool() -> pool.ThreadedConnectionPool:
    """Return the shared connection pool, creating it lazily if needed.

    Recreates the pool if the previous instance was closed (e.g. by a test
    fixture); this avoids "pool is closed" errors when tests teardown then
    re-use the module.
    """
    global _pool
    if _pool is None or _pool.closed:
        s = get_settings()
        _pool = pool.ThreadedConnectionPool(
            minconn=s.db_pool_min,
            maxconn=s.db_pool_max,
            host=s.postgres_host,
            port=s.postgres_port,
            dbname=s.postgres_db,
            user=s.postgres_user,
            password=s.postgres_password,
        )
    return _pool


@contextmanager
def _connection():
    """Borrow a connection from the pool and return it after use."""
    conn = get_pool().getconn()
    try:
        yield conn
    finally:
        get_pool().putconn(conn)


def query(
    sql: str,
    params: tuple | None = None,
    *,
    fetch_one: bool = False,
) -> list[dict[str, Any]] | dict[str, Any] | None:
    """Run a read-only query and return rows as dicts.

    Args:
        sql: SQL string; use ``%s`` placeholders for parameters.
        params: Optional tuple of values for the placeholders.
        fetch_one: If True, return a single dict or ``None``; otherwise a list.

    Returns:
        - ``list[dict]`` for normal SELECTs.
        - ``dict | None`` when ``fetch_one=True``.
        - ``None`` if the statement produced no result set (callers should
          prefer :func:`execute` for non-SELECT statements).
    """
    with _connection() as conn:
        try:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sql, params)
                # No result set means the caller passed a non-SELECT here.
                # Commit so any side effects persist; ``execute()`` is the
                # idiomatic call for writes.
                if cur.description is None:
                    conn.commit()
                    return None
                rows = cur.fetchall()
                # Read path: ending the implicit transaction with rollback
                # avoids a no-op commit on every SELECT.
                conn.rollback()
                if fetch_one:
                    return dict(rows[0]) if rows else None
                return [dict(r) for r in rows]
        except Exception:
            conn.rollback()
            raise


def execute(
    sql: str,
    params: tuple | None = None,
) -> dict[str, Any] | int | None:
    """Run a write statement (INSERT/UPDATE/DELETE) and return the result.

    Args:
        sql: SQL string; use ``%s`` placeholders for parameters.
        params: Optional tuple of values for the placeholders.

    Returns:
        - ``dict`` of the first returned row when the statement uses
          ``RETURNING`` and matches at least one row.
        - ``None`` when the statement uses ``RETURNING`` but matched no rows
          (callers should treat this as "not found" and raise
          :class:`app.core.exceptions.NotFoundError`).
        - ``int`` row count for statements without ``RETURNING``
          (e.g. ``DELETE`` returns the number of deleted rows).
    """
    with _connection() as conn:
        try:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sql, params)
                conn.commit()
                if cur.description:
                    row = cur.fetchone()
                    return dict(row) if row is not None else None
                return cur.rowcount
        except Exception:
            conn.rollback()
            raise


# ── Transactions ────────────────────────────────────────────────────────────

class Tx:
    """Transactional handle that pins a single connection for multiple writes.

    All ``query``/``execute`` calls go through the same connection, so they're
    part of one PostgreSQL transaction. Commit happens automatically at the
    end of the surrounding :func:`transaction` block; any exception triggers a
    rollback.
    """

    def __init__(self, conn) -> None:
        self._conn = conn

    def query(
        self,
        sql: str,
        params: tuple | None = None,
        *,
        fetch_one: bool = False,
    ) -> list[dict[str, Any]] | dict[str, Any] | None:
        """Run a SELECT inside the active transaction."""
        with self._conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(sql, params)
            if cur.description is None:
                return None
            rows = cur.fetchall()
            if fetch_one:
                return dict(rows[0]) if rows else None
            return [dict(r) for r in rows]

    def execute(
        self,
        sql: str,
        params: tuple | None = None,
    ) -> dict[str, Any] | int | None:
        """Run a write inside the active transaction (no commit yet)."""
        with self._conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(sql, params)
            if cur.description:
                row = cur.fetchone()
                return dict(row) if row is not None else None
            return cur.rowcount


@contextmanager
def transaction() -> Iterator[Tx]:
    """Context manager: run multiple writes atomically.

    Example::

        with transaction() as tx:
            tx.execute("DELETE FROM budgets WHERE user_id = %s", (user_id,))
            for s in suggestions:
                tx.execute("INSERT INTO budgets ...", (...))

    On a clean exit psycopg2 commits; any exception triggers a rollback.
    """
    with _connection() as conn:
        try:
            yield Tx(conn)
            conn.commit()
        except Exception:
            conn.rollback()
            raise


def close_pool() -> None:
    """Close all connections in the pool. Call on application shutdown."""
    global _pool
    if _pool and not _pool.closed:
        _pool.closeall()
        _pool = None
