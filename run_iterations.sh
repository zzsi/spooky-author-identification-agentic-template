#!/usr/bin/env bash

# Script to run multiple iterations of ML solution discovery with auto-commits
# Usage: ./run_iterations.sh <number_of_iterations>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <number_of_iterations>"
    echo "Example: $0 5"
    exit 1
fi

iterations=$1

if ! [[ "$iterations" =~ ^[0-9]+$ ]] || [ "$iterations" -lt 1 ]; then
    echo "Error: Please provide a positive integer for number of iterations"
    exit 1
fi

echo "Running $iterations iterations of ML solution discovery..."
echo "Each iteration will run ./prompt.sh and commit changes automatically."
echo

for i in $(seq 1 $iterations); do
    echo "=== Iteration $i/$iterations ==="
    
    # Run the agent
    ./prompt.sh
    
    # Check if prompt.sh succeeded
    if [ $? -ne 0 ]; then
        echo "Error: prompt.sh failed on iteration $i"
        exit 1
    fi
    
    # Add all changes and commit
    git add .
    git commit -m "iter $i"
    
    # Check if commit succeeded
    if [ $? -ne 0 ]; then
        echo "Warning: git commit failed on iteration $i (possibly no changes to commit)"
    else
        echo "Committed iteration $i"
    fi
    
    echo
done

echo "Completed $iterations iterations!"
echo "Check git log to see all iterations:"
echo "  git log --oneline -$iterations"