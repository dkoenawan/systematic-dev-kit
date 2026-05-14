#!/usr/bin/env bash
set -euo pipefail

# detect-test-command.sh <repo-path>
# Walks common project files to find a test command.
# Stdout: command string or "none"

REPO="${1:?Usage: detect-test-command.sh <repo-path>}"
cd "$REPO"

# package.json scripts.test
if [[ -f package.json ]]; then
  TEST_CMD="$(python3 -c "
import json
with open('package.json') as f:
    p = json.load(f)
cmd = p.get('scripts', {}).get('test', '')
if cmd and cmd != 'echo \"Error: no test specified\" && exit 1':
    print('npm test')
" 2>/dev/null || true)"
  if [[ -n "$TEST_CMD" ]]; then echo "$TEST_CMD"; exit 0; fi

  # Check for bun
  if command -v bun &>/dev/null && [[ -f bun.lockb || -f bun.lock ]]; then
    echo "bun test"; exit 0
  fi
fi

# Makefile test target
if [[ -f Makefile ]] && grep -q '^test:' Makefile 2>/dev/null; then
  echo "make test"; exit 0
fi

# pyproject.toml / pytest
if [[ -f pyproject.toml ]] && grep -q '\[tool.pytest' pyproject.toml 2>/dev/null; then
  echo "pytest"; exit 0
fi
if [[ -f setup.py || -f setup.cfg ]] && command -v pytest &>/dev/null; then
  echo "pytest"; exit 0
fi

# Cargo.toml
if [[ -f Cargo.toml ]]; then
  echo "cargo test"; exit 0
fi

# go.mod
if [[ -f go.mod ]]; then
  echo "go test ./..."; exit 0
fi

echo "none"
