---
domain: bootstrap-new-project
last_updated: 2026-05-01
source_path: skills/bootstrap-new-project
---

# Bootstrap New Project — Deprecated (L3)

> → [System overview](../solution-design.md) | → [Container architecture](../containers.md)

> **This skill is deprecated.** All new project creation should use `/systematic-dev-kit:init` instead, which clones a maintained template repository rather than generating files from inline templates. This overview is preserved for historical reference.

## What Is Bootstrap New Project?

Bootstrap New Project is a deprecated project scaffolding skill that generated complete full-stack application structures by writing files directly from inline templates embedded in the skill definition. Its primary object is a **NewProject** — a runnable full-stack monorepo with a Clean Architecture backend (Express + TypeScript + CQRS), an atomic-design frontend (React + Vite + MUI), and Docker Compose orchestration. It was superseded by the `init` skill, which is faster, lower-token, and easier to maintain because it clones a pre-built template repository rather than generating files from scratch.

## How It Works

A NewProject was created through a five-phase interactive workflow. The developer answered prompts for project name, target directory, git initialization preference, and whether to install dependencies immediately. The skill then validated that Docker was installed (a hard requirement — no fallback); if missing, it halted with installation instructions.

File generation proceeded by writing a complete directory tree to disk: backend structure (Express server, CQRS command/query handlers, OpenAPI spec skeleton, TypeScript config), frontend structure (React + Vite + MUI + atomic design component hierarchy), root configuration files (`docker-compose.yml`, `.gitignore`, `.dockerignore`, `README.md`), and placeholder `database/` and `agent/` directories containing only README files. All dependencies were pre-specified in generated `package.json` files.

Optionally, `git init` and an initial commit were performed, and `npm install` ran across both backend and frontend workspaces. The developer received service URLs: Frontend at `:3000`, Backend API at `:4000`, API docs at `:4000/api-docs`.

## Core Objects / Entities

| Object | Description |
| ------ | ----------- |
| `NewProject` | A complete full-stack monorepo scaffold generated from inline templates embedded in SKILL.md. |
| `Backend` | Express.js + TypeScript server following Clean Architecture (Domain → Usecases → Interface → Infrastructure) with CQRS command/query handlers. |
| `Frontend` | React + TypeScript + Vite + Material-UI application following atomic design (atoms → molecules → organisms → templates → pages). |
| `Database` | Placeholder directory reserved for future relational/document store implementation. Contains README only. |
| `Agent` | Placeholder directory reserved for future agentic AI workflow implementation. Contains README only. |

## Code Map — Which Code Touches This

- **Business Logic + Templates**: `skills/bootstrap-new-project/SKILL.md` — five-phase workflow and all generated file contents inline (TypeScript configs, package.json dependency lists, docker-compose structure, OpenAPI spec skeleton, Express server boilerplate, Vite config)
- **Interface**: Invoked as `/systematic-dev-kit:bootstrap-new-project`; interactive prompts for project name, directory, git, and npm preferences
- **Persistence**: Writes all files directly to the target directory; no template repository dependency (unlike `init`)
- **External callers**: Superseded by `systematic-dev-kit:init`; no other skills call into this domain

## Internal Architecture

**Clean Architecture Layers (generated backend)**: Domain (entities, repository interfaces) → Usecases (CQRS command/query handlers) → Interface (HTTP controllers, DTOs, route definitions) → Infrastructure (database connections, ORM repositories). Generated as an empty scaffold for developers to populate.

**Atomic Design (generated frontend)**: Components decomposed into five levels — atoms → molecules → organisms → templates → pages — to enforce reusability from the start.

**Inline Template Problem**: All file content was embedded inside `SKILL.md`, coupling template maintenance directly to skill logic. Any template change required editing the skill definition. This is the primary architectural reason it was superseded by `init`'s template-clone approach.

## Dependencies

- **Internal**: None — standalone skill; no inter-skill dependencies
- **External**: Docker (hard requirement, checked at validation step); npm (dependency installation); packages written into generated `package.json` include Express, cors, dotenv, swagger-ui-express, zod, React, react-router-dom, MUI, Vite, TypeScript

## Gotchas

- **Use `init` instead**: This skill is deprecated and receives no maintenance. Template content embedded in SKILL.md may be outdated relative to the template repository used by `init`.
- **Docker is a hard prerequisite**: If Docker is not installed, the skill halts with no graceful fallback.
- **`database/` and `agent/` directories are empty placeholders**: They contain only README files. Full implementation is left entirely to the developer; no schema, migration, or agent boilerplate is provided.
- **Generated `openapi.yaml` is a minimal skeleton**: No API endpoints are pre-populated. Developers must expand it to reflect actual contracts.
- **No authentication middleware**: Auth must be added manually post-scaffold.
- **Token-inefficient by design**: Generating all file content from inline templates is significantly more token-expensive than cloning a pre-built repository. This is the primary performance reason `init` was introduced.

## Changelog

- 2026-04-24: Initial documentation generated by doc-maintainer.
- 2026-05-01: Full refresh via doc-maintainer.
