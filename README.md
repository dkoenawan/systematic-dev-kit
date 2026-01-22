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
git clone https://github.com/yourusername/systematic-dev-kit.git
cd systematic-dev-kit
claude --plugin-dir .
```

## Plugin Structure

This plugin follows the Claude Code plugin architecture:

```
systematic-dev-kit/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── skills/                  # Agent-based skills
│   ├── infrastructure/      # Infrastructure setup skills
│   ├── database/           # Database design and setup
│   ├── backend/            # Backend development
│   └── frontend/           # Frontend development
├── commands/               # Quick command skills
├── hooks/                  # Development workflow hooks
├── README.md              # This file
└── CLAUDE.md             # Guidance for Claude Code instances

```

## Skills Included

*Skills will be added as the plugin develops. This section will be updated to reflect available skills.*

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
