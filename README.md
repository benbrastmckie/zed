# Zed IDE Configuration for R and Python with Claude Code

A Zed editor configuration for macOS optimized for working in **R** and **Python** with **Claude Code** as the integrated AI assistant. Standard keybindings (no vim mode), minimal custom shortcuts, first-class language server support (pyright + ruff for Python, r-language-server + lintr + styler for R), and an agent system that helps you write, test, and refactor code from a single Ctrl+Shift+A away.

Domain extensions for epidemiology research, grant development, memory capture, and Office document editing are also available and can be layered on top of the core R/Python workflow.

**Platform**: macOS 11 (Big Sur) or newer.

## Quick Start

1. Install [Homebrew](https://brew.sh), then `brew install --cask zed`
2. Open Zed from Applications or Spotlight (Cmd+Space, type "Zed")
3. Extensions install automatically on first launch (including `python`, `ruff`, `r`)
4. Set up your languages: [Python](docs/toolchain/python.md) and [R](docs/toolchain/r.md)
5. Theme is One Dark; font is Fira Code

For the full installation walkthrough, including MCP tool setup for Office file editing, see [docs/general/installation.md](docs/general/installation.md).

**Essential shortcuts to know right away**:

| Shortcut | What it does |
|----------|-------------|
| Ctrl+Shift+A | Open Claude Code (primary AI interface) |
| Cmd+P | Open any file by name |
| Cmd+S | Save |
| Cmd+Shift+F | Search across all files |
| Cmd+` | Toggle terminal |
| Cmd+Shift+P | Command palette (search for any command) |

For the full shortcuts guide, see [docs/general/keybindings.md](docs/general/keybindings.md).

## Example Outputs

To see concretely what this configuration produces, two runnable end-to-end examples are included:

| Example | Description |
|---------|-------------|
| [examples/epi-study/](examples/epi-study/README.md) | Synthetic RCT analysis produced by running the `/epi` command end to end -- R scripts, reports, and logs |
| [examples/epi-slides/](examples/epi-slides/README.md) | 14-slide Slidev conference deck walking through the `epi-study` example as a `/epi` workflow showcase |

## Languages

This configuration is built around first-class R and Python development inside Zed, with Claude Code as your writing, testing, and refactoring partner.

### Python

- **Language servers**: `pyright` (type checking) + `ruff` (lint + format)
- **Package/env manager**: `uv` (recommended)
- **Auto-formatting**: on save via ruff
- **Setup guide**: [docs/toolchain/python.md](docs/toolchain/python.md)

### R

- **Language server**: `r-language-server` (diagnostics + rich documentation)
- **Lint / style**: `lintr` + `styler`
- **Auto-formatting**: on save via r-language-server
- **Setup guide**: [docs/toolchain/r.md](docs/toolchain/r.md)

## Claude Code Commands

Claude Code provides structured research and development workflows. Open it with **Ctrl+Shift+A**, then use these commands.

**Core commands for R and Python development**:

| Command | What it does |
|---------|-------------|
| `/research` | Investigate a topic, library, or codebase and write a report |
| `/plan` | Create a phased implementation plan from research |
| `/implement` | Execute a plan, resuming from any incomplete phase |
| `/review` | Review code and produce an analysis report |
| `/learn` | Save knowledge to the memory vault for future sessions |
| `/convert` | Convert between PDF, DOCX, Markdown, and other formats |

**Also available -- domain extensions**:

| Command | What it does |
|---------|-------------|
| `/epi` | Design and run epidemiology studies in R |
| `/grant` | Develop grant proposals with narrative drafting |
| `/budget` | Generate grant budgets with justification |
| `/funds` | Analyze funding landscape and funder portfolios |
| `/timeline` | Plan research project timelines |
| `/slides` | Create research talks and presentations |

For the full command catalog, see [docs/agent-system/commands.md](docs/agent-system/commands.md).

## Directory Layout

```
~/.config/zed/
├── settings.json           # Editor settings (theme, fonts, extensions, AI)
├── keymap.json             # Custom shortcuts + default reference
├── tasks.json              # Task runner (git, export)
├── themes/                 # Custom color themes
├── docs/                   # Documentation
│   ├── general/            # Installation, keybindings, settings, R and Python setup
│   ├── agent-system/       # AI systems overview, commands, architecture
│   └── workflows/          # Agent lifecycle, epi, grants, Office file workflows
├── specs/                  # Claude Code task management
├── .claude/                # Claude Code agent system config
└── .memory/                # AI memory vault
```

## Documentation

| Document | Description |
|----------|-------------|
| [General](docs/general/README.md) | Installation, keybindings, settings, and R/Python setup for this Zed configuration on macOS |
| [Python Setup](docs/toolchain/python.md) | Python + uv + ruff + pyright configuration for Zed on macOS |
| [R Setup](docs/toolchain/r.md) | R + languageserver + lintr + styler configuration for Zed on macOS |
| [Agent System](docs/agent-system/README.md) | Zed agent + Claude Code overview, workflows, command catalog, memory, and architecture |
| [Workflows](docs/workflows/README.md) | Agent task lifecycle for R/Python development, plus epidemiology, grant, and Office file workflows |
| [Agent System Config](.claude/README.md) | Claude Code framework architecture, skills, agents, and extension system |
| [Memory Vault](.memory/README.md) | Shared AI memory vault for persistent knowledge across sessions |

## Custom Keybindings

This setup uses **Scheme A** -- a minimal set of custom shortcuts. Everything else uses Zed defaults.

| Shortcut | Action |
|----------|--------|
| Ctrl+Shift+A | Launch Claude Code CLI (primary AI interface) |
| Ctrl+H/L | Move focus between split panes (left/right) |
| Alt+J/K | Move current line down/up |

(The pane-navigation bindings intentionally use Ctrl so they do not collide with macOS system shortcuts.)

### Adding More Keybindings

Open `keymap.json` (press Cmd+P and type "keymap"). The file has two sections:

1. **Custom bindings** at the top -- your additions go here
2. **Default reference** in comments at the bottom -- check this before adding to avoid conflicts

See [docs/general/settings.md](docs/general/settings.md) for the keymap file format and context scoping.

## AI Integration

**Claude Code** (Ctrl+Shift+A): The primary AI interface. Helps you write, test, debug, and refactor R and Python code through the full project lifecycle with `/research`, `/plan`, and `/implement`. Also provides domain extensions for epidemiology (`/epi`), grant and research development (`/grant`, `/budget`, `/funds`, `/timeline`, `/slides`), and Office document editing (`/edit`, `/convert`).

**Zed Agent Panel** (Ctrl+?): Built-in AI sidebar for quick questions and inline edits. See [docs/agent-system/zed-agent-panel.md](docs/agent-system/zed-agent-panel.md).

## Platform Notes

- **macOS**: Install via Homebrew (`brew install --cask zed`). Open from Applications or Spotlight.
- **macOS keybindings**: All shortcuts use Cmd (shown as in menus). The Option key corresponds to Alt in custom bindings.
- **Config location**: `~/.config/zed/` -- standard for Zed on macOS.
- **Extensions**: Auto-installed on launch via `auto_install_extensions` in settings.json (`python`, `ruff`, `r`, and more).
- **Language tooling**: Install Python and R via Homebrew; see [docs/toolchain/python.md](docs/toolchain/python.md) and [docs/toolchain/r.md](docs/toolchain/r.md).
- **Office editing**: Requires SuperDoc and openpyxl MCP tools. See [docs/general/installation.md](docs/general/installation.md#install-mcp-tools) for setup and [docs/workflows/](docs/workflows/README.md) for workflows.

## Related

- [Claude Code System](.claude/CLAUDE.md) -- Full agent system reference (commands, skills, agents)
- [Task List](specs/TODO.md) -- Current project tasks
