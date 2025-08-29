# Spooky Author Identification — Agentic Template

This is a template to use a coding agent to find a machine learning solution to a Kaggle competition, spooky author identification.

**Contents**
- `data/` — Competition files (train/test/description).
- `user_prompt.txt` — Orchestration prompt for the agent.
- `requirements.txt` — Python dependencies for local runs.
- `setup_env.sh` — Create/activate local virtual environment and install deps.
- `prompt.sh` — Helper to run the agent CLI with the prompt.

## Quick Start

1. **Install prerequisites**: Coding agent CLI (e.g., `claude`) + Python 3.10+ + `uv`
2. **Setup environment**: `uv venv && source .venv/bin/activate && uv pip sync requirements.txt`
3. **Run iterations**: `./run_iterations.sh 3` (or `./prompt.sh` + manual commits)

**Environment Setup**
- Purpose: provide the coding agent an isolated Python env so it can import libraries without installing them each run.
- Prereqs: 
  - **Coding agent CLI** (e.g., `claude`, `cursor`, etc.) - install per your agent's documentation
  - `python3.10+` and `uv` (recommended). Install uv: macOS `brew install uv`, or `curl -LsSf https://astral.sh/uv/install.sh | sh`.
- Create venv: `uv venv` (creates `.venv`).
- Activate: `source .venv/bin/activate`.
- Install deps: `uv pip sync requirements.txt` (or `uv pip install -r requirements.txt`).
- Verify: `python -c "import sklearn, pandas; print('ok')"`.

**ML Solution Discovery Workflow**

This template enables iterative ML solution discovery with a coding agent:

1. **Setup** (once): Complete the environment setup above
2. **Iterate**: Repeatedly run `./prompt.sh` to let the agent improve the ML solution
3. **Track Progress**: After each iteration, commit the agent's changes:
   ```bash
   git add .
   git commit -m "iter 1"
   ```
4. **Continue**: Repeat steps 2-3 for multiple iterations:
   ```bash
   ./prompt.sh
   git commit -m "iter 2"
   ./prompt.sh  
   git commit -m "iter 3"
   # ... and so on
   ```

**For convenience**, use the multi-iteration script:
```bash
./run_iterations.sh 5  # Runs 5 iterations with auto-commits
```

Each run of `./prompt.sh`:
- Agent analyzes the ML problem and designs experiments
- Agent writes/modifies code and runs experiments  
- Agent learns from results and improves the approach
- Agent aims to maximize validation accuracy
- All work is logged to `./logs/` with timestamps

## What to Expect

The agent will create and evolve these artifacts:

**Planning & Documentation**:
- `eda_plan.md` — Data exploration strategy
- `model_prototype_plan.md` — Living plan of modeling approaches
- `journal/` — Time-stamped entries documenting each iteration's findings

**Code & Experiments**:
- Python scripts for data preprocessing, modeling, and evaluation
- Experiment tracking files (e.g., `experiments.csv`)
- Model checkpoints and serialized objects

**Outputs**:
- `submission.csv` — Final predictions for Kaggle submission
- Validation scores and performance metrics
- Logs of all agent activity in `./logs/`

The agent learns from each iteration, building on previous experiments to improve validation accuracy.

## Using Different Coding Agents

The scripts automatically detect and use available coding agent CLIs (Claude, Gemini, Cursor).

**Auto-detection priority**: Claude → Gemini → Cursor

**To use a specific agent** (when you have multiple installed):
```bash
AGENT=gemini ./prompt.sh              # Use Gemini for single run
AGENT=gemini ./run_iterations.sh 5    # Use Gemini for 5 iterations
```

**Supported agents:**
- `claude` — Claude CLI with full flags
- `gemini` — Gemini CLI with `--yolo` auto-approval  
- `cursor` — Cursor CLI with `--auto-approve`

**Examples:**
```bash
./prompt.sh                           # Auto-detect and use available agent
AGENT=claude ./prompt.sh              # Force Claude
AGENT=gemini ./prompt.sh              # Force Gemini
```

**For persistent agent choice**, set in your shell:
```bash
export AGENT=gemini
./run_iterations.sh 3                 # Will use Gemini for all iterations
```

**Notes on Docker**
- No Dockerfile or container runtime is included/used here by default.
- If you want Docker support, I can add a `Dockerfile` and helper scripts.

**Grading submissions.csv with MLE-bench**
- Install the `mlebench` CLI (choose one):
  - One-off with uvx: `uvx --from git+https://github.com/openai/mle-bench@main mlebench --help`
  - Install into current venv: `uv pip install 'mlebench @ git+https://github.com/openai/mle-bench@main'`
- Set up Kaggle credentials for dataset preparation: place `kaggle.json` in `~/.kaggle/` and ensure it’s readable only by you (`chmod 600 ~/.kaggle/kaggle.json`).
- Prepare the dataset for this competition (needed once):
  - `mlebench prepare -c spooky-author-identification --data-dir ~/.cache/mlebench`
- Ensure your `submissions.csv` matches the sample format in `data/sample_submission.csv` (columns: `id`, `EAP`, `HPL`, `MWS`).
- Grade your submission locally:
  - `mlebench grade-sample submissions.csv spooky-author-identification --data-dir ~/.cache/mlebench`
  - The CLI prints a JSON report with the competition metric.

**Notes**
- No Python implementation files are included in this template by design.
- Source of truth for the task is `./data/description.md`.
