#!/usr/bin/env bash
set -euo pipefail

# check-idempotency.sh <repo-path> <plan-file>
# Checks whether HEAD matches last_skill_commit from the plan file.
# Stdout: "ok" or "error:concurrency_conflict"

REPO="${1:?Usage: check-idempotency.sh <repo-path> <plan-file>}"
PLAN_FILE="${2:?Usage: check-idempotency.sh <repo-path> <plan-file>}"

cd "$REPO"

LAST_SKILL_COMMIT="$(grep '^last_skill_commit:' "$PLAN_FILE" | awk '{print $2}' | tr -d '"')"

if [[ -z "$LAST_SKILL_COMMIT" || "$LAST_SKILL_COMMIT" == "null" ]]; then
  # No previous commit — first run, always ok
  echo "ok"
  exit 0
fi

HEAD="$(git rev-parse HEAD)"

if [[ "$HEAD" == "$LAST_SKILL_COMMIT" ]]; then
  echo "ok"
else
  # Check if last_skill_commit is an ancestor of HEAD
  if git merge-base --is-ancestor "$LAST_SKILL_COMMIT" HEAD 2>/dev/null; then
    echo "error:concurrency_conflict"
  else
    echo "error:last_skill_commit not in history"
  fi
fi
