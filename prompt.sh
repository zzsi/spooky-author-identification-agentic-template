#!/usr/bin/env bash

# Auto-detect and use available coding agent CLI
# Supports: claude, gemini, cursor, etc.
# Override with: AGENT=gemini ./prompt.sh

timestamp="$(date +"%Y%m%d_%H%M%S")"
mkdir -p "logs"
log_file="logs/${timestamp}.log"

prompt_text="follow @user_prompt.txt, continue"

# Use specified agent or auto-detect
agent_to_use="${AGENT:-auto}"

run_claude() {
    echo "Using Claude CLI..."
    claude -p "$prompt_text" --verbose --output-format stream-json --model sonnet --permission-mode bypassPermissions --dangerously-skip-permissions 2>&1 | tee "$log_file"
}

run_gemini() {
    echo "Using Gemini CLI..."
    gemini -p "$prompt_text" --debug --yolo 2>&1 | tee "$log_file"
}

run_cursor() {
    echo "Using Cursor CLI..."
    cursor-cli -p "$prompt_text" --auto-approve 2>&1 | tee "$log_file"
}

# Handle specific agent request
if [ "$agent_to_use" != "auto" ]; then
    case "$agent_to_use" in
        claude)
            if command -v claude &> /dev/null; then
                run_claude
            else
                echo "Error: Claude CLI not found. Please install it first."
                exit 1
            fi
            ;;
        gemini)
            if command -v gemini &> /dev/null; then
                run_gemini
            else
                echo "Error: Gemini CLI not found. Please install it first."
                exit 1
            fi
            ;;
        cursor)
            if command -v cursor-cli &> /dev/null; then
                run_cursor
            else
                echo "Error: Cursor CLI not found. Please install it first."
                exit 1
            fi
            ;;
        *)
            echo "Error: Unsupported agent '$agent_to_use'"
            echo "Supported agents: claude, gemini, cursor"
            exit 1
            ;;
    esac
else
    # Auto-detect (priority: claude -> gemini -> cursor)
    if command -v claude &> /dev/null; then
        run_claude
    elif command -v gemini &> /dev/null; then
        run_gemini
    elif command -v cursor-cli &> /dev/null; then
        run_cursor
    else
        echo "Error: No supported coding agent CLI found."
        echo "Please install one of: claude, gemini, cursor-cli"
        echo "Or specify with: AGENT=<agent> ./prompt.sh"
        exit 1
    fi
fi
