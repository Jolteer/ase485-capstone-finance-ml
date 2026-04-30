"""HTTP layer.

Routers in :mod:`app.api.v1` are responsible only for translating between
HTTP requests and domain operations: parse the body via Pydantic, call a
service, return the result. They never touch SQL directly.
"""
