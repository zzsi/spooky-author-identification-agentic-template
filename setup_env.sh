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

# Download required NLTK data packages
echo "Downloading NLTK data packages (punkt, tagger, wordnet, etc.)"
python - <<'PY'
import ssl
import nltk

# Handle environments with custom/strict SSL by allowing unverified context
try:
    _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
    pass
else:
    ssl._create_default_https_context = _create_unverified_https_context

packages = [
    'punkt',
    'averaged_perceptron_tagger',
    'wordnet',
    'punkt_tab',
    'averaged_perceptron_tagger_eng',
]

for pkg in packages:
    try:
        ok = nltk.download(pkg, quiet=True)
        print(f"nltk: {pkg} => {'ok' if ok else 'already present or skipped'}")
    except Exception as e:
        print(f"nltk: warning: failed to download {pkg}: {e}")
PY

echo "Environment ready. Activate with: source $VENVDIR/bin/activate"
