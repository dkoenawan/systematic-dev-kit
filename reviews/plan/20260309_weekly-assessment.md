# Skill Review: plan — Weekly Assessment Feature Test

**Date**: 2026-03-09
**Skill**: `plan`
**File**: `reviews/plan/20260309_weekly-assessment.md`

---

## Invocation

**Skill invoked**: `/systematic-dev-kit:plan`

**Exact input**:
```
I need to make a new page called weekly assessment. Currently, this is managed within the pipeline
and interacted with the CLI. However, I want to move this experience to the frontend MithrilLedger
that we have created. I want a page where I can upload a csv file with the given format, it
transpose it to the correct table format, and then from there, instead of updating the Category
and SubCategory one by one I can just see all of them in the rows. I can dropdown update the
category and subcategory, and then confirm.
```

**SKILL.md version excerpt** (lines 59–64, active at test time):
```
Once explore returns its investigation report, present a brief summary to the user:
- Relevant existing data models
- Relevant existing usecases/commands
- Relevant existing pages/routes

Then continue to Q3.
```

---

## What Happened

**Steps that completed**:
- [x] Q1 — Feature description acknowledged from user input
- [x] Q2 — AskUserQuestion presented and answered ("Extends existing")
- [x] explore sub-skill invoked and returned a detailed investigation report
- [x] Explore report presented to user (tech stack, data models, frontend structure, backend flow)

**Where it stopped / broke**:

> After presenting the explore investigation report, the skill stopped. It did not ask Q3, did not proceed to Phase 2 (layer-by-layer design), did not synthesize a spec, and did not create a `specs/` file.

**Expected behavior**:

> After presenting the explore summary, the skill should have asked Q3 (Complexity Signals, AskUserQuestion multiSelect) in the same response — then continued through all subsequent phases to produce and write a spec file at `specs/weekly-assessment.md`.

**Actual behavior**:

> The skill presented the explore report as the final output of the response. The response closed with the report content, treating the sub-skill return as a natural conversation end.

---

## Root Cause Analysis

**Exact SKILL.md location that failed**: Lines 59–64, section "Q2 — New or Extending"

**Current wording**:
```
Once explore returns its investigation report, present a brief summary to the user:
- Relevant existing data models
- Relevant existing usecases/commands
- Relevant existing pages/routes

Then continue to Q3.
```

**Why it likely failed**:

> Two compounding causes:
>
> 1. **Natural stopping point**: The explore sub-skill returned a rich, detailed report. Presenting that report to the user created a natural conversational "beat" — the LLM read it as a completion moment and stopped. The phrase "then continue to Q3" is a soft directional cue that was overridden by this stopping signal.
>
> 2. **Weak transition language**: "Then continue to Q3" reads as a suggestion, not a hard requirement. It does not specify that Q3 must appear in the same response, and it does not create a blocking condition if violated.

**Failure pattern** (from reviews/README.md Known Failure Patterns):
- [x] Natural Stopping Points
- [ ] Declarative vs Evaluative Instructions
- [x] Weak Transition Language
- [ ] Other

---

## Recommended Fix

**File**: `skills/plan/SKILL.md`
**Section**: Lines 59–64 (paragraph after "Then invoke the explore skill")

**Current wording**:
```
Once explore returns its investigation report, present a brief summary to the user:
- Relevant existing data models
- Relevant existing usecases/commands
- Relevant existing pages/routes

Then continue to Q3.
```

**Proposed new wording**:
```
Once explore returns its investigation report, you are at a **MANDATORY CONTINUATION POINT**.
Do not stop. Do not wait for the user to prompt you again. The return of the explore skill is
NOT a conversation end — it is an internal workflow step.

In the **same response**, do both of the following:

**Action 1 — Present context summary** (3 bullet points max):
- Relevant existing data models found
- Relevant existing usecases/commands found
- Relevant existing pages/routes found

**Action 2 — Ask Q3 immediately** (in the same response, directly after the summary):

> Now let's size the complexity so I know how deep to go.

Then proceed to the Q3 AskUserQuestion below.

> **CRITICAL**: If you are about to end your response after presenting the explore summary
> without asking Q3, stop — you are making an error. Ask Q3 in this same response before closing.
```

**Rationale**:

> "MANDATORY CONTINUATION POINT" labels the moment as a non-terminal state. Specifying "same response" twice removes ambiguity about when Q3 must appear. The self-check ("if you are about to end your response... stop — you are making an error") catches the exact failure mode before it occurs.

---

## Follow-up Checklist

- [x] Fix applied to SKILL.md (2026-03-10)
- [ ] Re-tested with same or equivalent input
- [ ] Re-test outcome: {Pass / Fail / Partial}
- [ ] Notes: {Any observations from the re-test}
