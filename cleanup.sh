#!/bin/bash
# Clean up Claude sandbox Docker resources
# Usage: ./cleanup.sh [--full] [--force]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FULL=false
FORCE=false

for arg in "$@"; do
  case $arg in
    --full) FULL=true ;;
    --force) FORCE=true ;;
  esac
done

echo "Claude Sandbox Cleanup"
echo "======================"
echo ""
echo "Will delete:"
echo "  - Docker volume: claude-freedom_claude-config"
echo "  - Docker volume: claude-freedom_claude-config-local"
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

echo "Removing volumes..."
docker volume rm claude-freedom_claude-config claude-freedom_claude-config-local 2>/dev/null || echo "  (volumes not found or already removed)"

if $FULL; then
  echo "Removing image..."
  docker rmi claude-sandbox 2>/dev/null || true
fi

echo "Done."
