# OpenCode

OpenCode is the second AI agent system in this repository, running alongside Claude Code. Both systems share the same task management (`specs/`), memory vault (`.memory/`), and 9 extensions, but each has its own configuration tree, skill naming conventions, and access method.

## What Is OpenCode?

OpenCode is a terminal-based AI coding assistant (similar to Claude Code) that uses the same underlying Claude models. It provides a parallel command set for research, planning, and implementation workflows. In this repository, it is configured as an equal peer to Claude Code -- both systems can create, research, plan, and implement tasks using the same `specs/` directory.

## How to Access OpenCode

OpenCode runs in the terminal. If the binary is available on your system:

```bash
opencode
```

On NixOS systems, the binary is typically available at `/run/current-system/sw/bin/opencode` or via your Nix profile. See the [installation guide](../general/installation.md) for setup details.

## Relationship to Claude Code

| Aspect | Claude Code | OpenCode |
|--------|-------------|----------|
| Config directory | `.claude/` | `.opencode/` |
| Access in Zed | Ctrl+Shift+A or Agent Panel thread | Terminal |
| Task prefix | `{NNN}_{SLUG}` | `OC_{NNN}_{SLUG}` |
| MCP registration | `claude mcp add` | `~/.opencode/config.json` or `.mcp.json` |
| Quick reference | `.claude/CLAUDE.md` | `.opencode/AGENTS.md` |
| Internal docs | `.claude/docs/` | `.opencode/docs/` |

## Shared State Model

Both systems read and write the same state files:

```
specs/
├── TODO.md              # Shared task list (both systems append here)
├── state.json           # Shared machine state
├── errors.json          # Shared error tracking
├── 042_some_task/       # Claude Code task (no prefix)
└── OC_043_other_task/   # OpenCode task (OC_ prefix)

.memory/
├── 10-Memories/         # Both systems read and write memories
└── memory-index.json    # Validate-on-read index (shared)
```

The `OC_` prefix on task directories prevents numbering collisions and makes it clear which system created each task.

## Command Comparison

Both systems share the core lifecycle commands:

| Command | Claude Code | OpenCode | Notes |
|---------|:-----------:|:--------:|-------|
| `/task` | Yes | Yes | |
| `/research` | Yes | Yes | |
| `/plan` | Yes | Yes | |
| `/implement` | Yes | Yes | |
| `/revise` | Yes | Yes | |
| `/todo` | Yes | Yes | |
| `/review` | Yes | Yes | |
| `/errors` | Yes | Yes | |
| `/meta` | Yes | Yes | |
| `/fix-it` | Yes | Yes | |
| `/refresh` | Yes | Yes | |
| `/spawn` | Yes | Yes | |
| `/merge` | Yes | Yes | |
| `/tag` | Yes | Yes | |
| `/learn` | Yes | Yes | |
| `/grant` | Yes | Yes | |
| `/budget` | Yes | Yes | |
| `/funds` | Yes | Yes | |
| `/timeline` | Yes | Yes | |
| `/slides` | Yes | Yes | |
| `/convert` | Yes | Yes | |
| `/table` | Yes | Yes | |
| `/sheet` | Yes | Yes | |
| `/distill` | Yes | -- | Memory vault maintenance |
| `/epi` | Yes | -- | Epidemiology interactive routing |
| `/edit` | Yes | -- | DOCX editing with SuperDoc |
| `/scrape` | Yes | -- | PDF annotation extraction |
| `/deck` | -- | Yes | Presentation deck generation |
| `/project-overview` | -- | Yes | Repository documentation |

## Unique OpenCode Capabilities

- **`/deck`** -- Generate presentation decks directly from task research and plans
- **`/project-overview`** -- Generate comprehensive repository documentation (project-overview.md)

## Setup

### Prerequisites

- OpenCode binary installed and on PATH
- An Anthropic API key or account configured in OpenCode

### Configuration

OpenCode reads its configuration from `.opencode/` in the repository root. The configuration is pre-populated in this repository with the same 9 extensions as Claude Code.

### MCP Servers

OpenCode uses a different MCP registration mechanism than Claude Code. Instead of `claude mcp add`, configure MCP servers in:

- **Project scope**: `.mcp.json` in the repository root
- **User scope**: `~/.opencode/config.json`

Note that OpenCode subagents cannot access project-scoped MCP servers. For subagent access, use user-scope configuration.

## See also

- [extensions.md](extensions.md) -- Extension feature matrix with per-system availability
- [commands.md](commands.md) -- Full command catalog
- [context-and-memory.md](context-and-memory.md) -- Shared memory vault details
- [`.opencode/README.md`](../../.opencode/README.md) -- OpenCode internal architecture hub
- [`.opencode/AGENTS.md`](../../.opencode/AGENTS.md) -- OpenCode quick reference (loaded every session)
