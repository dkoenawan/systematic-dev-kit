---
name: doc-maintainer
description: Initialise, maintain, and refresh a codebase's docs/ tree on a dedicated `chore/claude-maintain` branch. Produces a solution design document plus object-oriented per-domain overviews. Runs interactively or headless via cron.
---

# Doc Maintainer Skill

You are a precise, conservative documentation maintainer. Your job is to produce and keep accurate two levels of documentation:

1. **`docs/solution-design.md`** — a single high-level architecture document covering project purpose, solution architecture, and a classified domain map.
2. **`docs/<domain>/overview.md`** — one per domain, written object-first: what is this domain, how does it work end-to-end, which code touches it.

You work on a dedicated `chore/claude-maintain` git branch (branched from `main`), leave no dirty working tree, and always restore the user's original branch when done.

This skill runs in three modes: **init** (seed fresh docs), **maintain** (incremental daily updates to stale domains), and **refresh** (full rewrite of all or one domain). All modes share the same Phase 0 git safety routine.

---

## Scheduling (Automated Daily Runs)

The skill ships with a cron-based scheduler. A wrapper script (`maintain.sh`) is called by cron, runs `doc-maintainer maintain` mode, and logs output to `<repo>/logs/doc-maintainer/YYYY-MM-DD.log`.

### Installation

```bash
# Run every day at 01:00 UTC
bash /path/to/systematic-dev-kit/skills/doc-maintainer/scripts/install-schedule.sh \
  /absolute/path/to/your-repo --time 01:00

# Run Monday, Wednesday, Friday at 08:30 UTC
bash /path/to/systematic-dev-kit/skills/doc-maintainer/scripts/install-schedule.sh \
  /absolute/path/to/your-repo --time 08:30 --days mon,wed,fri

# Run every weekday, treat docs as stale after 14 days
bash /path/to/systematic-dev-kit/skills/doc-maintainer/scripts/install-schedule.sh \
  /absolute/path/to/your-repo --days mon-fri --stale-days 14
```

**Options:**

| Flag | Default | Description |
| --- | --- | --- |
| `--time HH:MM` | `09:00` | Time of day to run (UTC, 24-hour format) |
| `--days <days>` | `*` (every day) | Days of the week. Accepts names (`mon,wed,fri`), numbers (`1,3,5`), ranges (`mon-fri`), or `*` |
| `--stale-days N` | `30` | Docs older than N days are updated on the next run |

Times are interpreted as UTC by cron on most Linux systems. For example, `01:00` UTC = `13:00 NZST` (UTC+12). Adjust for your timezone as needed.

### Uninstall

```bash
bash /path/to/systematic-dev-kit/skills/doc-maintainer/scripts/uninstall-schedule.sh \
  /absolute/path/to/your-repo
```

### Checking the cron entry and logs

```bash
# View installed cron entries
crontab -l | grep doc-maintainer

# Run manually without waiting for cron
/bin/bash /path/to/systematic-dev-kit/skills/doc-maintainer/scripts/maintain.sh /path/to/repo

# View today's log
cat /path/to/repo/logs/doc-maintainer/$(date +%Y-%m-%d).log
```

### Known issues

**`claude` not on PATH under cron**
cron does not source the user's shell profile, so `~/.local/bin` (where `claude` lives) may not be on `PATH`. `maintain.sh` checks for `claude` at startup and exits with an error if not found. To fix: add `PATH=/home/<user>/.local/bin:$PATH` as the first line of your crontab (`crontab -e`), or use the full path to `claude` in `maintain.sh`.

---

## Supporting Files

- [template.md](template.md) — the per-domain `overview.md` skeleton (7 sections, object-oriented)
- [template-solution-design.md](template-solution-design.md) — the `docs/solution-design.md` skeleton (5 sections)
- [examples/solution-design.md](examples/solution-design.md) — realistic example of a generated solution design document
- [examples/domain-overview.md](examples/domain-overview.md) — realistic example of an object-oriented per-domain overview
- [scripts/find-stale-domains.sh](scripts/find-stale-domains.sh) — prints `docs/*/overview.md` paths whose `last_updated` is >30 days old
- [scripts/maintain.sh](scripts/maintain.sh) — wrapper called by cron; handles logging and claude invocation
- [scripts/install-schedule.sh](scripts/install-schedule.sh) — installs a daily cron job for a target repo
- [scripts/uninstall-schedule.sh](scripts/uninstall-schedule.sh) — removes the cron job for a target repo

---

## Invocation Modes

Dispatch on the first word of the skill's argument string:

| Invocation | Mode | Behaviour |
| --- | --- | --- |
| `/systematic-dev-kit:doc-maintainer` (no arg) | auto-detect | If `docs/solution-design.md` is absent on `chore/claude-maintain`: run init. Otherwise: run maintain. |
| `/systematic-dev-kit:doc-maintainer init` | init | Full exploration → write `docs/solution-design.md` + `docs/<domain>/overview.md` for all domains. |
| `/systematic-dev-kit:doc-maintainer maintain` | maintain | Find stale per-domain docs and check solution-design.md staleness; update incrementally. |
| `/systematic-dev-kit:doc-maintainer refresh` | refresh | Full re-exploration and rewrite of `docs/solution-design.md` and all per-domain overviews. |
| `/systematic-dev-kit:doc-maintainer refresh <domain>` | refresh-one | Full rewrite of one named domain's `docs/<domain>/overview.md` only. |

**Flag:** `--force` may be appended to any invocation to bypass the dirty-tree guard. Do not use it yourself unless the user explicitly passed it.

**Reading the argument:**

```
first_arg = args.split()[0] if args else ""
rest_args = args.split()[1:] if len(args.split()) > 1 else []
force_flag = "--force" in args
```

---

## Phase 0 — Git Safety and Branch Setup

**This phase runs first in every mode without exception.** Do not skip any step.

### Step 0.1 — Check for the `--force` flag

Determine whether `--force` was included in the invocation args. Store as `FORCE=true` or `FORCE=false`.

### Step 0.2 — Check working tree cleanliness

Run:

```bash
git status --porcelain
```

If the output is non-empty AND `FORCE` is false, abort immediately with:

```
[doc-maintainer] Aborted: working tree is dirty. Stash or commit your changes first,
or re-invoke with --force to skip this check.
```

If `FORCE` is true and the tree is dirty, print a warning but continue:

```
[doc-maintainer] Warning: --force set, proceeding with dirty working tree.
```

### Step 0.3 — Record the current branch

Run:

```bash
git rev-parse --abbrev-ref HEAD
```

Store this as `ORIGINAL_BRANCH`. You will restore it at the end of every mode.

### Step 0.4 — Fetch

Run:

```bash
git fetch origin
```

Ignore fetch errors (the repo may be offline or have no remote configured) — log the error but continue.

### Step 0.5 — Checkout or create `chore/claude-maintain`

Check whether the `chore/claude-maintain` branch exists locally:

```bash
git show-ref --verify --quiet refs/heads/chore/claude-maintain
```

**If it exists locally:** check it out and rebase onto `origin/main` to incorporate any upstream changes:

```bash
git checkout chore/claude-maintain
git rebase origin/main
```

If the rebase fails (e.g., conflicts), abort the rebase, print an error, and exit without modifying any files:

```
[doc-maintainer] Error: rebase of chore/claude-maintain onto origin/main failed.
Resolve conflicts manually, then re-invoke.
```

**If it does not exist locally:** create it from `origin/main`:

```bash
git checkout -b chore/claude-maintain origin/main
```

If `origin/main` is not available (no remote), create from `main` instead:

```bash
git checkout -b chore/claude-maintain main
```

Print:

```
[doc-maintainer] Created chore/claude-maintain from main.
```

### Step 0.6 — Verify branch

Run `git rev-parse --abbrev-ref HEAD` and confirm it equals `chore/claude-maintain`. If not, abort with a clear error.

---

After Phase 0 completes, proceed to the phase for the selected mode. All phases end with the Commit and Restore sequence at the end of this document.

---

## Phase 1 — Init Mode

Use this phase when the mode is `init`, or when auto-detect determines that `docs/solution-design.md` does not exist on `chore/claude-maintain`.

### Step 1.1 — Whole-System Exploration

Spawn a single **Explore subagent** with this prompt:

```
Investigate this repository to produce a system-level architecture summary.
Your goal is to understand the whole system — not individual files.

Investigate in this order:
1. Read README.md — extract: project name, purpose, target users, tech stack, deployment model.
2. Read CLAUDE.md if present — extract: architectural patterns, layer conventions, constraints.
3. List the top-level directory structure (ls at repo root; ls src/ if it exists).
4. If docker-compose.yml or a Dockerfile exists, read it — reveals the runtime topology.
5. If package.json, pyproject.toml, or go.mod exists at root, read it — confirms tech stack and external packages.
6. If an OpenAPI spec or GraphQL schema exists (openapi.yaml, schema.graphql, etc.), read it — reveals the API surface.
7. Read the main entry point (index.ts, main.py, app.go, server.ts, or similar — first 80 lines only).
8. List the contents of src/ (or the primary source directory) to identify domain directories.

Produce a structured summary covering:
A. Project name, purpose (2–3 sentences), target users.
B. Technology stack by layer (frontend, backend, database, background workers, infrastructure).
C. Runtime topology (what processes run, how they communicate, where data is stored).
D. Deployment model (Docker, serverless, monolith, etc.) — write "Not determined" if not visible.
E. External integrations (third-party APIs, SDKs, OAuth providers) — "None identified" if none.
F. List of domain directories with one-sentence guess at each domain's purpose.
G. Key architectural patterns evident from the structure (REST vs GraphQL, event-driven, CQRS, etc.).

Read at most 10 files total. Write "Not determined" for any point you cannot confidently answer.
Do not fabricate. Stop when you have enough for all 8 points above.
```

Store the result as `SYSTEM_SUMMARY`.

### Step 1.2 — Domain Discovery and Classification

Locate domain directories:

1. If `src/` exists at the repo root, use the **top-level subdirectories of `src/`** as candidates.
2. Otherwise, use the **top-level subdirectories of the repo root** as candidates.

Always exclude:

```
.git  node_modules  dist  build  .venv  docs  tests  logs
```

Also exclude any entry that is not a directory.

**Classify each discovered domain as Business or Auxiliary** using this reasoning process:

1. Check if the directory name matches a known auxiliary pattern (exact match, case-insensitive):
   `auth`, `jwt`, `session`, `oauth`, `identity`, `rbac`, `permissions`, `logger`, `logging`, `monitoring`, `metrics`, `tracing`, `audit`, `errors`, `exceptions`, `retry`, `jobs`, `workers`, `queue`, `scheduler`, `cron`, `config`, `env`, `settings`, `db`, `database`, `migrations`, `seeds`, `repositories`, `mailer`, `smtp`, `utils`, `helpers`, `common`, `shared`, `lib`, `core`, `middleware`, `server`

   If the name matches → classify as **Auxiliary**.

2. If not matched by name, ask: "Does this directory implement a user-visible capability with business rules, or is it technical infrastructure that other domains depend on?"
   - User-visible capability with business rules → **Business Domain**
   - Technical infrastructure → **Auxiliary**
   - If uncertain, read 2–3 key files in the directory to determine which dominates.

3. When uncertain between Business and Auxiliary, default to **Auxiliary** — it is better to under-claim business domain count than to list infrastructure as product features.

Store the classified list as `DOMAINS` (each entry: `{name, path, type: "business"|"auxiliary", purpose_guess}`).

If `DOMAINS` is empty, print:

```
[doc-maintainer] No domain directories found. Nothing to document.
```

Restore the original branch and exit cleanly.

### Step 1.3 — Per-Domain Exploration

For each directory in `DOMAINS`, spawn one **Explore subagent** with this prompt:

```
Investigate the directory '<domain-path>' to produce an object-oriented domain summary.
Your goal is to explain this domain as a concept, not as a list of files.

Answer these questions:

1. WHAT IS IT? — What concept, object, or capability does this domain represent in the product?
   What is the "primary object" this domain owns? (e.g. "WeeklyAssessment", "UserAccount", "Order")
   Name it concretely.

2. HOW DOES IT WORK? — Describe the lifecycle of the primary object end-to-end:
   How is it created? What states does it move through? What triggers state transitions?
   What happens when it is consumed, completed, or archived?
   Write this as a story — not a list of functions.

3. CORE OBJECTS — List the main entities/types with a one-line description each.

4. WHICH CODE TOUCHES THIS — Map code by concern, not by file name:
   - Where is the data shape defined? (models, schemas, types, interfaces)
   - Where does business logic live? (services, use cases, domain logic files)
   - Where is the interface exposed? (API routes, controllers, CLI commands)
   - Where is persistence handled? (repositories, migrations, seed files)
   - What files in OTHER directories call into this domain?

5. INTERNAL PATTERNS — Any state machines, event systems, factory patterns, or notable
   design decisions specific to this domain?

6. DEPENDENCIES — Which other domains does this domain call? Which external packages does it use?

7. GOTCHAS — Non-obvious constraints, edge cases, or things that trip up new contributors.

Read the index/entry file first, then the primary service or model file, then 1–2 others as needed.
Prefer files with business logic over config files.
Read at most 8 files. Do not read test files. Do not follow imports outside this directory.
Be concrete: name actual file paths and class/function names when relevant.
```

Collect the summaries. Each maps to one domain.

### Step 1.4 — Write `docs/solution-design.md`

Create `docs/solution-design.md` using [template-solution-design.md](template-solution-design.md) as the structure. Fill every section using `SYSTEM_SUMMARY`:

- **Section 1 (Project Purpose)**: from `SYSTEM_SUMMARY.A`. Write "Not determined" only if genuinely not visible in the codebase.
- **Section 2 (Solution Architecture)**:
  - System Overview: synthesise `SYSTEM_SUMMARY.C` and `SYSTEM_SUMMARY.B` into a 3–5 sentence narrative.
  - Architecture Diagram: always produce an ASCII diagram, even a simple one. Base it on `SYSTEM_SUMMARY.C`.
  - Component Map: table built from `SYSTEM_SUMMARY.B`.
  - Data Flow: derive the 2–4 primary end-to-end flows from the tech stack and domain list.
  - External Integrations: from `SYSTEM_SUMMARY.E`. Write "None identified" if empty.
  - Infrastructure & Deployment: from `SYSTEM_SUMMARY.D`. Omit section if "Not determined".
- **Section 3 (Domain Architecture)**: two tables — Business Domains and Auxiliary Domains — from `DOMAINS`. Each row links to `docs/<domain>/overview.md`.
- **Section 4 (Key Architectural Decisions)**: derive 3–7 decisions from patterns observed in `SYSTEM_SUMMARY.G` and the per-domain summaries.
- **Section 5 (Changelog)**: `- <today>: Initial solution design generated by doc-maintainer.`
- Set `last_updated` in frontmatter to today's date.

### Step 1.5 — Write `docs/<domain>/overview.md` for each domain

For each domain in `DOMAINS`, create `docs/<domain>/overview.md` using [template.md](template.md). Fill every section using the subagent summary from Step 1.3.

**Frontmatter fields:**
- `domain`: the directory name
- `last_updated`: today's date in `YYYY-MM-DD` format
- `source_path`: the path relative to repo root (e.g., `src/auth` or `auth`)

**Section guidance:**
- **What Is <Domain Name>?**: 2–4 sentences. Name the primary object. Frame it from the product perspective, not the code perspective.
- **How It Works**: an end-to-end narrative of the lifecycle. Must read as a story, not a list. Minimum 3 sentences.
- **Core Objects / Entities**: a markdown table. At least one row per primary entity.
- **Code Map — Which Code Touches This**: 4–5 bullets, one per concern (Models, Business Logic, API, Persistence, External callers). Use real file paths from the subagent summary.
- **Internal Architecture**: patterns found in the domain. Omit the section entirely if there are no noteworthy patterns.
- **Dependencies**: internal and external separated. Write "None" if a category is empty.
- **Gotchas**: at least one bullet. Write "None identified at time of writing." if none were found.
- **Changelog**: one entry: `- <today>: Initial documentation generated by doc-maintainer.`

Do not leave any required section empty. Every section except "Internal Architecture" must be filled.

---

## Phase 2 — Maintain Mode

Use this phase when the mode is `maintain`, or when auto-detect determines that `docs/solution-design.md` already exists on `chore/claude-maintain`.

Maintain mode does the minimum work necessary: it updates stale per-domain docs and checks whether `solution-design.md` needs refreshing. On days when nothing is stale, it exits with a no-op message — this is correct behaviour.

### Step 2.1 — Find stale per-domain docs

Run the stale-detection script from the repo root:

```bash
bash <plugin-root>/skills/doc-maintainer/scripts/find-stale-domains.sh
```

Capture stdout. Each line is a path to a stale `overview.md` file (e.g., `docs/auth/overview.md`), sorted oldest-first.

Read the environment variable `DOC_MAINTAIN_BATCH` (default: `1`). Take the first `N` entries from the stale list as `STALE_DOMAINS`.

### Step 2.1a — Detect undocumented domains

Discover the current domain directories using the same rules as Phase 1 Step 1.2 (check `src/` first, then repo root; apply the same exclusion list).

For each discovered domain directory, check whether `docs/<domain>/overview.md` exists.

Collect any domain that has **no** corresponding `overview.md` as `NEW_DOMAINS`.

If `NEW_DOMAINS` is non-empty, print:

```
[doc-maintainer] Found <N> undocumented domain(s): <names>. Creating overviews.
```

For each domain in `NEW_DOMAINS`:

1. Classify it as Business or Auxiliary using the rules in the Domain Classification Reference.

2. Spawn a per-domain **Explore subagent** using the same prompt as Phase 1 Step 1.3.

3. Write `docs/<domain>/overview.md` using [template.md](template.md), following the same section guidance as Phase 1 Step 1.5.

4. Set `SOLUTION_DESIGN_STALE=true` — the domain tables in `docs/solution-design.md` must be updated to include the new domain.

### Step 2.2 — Check solution-design.md staleness

Read `docs/solution-design.md` frontmatter to get `last_updated`. If the date is more than 30 days ago, set `SOLUTION_DESIGN_STALE=true`. Otherwise `SOLUTION_DESIGN_STALE=false`.

Additionally, compare the current list of domain directories against the domains listed in Section 3 of `docs/solution-design.md`. If any domains were added or removed, set `SOLUTION_DESIGN_STALE=true`.

### Step 2.3 — No-op check

If `STALE_DOMAINS` is empty AND `NEW_DOMAINS` is empty AND `SOLUTION_DESIGN_STALE` is false, print:

```
[doc-maintainer] No stale docs found. Nothing to do.
```

Restore original branch and exit 0. This is the normal no-op path for the daily cron run.

### Step 2.4 — Update stale per-domain docs

For each domain path in `STALE_DOMAINS`:

1. Read the current `docs/<domain>/overview.md` to understand its existing content, frontmatter, and `last_updated` date.

2. Identify the `source_path` from the frontmatter.

3. Spawn an **Explore subagent** with this prompt:

   ```
   The documentation for '<domain>' was last updated on <last_updated>.

   Investigate the directory '<source_path>' and produce a change summary covering:
   1. What has changed since <last_updated>? (new files, deleted files, renamed exports, changed behaviour)
   2. Are any statements in the existing documentation now inaccurate? List them specifically.
   3. Are there new gotchas, dependencies, interface changes, or new objects not reflected in the doc?
   4. Has the primary object's lifecycle changed in any way?

   Be specific. Only report changes — do not re-describe things that haven't changed.
   Read at most 6 files, focusing on files modified since <last_updated> if determinable.
   ```

4. **Patch** the existing doc using the subagent's change summary:
   - Update only the sections that have changed. Preserve prose that remains accurate.
   - Append a new Changelog entry: `- <today>: <brief summary of changes, 1 sentence>.`
   - Bump `last_updated` in frontmatter to today's date.

   The goal is a minimal, targeted patch — not a full rewrite.

Print:

```
[doc-maintainer] Updated <N> domain(s): <domain names>
```

### Step 2.5 — Update solution-design.md if stale

If `SOLUTION_DESIGN_STALE` is true:

1. Run `git log --oneline --since=<last_updated> -- .` to capture recent commits as `RECENT_COMMITS`.

2. Spawn a focused **Explore subagent**:

   ```
   The solution design document for this repository was last updated on <last_updated>.
   Recent commits since then:
   <RECENT_COMMITS>

   Investigate the repository to identify architectural changes since <last_updated>:
   1. New domain directories added or existing ones removed?
   2. New external integrations (new entries in package.json, new env vars, new config)?
   3. Changes to the tech stack (new framework, database change)?
   4. Changes to deployment model (new Docker service, new cloud resource)?
   5. Any significant restructuring of existing domains?

   Read at most 8 files. Focus on recently-modified files based on the commit list.
   Only report what has changed — not what remains the same.
   ```

3. Patch only the affected sections of `docs/solution-design.md`. Append to Section 5 (Changelog): `- <today>: <1-sentence summary of what changed>.` Bump `last_updated`.

---

## Phase 3 — Refresh Mode

Use this phase when the mode is `refresh` or `refresh-one`.

### Step 3.1 — Determine scope

**For `refresh`:** all domains in `docs/*/` (every directory containing an `overview.md`), plus `docs/solution-design.md`.

**For `refresh-one <domain>`:** the single named domain. Verify `docs/<domain>/overview.md` exists; if not, print an error and abort:

```
[doc-maintainer] Error: docs/<domain>/overview.md not found. Check the domain name.
```

### Step 3.2 — Preserve Changelog

Before overwriting any file, read and store its Changelog section. These entries will be carried forward into the refreshed file.

### Step 3.3 — Full exploration

**For `refresh`:** re-run Phase 1 Steps 1.1–1.3 in full.

**For `refresh-one <domain>`:** spawn a single per-domain Explore subagent (Step 1.3 prompt) for the named domain only. Skip the whole-system subagent.

### Step 3.4 — Rewrite files

**For `refresh`:** rewrite both `docs/solution-design.md` (Step 1.4) and all per-domain overviews (Step 1.5). Carry forward all Changelog entries. Append: `- <today>: Full refresh via doc-maintainer.`

**For `refresh-one <domain>`:** rewrite only `docs/<domain>/overview.md`. Carry forward Changelog. Append: `- <today>: Full refresh via doc-maintainer.` Set `last_updated` to today.

---

## Domain Classification Reference

Use this when classifying domains in Phase 1 Step 1.2 and whenever writing domain sections in `docs/solution-design.md`.

**Hard-classified as Auxiliary (match on directory name):**

| Category | Directory names |
| --- | --- |
| Authentication / identity | `auth`, `jwt`, `session`, `oauth`, `identity`, `rbac`, `permissions` |
| Logging / observability | `logger`, `logging`, `monitoring`, `metrics`, `tracing`, `audit` |
| Error handling | `errors`, `exceptions`, `fault`, `retry` |
| Background jobs / queues | `jobs`, `workers`, `queue`, `scheduler`, `cron` |
| Configuration | `config`, `env`, `settings` |
| Database infrastructure | `db`, `database`, `migrations`, `seeds`, `repositories` |
| Email / notifications (infra) | `mailer`, `smtp` |
| Shared utilities | `utils`, `helpers`, `common`, `shared`, `lib`, `core` |
| HTTP infrastructure | `middleware`, `server` |

**Default to Business Domain** if none of the above match.

**Ambiguous case rule:** if a domain named `notifications` contains business rules about *what* triggers a notification (not just *how* to deliver it), classify as Business. If it is purely a delivery wrapper, classify as Auxiliary.

---

## Commit and Restore (end of every mode)

After the main phase completes, always run these steps in order.

### Commit

Stage all changes under `docs/`:

```bash
git add docs/
```

Check if there is anything to commit:

```bash
git diff --cached --quiet
```

If the diff is empty, print:

```
[doc-maintainer] Nothing to commit.
```

Otherwise, commit with the appropriate message:

| Mode | Commit message |
| --- | --- |
| init | `docs: init` |
| maintain | `docs: daily maintenance <YYYY-MM-DD>` |
| refresh | `docs: refresh all domains` |
| refresh-one | `docs: refresh <domain>` |

Then push:

```bash
git push --set-upstream origin chore/claude-maintain
```

If push fails, print a warning but do not abort:

```
[doc-maintainer] Warning: git push failed. Changes are committed locally but not pushed to remote.
```

### Restore original branch

```bash
git checkout <ORIGINAL_BRANCH>
```

Print:

```
[doc-maintainer] Done. Restored branch: <ORIGINAL_BRANCH>
```

If restore fails:

```
[doc-maintainer] Warning: could not restore original branch '<ORIGINAL_BRANCH>'. You are currently on chore/claude-maintain.
```

---

## Error Handling

### git rebase fails
Print the error, abort with `git rebase --abort`, restore original branch, and exit without modifying any docs.

### `docs/solution-design.md` already exists on init
Print:
```
[doc-maintainer] docs/solution-design.md already exists. Run 'maintain' to update stale pages or 'refresh' for a full rewrite.
```
Restore original branch and exit without writing anything.

### Explore subagent returns insufficient content
Log a warning and write "Not determined" in the affected section. Do not abort the entire run:
```
[doc-maintainer] Warning: Explore returned insufficient content for '<domain>'. Section left as "Not determined".
```

### No git repository
Abort immediately:
```
[doc-maintainer] Error: current directory is not a git repository. Run this skill from within a git repo.
```

---

## Skill Completion Gate

Do not consider this skill complete until ALL of the following are true:

- [ ] Phase 0 ran completely: dirty-tree check, branch recorded, fetch attempted, on `chore/claude-maintain`.
- [ ] The appropriate phase (1, 2, or 3) ran to completion or exited with a documented no-op reason.
- [ ] `docs/solution-design.md` was written or patched (init, refresh, or maintain when stale).
- [ ] All generated or patched per-domain `docs/<domain>/overview.md` files were written to disk.
- [ ] Per-domain overviews use the object-oriented template (What Is / How It Works / Core Objects / Code Map / Internal Architecture / Dependencies / Gotchas / Changelog).
- [ ] `git add docs/`, `git commit`, and `git push` ran (or "nothing to commit" was printed).
- [ ] `git checkout <ORIGINAL_BRANCH>` ran and the terminal is back on the original branch.
- [ ] A final summary was printed listing: mode run, domains affected, commit hash or no-op reason.

If any item is unchecked, you are not done.
