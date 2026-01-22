# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **Claude Code plugin repository** that provides systematic development skills for building full-stack applications. It follows the Claude Code plugin architecture as documented at https://code.claude.com/docs/en/plugins.

## Architecture

### Plugin Structure

This repository follows the standard Claude Code plugin structure:

- `.claude-plugin/plugin.json` - Plugin manifest (required, contains metadata only)
- `skills/` - Agent-based skills organized by domain (infrastructure, database, backend, frontend)
- `commands/` - Direct command skills that don't require AI model invocation
- `hooks/` - Event handlers for development workflow automation
- Root-level directories only (never nest `skills/`, `commands/`, `hooks/` inside `.claude-plugin/`)

### Skill Organization

Skills are organized by development domain:

- **Infrastructure skills**: Server setup, deployment, containerization
- **Database skills**: Schema design, migrations, query optimization
- **Backend skills**: API design, business logic, authentication
- **Frontend skills**: UI components, state management, routing

Each skill is namespaced as `/systematic-dev-kit:skill-name` when invoked.

## Key Constraints

### Directory Structure Rules

**CRITICAL**: Only `plugin.json` goes inside `.claude-plugin/`. All other directories (`skills/`, `commands/`, `hooks/`) must be at the plugin root level.

### Skill Definition Format

Each skill requires a `SKILL.md` file with frontmatter:

```markdown
---
name: skill-name
description: What the skill does
---

Skill instructions here...
```

### Plugin Manifest

The `plugin.json` must contain at minimum:
- `name`: "systematic-dev-kit"
- `description`: Plugin description
- `version`: Semantic version (e.g., "1.0.0")
- `author`: Author information

## Development Workflow

### Testing the Plugin Locally

```bash
claude --plugin-dir /home/su-sentinel/private/systematic-dev-kit
```

### Adding New Skills

1. Create directory under `skills/` (e.g., `skills/new-skill/`)
2. Add `SKILL.md` with proper frontmatter
3. Test with `claude --plugin-dir .`
4. Update README.md to document the new skill

### Version Management

Follow semantic versioning in `plugin.json`:
- MAJOR: Breaking changes to skill interfaces
- MINOR: New skills or backward-compatible enhancements
- PATCH: Bug fixes and documentation updates

## Important Notes

- This plugin is designed for **public distribution** and reuse across projects
- Skills should be **opinionated** and provide clear, systematic guidance
- Each skill should follow **established best practices** for its domain
- Skills are intended to work **independently** but can reference each other
- Keep skills **focused** - one clear purpose per skill
