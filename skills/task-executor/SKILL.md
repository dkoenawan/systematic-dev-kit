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

#### Step 0 — Pre-Task Registry Check (mandatory, runs before every task)

Check whether `docs/registry/index.md` exists in the repository root.

**If it does NOT exist**: Skip this step, proceed directly to Step 1.

**If it exists**:

1. Read `docs/registry/index.md` — extract the Constructs table (`Name`, `Does`, `Layer`, `Status`) and Known Gaps list.

2. **Keyword extraction**: From the task description, extract the key nouns and verbs that identify what is about to be created or modified (e.g., for "Implement UserAuthService with JWT validation" → keywords: `UserAuthService`, `auth`, `JWT`).

3. **Construct search**: Scan the `Name` and `Does` columns for keyword overlap with the extracted keywords. Consider a construct relevant if its name or Does text shares a keyword with the task description.

4. **For each relevant construct found** (status: `built` or `verified`): read its file at `docs/registry/constructs/<Name>.md`. Hard limit: 3 construct files per pre-task check.

5. **Known Gap fallback**: If no constructs matched but the task domain (derived from keywords) appears in the Known Gaps list:
   ```bash
   ls docs/registry/constructs/ 2>/dev/null | grep -i "<domain-keyword>"
   ```
   Read any matching construct files found (max 2).

6. **Registry context use**: Before starting implementation, incorporate what was found:
   - If a `built`/`verified` construct covers the task area → extend or reuse it; do not create a duplicate.
   - If a `planned` construct matches → the task is implementing that planned construct; update its status to `built` as part of the task.
   - If nothing matches → note "no registry match for this task domain" and proceed without constraint.

Log the registry check result as one line in the commit body (see Step 5).

#### Step 1 — Implement

Read the task description. Implement it — write code, make changes.

#### Step 2 — Diff Verification

Stage and verify a non-empty diff exists. If diff is empty → E9 (bump retry, stop run).

#### Step 3 — Tests

Run tests:
```bash
scripts/run-tests.sh <repo> <test-command>
```
- If `test_command` is null → skip tests, note "tests skipped — no command configured" in commit body.
- If `{"passed":false}` → E7.

#### Step 4 — Commit

On success:
```bash
scripts/mark-task.sh <plan-file> <index> complete
scripts/commit-and-push.sh <repo> <plan-file> "feat(<feature-name>): <task description>"
```

Include a registry check summary in the commit body:
- `registry: matched <Name> (<status>)` — if a construct was found and used
- `registry: no match — task domain not in registry` — if no match
- `registry: not found — skipped` — if docs/registry/index.md does not exist

#### Step 5 — Post-Task Registry Write (mandatory after every successful commit)

Check whether `docs/registry/index.md` exists.

**If it does NOT exist**: Skip this step, proceed to Step 6.

**If it exists**:

Determine what was built or modified in the task. Use the task description and the files changed in the commit to derive construct names and types.

**Case A — Task matched a `planned` construct in Step 0:**

Update the construct file at `docs/registry/constructs/<Name>.md`:

1. Change `status: planned` → `status: built`
2. Set `last_verified: null` (verification is the post-hook validator's job)
3. Fill in the `## Interface` section with the actual implemented interface (class/function signatures, API shape) from the just-committed code — read the committed file(s) to extract it.
4. Fill in `## Dependencies` — list constructs it calls and constructs that call it, derived from the committed code.
5. Note cross-domain dependencies in `## Key Decisions`: for each dependency that crosses a layer boundary (e.g., Backend → Database, Frontend → Backend), add an entry: `cross-domain dependency: <ThisConstruct> → <OtherConstruct> (doc-maintainer: reconcile)`.

Then update `docs/registry/index.md`:
- Change the row's `Status` column from `planned` to `built`.
- Increment `verified` count only if a test was run and passed; otherwise leave as-is.
- Update `last_updated` to today's date.

**Case B — Task created a new construct not previously in the registry:**

Determine: type (Service | Component | Repository | Model | Resource | Utility | Middleware | Hook), layer (Backend | Frontend | Database | Infra | Shared), PascalCase name, file path.

Write `docs/registry/constructs/<Name>.md` with `status: built`:

```markdown
---
name: <Name>
type: <type>
layer: <layer>
file: <path>
status: built
planned_in: null
last_verified: null
---

## Does

<one or two sentences describing what this construct does, derived from the task description and committed code>

## Functional Requirements

<extract FRs from the task description — make each testable and user-facing>

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: null

## Interface

```<language>
<actual interface from committed code — class/function signatures or API shape>
```

## Dependencies

- Calls: <other construct names or "none">
- Called by: <other construct names or "none">
- Reads: <data sources or "none">
- Writes: <data sources or "none">

## Patterns Applied

- (none)

## Key Decisions

- <cross-domain dependency entries if applicable>
```

Then update `docs/registry/index.md`:
- Append a row to the Constructs table: `| <Name> | <type> | <Does one-line> | <layer> | constructs/<Name>.md | built |`
- Append a row to Feature Cross-Reference if the feature isn't already there, or add the construct name to the existing row.
- Increment `construct_count` and update `last_updated`.

**Case C — Task modified an existing `built` or `verified` construct:**

Update the construct file:
- Update the `## Interface` section to reflect any signature changes.
- Add a note to `## Key Decisions`: `updated by task-executor on <date>: <one-line description of what changed>`.
- Do NOT change `status` — leave `built`/`verified` as-is.

Update `docs/registry/index.md`: update `last_updated`.

**Case D — Task touched code unrelated to any registered construct (tooling, config, tests):**

Skip the registry write. Log "registry write skipped — task is tooling/config, no construct boundary crossed" in the next commit body.

**Hard limit**: Write or update at most 3 construct files per task. If more were touched, note the remainder as "registry write deferred — exceeded 3-construct limit per task."

Commit the registry update separately:
```bash
git add docs/registry/ && git commit -m "chore(<feature-name>): update registry after task <index>"
git push origin feat/<feature-name>
```

#### Step 6 — Next Task

Repeat for next task (budget check first).

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
