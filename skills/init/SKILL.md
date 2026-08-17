---
name: init
description: Initialize a new full-stack project from a template repository with opt-out component selection. Also supports brownfield-migrate mode to seed an architecture registry from an existing codebase.
---

# Init Skill

This skill creates a new full-stack project by cloning a pre-built template repository. It uses a simple opt-out approach - you get the full stack by default and only need to specify what you DON'T want.

## What This Skill Does

1. **Clones the template repository** - Fast, token-efficient project scaffolding
2. **Asks simple opt-out questions** - Only answer if you want to REMOVE something
3. **Removes unwanted components** - Deletes directories and updates configs
4. **Configures the project** - Updates names, docker-compose.yml, package.json
5. **Brownfield-migrate mode** - Seeds an architecture registry from an existing codebase (run with `brownfield-migrate` argument)

## Default Stack (Opinionated)

| Component | Technology |
|-----------|------------|
| Frontend | React + Vite + TypeScript |
| Backend | Node.js + TypeScript + Prisma |
| Database | PostgreSQL |
| Infrastructure | Docker with docker-compose |

## Usage

```bash
/compass:init                         # Greenfield: scaffold a new project
/compass:init brownfield-migrate      # Brownfield: seed registry from existing codebase
```

## Project Structure Created

```
{project-name}/
├── frontend/                  # React + Vite + TypeScript
│   ├── package.json
│   ├── vite.config.ts
│   ├── tsconfig.json
│   ├── Dockerfile
│   └── src/
│       ├── main.tsx
│       ├── App.tsx
│       └── components/
├── backend/                   # Node.js + TypeScript + Prisma
│   ├── package.json
│   ├── tsconfig.json
│   ├── Dockerfile
│   ├── prisma/
│   │   └── schema.prisma
│   └── src/
│       ├── index.ts
│       └── server.ts
├── database/                  # PostgreSQL configuration
│   └── init.sql
├── docker-compose.yml         # Full stack orchestration
├── package.json               # Workspaces root
└── README.md                  # Project documentation
```

## Mode Dispatch

Parse the invocation argument:

| Argument | Mode |
|---|---|
| (none) | Greenfield — scaffold a new project (Phases 1–6) |
| `brownfield-migrate` | Brownfield migrate — seed registry from existing codebase (Phase 7) |

If `brownfield-migrate` is the argument, skip Phases 1–6 entirely and go to **Phase 7**.

---

## Instructions for Claude Code

When this skill is invoked in **greenfield mode**, follow this exact sequence:

### Phase 1: Gather Project Basics

Use AskUserQuestion to ask for project basics:

**Question 1: Project Name**
- Header: "Project name"
- Question: "What should the project be called?"
- Options:
  - "my-project" (description: "Use default project name")
  - "Custom name" (description: "Enter a custom project name")

If user selects "Custom name", ask them to type the name.

**Question 2: Target Directory**
- Header: "Directory"
- Question: "Where should the project be created?"
- Options:
  - "./{project-name}" (description: "Create in a new subdirectory (Recommended)")
  - "Current directory" (description: "Initialize in the current working directory")
  - "Custom path" (description: "Specify a different location")

### Phase 2: Component Selection (Opt-Out)

Use AskUserQuestion with multiSelect: true:

**Question 3: Exclude Components**
- Header: "Components"
- Question: "Which components do you want to EXCLUDE? (Select none to keep everything)"
- multiSelect: true
- Options:
  - "Frontend" (description: "Remove React + Vite + TypeScript frontend")
  - "Backend" (description: "Remove Node.js + Prisma backend")
  - "Database" (description: "Remove PostgreSQL database")

Default behavior: User selects NOTHING = keep everything (full stack)

### Phase 3: Setup Options

Use AskUserQuestion:

**Question 4: Git Initialization**
- Header: "Git"
- Question: "Initialize a git repository?"
- Options:
  - "Yes" (description: "Run git init and create initial commit (Recommended)")
  - "No" (description: "Skip git initialization")

**Question 5: Install Dependencies**
- Header: "Dependencies"
- Question: "Install npm dependencies now?"
- Options:
  - "No" (description: "Skip installation, run npm install later (Recommended)")
  - "Yes" (description: "Run npm install in all workspaces")

### Phase 4: Execute Setup

After collecting all answers, execute the following steps:

#### Step 1: Clone Template Repository

```bash
git clone --depth 1 git@github.com:dkoenawan/dev-kit-scaffolding.git {target-directory}
```

If clone fails (e.g., SSH not configured), try HTTPS:
```bash
git clone --depth 1 https://github.com/dkoenawan/dev-kit-scaffolding.git {target-directory}
```

#### Step 2: Remove Template Git History

```bash
cd {target-directory}
rm -rf .git
```

#### Step 3: Remove Excluded Components

For each component the user chose to EXCLUDE:

**If Frontend excluded:**
```bash
rm -rf frontend/
```

**If Backend excluded:**
```bash
rm -rf backend/
```

**If Database excluded:**
```bash
rm -rf database/
```

#### Step 4: Update docker-compose.yml

Read the docker-compose.yml file and remove services for excluded components:

- If Frontend excluded: Remove the `frontend` service
- If Backend excluded: Remove the `backend` service
- If Database excluded: Remove the `db` service and any `depends_on: db` references

Write the updated docker-compose.yml.

#### Step 5: Update package.json Workspaces

Read the root package.json and update the `workspaces` array:

- If Frontend excluded: Remove `"frontend"` from workspaces
- If Backend excluded: Remove `"backend"` from workspaces

Write the updated package.json.

#### Step 6: Replace Project Name Placeholders

Find and replace `{{PROJECT_NAME}}` in all files:

```bash
find . -type f \( -name "*.json" -o -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) -exec sed -i 's/{{PROJECT_NAME}}/{project-name}/g' {} +
```

Also rename README.md.template to README.md if it exists:
```bash
mv README.md.template README.md 2>/dev/null || true
```

#### Step 7: Initialize Git (if requested)

```bash
git init
git add .
git commit -m "feat: initialize project with compass-labs"
```

#### Step 8: Install Dependencies (if requested)

```bash
npm install
```

### Phase 5: Summary

After completion, provide a summary to the user:

1. **Created project at**: {target-directory}
2. **Included components**: List what was kept
3. **Excluded components**: List what was removed (if any)
4. **Next steps**:
   - If dependencies not installed: `cd {project-name} && npm install`
   - Start development: `docker-compose up`
   - Access URLs (based on included components):
     - Frontend: http://localhost:3000
     - Backend: http://localhost:4000
     - Database: PostgreSQL on localhost:5432

## Error Handling

- **Clone fails**: Try HTTPS URL as fallback, then report error with troubleshooting steps
- **Directory exists**: Ask user to confirm overwrite or choose different location
- **Invalid project name**: Validate name (alphanumeric, hyphens, underscores only) and ask to correct
- **npm install fails**: Report error but don't halt - user can install manually later

## Why Opt-Out?

The opt-out approach means:
- **Fewer questions** - Most users want the full stack
- **Faster setup** - Just press Enter to accept defaults
- **Clear intent** - Users explicitly choose what to remove
- **Simpler logic** - No complex combinations to validate

---

## Phase 6: Registry Bootstrap (Greenfield)

After Phase 5 summary, always bootstrap the architecture registry for the new project. This is not optional — the registry is part of the project structure, not a feature.

### Step 1: Create registry directory skeleton

In the target project directory, create:

```bash
mkdir -p {target-directory}/docs/reference/constructs
mkdir -p {target-directory}/docs/registry/decisions
```

### Step 2: Write docs/registry/index.md

Write the L0 construct index with today's date and empty tables:

```markdown
---
last_updated: {today YYYY-MM-DD}
construct_count: 0
verified: 0
stubs: 0
---

# System Model — Construct Registry

> Before building anything: search this index.
> Column "Does" is the capability description — search it before creating a new construct.

## Constructs

| Name | Type | Does | Layer | File | Status |
|------|------|------|-------|------|--------|

## Feature Cross-Reference

| Feature | Constructs |
|---------|-----------|

## Known Gaps

- docs/ tree not yet surveyed
- src/ tree not yet surveyed

## Patterns

[Cross-cutting conventions](patterns.md) — 0 patterns established
```

### Step 3: Write docs/registry/patterns.md

```markdown
# Established Patterns

> These are non-negotiable conventions. Before implementing anything,
> check if a pattern applies. If you need to deviate, write an ADR first.

## Anti-Patterns

- ❌ Do not build a construct without searching the registry first
```

### Step 4: Write docs/registry/decisions/index.md

```markdown
---
last_updated: {today YYYY-MM-DD}
adr_count: 1
---

# Architecture Decision Record Index

> Each row is one significant decision. Click the title to read the full ADR.
> Status: Proposed | Accepted | Deprecated | Superseded

| ID | Date | Status | Decision | Affects |
|----|------|--------|----------|---------|
| [001](001-initial-stack-choices.md) | {today YYYY-MM-DD} | Accepted | Initial stack choices for {project-name} | all |
```

### Step 5: Write ADR-001 — initial stack choices

Derive the content from the choices made during Phases 1–3 (which components were included/excluded, and why the user chose them if they said anything). If the user gave no reasons, use "team default / project requirements" as the rationale.

Write `docs/registry/decisions/001-initial-stack-choices.md`:

```markdown
---
id: "001"
date: {today YYYY-MM-DD}
status: Accepted
deciders: [{user name if known, else "project initiator"}]
affects: [all]
---

## Context

New project {project-name} initialized via compass-labs init.
Stack selected during initialization.

## Decision

We will use the following stack for {project-name}:
{list each included component — e.g. "React + Vite + TypeScript (frontend), Node.js + Prisma (backend), PostgreSQL (database)"}

## Options Considered

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **Selected stack (chosen)** | Full-stack type safety, ORM-managed migrations, containerized development | Initial complexity vs. simpler alternatives | — chosen |
{For each excluded component, add a row explaining it was removed: e.g. "Frontend excluded" | N/A | N/A | User opted out during init}

## NFR Captured

- (none captured at initialization — add NFRs as decisions are made)

## Consequences

**Now easier**: Consistent tooling across the team, containerized environment, type-safe DB queries.
**Now harder**: Higher initial setup cost vs. a single-language or no-ORM approach.
**New constraints**: All schema changes must go through Prisma migrations.

## Revisit Conditions

If the team grows past 10 engineers and the monorepo structure creates bottlenecks,
or if a component proves unsuitable for the project's actual requirements.
```

### Step 6: Inject agent navigation protocol into project CLAUDE.md

Read `{target-directory}/CLAUDE.md` if it exists. If not, create it.

Append the following block at the **top** of the file (before any existing content):

```markdown
## Agent Navigation Protocol

Before designing or building anything in this codebase, always:

1. Read `docs/registry/index.md` — search the "Does" column for capabilities that already exist
2. Check the Feature Cross-Reference for related constructs across all layers
3. If the registry has Known Gaps in the relevant area — read source only for those specific areas
4. After any implementation: write or update the construct file in `docs/reference/constructs/`

This prevents duplicate work and keeps the registry as the single source of truth for what exists.

**Sufficiency gate**: If the registry fully covers the area you're investigating with no Known Gaps, stop reading. You have enough context. Do not read source code for areas the registry already covers.

See `docs/registry/index.md` for the current construct map.
```

### Step 7: Commit registry files

```bash
git -C {target-directory} add docs/registry/ CLAUDE.md
git -C {target-directory} commit -m "feat: bootstrap architecture registry with ADR-001"
```

If git was not initialized (user chose No in Phase 3), skip the commit — the files are already written.

### Step 8: Tell the user

```
Registry bootstrapped:
  docs/registry/index.md          (L0 construct index — empty, ready to fill)
  docs/registry/patterns.md       (cross-cutting conventions — empty)
  docs/registry/decisions/
    index.md                      (ADR index)
    001-initial-stack-choices.md  (stack decision captured)
  CLAUDE.md updated               (agent navigation protocol injected)

Next: run /compass:plan to design your first feature. The plan skill
will read the registry before proposing anything new.
```

---

## Phase 7: Brownfield-Migrate Mode

This mode seeds the architecture registry from an **existing codebase** — no project scaffolding, no template cloning. It reads the codebase structure, extracts constructs, and writes them as stubs into `docs/registry/`.

**Hard limit: read at most 5 source files.** Prioritise breadth (know what exists everywhere) over depth (know one file completely). Stop reading once the limit is reached.

### Step 1: Confirm target directory

Ask the user for the project root directory if not already in it:

- Header: "Project root"
- Question: "Where is the existing project? (Press Enter to use current directory)"
- Options:
  - "Current directory" (description: "Use the directory Claude Code is running in (Recommended)")
  - "Custom path" (description: "Specify the project root path")

Set `{target-directory}` from the answer. All subsequent reads and writes are relative to `{target-directory}`.

### Step 2: Create registry skeleton (if not present)

Check whether `{target-directory}/docs/registry/index.md` already exists. If not, create the full skeleton (same as Phase 6 Steps 1–3 above — directory tree, `index.md`, `patterns.md`, `decisions/index.md`). If it already exists, read it and note the existing construct count before proceeding.

### Step 3: Source discovery (max 5 reads total)

Use this priority order. Each item costs one read from the budget of 5. Stop the moment the budget is exhausted — do not exceed 5 reads even if more sources exist.

| Priority | Source | What to extract |
|----------|--------|-----------------|
| 1 | `docs/sessions/*/overview.md` (read the first match); if none found, fall back to `specs/*/overview.md` (legacy convention, read the first match) | Feature names, planned constructs, Implementation Order items — yields `status: planned` stubs |
| 2 | `src/` directory listing (one `ls -R` or `Glob("src/**")`) | Service files, component files, repository files — yields `status: built` stubs |
| 3 | Schema file — first of: `prisma/schema.prisma`, `schema.sql`, `db/schema.rb`, `models.py` | Model names and fields — yields `type: Model` stubs |
| 4 | IaC — first of: `docker-compose.yml`, `terraform/`, `k8s/`, `infrastructure/` (one file read) | Resource names (services, queues, buckets) — yields `type: Resource` stubs |
| 5 | Any remaining top-level config — first of: `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod` | Package name (use as project name), dependency hints for layer detection |

For each source read, extract a list of constructs in this format (hold in memory, do not write yet):

```
{ConstructName}  type:{Type}  layer:{Layer}  status:{planned|built}  source:{source-file-path}
```

Type mapping heuristics:
- File names ending in `Service`, `service`, `Controller`, `controller`, `Handler` → `Service`
- File names ending in `Repository`, `Repo`, `Store`, `store` → `Repository`
- File names ending in `Component`, component in path `components/` → `Component`
- Prisma `model` blocks, SQL `CREATE TABLE`, Rails models → `Model`
- `docker-compose` services, Terraform resources → `Resource`
- Anything in `utils/`, `lib/`, `helpers/` → `Utility`
- Anything in `middleware/` → `Middleware`
- React hooks (`use*.ts`, `use*.tsx`) → `Hook`
- Anything else → `Service` (default)

Layer mapping heuristics:
- Path contains `frontend/`, `client/`, `web/`, `ui/`, `components/`, `pages/`, `views/`, `hooks/` → `Frontend`
- Path contains `backend/`, `server/`, `api/`, `services/`, `routes/`, `controllers/` → `Backend`
- Schema file, `models/`, `repositories/` → `Database`
- `docker-compose.yml`, `terraform/`, `k8s/`, `infra/` → `Infra`
- `packages/shared/`, `lib/`, no clear layer → `Shared`

### Step 4: Deduplicate and rank

After source reads are complete:
1. Deduplicate: if the same logical name appears in both `docs/sessions/*/overview.md`/`specs/*/overview.md` (planned) and `src/` (built), keep one entry with `status: built`.
2. Rank by confidence: constructs with explicit file paths > inferred from directory names > guessed from package names.
3. Cap at 25 construct stubs total — if more were found, keep the 25 highest-confidence ones and note the rest as Known Gaps.

### Step 5: Write construct stubs

For each extracted construct, write `{target-directory}/docs/reference/constructs/{ConstructName}.md`:

```markdown
---
name: {ConstructName}
type: {Type}
layer: {Layer}
file: {relative-path-to-source-file or null if inferred}
status: {planned | built}
planned_in: {source-file-path if from docs/sessions/ or specs/, else null}
last_verified: null
---

## Does

{One sentence inferred from the file name and layer. Lead with a verb.}
Seeded automatically by brownfield-migrate — verify and expand this description.

## Functional Requirements

- [ ] (not yet captured — fill in from docs/sessions/, specs/, or source code review)

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: null

## Interface

```
// Not yet captured — add the real interface after reviewing the source.
```

## Dependencies

- Calls: (not yet mapped)
- Called by: (not yet mapped)
- Reads: (not yet mapped)
- Writes: (not yet mapped)

## Patterns Applied

- (none yet)

## Key Decisions

- (none yet)
```

### Step 6: Update docs/registry/index.md

Rewrite the Constructs table to include all extracted stubs:

```markdown
| Name | Type | Does | Layer | File | Status |
|------|------|------|-------|------|--------|
| [{ConstructName}](constructs/{ConstructName}.md) | {Type} | {one-line Does} | {Layer} | {file} | {status} |
```

Update the frontmatter:
- `last_updated`: today's date
- `construct_count`: total stubs written
- `verified`: 0 (none verified yet — brownfield migration only seeds stubs)
- `stubs`: total stubs written

Add entries to the Known Gaps section for areas not read (due to the 5-read budget):

```markdown
## Known Gaps

- {Any source type that was skipped due to budget — e.g., "IaC not surveyed (budget exhausted)"}
- {Any constructs truncated past the 25-stub cap — list area names}
- All stubs need human verification — descriptions were inferred, not read from source
```

### Step 7: Update docs/registry/decisions/index.md

Append a row for the migration event:

```markdown
| [002](002-brownfield-registry-migration.md) | {today YYYY-MM-DD} | Accepted | Architecture registry seeded from existing codebase | all |
```

Then write `docs/registry/decisions/002-brownfield-registry-migration.md`:

```markdown
---
id: "002"
date: {today YYYY-MM-DD}
status: Accepted
deciders: [{user name if known, else "project maintainer"}]
affects: [all]
---

## Context

This project already existed when the architecture registry was introduced.
The registry was seeded automatically from up to 5 source reads using
`/compass:init brownfield-migrate`.

## Decision

Seed construct stubs from the sources actually read (list them), accept them as
`status: built` where source files were found, `status: planned` where only spec files existed.
All stubs require human review — descriptions are inferred, not verified.

## Sources Read

{List each source file actually read and what was extracted from it.}

## Consequences

**Now easier**: The registry exists and provides a starting map of the system.
**Now harder**: Stubs may be inaccurate — descriptions were generated from file names, not source content.
**New constraint**: Before marking any stub `verified`, a human must read the source and confirm the Does statement and FRs.

## Revisit Conditions

Once 80% of stubs are verified, remove this ADR's "stubs require review" constraint.
```

### Step 8: Inject agent navigation protocol into CLAUDE.md

Same as Phase 6 Step 6 — read `{target-directory}/CLAUDE.md` (or create it), prepend the Agent Navigation Protocol block.

If the block is already present (check for `## Agent Navigation Protocol`), skip this step.

### Step 9: Commit

```bash
git -C {target-directory} add docs/registry/ CLAUDE.md
git -C {target-directory} commit -m "feat: seed architecture registry via brownfield-migrate"
```

If the directory is not a git repo, skip the commit and note it in the report.

### Step 10: Print migration report

```
Brownfield migration complete
─────────────────────────────────────────────────
Sources read ({N}/5 budget used):
  ✓ docs/sessions/your-feature/overview.md → 4 planned constructs
  ✓ src/ tree                        → 12 built constructs
  ✓ prisma/schema.prisma             → 3 Model constructs
  ✗ IaC (budget exhausted)
  ✗ package.json (budget exhausted)

Registry written:
  docs/registry/index.md             ({total} constructs indexed)
  docs/reference/constructs/         ({total} stub files)
  docs/registry/decisions/002-...md  (migration ADR)
  CLAUDE.md                          (agent nav protocol injected)

Summary:
  Planned (from specs):  {N}
  Built   (from src/):   {N}
  Models  (from schema): {N}
  Total stubs:           {N}
  Known Gaps:            {N areas not surveyed}

Next steps:
  1. Review each stub in docs/reference/constructs/ — fix inferred descriptions
  2. Run /compass:explore to fill Known Gaps one area at a time
  3. Run /compass:plan — it will now read the registry before designing
```
