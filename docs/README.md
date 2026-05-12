# Documentation

Human-readable documentation for this Zed configuration, focused on working in **R** and **Python** with two AI agent systems -- **Claude Code** and **OpenCode**. Both systems provide a structured task lifecycle for research, planning, and implementation, sharing the same 10 domain extensions for epidemiology, grant development, document tools, and more. These guides explain how to install, use, and extend the editor and its AI integrations. See the [main README](../README.md) for a quick-start overview.

**Audience**: These docs are written for day-to-day users of this configuration. For the machine-facing agent system internals, see [`.claude/docs/README.md`](../.claude/docs/README.md) (Claude Code) or [`.opencode/README.md`](../.opencode/docs/README.md) (OpenCode). For persistent AI knowledge, see [`.memory/README.md`](../.memory/README.md).

**For R/Python development**: Jump straight to [toolchain/python.md](toolchain/python.md) and [toolchain/r.md](toolchain/r.md) for language setup (pyright + ruff + uv for Python; r-language-server + lintr + styler for R).

--

## Sections

### [General](general/README.md)

Installation, keybindings, settings reference, and language setup. Start here if you are setting up the editor for the first time. Covers Homebrew, Node.js, Zed, the Claude Code CLI, the `claude-acp` bridge, MCP tool installation, and per-language setup guides for [Python](toolchain/python.md) and [R](toolchain/r.md).

### [Agent System](agent-system/README.md)

Claude Code, OpenCode, and Zed Agent Panel: the three AI access methods, the command catalog, context and memory layers, and the three-layer execution architecture. Domain extensions (epidemiology, grant development, document tools, memory, LaTeX/Typst, Python, web) are first-class capabilities shared by both agent systems, each providing specialized commands, agents, and context.

### [Workflows](workflows/README.md)

End-to-end usage narratives organized by domain. Covers the agent task lifecycle (`/task`, `/research`, `/plan`, `/implement`), web development (Astro 5 + Tailwind CSS v4), epidemiology analysis (`/epi`), grant development (`/grant`, `/budget`, `/funds`, `/timeline`, `/slides`), memory management (`/learn`, `/distill`), and Office document workflows (Word editing, spreadsheet updates, format conversions, PDF annotation extraction).

--

## See also

- [Main README](../README.md) -- Repository overview, quick start, and directory layout
- [AI Agent Systems Comparison](ai_agent_systems.md) -- Side-by-side comparison of Claude Code and OpenCode
- [`.claude/docs/README.md`](../.claude/docs/README.md) -- Claude Code framework architecture (agent-facing)
- [`.opencode/README.md`](../.opencode/docs/README.md) -- OpenCode framework architecture (agent-facing)
- [`.memory/README.md`](../.memory/README.md) -- Shared AI memory vault (used by both systems)
