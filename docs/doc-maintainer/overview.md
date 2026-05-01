---
domain: doc-maintainer
last_updated: 2026-05-01
source_path: skills/doc-maintainer
---

# Doc Maintainer (L3)

> → [System overview](../solution-design.md) | → [Container architecture](../containers.md)

## What Is Doc Maintainer?

Doc Maintainer is an automated documentation lifecycle system that explores a codebase, infers its architecture, and produces a living C4-layered documentation tree that stays synchronised with code changes over time. Its primary object is the **DocumentationTree** — a multi-file, versioned hierarchy containing an L1 system context file (`docs/solution-design.md`), an L2 container architecture file (`docs/containers.md`), and L3 per-domain deep-dives (`docs/<domain>/overview.md`). The system grows incrementally — one file per run — so token cost per invocation stays bounded and predictable regardless of codebase size.

## How It Works

A DocumentationTree is seeded on first run (`init` mode), built out incrementally on a schedule (`maintain` mode), and fully rewritten on demand (`refresh` mode). Every mode begins with Phase 0 — a git safety routine that checks the working tree is clean, records the current branch, fetches from origin, and checks out (or creates) the `chore/claude-maintain` branch rebased onto `origin/main`. All documentation changes happen exclusively on this branch; the developer's working branch is never touched.

In `init` mode, a whole-system Explore subagent investigates the codebase (up to 10 files: README, CLAUDE.md, top-level structure, docker-compose, package files, OpenAPI spec, and entry point). The skill classifies each top-level domain directory as Business or Auxiliary, then writes only `docs/solution-design.md` (L1). No container architecture or domain overviews are written on init — those accumulate through subsequent maintain runs.

In `maintain` mode (typically run daily via cron), a priority queue dispatcher picks exactly one unit of work per run: (1) generate `docs/containers.md` if missing, (2) generate the next ⬜ domain overview, (3) run an accuracy patch on any doc whose `last_updated` frontmatter is older than the staleness threshold (default 30 days), or (4) run a clarity review on the oldest-reviewed doc in the tree. In `refresh` mode, all docs are fully re-explored and rewritten, preserving existing Changelog entries.

After every mode, the skill stages `docs/`, commits with a mode-specific message, pushes to `origin/chore/claude-maintain`, and restores the developer's original branch.

## Core Objects / Entities

| Object | Description |
| ------ | ----------- |
| `DocumentationTree` | The full multi-file hierarchy: L1 solution-design.md, L2 containers.md, L3 domain overviews. Versioned, incrementally built. |
| `SolutionDesignDoc (L1)` | Entry-point file. Contains project name, purpose, users, external systems diagram, domain map table with status (⬜/📄), and key architectural decisions. |
| `ContainerArchDoc (L2)` | Infrastructure topology. Contains ASCII container diagram, services table, primary data flows, and deployment model. |
| `DomainOverview (L3)` | Per-domain deep-dive. Contains what/how narrative, core objects table, code map by concern, internal patterns, dependencies, gotchas, and changelog. |
| `DomainClassification` | Each domain tagged as Business (user-visible capability) or Auxiliary (technical infrastructure). Used in the L1 domain map. |
| `DocumentStatus` | Track state of each L3 doc: ⬜ (not yet generated) or 📄 (generated). Stored in the L1 domain map table. |
| `StalenessTracker` | The `last_updated` YAML frontmatter date in each doc. Read by `find-stale-domains.sh` to detect which overviews need accuracy patches. |
| `ClarityLog` | `docs/clarity-log.md` — audit trail of clarity reviews: one entry per file per review, format `YYYY-MM-DD | path | one-sentence description`. |

## Code Map — Which Code Touches This

- **Templates (data shapes)**: `skills/doc-maintainer/template.md` (L3 structure), `skills/doc-maintainer/template-solution-design.md` (L1 structure), `skills/doc-maintainer/template-containers.md` (L2 structure)
- **Business Logic**: `skills/doc-maintainer/SKILL.md` — the master specification defining all three modes and their phases, Phase 0 git safety routine, domain classification rules, priority queue dispatch logic, and post-write size check (split files >500 lines)
- **Cron Interface**: `skills/doc-maintainer/scripts/maintain.sh` — wrapper that invokes `claude -p "/systematic-dev-kit:doc-maintainer maintain"` non-interactively and logs output to `<repo>/logs/doc-maintainer/YYYY-MM-DD.log`
- **Scheduler**: `skills/doc-maintainer/scripts/install-schedule.sh` / `uninstall-schedule.sh` — manage the user's crontab entry (accepts `--time HH:MM`, `--days`, `--stale-days` options)
- **Staleness Detection**: `skills/doc-maintainer/scripts/find-stale-domains.sh` — reads `last_updated` from YAML frontmatter of every `docs/*/overview.md`, prints paths older than the threshold, sorted oldest-first
- **Examples**: `skills/doc-maintainer/examples/` — realistic L1, L2, and L3 reference implementations used as quality bar

## Internal Architecture

**Phase Gate Pattern**: Every mode (init, maintain, refresh) begins with Phase 0 (git safety) and ends with Commit + Restore. Mode-specific logic runs between these bookends, ensuring consistent branch hygiene regardless of outcome or error.

**Priority Queue Dispatch (Maintain Mode)**: Four-tier priority system ensures every maintain run is productive. L2 generation always comes before L3; new domains (⬜) before stale patches; stale patches before clarity reviews. There is no "nothing to do" exit path — Priority 4 (clarity review) is always reachable.

**Subagent-Driven Exploration**: The skill never reads code itself. All codebase investigation is delegated to focused Explore subagents with bounded file budgets (6–10 files per subagent depending on phase). Subagent results are formatted into template-driven Markdown by the orchestrating skill.

**Domain Classification Logic**: Two-step automatic classification. Step 1: exact name-match against a hardcoded auxiliary list (auth, jwt, db, logger, middleware, utils, etc.). Step 2 (if no match): heuristic — "Does this implement user-visible capability with business rules?" Default on ambiguity: Auxiliary.

**File Size Splitting**: After writing any doc, the skill counts lines. Files exceeding 500 lines are split into a folder structure (`index.md`, `lifecycle.md`, `code-map.md`, `decisions.md`, `changelog.md`), keeping individual files scannable by downstream agents.

**Staleness Tracking via Frontmatter**: `last_updated` in each doc's YAML frontmatter is the source of truth. `find-stale-domains.sh` reads this field; if missing or malformed, it falls back to file mtime.

## Dependencies

- **Internal**: `systematic-dev-kit:explore` — spawned as subagents during all three modes to perform codebase investigation
- **External**: `git` (all branch operations); `bash`/coreutils (`date`, `stat`, `sort`, `grep`, `sed`) for staleness detection and scheduling scripts; `cron` for scheduled maintenance; Claude Code CLI (`claude` binary) called by `maintain.sh`

## Gotchas

- **Rebase failures block execution**: If `chore/claude-maintain` has diverged from `origin/main` (e.g., due to a force-push or manual edit), the rebase in Phase 0 fails and the skill aborts without modifying any docs. Resolve conflicts manually and re-invoke.
- **Dirty working tree blocks execution** (unless `--force`): Any uncommitted changes cause Phase 0 to abort. `--force` bypasses this check but prints a warning; use with care as git operations may produce unexpected results.
- **`claude` not on PATH under cron**: Cron does not source the user's shell profile, so `~/.local/bin/claude` may not be available. Fix by adding `PATH=/home/<user>/.local/bin:$PATH` as the first line of the crontab.
- **No auto-cleanup of deleted domains**: If a domain directory is removed from the codebase, its `docs/<domain>/overview.md` is not automatically deleted. The L1 domain map table will contain a stale link. Remove the doc and update the table manually.
- **Stale detection does not track structural changes**: The staleness script only checks the `last_updated` date — it does not detect whether the code has actually changed. Run `refresh` after major structural changes rather than waiting for the 30-day threshold.
- **Log files grow unbounded**: `logs/doc-maintainer/` accumulates one file per calendar day with no built-in rotation. Prune manually for long-running repos.
- **`last_updated` must be strict `YYYY-MM-DD`**: Malformed dates silently degrade to file mtime for staleness comparison, which may cause unexpected accuracy patches.

## Changelog

- 2026-04-24: Initial documentation generated by doc-maintainer.
- 2026-05-01: Full refresh via doc-maintainer.
