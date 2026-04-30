"""Lightweight logger configuration.

We don't ship a full structured-logging stack because the deployment target
(Railway / Docker) already collects stdout. This helper just gives every
module a ``logging.Logger`` with a consistent format and lets us tune the
level via the ``LOG_LEVEL`` environment variable.
"""

from __future__ import annotations

import logging
import os

_FORMAT = "%(asctime)s %(levelname)s [%(name)s] %(message)s"
_DATE_FORMAT = "%Y-%m-%dT%H:%M:%S%z"

_configured = False


def _configure_root() -> None:
    """Configure the root logger once per process."""
    global _configured
    if _configured:
        return
    level = os.getenv("LOG_LEVEL", "INFO").upper()
    logging.basicConfig(level=level, format=_FORMAT, datefmt=_DATE_FORMAT)
    _configured = True


def get_logger(name: str) -> logging.Logger:
    """Return a logger using the shared configuration.

    Use ``get_logger(__name__)`` at module top-level. The first call configures
    the root handler; subsequent calls reuse it.
    """
    _configure_root()
    return logging.getLogger(name)
