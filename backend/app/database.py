"""Database connection pool for PostgreSQL."""

import os
from contextlib import contextmanager

from psycopg2 import pool
from psycopg2.extras import RealDictCursor

_pool: pool.SimpleConnectionPool | None = None


def get_pool() -> pool.SimpleConnectionPool:
    """Return (and lazily create) a connection pool."""
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
    """Yield a pooled connection that is automatically returned."""
    conn = get_pool().getconn()
    try:
        yield conn
    finally:
        get_pool().putconn(conn)


def query(sql: str, params: tuple | None = None, *, fetch_one: bool = False):
    """Execute a read query and return rows as dicts."""
    with _connection() as conn:
        try:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute(sql, params)
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
    """Execute a write statement and return the first row or affected count."""
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
    """Close all pooled connections."""
    global _pool
    if _pool and not _pool.closed:
        _pool.closeall()
        _pool = None
