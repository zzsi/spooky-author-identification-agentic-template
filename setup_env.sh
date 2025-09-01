#!/usr/bin/env bash
set -euo pipefail

# Creates a local virtual environment in .venv and installs requirements
# Also attempts to prefetch the embedding model
#   sentence-transformers/all-MiniLM-L6-v2 (optional; graceful on failure)
#
# Usage: ./setup_env.sh [python_executable]
# Example: ./setup_env.sh python3.11
#
# Environment variables:
#   SKIP_MINILM=1   Skip prefetching the MiniLM embedding model

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

# Prefetch sentence-transformers MiniLM embedding model (gracefully skips on failure)
if [ "${SKIP_MINILM:-0}" != "1" ]; then
  echo "Prefetching embedding model: sentence-transformers/all-MiniLM-L6-v2"
  python - <<'PY'
import ssl

# Relax SSL if needed (mirrors NLTK block)
try:
    _create_unverified_https_context = ssl._create_unverified_context
except AttributeError:
    pass
else:
    ssl._create_default_https_context = _create_unverified_https_context

model_id = "sentence-transformers/all-MiniLM-L6-v2"
try:
    from sentence_transformers import SentenceTransformer
    # Load and run a tiny encode to trigger weights+tokenizer download
    model = SentenceTransformer(model_id)
    _ = model.encode(["warmup"], show_progress_bar=False)
    print(f"embeddings: {model_id} => ok")
except Exception as e:
    print(f"embeddings: warning: failed to prefetch {model_id}: {e}")
PY
else
  echo "Skipping MiniLM prefetch (SKIP_MINILM=1)"
fi

echo "Environment ready. Activate with: source $VENVDIR/bin/activate"
