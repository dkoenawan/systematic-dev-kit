#!/usr/bin/env bash
set -euo pipefail

# commit-and-push.sh <repo-path> <plan-file> <commit-message>
# Stages all tracked changes + plan file, commits, pushes.
# Updates last_skill_commit in plan file frontmatter.
# Stdout: sha or "error:<reason>"

REPO="${1:?Usage: commit-and-push.sh <repo-path> <plan-file> <commit-message>}"
PLAN_FILE="${2:?}"
COMMIT_MSG="${3:?}"

cd "$REPO"

# Stage tracked changes and plan file
git add -u
git add "$PLAN_FILE"

if git diff --cached --quiet; then
  echo "error:empty_diff"
  exit 1
fi

git commit -m "$COMMIT_MSG"
SHA="$(git rev-parse HEAD)"

# Update last_skill_commit in plan file frontmatter
python3 - "$PLAN_FILE" "$SHA" <<'PYEOF'
import sys, re
plan_file, sha = sys.argv[1], sys.argv[2]
with open(plan_file) as f:
    content = f.read()
updated = re.sub(r'(last_skill_commit:\s*).*', rf'\g<1>{sha}', content)
with open(plan_file, 'w') as f:
    f.write(updated)
PYEOF

# Amend to include the updated plan file with last_skill_commit
git add "$PLAN_FILE"
git commit --amend --no-edit
SHA="$(git rev-parse HEAD)"

git push origin "$(git rev-parse --abbrev-ref HEAD)"

echo "$SHA"
