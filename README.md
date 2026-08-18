# Systematic Dev Kit

A systematic methodology for building full-stack applications - opinionated Claude Code skills covering infrastructure, database, backend, and frontend development.

## Overview

This plugin provides a comprehensive set of skills that guide Claude Code through a structured, step-by-step approach to building production-ready applications. Each skill follows established best practices and provides clear, opinionated guidance for common development tasks.

## Installation

### Option 1: Permanent (Recommended)

Installs the plugin so it loads automatically on every `claude` session — no flags needed.

**Step 1 — Clone the repo**

```bash
git clone https://github.com/dkoenawan/compass-labs.git
```

**Step 2 — Register as a local marketplace**

```bash
claude plugin marketplace add /path/to/compass-labs
```

**Step 3 — Install the plugin**

```bash
claude plugin install compass-labs@compass-labs
```

**Step 4 — Verify**

```bash
claude plugin list
# compass-labs@compass-labs should show Status: ✔ enabled
```

All skills are now available in every `claude` session. To update later:

```bash
claude plugin update compass-labs@compass-labs
```

---

### Option 2: Session-only (quick test)

Loads the plugin for the current session only. Nothing is written to your user config.

```bash
claude --plugin-dir /path/to/compass-labs
```

---

### Option 3: Clone and load session-only

```bash
git clone https://github.com/dkoenawan/compass-labs.git
cd compass-labs
claude --plugin-dir .
```

## Plugin Structure

This plugin follows the Claude Code plugin architecture:

```
compass-labs/
├── .claude-plugin/
│   └── plugin.json                    # Plugin manifest
├── skills/                            # Agent-based skills
│   ├── init/                          # Project initialization (recommended)
│   │   └── SKILL.md
│   ├── brand-designer/                # Brand identity design through discovery
│   │   └── SKILL.md
│   ├── explore/                        # Token-efficient codebase investigation
│   │   └── SKILL.md
│   ├── plan/                          # Feature planning and spec generation
│   │   ├── SKILL.md
│   │   ├── template.md
│   │   └── examples/
│   │       └── user-management/
│   │           └── feature-spec.md
│   └── bootstrap-new-project/         # Full-stack project bootstrap (deprecated)
│       └── SKILL.md
├── commands/                          # Quick command skills (future)
├── hooks/                             # Development workflow hooks (future)
├── README.md                          # This file
└── CLAUDE.md                          # Guidance for Claude Code instances

```

## Skills Included

### Project Initialization

#### `/compass:init` (Recommended)

Initialize a new full-stack project from a template repository with opt-out component selection.

**Default Stack (Opinionated):**

| Component | Technology |
|-----------|------------|
| Frontend | React + Vite + TypeScript |
| Backend | Node.js + TypeScript + Prisma |
| Database | PostgreSQL |
| Infrastructure | Docker with docker-compose |

**Usage:**
```bash
/compass:init
```

**How it works:**
1. Clones the [compass-scaffolding](https://github.com/dkoenawan/compass-scaffolding) template
2. Asks which components to EXCLUDE (opt-out approach)
3. Removes unwanted components and updates configs
4. Optionally initializes git and installs dependencies

**Interactive prompts:**
- Project name (default: "my-project")
- Target directory (default: ./{project-name})
- Components to exclude (multi-select, default: none)
- Initialize git? (default: yes)
- Install dependencies? (default: no)

**After init:**
- Frontend: http://localhost:3000
- Backend: http://localhost:4000
- Database: PostgreSQL on localhost:5432

---

### Brand Design

#### `/compass:brand-designer`

Design a distinctive brand identity through systematic emotional discovery — generates brand guidelines, CSS custom properties, and optional Tailwind config.

**What it produces:**

| File | Description |
|------|-------------|
| `brand/brand-guideline.md` | Comprehensive brand identity doc (colors, typography, spacing, component tokens, voice & tone) |
| `brand/brand-theme.css` | CSS custom properties in HSL format with intentionally designed dark mode |
| `brand/tailwind.brand.js` | Tailwind theme config (only if selected) |

**Usage:**
```bash
/compass:brand-designer
```

**How it works (6 phases):**

1. **Brand Soul Discovery** — Understand the brand's story, future vision, and personality archetype
2. **Emotional Mapping** — Define the three core emotions, sensory environment, and anti-inspiration
3. **Visual Direction** — Gather references, assess existing assets, confirm technical context
4. **Creative Direction Synthesis** — AI presents a narrative creative brief for approval before generating anything
5. **File Generation** — Produces brand guidelines, CSS theme, and optional Tailwind config
6. **Handoff Summary** — Google Fonts snippet, import instructions, and next steps

**Key principle:** Colors are derived from emotions, not picked from palettes. The skill spends most of its time understanding the brand through discovery before generating any design artifacts.

---

### Codebase Investigation

#### `/compass:explore`

Token-efficient codebase investigation — reads docs before code, stops when context is sufficient.

**What it produces:**

A structured Investigation Report covering tech stack, data models, backend structure, frontend structure, key architectural patterns, and relevance to the investigation focus.

**Usage:**
```bash
/compass:explore
```

**How it works (3 tiers, stops early):**

1. **Tier 1 — Docs First** (always): README → docs/ → CLAUDE.md. Stops here if tech stack, structure, and focus context are clear.
2. **Tier 2 — Structure** (only if needed): package.json → Prisma schema → directory listings. Stops here if focus is answered.
3. **Tier 3 — Targeted Code** (only if needed): ≤5 files, no import chain following, no broad scanning.

**Key principle:** Thoroughness is not a virtue; precision is. The skill gathers exactly enough context to answer the investigation focus, then stops. Runs on Haiku to minimize token cost.

**Invocation modes:**
- **Standalone**: Invoke directly and provide an investigation focus (e.g., "auth system", "order management", "overall architecture")
- **Via plan**: Automatically invoked by the plan skill when a feature extends existing code — no manual invocation needed

---

### Feature Planning

#### `/compass:plan`

Systematic feature planning through structured discovery — generates detailed specs (DB → Backend → Frontend) that eliminate re-scanning and token waste in future implementation prompts.

**What it produces:**

| File | Description |
|------|-------------|
| `docs/sessions/{date}-{feature-name}/overview.md` | Complete feature spec with Prisma models, CQRS commands/queries, API shapes, routes, and implementation order |

**Usage:**
```bash
/compass:plan
```

**How it works (5 phases):**

1. **Feature Intent** — Understand what the user wants to build, whether it's new or extends existing code, and assess complexity signals
2. **Layer-by-Layer Design** — Walk through Database → Backend → Frontend with adaptive depth (simple features get fewer questions, complex features get the full set plus tradeoff surfacing)
3. **Spec Synthesis** — Synthesize all answers into a complete spec with Prisma models, CQRS operations, TypeScript interfaces, routes, and component hierarchy
4. **Approval Gate** — Present full spec for user approval with option to adjust or rethink
5. **File Generation & Handoff** — Generate spec file and explain how to reference it for implementation

**Key principle:** Plan once, implement by referencing the spec. Each section of the generated spec is detailed enough to implement a full layer (DB, Backend, or Frontend) without re-scanning the codebase or re-explaining context.

**Adaptive depth:** The skill adjusts question count based on feature complexity — a simple CRUD feature gets 3 core questions per layer, while a feature with auth, real-time updates, and file uploads gets the full question set plus inline tradeoff surfacing.

---

### Documentation Maintenance

#### `/compass:doc-maintainer`

Builds and maintains a **C4-layered documentation tree** that grows incrementally — one file per run. Designed so both humans and agents can navigate to exactly the information they need without reading everything.

**The C4 navigation model:**

| Level | File | What it answers | When to read |
|-------|------|-----------------|--------------|
| L1 | `docs/explanation/solution-design.md` | What is this system, who uses it, what external systems does it touch? | Always — it's the entry point |
| L2 | `docs/explanation/containers.md` | What services run, how do they communicate, how is it deployed? | When you need infrastructure context |
| L3 | `docs/explanation/<domain>/overview.md` | What is this domain, how does it work end-to-end, which files touch it? | When working in a specific domain |

**Key principle:** `init` generates L1 only. Each subsequent `maintain` run adds or improves exactly one file — L2 first, then one L3 domain per run, then session fold-back, then accuracy patches, then daily clarity reviews. Token cost scales with task scope.

The C4 tree lives under `docs/explanation/` as part of the plugin's [Diataxis](https://diataxis.fr/) documentation structure — see [ADR-001](docs/registry/decisions/001-diataxis-docs-restructure.md). Sibling top-level folders: `docs/tutorials/`, `docs/how-to/`, `docs/reference/` (registry constructs + API specs), and `docs/sessions/` (session-scoped specs, folded back by `doc-maintainer` on completion).

**What it produces:**

| File | Description |
|------|-------------|
| `docs/explanation/solution-design.md` | L1 system context: purpose, users, external systems, domain map with drill-down links |
| `docs/explanation/containers.md` | L2 container architecture: deployable units, data flows, deployment model |
| `docs/explanation/<domain>/overview.md` | L3 per-domain: object lifecycle, core entities, code map, gotchas |
| `docs/explanation/clarity-log.md` | Running log of daily clarity reviews — one entry per run |
| `docs/how-to/*.md`, `docs/reference/*.md` | Task guides and reference material folded back from completed `docs/sessions/` |

**Usage:**
```bash
/compass:doc-maintainer          # auto-detect: init if docs/ absent, else maintain
/compass:doc-maintainer init     # generate L1 (solution-design.md) only
/compass:doc-maintainer maintain # one unit of work: next missing doc, stale patch, or clarity review
/compass:doc-maintainer refresh  # full rewrite of all docs
/compass:doc-maintainer refresh <domain>  # full rewrite of one named domain
```

**How maintain mode prioritises work (one per run):**

1. Generate `docs/explanation/containers.md` (L2) if missing
2. Generate the next missing `docs/explanation/<domain>/overview.md` (L3), oldest-discovered domain first
3. Fold back the oldest unfolded `docs/sessions/<session>/` into `docs/how-to/`, `docs/reference/`, and `docs/explanation/`
4. Accuracy-patch the most stale existing doc (>30 days old)
5. Clarity review — improve prose quality of the oldest-reviewed doc

**Scheduling (unattended daily runs):**
```bash
# Install a daily cron job for a target repo
bash skills/doc-maintainer/scripts/install-schedule.sh /path/to/repo --time 13:15

# Run Monday–Friday only
bash skills/doc-maintainer/scripts/install-schedule.sh /path/to/repo --time 09:00 --days mon-fri

# Uninstall
bash skills/doc-maintainer/scripts/uninstall-schedule.sh /path/to/repo

# Check installed jobs
crontab -l | grep doc-maintainer
```

**File size discipline:** Any doc that grows beyond 500 lines is automatically split into a subfolder (`docs/explanation/<domain>/index.md` + sub-files) so no single file ever needs to be read in full to get oriented.

**Feature tracing:** `docs/explanation/features/<feature-name>.md` traces a named feature end-to-end — FR/NFR → Pages → API specs → Technical architecture — generated on-demand during session fold-back rather than scheduled. See [ADR-001](docs/registry/decisions/001-diataxis-docs-restructure.md).


---

### Autonomous Task Execution

#### `/compass:task-executor`

Runs large GitHub issues autonomously via cron over multiple days. An interactive planning conversation decomposes an issue into hour-sized tasks, then executes up to 3 per scheduled run — rebasing, implementing, testing, committing, and opening a PR on completion.

**Why 6-hour cadence:** Aligns with the ~5h Claude quota window so runs don't exhaust quota mid-task.

**What it produces:**

| Artifact | Description |
|----------|-------------|
| `docs/sessions/<date>-<feature-name>/tasks.md` | Plan file with frontmatter (issue, branch, test command, retry counts) + dependency-annotated checklist |
| `feat/<feature-name>` branch | One commit per completed task, conventional-commit format |
| GitHub PR | Opened automatically on completion, linked to the issue |

**Usage:**
```bash
/compass:task-executor                    # auto: show status or start planning
/compass:task-executor plan <issue-number> # interactive planning conversation
/compass:task-executor status             # show active plan summary
/compass:task-executor stop               # pause (preserves branch + plan)
/compass:task-executor resume             # resume a paused plan
```

**Typical workflow:**
1. Open a GitHub issue describing the feature
2. Run `plan <issue-number>` — 9-phase conversation produces tasks.md, creates branch, installs cron
3. Come back in a day or two — skill has been committing completed tasks every 6h
4. Review the auto-opened PR

**Task checklist states:**
- `- [ ]` pending
- `- [x]` complete
- `- [!] <desc> (failed YYYY-MM-DD: <reason>)` failed/skipped

**Failure recovery:** Failed tasks are marked `- [!]` after two consecutive failures. Dependent tasks are skipped. If all remaining tasks are blocked, a draft PR is opened with the completed work.

---

#### `/compass:bootstrap-new-project` (Deprecated)

> **Deprecated**: Use `/compass:init` instead. This skill generates files directly which is less token-efficient.

Bootstrap a complete full-stack project with systematic structure and best practices.

**What it creates:**

- **Infrastructure**: Docker setup with docker-compose.yml orchestration
- **Backend**: Node.js + TypeScript with Clean Architecture
  - Domain, Usecases, Interface, Infrastructure layers
  - CQRS pattern (commands and queries separated)
  - Express.js server with health endpoint
  - Swagger API documentation
  - OpenAPI specification
- **Frontend**: React + TypeScript + Vite + Material-UI
  - Atomic design structure (atoms, molecules, organisms, templates, pages)
  - MUI theme configuration
  - Landing page component
  - Routing setup
- **Database**: Placeholder directory for future implementation
- **Agent**: Placeholder directory for agentic AI workflows

**Usage:**
```bash
/compass:bootstrap-new-project
```

**Interactive prompts:**
- Project name
- Target directory
- Initialize git repository?
- Install dependencies?

**After bootstrap:**
- Frontend: http://localhost:3000
- Backend API: http://localhost:4000
- API Docs: http://localhost:4000/api-docs
- Health Check: http://localhost:4000/health

## Development

To develop this plugin locally:

1. Clone the repository
2. Make changes to skills, commands, or hooks
3. Test using `claude --plugin-dir .`
4. Submit pull requests for improvements

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for:

- New skills for systematic development workflows
- Improvements to existing skills
- Documentation enhancements
- Bug fixes

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

Daniel Koenawan

## Resources

- [Claude Code Plugin Documentation](https://code.claude.com/docs/en/plugins)
- [Skills Guide](https://code.claude.com/docs/en/skills)
- [Plugin Reference](https://code.claude.com/docs/en/plugins-reference)
