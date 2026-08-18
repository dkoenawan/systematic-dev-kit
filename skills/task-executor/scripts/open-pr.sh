#!/usr/bin/env bash
set -euo pipefail

# open-pr.sh <repo-path> <issue-number> [--draft]
# Creates a PR linking the issue. Handles E12 (PR already exists).
# Stdout: PR URL

REPO="${1:?Usage: open-pr.sh <repo-path> <issue-number> [--draft]}"
ISSUE="${2:?}"
DRAFT_FLAG=""

shift 2
while [[ $# -gt 0 ]]; do
  case "$1" in
    --draft) DRAFT_FLAG="--draft"; shift ;;
    *) shift ;;
  esac
done

cd "$REPO"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
TITLE="$(git log --format=%s -1)"

BODY="$(cat <<EOF
Automated by \`/compass:task-executor\`.

Closes #$ISSUE
EOF
)"

PR_URL="$(gh pr create \
  --title "$TITLE" \
  --body "$BODY" \
  --head "$BRANCH" \
  $DRAFT_FLAG 2>&1)" || {
  # E12: PR already exists
  EXISTING_URL="$(gh pr list --head "$BRANCH" --json url --jq '.[0].url' 2>/dev/null || true)"
  if [[ -n "$EXISTING_URL" ]]; then
    echo "$EXISTING_URL"
    exit 0
  fi
  echo "error:$PR_URL" >&2
  exit 1
}

echo "$PR_URL"
