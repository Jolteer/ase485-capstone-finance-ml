#!/usr/bin/env bash
#
# Starts the full SmartSpend dev stack: PostgreSQL + FastAPI + pgAdmin via
# Docker Compose, waits for the API to become healthy, then launches the
# Flutter app.
#
# Usage:  ./scripts/start.sh [device]
#   e.g.  ./scripts/start.sh chrome
# Prerequisites: Docker running, Flutter SDK on PATH, curl installed.

set -euo pipefail

DEVICE="${1:-}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# --- Pre-flight checks ------------------------------------------------------
if ! command -v docker &>/dev/null; then
    echo "ERROR: 'docker' not found. Make sure Docker is installed and running." >&2
    exit 1
fi

if ! command -v flutter &>/dev/null; then
    echo "ERROR: 'flutter' not found. Make sure the Flutter SDK is on your PATH." >&2
    exit 1
fi

# --- Start Docker Compose ----------------------------------------------------
echo ""
echo ">> Starting Docker Compose services (db, backend, pgadmin)..."
docker compose -f "$REPO_ROOT/docker-compose.yml" up -d

# --- Wait for the API --------------------------------------------------------
API_URL="http://localhost:8000/health"
MAX_RETRIES=20
RETRY_DELAY=2

echo ">> Waiting for API at $API_URL ..."
for i in $(seq 1 "$MAX_RETRIES"); do
    status=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL" 2>/dev/null || true)
    if [ "$status" = "200" ]; then
        echo "   API is ready."
        break
    fi

    if [ "$i" -eq "$MAX_RETRIES" ]; then
        echo "ERROR: API did not become healthy after $(( MAX_RETRIES * RETRY_DELAY ))s. Check 'docker compose logs backend'." >&2
        exit 1
    fi

    echo "   Attempt $i/$MAX_RETRIES - retrying in ${RETRY_DELAY}s..."
    sleep "$RETRY_DELAY"
done

# --- Launch Flutter -----------------------------------------------------------
cd "$REPO_ROOT"
echo ""
echo ">> Installing Flutter dependencies..."
flutter pub get

echo ""
echo ">> Launching Flutter app..."
if [ -n "$DEVICE" ]; then
    flutter run -d "$DEVICE"
else
    flutter run
fi
