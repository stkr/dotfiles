#!/bin/bash

# Sanitize a string for use as a tmux window name:
# - Replace any character that is not alnum, dash, or underscore with '_'
# - Truncate to 20 characters
sanitize() {
    local s="${1//[^a-zA-Z0-9_-]/_}"   # replace disallowed chars with '_'
    echo "${s:0:20}"                    # truncate
}

# Usage check
if [ -z "$1" ]; then
    echo "Usage: $0 <file>"
    exit 1
fi


if [ "$TERM_PROGRAM" = "tmux" ]; then
    window_name=$(sanitize "$1")
    tmux new-window -n "$window_name" nvim "$1"
else
    nvim "$1"
fi
