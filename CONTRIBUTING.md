# Contributing to Systematic Dev Kit

Thank you for your interest in contributing to the Systematic Dev Kit! This guide will help you understand how to contribute effectively.

## Getting Started

1. Fork the repository
2. Clone your fork locally
3. Test the plugin with `claude --plugin-dir .`
4. Make your changes
5. Submit a pull request

## Plugin Architecture

This is a Claude Code plugin that follows the structure documented at https://code.claude.com/docs/en/plugins

### Directory Structure

```
systematic-dev-kit/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (metadata only)
├── skills/                  # Agent-based skills
│   ├── infrastructure/
│   ├── database/
│   ├── backend/
│   └── frontend/
├── commands/               # Direct command skills
├── hooks/                  # Development workflow hooks
└── README.md
```

**IMPORTANT**: Only `plugin.json` should be inside `.claude-plugin/`. All other directories must be at the root level.

## Adding a New Skill

### 1. Choose the Right Category

Skills are organized by domain:
- `skills/infrastructure/` - Server setup, deployment, containerization
- `skills/database/` - Schema design, migrations, queries
- `skills/backend/` - API design, business logic, authentication
- `skills/frontend/` - UI components, state management, routing

### 2. Create Skill Directory and File

```bash
mkdir -p skills/category-name/skill-name
```

### 3. Create SKILL.md

Every skill requires a `SKILL.md` file with frontmatter:

```markdown
---
name: skill-name
description: Clear, concise description of what this skill does
---

# Skill Instructions

Provide clear, systematic guidance for Claude Code to follow.

## When to Use This Skill

Describe the scenarios where this skill should be invoked.

## Methodology

1. First step
2. Second step
3. Third step

## Best Practices

- Key practice 1
- Key practice 2

## Example Usage

Provide concrete examples of how this skill should be used.
```

### 4. Skill Design Principles

- **Opinionated**: Provide clear, specific guidance rather than generic advice
- **Systematic**: Break down complex tasks into clear, sequential steps
- **Focused**: Each skill should have one clear purpose
- **Reusable**: Skills should work across different projects
- **Self-contained**: Include all necessary context and instructions

### 5. Testing Your Skill

```bash
# Test the plugin locally
claude --plugin-dir /path/to/systematic-dev-kit

# Invoke your skill
/systematic-dev-kit:skill-name
```

## Adding Commands

Commands are simpler than skills and don't require AI model invocation. Create a markdown file in `commands/`:

```markdown
---
name: command-name
description: What this command does
disable-model-invocation: true
---

Command instructions here.
```

## Adding Hooks

Hooks automate development workflow tasks. Edit `hooks/hooks.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'File modified: $FILE'"
          }
        ]
      }
    ]
  }
}
```

## Version Management

We follow semantic versioning:

- **MAJOR**: Breaking changes to skill interfaces
- **MINOR**: New skills or backward-compatible enhancements
- **PATCH**: Bug fixes and documentation updates

Update `version` in `.claude-plugin/plugin.json` when making changes.

## Pull Request Guidelines

1. **Clear description**: Explain what your contribution does and why
2. **Test locally**: Ensure your changes work with `claude --plugin-dir .`
3. **Update documentation**: Add your skill to README.md if applicable
4. **Follow conventions**: Use existing skills as templates
5. **One skill per PR**: Keep pull requests focused

## Code of Conduct

- Be respectful and constructive
- Focus on systematic, best-practice approaches
- Provide clear documentation
- Help others learn and improve

## Questions?

Open an issue for:
- Clarification on plugin architecture
- Discussion of new skill ideas
- Questions about contribution process

## Resources

- [Claude Code Plugin Documentation](https://code.claude.com/docs/en/plugins)
- [Skills Guide](https://code.claude.com/docs/en/skills)
- [Plugin Reference](https://code.claude.com/docs/en/plugins-reference)
