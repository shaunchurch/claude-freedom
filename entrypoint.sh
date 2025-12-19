#!/bin/bash
# Entrypoint for Claude sandbox container

# Configure git from env vars if provided
if [ -n "$GIT_USER_NAME" ]; then
  git config --global user.name "$GIT_USER_NAME"
fi
if [ -n "$GIT_USER_EMAIL" ]; then
  git config --global user.email "$GIT_USER_EMAIL"
fi

# Link host skills/commands into sandbox config (read-only access)
if [ -d "/host-claude/skills" ] && [ ! -e "/claude/skills" ]; then
  ln -s /host-claude/skills /claude/skills
fi
if [ -d "/host-claude/commands" ] && [ ! -e "/claude/commands" ]; then
  ln -s /host-claude/commands /claude/commands
fi

# Create settings with sandbox status line if not exists
if [ ! -f "/claude/settings.json" ]; then
  cat > /claude/settings.json << SETTINGS
{
  "statusLine": {
    "type": "command",
    "command": "/usr/local/bin/statusline.sh"
  }
}
SETTINGS
fi

# Launch claude (CLAUDE_CONFIG_DIR env var tells it where to store config)
exec claude "$@"
