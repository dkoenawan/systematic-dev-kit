#!/usr/bin/env bash
# install-schedule.sh
# Installs a cron job to run doc-maintainer maintain mode for a target repo.
# The cron job calls maintain.sh, which handles logging and claude invocation.
#
# Usage:
#   install-schedule.sh <absolute-path-to-target-repo> [--time HH:MM] [--days <days>] [--stale-days N]
#
# Options:
#   --time HH:MM      Time of day to run (UTC, 24-hour format, default: 09:00)
#   --days <days>     Days of the week to run (default: * meaning every day).
#                     Accepts cron day syntax: a number (0=Sun, 1=Mon, ..., 6=Sat),
#                     a name (sun, mon, tue, wed, thu, fri, sat), or a comma-separated
#                     combination. Examples: mon,wed,fri  |  1,3,5  |  mon-fri
#   --stale-days N    Staleness threshold in days passed to the skill (default: 30).
#                     A domain doc older than N days will be updated on the next run.
#   -h, --help        Show this help message

set -euo pipefail

SCRIPT_NAME="install-schedule.sh"

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME <absolute-path-to-target-repo> [--time HH:MM] [--days <days>] [--stale-days N]

Installs a cron job that runs:
  maintain.sh <target-repo> [--days N]
at the specified time and day(s). Output is logged to:
  <target-repo>/logs/doc-maintainer/YYYY-MM-DD.log

Arguments:
  <absolute-path-to-target-repo>   Absolute path to the git repository to document.

Options:
  --time HH:MM      Time of day (UTC, 24-hour, default: 09:00)
  --days <days>     Days of the week to run (default: *, every day).
                    Accepts cron day-of-week syntax:
                      Numbers:  0-7 (0 and 7 = Sunday)
                      Names:    sun, mon, tue, wed, thu, fri, sat (case-insensitive)
                      Ranges:   mon-fri
                      Lists:    mon,wed,fri  or  1,3,5
  --stale-days N    Staleness threshold in days (default: 30). Docs older than
                    N days will be updated on the next scheduled run.
  -h, --help        Show this help message

Examples:
  # Run every day at 01:00 UTC
  $SCRIPT_NAME /home/user/myproject --time 01:00

  # Run Monday, Wednesday, Friday at 08:30 UTC
  $SCRIPT_NAME /home/user/myproject --time 08:30 --days mon,wed,fri

  # Run every weekday at 09:00 UTC, treat docs as stale after 14 days
  $SCRIPT_NAME /home/user/myproject --days mon-fri --stale-days 14

Note:
  Times are interpreted as UTC by cron on most Linux systems.
  Day names are converted to their cron numeric equivalents for portability.
EOF
}

# --- Argument parsing ---

TARGET_REPO=""
RUN_TIME="09:00"
RUN_DAYS="*"
STALE_DAYS=""

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
    --days)
      if [[ -z "${2:-}" ]]; then
        echo "[$SCRIPT_NAME] Error: --days requires an argument." >&2
        exit 1
      fi
      RUN_DAYS="$2"
      shift 2
      ;;
    --stale-days)
      if [[ -z "${2:-}" ]]; then
        echo "[$SCRIPT_NAME] Error: --stale-days requires a numeric argument." >&2
        exit 1
      fi
      if ! echo "$2" | grep -qE '^[0-9]+$'; then
        echo "[$SCRIPT_NAME] Error: --stale-days value '$2' is not a positive integer." >&2
        exit 1
      fi
      STALE_DAYS="$2"
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

# --- Normalise --days to cron day-of-week field ---
# Converts day names to numbers for maximum cron compatibility.
# Input examples: mon,wed,fri | 1,3,5 | mon-fri | * | 0
# Output examples: 1,3,5      | 1,3,5 | 1-5     | * | 0

normalise_days() {
  local input="$1"
  # Replace day names (case-insensitive) with cron numbers.
  echo "$input" \
    | tr '[:upper:]' '[:lower:]' \
    | sed \
        -e 's/\bsun\b/0/g' \
        -e 's/\bmon\b/1/g' \
        -e 's/\btue\b/2/g' \
        -e 's/\bwed\b/3/g' \
        -e 's/\bthu\b/4/g' \
        -e 's/\bfri\b/5/g' \
        -e 's/\bsat\b/6/g'
}

CRON_DAYS=$(normalise_days "$RUN_DAYS")

# Basic sanity check: result should only contain digits, commas, hyphens, and *.
if ! echo "$CRON_DAYS" | grep -qE '^[0-9,\-\*]+$'; then
  echo "[$SCRIPT_NAME] Error: --days value '$RUN_DAYS' could not be parsed into a valid cron day field." >&2
  echo "[$SCRIPT_NAME] Valid examples: mon,wed,fri | 1,3,5 | mon-fri | * | 0" >&2
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

SCRIPTS_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
MAINTAIN_SH="$SCRIPTS_DIR/maintain.sh"

if [[ ! -f "$MAINTAIN_SH" ]]; then
  echo "[$SCRIPT_NAME] Error: maintain.sh not found at '$MAINTAIN_SH'." >&2
  exit 1
fi

# --- Build cron entry ---

# Append --days to maintain.sh call if a stale-days threshold was specified.
MAINTAIN_ARGS="$TARGET_REPO"
if [[ -n "$STALE_DAYS" ]]; then
  MAINTAIN_ARGS="$TARGET_REPO --days $STALE_DAYS"
fi

# The marker comment lets uninstall-schedule.sh identify this entry uniquely.
CRON_MARKER="# doc-maintainer: $TARGET_REPO"
CRON_ENTRY="$RUN_MINUTE $RUN_HOUR * * $CRON_DAYS /bin/bash $MAINTAIN_SH $MAINTAIN_ARGS $CRON_MARKER"

echo "[$SCRIPT_NAME] Target repo: $TARGET_REPO"
echo "[$SCRIPT_NAME] Schedule:    $RUN_TIME UTC on days '$RUN_DAYS' (cron: $RUN_MINUTE $RUN_HOUR * * $CRON_DAYS)"
[[ -n "$STALE_DAYS" ]] && echo "[$SCRIPT_NAME] Stale days:  $STALE_DAYS"
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

# Human-readable day description for the summary.
if [[ "$RUN_DAYS" == "*" ]]; then
  DAY_DESC="every day"
else
  DAY_DESC="$RUN_DAYS"
fi

echo ""
echo "============================================================"
echo " doc-maintainer cron job installed"
echo "============================================================"
echo ""
echo " Repo:       $TARGET_REPO"
echo " Schedule:   $RUN_TIME UTC, $DAY_DESC"
echo " Cron field: $RUN_MINUTE $RUN_HOUR * * $CRON_DAYS"
echo " Script:     $MAINTAIN_SH"
echo " Stale days: ${STALE_DAYS:-30 (default)}"
echo " Logs:       $TARGET_REPO/logs/doc-maintainer/YYYY-MM-DD.log"
echo ""
echo " Verify the entry:"
echo "   crontab -l | grep doc-maintainer"
echo ""
echo " Run manually (without waiting for cron):"
echo "   /bin/bash $MAINTAIN_SH $MAINTAIN_ARGS"
echo ""
echo " Uninstall:"
echo "   bash $SCRIPTS_DIR/uninstall-schedule.sh $TARGET_REPO"
echo ""
echo "============================================================"
