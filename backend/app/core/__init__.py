"""Cross-cutting infrastructure used by every layer.

The ``core`` package contains the building blocks that the API, services, and
repositories all depend on but that don't belong to any single domain:

- :mod:`app.core.config` - environment-driven settings.
- :mod:`app.core.db` - PostgreSQL connection pool + transactional helpers.
- :mod:`app.core.security` - JWT issuance/verification + the FastAPI dependency
  used to authenticate requests.
- :mod:`app.core.exceptions` - typed domain errors mapped to HTTP statuses by
  the global exception handlers in :mod:`app.main`.
- :mod:`app.core.logging` - structured logger configuration.

Importing from this package instead of reaching into the database or auth
implementation directly keeps the layers decoupled.
"""
