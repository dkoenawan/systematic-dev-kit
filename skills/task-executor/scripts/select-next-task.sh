#!/usr/bin/env bash
set -euo pipefail

# select-next-task.sh <plan-file>
# Parses checklist, applies dependency rules, returns next eligible task.
# Stdout: JSON {index, text, retry_count} | {result:"none"} | {result:"all_blocked"} | {result:"all_complete"}

PLAN_FILE="${1:?Usage: select-next-task.sh <plan-file>}"

python3 - "$PLAN_FILE" <<'PYEOF'
import sys, re, json

plan_file = sys.argv[1]
with open(plan_file) as f:
    content = f.read()

# Parse frontmatter retry_counts
retry_counts = {}
fm_match = re.match(r'^---\n(.*?)\n---\n', content, re.DOTALL)
if fm_match:
    fm = fm_match.group(1)
    rc_match = re.search(r'retry_counts:\s*\n((?:  \d+: \d+\n?)*)', fm)
    if rc_match:
        for line in rc_match.group(1).strip().splitlines():
            m = re.match(r'\s+(\d+):\s+(\d+)', line)
            if m:
                retry_counts[int(m.group(1))] = int(m.group(2))

# Parse checklist lines
lines = content.split('\n')
tasks = []
for i, line in enumerate(lines):
    m = re.match(r'- (\[[ x!]\]) (.+)', line)
    if m:
        state = m.group(1)  # [ ], [x], [!]
        text = m.group(2)
        dep_match = re.search(r'\(depends on: ([\d, ]+)\)', text)
        deps = [int(d.strip()) for d in dep_match.group(1).split(',')] if dep_match else []
        tasks.append({'index': len(tasks) + 1, 'state': state, 'text': text, 'deps': deps})

complete_indices = {t['index'] for t in tasks if t['state'] == '[x]'}
failed_indices = {t['index'] for t in tasks if t['state'] == '[!]'}
pending = [t for t in tasks if t['state'] == '[ ]']

if not pending:
    if len(complete_indices) == len(tasks):
        print(json.dumps({'result': 'all_complete'}))
    else:
        print(json.dumps({'result': 'all_complete'}))
    sys.exit(0)

for task in pending:
    deps_met = all(d in complete_indices for d in task['deps'])
    if deps_met:
        print(json.dumps({
            'index': task['index'],
            'text': task['text'],
            'retry_count': retry_counts.get(task['index'], 0)
        }))
        sys.exit(0)

# All pending tasks have unmet deps — check if blocked by failures
def transitively_blocked(idx, visited=None):
    if visited is None:
        visited = set()
    if idx in visited:
        return True
    visited.add(idx)
    t = next((t for t in tasks if t['index'] == idx), None)
    if t is None:
        return False
    for d in t['deps']:
        if d in failed_indices:
            return True
        if transitively_blocked(d, visited):
            return True
    return False

all_blocked = all(transitively_blocked(t['index']) for t in pending)
if all_blocked:
    print(json.dumps({'result': 'all_blocked'}))
else:
    print(json.dumps({'result': 'none'}))
PYEOF
