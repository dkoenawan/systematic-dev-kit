---
domain: plan
last_updated: 2026-05-01
source_path: skills/plan
---

# Plan (L3)

> → [System overview](../solution-design.md) | → [Container architecture](../containers.md)

## What Is Plan?

Plan is a systematic feature specification generator that transforms a developer's intent into a complete, implementation-ready blueprint. The primary object it owns is the **FeatureSpec** — a markdown document containing Prisma database models, CQRS-named backend operations with TypeScript request/response types, frontend routes and component hierarchy, error handling rules, and a concrete Database → Backend → Frontend implementation order. A FeatureSpec eliminates the need to re-scan the codebase while coding and surfaces design tradeoffs before implementation begins, not during it.

## How It Works

A FeatureSpec moves through five mandatory sequential phases. The developer invokes `/systematic-dev-kit:plan` and describes what they want to build in natural language. The skill asks whether this is a new feature or extends existing code, and prompts selection of complexity signals (new DB tables, auth, real-time, file uploads, external integrations, complex state, high overall complexity). The count of selected signals locks the **adaptive depth** for all subsequent questions: 0–1 signals = shallow (1 question per layer), 2–3 = moderate, 4+ = deep plus tradeoff surfacing.

If the developer selects "Extends existing", the `explore` subskill is immediately invoked to scan related code. Its report is summarized in three bullets, and Phase 2 planning questions begin in the same response — the skill must not pause between the explore return and Q3 (a known failure mode documented in `reviews/plan/`).

In Phase 2, the skill asks layer-by-layer design questions: Database (entities, relationships, constraints), Backend (operations, API boundary, error scenarios), and Frontend (pages, UI patterns, state management). Six known tension patterns are checked — frontend-heavy + auth, real-time + simple fetch, bulk operations without pagination, many-to-many with delete, file uploads, and extending existing models. Any match triggers an explicit Option A / Option B tradeoff analysis that must be resolved before synthesis proceeds.

Phase 3 maps all answers into the FeatureSpec structure using CQRS naming (`CreateUserCommand`, `ListUsersQuery`), Prisma model syntax, and typed API shapes. Phase 4 presents the complete spec for approval: "This nails it" → Phase 5 (write to disk); "Adjust" → iterate Phase 3; "Rethink" → restart Phase 1. No file is written without explicit approval.

Phase 5 writes `specs/<feature-name>.md` to the project root (kebab-case filename) and presents a concrete implementation order with numbered steps.

## Core Objects / Entities

| Object | Description |
| ------ | ----------- |
| `FeatureSpec` | Complete markdown blueprint: Prisma models, CQRS operations with TypeScript types, frontend routes/components, error handling, implementation order. Written to `specs/<feature-name>.md`. |
| `ComplexityProfile` | Table of selected complexity signals that determines adaptive question depth (shallow/moderate/deep). Fixed at Phase 1 Q3. |
| `DatabaseLayer` | Prisma models with fields, types, relations, decorators, migration notes, and data constraints for the feature. |
| `BackendLayer` | CQRS commands (writes) and queries (reads) with API endpoints, TypeScript request/response shapes, and validation rules. |
| `FrontendLayer` | Routes, components, component hierarchy, UI patterns, and state management strategy. |
| `Tradeoff` | Documented design tension (e.g., "real-time + simple fetch"), presented as Option A / Option B with pros/cons. Must be resolved before Phase 3 synthesis. |
| `ImplementationOrder` | Numbered steps: Database (models + migrations) → Backend (commands/queries + endpoints) → Frontend (pages + components). |

## Code Map — Which Code Touches This

- **Business Logic**: `skills/plan/SKILL.md` — complete five-phase workflow, adaptive depth calculation, six tradeoff detection patterns, CQRS naming conventions, approval gate logic, and the Mandatory Continuation Point after explore invocation
- **FeatureSpec Template**: `skills/plan/template.md` — FeatureSpec markdown structure with all required sections (Summary, Complexity Profile, Database Layer, Backend Layer, Frontend Layer, Implementation Order, Open Questions)
- **Reference example**: `skills/plan/examples/user-management/feature-spec.md` — complete worked example showing a User Management spec (User, Role, UserRole, UserProfile models; admin/self-only auth; CRUD + search; cache-and-revalidate strategy)
- **Interface**: Invoked as `/systematic-dev-kit:plan`; `AskUserQuestion` components for multi-select (complexity signals) and single-select (feature type, boundary) prompts
- **Persistence**: Writes `specs/<feature-name>.md` to the project root after Phase 4 approval
- **External callers**: `skills/plan/SKILL.md` invokes `systematic-dev-kit:explore` when user selects "Extends existing" in Phase 1

## Internal Architecture

**Adaptive Depth Engine**: Question depth is determined once at Phase 1 Q3 by counting complexity signals (0–1 = shallow, 2–3 = moderate, 4+ = deep). This single decision point controls which question set is used across all three layers. Depth cannot be upgraded mid-session; a restart is required.

**Tradeoff Detection (Six Patterns)**: After Phase 2, six known tension patterns are checked: frontend-heavy + auth (server-side validation required), real-time + simple fetch (WebSocket vs. polling conflict), bulk operations without pagination (unbounded data risk), many-to-many with delete (cascade vs. orphan decision), file uploads (storage strategy: local vs. S3 vs. blob), extends existing with overlapping models (extend vs. new entity decision). Any pattern match triggers a mandatory Option A / Option B resolution before synthesis.

**Phase Gates (Approval + Adaptive Depth)**: Two gate types enforce structure. The approval gate at Phase 4 is a hard stop with three outcomes: write, iterate, or restart. The adaptive depth gate at Phase 1 is a one-time decision that locks the question set for the entire planning session. Both gates are non-negotiable.

**Mandatory Continuation After Explore**: When `explore` returns during the "Extends existing" path, the skill must immediately summarize the report in three bullets and ask the next planning question in the same response. Treating the explore return as a conversation end is a known failure mode — documented in `reviews/plan/20260309_weekly-assessment.md` and fixed with **MANDATORY CONTINUATION POINT** language in SKILL.md.

**CQRS Naming Convention**: All operations are named as `Create{Entity}Command`, `Update{Entity}Command`, `Delete{Entity}Command`, `Get{Entity}Query`, `List{Entity}Query`. This establishes a consistent backend API contract that downstream implementation can follow without ambiguity.

## Dependencies

- **Internal**: `systematic-dev-kit:explore` — invoked conditionally in Phase 1 when the user selects "Extends existing"; provides targeted codebase context before planning begins
- **External**: Prisma (generated model syntax with decorators); REST conventions (Express-style API endpoint notation); TypeScript (request/response interface shapes); React + hooks pattern (component hierarchy and `use{Entity}` hook naming); no runtime packages — plan produces specification artifacts only

## Gotchas

- **Adaptive depth is fixed at Q3**: If a developer realizes mid-planning that they need deeper coverage (e.g., forgot to select a complexity signal), they must restart Phase 1. There is no way to upgrade depth in-flight.
- **Explore return must not pause**: When `explore` returns in the "Extends existing" path, the skill must continue with Q3 in the same response. Not doing so is the highest-frequency documented failure mode — see `reviews/plan/20260309_weekly-assessment.md`.
- **All six tradeoffs must be resolved before synthesis**: If a tradeoff is triggered, Phase 3 cannot begin until the developer picks an option. There is no way to defer or skip tradeoff resolution.
- **File-upload tradeoff blocks implementation**: The storage strategy choice (local filesystem vs. S3-compatible vs. database blob) is non-trivial and must be decided at planning time. The spec cannot be written with "TBD" for storage.
- **Test generation is out of scope**: The skill produces implementation specs, not test suites. Test strategy must be handled separately.
- **Spec filename is strict kebab-case**: Files must be written to `specs/<feature-name>.md` in kebab-case. Deviating from this convention makes specs hard to discover.
- **Soft vs. hard delete is not defaulted**: If data sensitivity or cascade relationships make deletion non-trivial, the spec must capture the decision explicitly. The skill does not assume a deletion strategy.

## Changelog

- 2026-04-24: Initial documentation generated by doc-maintainer.
- 2026-05-01: Full refresh via doc-maintainer.
