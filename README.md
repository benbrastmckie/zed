# Zed + Claude Code for Epidemiology and Medical Research

A Zed editor configuration for macOS with full Claude Code integration, designed for epidemiology research, grant development, and medical research workflows. Standard keybindings (no vim mode), minimal custom shortcuts, and AI-powered research automation.

**Platform**: macOS 11 (Big Sur) or newer.

## Quick Start

1. Install [Homebrew](https://brew.sh), then `brew install --cask zed`
2. Open Zed from Applications or Spotlight (Cmd+Space, type "Zed")
3. Extensions install automatically on first launch
4. Theme is One Dark; font is Fira Code

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

## Research Commands

Claude Code provides structured research and development workflows. Open it with **Ctrl+Shift+A**, then use these commands:

| Command | What it does |
|---------|-------------|
| `/epi` | Design and run epidemiology studies in R |
| `/grant` | Develop grant proposals with narrative drafting |
| `/budget` | Generate grant budgets with justification |
| `/funds` | Analyze funding landscape and funder portfolios |
| `/timeline` | Plan research project timelines |
| `/slides` | Create research talks and presentations |
| `/learn` | Save knowledge to the memory vault for future sessions |
| `/convert` | Convert between PDF, DOCX, Markdown, and other formats |

For the full command catalog, see [docs/agent-system/commands.md](docs/agent-system/commands.md).

## Directory Layout

```
~/.config/zed/
├── settings.json           # Editor settings (theme, fonts, extensions, AI)
├── keymap.json             # Custom shortcuts + default reference
├── tasks.json              # Task runner (git, export)
├── themes/                 # Custom color themes
├── docs/                   # Documentation
│   ├── general/            # Installation, keybindings, settings reference
│   ├── agent-system/       # AI systems overview, commands, architecture
│   └── workflows/          # Agent lifecycle, epi, grants, Office file workflows
├── specs/                  # Claude Code task management
├── .claude/                # Claude Code agent system config
└── .memory/                # AI memory vault
```

## Documentation

| Document | Description |
|----------|-------------|
| [General](docs/general/README.md) | Installation, keybindings, and settings reference for this Zed configuration on macOS |
| [Agent System](docs/agent-system/README.md) | Zed agent + Claude Code overview, workflows, command catalog, memory, and architecture |
| [Workflows](docs/workflows/README.md) | Agent task lifecycle, epidemiology analysis, grant development, and Office file workflows on macOS |
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

**Claude Code** (Ctrl+Shift+A): The primary AI interface. Full project management with `/research`, `/plan`, `/implement`, epidemiology workflows (`/epi`), grant/research commands (`/grant`, `/budget`, `/funds`, `/timeline`, `/slides`), and Office document editing (`/edit`, `/convert`).

**Zed Agent Panel** (Ctrl+?): Built-in AI sidebar for quick questions and edits. See [docs/agent-system/zed-agent-panel.md](docs/agent-system/zed-agent-panel.md).

## Platform Notes

- **macOS**: Install via Homebrew (`brew install --cask zed`). Open from Applications or Spotlight.
- **macOS keybindings**: All shortcuts use Cmd (shown as in menus). The Option key corresponds to Alt in custom bindings.
- **Config location**: `~/.config/zed/` -- standard for Zed on macOS.
- **Extensions**: Auto-installed on launch via `auto_install_extensions` in settings.json.
- **Office editing**: Requires SuperDoc and openpyxl MCP tools. See [docs/general/installation.md](docs/general/installation.md#install-mcp-tools) for setup and [docs/workflows/](docs/workflows/README.md) for workflows.

## Related

- [Claude Code System](.claude/CLAUDE.md) -- Full agent system reference (commands, skills, agents)
- [Task List](specs/TODO.md) -- Current project tasks
