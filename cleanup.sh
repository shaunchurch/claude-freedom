#!/bin/bash
# Clean up Claude sandbox Docker resources
# Usage: ./cleanup.sh [--full] [--force]

set -e

FULL=false
FORCE=false

for arg in "$@"; do
  case $arg in
    --full) FULL=true ;;
    --force) FORCE=true ;;
  esac
done

CONFIG_DIR="${CLAUDE_SANDBOX_CONFIG:-$HOME/.config/claude-sandbox}"

echo "Claude Sandbox Cleanup"
echo "======================"
echo ""
echo "Will delete:"
echo "  - Config directory: $CONFIG_DIR"
if $FULL; then
  echo "  - Docker image: claude-sandbox"
fi
echo ""

if ! $FORCE; then
  read -p "Continue? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
  fi
fi

echo "Removing config directory..."
rm -rf "$CONFIG_DIR"

if $FULL; then
  echo "Removing image..."
  docker rmi claude-sandbox 2>/dev/null || true
fi

echo "Done."
