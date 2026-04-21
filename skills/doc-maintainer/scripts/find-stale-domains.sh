#!/usr/bin/env bash
# find-stale-domains.sh
# Walks docs/*/overview.md in the current directory.
# For each file, reads last_updated from YAML frontmatter (falls back to mtime).
# Prints paths whose age exceeds 30 days to stdout, sorted oldest-first.
# Exits 0 always — no stale docs is not an error.
#
# Usage:
#   find-stale-domains.sh [-h|--help]
#
# Output:
#   One path per line (e.g. docs/auth/overview.md), sorted oldest-first.
#   Empty output means no stale docs were found.
#
# Dependencies: bash, coreutils (date, stat, sort) — no external tools required.

set -euo pipefail

SCRIPT_NAME="find-stale-domains.sh"
STALE_THRESHOLD_DAYS=30

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<EOF
Usage: $SCRIPT_NAME

Walks docs/*/overview.md in the current working directory.
Prints the path of any overview.md whose last_updated date (from YAML
frontmatter) is more than $STALE_THRESHOLD_DAYS days ago.

Falls back to file mtime if no last_updated field is found in frontmatter.

Output is sorted oldest-first (one path per line).
Exits 0 always.
EOF
  exit 0
fi

# --- Helpers ---

# Extract last_updated value from YAML frontmatter of a file.
# Frontmatter is delimited by --- on the first and second lines.
# Prints the date string (YYYY-MM-DD) or empty string if not found.
extract_last_updated() {
  local file="$1"
  local in_frontmatter=0
  local found_open=0

  while IFS= read -r line; do
    # First line must be ---
    if [[ $found_open -eq 0 ]]; then
      if [[ "$line" == "---" ]]; then
        found_open=1
        in_frontmatter=1
        continue
      else
        # No frontmatter block at all
        break
      fi
    fi

    # Closing --- ends the frontmatter
    if [[ $in_frontmatter -eq 1 && "$line" == "---" ]]; then
      break
    fi

    # Look for last_updated: YYYY-MM-DD
    if [[ $in_frontmatter -eq 1 ]]; then
      if echo "$line" | grep -qE '^last_updated:[[:space:]]*[0-9]{4}-[0-9]{2}-[0-9]{2}'; then
        echo "$line" | sed -E 's/^last_updated:[[:space:]]*//'
        return
      fi
    fi
  done < "$file"

  # Not found
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

# Collect results as "epoch path" pairs so we can sort numerically.
declare -a RESULTS=()

# Walk docs/*/overview.md — glob only, no find, no subshells.
for overview_file in docs/*/overview.md; do
  # Skip if the glob matched nothing (bash expands to literal string).
  [[ -e "$overview_file" ]] || continue

  # Attempt to read last_updated from frontmatter.
  last_updated=$(extract_last_updated "$overview_file")

  if [[ -n "$last_updated" ]]; then
    file_epoch=$(date_to_epoch "$last_updated")
    if [[ -z "$file_epoch" ]]; then
      # date -d failed (malformed date) — fall back to mtime.
      echo "[$SCRIPT_NAME] Warning: could not parse last_updated='$last_updated' in $overview_file — using mtime." >&2
      file_epoch=$(stat -c %Y "$overview_file" 2>/dev/null || echo "$NOW_EPOCH")
    fi
  else
    # No frontmatter date found — use mtime.
    file_epoch=$(stat -c %Y "$overview_file" 2>/dev/null || echo "$NOW_EPOCH")
  fi

  age_seconds=$(( NOW_EPOCH - file_epoch ))

  if [[ $age_seconds -gt $THRESHOLD_SECONDS ]]; then
    RESULTS+=("${file_epoch} ${overview_file}")
  fi
done

# Sort by epoch ascending (oldest first) and print only the path.
if [[ ${#RESULTS[@]} -gt 0 ]]; then
  printf '%s\n' "${RESULTS[@]}" | sort -n | awk '{print $2}'
fi

exit 0
