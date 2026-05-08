#!/usr/bin/env bash
set -euo pipefail

# run-tests.sh <repo-path> <test-command>
# Runs the test command and captures result.
# Stdout: JSON {passed: bool, output_tail: str}

REPO="${1:?Usage: run-tests.sh <repo-path> <test-command>}"
TEST_CMD="${2:?}"

cd "$REPO"

TMPFILE="$(mktemp)"
trap 'rm -f "$TMPFILE"' EXIT

EXIT_CODE=0
eval "$TEST_CMD" > "$TMPFILE" 2>&1 || EXIT_CODE=$?

TAIL="$(tail -30 "$TMPFILE")"
PASSED=$([[ $EXIT_CODE -eq 0 ]] && echo "true" || echo "false")

python3 -c "
import json, sys
print(json.dumps({'passed': $PASSED == 'true', 'output_tail': sys.argv[1]}))
" "$TAIL"
