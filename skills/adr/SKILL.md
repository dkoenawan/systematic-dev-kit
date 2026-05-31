---
name: adr
description: Capture a significant architecture decision as a MADR-format ADR. Runs a 6-phase conversation to elicit decision context, options, NFRs, and revisit conditions — then writes docs/registry/decisions/<NNN>-<title>.md, updates decisions/index.md, cross-links affected construct files, and appends to patterns.md if a cross-cutting convention is established.
---

# ADR Skill

You capture architecture decisions as precise, durable records. Your output is not documentation — it is institutional memory. You ask precise questions to surface the constraints that made a decision necessary and the conditions under which it should be revisited.

This skill has two triggers:
1. **Manual** — developer runs `/adr` at a decision point
2. **Automatic** — post-hook validator detected an implementation divergence and called this skill

## Before Starting

Read the registry to understand what exists:

1. Read `docs/registry/index.md` — get the construct list and feature cross-reference
2. Read `docs/registry/decisions/index.md` — get the ADR count to determine the next ADR number (NNN = count + 1, zero-padded to 3 digits)
3. If triggered by post-hook validator, read the flagged construct file for context

## Phase 1 — Decision Statement

Ask the user:

> What did you decide? Give me one sentence — start with "We will..." or "We have chosen..."

Listen for: what was decided (not the context yet). If the statement is vague ("we changed how auth works"), ask them to make it specific ("we will use JWT tokens instead of session cookies for authentication").

Once you have a clear one-sentence decision, confirm it back to them before moving to Phase 2.

## Phase 2 — Alternatives Considered

Ask the user:

> What other options did you consider? List them — even partial alternatives or the "do nothing" option.

For each alternative mentioned, note:
- What it is
- Why it was not chosen

If the user lists only one alternative, prompt: "What would the simplest possible alternative have been, even if it was obviously wrong for this case?"

## Phase 3 — Constraints at Decision Time

Ask the user:

> What constraints were active when you made this decision? Think about:
> - Team size and experience
> - Current scale (users, data volume, requests/day)
> - Deadlines
> - Cost limits
> - Compliance requirements
> - Existing systems you couldn't change

These constraints are what made the decision non-obvious. Without them, the ADR loses its explanatory power. Push back if the user gives vague constraints ("it was complex") — ask for specifics ("how many engineers, what was the deadline, what was the volume?").

## Phase 4 — Pattern Detection

Ask the user:

> Does this decision establish a convention that should apply everywhere in this codebase — not just to this one case?

Examples of cross-cutting patterns: "all entities use soft-delete", "all API responses follow { data, error, meta }", "all auth uses JWT".

If **yes**: note that you will also write to `patterns.md`. Ask: "Name the pattern in 3–5 words." (e.g. "Soft Delete", "API Response Envelope", "JWT Auth").

If **no**: proceed to Phase 5. The decision affects specific constructs but does not establish a universal rule.

## Phase 5 — NFR Capture

Ask the user:

> Does this decision enforce any measurable quality targets — performance, security, reliability, cost?

Examples:
- "Auth response time < 100ms p95"
- "No plaintext credentials stored at any point"
- "Service uptime ≥ 99.5%"
- "Monthly cloud cost < $500"

If the user says "no" or "not really", prompt once more: "Does the chosen option perform differently from the alternatives in a way that matters? That difference is an NFR."

## Phase 6 — Revisit Conditions

Ask the user:

> What should trigger a revisit of this decision? Describe a specific, observable condition — not "when things get complicated."

Examples:
- "If order volume exceeds 5,000/day"
- "If we add a compliance requirement for session revocation"
- "If team grows past 5 engineers"

Generic answers ("if requirements change", "when we scale") are not useful. Push for specificity.

## Phase 7 — Affected Constructs

Ask the user:

> Which constructs does this decision affect? Search the registry:

Show the user the construct list from `docs/registry/index.md`. Ask them to identify which constructs are directly affected (will need a "Key Decisions" link back to this ADR).

If triggered by post-hook validator, the affected construct is already known — confirm it and ask if any others are affected.

## Phase 8 — Confirm Options Table

Before writing, show the user a preview of the options table:

```
## Options Considered

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **[ChosenOption] (chosen)** | [pros] | [cons] | — chosen |
| [AltOption1] | [pros] | [cons] | [reason] |
| [AltOption2] | [pros] | [cons] | [reason] |
```

Ask: "Does this table accurately capture the tradeoffs? Adjust anything before I write the ADR."

Wait for approval or corrections. Do not write files until the user confirms.

## Phase 9 — Write Files

After confirmation, write all files in this order:

### 1. Write the ADR file

Determine the next ADR number: count rows in `docs/registry/decisions/index.md` + 1. Zero-pad to 3 digits.

Derive a kebab-case title from the decision statement (e.g. "We will use JWT tokens" → `jwt-over-session-cookies`).

Write `docs/registry/decisions/<NNN>-<title>.md` using the template:

```markdown
---
id: "<NNN>"
date: <today's date YYYY-MM-DD>
status: Accepted
deciders: [<user's name>]
affects: [<construct names>]
---

## Context

<constraints paragraph — team size, scale, deadline, compliance, existing systems>

## Decision

<one-sentence decision statement>

## Options Considered

<options table from Phase 8>

## NFR Captured

<bullet list from Phase 5, or "(none)" if none>

## Consequences

**Now easier**: <what becomes simpler>
**Now harder**: <what becomes more complex>
**New constraints**: <what must be true going forward>

## Revisit Conditions

<specific, measurable revisit condition from Phase 6>
```

### 2. Append to decisions/index.md

Add a row to the table in `docs/registry/decisions/index.md`:

```
| [NNN](NNN-title.md) | YYYY-MM-DD | Accepted | <decision one-liner> | <construct names> |
```

Update the `last_updated` and `adr_count` in the frontmatter.

### 3. Cross-link affected construct files

For each construct in the affects list:

Read `docs/registry/constructs/<Name>.md`. Append to its `## Key Decisions` section:

```
- [ADR-<NNN>](../decisions/<NNN>-<title>.md) — <decision one-liner>
```

If the construct file does not yet exist, note it in `docs/registry/index.md` Known Gaps — do not create it here.

### 4. If pattern detected — append to patterns.md

Read `docs/registry/patterns.md`. Append:

```markdown
## <Pattern Name>

<one-sentence description of the convention>
- Implements: <construct names>
- ADR: [ADR-<NNN>](decisions/<NNN>-<title>.md)
```

## Completion

Tell the user:

```
ADR-<NNN> written: docs/registry/decisions/<NNN>-<title>.md
decisions/index.md updated (N ADRs total)
Construct files updated: <list>
[Pattern "<name>" added to patterns.md]  ← only if applicable
```

If triggered by post-hook validator after a divergence: also update the affected construct's `status` to `diverged` and add a note linking to this ADR.
