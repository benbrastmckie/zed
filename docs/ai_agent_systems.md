# AI Agent Systems Comparison

This repository includes two AI agent systems -- **Claude Code** and **OpenCode** -- that serve as parallel development assistants. Both use Anthropic's Claude models, share the same task management infrastructure, and provide structured research-plan-implement workflows. This document covers how they differ, what they share, and how to choose.

## Choosing a System

The installation wizard at `scripts/install/install.sh` offers three options during the **Agent Systems** group:

1. **Claude Code only** -- The primary interface, accessed via Ctrl+Shift+A in Zed or from the terminal.
2. **OpenCode only** -- A terminal-based alternative with its own configuration tree.
3. **Both** -- Install both systems side by side. They share task state and memory without conflict.

You can switch at any time by running the install wizard again.

## Cost Model

| | Claude Code | OpenCode |
|--|-------------|----------|
| **Pricing** | Subscription-based (at time of writing, discounted when using Claude Code directly via Anthropic's Claude Max plan) | API credit-based (pay-per-use via your Anthropic API key) |
| **Best for** | Heavy daily use where flat-rate pricing is more predictable | Occasional use or teams that prefer usage-based billing |
| **Billing** | Monthly subscription through Anthropic | Prepaid API credits consumed per request |

Note: Pricing details are current at time of writing. Check [anthropic.com/pricing](https://www.anthropic.com/pricing) for the latest information.

## Shared Infrastructure

Both systems read and write the same shared resources:

| Resource | Location | Purpose |
|----------|----------|---------|
| Task management | `specs/` | TODO.md, state.json, task directories |
| Memory vault | `.memory/` | Persistent AI knowledge with validate-on-read index |
| Extensions | 10 shared extensions | core, epidemiology, filetypes, latex, memory, present, python, slidev, typst, web |
| Documentation | `docs/` | User-facing guides (this directory) |
| Install scripts | `scripts/install/` | Shared installation wizard |

Task directories use prefixes to identify their origin:
- Claude Code tasks: `specs/{NNN}_{SLUG}/` (no prefix)
- OpenCode tasks: `specs/OC_{NNN}_{SLUG}/` (OC_ prefix)

## Key Differences

| Aspect | Claude Code | OpenCode |
|--------|-------------|----------|
| Config directory | `.claude/` | `.opencode/` |
| Access method | Ctrl+Shift+A in Zed, or `claude` in terminal | `opencode` in terminal |
| Quick reference | `.claude/CLAUDE.md` | `.opencode/AGENTS.md` |
| Internal docs | `.claude/docs/` | `.opencode/docs/` |
| MCP registration | `claude mcp add` | `~/.opencode/config.json` or `.mcp.json` |
| Task prefix | `{NNN}_{SLUG}` | `OC_{NNN}_{SLUG}` |

### System-Exclusive Commands

Most commands are available in both systems. A few are exclusive to one:

| Command | Claude Code | OpenCode | Description |
|---------|:-----------:|:--------:|-------------|
| `/distill` | Yes | -- | Memory vault maintenance |
| `/epi` | Yes | -- | Epidemiology interactive routing |
| `/edit` | Yes | -- | DOCX editing with SuperDoc |
| `/scrape` | Yes | -- | PDF annotation extraction |
| `/deck` | -- | Yes | Presentation deck generation |

`/project-overview` is available in both systems.

## Detailed References

- [docs/agent-system/opencode.md](agent-system/opencode.md) -- OpenCode setup, command comparison, and unique capabilities
- [.claude/CLAUDE.md](../.claude/CLAUDE.md) -- Claude Code quick reference with routing tables
- [.opencode/AGENTS.md](../.opencode/AGENTS.md) -- OpenCode quick reference
- [docs/agent-system/extensions.md](agent-system/extensions.md) -- Extension feature matrix for both systems
- [docs/agent-system/commands.md](agent-system/commands.md) -- Full command catalog with per-system availability
