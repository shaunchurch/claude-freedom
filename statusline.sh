#!/bin/bash
# Status line for Claude sandbox - shows project name, model, context usage

# Read JSON from stdin
read -r json

# Parse fields using jq (available in container)
model=$(echo "$json" | jq -r '.model.display_name // "?"')
input_tokens=$(echo "$json" | jq -r '.context_window.current_usage.input_tokens // 0')
context_size=$(echo "$json" | jq -r '.context_window.context_window_size // 200000')

# Format token count (e.g., 45231 -> 45k)
if [ "$input_tokens" -ge 1000 ]; then
  tokens_display="$((input_tokens / 1000))k"
else
  tokens_display="$input_tokens"
fi

# Calculate context percentage
if [ "$context_size" -gt 0 ]; then
  pct=$((input_tokens * 100 / context_size))
else
  pct=0
fi

# Output status line
echo "🐳 ${PROJECT_NAME:-sandbox} | ${model} | ${tokens_display} (${pct}%)"
