---
domain: init
last_updated: 2026-04-24
source_path: skills/init
---

# Init

## What Is Init?

Init is a project scaffolding capability that bootstraps new full-stack applications by cloning a pre-configured template repository and customising it through an opt-out component selection model. The primary object it owns is a **Project** — a newly initialised full-stack monorepo with a user-specified name, target location, and selected technology stack, ready for `docker-compose up` and development.

## How It Works

A Project is created through five sequential phases. The developer invokes `/systematic-dev-kit:init` and answers five questions: what to name the project, where it should live, which components to exclude (frontend, backend, and/or database — everything is included by default), whether to initialise git, and whether to install npm dependencies immediately.

Once answers are collected, the skill clones the `dev-kit-scaffolding` template repository with `--depth 1` (shallow, for speed) into the target directory, then strips the cloned git history to give the new project a clean slate. Based on the user's exclusions, the skill surgically removes unwanted component directories, updates `docker-compose.yml` to remove the corresponding services, and removes excluded packages from the root `package.json` workspaces array. All `{{PROJECT_NAME}}` placeholders in configuration files are replaced with the user's chosen name via a find-and-sed pass.

If the user selected git initialisation, `git init`, `git add`, and an initial commit are performed. If the user selected immediate dependency installation, `npm install` is run across all workspaces. The Project reaches ready state with all selected technology stacks in place, configuration files updated, and clear next-step instructions provided.

## Core Objects / Entities

| Object | Description |
| ------ | ----------- |
| `Project` | A full-stack monorepo scaffold: named, located, component-selected, optionally git-initialised and npm-installed. |
| `TemplateRepository` | The `dkoenawan/dev-kit-scaffolding` GitHub repo — the pre-built reference implementation cloned during scaffolding. |
| `Component` | A removable stack element: Frontend (React + Vite + TypeScript), Backend (Node.js + Prisma + TypeScript), or Database (PostgreSQL). |
| `Configuration` | `docker-compose.yml` and `package.json` files updated during customisation to reflect the selected component set and project name. |

## Code Map — Which Code Touches This

- **Models / Schema**: `skills/init/SKILL.md` — defines the five-question data model for user inputs (project name, directory, excluded components, git flag, npm flag) and the Project object's expected final state.
- **Business Logic / Services**: `skills/init/SKILL.md` — complete five-phase workflow: Gather Basics → Component Selection → Setup Options → Execute Setup (8 steps) → Summary; includes SSH-to-HTTPS clone fallback and placeholder replacement logic.
- **API / Interface**: Invoked as `/systematic-dev-kit:init`; five interactive `AskUserQuestion` prompts drive the configuration conversation.
- **Persistence**: Git clone of `git@github.com:dkoenawan/dev-kit-scaffolding.git` (SSH, with HTTPS fallback); filesystem operations to delete excluded directories and replace placeholders; optional `git init` and `npm install`.
- **External callers**: Invoked standalone; no other skills call into init programmatically.

## Internal Architecture

**Opt-out Selection Pattern**: Users select what to *remove* from the default full stack, not what to add. This eliminates choice paralysis on the happy path and makes the most common case (full stack) near-zero friction.

**SSH / HTTPS Clone Fallback**: The skill defaults to SSH clone (`git@github.com`) and silently retries with HTTPS if SSH fails, accommodating environments without SSH key configuration.

**Shallow Clone for Speed**: `--depth 1` avoids fetching the full template history, reducing clone time and token cost.

**Placeholder Replacement**: Simple `{{PROJECT_NAME}}` string templating in configuration files is replaced in bulk via `find` + `sed`, decoupling template maintenance from skill logic.

## Dependencies

- **Internal**: None — init is a standalone skill.
- **External**: `git` (clone, init, commit); `npm`/npm workspaces (optional dependency installation); `docker-compose` (referenced in generated config, not executed by this skill); `dkoenawan/dev-kit-scaffolding` GitHub repo (template source).

## Gotchas

- Project names containing sed regex special characters (e.g., `/`, `\`) may cause the placeholder replacement step to fail or produce unexpected results. Validate project names before running the substitution.
- If the target directory already exists, the skill asks for confirmation before overwriting. Declining leaves the skill in an incomplete state with no clear recovery path documented.
- If `npm install` is selected and fails, the skill reports the error but does not halt — the project is delivered in a partially-installed state. The developer must debug and re-run `npm install` manually.
- If git is not configured (`user.name`/`user.email` missing), the initial commit fails silently, leaving the project with no commits despite the user having selected git initialisation.
- The root `package.json` workspace removal logic assumes literal package names in the `workspaces` array. If the template switches to glob patterns (e.g., `"packages/*"`), the exclusion logic will not work as intended.

## Changelog

- 2026-04-24: Initial documentation generated by doc-maintainer.
