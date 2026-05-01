---
domain: reviews
last_updated: 2026-05-01
source_path: reviews
---

# Reviews (L3)

> → [System overview](../solution-design.md) | → [Container architecture](../containers.md)

## What Is Reviews?

Reviews is a skill debugging and improvement system built as a searchable failure-pattern library. Its primary object is the **SkillReview** — a structured markdown document that records a single failed test run of a Claude skill, capturing the exact user input, where the skill deviated from its intended behavior, which canonical failure pattern caused the deviation, and the precise `SKILL.md` wording change needed to fix it. Over time, the `reviews/` directory becomes a diagnostic library that accelerates skill hardening by encoding known LLM interpretation failures and their solutions in one reusable place.

## How It Works

A SkillReview is created after a developer observes a skill behaving incorrectly during a manual test run. The developer copies `TEMPLATE.md` into `reviews/<skill-name>/YYYYMMDD_<short-description>.md` and fills in five sections: Invocation (the exact user input that triggered the failure), What Happened (observed vs. expected behavior, with phase-by-phase detail), Root Cause Analysis (which canonical failure pattern applies and why, referencing the specific `SKILL.md` line), Recommended Fix (exact before/after text change, ready to copy-paste), and a Follow-up Checklist.

The developer maps the failure to one of three canonical failure patterns documented in `reviews/README.md`: (1) **Natural Stopping Points** — a sub-skill return (rich output) creates a conversational "beat" the model misreads as completion, ignoring soft continuation directives; (2) **Declarative vs. Evaluative Instructions** — descriptive language ("create the file") is treated as documentation to acknowledge, not a requirement to enforce; (3) **Weak Transition Language** — soft cues ("proceed to", "then continue") are treated as suggestions rather than imperatives. If the failure is novel, a new pattern is documented.

The recommended fix is applied to the relevant `SKILL.md`, the test is re-run with the same input, and the Follow-up Checklist is updated with pass/fail status and observations. The completed review remains in `reviews/<skill-name>/` permanently as a diagnostic reference.

## Core Objects / Entities

| Object | Description |
| ------ | ----------- |
| `SkillReview` | A dated markdown record of one skill test run failure: invocation, observed behavior, root cause mapped to a canonical pattern, recommended SKILL.md fix, and verification status. |
| `FailurePattern` | A named category of LLM skill-definition interpretation failure, with a diagnostic signature and a reusable fix template. Three canonical patterns are currently defined. |
| `RecommendedFix` | A concrete before/after diff of the relevant `SKILL.md` section — the actionable output of each review. |
| `FollowUpChecklist` | Per-review tracking items: Fix applied? Re-tested? Pass/fail status and observations. |

## Code Map — Which Code Touches This

- **Data Shape (template)**: `reviews/TEMPLATE.md` — canonical five-section structure for all SkillReview documents (Invocation, What Happened, Root Cause Analysis, Recommended Fix, Follow-up Checklist)
- **Business Logic (patterns + workflow)**: `reviews/README.md` — defines the review system, file naming convention (`YYYYMMDD_<short-description>.md`), three canonical failure patterns with diagnostic signatures and fix strategies, and the end-to-end debugging workflow
- **Interface**: No programmatic interface — reviews are created and read manually by developers; files are plain markdown
- **Persistence**: `reviews/<skill-name>/` subdirectories containing dated review files; e.g., `reviews/plan/20260309_weekly-assessment.md` (the first concrete review, documenting the Mandatory Continuation Point failure in the `plan` skill)
- **External callers**: `skills/*/SKILL.md` files are the *subjects* of recommended fixes; reviews reference specific line numbers and excerpts from those files. `docs/plan/overview.md` references known failure modes documented in `reviews/plan/`.

## Internal Architecture

**Review-Driven Improvement Loop**: Reviews encode failures as actionable diffs — not bug reports. Each review produces a specific before/after change to `SKILL.md` using one of three canonical fix strategies:
- Natural Stopping Points → add **MANDATORY CONTINUATION POINT** label + explicit scope ("in this same response") + self-check ("if you are about to end this response without doing X, stop — you are making an error")
- Declarative vs. Evaluative → replace descriptive requirements with binary **SKILL COMPLETION GATE** checklists
- Weak Transition Language → replace soft directional phrases with imperative scope ("Ask Q3 in this same response before closing")

These fix strategies are reusable — the same language patterns appear across multiple skills and failures.

## Dependencies

- **Internal**: All skills in `skills/*/` are potential subjects of reviews; `reviews/plan/` contains the first concrete example. The `plan` skill's SKILL.md has already been hardened based on review findings (Mandatory Continuation Point after `explore` return).
- **External**: None — reviews are pure markdown documentation with no runtime dependencies

## Gotchas

- **Manual discipline required for follow-through**: The Follow-up Checklist relies on the developer to apply the recommended fix and re-test. A review can be filed and its fix left unapplied indefinitely — there is no enforcement mechanism.
- **Observational, not regression-tested**: Reviews document manual test observations. The same failure can reoccur months later if the fix was reverted or if a skill was heavily edited; search the review history proactively when debugging recurring issues.
- **Sub-skill chaining is high-risk by default**: Any skill that invokes a sub-skill (like `plan` calling `explore`) is at high risk of the Natural Stopping Points failure. Use Mandatory Continuation Point language proactively — before a failure occurs — in any new skill that chains sub-skills.
- **No automated indexing**: Reviews are found by manual file browsing or grep. The `README.md` maintains a file index table, but a large review library could become hard to navigate without search.
- **Fix validation burden falls on the reviewer**: The developer who applies a fix bears responsibility for re-testing. If re-testing is incomplete or undocumented, the Follow-up Checklist remains ambiguous.

## Changelog

- 2026-04-24: Initial documentation generated by doc-maintainer.
- 2026-05-01: Full refresh via doc-maintainer.
