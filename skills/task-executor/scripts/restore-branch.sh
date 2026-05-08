#!/usr/bin/env bash
set -euo pipefail

# restore-branch.sh <repo-path>
# Checks out the branch that was active before prepare-branch.sh ran.

REPO="${1:?Usage: restore-branch.sh <repo-path>}"
cd "$REPO"

ORIG_BRANCH_FILE=".git/TASK_EXECUTOR_ORIG_BRANCH"
if [[ ! -f "$ORIG_BRANCH_FILE" ]]; then
  echo "ok: no saved branch to restore"
  exit 0
fi

ORIG_BRANCH="$(cat "$ORIG_BRANCH_FILE")"
rm -f "$ORIG_BRANCH_FILE"

git checkout "$ORIG_BRANCH" 2>/dev/null
echo "ok: restored to $ORIG_BRANCH"
