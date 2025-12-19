#!/bin/bash
# Entrypoint for Claude sandbox container
# Sets up git config and Claude settings before launching

# Configure git from env vars if provided
if [ -n "$GIT_USER_NAME" ]; then
  git config --global user.name "$GIT_USER_NAME"
fi
if [ -n "$GIT_USER_EMAIL" ]; then
  git config --global user.email "$GIT_USER_EMAIL"
fi

# Create Claude settings with bypass mode if not exists
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [ ! -f "$CLAUDE_SETTINGS" ]; then
  mkdir -p "$HOME/.claude"
  echo '{"permissions":{"defaultMode":"bypassPermissions"},"sandbox":{"allowUnsandboxedCommands":false}}' > "$CLAUDE_SETTINGS"
fi

# Launch claude with all passed arguments
exec claude "$@"
