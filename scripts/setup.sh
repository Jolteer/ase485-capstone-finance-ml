#!/usr/bin/env bash
#
# One-time setup for SmartSpend on a new Mac/Linux machine.
# Run this once after cloning the repo, then use ./scripts/start.sh to run the app.
#
# Usage:  ./scripts/setup.sh
# Prerequisites: Docker installed and running, Flutter SDK on PATH.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
missing=0

echo ""
echo "================================================"
echo "  SmartSpend — New Machine Setup"
echo "================================================"
echo ""

# --- Check: Docker -----------------------------------------------------------
echo ">> Checking prerequisites..."

if ! command -v docker &>/dev/null; then
    echo ""
    echo "  [MISSING] Docker is not installed or not on PATH."
    echo "  Download it from: https://www.docker.com/products/docker-desktop/"
    echo ""
    missing=1
else
    echo "  [OK] Docker: $(docker --version)"
fi

# --- Check: Flutter ----------------------------------------------------------
if ! command -v flutter &>/dev/null; then
    echo ""
    echo "  [MISSING] Flutter SDK is not installed or not on PATH."
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "  Download it from: https://docs.flutter.dev/get-started/install/macos"
    else
        echo "  Download it from: https://docs.flutter.dev/get-started/install/linux"
    fi
    echo ""
    missing=1
else
    echo "  [OK] Flutter: $(flutter --version 2>&1 | head -1)"
fi

# --- Check: Git --------------------------------------------------------------
if ! command -v git &>/dev/null; then
    echo ""
    echo "  [MISSING] Git is not installed or not on PATH."
    echo "  Install via your package manager (e.g. brew install git) or https://git-scm.com"
    echo ""
    missing=1
else
    echo "  [OK] Git: $(git --version)"
fi

if [ "$missing" -ne 0 ]; then
    echo ""
    echo "ERROR: Install the missing tools above, then re-run this script." >&2
    exit 1
fi

# --- Copy .env ---------------------------------------------------------------
echo ""
echo ">> Checking .env file..."

ENV_FILE="$REPO_ROOT/.env"
ENV_EXAMPLE="$REPO_ROOT/.env.example"

if [ -f "$ENV_FILE" ]; then
    echo "  [OK] .env already exists — skipping copy."
else
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    echo "  [CREATED] .env copied from .env.example"
    echo ""
    echo "  *** ACTION REQUIRED ***"
    echo "  Open .env and replace all CHANGE_ME values before running the app."
    echo "  Especially set a strong JWT_SECRET."
fi

# --- Flutter pub get ---------------------------------------------------------
echo ""
echo ">> Fetching Flutter dependencies..."
cd "$REPO_ROOT"
flutter pub get

# --- Done --------------------------------------------------------------------
echo ""
echo "================================================"
echo "  Setup complete!"
echo "================================================"
echo ""
echo "  Next steps:"
echo "    1. Edit .env and replace any CHANGE_ME values"
echo "    2. Make sure Docker is running"
echo "    3. Run:  ./scripts/start.sh"
echo ""
