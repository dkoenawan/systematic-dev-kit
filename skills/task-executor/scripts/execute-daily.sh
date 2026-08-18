#!/usr/bin/env bash
set -euo pipefail

# execute-daily.sh <repo-path>
# Cron entry point. Acquires lockfile, logs to logs/task-executor/YYYY-MM-DD.log,
# invokes claude in execute mode.

REPO="${1:?Usage: execute-daily.sh <repo-path>}"
REPO_ABS="$(cd "$REPO" && pwd)"

LOG_DIR="$REPO_ABS/logs/task-executor"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).log"
LOCK_FILE="$LOG_DIR/.lock"

mkdir -p "$LOG_DIR"

# Acquire lockfile (E13: exit silently if held)
if ! mkdir "$LOCK_FILE" 2>/dev/null; then
  exit 0
fi
trap 'rmdir "$LOCK_FILE" 2>/dev/null || true' EXIT

{
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ===== task-executor started ====="

  CLAUDE_BIN="${CLAUDE_BIN:-$(which claude 2>/dev/null || echo "$HOME/.local/bin/claude")}"

  cd "$REPO_ABS"

  "$CLAUDE_BIN" \
    --dangerously-skip-permissions \
    -p "You are running /compass:task-executor in execute mode for the repository at $REPO_ABS. Follow the SKILL.md execute mode instructions exactly. Do not ask for clarification — proceed with the daily run sequence."

  EXIT_CODE=$?
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] task-executor exited with code $EXIT_CODE"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ===== task-executor finished ====="
  exit $EXIT_CODE
} >> "$LOG_FILE" 2>&1
