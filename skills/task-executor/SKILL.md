---
name: task-executor
description: Runs large GitHub issues autonomously via cron over multiple days. Interactive planning conversation decomposes an issue into hour-sized tasks, then executes up to 3 per scheduled run — rebasing, implementing, testing, committing, and opening a PR on completion.
---

# Task Executor Skill

## Mode Dispatch (Phase 0)

Parse the invocation arguments and route:

| Invocation | Mode |
|---|---|
| `/systematic-dev-kit:task-executor` | Auto: if active plan exists → `status`; else → `plan` (ask for issue number) |
| `/systematic-dev-kit:task-executor plan <issue-number>` | Planning conversation |
| `/systematic-dev-kit:task-executor execute` | Daily run sequence (cron only) |
| `/systematic-dev-kit:task-executor status` | Show active plan summary |
| `/systematic-dev-kit:task-executor stop` | Uninstall cron, pause plan |
| `/systematic-dev-kit:task-executor resume` | Re-install cron for paused plan |

Scripts live in `skills/task-executor/scripts/` relative to the plugin root. Always resolve the absolute path before invoking.

---

## Plan Mode

Run these 9 phases in order. Be conversational — show what you found, confirm before proceeding.

### Phase 1 — Preflight

```bash
gh auth status
```

Verify: repo is a git repo (`git rev-parse --git-dir`), issue number is provided. Run `find-active-plan.sh <repo>` — if another plan is `in-progress`, halt with: "Another plan is already in progress at `<path>`. Run `/systematic-dev-kit:task-executor status` to see it, or `stop` to pause it first."

Check crontab for clashing `execute-daily.sh` entries at the same time:
```bash
crontab -l 2>/dev/null | grep execute-daily.sh
```

### Phase 2 — Issue Ingest

```bash
gh issue view <N> --json title,body,labels
```

Show the user the issue title, body excerpt, and labels. If the body contains a `- [ ]` checklist, note it as draft input for decomposition.

### Phase 3 — Feature Name

Derive a kebab-case feature name from the issue title (e.g., "Add user roles" → `user-roles`). Confirm with user. Check branch availability:

```bash
git show-ref --verify refs/heads/feat/<name>
git ls-remote origin refs/heads/feat/<name>
```

If branch exists, ask whether to reuse it or choose a different name.

### Phase 4 — Design Spec Resolution

Check whether `specs/<feature-name>/overview.md` exists. If not, invoke `/systematic-dev-kit:plan` to produce it. The plan skill writes to `specs/<feature-name>/overview.md`.

If it exists, read it and summarise the Implementation Order section to the user.

### Phase 5 — Hour-Sized Decomposition

Read `specs/<feature-name>/overview.md` Implementation Order. Decompose each item into hour-sized tasks (≈ one focused commit, ~30–90 min agent work). Apply dependency annotations using 1-based task indices.

Present as a numbered checklist with dependencies annotated. Example:

```
1. Add `User.role` field to Prisma schema
2. Generate and apply migration (depends on: 1)
3. Implement `AssignRoleCommand` with validation (depends on: 2)
4. Wire up `/admin/users` route (depends on: 3)
5. Add role badge to user list (depends on: 4)
6. Write integration test for role assignment (depends on: 3)
```

Ask: "Does this decomposition look right? Adjust any tasks before we continue."

### Phase 6 — Test Command Detection

```bash
scripts/detect-test-command.sh <repo>
```

Show the result. If "none", ask: "No test command found. Enter one manually, or type 'skip' to proceed without tests (not recommended)."

### Phase 7 — Schedule Confirmation

Default schedule: every 6h (`0 */6 * * *`). Explain the 6h cadence aligns with the ~5h Claude quota window to avoid mid-run quota exhaustion.

Ask: "Run every 6 hours (default), or specify a different interval? (e.g. `--every 12h`, `--time 02:00`)"

Warn if crontab clash detected in Phase 1.

### Phase 8 — Approval Gate

Show summary:
```
Branch:       feat/<feature-name>
Plan file:    specs/<feature-name>/tasks.md
Tasks:        <N> tasks, <M> with dependencies
Test command: <cmd>
Schedule:     every 6h (cron: 0 */6 * * *)
First run:    next scheduled firing
```

Ask: "Ready to go? (yes / adjust / rethink)"

On `adjust`: re-enter the relevant phase. On `rethink`: start over from Phase 2.

### Phase 9 — Commit

1. Write `specs/<feature-name>/tasks.md` (see **Plan File Format** below)
2. Create branch: `git checkout -b feat/<feature-name>`
3. Commit: `git add specs/<feature-name>/tasks.md && git commit -m "feat(<feature-name>): initialise task-executor plan"`
4. Push: `git push -u origin feat/<feature-name>`
5. Install cron: `scripts/install-schedule.sh <repo> [--every Nh]`
6. Comment on issue:

```bash
scripts/comment-on-issue.sh <N> "🤖 Task automation started — runs every 6h via \`/systematic-dev-kit:task-executor\`. Plan: \`specs/<feature-name>/tasks.md\`."
```

---

## Execute Mode

**This mode is for cron invocation only.** Do not prompt the user. Proceed deterministically through all phases.

### Phase 0 — Git Safety

```bash
scripts/prepare-branch.sh <repo> feat/<feature-name>
```

On `error:branch_missing` → E1. On `error:rebase_conflict` → E2. On `ok` → continue.

Register cleanup trap to always run `scripts/restore-branch.sh <repo>` on exit.

### Phase 1 — Plan Resolution

```bash
scripts/find-active-plan.sh <repo>
```

- `none` → E3 (no active plan — uninstall cron, exit clean)
- `multiple:<paths>` → E4 (halt, comment all linked issues)
- `<path>` → read the plan file

```bash
scripts/check-idempotency.sh <repo> <plan-file>
```

On `error:concurrency_conflict` → E14.

### Phase 2 — Task Selection

Read `status` from plan frontmatter. If `complete` → exit clean (cron already uninstalled; this is a no-op).

```bash
scripts/select-next-task.sh <plan-file>
```

- `{"result":"all_complete"}` → completion path (Phase 4)
- `{"result":"all_blocked"}` → E5 (draft PR + uninstall)
- `{"result":"none"}` → log "no eligible tasks this run", exit clean
- `{"index":N, "text":"...", "retry_count":R}` → execute task

Budget loop: repeat task selection + execution up to `max_tasks_per_run` times, or until wall-clock exceeds `max_wall_clock_minutes`, or `stop_on_first_failure` triggers.

### Phase 3 — Execute Per Task

For each selected task:

1. Read the task description. Implement it — write code, make changes.
2. Stage and verify a non-empty diff exists.
3. If diff is empty → E9 (bump retry, stop run).
4. Run tests:
   ```bash
   scripts/run-tests.sh <repo> <test-command>
   ```
   - If `test_command` is null → skip tests, note "tests skipped — no command configured" in commit body.
   - If `{"passed":false}` → E7.
5. On success:
   ```bash
   scripts/mark-task.sh <plan-file> <index> complete
   scripts/commit-and-push.sh <repo> <plan-file> "feat(<feature-name>): <task description>"
   ```
6. Repeat for next task (budget check first).

**Failure handling (E6/E7/E9):**
```bash
scripts/mark-task.sh <plan-file> <index> retry
```
Read `retry_count` from select-next-task output. If it was already ≥ 1 (second consecutive fail):
```bash
scripts/mark-task.sh <plan-file> <index> failed "<reason: test fail / empty diff / stuck>"
scripts/comment-on-issue.sh <N> "⚠️ Task <index> failed twice and has been skipped: <reason>\n\`\`\`\n<test output tail>\n\`\`\`"
```
Stop the run (`stop_on_first_failure` applies).

### Phase 4 — Push & Check Completion

After the budget loop:

```bash
git push origin feat/<feature-name>
```

On push rejected → E10.

Re-run `scripts/select-next-task.sh <plan-file>`. If `all_complete`:

```bash
# Update plan status
python3 -c "
import re
with open('<plan-file>') as f: c = f.read()
c = re.sub('status: in-progress', 'status: complete', c)
with open('<plan-file>', 'w') as f: f.write(c)
"
git add <plan-file> && git commit -m "chore(<feature-name>): mark plan complete"
git push origin feat/<feature-name>

PR_URL="$(scripts/open-pr.sh <repo> <issue-number>)"
scripts/comment-on-issue.sh <issue-number> "✅ All tasks complete. PR: $PR_URL"
scripts/uninstall-schedule.sh <repo>
```

### Phase 5 — Restore

Always runs (trap):
```bash
scripts/restore-branch.sh <repo>
```

---

## Status Mode

```bash
PLAN="$(scripts/find-active-plan.sh <repo>)"
```

If `none`: "No active plan. Run `/systematic-dev-kit:task-executor plan <issue-number>` to start one."

Otherwise read the plan file and display:

```
Active plan:  specs/<feature-name>/tasks.md
Issue:        #<N>
Branch:       feat/<feature-name>
Status:       in-progress
Progress:     <X> complete, <Y> pending, <Z> failed
Next task:    [<index>] <description>
Last commit:  <sha> (<date>)
Schedule:     0 */6 * * * (next: ~<approx time>)
```

Show retry counts if any > 0.

---

## Stop Mode

```bash
PLAN="$(scripts/find-active-plan.sh <repo>)"
```

1. Update plan `status: paused`
2. `scripts/uninstall-schedule.sh <repo>`
3. `scripts/comment-on-issue.sh <N> "⏸️ Task automation paused. Branch and plan preserved. Resume with \`/systematic-dev-kit:task-executor resume\`."`

Tell user: "Automation paused. Your branch `feat/<name>` and plan file are untouched."

---

## Resume Mode

```bash
PLAN="$(scripts/find-active-plan.sh <repo>)"  # also matches status: paused
```

1. Confirm plan exists and `status: paused`
2. Update `status: in-progress`
3. Ask for schedule (default: reuse stored `schedule` from frontmatter)
4. `scripts/install-schedule.sh <repo> [--every Nh]`
5. `scripts/comment-on-issue.sh <N> "▶️ Task automation resumed."`

---

## Plan File Format

`specs/<feature-name>/tasks.md`:

```yaml
---
issue: <N>
branch: feat/<feature-name>
status: in-progress
test_command: <cmd or null>
last_skill_commit: null
retry_counts:
schedule: "0 */6 * * *"
budget:
  max_tasks_per_run: 3
  max_wall_clock_minutes: 90
  stop_on_first_failure: true
---

- [ ] <task 1 description>
- [ ] <task 2 description> (depends on: 1)
- [ ] <task 3 description> (depends on: 1)
- [ ] <task 4 description> (depends on: 2, 3)
```

State markers: `- [ ]` pending, `- [x]` complete, `- [!] <desc> (failed YYYY-MM-DD: <reason>)` failed.

---

## Error Handling Reference

| Code | Trigger | Response |
|---|---|---|
| E1 | Work branch missing | Halt + comment on issue. Don't uninstall cron. |
| E2 | Rebase conflict | Retry next run; second consecutive → halt + comment "manual rebase needed" |
| E3 | No active plan | Uninstall cron, exit clean |
| E4 | Multiple in-progress plans | Halt + comment all linked issues, don't uninstall |
| E5 | All remaining tasks blocked by `- [!]` | Open **draft PR**, uninstall cron, comment on issue |
| E6 | Task execution stuck (no diff, LLM can't proceed) | Same as E9 |
| E7 | Tests fail | Bump retry; second consecutive fail → `- [!]`; don't commit; comment with test tail |
| E8 | Test command null | Skip tests; note in commit body |
| E9 | Empty diff after execution | Bump retry; second consecutive → `- [!]`; stop run |
| E10 | Push rejected | Halt + comment "remote diverged — manual push needed" |
| E11 | `gh` unauthenticated | Caught at install preflight. Mid-run: log silently, halt |
| E12 | `gh pr create` fails (PR exists) | Fetch existing PR URL, comment, uninstall anyway |
| E13 | Cron fires while run active | Lockfile exits silently |
| E14 | Branch ahead of `last_skill_commit` | Retry next run; second consecutive → halt + comment |

---

## Skill Completion Gates

**Plan mode exits successfully when:** `tasks.md` is committed, branch pushed, cron installed, issue commented.

**Execute mode exits successfully when:** budget loop ran to completion (or was empty), branch pushed, restore-branch completed. Partial progress (some tasks done, some failed) is still a successful exit.

**Execute mode exits as failure when:** E1, E4, E10 — these halt and require human intervention.
