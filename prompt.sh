#!/usr/bin/env bash

timestamp="$(date +"%Y%m%d_%H%M%S")"
mkdir -p "logs"
log_file="logs/${timestamp}.log"

claude -p "follow @user_prompt.txt, continue" --verbose --output-format stream-json --model sonnet --permission-mode bypassPermissions --dangerously-skip-permissions 2>&1 | tee "$log_file"
