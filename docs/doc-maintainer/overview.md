---
domain: doc-maintainer
last_updated: 2026-04-24
source_path: skills/doc-maintainer
---

# Doc Maintainer

## What Is Doc Maintainer?

Doc Maintainer is an automated documentation lifecycle system that explores a codebase, infers its architecture, and produces living documentation that stays synchronised with code changes. The primary object it owns is a **DocumentationSnapshot** — a timestamped pair of files: one high-level `docs/solution-design.md` covering project purpose, architecture, and domain map, and a set of `docs/<domain>/overview.md` files each describing one domain in an object-oriented, narrative style. It is a code-archaeology agent, not a prose-writing assistant.

## How It Works

A DocumentationSnapshot is seeded on first run (`init` mode), maintained incrementally on a schedule (`maintain` mode), and fully rewritten on demand (`refresh` mode). Every mode begins with a git safety routine: the working tree must be clean, the current branch is recorded, and the skill checks out or creates the `chore/claude-maintain` branch (rebased from `origin/main`). All doc changes happen exclusively on this branch — the developer's working branch is never touched.

In `init` mode, the skill spawns a whole-system Explore sub-agent to understand the project's tech stack, runtime topology, and domain list. It then classifies each domain directory as Business or Auxiliary using name-matching rules and code inspection. For each domain, it spawns a per-domain Explore sub-agent that produces a structured object-oriented summary. Those summaries fill the `solution-design.md` and `overview.md` templates. Once all files are written, the skill stages, commits (`docs: init`), and pushes, then restores the developer's original branch.

In `maintain` mode (typically run daily via cron), the skill identifies stale `overview.md` files by reading the `last_updated` frontmatter field, detects any new domain directories that have no corresponding doc, and checks whether `solution-design.md` is older than 30 days or whether the domain list has changed. It updates only what is stale — most runs produce a no-op exit. In `refresh` mode, the skill repeats the full exploration and overwrites all files, preserving the Changelog sections so history is not lost.

## Core Objects / Entities

| Object | Description |
| ------ | ----------- |
| `DocumentationSnapshot` | The full set of generated docs at a point in time: `solution-design.md` + all `docs/<domain>/overview.md` files. |
| `Domain` | A code directory classified as Business or Auxiliary, with name, path, type, and purpose. The unit of documentation. |
| `DomainOverview` | Per-domain markdown doc with YAML frontmatter (`domain`, `last_updated`, `source_path`). Contains What/How narrative, Core Objects table, Code Map, dependencies, and gotchas. |
| `SolutionDesign` | Project-level markdown doc. Contains project purpose, architecture diagram, component map, data flows, external integrations, and domain tables. |
| `ChangeLog` | Ordered list of `(date, description)` entries appended on every generation. Preserved across refresh cycles. |

## Code Map — Which Code Touches This

- **Models / Schema**: `skills/doc-maintainer/template.md` — per-domain `overview.md` structure (What Is / How It Works / Core Objects / Code Map / Internal Architecture / Dependencies / Gotchas / Changelog); `skills/doc-maintainer/template-solution-design.md` — `solution-design.md` structure.
- **Business Logic / Services**: `skills/doc-maintainer/SKILL.md` — complete specification of all three modes (init, maintain, refresh), git safety routines (Phase 0), domain classification rules, stale detection logic, and per-domain exploration prompts.
- **API / Interface**: Invoked as `/systematic-dev-kit:doc-maintainer [init|maintain|refresh|refresh <domain>]`; `scripts/maintain.sh` is the cron wrapper that invokes `claude -p "/systematic-dev-kit:doc-maintainer maintain"` non-interactively.
- **Persistence**: `scripts/find-stale-domains.sh` — walks `docs/*/overview.md`, reads `last_updated` frontmatter, prints stale paths oldest-first; `scripts/install-schedule.sh` / `scripts/uninstall-schedule.sh` — manage the user's crontab entry.
- **External callers**: `scripts/maintain.sh` (called by cron); the Claude Code harness (interactive invocation).

## Internal Architecture

**Phase Gate Pattern**: Every mode (init, maintain, refresh) begins with Phase 0 (git safety) and ends with Commit + Restore. Mode-specific logic runs between these two bookends, ensuring consistent branch hygiene regardless of outcome.

**Domain Classification State Machine**: Domains are classified in two steps — (1) exact name-match against a hardcoded auxiliary pattern list (`auth`, `db`, `logger`, `middleware`, etc.), then (2) if unmatched, code inspection to determine whether the directory has user-visible business logic. Default on ambiguity: Auxiliary.

**Batch Update Window**: The `DOC_MAINTAIN_BATCH` env var (default: 1) caps how many stale domains are updated per maintain run, limiting the token cost of each cron execution.

**Staleness via Frontmatter**: `last_updated` in each doc's YAML frontmatter is the source of truth. If the field is missing or malformed, `find-stale-domains.sh` falls back to file mtime.

**No-op Exit Path**: If no stale domains, no new domains, and `solution-design.md` is not stale, maintain exits cleanly with a no-op message. This is the expected outcome on most daily runs.

## Dependencies

- **Internal**: `systematic-dev-kit:explore` — spawned as sub-agents during init, maintain, and refresh to perform codebase investigation.
- **External**: `bash`/coreutils (`date`, `stat`, `sort`, `grep`, `sed`) for staleness detection scripts; `git` for all branch operations; `cron` for scheduled maintenance; Claude Code CLI (`claude` binary) called by `maintain.sh`.

## Gotchas

- The `chore/claude-maintain` branch must rebase cleanly onto `origin/main`. If there are conflicts, the skill aborts and asks the developer to resolve them manually.
- Cron does not source the user's shell profile, so the `claude` binary (typically at `~/.local/bin/claude`) may not be on `PATH`. Fix by adding `PATH=/home/<user>/.local/bin:$PATH` as the first line of the crontab, or using the full path in `maintain.sh`.
- The `--force` flag bypasses the dirty-tree check. Use it only when you explicitly want to proceed with uncommitted changes; it will print a warning but not abort.
- Log files in `<repo>/logs/doc-maintainer/` grow unbounded — one file per calendar day. There is no built-in log rotation; prune manually for long-running repos.
- Stale detection does not track fine-grained architectural changes (e.g., a new external integration) unless a domain directory was added or removed. Run `refresh` to force a full re-exploration when significant structural changes occur.
- `last_updated` must be in strict `YYYY-MM-DD` format. Malformed dates silently degrade to file mtime for staleness comparison.

## Changelog

- 2026-04-24: Initial documentation generated by doc-maintainer.
