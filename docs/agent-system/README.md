# Agent System

This project hosts two AI systems: Zed's built-in Agent Panel for quick, in-editor assistance, and a terminal-or-panel-based Claude Code framework with full research, planning, and implementation workflows. This directory is an orientation guide. For the authoritative power-user reference, see [`.claude/CLAUDE.md`](../../.claude/CLAUDE.md).

## Two AI systems

| System | How to open | Strengths | When to use |
|--------|-------------|-----------|-------------|
| Zed Agent Panel | Cmd+Shift+? | Fast, inline edits, knows open files | Quick questions, single-file tweaks, inline assist |
| Claude Code | Terminal (`claude`) or Zed Agent Panel Claude Code thread | Full task lifecycle, structured artifacts, multi-file refactors, grant & research workflows | Multi-step work, anything worth tracking in `specs/TODO.md` |

Both run on Claude models. They do **not** share conversation history. Use the panel for a 30-second question; use Claude Code when you want research, a plan, and a commit trail.

## Navigation

Files in this directory (`docs/agent-system/`):

- **[zed-agent-panel.md](zed-agent-panel.md)** — Opening the panel, the built-in agent vs the Claude Code thread, how the `claude-acp` bridge works under the hood, authentication, inline assist, edit predictions, troubleshooting.
- **[agent-lifecycle.md](../workflows/agent-lifecycle.md)** — Task lifecycle state machine and the seven main-workflow commands that drive it.
- **[commands.md](commands.md)** — Full catalog of the Claude Code command catalog grouped by topic, each with a one-line summary, example, and link into `.claude/docs/`.
- **[context-and-memory.md](context-and-memory.md)** — The two memory layers (`.memory/` vault vs auto-memory), the five context layers, and where new content belongs.
- **[architecture.md](architecture.md)** — Three-layer execution pipeline, checkpoint execution, session IDs, state files, and routing.

Companion files outside this directory:

- [../general/installation.md](../general/installation.md) — Installing Zed, Claude Code CLI, `claude-acp`, and MCP tools
- [../general/settings.md](../general/settings.md#agent_servers) — `agent_servers` configuration reference
- [../general/keybindings.md](../general/keybindings.md#how-do-i-use-the-ai-agent) — Agent Panel keybindings

## Zed adaptations

This workspace adapts the upstream `.claude/` configuration (designed for the neovim Claude Code plugin) with three intentional deviations:

- **No extension loader keybinding** — The neovim config uses `<leader>ac` to load extensions on demand. In Zed, all extensions are pre-merged into the active configuration; there is no equivalent keybinding.
- **No `Co-Authored-By` trailer** — Git commits in this workspace omit the `Co-Authored-By` line per user preference.
- **No `.claude/extensions/` directory** — Extensions are tracked via the flat `.claude/extensions.json` file rather than a directory tree. References to `.claude/extensions/*/context/` in `.claude/CLAUDE.md` do not apply here.

## Quick start: your first task

Assuming [installation](../general/installation.md) is complete and the Claude Code thread is authenticated:

1. In the Agent Panel (Cmd+Shift+?), open a Claude Code thread.
2. Create a task:
   ```
   /task "Add a dark-mode toggle to the settings page"
   ```
3. Research it:
   ```
   /research 1
   ```
4. Plan it:
   ```
   /plan 1
   ```
5. Implement it:
   ```
   /implement 1
   ```

Each command produces a structured artifact under `specs/001_add_dark_mode_toggle/` and commits its work. You can stop between any two steps and resume later — the task state machine tracks where you are. See [agent-lifecycle.md](../workflows/agent-lifecycle.md) for the full state machine and [commands.md](commands.md) for the rest of the command catalog.

## See also

- [`.claude/README.md`](../../.claude/README.md) — Architecture navigation hub for the Claude Code framework
- [`.claude/CLAUDE.md`](../../.claude/CLAUDE.md) — Always-loaded quick reference; canonical command list
- [`.claude/docs/guides/user-guide.md`](../../.claude/docs/guides/user-guide.md) — Comprehensive command reference with examples
