#!/usr/bin/env bash
# install-schedule.sh
# Installs a cron job to run doc-maintainer maintain mode daily for a target repo.
# The cron job calls maintain.sh, which handles logging and claude invocation.
#
# Usage:
#   install-schedule.sh <absolute-path-to-target-repo> [--time HH:MM]
#
# Options:
#   --time HH:MM    Time of day to run (UTC, 24-hour format, default: 09:00)
#   -h, --help      Show this help message

set -euo pipefail

SCRIPT_NAME="install-schedule.sh"

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME <absolute-path-to-target-repo> [--time HH:MM]

Installs a daily cron job that runs:
  maintain.sh <target-repo>
at the specified time (UTC). Output is logged to:
  <target-repo>/logs/doc-maintainer/YYYY-MM-DD.log

Arguments:
  <absolute-path-to-target-repo>   Absolute path to the git repository to document.

Options:
  --time HH:MM   Time of day for the daily run (UTC, 24-hour format, default: 09:00)
  -h, --help     Show this help message

Examples:
  $SCRIPT_NAME /home/user/myproject
  $SCRIPT_NAME /home/user/myproject --time 08:30

Note:
  The cron entry uses the full path to maintain.sh so it works without requiring
  the plugin directory to be on PATH. Times are interpreted as UTC by cron on most
  Linux systems. Adjust for your timezone if your cron daemon uses local time.
EOF
}

# --- Argument parsing ---

TARGET_REPO=""
RUN_TIME="09:00"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --time)
      if [[ -z "${2:-}" ]]; then
        echo "[$SCRIPT_NAME] Error: --time requires an argument (HH:MM)." >&2
        exit 1
      fi
      RUN_TIME="$2"
      shift 2
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

# --- Validate time format ---

if ! echo "$RUN_TIME" | grep -qE '^[0-2][0-9]:[0-5][0-9]$'; then
  echo "[$SCRIPT_NAME] Error: Invalid time format '$RUN_TIME'. Expected HH:MM (e.g. 09:00)." >&2
  exit 1
fi

RUN_HOUR="${RUN_TIME%%:*}"
RUN_MINUTE="${RUN_TIME##*:}"

if [[ "$RUN_HOUR" -gt 23 ]]; then
  echo "[$SCRIPT_NAME] Error: Hour '$RUN_HOUR' is out of range (00-23)." >&2
  exit 1
fi

# --- Validate target repo ---

if [[ ! -d "$TARGET_REPO" ]]; then
  echo "[$SCRIPT_NAME] Error: '$TARGET_REPO' does not exist or is not a directory." >&2
  exit 1
fi

if [[ ! -d "$TARGET_REPO/.git" ]]; then
  echo "[$SCRIPT_NAME] Error: '$TARGET_REPO' is not a git repository (no .git directory found)." >&2
  exit 1
fi

# --- Resolve script paths ---

# This script lives at <plugin-root>/skills/doc-maintainer/scripts/
SCRIPTS_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
MAINTAIN_SH="$SCRIPTS_DIR/maintain.sh"

if [[ ! -f "$MAINTAIN_SH" ]]; then
  echo "[$SCRIPT_NAME] Error: maintain.sh not found at '$MAINTAIN_SH'." >&2
  exit 1
fi

# --- Build cron entry ---

# Format: <minute> <hour> * * * /bin/bash <maintain.sh> <target-repo>
# The marker comment allows uninstall-schedule.sh to identify this entry.
CRON_MARKER="# doc-maintainer: $TARGET_REPO"
CRON_ENTRY="$RUN_MINUTE $RUN_HOUR * * * /bin/bash $MAINTAIN_SH $TARGET_REPO $CRON_MARKER"

echo "[$SCRIPT_NAME] Target repo: $TARGET_REPO"
echo "[$SCRIPT_NAME] Schedule:    daily at $RUN_TIME UTC"
echo "[$SCRIPT_NAME] Cron entry:  $CRON_ENTRY"

# --- Check for duplicate ---

EXISTING_CRON=$(crontab -l 2>/dev/null || true)

if echo "$EXISTING_CRON" | grep -qF "doc-maintainer: $TARGET_REPO"; then
  echo "[$SCRIPT_NAME] A cron entry for this repo already exists. Removing old entry first."
  EXISTING_CRON=$(echo "$EXISTING_CRON" | grep -vF "doc-maintainer: $TARGET_REPO")
fi

# --- Install cron entry ---

printf '%s\n%s\n' "$EXISTING_CRON" "$CRON_ENTRY" | crontab -

echo "[$SCRIPT_NAME] Cron entry installed."

# --- Summary ---

echo ""
echo "============================================================"
echo " doc-maintainer cron job installed"
echo "============================================================"
echo ""
echo " Repo:     $TARGET_REPO"
echo " Schedule: daily at $RUN_TIME UTC (cron: $RUN_MINUTE $RUN_HOUR * * *)"
echo " Script:   $MAINTAIN_SH"
echo " Logs:     $TARGET_REPO/logs/doc-maintainer/YYYY-MM-DD.log"
echo ""
echo " Verify the entry:"
echo "   crontab -l | grep doc-maintainer"
echo ""
echo " Run manually (without waiting for cron):"
echo "   /bin/bash $MAINTAIN_SH $TARGET_REPO"
echo ""
echo " Uninstall:"
echo "   bash $SCRIPTS_DIR/uninstall-schedule.sh $TARGET_REPO"
echo ""
echo "============================================================"
