# Skill Review: adr — category-management post-mortem

**Date**: 2026-06-28
**Skill**: `adr`
**File**: `reviews/adr/20260628_category-management-postmortem.md`

---

## Invocation

**Skill invoked**: `/systematic-dev-kit:adr`

**Exact input**:
```
Post-mortem: divergence between category-management spec and actual implementation — pipeline
retained as subprocess, transactions never persisted to DB, TSV/DB hybrid categorisation,
transactions page stub only
```

**SKILL.md version excerpt** (the "Before Starting" section that governed the failing behavior):
```
## Before Starting

Read the registry to understand what exists:

1. Read `docs/registry/index.md` — get the construct list and feature cross-reference
2. Read `docs/registry/decisions/index.md` — get the ADR count to determine the next ADR number
3. If triggered by post-hook validator, read the flagged construct file for context
```

---

## What Happened

**Steps that completed**:
- [x] Skill loaded and instructions read
- [x] Attempted to read `docs/registry/index.md` in the target project
- [ ] Phase 1 — Decision Statement (never reached)
- [ ] Phase 2–9 (never reached)
- [ ] Any file written

**Where it stopped / broke**:

> The skill's "Before Starting" block instructed the model to read `docs/registry/index.md`
> and `docs/registry/decisions/index.md`. Neither file exists in the target project — it
> uses a flat `docs/` layout with no registry subdirectory. The model correctly identified
> this, reported it to the user, and then stopped — pivoting to write a `clarity-log.md`
> entry instead. The user interrupted and redirected to write the review manually here.

**Expected behavior**:

> The skill should have detected that no registry exists, surfaced this as a prerequisite
> gap to the user ("this project has no docs/registry/ — do you want to bootstrap it, or
> proceed with a standalone ADR in a docs/decisions/ folder?"), and offered a path forward
> rather than silently abandoning the skill workflow.

**Actual behavior**:

> Model read the docs directory, confirmed no registry existed, announced it would use the
> project's existing `clarity-log.md` instead, started reading the spec file — and was then
> interrupted by the user. The skill never entered Phase 1 or asked a single question.

---

## Root Cause Analysis

**Exact SKILL.md location that failed**: Lines 14–19, section "Before Starting"

**Current wording**:
```
## Before Starting

Read the registry to understand what exists:

1. Read `docs/registry/index.md` — get the construct list and feature cross-reference
2. Read `docs/registry/decisions/index.md` — get the ADR count to determine the next ADR number (NNN = count + 1, zero-padded to 3 digits)
3. If triggered by post-hook validator, read the flagged construct file for context
```

**Why it likely failed**:

> The "Before Starting" block assumes the registry already exists. When the files are missing,
> the model has no instruction for what to do — so it improvises (trying clarity-log.md) or
> stops. There is no fallback branch, no guard clause, and no explicit instruction to surface
> the missing registry to the user as a blocker.
>
> Secondary cause: the model pivoted to an alternative output format (clarity-log entry)
> rather than failing loudly. This is a "soft failure" — the model tried to be helpful but
> silently exited the skill workflow.

**Failure pattern** (from reviews/README.md Known Failure Patterns):
- [ ] Natural Stopping Points
- [ ] Declarative vs Evaluative Instructions
- [x] Other: **Missing prerequisite with no fallback branch** — skill assumes infrastructure
  (docs/registry/) that does not exist in the target project, with no instruction for what
  to do when it is absent

---

## Recommended Fix

**File**: `skills/adr/SKILL.md`
**Section**: "Before Starting", lines 14–19

**Current wording**:
```markdown
## Before Starting

Read the registry to understand what exists:

1. Read `docs/registry/index.md` — get the construct list and feature cross-reference
2. Read `docs/registry/decisions/index.md` — get the ADR count to determine the next ADR number (NNN = count + 1, zero-padded to 3 digits)
3. If triggered by post-hook validator, read the flagged construct file for context
```

**Proposed new wording**:
```markdown
## Before Starting

Check whether this project has a registry. Look for `docs/registry/index.md`.

**If the registry exists**:
1. Read `docs/registry/index.md` — get the construct list and feature cross-reference
2. Read `docs/registry/decisions/index.md` — get the ADR count (NNN = count + 1, zero-padded to 3 digits)
3. If triggered by post-hook validator, read the flagged construct file for context

**If the registry does NOT exist** — stop and ask the user:

> This project has no docs/registry/ yet. The ADR skill writes into that structure.
> How do you want to proceed?
> 1. Bootstrap the registry now (I'll create docs/registry/index.md, decisions/index.md, patterns.md)
> 2. Write a standalone ADR into docs/decisions/ without full registry structure
> 3. Cancel

Do not proceed past this point until the user has chosen an option. Do not silently fall
back to another format (clarity-log, notable-bugs, etc.) — surface the gap explicitly.
```

**Rationale**:

> The fix adds an explicit branch for the missing-registry case and replaces the implicit
> "improvise or stop" behavior with a hard user-facing gate. It prevents silent format
> substitution and keeps the user in control of whether to invest in bootstrapping the
> registry or take a lighter path.

---

## Follow-up Checklist

- [ ] Fix applied to SKILL.md
- [ ] Re-tested with same or equivalent input
- [ ] Re-test outcome: {Pass / Fail / Partial}
- [ ] Notes: {Any observations from the re-test}
