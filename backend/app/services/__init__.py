"""Application service layer (use cases).

Services orchestrate one logical operation at a time: register a user, create
a transaction (with optional ML categorization), regenerate budgets from
history. They depend on repositories for persistence and the ``ml`` package
for analytics; they raise typed :mod:`app.core.exceptions` on failure and
never import FastAPI types.

Keeping use-case logic out of the routers means the same code is reusable
from CLI scripts or background workers and trivial to unit-test in isolation.
"""
