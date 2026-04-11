# Documentation

Human-readable documentation for this Zed configuration on macOS. These guides explain how to install, use, and extend the editor and its AI integrations. See the [main README](../README.md) for a quick-start overview.

**Audience**: These docs are written for day-to-day users of this configuration. For the machine-facing agent system internals (commands, skills, agents, routing), see [`.claude/README.md`](../.claude/README.md). For persistent AI knowledge, see [`.memory/README.md`](../.memory/README.md).

--

## Sections

### [General](general/README.md)

Installation, keybindings, and settings reference. Start here if you are setting up the editor for the first time. Covers Homebrew, Node.js, Zed, the Claude Code CLI, the `claude-acp` bridge, and MCP tool installation.

### [Agent System](agent-system/README.md)

Claude Code and Zed AI integration: the Agent Panel, the Claude Code terminal interface, the command catalog, context and memory layers, and the three-layer execution architecture. This section also covers the epidemiology, grant development, memory, and Python extensions.

### [Workflows](workflows/README.md)

End-to-end usage narratives organized by domain. Covers the agent task lifecycle (`/task`, `/research`, `/plan`, `/implement`), epidemiology analysis (`/epi`), grant development (`/grant`, `/budget`, `/funds`, `/timeline`, `/slides`), memory management (`/learn`), and Office document workflows (Word editing, spreadsheet updates, format conversions, PDF annotation extraction).

--

## See also

- [Main README](../README.md) -- Repository overview, quick start, and directory layout
- [`.claude/README.md`](../.claude/README.md) -- Claude Code framework architecture (agent-facing)
- [`.memory/README.md`](../.memory/README.md) -- Shared AI memory vault
