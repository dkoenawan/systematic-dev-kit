#!/usr/bin/env bash
set -euo pipefail

# uninstall-schedule.sh <repo-path>
# Removes the cron job for the given repo.

REPO="${1:?Usage: uninstall-schedule.sh <repo-path>}"
REPO_ABS="$(cd "$REPO" && pwd)"

ESCAPED="$(echo "$REPO_ABS" | sed 's|/|\\/|g')"

if ! crontab -l 2>/dev/null | grep -q "execute-daily.sh.*$ESCAPED"; then
  echo "ok: no cron job found for $REPO_ABS (nothing to remove)"
  exit 0
fi

crontab -l 2>/dev/null | grep -v "execute-daily.sh.*$ESCAPED" | crontab -

echo "ok: cron job removed for $REPO_ABS"
