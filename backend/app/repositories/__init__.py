"""Data-access layer.

Each module in this package owns the SQL for one aggregate (users,
transactions, budgets, goals, recommendations). Repositories return plain
dicts (matching ``RealDictCursor`` rows), raise :class:`NotFoundError` when a
row is missing, and never know about HTTP, FastAPI, or Pydantic.

The thin :mod:`app.repositories._partial_update` helper deduplicates the
shared ``UPDATE … RETURNING *`` and ``DELETE`` patterns used by transactions,
budgets, and goals.
"""
