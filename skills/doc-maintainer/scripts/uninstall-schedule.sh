#!/usr/bin/env bash
# uninstall-schedule.sh
# Removes the daily cron job for doc-maintainer on a target repository.
#
# Usage:
#   uninstall-schedule.sh <absolute-path-to-target-repo>
#
# Options:
#   -h, --help   Show this help message

set -euo pipefail

SCRIPT_NAME="uninstall-schedule.sh"

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME <absolute-path-to-target-repo>

Removes the doc-maintainer daily cron entry for the specified repository.

Arguments:
  <absolute-path-to-target-repo>   Absolute path to the git repository whose
                                   cron job should be removed.

Examples:
  $SCRIPT_NAME /home/user/myproject
EOF
}

# --- Argument parsing ---

TARGET_REPO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "[$SCRIPT_NAME] Error: Unknown option '$1'. Run with --help for usage." >&2
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

# --- Validate required argument ---

if [[ -z "$TARGET_REPO" ]]; then
  echo "[$SCRIPT_NAME] Error: No target repo path provided." >&2
  echo "[$SCRIPT_NAME] Run with --help for usage." >&2
  exit 1
fi

echo "[$SCRIPT_NAME] Target repo: $TARGET_REPO"

# --- Remove matching cron entries ---

EXISTING_CRON=$(crontab -l 2>/dev/null || true)
MARKER="doc-maintainer: $TARGET_REPO"

if ! echo "$EXISTING_CRON" | grep -qF "$MARKER"; then
  echo "[$SCRIPT_NAME] No cron entry found for '$TARGET_REPO'. Nothing to remove."
  exit 0
fi

# Remove every line that contains the marker (handles duplicates from partial installs)
NEW_CRON=$(echo "$EXISTING_CRON" | grep -vF "$MARKER")

echo "$NEW_CRON" | crontab -

echo "[$SCRIPT_NAME] Cron entry removed."

# --- Verify removal ---

REMAINING=$(crontab -l 2>/dev/null | grep -F "$MARKER" || true)
if [[ -n "$REMAINING" ]]; then
  echo "[$SCRIPT_NAME] Warning: entry still present after removal — manual cleanup may be needed:" >&2
  echo "$REMAINING" >&2
  exit 1
fi

# --- Summary ---

echo ""
echo "============================================================"
echo " doc-maintainer cron job removed"
echo "============================================================"
echo ""
echo " Removed entry for: $TARGET_REPO"
echo ""
echo " Verify:"
echo "   crontab -l | grep doc-maintainer"
echo ""
echo "============================================================"
