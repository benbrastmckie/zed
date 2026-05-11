# Agent System

This project hosts two AI agent systems -- **Claude Code** and **OpenCode** -- that share the same task management (`specs/`), memory vault (`.memory/`), and 9 domain extensions. A third access method, Zed's built-in **Agent Panel**, provides lightweight in-editor assistance. This directory is an orientation guide. For the authoritative power-user references, see [`.claude/CLAUDE.md`](../../.claude/CLAUDE.md) (Claude Code) and [`.opencode/AGENTS.md`](../../.opencode/AGENTS.md) (OpenCode).

## Three AI access methods

| System | How to open | Strengths | When to use |
|--------|-------------|-----------|-------------|
| Claude Code | Ctrl+Shift+A (terminal task) or Agent Panel thread | Full task lifecycle, structured artifacts, multi-file refactors, grant & research workflows | Multi-step work, anything worth tracking in `specs/TODO.md` |
| OpenCode | Terminal (`opencode`) | Same task lifecycle and extensions as Claude Code; alternative terminal interface | Same as Claude Code; use whichever interface you prefer |
| Zed Agent Panel | Ctrl+? | Fast, inline edits, knows open files | Quick questions, single-file tweaks, inline assist |

Claude Code and OpenCode both run on Claude models and share the same `specs/` task list, `.memory/` vault, and 9 extensions. They do **not** share conversation history with each other or with the Agent Panel. Use the Agent Panel for a 30-second question; use Claude Code or OpenCode when you want research, a plan, and a commit trail. See [extensions.md](extensions.md) for the full feature matrix and [opencode.md](opencode.md) for OpenCode-specific setup.

## Quick start: your first task

Assuming [installation](../general/installation.md) is complete and Claude Code or OpenCode is authenticated:

1. Open Claude Code with Ctrl+Shift+A (or open a Claude Code thread in the Agent Panel with Ctrl+?). Alternatively, run `opencode` in a terminal.
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

Each command produces a structured artifact under `specs/001_add_dark_mode_toggle/` and commits its work. You can stop between any two steps and resume later -- the task state machine tracks where you are. See [agent-lifecycle.md](../workflows/agent-lifecycle.md) for the full state machine and [commands.md](commands.md) for the rest of the command catalog.

## Navigation

Files in this directory (`docs/agent-system/`):

- **[zed-agent-panel.md](zed-agent-panel.md)** — Opening the panel, the built-in agent vs the Claude Code thread, how the `claude-acp` bridge works under the hood, authentication, inline assist, edit predictions, troubleshooting.
- **[agent-lifecycle.md](../workflows/agent-lifecycle.md)** — Task lifecycle state machine and the seven main-workflow commands that drive it.
- **[commands.md](commands.md)** — Full command catalog grouped by topic, each with a one-line summary, example, and per-system availability.
- **[context-and-memory.md](context-and-memory.md)** — The two memory layers (`.memory/` vault vs auto-memory), the five context layers, and where new content belongs.
- **[architecture.md](architecture.md)** — Three-layer execution pipeline, checkpoint execution, session IDs, state files, and routing.
- **[extensions.md](extensions.md)** — Extension feature matrix covering all 9 shared extensions, per-system availability, and naming differences.
- **[opencode.md](opencode.md)** — OpenCode setup, configuration, command comparison, shared state model, and unique capabilities.

Companion files outside this directory:

- [../general/installation.md](../general/installation.md) — Installing Zed, Claude Code CLI, `claude-acp`, and MCP tools
- [../general/settings.md](../general/settings.md#agent_servers) — `agent_servers` configuration reference
- [../general/keybindings.md](../general/keybindings.md#how-do-i-use-the-ai-agent) — Agent Panel keybindings

## Extensions

The agent system includes domain-specific extensions that provide specialized research and implementation capabilities:

- **Epidemiology** -- R-based study design, causal inference, statistical modeling, and reporting (STROBE, CONSORT). Use `/epi` to start a study. R language setup is covered in [../general/R.md](../general/R.md).
- **Present** -- Grant proposals (`/grant`), budgets (`/budget`), timelines (`/timeline`), funding analysis (`/funds`), and research talks (`/slides`). Slide planning uses an interactive 5-stage design review via `skill-slide-planning`. Use `/slides N --critic` for interactive slide critique with rubric evaluation via `skill-slide-critic`.
- **Memory** -- Persistent knowledge vault (`/learn`, `--remember` flag on `/research`).
- **Filetypes** -- Office document conversion and editing (`/convert`, `/edit`, `/table`, `/scrape`).
- **LaTeX / Typst** -- Document typesetting with compilation support.

All extensions are pre-merged into the active configuration; there is no manual loading step.

## Zed adaptations

This workspace adapts the upstream `.claude/` configuration with one intentional deviation:

- **No `.claude/extensions/` directory** -- Extensions are tracked via the flat `.claude/extensions.json` file rather than a directory tree. References to `.claude/extensions/*/context/` in `.claude/CLAUDE.md` do not apply here.

## See also

- [`.claude/docs/README.md`](../../.claude/docs/README.md) -- Architecture navigation hub for the Claude Code framework
- [`.claude/CLAUDE.md`](../../.claude/CLAUDE.md) -- Always-loaded quick reference; canonical command list
- [`.claude/docs/guides/user-guide.md`](../../.claude/docs/guides/user-guide.md) -- Comprehensive command reference with examples
- [`.opencode/README.md`](../../.opencode/README.md) -- OpenCode architecture navigation hub
- [`.opencode/AGENTS.md`](../../.opencode/AGENTS.md) -- OpenCode quick reference
- [`.memory/README.md`](../../.memory/README.md) -- Shared AI memory vault (used by both systems)
