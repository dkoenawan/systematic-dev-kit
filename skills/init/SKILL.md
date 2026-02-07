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
