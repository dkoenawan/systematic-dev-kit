#!/usr/bin/env bash
# find-stale-domains.sh
# Walks docs/*/overview.md in the current directory.
# For each file, reads last_updated from YAML frontmatter (falls back to mtime).
# Prints paths whose age exceeds the threshold to stdout, sorted oldest-first.
# Exits 0 always — no stale docs is not an error.
#
# Usage:
#   find-stale-domains.sh [--days N] [-h|--help]
#
# Options:
#   --days N   Staleness threshold in days (default: 30). Overrides the
#              DOC_STALE_THRESHOLD_DAYS environment variable.
#
# Output:
#   One path per line (e.g. docs/auth/overview.md), sorted oldest-first.
#   Empty output means no stale docs were found.
#
# Dependencies: bash, coreutils (date, stat, sort) — no external tools required.

set -euo pipefail

SCRIPT_NAME="find-stale-domains.sh"

# Default threshold: env var, then hardcoded fallback.
STALE_THRESHOLD_DAYS="${DOC_STALE_THRESHOLD_DAYS:-30}"

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [--days N]

Walks docs/*/overview.md in the current working directory.
Prints the path of any overview.md whose last_updated date (from YAML
frontmatter) is more than N days ago (default: $STALE_THRESHOLD_DAYS).

Falls back to file mtime if no last_updated field is found in frontmatter.

Options:
  --days N   Override the staleness threshold (days). Also settable via
             the DOC_STALE_THRESHOLD_DAYS environment variable.
  -h, --help Show this help message.

Output is sorted oldest-first (one path per line).
Exits 0 always.
EOF
}

# --- Argument parsing ---

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --days)
      if [[ -z "${2:-}" ]]; then
        echo "[$SCRIPT_NAME] Error: --days requires a numeric argument." >&2
        exit 1
      fi
      if ! echo "$2" | grep -qE '^[0-9]+$'; then
        echo "[$SCRIPT_NAME] Error: --days value '$2' is not a positive integer." >&2
        exit 1
      fi
      STALE_THRESHOLD_DAYS="$2"
      shift 2
      ;;
    *)
      echo "[$SCRIPT_NAME] Error: Unknown argument '$1'. Run with --help for usage." >&2
      exit 1
      ;;
  esac
done

# --- Helpers ---

# Extract last_updated value from YAML frontmatter of a file.
# Frontmatter is delimited by --- on the first and second lines.
# Prints the date string (YYYY-MM-DD) or empty string if not found.
extract_last_updated() {
  local file="$1"
  local in_frontmatter=0
  local found_open=0

  while IFS= read -r line; do
    if [[ $found_open -eq 0 ]]; then
      if [[ "$line" == "---" ]]; then
        found_open=1
        in_frontmatter=1
        continue
      else
        break
      fi
    fi

    if [[ $in_frontmatter -eq 1 && "$line" == "---" ]]; then
      break
    fi

    if [[ $in_frontmatter -eq 1 ]]; then
      if echo "$line" | grep -qE '^last_updated:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}'; then
        echo "$line" | sed -E 's/^last_updated:[[:space:]]*//'
        return
      fi
    fi
  done < "$file"

  echo ""
}

# Convert a YYYY-MM-DD string to a Unix timestamp (seconds since epoch).
date_to_epoch() {
  local datestr="$1"
  date -d "$datestr" +%s 2>/dev/null || echo ""
}

# --- Main ---

NOW_EPOCH=$(date +%s)
THRESHOLD_SECONDS=$(( STALE_THRESHOLD_DAYS * 86400 ))

declare -a RESULTS=()

for overview_file in docs/*/overview.md; do
  [[ -e "$overview_file" ]] || continue

  last_updated=$(extract_last_updated "$overview_file")

  if [[ -n "$last_updated" ]]; then
    file_epoch=$(date_to_epoch "$last_updated")
    if [[ -z "$file_epoch" ]]; then
      echo "[$SCRIPT_NAME] Warning: could not parse last_updated='$last_updated' in $overview_file — using mtime." >&2
      file_epoch=$(stat -c %Y "$overview_file" 2>/dev/null || echo "$NOW_EPOCH")
    fi
  else
    file_epoch=$(stat -c %Y "$overview_file" 2>/dev/null || echo "$NOW_EPOCH")
  fi

  age_seconds=$(( NOW_EPOCH - file_epoch ))

  if [[ $age_seconds -gt $THRESHOLD_SECONDS ]]; then
    RESULTS+=("${file_epoch} ${overview_file}")
  fi
done

if [[ ${#RESULTS[@]} -gt 0 ]]; then
  printf '%s\n' "${RESULTS[@]}" | sort -n | awk '{print $2}'
fi

exit 0
