# Documentation

Human-readable documentation for this Zed configuration, focused on working in **R** and **Python** with **Claude Code** as the integrated AI assistant. The Claude Code agent system provides a structured task lifecycle for research, planning, and implementation, with domain extensions that add specialized capabilities for epidemiology, grant development, document tools, and more. These guides explain how to install, use, and extend the editor and its AI integrations. See the [main README](../README.md) for a quick-start overview.

**Audience**: These docs are written for day-to-day users of this configuration. For the machine-facing agent system internals (commands, skills, agents, routing), see [`.claude/README.md`](../.claude/README.md). For persistent AI knowledge, see [`.memory/README.md`](../.memory/README.md).

**For R/Python development**: Jump straight to [general/python.md](general/python.md) and [general/R.md](general/R.md) for language setup (pyright + ruff + uv for Python; r-language-server + lintr + styler for R).

--

## Sections

### [General](general/README.md)

Installation, keybindings, settings reference, and language setup. Start here if you are setting up the editor for the first time. Covers Homebrew, Node.js, Zed, the Claude Code CLI, the `claude-acp` bridge, MCP tool installation, and per-language setup guides for [Python](general/python.md) and [R](general/R.md).

### [Agent System](agent-system/README.md)

Claude Code and Zed AI integration: the Agent Panel, the Claude Code terminal interface, the command catalog, context and memory layers, and the three-layer execution architecture. Domain extensions (epidemiology, grant development, document tools, memory, LaTeX/Typst) are first-class capabilities of the agent system, each providing specialized commands, agents, and context.

### [Workflows](workflows/README.md)

End-to-end usage narratives organized by domain. Covers the agent task lifecycle (`/task`, `/research`, `/plan`, `/implement`), epidemiology analysis (`/epi`), grant development (`/grant`, `/budget`, `/funds`, `/timeline`, `/slides`), memory management (`/learn`, `/distill`), and Office document workflows (Word editing, spreadsheet updates, format conversions, PDF annotation extraction).

--

## See also

- [Main README](../README.md) -- Repository overview, quick start, and directory layout
- [`.claude/README.md`](../.claude/README.md) -- Claude Code framework architecture (agent-facing)
- [`.memory/README.md`](../.memory/README.md) -- Shared AI memory vault
