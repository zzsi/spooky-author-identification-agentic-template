#!/usr/bin/env bash
set -euo pipefail

# Creates a local virtual environment in .venv and installs requirements
# Usage: ./setup_env.sh [python_executable]
# Example: ./setup_env.sh python3.11

PYTHON_BIN="${1:-python3}"
VENVDIR=".venv"

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
  echo "Error: Python not found: $PYTHON_BIN" >&2
  exit 1
fi

echo "Using Python: $($PYTHON_BIN --version)"

if [ ! -d "$VENVDIR" ]; then
  echo "Creating virtualenv in $VENVDIR"
  "$PYTHON_BIN" -m venv "$VENVDIR"
fi

# shellcheck disable=SC1091
source "$VENVDIR/bin/activate"

python -m pip install --upgrade pip
if [ -f requirements.txt ]; then
  echo "Installing requirements from requirements.txt"
  pip install -r requirements.txt
else
  echo "No requirements.txt found; skipping dependency install"
fi

echo "Environment ready. Activate with: source $VENVDIR/bin/activate"
