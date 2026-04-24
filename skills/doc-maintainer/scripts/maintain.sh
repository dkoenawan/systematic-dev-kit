#!/usr/bin/env bash
# maintain.sh
# Wrapper script called by cron to run doc-maintainer maintain mode.
# Handles path resolution, logging, and error capture.
#
# Usage:
#   maintain.sh <absolute-path-to-target-repo> [--days N]
#
# Options:
#   --days N   Staleness threshold in days passed to the skill (default: 30).
#              Exposed as DOC_STALE_THRESHOLD_DAYS in the environment.
#
# Logs to: <target-repo>/logs/doc-maintainer/YYYY-MM-DD.log
#
# The log directory is created automatically if it does not exist.
# Add logs/ to .gitignore if you do not want log files committed.

set -euo pipefail

SCRIPT_NAME="maintain.sh"

# --- Resolve plugin root ---
# This script lives at <plugin-root>/skills/doc-maintainer/scripts/maintain.sh
PLUGIN_DIR="$(cd "$(dirname "$(realpath "$0")")/../../.." && pwd)"

# --- Argument parsing ---

TARGET_REPO=""
STALE_DAYS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --days)
      if [[ -z "${2:-}" ]]; then
        echo "[$SCRIPT_NAME] Error: --days requires a numeric argument." >&2
        exit 1
      fi
      if ! echo "$2" | grep -qE '^[0-9]+$'; then
        echo "[$SCRIPT_NAME] Error: --days value '$2' is not a positive integer." >&2
        exit 1
      fi
      STALE_DAYS="$2"
      shift 2
      ;;
    -*)
      echo "[$SCRIPT_NAME] Error: Unknown option '$1'." >&2
      exit 1
      ;;
    *)
      if [[ -n "$TARGET_REPO" ]]; then
        echo "[$SCRIPT_NAME] Error: Unexpected argument '$1'. Only one repo path is accepted." >&2
        exit 1
      fi
      TARGET_REPO="$1"
      shift
      ;;
  esac
done

# --- Validate repo argument ---

if [[ -z "$TARGET_REPO" ]]; then
  echo "[$SCRIPT_NAME] Error: No target repo path provided." >&2
  echo "[$SCRIPT_NAME] Usage: $SCRIPT_NAME <absolute-path-to-target-repo> [--days N]" >&2
  exit 1
fi

if [[ ! -d "$TARGET_REPO" ]]; then
  echo "[$SCRIPT_NAME] Error: '$TARGET_REPO' does not exist or is not a directory." >&2
  exit 1
fi

if [[ ! -d "$TARGET_REPO/.git" ]]; then
  echo "[$SCRIPT_NAME] Error: '$TARGET_REPO' is not a git repository." >&2
  exit 1
fi

# --- Set up logging ---

LOG_DIR="$TARGET_REPO/logs/doc-maintainer"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).log"

mkdir -p "$LOG_DIR"

# --- Verify claude is available ---

if ! command -v claude &>/dev/null; then
  echo "[$SCRIPT_NAME] Error: 'claude' not found on PATH." >&2
  echo "[$SCRIPT_NAME] Ensure ~/.local/bin (or wherever claude is installed) is on PATH." >&2
  exit 1
fi

# --- Export staleness threshold if provided ---

if [[ -n "$STALE_DAYS" ]]; then
  export DOC_STALE_THRESHOLD_DAYS="$STALE_DAYS"
fi

# --- Run ---

{
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ===== doc-maintainer maintain started ====="
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Repo:        $TARGET_REPO"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Plugin dir:  $PLUGIN_DIR"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Stale days:  ${STALE_DAYS:-30 (default)}"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Log file:    $LOG_FILE"
} >> "$LOG_FILE"

cd "$TARGET_REPO"

# Run claude in non-interactive mode. Exit code is captured to log it, but we
# do not propagate a non-zero exit — a failed maintain run should not cause the
# cron job to spam the system mail spool.
claude \
  --plugin-dir "$PLUGIN_DIR" \
  -p "/systematic-dev-kit:doc-maintainer maintain" \
  --dangerously-skip-permissions \
  >> "$LOG_FILE" 2>&1 \
  && EXIT_CODE=0 || EXIT_CODE=$?

{
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] doc-maintainer exited with code $EXIT_CODE"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ===== doc-maintainer maintain finished ====="
  echo ""
} >> "$LOG_FILE"
