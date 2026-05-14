#!/usr/bin/env bash
set -euo pipefail

# mark-task.sh <plan-file> <index> <status> [reason]
# status: complete | failed | retry
# - complete: changes - [ ] to - [x]
# - failed: changes - [ ] to - [!] with date+reason
# - retry: bumps retry_counts[index] in frontmatter

PLAN_FILE="${1:?Usage: mark-task.sh <plan-file> <index> <status> [reason]}"
INDEX="${2:?}"
STATUS="${3:?}"
REASON="${4:-}"

python3 - "$PLAN_FILE" "$INDEX" "$STATUS" "$REASON" <<'PYEOF'
import sys, re
from datetime import date

plan_file, index_str, status, reason = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
target_idx = int(index_str)

with open(plan_file) as f:
    content = f.read()

# Split frontmatter and body
fm_match = re.match(r'^(---\n.*?\n---\n)(.*)', content, re.DOTALL)
if fm_match:
    fm, body = fm_match.group(1), fm_match.group(2)
else:
    fm, body = '', content

if status == 'retry':
    # Bump retry_counts[index] in frontmatter
    def bump_retry(fm_text, idx):
        rc_block = re.search(r'(retry_counts:\s*\n)((?:  \d+: \d+\n?)*)', fm_text)
        if rc_block:
            entries = {}
            for line in rc_block.group(2).strip().splitlines():
                m = re.match(r'\s+(\d+):\s+(\d+)', line)
                if m:
                    entries[int(m.group(1))] = int(m.group(2))
            entries[idx] = entries.get(idx, 0) + 1
            new_block = 'retry_counts:\n' + ''.join(f'  {k}: {v}\n' for k, v in sorted(entries.items()))
            return fm_text[:rc_block.start()] + new_block + fm_text[rc_block.end():]
        else:
            return fm_text.replace('retry_counts:', f'retry_counts:\n  {idx}: 1\n', 1) \
                   if 'retry_counts:' in fm_text \
                   else fm_text + f'\nretry_counts:\n  {idx}: 1\n'
    fm = bump_retry(fm, target_idx)
    with open(plan_file, 'w') as f:
        f.write(fm + body)
    print(f'ok: retry_counts[{target_idx}] bumped')
    sys.exit(0)

# Process body checklist
lines = body.split('\n')
task_count = 0
new_lines = []
for line in lines:
    m = re.match(r'- (\[[ x!]\]) (.+)', line)
    if m:
        task_count += 1
        if task_count == target_idx:
            text = m.group(2)
            # Strip any existing failed annotation for re-marking
            text = re.sub(r' \(failed \d{4}-\d{2}-\d{2}: .+\)$', '', text)
            if status == 'complete':
                new_lines.append(f'- [x] {text}')
            elif status == 'failed':
                today = date.today().isoformat()
                r = reason if reason else 'unknown reason'
                new_lines.append(f'- [!] {text} (failed {today}: {r})')
            else:
                new_lines.append(line)
            continue
    new_lines.append(line)

with open(plan_file, 'w') as f:
    f.write(fm + '\n'.join(new_lines))

print(f'ok: task {target_idx} marked {status}')
PYEOF
