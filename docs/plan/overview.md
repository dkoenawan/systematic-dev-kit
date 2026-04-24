---
domain: plan
last_updated: 2026-04-24
source_path: skills/plan
---

# Plan

## What Is Plan?

Plan is a systematic feature specification generator that transforms a developer's intent into a complete, implementation-ready blueprint. The primary object it owns is the **FeatureSpec** — a markdown document containing Prisma database models, CQRS-named backend operations with TypeScript request/response types, frontend routes and component hierarchy, error handling rules, and a concrete Database → Backend → Frontend implementation order. A FeatureSpec eliminates the need to re-scan the codebase while coding and surfaces design tradeoffs before implementation begins.

## How It Works

A FeatureSpec moves through five sequential phases. The developer invokes `/systematic-dev-kit:plan` and describes what they want to build in natural language. The skill asks whether this is a new feature or an extension of existing code, and how complex it is. If the developer selects "Extends existing", the `explore` sub-skill is immediately invoked to scan related code; its report is summarised in three bullets and the planning conversation continues in the same response without pausing.

In Phase 2, the skill asks layer-by-layer design questions with adaptive depth: zero or one complexity signals yield shallow coverage (one question per layer); two or three signals yield moderate depth; four or more trigger full coverage plus tradeoff surfacing. Tradeoffs are surfaced as explicit Option A / Option B analyses — for example, "frontend-heavy + auth" surfaces a server-side validation requirement — and the developer must choose before synthesis proceeds.

Phase 3 maps all answers into the FeatureSpec structure using CQRS naming (`CreateUserCommand`, `ListUsersQuery`), Prisma model syntax, and typed API shapes. Phase 4 presents the complete spec for approval: if the developer says "this nails it", Phase 5 writes the spec to `specs/<feature-name>.md` and presents the implementation order. If adjustments are needed, Phase 3 iterates; if the approach is fundamentally wrong, Phase 1 restarts.

## Core Objects / Entities

| Object | Description |
| ------ | ----------- |
| `FeatureSpec` | Complete markdown blueprint: Prisma models, CQRS operations with TypeScript types, frontend routes/components, error handling, implementation order. |
| `ComplexityProfile` | Table of selected complexity signals (new DB tables, auth, real-time, file uploads, etc.) that determines adaptive question depth. |
| `DatabaseLayer` | Prisma models with fields, types, relations, decorators, migration notes, and data constraints for the feature. |
| `BackendLayer` | CQRS commands (writes) and queries (reads) with API endpoints, TypeScript request/response shapes, and validation rules. |
| `FrontendLayer` | Routes, components, component hierarchy, UI patterns, and state management strategy for the feature. |
| `Tradeoff` | Documented tension between conflicting design signals, presented as Option A / Option B with pros/cons; requires explicit developer resolution. |
| `ImplementationOrder` | Numbered steps sequencing: Database creation → Backend implementation → Frontend development. |

## Code Map — Which Code Touches This

- **Models / Schema**: `skills/plan/template.md` — FeatureSpec markdown structure with all sections (Summary, Complexity Profile, Database Layer, Backend Layer, Frontend Layer, Implementation Order, Open Questions); `skills/plan/examples/user-management/feature-spec.md` — complete worked example.
- **Business Logic / Services**: `skills/plan/SKILL.md` — complete five-phase workflow, adaptive depth calculation, tradeoff detection patterns, CQRS naming conventions, approval gate logic, and error handling for common edge cases.
- **API / Interface**: Invoked as `/systematic-dev-kit:plan`; `AskUserQuestion` components for multi-select (complexity signals, component exclusions) and single-select (feature type, boundary) prompts.
- **Persistence**: Writes `specs/<feature-name>.md` to the project root after Phase 4 approval.
- **External callers**: `skills/plan/SKILL.md` invokes `systematic-dev-kit:explore` when the user selects "Extends existing" in Phase 1.

## Internal Architecture

**Adaptive Depth Engine**: Question depth is locked at Phase 1 Question 3 based on the count of selected complexity signals. This single decision point controls which of three question sets (shallow / moderate / deep) are asked across all three layers. Developers cannot retroactively request deeper coverage without restarting Phase 1.

**Tradeoff Detection Patterns**: Six known tension patterns are checked after Phase 2: frontend-heavy + auth (requires server-side validation), real-time + simple fetch (WebSocket vs. polling conflict), bulk operations + no pagination, many-to-many + delete (cascade complexity), file uploads (storage strategy required), extends existing + overlapping models. Any match triggers an Option A / Option B analysis that must be resolved before synthesis.

**Phase Gates**: Approval gate (Phase 4) is mandatory before file generation. Three branching outcomes: "nails it" → Phase 5, "adjust" → iterate Phase 3, "rethink" → restart Phase 1. Skipping the gate violates the skill completion contract.

**Mandatory Continuation After Explore**: When `explore` returns (Phase 1, "Extends existing" path), the skill must immediately present a three-bullet context summary and ask the next planning question in the same response. Treating the explore return as a conversation end is a known failure mode (documented in `reviews/plan/`).

## Dependencies

- **Internal**: `systematic-dev-kit:explore` — invoked when the feature extends existing code; provides targeted codebase context before planning begins.
- **External**: Prisma (generated model syntax); Express.js / REST conventions (API endpoint notation); React + TypeScript (component and hook patterns); no runtime packages — plan produces specification artifacts only.

## Gotchas

- Adaptive depth is fixed at Question 3. If a developer realises mid-planning that they need deeper coverage, they must restart Phase 1 — there is no way to upgrade depth in-flight.
- Real-time features selected alongside simple-fetch state management will always trigger a tradeoff. The resolution is required; skipping it produces a spec with an unresolved conflict.
- Soft delete vs. hard delete is unspecified by default. If data sensitivity or cascading relationships make the choice non-trivial, the spec must capture this explicitly; the skill does not assume a deletion strategy.
- The file-upload tradeoff (local filesystem vs. S3-compatible vs. database blob) is non-trivial and blocks implementation. The skill surfaces it but the developer must provide a concrete decision.
- Test file generation is out of scope — the skill produces implementation specs only.

## Changelog

- 2026-04-24: Initial documentation generated by doc-maintainer.
