# Skill Review: {skill-name} — {short-description}

**Date**: YYYY-MM-DD
**Skill**: `{skill-name}`
**File**: `reviews/{skill-name}/YYYYMMDD_{short-description}.md`

---

## Invocation

**Skill invoked**: `/systematic-dev-kit:{skill-name}`

**Exact input**:
```
{paste the exact user input here}
```

**SKILL.md version excerpt** (paste the relevant section active at test time):
```
{lines N–M of SKILL.md that governed the failing behavior}
```

---

## What Happened

**Steps that completed**:
- [ ] {Step 1}
- [ ] {Step 2}

**Where it stopped / broke**:

> {Describe exactly where the skill deviated — which phase, which question, which action was expected vs what occurred}

**Expected behavior**:

> {What should have happened}

**Actual behavior**:

> {What actually happened — be specific about what the LLM said or did}

---

## Root Cause Analysis

**Exact SKILL.md location that failed**: Line {N}, section "{section name}"

**Current wording**:
```
{paste the exact text from SKILL.md}
```

**Why it likely failed**:

> {Explain the failure mechanism — e.g., "soft transition language overridden by natural stopping point", "declarative instruction treated as documentation"}

**Failure pattern** (from reviews/README.md Known Failure Patterns):
- [ ] Natural Stopping Points
- [ ] Declarative vs Evaluative Instructions
- [ ] Weak Transition Language
- [ ] Other: {describe}

---

## Recommended Fix

**File**: `{file path}`
**Section**: `{section name, line range}`

**Current wording**:
```
{exact current text}
```

**Proposed new wording**:
```
{exact replacement text}
```

**Rationale**:

> {Why this fix addresses the root cause}

---

## Follow-up Checklist

- [ ] Fix applied to SKILL.md
- [ ] Re-tested with same or equivalent input
- [ ] Re-test outcome: {Pass / Fail / Partial}
- [ ] Notes: {Any observations from the re-test}
