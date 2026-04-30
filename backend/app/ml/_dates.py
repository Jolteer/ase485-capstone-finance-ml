"""Date helpers shared by the budget and recommendation engines.

Transactions arrive as raw psycopg2 rows where ``date`` may already be a
:class:`datetime`, a string from a JSON-serialised payload, or missing. This
module is the one place that knows how to coerce that into a usable datetime.
"""

from __future__ import annotations

from datetime import datetime


def parse_iso_date(value: object) -> datetime | None:
    """Coerce a raw ``date`` field into a :class:`datetime`, or ``None`` if invalid.

    Accepts:
    - existing ``datetime`` instances (returned unchanged);
    - ISO-8601 strings, including the trailing-``Z`` form psycopg2/json
      round-trips frequently produce;
    - anything else returns ``None`` so callers can ``continue`` past undated
      rows without crashing.
    """
    if isinstance(value, datetime):
        return value
    if isinstance(value, str):
        try:
            return datetime.fromisoformat(value.replace("Z", "+00:00"))
        except ValueError:
            return None
    return None
