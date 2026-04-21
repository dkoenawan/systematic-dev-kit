---
name: doc-maintainer
description: Initialise, maintain, and refresh a codebase's docs/ tree on a dedicated `docs` branch. Runs interactively or headless via systemd timer.
---

# Doc Maintainer Skill

You are a precise, conservative documentation maintainer. Your job is to keep a living `docs/` tree accurate and up to date — not to rewrite things that don't need rewriting. You work on a dedicated `docs` git branch, leave no dirty working tree, and always restore the user's original branch when done.

This skill runs in three modes: **init** (seed fresh docs), **maintain** (incremental daily updates to stale domains), and **refresh** (full rewrite of all or one domain). All modes share the same Phase 0 git safety routine.

## Scheduling (Automated Daily Runs)

The skill ships with a systemd user timer that runs `maintain` mode headlessly once per day.

### Installation

```bash
# The server runs UTC. Specify the time in UTC (e.g. 13:00 UTC = 01:00 NZST).
XDG_RUNTIME_DIR=/run/user/$(id -u) \
  bash /path/to/systematic-dev-kit/skills/doc-maintainer/scripts/install-schedule.sh \
  /absolute/path/to/your-repo --time 13:00
```

`XDG_RUNTIME_DIR` must be set explicitly — it is often absent in non-login shells (e.g. SSH sessions, VS Code terminals). Without it, `systemctl --user` cannot reach the D-Bus socket and exits with `Failed to connect to bus: No medium found`.

### Uninstall

```bash
XDG_RUNTIME_DIR=/run/user/$(id -u) \
  bash /path/to/systematic-dev-kit/skills/doc-maintainer/scripts/uninstall-schedule.sh \
  /absolute/path/to/your-repo
```

### Checking status / logs

```bash
# Timer next-fire time
XDG_RUNTIME_DIR=/run/user/$(id -u) systemctl --user list-timers "doc-maintainer*"

# Last run logs
XDG_RUNTIME_DIR=/run/user/$(id -u) journalctl --user \
  -u "doc-maintainer@$(systemd-escape /absolute/path/to/your-repo).service" \
  -n 50 --no-pager
```

### Known issues

**`WorkingDirectory=%i` vs `%I`**  
systemd template units use `%i` for the *escaped* instance name and `%I` for the *unescaped* (decoded) path. `WorkingDirectory=` requires an absolute path, so it must use `%I`. Earlier versions of the service template incorrectly used `%i`, causing the unit to refuse to start with `path is not absolute`. The install script generates `WorkingDirectory=%I` — if you have a service file from before this fix, re-run `install-schedule.sh` to regenerate it.

**`claude` not on PATH under systemd**  
systemd does not source the user's shell profile, so `~/.local/bin` (where `claude` lives) is not on `PATH`. The service uses `/bin/bash -lc` (login shell) to load the profile and resolve `claude`. If `claude` is installed somewhere non-standard, update the `ExecStart` line in `~/.config/systemd/user/doc-maintainer@.service`.

---

## Supporting Files

- [template.md](template.md) — the per-domain `overview.md` skeleton. Fill every field when generating a new doc page.
- [examples/index.md](examples/index.md) — a realistic example of what `docs/index.md` looks like after init.
- [scripts/find-stale-domains.sh](scripts/find-stale-domains.sh) — pure bash script that prints domain paths whose `last_updated` is >30 days old.
- [scripts/install-schedule.sh](scripts/install-schedule.sh) — installs a systemd user timer to run maintain mode daily on a target repo.
- [scripts/uninstall-schedule.sh](scripts/uninstall-schedule.sh) — removes the systemd timer for a target repo.

---

## Invocation Modes

Dispatch on the first word of the skill's argument string:

| Invocation                                            | Mode         | Behaviour                                                                          |
| ----------------------------------------------------- | ------------ | ---------------------------------------------------------------------------------- |
| `/systematic-dev-kit:doc-maintainer` (no arg)         | auto-detect  | If `docs/` is absent on the `docs` branch: run init. Otherwise: run maintain.     |
| `/systematic-dev-kit:doc-maintainer init`             | init         | Scan repo, build domain list, seed one `overview.md` per domain + `docs/index.md`. |
| `/systematic-dev-kit:doc-maintainer maintain`         | maintain     | Pick the N stalest domains (>30 days old), update them incrementally.              |
| `/systematic-dev-kit:doc-maintainer refresh`          | refresh      | Full re-scan of every domain; rewrite all pages in a single commit.                |
| `/systematic-dev-kit:doc-maintainer refresh <dir>`   | refresh-one  | Full re-scan of a single named domain directory only.                              |

**Flag:** `--force` may be appended to any invocation to bypass the dirty-tree guard. Do not use it yourself unless the user explicitly passed it — it exists so unattended timer runs can override a stale flag from a prior interrupted run.

**Reading the argument:** The skill argument string is everything after the skill name. Parse with:

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
git fetch
```

Ignore fetch errors (the repo may be offline or have no remote configured) — log the error but continue.

### Step 0.5 — Checkout or create the `docs` branch

Check whether the `docs` branch exists:

```bash
git show-ref --verify --quiet refs/heads/docs
```

**If it exists:** checkout:

```bash
git checkout docs
```

**If it does not exist:** create it branching from the current HEAD (not orphan — keep shared history so `git log docs/<domain>/overview.md` is meaningful):

```bash
git checkout -b docs
```

Print:

```
[doc-maintainer] Created new docs branch from HEAD.
```

### Step 0.6 — Verify you are on the `docs` branch

Run `git rev-parse --abbrev-ref HEAD` and confirm it equals `docs`. If not, abort with a clear error.

---

After Phase 0 completes, proceed to the phase for the selected mode. Phases 1, 2, and 3 each end with a commit-and-restore sequence described at the end of this document.

---

## Phase 1 — Init Mode

Use this phase when the mode is `init`, or when auto-detect determines that `docs/` does not exist on the `docs` branch.

### Step 1.1 — Determine domain directories

Locate domain directories as follows:

1. If `src/` exists at the repo root, treat the **top-level subdirectories of `src/`** as domain candidates.
2. Otherwise, treat the **top-level subdirectories of the repo root** as domain candidates.

**Always exclude these regardless of location:**

```
.git  node_modules  dist  build  .venv  docs  tests
```

Also exclude any entry that is not a directory (files at root level are not domains).

Run a directory listing to collect the candidates. Store as `DOMAINS` list.

If `DOMAINS` is empty, print:

```
[doc-maintainer] No domain directories found. Nothing to document.
```

Restore the original branch (see end of document) and exit cleanly.

### Step 1.2 — Explore each domain

For each directory in `DOMAINS`, spawn an **Explore subagent** with the following prompt:

```
Investigate the directory '<domain-path>' in this repository. Produce a structured summary covering:
1. Purpose — what this domain does in one or two sentences.
2. Key files — the 3-5 most important files with a one-line note on each.
3. Public interface — exported functions, classes, API routes, or CLI entry points.
4. Dependencies — which other domains or external packages this domain depends on.
5. Gotchas — non-obvious constraints, known issues, or things that trip up new contributors.

Be specific and concrete. Do not describe the whole repo — only this directory.
```

Collect the subagent summaries. Each summary maps to one domain.

### Step 1.3 — Generate `docs/index.md`

Create `docs/index.md` with the following structure:

```markdown
# <Repo name> — Documentation Index

> Auto-generated by `/systematic-dev-kit:doc-maintainer`. Last updated: <YYYY-MM-DD>.

## Overview

<Two to four sentences describing the overall purpose of this codebase, synthesised from the domain summaries.>

## Domains

| Domain | Path | Description |
| ------ | ---- | ----------- |
| [<domain>](./<domain>/overview.md) | `<source_path>` | <one-line purpose> |
| ... | | |
```

The date is today's date (format: `YYYY-MM-DD`). The repo name comes from `git rev-parse --show-toplevel | xargs basename`.

### Step 1.4 — Generate `docs/<domain>/overview.md` for each domain

For each domain in `DOMAINS`, create `docs/<domain>/overview.md` using the structure from [template.md](template.md). Fill in every section using the subagent summary from Step 1.2.

**Frontmatter fields:**

- `domain`: the directory name (e.g., `auth`)
- `last_updated`: today's date in `YYYY-MM-DD` format
- `source_path`: the path relative to repo root (e.g., `src/auth` or `auth`)

**Section guidance:**

- **Purpose**: 2-4 sentences. What this domain does and why it exists.
- **Key files**: a bulleted list, one item per key file, format `- \`path/to/file\` — what it does`.
- **Public interface**: exported symbols, API endpoints, or CLI commands. Use code blocks where helpful.
- **Dependencies**: internal deps (other domains) and external packages. Separate with sub-headings if both present.
- **Gotchas**: bullet list of non-obvious facts. If none were found, write "None identified at time of writing."
- **Changelog**: one entry: `- <YYYY-MM-DD>: Initial documentation generated by doc-maintainer.`

Do not leave any section empty. Write "Not applicable" if genuinely nothing belongs there.

---

## Phase 2 — Maintain Mode

Use this phase when the mode is `maintain`, or when auto-detect determines that `docs/` already exists on the `docs` branch.

Maintain mode is the **daily incremental update path**. It is designed to do as little work as necessary: pick the stalest domains, update only them, and exit. On days when nothing is stale, it exits with a no-op message — this is the expected and correct behaviour.

### Step 2.1 — Find stale domains

Run the stale-detection script from the repo root:

```bash
bash <plugin-root>/skills/doc-maintainer/scripts/find-stale-domains.sh
```

Where `<plugin-root>` is the directory of this plugin (available as `$CLAUDE_PLUGIN_ROOT` in the execution environment).

Capture stdout. Each line is a path to a stale `overview.md` file (e.g., `docs/auth/overview.md`), sorted oldest-first.

**If the output is empty** (no stale domains), print:

```
[doc-maintainer] No stale docs found. Nothing to do.
```

Restore original branch and exit 0. This is the normal no-op path for the daily timer — do not treat it as an error.

### Step 2.2 — Select domains to update

Read the environment variable `DOC_MAINTAIN_BATCH` (default: `1`). Take the first `N` entries from the stale list.

Print:

```
[doc-maintainer] Updating <N> domain(s): <domain names>
```

### Step 2.3 — Incremental update for each selected domain

For each selected domain path:

1. Read the current `docs/<domain>/overview.md` to understand its existing content, frontmatter, and the `last_updated` date.

2. Identify the `source_path` from the frontmatter to know where the source code lives.

3. Spawn an **Explore subagent** with the following prompt:

   ```
   The documentation for '<domain>' was last updated on <last_updated>.
   
   Investigate the directory '<source_path>' and produce a change summary covering:
   1. What has changed or been added since <last_updated>? (new files, deleted files, renamed exports, changed behaviour)
   2. Are any statements in the existing doc now inaccurate? List them specifically.
   3. Are there new gotchas, dependencies, or interface changes not reflected in the doc?
   
   Be specific. Only report changes — do not re-describe things that haven't changed.
   ```

4. Using the subagent's change summary, **patch** the existing doc:
   - Update only the sections that have changed. Do not rewrite sections that are still accurate.
   - Append a new entry to the **Changelog** section: `- <today>: <brief summary of what changed, 1 sentence>`.
   - Bump `last_updated` in the frontmatter to today's date.

   The goal is a minimal, targeted patch — not a full rewrite. Preserve the author's prose where it remains accurate.

---

## Phase 3 — Refresh Mode

Use this phase when the mode is `refresh` or `refresh-one`.

Refresh mode does a **full rewrite** — it re-investigates each domain from scratch and regenerates the doc page. It is intended for use after large refactors where incremental patching would be inadequate.

### Step 3.1 — Determine scope

**For `refresh`:** all domains in `docs/*/` (every directory under `docs/` that contains an `overview.md`).

**For `refresh-one <dir>`:** the single named domain. Verify the directory exists at `docs/<dir>/overview.md`; if not, print an error and abort:

```
[doc-maintainer] Error: docs/<dir>/overview.md not found. Check the domain name.
```

### Step 3.2 — Explore each domain in scope

For each domain, spawn an **Explore subagent** using the same prompt as Phase 1 Step 1.2.

### Step 3.3 — Rewrite each domain's overview

For each domain, rewrite `docs/<domain>/overview.md` from scratch using [template.md](template.md), filling in every section with the fresh subagent summary.

**Preserving manual edits:** Before overwriting, read the existing file and identify any Changelog entries. Carry all existing Changelog entries forward into the new file. Append a new entry: `- <today>: Full refresh via doc-maintainer.`

Set `last_updated` to today's date.

### Step 3.4 — Update `docs/index.md`

Rewrite `docs/index.md` using the same format as Phase 1 Step 1.3, reflecting the current domain list. If any domains were added or removed from `docs/` since init, the table should reflect the current state.

---

## Commit and Restore (end of every mode)

After the main phase completes, always run these steps in order:

### Commit

Stage all changes under `docs/`:

```bash
git add docs/
```

Check if there is anything to commit:

```bash
git diff --cached --quiet
```

If the diff is empty (nothing staged), print:

```
[doc-maintainer] Nothing to commit.
```

Otherwise, commit with the appropriate conventional message:

| Mode         | Commit message                                            |
| ------------ | --------------------------------------------------------- |
| init         | `docs: init`                                              |
| maintain     | `docs: daily maintenance <YYYY-MM-DD>`                    |
| refresh      | `docs: refresh all domains`                               |
| refresh-one  | `docs: refresh <domain>`                                  |

Run:

```bash
git commit -m "<message>"
```

### Restore original branch

```bash
git checkout <ORIGINAL_BRANCH>
```

Print:

```
[doc-maintainer] Done. Restored branch: <ORIGINAL_BRANCH>
```

If the restore fails (e.g., the original branch was deleted), print a clear warning:

```
[doc-maintainer] Warning: could not restore original branch '<ORIGINAL_BRANCH>'. You are currently on docs.
```

Do not abort on restore failure — the doc work is already committed.

---

## Error Handling

### git checkout docs fails

If `git checkout docs` fails (e.g., due to conflict with local changes), and `--force` was not set:

```
[doc-maintainer] Error: could not checkout docs branch. Working tree may have conflicts.
Run with --force or resolve conflicts manually, then try again.
```

Abort without modifying any files.

### Explore subagent returns no useful content

If the Explore subagent returns an empty or clearly insufficient summary for a domain, log a warning:

```
[doc-maintainer] Warning: Explore returned insufficient content for '<domain>'. Skipping this domain.
```

Continue with other domains. Do not abort the entire run.

### `docs/` already exists on init

If `docs/index.md` already exists when running init, print:

```
[doc-maintainer] docs/index.md already exists. Run 'maintain' to update stale pages or 'refresh' for a full rewrite.
```

Restore the original branch and exit without writing anything.

### No git repository

If `git status` fails entirely (not a git repo), abort immediately:

```
[doc-maintainer] Error: current directory is not a git repository. Run this skill from within a git repo.
```

---

## Skill Completion Gate

Do not consider this skill complete until ALL of the following are true:

- [ ] Phase 0 ran completely: dirty-tree check, branch recorded, fetch attempted, on `docs` branch.
- [ ] The appropriate phase (1, 2, or 3) ran to completion or exited with a documented no-op reason.
- [ ] All generated or patched files were written to disk under `docs/`.
- [ ] `git add docs/` and `git commit` ran (or "nothing to commit" was printed).
- [ ] `git checkout <ORIGINAL_BRANCH>` ran and the terminal is back on the original branch.
- [ ] A final summary was printed listing: mode run, domains affected, commit hash (or no-op reason).

If any item is unchecked, you are not done.
