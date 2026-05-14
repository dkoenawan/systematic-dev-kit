#!/usr/bin/env bash
set -euo pipefail

# comment-on-issue.sh <issue-number> <message>
# Posts a comment on the given GitHub issue using gh CLI.

ISSUE="${1:?Usage: comment-on-issue.sh <issue-number> <message>}"
MESSAGE="${2:?}"

gh issue comment "$ISSUE" --body "$MESSAGE"
echo "ok: commented on issue #$ISSUE"
