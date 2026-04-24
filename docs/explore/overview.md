---
domain: explore
last_updated: 2026-04-24
source_path: skills/explore
---

# Explore

## What Is Explore?

Explore is a token-efficient codebase investigation capability whose primary object is an **Investigation Report** — a structured summary that answers a specific question about a codebase by reading the minimum number of files necessary. It distils large codebases into essential architectural knowledge without broad file scanning, making it the preferred entry point for any task that requires understanding an unfamiliar codebase or a specific domain before acting on it.

## How It Works

An Investigation Report is produced through a three-tier traversal with sufficiency gates between each tier. The investigation begins when the skill receives a focus question — either from a developer invoking `/systematic-dev-kit:explore` directly, or from the `plan` or `doc-maintainer` skills passing a focus parameter automatically.

In Tier 1, the skill reads `README.md`, checks for a `docs/` directory, and reads `CLAUDE.md` if present. After each read, a sufficiency gate evaluates whether the tech stack, project structure, and focus-relevant context are now understood. If yes, investigation stops immediately — no further files are read. If gaps remain, the skill advances to Tier 2: reading `package.json` (or equivalent), workspace configs, Prisma schemas, and performing directory listings to understand structure without deep code reading. A second sufficiency gate then fires. If gaps still remain, Tier 3 reads up to 5 specific source files (capped at 50 lines each for files over 300 lines) to close explicit gaps. Import chains are never followed.

The completed Investigation Report is returned with fixed sections: Tech Stack, Data Models, Backend Structure, Frontend Structure, Key Architectural Patterns, Relevance to Focus, and What Was Not Determined. When invoked automatically by `plan` or `doc-maintainer`, the report flows directly back into the calling skill's workflow.

## Core Objects / Entities

| Object | Description |
| ------ | ----------- |
| `InvestigationReport` | Structured output with fixed sections answering the stated investigation focus. |
| `TieredTraversal` | The three-tier algorithm (Docs → Structure → Targeted Code) with sufficiency gates between each tier. |
| `SufficiencyGate` | Decision point after each tier determining whether more investigation is needed before advancing. |
| `Focus` | The investigation question passed by the user or a calling skill (e.g., "auth system", "order management"). |

## Code Map — Which Code Touches This

- **Models / Schema**: `skills/explore/SKILL.md` — defines allowed tools (Read, Glob, Grep, Bash/ls only), hard limits (max 5 files in Tier 3, max 50 lines for large files), and the fixed Report section structure.
- **Business Logic / Services**: `skills/explore/SKILL.md` — the three-tier traversal algorithm with sufficiency gate logic, file-read ordering (README first, schema before source, docs before code), and monorepo/large-schema handling rules.
- **API / Interface**: Invoked as `/systematic-dev-kit:explore` (standalone, user provides focus) or called automatically with a focus parameter by `systematic-dev-kit:plan` and `systematic-dev-kit:doc-maintainer`.
- **Persistence**: None — the skill produces a report returned in-context; no files are written.
- **External callers**: `skills/plan/SKILL.md` — invokes explore when user selects "Extends existing" to investigate related code before feature planning; `skills/doc-maintainer/SKILL.md` — spawns explore sub-agents for whole-system and per-domain codebase archaeology.

## Internal Architecture

**Tiered Sufficiency Architecture**: The three sequential tiers with explicit stop gates prevent over-reading. Each tier checks whether the focus question is answered before proceeding. This is the core design invariant — the skill must not advance to a higher tier if the lower tier was sufficient.

**Token Economy Ordering**: Read order is designed to maximise information density per token: README (high context, low size) → CLAUDE.md (architectural constraints) → schema files (data model, low line count) → directory listings (structure without reading files) → targeted source (highest cost, only when necessary).

**Error Transparency**: Missing README, oversized schema files, and monorepo path complexity are all documented in the report's "What Was Not Determined" section rather than silently handled.

## Dependencies

- **Internal**: Called by `systematic-dev-kit:plan` and `systematic-dev-kit:doc-maintainer` as a sub-skill.
- **External**: Read, Glob, Grep, and Bash (ls only) tools — standard Claude Code tooling; no external packages or APIs.

## Gotchas

- The sufficiency gate relies on honest self-assessment. If the focus question appears answered at Tier 1 but key context is in a non-obvious file, the report will have gaps and the caller's workflow may suffer.
- Tier 3 deliberately does not follow imports. If a key entity is defined in a dependency of the scanned file, it will not be captured — the "What Was Not Determined" section should note this.
- Large Prisma or entity schema files (>500 lines) are truncated to 200 lines. The truncation must be noted in the report; the developer should investigate the remainder manually if the schema is a critical focus area.
- Codebases without README, `docs/`, or `CLAUDE.md` immediately skip to Tier 2 — the highest-value cheap reads are unavailable, which may produce less-confident reports.
- Vague focus questions (e.g., "overall architecture") may satisfy the sufficiency gate at Tier 1 before all architectural patterns are fully captured. Callers should provide specific focus questions for best results.

## Changelog

- 2026-04-24: Initial documentation generated by doc-maintainer.
