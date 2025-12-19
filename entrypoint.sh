#!/bin/bash
# Entrypoint for Claude sandbox container
# Sets up git config, Claude settings, and links host config before launching

# Configure git from env vars if provided
if [ -n "$GIT_USER_NAME" ]; then
  git config --global user.name "$GIT_USER_NAME"
fi
if [ -n "$GIT_USER_EMAIL" ]; then
  git config --global user.email "$GIT_USER_EMAIL"
fi

# Ensure .claude directory exists
mkdir -p "$HOME/.claude"

# Create Claude settings with bypass mode if not exists
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
if [ ! -f "$CLAUDE_SETTINGS" ]; then
  echo '{"permissions":{"defaultMode":"bypassPermissions"},"sandbox":{"allowUnsandboxedCommands":false}}' > "$CLAUDE_SETTINGS"
fi

# Link host config directories (read-only) if they exist
HOST_CLAUDE="$HOME/.claude-host"
if [ -d "$HOST_CLAUDE" ]; then
  # Link skills directory
  if [ -d "$HOST_CLAUDE/skills" ] && [ ! -e "$HOME/.claude/skills" ]; then
    ln -s "$HOST_CLAUDE/skills" "$HOME/.claude/skills"
  fi
  # Link commands directory
  if [ -d "$HOST_CLAUDE/commands" ] && [ ! -e "$HOME/.claude/commands" ]; then
    ln -s "$HOST_CLAUDE/commands" "$HOME/.claude/commands"
  fi
fi

# Launch claude with all passed arguments
exec claude "$@"
