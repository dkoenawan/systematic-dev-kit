---
domain: explore
last_updated: 2026-05-01
source_path: skills/explore
---

# Explore (L3)

> → [System overview](../solution-design.md) | → [Container architecture](../containers.md)

## What Is Explore?

Explore is a token-efficient codebase investigation capability whose primary object is an **InvestigationReport** — a structured summary that answers a specific question about a codebase by reading the minimum number of files necessary. It distils large codebases into essential architectural knowledge without broad file scanning, making it the preferred entry point for any task that requires understanding an unfamiliar codebase or a specific domain before acting. Explore is both a standalone skill developers invoke directly and an internal dependency called automatically by `plan` and `doc-maintainer`.

## How It Works

An InvestigationReport is produced through a three-tier traversal with sufficiency gates between each tier. The investigation begins when the skill receives a focus question — either from a developer invoking `/compass:explore` directly, or passed automatically by the `plan` or `doc-maintainer` skills.

**Tier 1 (Docs First)**: Read `README.md`, check for a `docs/` directory, and read `CLAUDE.md` if present. After each read, a sufficiency gate evaluates whether the tech stack, project structure, and focus-relevant context are now understood. If yes, investigation stops immediately. If gaps remain, advance to Tier 2.

**Tier 2 (Structure)**: Read `package.json` (or pyproject.toml/go.mod equivalent), workspace configs, Prisma schemas or entity files, and perform directory listings. A second sufficiency gate fires. If gaps remain, advance to Tier 3.

**Tier 3 (Targeted Code)**: Read up to 5 specific source files, capped at 50 lines each for files over 300 lines. Import chains are never followed. Hard stop — no further reading regardless of remaining gaps.

The completed InvestigationReport is returned with fixed sections: Tech Stack, Data Models, Backend Structure, Frontend Structure, Key Architectural Patterns, Relevance to Focus, and What Was Not Determined. When invoked automatically by `plan` or `doc-maintainer`, the report flows directly back into the calling skill's workflow without surfacing to the user.

## Core Objects / Entities

| Object | Description |
| ------ | ----------- |
| `InvestigationReport` | Structured output with fixed sections answering the stated focus question. The primary deliverable. |
| `Focus` | The investigation question passed by the user or a calling skill (e.g., "auth system", "order management domain"). |
| `TieredTraversal` | The three-tier algorithm (Docs → Structure → Targeted Code) executed in sequence with sufficiency gates. |
| `SufficiencyGate` | Decision point after each tier: "Is the focus question answered?" If yes, stop. If no, advance to next tier. |

## Code Map — Which Code Touches This

- **Business Logic**: `skills/explore/SKILL.md` — the full three-tier traversal algorithm, sufficiency gate logic, file-read ordering rules (README first, schema before source, docs before code), hard limits (max 5 files in Tier 3, max 50 lines for large files), monorepo and large-schema handling rules, and fixed Report section structure
- **Interface**: Invoked as `/compass:explore` (standalone, user provides focus); or called automatically with a focus parameter by `compass-labs:plan` and `compass-labs:doc-maintainer`
- **Persistence**: None — the skill produces a report returned in-context; no files are written or modified
- **External callers**: `skills/plan/SKILL.md` — invokes explore when user selects "Extends existing" to investigate related code before feature planning; `skills/doc-maintainer/SKILL.md` — spawns explore subagents for whole-system archaeology and per-domain deep dives

## Internal Architecture

**Tiered Sufficiency Architecture**: The three sequential tiers with explicit stop gates prevent over-reading. The core design invariant is that the skill must not advance to a higher tier if the lower tier was sufficient — stopping early is correct behavior, not a shortcut.

**Token Economy Read Ordering**: Read order is designed to maximize information density per token used: README (high context, low file size) → CLAUDE.md (architectural constraints and conventions) → schema files (data model, compact) → directory listings (structure without reading files) → targeted source files (highest cost, only when necessary). This ordering is not configurable.

**Fixed Output Schema**: The InvestigationReport has a rigid structure with required sections, making outputs deterministic and suitable for downstream parsing by skills like `plan` and `doc-maintainer`. The "What Was Not Determined" section is mandatory — it must honestly record what the investigation could not answer rather than silently omitting gaps.

**Context Fork Isolation**: The skill runs in an isolated context from its parent (e.g., `plan`). State from the parent is not available; the focus question must be passed explicitly at invocation.

## Dependencies

- **Internal**: Called by `compass-labs:plan` and `compass-labs:doc-maintainer` as a subskill; no outbound calls to other skills
- **External**: Read, Glob, Grep, and Bash (`ls` only) tools — standard Claude Code tooling; no external packages or APIs required

## Gotchas

- **Sufficiency gate relies on honest self-assessment**: If the focus appears answered at Tier 1 but key context is in a non-obvious file (e.g., a domain-specific config rather than README), the report will have gaps. The "What Was Not Determined" section is the safety valve — it must be filled honestly.
- **Tier 3 does not follow imports**: If a key entity is defined in a dependency of the scanned file, it will not be captured. This is by design (scope containment), but callers must be aware the report may miss cross-file relationships.
- **Large schema files are truncated**: Prisma or entity schema files exceeding 300 lines are truncated to the first 50 lines. The truncation must be noted in the report; the developer should inspect the remainder manually if the schema is a critical focus area.
- **Vague focus questions satisfy sufficiency early**: A broad focus like "overall architecture" may pass the sufficiency gate at Tier 1 before all patterns are captured. Callers should pass specific focus questions for reliable results.
- **Codebases without README or docs immediately lose Tier 1**: The highest-value cheap reads are unavailable, which typically produces less-confident Tier 2 or Tier 3 reports. The "What Was Not Determined" section should reflect this.
- **No iterative refinement**: The skill completes in one invocation. If the focus was underspecified, the report must be taken as-is; there is no follow-up narrowing within the same invocation.

## Changelog

- 2026-04-24: Initial documentation generated by doc-maintainer.
- 2026-05-01: Full refresh via doc-maintainer.
