#!/usr/bin/env bash
# uninstall-schedule.sh
# Disables and stops the systemd user timer for a target git repository.
# Does NOT remove the template unit files (doc-maintainer@.service and
# doc-maintainer@.timer) — other repo instances may still use them.
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

Disables and stops the daily doc-maintainer timer for the specified repository.

Arguments:
  <absolute-path-to-target-repo>   Absolute path to the git repository whose
                                   timer should be removed.

Note:
  This command disables the specific timer instance for this repo. The shared
  template unit files (~/.config/systemd/user/doc-maintainer@.service and
  doc-maintainer@.timer) are NOT removed, because other repositories may still
  have timers using them. To remove the template files entirely, delete them
  manually after all instances have been uninstalled:
    rm ~/.config/systemd/user/doc-maintainer@.service
    rm ~/.config/systemd/user/doc-maintainer@.timer
    systemctl --user daemon-reload

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

# --- Validate target repo exists ---

if [[ ! -d "$TARGET_REPO" ]]; then
  echo "[$SCRIPT_NAME] Warning: '$TARGET_REPO' does not exist on disk." >&2
  echo "[$SCRIPT_NAME] Proceeding with uninstall anyway (the timer may still be registered)." >&2
fi

# --- Compute escaped instance name ---

ESCAPED_INSTANCE=$(systemd-escape "$TARGET_REPO")
UNIT_NAME="doc-maintainer@${ESCAPED_INSTANCE}"

echo "[$SCRIPT_NAME] Target repo:   $TARGET_REPO"
echo "[$SCRIPT_NAME] Unit instance: ${UNIT_NAME}.timer"

# --- Disable and stop the timer instance ---

# Check if the timer unit is known to systemd before trying to disable it.
if systemctl --user list-unit-files "${UNIT_NAME}.timer" &>/dev/null && \
   systemctl --user list-unit-files "${UNIT_NAME}.timer" | grep -q "doc-maintainer"; then
  echo "[$SCRIPT_NAME] Disabling and stopping ${UNIT_NAME}.timer..."
  systemctl --user disable --now "${UNIT_NAME}.timer" || {
    echo "[$SCRIPT_NAME] Warning: 'systemctl --user disable --now' returned non-zero." >&2
    echo "[$SCRIPT_NAME] The timer may already have been stopped or was never started." >&2
  }
else
  echo "[$SCRIPT_NAME] Timer ${UNIT_NAME}.timer not found in systemd — nothing to disable."
fi

# --- Reload daemon ---

echo "[$SCRIPT_NAME] Reloading systemd user daemon..."
systemctl --user daemon-reload

# --- Summary ---

echo ""
echo "============================================================"
echo " doc-maintainer timer uninstalled"
echo "============================================================"
echo ""
echo " Removed instance: ${UNIT_NAME}.timer"
echo " Repo:             $TARGET_REPO"
echo ""
echo " Template unit files were NOT removed."
echo " Other repos using doc-maintainer timers are unaffected."
echo ""
echo " To verify no timers remain:"
echo "   systemctl --user list-timers | grep doc-maintainer"
echo ""
echo " To remove template files entirely (only if no other instances remain):"
echo "   rm ~/.config/systemd/user/doc-maintainer@.service"
echo "   rm ~/.config/systemd/user/doc-maintainer@.timer"
echo "   systemctl --user daemon-reload"
echo "============================================================"
