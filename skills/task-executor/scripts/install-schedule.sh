#!/usr/bin/env bash
set -euo pipefail

# install-schedule.sh <repo-path> [--time HH:MM] [--every Nh]
# Registers a cron job to run execute-daily.sh for the given repo.
# Preflights: gh auth, no clashing claude cron jobs at the same time.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="${1:?Usage: install-schedule.sh <repo-path> [--time HH:MM] [--every Nh]}"
shift

HOUR="*/6"
MINUTE="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --time)
      IFS=: read -r MINUTE_VAL HOUR_VAL <<< "$2"
      HOUR="$HOUR_VAL"
      MINUTE="$MINUTE_VAL"
      shift 2
      ;;
    --every)
      N="${2%h}"
      HOUR="*/$N"
      MINUTE="0"
      shift 2
      ;;
    *) echo "error:unknown option $1" >&2; exit 1 ;;
  esac
done

# Preflight: gh auth
if ! gh auth status &>/dev/null; then
  echo "error:gh not authenticated — run 'gh auth login' first" >&2
  exit 1
fi

REPO_ABS="$(cd "$REPO" && pwd)"
CRON_LINE="$MINUTE $HOUR * * * \"$SCRIPT_DIR/execute-daily.sh\" \"$REPO_ABS\""

# Check for clashing claude cron jobs
if crontab -l 2>/dev/null | grep -q "execute-daily.sh.*$(echo "$REPO_ABS" | sed 's|/|\\/|g')"; then
  echo "error:cron job already exists for $REPO_ABS — run uninstall-schedule.sh first" >&2
  exit 1
fi

# Check for time collision with any other claude job
EXISTING=$(crontab -l 2>/dev/null | grep "execute-daily.sh" || true)
if [[ -n "$EXISTING" ]]; then
  echo "warning: existing task-executor cron jobs found for other repos:" >&2
  echo "$EXISTING" >&2
fi

(crontab -l 2>/dev/null; echo "$CRON_LINE") | crontab -

echo "ok: cron installed for $REPO_ABS"
echo "schedule: $MINUTE $HOUR * * *"
echo "cron_line: $CRON_LINE"
