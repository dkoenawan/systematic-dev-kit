#!/usr/bin/env bash
# install-schedule.sh
# Sets up a systemd user timer to run doc-maintainer maintain mode daily
# for a target git repository.
#
# Usage:
#   install-schedule.sh <absolute-path-to-target-repo> [--time HH:MM]
#
# Options:
#   --time HH:MM    Time of day to run the daily timer (default: 09:00)
#   -h, --help      Show this help message

set -euo pipefail

SCRIPT_NAME="install-schedule.sh"

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME <absolute-path-to-target-repo> [--time HH:MM]

Sets up a systemd user timer to run:
  claude -p "/systematic-dev-kit:doc-maintainer maintain" --dangerously-skip-permissions
inside the target repository once per day at the specified time.

Arguments:
  <absolute-path-to-target-repo>   Absolute path to the git repository to document.

Options:
  --time HH:MM   Time of day for the daily run (24-hour format, default: 09:00)
  -h, --help     Show this help message

Examples:
  $SCRIPT_NAME /home/user/myproject
  $SCRIPT_NAME /home/user/myproject --time 08:30

Note:
  This script uses systemd template units (doc-maintainer@.service and
  doc-maintainer@.timer). A single set of template unit files supports
  multiple repos — each repo is a separate instance identified by its
  escaped path. The template files are written to:
    ~/.config/systemd/user/doc-maintainer@.service
    ~/.config/systemd/user/doc-maintainer@.timer

  IMPORTANT: The service runs claude with --dangerously-skip-permissions,
  which is required for unattended headless execution. If you prefer to
  handle approval prompts manually, remove that flag from the ExecStart
  line in the service unit file after installation.
EOF
}

# --- Argument parsing ---

TARGET_REPO=""
RUN_TIME="13:00"

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

echo "[$SCRIPT_NAME] Target repo: $TARGET_REPO"
echo "[$SCRIPT_NAME] Scheduled time: $RUN_TIME daily"

# --- Compute escaped instance name ---
# systemd-escape converts the repo path to a safe string usable as @<instance>

ESCAPED_INSTANCE=$(systemd-escape "$TARGET_REPO")
echo "[$SCRIPT_NAME] Systemd instance name: $ESCAPED_INSTANCE"

UNIT_NAME="doc-maintainer@${ESCAPED_INSTANCE}"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

# Resolve the plugin root: this script lives at <plugin-root>/skills/doc-maintainer/scripts/
PLUGIN_DIR="$(cd "$(dirname "$(realpath "$0")")/../../.." && pwd)"

# --- Write template unit files ---

mkdir -p "$SYSTEMD_USER_DIR"

SERVICE_UNIT_FILE="$SYSTEMD_USER_DIR/doc-maintainer@.service"
TIMER_UNIT_FILE="$SYSTEMD_USER_DIR/doc-maintainer@.timer"

# Write the service template unit
# %I expands to the unescaped instance name (the repo path) at runtime.
# Note: heredoc is unquoted so $PLUGIN_DIR is substituted at install time.
cat > "$SERVICE_UNIT_FILE" <<UNIT
[Unit]
Description=doc-maintainer: daily documentation maintenance for %i
After=network.target

[Service]
Type=oneshot
# %I is the unescaped instance name — the absolute path to the target repo.
# %i is the escaped form; %I is the decoded path suitable for WorkingDirectory=.
#
# NOTE: --dangerously-skip-permissions is required for unattended headless
# execution. Claude cannot prompt for approval when invoked via -p (non-interactive).
# If you prefer to handle approval prompts manually, remove that flag and run
# the timer interactively, or pre-approve all required tools in your Claude config.
WorkingDirectory=%I
ExecStart=/bin/bash -lc 'claude --plugin-dir ${PLUGIN_DIR} -p "/systematic-dev-kit:doc-maintainer maintain" --dangerously-skip-permissions'
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
UNIT

echo "[$SCRIPT_NAME] Wrote service template: $SERVICE_UNIT_FILE"

# Write the timer template unit
# OnCalendar uses a specific HH:MM time, filled in by this script.
# Persistent=true means if the system was off at the scheduled time,
# the timer fires once at next boot to catch up.
cat > "$TIMER_UNIT_FILE" <<UNIT
[Unit]
Description=doc-maintainer: daily timer for %i

[Timer]
OnCalendar=*-*-* ${RUN_HOUR}:${RUN_MINUTE}:00
Persistent=true
Unit=doc-maintainer@%i.service

[Install]
WantedBy=timers.target
UNIT

echo "[$SCRIPT_NAME] Wrote timer template: $TIMER_UNIT_FILE"

# --- Reload systemd and enable the timer instance ---

echo "[$SCRIPT_NAME] Reloading systemd user daemon..."
systemctl --user daemon-reload

echo "[$SCRIPT_NAME] Enabling and starting timer: ${UNIT_NAME}.timer"
systemctl --user enable --now "${UNIT_NAME}.timer"

# --- Summary ---

echo ""
echo "============================================================"
echo " doc-maintainer timer installed successfully"
echo "============================================================"
echo ""
echo " Instance:  ${UNIT_NAME}.timer"
echo " Repo:      $TARGET_REPO"
echo " Schedule:  daily at $RUN_TIME (Persistent=true)"
echo ""
echo " Check timer status:"
echo "   systemctl --user status ${UNIT_NAME}.timer"
echo ""
echo " Check service logs:"
echo "   journalctl --user -u ${UNIT_NAME}.service -n 50 --no-pager"
echo ""
echo " Run manually (test without waiting for timer):"
echo "   systemctl --user start ${UNIT_NAME}.service"
echo ""
echo " Uninstall:"
echo "   bash $(dirname "$(realpath "$0")")/uninstall-schedule.sh $TARGET_REPO"
echo ""
echo "============================================================"
