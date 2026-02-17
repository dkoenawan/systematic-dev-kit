# Systematic Dev Kit

A systematic methodology for building full-stack applications - opinionated Claude Code skills covering infrastructure, database, backend, and frontend development.

## Overview

This plugin provides a comprehensive set of skills that guide Claude Code through a structured, step-by-step approach to building production-ready applications. Each skill follows established best practices and provides clear, opinionated guidance for common development tasks.

## Installation

### Option 1: Load from Local Directory

```bash
claude --plugin-dir /path/to/systematic-dev-kit
```

### Option 2: Clone and Configure

```bash
git clone https://github.com/dkoenawan/systematic-dev-kit.git
cd systematic-dev-kit
claude --plugin-dir .
```

## Plugin Structure

This plugin follows the Claude Code plugin architecture:

```
systematic-dev-kit/
├── .claude-plugin/
│   └── plugin.json                    # Plugin manifest
├── skills/                            # Agent-based skills
│   ├── init/                          # Project initialization (recommended)
│   │   └── SKILL.md
│   ├── brand-designer/                # Brand identity design through discovery
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

#### `/systematic-dev-kit:init` (Recommended)

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
/systematic-dev-kit:init
```

**How it works:**
1. Clones the [dev-kit-scaffolding](https://github.com/dkoenawan/dev-kit-scaffolding) template
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

#### `/systematic-dev-kit:brand-designer`

Design a distinctive brand identity through systematic emotional discovery — generates brand guidelines, CSS custom properties, and optional Tailwind config.

**What it produces:**

| File | Description |
|------|-------------|
| `brand/brand-guideline.md` | Comprehensive brand identity doc (colors, typography, spacing, component tokens, voice & tone) |
| `brand/brand-theme.css` | CSS custom properties in HSL format with intentionally designed dark mode |
| `brand/tailwind.brand.js` | Tailwind theme config (only if selected) |

**Usage:**
```bash
/systematic-dev-kit:brand-designer
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

### Feature Planning

#### `/systematic-dev-kit:plan`

Systematic feature planning through structured discovery — generates detailed specs (DB → Backend → Frontend) that eliminate re-scanning and token waste in future implementation prompts.

**What it produces:**

| File | Description |
|------|-------------|
| `specs/{feature-name}.md` | Complete feature spec with Prisma models, CQRS commands/queries, API shapes, routes, and implementation order |

**Usage:**
```bash
/systematic-dev-kit:plan
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

#### `/systematic-dev-kit:bootstrap-new-project` (Deprecated)

> **Deprecated**: Use `/systematic-dev-kit:init` instead. This skill generates files directly which is less token-efficient.

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
/systematic-dev-kit:bootstrap-new-project
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
