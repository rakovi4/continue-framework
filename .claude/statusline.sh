#!/bin/bash
input=$(cat)
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
CONTEXT_USED=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
CONTEXT_REMAINING=$(echo "$input" | jq -r '.context_window.remaining_percentage // 0')
echo "[$MODEL] | Context: ${CONTEXT_USED}% used (${CONTEXT_REMAINING}% remaining)"
