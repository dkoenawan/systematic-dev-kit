---
domain: init
last_updated: 2026-05-01
source_path: skills/init
---

# Init (L3)

> → [System overview](../solution-design.md) | → [Container architecture](../containers.md)

## What Is Init?

Init is a project scaffolding capability that bootstraps new full-stack applications by cloning a pre-configured template repository and customizing it through an opt-out component selection model. The primary object it owns is a **Project** — a newly initialized full-stack monorepo with a user-specified name, target location, and selected technology stack, ready for `docker-compose up` and active development. Init supersedes the deprecated `bootstrap-new-project` skill; it is faster and lower-token because it clones a maintained template rather than generating files from scratch.

## How It Works

A Project is created in five sequential phases. The developer invokes `/compass:init` and answers five questions via interactive prompts: (1) project name, (2) target directory (new subdirectory, current dir, or custom path), (3) which components to *exclude* (Frontend, Backend, and/or Database — everything is included by default), (4) whether to initialize git, and (5) whether to install npm dependencies immediately.

Once answers are collected, the skill clones the `dkoenawan/dev-kit-scaffolding` template repository using `git clone --depth 1` (shallow, for speed). SSH is tried first; if it fails, HTTPS is retried silently. The cloned git history is immediately stripped to give the new project a clean slate.

Based on the user's exclusions, the skill surgically customizes the project: deletes unwanted component directories, updates `docker-compose.yml` to remove the corresponding services (and any `depends_on` references), removes excluded packages from the root `package.json` workspaces array, and runs a bulk find-and-sed pass to replace all `{{PROJECT_NAME}}` placeholders with the chosen project name across all configuration files.

If git initialization was selected, `git init`, `git add .`, and an initial commit are performed. If dependency installation was selected, `npm install` runs across all workspaces. The Project reaches ready state with all selected stacks in place, configuration files updated, and clear next-step instructions (Frontend at `:3000`, Backend at `:4000`).

## Core Objects / Entities

| Object | Description |
| ------ | ----------- |
| `Project` | A full-stack monorepo scaffold: named, located, component-selected, optionally git-initialized and npm-installed. The primary deliverable. |
| `TemplateRepository` | `dkoenawan/dev-kit-scaffolding` on GitHub — the pre-built reference implementation cloned as the foundation for every Project. |
| `Component` | A removable stack element: Frontend (React + Vite + TypeScript), Backend (Node.js + Prisma + TypeScript), or Database (PostgreSQL). Included by default; removed on explicit exclusion. |
| `Configuration` | `docker-compose.yml` and root `package.json` — updated during customization to reflect the selected component set, removed services, and project name. |

## Code Map — Which Code Touches This

- **Business Logic**: `skills/init/SKILL.md` — complete five-phase workflow: Gather Basics → Component Selection → Setup Options → Execute Setup (8 steps) → Summary; includes SSH-to-HTTPS clone fallback, placeholder replacement logic, and post-scaffold instructions
- **Interface**: Invoked as `/compass:init`; five interactive `AskUserQuestion` prompts drive the configuration conversation
- **Persistence**: `git clone --depth 1 git@github.com:dkoenawan/dev-kit-scaffolding.git` (SSH, with HTTPS fallback); filesystem ops to delete excluded directories and replace placeholders; optional `git init` + `git commit`; optional `npm install`
- **External callers**: Invoked standalone; no other compass-labs skills call into init programmatically

## Internal Architecture

**Opt-out Selection Model**: Users select what to *remove* from the default full stack, not what to add. This eliminates choice paralysis on the happy path — the most common case (full stack) requires zero component exclusions and proceeds with defaults.

**SSH / HTTPS Clone Fallback**: The skill defaults to SSH clone and silently retries with HTTPS if SSH fails. This accommodates environments without SSH key configuration without surfacing an error to the user.

**Shallow Clone for Speed**: `--depth 1` avoids fetching the full template history, reducing clone time and token cost. The cloned history is immediately discarded (`.git` stripped) to give the new project a clean slate.

**Placeholder Replacement via find + sed**: `{{PROJECT_NAME}}` string templating is replaced in bulk across all configuration files via a `find` + `sed` pipeline, decoupling template maintenance from skill logic and keeping the template repository stable.

**Configuration Cascade**: After cloning, customization runs in a deterministic order — directory deletion, then `docker-compose.yml`, then `package.json`, then placeholder replacement — ensuring no stale references survive.

## Dependencies

- **Internal**: None — init is a standalone skill with no calls to other compass-labs skills
- **External**: `git` (clone with `--depth 1`, init, add, commit); `npm`/npm workspaces (optional dependency installation); `docker-compose` (referenced in generated config, not executed by this skill); `sed` / `find` utilities (placeholder replacement); `dkoenawan/dev-kit-scaffolding` GitHub repo (must be publicly accessible)

## Gotchas

- **Project names with sed special characters**: Names containing `/`, `\`, or `&` may cause the `{{PROJECT_NAME}}` placeholder replacement to fail or corrupt configuration files. Validate project names before running the substitution step.
- **Target directory already exists**: If the target directory exists and is non-empty, the skill asks for confirmation before overwriting. Declining leaves the skill in an incomplete state with no documented recovery path — the user must manually clean up.
- **npm install failures are non-fatal**: If `npm install` is selected and fails, the skill reports the error but continues. The project is delivered in a partially-installed state; the developer must debug and re-run `npm install` manually.
- **Silent git initialization failure**: If git is not configured globally (`user.name`/`user.email` missing), the initial `git commit` fails silently. The project will have `git init` and `git add .` completed but no commits, despite the user having selected git initialization.
- **Workspace glob pattern assumption**: The root `package.json` workspace removal logic assumes literal package names in the `workspaces` array (e.g., `"frontend"`, `"backend"`). If the template switches to glob patterns (e.g., `"packages/*"`), the exclusion logic will not work as intended and excluded packages may still be registered.

## Changelog

- 2026-04-24: Initial documentation generated by doc-maintainer.
- 2026-05-01: Full refresh via doc-maintainer.
