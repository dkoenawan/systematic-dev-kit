---
name: post-hook-validator
description: Post-commit FR validator — reads Functional Requirements from the construct file updated by the last task-executor commit, generates a human checklist, records pass/fail per FR, transitions construct status to verified or diverged, auto-triggers /adr on divergence, and blocks the next task-executor run until any required ADR is written.
---

# Post-Hook Validator Skill

You are a quality gate. Your job is not to evaluate code style or test coverage — it is to verify that each Functional Requirement in the construct file is actually satisfied by what was just built. You are the bridge between "task complete" and "task verified."

This skill is always invoked after a task-executor commit that updated a construct file. It runs interactively: the developer reads each FR and marks it pass or fail based on their inspection of the code.

## Invocation

```
/compass:post-hook-validator [construct-name]
```

If `construct-name` is omitted, derive it from the most recent task-executor commit:
1. Run `git log -1 --pretty=format:"%s"` to get the last commit subject.
2. Extract the feature name from `feat(<feature-name>): ...`.
3. Look for recently modified construct files: `git diff HEAD~1 --name-only | grep docs/reference/constructs/`.
4. If exactly one construct file was modified, use it. If multiple, list them and ask the developer which to validate.

If no construct file was modified in the last commit → exit with: "No construct files were updated in the last commit — nothing to validate. Run this skill manually with a construct name if needed."

---

## Phase 0 — Registry Preflight

1. Verify `docs/registry/index.md` exists. If not: "No architecture registry found — post-hook validation requires a registry. Run `/compass:init` to create one, or skip validation."

2. Read the construct file at `docs/reference/constructs/<Name>.md`.
   - If `status: verified`: "Construct `<Name>` is already verified. No action needed."
   - If `status: planned`: "Construct `<Name>` has not been built yet (status: planned). Run task-executor to implement it first."
   - If `status: diverged`: Note this — the developer is re-validating after a divergence. Proceed normally; a new pass will clear the diverged status.
   - If `status: built`: proceed.

3. Extract the `## Functional Requirements` section. Split into individual FR items (one per line or bullet). If the section is empty or contains only "(none)": "No Functional Requirements are defined for this construct — add FRs to the construct file before validating."

---

## Phase 1 — Present the Checklist

Show the developer:

```
## FR Validation — <Name>

Construct: <Name> (<type>, <layer>)
File: <file path>
Status: built → pending verification

For each FR below, review the implementation and answer: did the commit deliver this requirement?
```

Then present each FR as a numbered item with pass/fail choice. Use AskUserQuestion with multiSelect: false for each FR, or (if there are 5+ FRs) present them all at once as a multiSelect "Which FRs passed?" question to reduce round-trips.

**For ≤ 4 FRs** — ask one at a time:

Use AskUserQuestion for each FR:
- **Header**: "FR <N>"
- **Question**: "FR <N>: `<fr text>` — Did the implementation satisfy this requirement?"
- **multiSelect**: false
- **Options**:
  - **"Pass"** — description: "The commit delivers this requirement as described"
  - **"Fail"** — description: "The implementation diverges from or does not yet satisfy this requirement"
  - **"Partial"** — description: "Partially implemented — a follow-up task is needed"

**For 5+ FRs** — batch as multiSelect:

Use AskUserQuestion:
- **Header**: "FR Checklist"
- **Question**: "Select every FR that **passed** in this commit. Unselected FRs will be marked fail."
- **multiSelect**: true
- **Options**: one option per FR (label: "FR <N>", description: `<fr text>`)

After collecting all answers, show a summary:

```
Results:
  Pass:    FR 1, FR 3, FR 4
  Fail:    FR 2
  Partial: FR 5
```

Ask: "Confirm these results? (yes / adjust)"

---

## Phase 2 — Outcome Routing

### All FRs pass (and no partials)

1. Update construct file:
   - `status: verified`
   - `last_verified: <today's date>`
   - Fill in `## Proof` section:
     ```
     - method: manual-checklist
     - verified_by: <developer — infer from git config or ask>
     - checklist_result: all-pass
     - test_file: null
     ```

2. Update `docs/registry/index.md` — change the construct's row `Status` from `built` to `verified`. Increment the `verified` count in the frontmatter. Update `last_updated`.

3. Tell the developer:

   ```
   Construct <Name> is now verified.
   docs/reference/constructs/<Name>.md — status: verified
   docs/registry/index.md — updated
   ```

4. Commit the registry update:
   ```bash
   git add docs/registry/ && git commit -m "chore(<feature-name>): verify <Name> — all FRs pass"
   ```

### Any FR fails (or marked diverged)

1. Update construct file:
   - `status: diverged`
   - `last_verified: <today's date>`
   - Fill in `## Proof`:
     ```
     - method: manual-checklist
     - verified_by: <developer>
     - checklist_result: fail (FR <N>, FR <M>)
     - test_file: null
     ```
   - Append to `## Key Decisions`: `divergence detected on <date>: FR <N> — <fr text> — not satisfied`

2. Update `docs/registry/index.md` — change the construct's Status to `diverged`. Update `last_updated`.

3. Commit the divergence record:
   ```bash
   git add docs/registry/ && git commit -m "chore(<feature-name>): mark <Name> diverged — FR <N> failed"
   ```

4. **Block next task-executor run** by writing a lockfile in the feature's session directory (`docs/sessions/<date>-<feature-name>/`, found via `find-active-plan.sh` or by matching `docs/sessions/*-<feature-name>/`):
   ```bash
   echo "<Name>:<date>" >> docs/sessions/<date>-<feature-name>/.validation-blocked
   ```
   The task-executor checks for this lockfile before selecting the next task (see **Integration with Task-Executor** below).

5. **Auto-trigger /adr**:

   Tell the developer:

   > FR divergence detected on `<Name>`. Before the next automated task can run, an ADR is required to document the architectural decision behind this divergence.
   >
   > **What diverged:**
   > - FR <N>: `<fr text>`
   >
   > I'll now start the ADR conversation. Answer the questions and the lockfile will be cleared automatically when the ADR is written.

   Invoke `/compass:adr` — the ADR skill's "triggered by post-hook validator" path will:
   - Pre-fill the affected construct as `<Name>`
   - Ask the developer to state the decision that caused the divergence
   - On completion: write the ADR, cross-link the construct file, and change `status: diverged` → `verified` with a note linking to the ADR

6. After the ADR is written, clear the lockfile:
   ```bash
   rm docs/sessions/<date>-<feature-name>/.validation-blocked
   ```

### All FRs partial (no hard failures)

Treat as **pass with follow-up**:
- Set `status: built` (not yet verified — leave for the next validation run after follow-up tasks complete).
- Append a note to `## Key Decisions`: `partial validation on <date>: FR <N> is partially satisfied — follow-up task needed`.
- Do NOT block the next run.
- Tell the developer: "Marked as partially validated. The next task-executor run will proceed. Re-run `/compass:post-hook-validator <Name>` after the follow-up task completes."

---

## Integration with Task-Executor

The task-executor **checks for a validation block before selecting each task**. The check is:

```bash
SESSION_DIR="$(dirname "<plan-file>")"
[ -f "$SESSION_DIR/.validation-blocked" ] && cat "$SESSION_DIR/.validation-blocked"
```

If this file exists, the task-executor halts the run with:
```
Validation blocked: construct <Name> diverged on <date>. Run /compass:post-hook-validator and /compass:adr to clear the block before resuming.
```

This check belongs in the task-executor's Phase 2 (Task Selection), immediately before `select-next-task.sh`.

The lockfile is cleared by the post-hook validator after the ADR is written (see Phase 2, divergence path, step 6 above).

---

## Error Handling

| Situation | Action |
|-----------|--------|
| Construct file not found | "Construct file `docs/reference/constructs/<Name>.md` does not exist. Was the task-executor registry write step skipped?" |
| FRs section empty | Tell developer to add FRs to the construct file before validating |
| ADR skill unavailable | Write the divergence record, set lockfile, tell developer to run `/adr` manually |
| Developer cancels mid-checklist | Save partial results, leave status as `built`, note "validation incomplete" in construct Key Decisions |
| Multiple constructs modified | Validate each one sequentially — run full flow per construct |

---

## Skill Completion Gates

- [ ] Construct file `status` has been updated to `verified`, `diverged`, or left `built` (partial) — never left unchanged after a completed checklist
- [ ] `docs/registry/index.md` Status column updated to match
- [ ] Registry changes committed
- [ ] If diverged: lockfile written at `docs/sessions/<date>-<feature-name>/.validation-blocked`
- [ ] If diverged: `/compass:adr` was invoked and the developer was walked through it
- [ ] If ADR written: lockfile cleared, construct status updated to `verified`
