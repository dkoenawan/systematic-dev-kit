#!/usr/bin/env bash
set -euo pipefail

# find-active-plan.sh <repo-path>
# Finds specs/*/tasks.md with status: in-progress.
# Stdout: path | "none" | "multiple:<path1>:<path2>..."

REPO="${1:?Usage: find-active-plan.sh <repo-path>}"
cd "$REPO"

mapfile -t FOUND < <(grep -rl '^status: in-progress' specs/*/tasks.md 2>/dev/null || true)

case "${#FOUND[@]}" in
  0) echo "none" ;;
  1) echo "${FOUND[0]}" ;;
  *) echo "multiple:$(IFS=:; echo "${FOUND[*]}")" ;;
esac
