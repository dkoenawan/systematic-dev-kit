#!/usr/bin/env bash
set -euo pipefail

# prepare-branch.sh <repo-path> <branch-name>
# Phase 0: fetch origin, checkout work branch, rebase on origin/main.
# Stdout: "ok" or "error:<reason>"

REPO="${1:?Usage: prepare-branch.sh <repo-path> <branch-name>}"
BRANCH="${2:?Usage: prepare-branch.sh <repo-path> <branch-name>}"

cd "$REPO"

# Save original branch for restore-branch.sh
git rev-parse --abbrev-ref HEAD > .git/TASK_EXECUTOR_ORIG_BRANCH

git fetch origin 2>/dev/null

# E1: branch missing
if ! git show-ref --verify --quiet "refs/remotes/origin/$BRANCH" && \
   ! git show-ref --verify --quiet "refs/heads/$BRANCH"; then
  echo "error:branch $BRANCH not found locally or on origin"
  exit 1
fi

git checkout "$BRANCH" 2>/dev/null

# E2: rebase conflict
if ! git rebase "origin/main" 2>/dev/null; then
  git rebase --abort 2>/dev/null || true
  echo "error:rebase_conflict"
  exit 1
fi

echo "ok"
