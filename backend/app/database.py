"""Database connection pool for PostgreSQL.

Uses psycopg2 SimpleConnectionPool; configuration via POSTGRES_* environment
variables. Provides query() for read operations (returns list of dicts),
execute() for write operations (INSERT/UPDATE/DELETE), and close_pool() for
graceful shutdown. All connections use RealDictCursor so rows are dicts keyed
by column name.
"""

import os
from contextlib import contextmanager

from psycopg2 import pool
from psycopg2.extras import RealDictCursor

# Module-level pool; created on first get_pool() call, reused thereafter.
_pool: pool.SimpleConnectionPool | None = None


def get_pool() -> pool.SimpleConnectionPool:
    """Return the shared connection pool, creating it if needed or if closed."""
    global _pool
    if _pool is None or _pool.closed:
        _pool = pool.SimpleConnectionPool(
            minconn=1,
            maxconn=10,
            host=os.getenv("POSTGRES_HOST", "db"),
            port=int(os.getenv("POSTGRES_PORT", "5432")),
            dbname=os.getenv("POSTGRES_DB", "smartspend"),
            user=os.getenv("POSTGRES_USER", "smartspend"),
            password=os.getenv("POSTGRES_PASSWORD", "smartspend_dev"),
        )
    return _pool


@contextmanager
def _connection():
    """Context manager: borrow a connection from the pool and return it when done."""
    conn = get_pool().getconn()
    try:
        yield conn
    finally:
        get_pool().putconn(conn)


def query(sql: str, params: tuple | None = None, *, fetch_one: bool = False):
    """Run a read-only query (SELECT) and return results as dicts.

    Args:
        sql: SQL string; use %s placeholders for parameters.
        params: Optional tuple of values for the placeholders.
        fetch_one: If True, return a single dict or None; otherwise return a list.

    Returns:
        List of dicts (or single dict if fetch_one), or None if the statement
        produced no result set (e.g. non-SELECT).
    """
    with _connection() as conn:
        try:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sql, params)
                # Statements without a result set (e.g. INSERT without RETURNING)
                if cur.description is None:
                    conn.commit()
                    return None
                rows = cur.fetchall()
                conn.commit()
                if fetch_one:
                    return dict(rows[0]) if rows else None
                return [dict(r) for r in rows]
        except Exception:
            conn.rollback()
            raise


def execute(sql: str, params: tuple | None = None):
    """Run a write statement (INSERT/UPDATE/DELETE) and return the result.

    Args:
        sql: SQL string; use %s placeholders for parameters.
        params: Optional tuple of values for the placeholders.

    Returns:
        If the statement has RETURNING *, the first row as a dict; otherwise
        the number of affected rows (e.g. for DELETE).
    """
    with _connection() as conn:
        try:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sql, params)
                conn.commit()
                if cur.description:
                    return dict(cur.fetchone())
                return cur.rowcount
        except Exception:
            conn.rollback()
            raise


def close_pool():
    """Close all connections in the pool. Call on application shutdown."""
    global _pool
    if _pool and not _pool.closed:
        _pool.closeall()
        _pool = None
