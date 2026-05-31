---
name: init
description: Initialize a new full-stack project from a template repository with opt-out component selection
---

# Init Skill

This skill creates a new full-stack project by cloning a pre-built template repository. It uses a simple opt-out approach - you get the full stack by default and only need to specify what you DON'T want.

## What This Skill Does

1. **Clones the template repository** - Fast, token-efficient project scaffolding
2. **Asks simple opt-out questions** - Only answer if you want to REMOVE something
3. **Removes unwanted components** - Deletes directories and updates configs
4. **Configures the project** - Updates names, docker-compose.yml, package.json

## Default Stack (Opinionated)

| Component | Technology |
|-----------|------------|
| Frontend | React + Vite + TypeScript |
| Backend | Node.js + TypeScript + Prisma |
| Database | PostgreSQL |
| Infrastructure | Docker with docker-compose |

## Usage

```bash
/systematic-dev-kit:init
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

## Instructions for Claude Code

When this skill is invoked, follow this exact sequence:

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
git commit -m "feat: initialize project with systematic-dev-kit"
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
mkdir -p {target-directory}/docs/registry/constructs
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

New project {project-name} initialized via systematic-dev-kit init.
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
4. After any implementation: write or update the construct file in `docs/registry/constructs/`

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

Next: run /systematic-dev-kit:plan to design your first feature. The plan skill
will read the registry before proposing anything new.
```
