#!/bin/bash
# Run Claude Code in a sandboxed Docker container
# Usage: ./sandbox.sh [/path/to/project] [--no-build] [claude args...]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check Docker is running
if ! docker info >/dev/null 2>&1; then
  echo "Error: Docker is not running. Please start Docker and try again."
  exit 1
fi

# Parse arguments
PROJECT_PATH=""
NO_BUILD=false
CLAUDE_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --no-build)
      NO_BUILD=true
      shift
      ;;
    -*)
      CLAUDE_ARGS+=("$1")
      shift
      ;;
    *)
      if [ -z "$PROJECT_PATH" ]; then
        PROJECT_PATH="$1"
      else
        CLAUDE_ARGS+=("$1")
      fi
      shift
      ;;
  esac
done

# Default to current directory
PROJECT_PATH="${PROJECT_PATH:-.}"

# Validate path exists
if [ ! -d "$PROJECT_PATH" ]; then
  echo "Error: Directory does not exist: $PROJECT_PATH"
  exit 1
fi

# Convert to absolute path
PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"

echo "Starting Claude sandbox for: $PROJECT_PATH"

# Extract git config from host
GIT_USER_NAME=$(git config --global user.name 2>/dev/null || echo "")
GIT_USER_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

# Build if needed (fast if cached)
if ! $NO_BUILD; then
  docker compose -f "$SCRIPT_DIR/docker-compose.yml" build --quiet
fi

# Run Claude with remaining args
PROJECT_PATH="$PROJECT_PATH" \
GIT_USER_NAME="$GIT_USER_NAME" \
GIT_USER_EMAIL="$GIT_USER_EMAIL" \
docker compose -f "$SCRIPT_DIR/docker-compose.yml" run --rm claude-sandbox "${CLAUDE_ARGS[@]}"
