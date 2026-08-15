---
name: doc-maintainer
description: Initialise, maintain, and refresh a codebase's docs/ tree on a dedicated `chore/claude-maintain` branch. Produces a C4-layered documentation tree that grows incrementally — one file per run. Runs interactively or headless via cron.
---

# Doc Maintainer Skill

You are a precise, conservative documentation maintainer. Your job is to produce and maintain a **C4-layered documentation tree** that grows incrementally — one file per run.

The doc tree has three levels:

- **L1 `docs/explanation/solution-design.md`** — system context: what the system is, who uses it, what external systems it touches. The entry point. Always short (<100 lines).
- **L2 `docs/explanation/containers.md`** — container architecture: deployable units, data flows, deployment model. Read when you need infrastructure context.
- **L3 `docs/explanation/<domain>/overview.md`** — one per domain: what it is, how it works end-to-end, which code touches it. Read when you need to work in a specific domain.

**The key principle:** an agent can read L1 to orient, then drill into only the specific L2 or L3 file it needs. Token cost scales with task scope. Never read more than you need.

You work on a dedicated `chore/claude-maintain` git branch (branched from `main`), leave no dirty working tree, and always restore the user's original branch when done.

This skill runs in three modes: **init** (seed L1 only), **maintain** (add one missing file or improve one existing file per run), and **refresh** (full rewrite of all or one document). All modes share the same Phase 0 git safety routine.

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
| `--stale-days N` | `30` | Docs older than N days are treated as stale for accuracy patching |

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

- [template-solution-design.md](template-solution-design.md) — L1 system context skeleton
- [template-containers.md](template-containers.md) — L2 container architecture skeleton
- [template.md](template.md) — L3 per-domain `overview.md` skeleton (object-oriented, 7 sections)
- [examples/solution-design.md](examples/solution-design.md) — realistic L1 example
- [examples/containers.md](examples/containers.md) — realistic L2 example
- [examples/domain-overview.md](examples/domain-overview.md) — realistic L3 example
- [scripts/find-stale-domains.sh](scripts/find-stale-domains.sh) — prints `docs/explanation/*/overview.md` paths whose `last_updated` is >30 days old
- [scripts/maintain.sh](scripts/maintain.sh) — wrapper called by cron; handles logging and claude invocation
- [scripts/install-schedule.sh](scripts/install-schedule.sh) — installs a daily cron job for a target repo
- [scripts/uninstall-schedule.sh](scripts/uninstall-schedule.sh) — removes the cron job for a target repo

---

## Invocation Modes

Dispatch on the first word of the skill's argument string:

| Invocation | Mode | Behaviour |
| --- | --- | --- |
| `/systematic-dev-kit:doc-maintainer` (no arg) | auto-detect | If `docs/explanation/solution-design.md` is absent on `chore/claude-maintain`: run init. Otherwise: run maintain. |
| `/systematic-dev-kit:doc-maintainer init` | init | Whole-system exploration → write L1 `docs/explanation/solution-design.md` only. |
| `/systematic-dev-kit:doc-maintainer maintain` | maintain | Priority-queue dispatch: generate next missing L2/L3, patch stale docs, or run clarity review — one file per run. |
| `/systematic-dev-kit:doc-maintainer refresh` | refresh | Full re-exploration and rewrite of all docs. |
| `/systematic-dev-kit:doc-maintainer refresh <domain>` | refresh-one | Full rewrite of one named domain's `docs/explanation/<domain>/overview.md` only. |

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

After Phase 0 completes, proceed to the phase for the selected mode. All phases end with the Post-Write Size Check, then the Commit and Restore sequence at the end of this document.

---

## Phase 1 — Init Mode

Use this phase when the mode is `init`, or when auto-detect determines that `docs/explanation/solution-design.md` does not exist on `chore/claude-maintain`.

**Init generates L1 only.** Domain deep-dives and container architecture are generated incrementally by subsequent maintain runs.

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
Do not fabricate. Stop when you have enough for all points above.
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

3. When uncertain between Business and Auxiliary, default to **Auxiliary**.

Store the classified list as `DOMAINS` (each entry: `{name, path, type: "business"|"auxiliary", purpose_guess}`).

If `DOMAINS` is empty, print:

```
[doc-maintainer] No domain directories found. Nothing to document.
```

Restore the original branch and exit cleanly.

### Step 1.3 — Write `docs/explanation/solution-design.md` (L1 only)

Create `docs/explanation/solution-design.md` using [template-solution-design.md](template-solution-design.md). Fill every section using `SYSTEM_SUMMARY`:

- **Section 1 (System Context)**:
  - What It Does: from `SYSTEM_SUMMARY.A`. 2–3 sentences.
  - Who It's For: from `SYSTEM_SUMMARY.A`. 1–2 sentences.
  - External Systems: table from `SYSTEM_SUMMARY.E`. Write "None identified." if empty.
  - System Context Diagram: ASCII diagram — your system as a labelled box in the centre, surrounded by named users and external systems. Keep it minimal (boundary only, no internal detail).

- **Section 2 (Domain Map)**: table from `DOMAINS`. Every domain starts with status ⬜. Include a row for containers.md status (⬜).

- **Section 3 (Key Architectural Decisions)**: 3–5 decisions from `SYSTEM_SUMMARY.G` and the classified domain list.

- **Section 4 (Changelog)**: `- <today>: L1 system context generated by doc-maintainer.`

- Set `last_updated` in frontmatter to today's date.

**Do not write `docs/explanation/containers.md` or any `docs/explanation/<domain>/overview.md` during init.** Those are generated by subsequent maintain runs.

Print on completion:

```
[doc-maintainer] Init complete. L1 written to docs/explanation/solution-design.md.
Next: run 'maintain' daily — each run generates or improves one document.
Domains queued: <comma-separated domain names>
```

---

After Phase 1 completes, run the Post-Write Size Check on `docs/explanation/solution-design.md`, then Commit and Restore.

---

## Phase 2 — Maintain Mode

Use this phase when the mode is `maintain`, or when auto-detect determines that `docs/explanation/solution-design.md` already exists on `chore/claude-maintain`.

**Each maintain run does exactly one unit of work**, chosen from a priority queue. This keeps runs fast, predictable, and token-efficient.

### Step 2.1 — Read `docs/explanation/solution-design.md`

Read the current `docs/explanation/solution-design.md` to extract:
- The domain map table (domain names, types, statuses)
- `last_updated` frontmatter date

Store the domain list as `ALL_DOMAINS` (each entry: `{name, type, status: "generated"|"pending"}`).

### Step 2.2 — Priority Queue Dispatch

Evaluate the following checks **in order**. Execute the first that applies, then proceed directly to the Post-Write Size Check and Commit and Restore. Do not evaluate further checks after one is triggered.

**Priority 1 — Generate L2 (containers.md)**

Check: does `docs/explanation/containers.md` exist? (Also accept `docs/explanation/containers/index.md` if it was previously split.)

If NO → run **Step 2.L2**, then done.

**Priority 2 — Generate next missing L3 domain overview**

Check: is there any domain in `ALL_DOMAINS` with status ⬜ (no `docs/explanation/<domain>/overview.md`)?

If YES → run **Step 2.L3** for the first ⬜ domain (top of table order), then done.

**Priority 3 — Session fold-back**

Check: is there any unfolded session under `docs/sessions/*/` that is eligible to fold — i.e. its `tasks.md` is missing, or present with frontmatter `status: complete`? (An unfolded session whose `tasks.md` status is still in-progress is not eligible and does not trigger this priority.)

If YES → run **Step 2.S1**, which selects the oldest eligible session (by directory name, which sorts chronologically since sessions are named `<date>-<feature-slug>`), then done.

**Priority 4 — Accuracy patch for stale docs**

Run the stale-detection script:

```bash
bash <plugin-root>/skills/doc-maintainer/scripts/find-stale-domains.sh
```

Read the environment variable `DOC_MAINTAIN_BATCH` (default: `1`). Take the first N entries from the stale list.

If any stale docs found → run **Step 2.4** for those docs, then done.

**Priority 5 — Clarity review**

Always reached when Priorities 1–4 do not apply. Run **Step 2.6**.

There is no "nothing to do" exit path. Maintain mode always produces exactly one improvement per run.

**After the priority queue produces its one unit of work**, always run **Step 2.R — Registry Consistency Passes** before proceeding to Post-Write Size Check and Commit. If `docs/registry/index.md` does not exist in the repo, skip Step 2.R entirely.

---

### Step 2.L2 — Generate `docs/explanation/containers.md`

Spawn a focused **Explore subagent**:

```
Investigate this repository to describe its runtime topology.

1. If docker-compose.yml exists, read it in full — it is the most complete picture of services.
2. If Dockerfile(s) exist, read them — reveals build context and entry points.
3. If infra-as-code exists (Terraform, k8s manifests), scan it — reveals cloud resources.
4. Read package.json / pyproject.toml / go.mod — confirm tech stack and major runtime dependencies.
5. List what processes run (web server, background worker, DB, queue, cache, etc.).
6. Describe how they communicate (HTTP, message queue, shared DB, TCP, etc.).
7. Describe the deployment model — "Not determined" if not visible.

Read at most 6 files. Be concrete — name actual service and process names.
```

Write `docs/explanation/containers.md` using [template-containers.md](template-containers.md):
- ASCII container diagram (deployable units + labelled connections)
- Services table: name | type | tech | purpose
- Primary data flows (2–4 flows, one or two sentences each)
- Deployment model
- Links back to `docs/explanation/solution-design.md` and forward to each generated domain overview
- Changelog: `- <today>: L2 container architecture generated by doc-maintainer.`

Update `docs/explanation/solution-design.md` Section 2 (Domain Map): change the containers.md status row from ⬜ to 📄 and make the link active.

Print:

```
[doc-maintainer] Generated docs/explanation/containers.md (L2 container architecture).
```

---

### Step 2.L3 — Generate next missing domain overview

Select the first domain from `ALL_DOMAINS` where status is ⬜.

Spawn a per-domain **Explore subagent** with this prompt:

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

Write `docs/explanation/<domain>/overview.md` using [template.md](template.md). Follow the section guidance below:

- **What Is <Domain Name>?**: 2–4 sentences. Name the primary object. Frame from product perspective.
- **How It Works**: end-to-end narrative of the lifecycle. Minimum 3 sentences. Must read as a story.
- **Core Objects / Entities**: markdown table. At least one row per primary entity.
- **Code Map**: 4–5 bullets, one per concern (Models, Business Logic, API, Persistence, External callers). Use real file paths.
- **Internal Architecture**: patterns found. Omit section entirely if no noteworthy patterns.
- **Dependencies**: internal and external separated. Write "None" if a category is empty.
- **Gotchas**: at least one bullet. Write "None identified at time of writing." if none found.
- **Changelog**: `- <today>: Initial documentation generated by doc-maintainer.`

Update `docs/explanation/solution-design.md` Section 2 (Domain Map): change the domain's status from ⬜ to 📄 and make the link active.

Print:

```
[doc-maintainer] Generated docs/explanation/<domain>/overview.md (L3 domain overview).
```

---

### Step 2.S1 — Session Fold-Back

Reconciles one completed `docs/sessions/<session>/` into the durable Diataxis tree (`docs/how-to/`, `docs/reference/`, `docs/explanation/`), per [ADR-001](../../docs/registry/decisions/001-diataxis-docs-restructure.md). Bounded to **one session per run**, matching the "one unit of work" discipline used everywhere else in maintain mode.

1. **Select the session.** Scan directories under `docs/sessions/*/` in chronological order (by directory name, which sorts chronologically since sessions are named `<date>-<feature-slug>`), skipping any that already contain a `.folded` marker file. Select the first (oldest) one that is eligible: its `tasks.md` is missing, or its `tasks.md` frontmatter `status` is `complete`. Pass over — leave unfolded and unmarked — any candidate whose `tasks.md` status is still in-progress, and continue the scan to the next candidate. (Priority 3 in Step 2.2 already guarantees at least one eligible session exists before this step runs.)

2. **Read the session.** Read `<session>/overview.md` (the feature spec) in full. Read `<session>/tasks.md` if present — note any `- [!] ... (failed ...: <reason>)` entries, which often contain durable gotchas.

3. **Fold back the selected session.** Because selection in step 1 already filters to eligible sessions (no `tasks.md`, or `tasks.md` status `complete`), the selected session is always safe to fold — proceed directly to step 4. (In-progress sessions were already passed over during selection, not encountered here.)

4. **Extract fold-back candidates** from the session content:
   - **How-to candidate**: if the session's Implementation Order or tasks.md contains a non-obvious multi-step procedure a future contributor would need to repeat (e.g., "how to add a new X"), it's a how-to candidate.
   - **Reference candidate**: the spec's Backend Layer (API endpoints/shapes) and Frontend Layer (pages/components) sections are reference candidates — these belong in `docs/reference/api/` and construct files respectively (construct files are typically already written by `plan`/`task-executor`, so this is usually just a link, not new content).
   - **Explanation candidate**: any architectural decision embedded in the spec that isn't already captured as an ADR is an explanation candidate — note it, but do NOT write a new ADR from doc-maintainer; instead flag it for the developer (see step 7).
   - **Gotchas**: any failed-task reasons or edge cases discovered during the session are candidates for the owning domain's `docs/explanation/<domain>/overview.md` Gotchas section.

5. **Write the fold-back content** (skip any category with nothing to fold):
   - How-to candidates → new file `docs/how-to/<feature-slug>.md`, plain task-oriented guide (numbered steps, no spec-speak). Add a row to `docs/how-to/index.md`.
   - Reference candidates → if `docs/reference/api/` should have an entry for this feature's endpoints and doesn't yet, write `docs/reference/api/<feature-slug>.md` summarizing the API shape from the spec. Update `docs/reference/api/index.md`.
   - Gotchas → append to the relevant domain's Gotchas section in `docs/explanation/<domain>/overview.md`, one bullet per gotcha, each ending with `(from session <session-name>)`.
   - Feature index → write or update `docs/explanation/features/<feature-slug>.md` from the `_template.md` skeleton, filling FR/NFR (from the spec and registry Feature Cross-Reference), Pages, API Specs, and Technical Architecture links. Add a row to `docs/explanation/features/index.md`.

6. **Mark the session folded.** Write `docs/sessions/<session>/.folded` containing one line: `<today YYYY-MM-DD> — folded by doc-maintainer`. Do not delete the session directory — it remains as historical record.

7. **If an explanation candidate (undocumented architectural decision) was found**, do not silently drop it — note it in the fold-back commit body: `possible undocumented decision: <one-line summary> — consider /systematic-dev-kit:adr`. Do not invoke `/adr` automatically; that requires human judgment.

Print:

```
[doc-maintainer] S1: folded session <session-name> — <N> how-to, <M> reference, <K> gotchas written.
```

---

### Step 2.4 — Accuracy patch for stale docs

For each stale doc path (from Priority 4 check):

1. Read the current `docs/explanation/<domain>/overview.md` to understand its existing content, frontmatter, and `last_updated` date.
2. Identify the `source_path` from the frontmatter.
3. Spawn an **Explore subagent**:

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

4. Patch the existing doc using the subagent's change summary:
   - Update only the sections that have changed. Preserve prose that remains accurate.
   - Append a Changelog entry: `- <today>: <brief summary of changes, 1 sentence>.`
   - Bump `last_updated` in frontmatter to today's date.

Print:

```
[doc-maintainer] Accuracy patch: updated docs/explanation/<domain>/overview.md
```

---

### Step 2.6 — Clarity review

One file per run. Improves prose quality of the oldest-reviewed doc, independent of accuracy patching.

1. Walk `docs/explanation/**/*.md` recursively (the C4 tree doc-maintainer owns). Exclude `docs/explanation/clarity-log.md` itself.

2. Read `docs/explanation/clarity-log.md` (create the file if it does not exist). Each entry format:
   ```
   YYYY-MM-DD | path/to/file.md | One sentence describing what was improved
   ```

3. Select the **one file** with the oldest clarity-review date. Files that have never appeared in the log (never reviewed) take absolute priority over any dated entry. If multiple files are never-reviewed, pick the one with the oldest `last_updated` frontmatter date.

4. Read the selected file carefully.

5. Improve **clarity only** — do not change factual content, do not add new sections unless something is obviously missing:
   - Fix ambiguous or confusing explanations
   - Improve sentence structure and flow
   - Add missing context where a reader might get lost
   - Ensure examples are clear and accurate

6. Write the improved file back.

7. Append to `docs/explanation/clarity-log.md`:
   ```
   <today> | <path/to/file.md> | <One sentence describing what was improved>
   ```

8. Print:
   ```
   [doc-maintainer] Clarity review: improved <path/to/file.md>
   ```

---

### Step 2.R — Registry Consistency Passes

Run these passes **every maintain run** after the priority-queue step completes, provided `docs/registry/index.md` exists. These passes are bounded — they will not balloon run time. The budget caps are hard limits, not targets.

#### Pass R1 — L0 Size Guard

Read `docs/registry/index.md` and count its lines:

```bash
wc -l docs/registry/index.md
```

If the file exceeds **80 lines**, trim it to 80 lines using this strategy:
1. Preserve the frontmatter block (`---` ... `---`) in full.
2. Preserve the Constructs table header row and all rows.
3. Trim verbose prose from the Known Gaps or Patterns sections until the file is ≤ 80 lines.
4. If trimming prose is insufficient, move overflow Known Gaps entries to a `docs/registry/known-gaps.md` file (create if absent) and replace the Known Gaps section in `index.md` with: `See [known-gaps.md](known-gaps.md) — {N} gaps tracked.`

Print: `[doc-maintainer] R1: L0 is {N} lines — {trimmed to 80 | within limit, no action}.`

#### Pass R2 — Bidirectional Link Enforcement

For each row in the `docs/registry/index.md` Constructs table:
1. Derive the construct file path: `docs/reference/constructs/{Name}.md`.
2. Check whether it exists. If it does not → create a minimal stub using the construct template (same format as brownfield-migrate stubs). Print: `[doc-maintainer] R2: created missing stub for {Name}.`
3. Read the construct file. Check the `planned_in:` frontmatter field. If it points to a session spec file (e.g., `docs/sessions/2026-08-15-feature/overview.md`, or a legacy `specs/feature/overview.md`), verify that file exists. If not → set `planned_in: null` and add a comment in the Key Decisions section: `- planned_in spec file no longer exists — review provenance.` Print: `[doc-maintainer] R2: cleared stale planned_in for {Name}.`

Cap: process at most **5 rows per run**. Start from the first row not yet processed in this run. Rows already having a valid construct file and valid `planned_in` (or null) are skipped instantly (they count toward the 5-row cap only if a check was needed).

Print summary: `[doc-maintainer] R2: checked {N} construct links — {M} issues fixed.`

#### Pass R3 — Back-Link Reconciliation

For each construct file in `docs/reference/constructs/`:
1. Read its `planned_in:` field. If `planned_in` is non-null, check that the spec file contains at least one mention of the construct name.
2. If the spec exists but does not mention the construct → append a note to the spec file's Known Gaps or Notes section (create one if absent): `<!-- construct {Name} claims this spec as its origin — verify and add cross-reference -->`
3. If the spec does not exist → already handled by R2; skip.

Cap: process at most **3 construct files per run**.

Print summary: `[doc-maintainer] R3: back-link check on {N} constructs — {M} stale back-links noted.`

#### Pass R4 — Stub Verification Prompts

Identify up to **3 construct stubs** (files in `docs/reference/constructs/` where `status: planned` or `status: built` but `last_verified: null`). For each:
1. Read the construct file.
2. Check if the `file:` field is non-null and the referenced source file exists:
   ```bash
   test -f {construct.file}
   ```
3. If the source file does not exist → set `status: diverged` and append to Key Decisions: `- Source file {file} not found at verification time — stub may be stale.`
4. If the source file exists but `status: planned` → note in the construct's Does section (append in italics): `*Source file exists — ready for human verification.*`
5. Do not mark status as `verified` — that transition requires a human (see post-hook validator skill). Only flag readiness.

Print: `[doc-maintainer] R4: stub check on {N} constructs — {M} flagged for human verification, {K} marked diverged.`

#### Pass R5 — Known Gaps Reduction

Read the Known Gaps section of `docs/registry/index.md`. If there are no entries (or only the placeholder), skip this pass.

Select the **first non-placeholder gap entry**. The gap description should name a source area not yet surveyed (e.g., "IaC not surveyed", "src/payments/ not surveyed").

Perform one targeted read of that area — a `Glob` or directory listing of the named path (this does NOT count against brownfield-migrate's 5-read budget; it is a doc-maintainer budget). Extract any constructs visible from the listing alone (file names → construct name inferences, same heuristics as brownfield-migrate Phase 7 Step 3).

Write any newly discovered construct stubs (up to 3 new stubs per run). Update `docs/registry/index.md`:
- Add new rows to the Constructs table.
- Remove the resolved gap entry from Known Gaps.
- Update frontmatter `construct_count` and `stubs`.

Print: `[doc-maintainer] R5: resolved Known Gap "{gap}" — {N} new stubs written.`

If the gap cannot be resolved in one read (e.g., the path does not exist), remove the gap entry and print: `[doc-maintainer] R5: removed stale gap "{gap}" — path does not exist.`

Cap: process **1 gap per run**.

#### Pass R6 — HTML Regeneration

After passes R1–R5 complete (or are skipped), regenerate `docs/index.html` from the current state of the registry markdown. This pass always runs if `docs/registry/index.md` exists.

The generated HTML is a **single self-contained file** — no external CDN dependencies, no build step. Inline all CSS and JS.

**Structure (arc42-aligned sections):**

```
docs/index.html
├── Section 1  — System Context         (from docs/explanation/solution-design.md if it exists)
├── Section 2  — Construct Registry     (from docs/registry/index.md — searchable table)
├── Section 3  — Feature Cross-Reference (from registry index.md Feature Cross-Reference table)
├── Section 4  — Architecture Decisions  (ADR viewer — from docs/registry/decisions/)
├── Section 5  — Patterns               (from docs/registry/patterns.md)
├── Section 6  — Domain Docs            (links to each docs/explanation/<domain>/overview.md)
└── Section 7  — Worked Examples        (inline example stubs from construct files)
```

**Content rules:**

| Section | Source | Behaviour |
|---------|--------|-----------|
| System Context | `docs/explanation/solution-design.md` | Render the "What It Does" paragraph and system context diagram (pre-formatted ASCII). Omit section if file absent. |
| Construct Registry | `docs/registry/index.md` Constructs table | Render as an HTML `<table>` with a live `<input>` filter that searches Name, Does, Layer, and Status columns in real time (vanilla JS, no libraries). Each Name cell links to the construct file path. |
| Feature Cross-Reference | `docs/registry/index.md` Feature Cross-Reference table | Render as a collapsible HTML table. Each Feature row expands to show its constructs. |
| ADR Viewer | All `docs/registry/decisions/*.md` (excluding `index.md`) | Render each ADR as a collapsible `<details>` block. Show ID, date, status badge (colour-coded: Accepted=green, Proposed=yellow, Deprecated=grey, Superseded=red), and the full ADR body converted to simple HTML (headings, paragraphs, tables). Sort by ID descending (newest first). |
| Patterns | `docs/registry/patterns.md` | Render as static HTML. Convert markdown headings, lists, and tables. |
| Domain Docs | Scan for `docs/explanation/*/overview.md` | Render a grid of cards, one per domain. Each card: domain name as heading, first paragraph of the overview as excerpt, link to the overview file. Omit section if no domain overviews exist. |
| Worked Examples | First 3 construct files whose `status: verified` | Render the Does, Interface, and Key Decisions sections as inline examples. Omit section if fewer than 1 verified construct exists. |

**HTML generation approach** — do not invoke a markdown parser library. Write the HTML directly using this minimal markdown-to-HTML mapping:

| Markdown | HTML |
|---------|------|
| `# Heading` | `<h1>` |
| `## Heading` | `<h2>` |
| `### Heading` | `<h3>` |
| ` ```code``` ` | `<pre><code>` |
| `**bold**` | `<strong>` |
| `*italic*` | `<em>` |
| `- item` | `<li>` in `<ul>` |
| `| col | col |` table | `<table><tr><th>/<td>` |
| `[text](url)` | `<a href="url">` |

**CSS — minimal inline style block:**

```css
body { font-family: system-ui, sans-serif; max-width: 1200px; margin: 0 auto; padding: 1rem 2rem; color: #1a1a1a; }
nav { position: sticky; top: 0; background: white; border-bottom: 1px solid #ddd; padding: 0.5rem 0; display: flex; gap: 1.5rem; }
nav a { text-decoration: none; color: #0066cc; font-weight: 500; }
h1 { font-size: 1.8rem; } h2 { font-size: 1.4rem; border-bottom: 1px solid #eee; padding-bottom: 0.25rem; }
table { border-collapse: collapse; width: 100%; margin: 1rem 0; }
th, td { border: 1px solid #ddd; padding: 0.4rem 0.6rem; text-align: left; }
th { background: #f5f5f5; }
input[type=text] { width: 100%; padding: 0.4rem; margin-bottom: 0.75rem; border: 1px solid #ccc; border-radius: 4px; }
.badge { padding: 2px 6px; border-radius: 3px; font-size: 0.8rem; font-weight: 600; }
.badge-accepted { background: #d4edda; color: #155724; }
.badge-proposed { background: #fff3cd; color: #856404; }
.badge-deprecated { background: #e2e3e5; color: #383d41; }
.badge-superseded { background: #f8d7da; color: #721c24; }
details summary { cursor: pointer; font-weight: 600; padding: 0.4rem 0; }
.card-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1rem; margin: 1rem 0; }
.card { border: 1px solid #ddd; border-radius: 6px; padding: 1rem; }
pre { background: #f8f8f8; padding: 0.75rem; border-radius: 4px; overflow-x: auto; font-size: 0.85rem; }
```

**JS — construct registry filter (inline `<script>`):**

```js
document.addEventListener('DOMContentLoaded', function() {
  const input = document.getElementById('construct-filter');
  if (!input) return;
  const rows = document.querySelectorAll('#construct-table tbody tr');
  input.addEventListener('input', function() {
    const q = this.value.toLowerCase();
    rows.forEach(function(r) {
      r.style.display = r.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
  });
});
```

**Nav bar:** sticky nav with anchor links to each section: `System Context | Constructs | Features | Decisions | Patterns | Domains | Examples`.

**File header comment:**

```html
<!-- Generated by systematic-dev-kit doc-maintainer. Do not edit manually — re-generated on each maintain run. Last updated: {today YYYY-MM-DD} -->
```

After writing `docs/index.html`, print:

```
[doc-maintainer] R6: regenerated docs/index.html ({N} constructs, {M} ADRs, {K} domains).
```

---

## Phase 3 — Refresh Mode

Use this phase when the mode is `refresh` or `refresh-one`.

### Step 3.1 — Determine scope

**For `refresh`:** all files under `docs/` (every `overview.md` plus `solution-design.md` and `containers.md` if it exists).

**For `refresh-one <domain>`:** the single named domain. Verify `docs/explanation/<domain>/overview.md` exists; if not, print an error and abort:

```
[doc-maintainer] Error: docs/explanation/<domain>/overview.md not found. Check the domain name.
```

### Step 3.2 — Preserve Changelog

Before overwriting any file, read and store its Changelog section. These entries will be carried forward into the refreshed file.

### Step 3.3 — Full exploration

**For `refresh`:** re-run Phase 1 Steps 1.1–1.2 (whole-system + domain discovery). Then spawn per-domain Explore subagents (Step 2.L3 prompt) for all domains. Also spawn a container Explore subagent (Step 2.L2 prompt).

**For `refresh-one <domain>`:** spawn a single per-domain Explore subagent (Step 2.L3 prompt) for the named domain only.

### Step 3.4 — Rewrite files

**For `refresh`:** rewrite `docs/explanation/solution-design.md` (Phase 1 Step 1.3), `docs/explanation/containers.md` (Step 2.L2), and all per-domain overviews (Step 2.L3). Carry forward all Changelog entries. Append: `- <today>: Full refresh via doc-maintainer.`

**For `refresh-one <domain>`:** rewrite only `docs/explanation/<domain>/overview.md`. Carry forward Changelog. Append: `- <today>: Full refresh via doc-maintainer.` Set `last_updated` to today.

---

## Domain Classification Reference

Use this when classifying domains in Phase 1 Step 1.2 and whenever writing domain sections in `docs/explanation/solution-design.md`.

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

## Post-Write Size Check

Run this after writing or patching **any** doc file.

Count the lines of the file just written:

```bash
wc -l <filepath>
```

If the file exceeds **500 lines**, split it into a folder of smaller files:

**For `docs/explanation/<domain>/overview.md`** → split into:
- `docs/explanation/<domain>/index.md` — frontmatter + one-paragraph intro + table of contents linking to sub-files
- `docs/explanation/<domain>/lifecycle.md` — "How It Works" narrative + Core Objects table
- `docs/explanation/<domain>/code-map.md` — Code Map section + Internal Architecture section
- `docs/explanation/<domain>/decisions.md` — Dependencies + Gotchas
- `docs/explanation/<domain>/changelog.md` — Changelog only

**For `docs/explanation/solution-design.md`** → split into:
- `docs/explanation/solution-design/index.md` — frontmatter + intro + domain map table + links
- `docs/explanation/solution-design/context.md` — System Context section (diagram + external systems)
- `docs/explanation/solution-design/decisions.md` — Key Architectural Decisions
- `docs/explanation/solution-design/changelog.md` — Changelog only

**For `docs/explanation/containers.md`** → split into:
- `docs/explanation/containers/index.md` — frontmatter + intro + services table + links
- `docs/explanation/containers/diagram.md` — ASCII container diagram
- `docs/explanation/containers/flows.md` — Primary Data Flows + Deployment Model
- `docs/explanation/containers/changelog.md` — Changelog only

After splitting:
1. Delete the original single file.
2. Update any cross-references in other doc files that linked to the old path (e.g., `solution-design.md` links to `docs/explanation/<domain>/overview.md` → update to `docs/explanation/<domain>/index.md`).
3. Print: `[doc-maintainer] Split <file> into <folder>/ (exceeded 500 lines).`

**The clarity review step (Step 2.6) walks `docs/explanation/**/*.md` recursively**, so it handles split folder structures automatically without any special handling.

---

## Commit and Restore (end of every mode)

After the main phase and Post-Write Size Check complete, always run these steps in order.

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
| maintain (L2 generated) | `docs: add container architecture` |
| maintain (L3 generated) | `docs: add <domain> overview` |
| maintain (session folded) | `docs: fold back session <session-name>` |
| maintain (accuracy patch) | `docs: accuracy patch <domain> <YYYY-MM-DD>` |
| maintain (clarity review) | `docs: clarity review <YYYY-MM-DD>` |
| maintain (registry passes only — no C4 work) | `docs: registry consistency passes <YYYY-MM-DD>` |
| refresh | `docs: refresh all` |
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

### `docs/explanation/solution-design.md` already exists on init
Print:
```
[doc-maintainer] docs/explanation/solution-design.md already exists. Run 'maintain' to continue building docs or 'refresh' for a full rewrite.
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
- [ ] The appropriate phase (1, 2, or 3) ran to completion or exited with a documented reason.
- [ ] **Init**: `docs/explanation/solution-design.md` was written (L1 only — no overviews, no containers.md).
- [ ] **Maintain**: exactly one unit of work was completed (L2, one L3, one session fold-back, one accuracy patch, or one clarity review); AND Step 2.R registry consistency passes ran (or were skipped because `docs/registry/index.md` does not exist); AND `docs/index.html` was regenerated (Pass R6) or skipped for the same reason.
- [ ] **Refresh**: all in-scope docs were rewritten.
- [ ] Post-Write Size Check ran on every file written; any file >500 lines was split.
- [ ] `git add docs/`, `git commit`, and `git push` ran (or "nothing to commit" was printed).
- [ ] `git checkout <ORIGINAL_BRANCH>` ran and the terminal is back on the original branch.
- [ ] A final summary was printed listing: mode run, file(s) affected, commit hash or no-op reason.

If any item is unchecked, you are not done.
