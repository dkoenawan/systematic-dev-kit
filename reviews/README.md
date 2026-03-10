# Skill Review System

Reviews document test runs of skills — what worked, what broke, and what was fixed. They are the primary input when debugging `SKILL.md` files.

## File Naming Convention

```
reviews/{skill-name}/YYYYMMDD_{short-description}.md
```

Examples:
- `reviews/plan/20260309_weekly-assessment.md`
- `reviews/explore/20260312_new-feature-test.md`
- `reviews/plan/20260315_post-fix-retest.md`

## How to Create a Review

1. Copy `TEMPLATE.md` into the appropriate `reviews/{skill-name}/` subdirectory
2. Rename to `YYYYMMDD_{short-description}.md`
3. Fill in every section — do not leave placeholders
4. If the skill failed, complete the Root Cause Analysis and Recommended Fix sections before closing

## How to Use Reviews When Debugging SKILL.md

Before editing a `SKILL.md` file:

1. Read all reviews in `reviews/{skill-name}/` — look for prior failures at the same location
2. Check the **Known Failure Patterns** section below — the failure may match a named pattern
3. Read the **Recommended Fix** sections of prior reviews — the fix may already be documented
4. After applying a fix, create a new review documenting the re-test outcome

---

## File Index

| File | Skill | Date | Outcome | Notes |
|------|-------|------|---------|-------|
| [reviews/plan/20260309_weekly-assessment.md](plan/20260309_weekly-assessment.md) | plan | 2026-03-09 | Failed — stopped after explore | Skill stopped after explore returned; never asked Q3 or wrote spec |

---

## Known Failure Patterns

### 1. Natural Stopping Points (sub-agent returns feel like conversation ends)

**What it looks like**: The skill invokes a sub-skill (e.g., explore). The sub-skill returns a detailed report. The LLM presents the report to the user and stops — treating the sub-skill return as a conversation end rather than an internal workflow step.

**Why it happens**: Sub-skill invocations produce rich output. When the LLM surfaces that output to the user, it creates a natural conversational "beat" that the model reads as completion. Soft instructions like "then continue to Q3" are overridden by this stopping signal.

**Fix**: Replace soft transition language with a hard directive block — label it `MANDATORY CONTINUATION POINT`, list the exact actions required in the same response, and add an explicit check ("if you are about to end your response without doing X, stop — you are making an error").

---

### 2. Declarative vs Evaluative Instructions (descriptions vs gates)

**What it looks like**: The skill includes a Phase 5 that says "create the spec file at `specs/{feature-name}.md`". The LLM acknowledges this instruction, sometimes describes what it would do, but doesn't actually invoke the Write tool.

**Why it happens**: Descriptive instructions ("create the file") read as documentation to the LLM — something to acknowledge. Only evaluative gates ("this skill is not complete until the file exists on disk") create enforcement pressure.

**Fix**: Add a `SKILL COMPLETION GATE` checklist at the end of the skill. Each item must be a binary verifiable condition, not a description. Frame it as a blocking condition: "if any item is unchecked, you are not done."

---

### 3. Weak Transition Language

**What it looks like**: Instructions use soft transitional phrases: "then continue to", "proceed to", "move on to". The LLM treats these as suggestions, not requirements — especially when a natural stopping point (see #1) is present.

**Fix**: Replace "then continue to Q3" with "Ask Q3 in this same response". Explicit scope ("same response", "before closing") creates a harder constraint than directional language ("then", "proceed").
