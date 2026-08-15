---
last_updated: 2026-05-14
type: integration-note
---

# Kimi CLI — Programmatic Integration

## What Is It

Kimi Code CLI is a terminal AI coding agent by Moonshot AI, comparable to Claude Code. It supports being driven as a child process, which enables a **master/child orchestration pattern** where Claude Code acts as the orchestrator and Kimi CLI executes delegated tasks.

- GitHub: https://github.com/MoonshotAI/kimi-cli
- Docs: https://moonshotai.github.io/kimi-cli/en/
- Requires a `MOONSHOT_API_KEY` from https://platform.moonshot.cn/console/api-keys

## The Pattern

Claude Code (master) spawns `kimi --print` as a child process via the `Bash` tool, captures its output, and checks the exit code to determine next steps.

```
[Claude Code — master orchestrator]
         |
         | Bash tool: kimi --print -p "..."
         v
  [Kimi CLI — child process]
         |
         | stdout (text or JSONL)
         | exit code: 0 (success) | 1 (failure) | 75 (retryable)
         v
[Claude Code reads result and continues]
```

## Key Flags for Programmatic Use

| Flag | Purpose |
|------|---------|
| `--print` | Non-interactive mode — auto-exits after task, auto-approves all tool calls |
| `-p "task"` | Pass the prompt inline |
| `--output-format=stream-json` | JSONL output for structured parsing |
| `--input-format=stream-json` | JSONL input |
| `--final-message-only` | Suppress intermediate output, return only the final response |
| `--quiet` | Clean output (shorthand for suppressing progress noise) |

## Basic Usage

```bash
# Simple fire-and-forget
kimi --print -p "Refactor the auth module to use JWT"

# Pipe input
echo "Write tests for utils.ts" | kimi --print

# Structured JSON output
kimi --print --output-format=stream-json -p "Summarise the API surface"
```

## Exit Codes

- `0` — success
- `1` — permanent failure (don't retry)
- `75` — retryable failure (e.g. rate limit, transient error)

## Agent SDK

For more complex orchestration, Moonshot also provides a thin SDK wrapper:
- https://github.com/MoonshotAI/kimi-agent-sdk
- Available for Python, Node.js, and Go
