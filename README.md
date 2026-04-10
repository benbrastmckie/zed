# Zed Configuration

Zed editor configuration for macOS. Standard keybindings (no vim mode), minimal custom shortcuts, and full AI integration via Claude Code.

**Platform**: macOS 11 (Big Sur) or newer.

## Quick Start

1. Install [Homebrew](https://brew.sh), then `brew install --cask zed`
2. Open Zed from Applications or Spotlight (Cmd+Space, type "Zed")
3. Extensions install automatically on first launch (Markdown, Claude Code, and more)
4. Theme is One Dark; font is JetBrains Mono

For the full installation walkthrough, including MCP tool setup for Office file editing, see [docs/installation.md](docs/installation.md).

**Essential shortcuts to know right away**:

| Shortcut | What it does |
|----------|-------------|
| Cmd+P | Open any file by name |
| Cmd+S | Save |
| Cmd+Z | Undo |
| Cmd+Shift+F | Search across all files |
| Cmd+` | Toggle terminal |
| Cmd+Shift+? | Toggle AI agent panel |
| Cmd+Shift+P | Command palette (search for any command) |

For the full shortcuts guide, see [docs/keybindings.md](docs/keybindings.md).

## Directory Layout

```
~/.config/zed/
├── settings.json           # Editor settings (theme, fonts, extensions, AI)
├── keymap.json             # Custom shortcuts + default reference
├── tasks.json              # Task runner (git, export)
├── themes/                 # Custom color themes
├── docs/                   # Documentation
│   ├── keybindings.md      # Keyboard shortcuts guide
│   ├── settings.md         # Configuration reference
│   ├── installation.md     # Installation: Zed, Claude Code CLI, claude-acp, MCP tools
│   ├── agent-system/       # AI systems overview, workflows, commands, architecture
│   └── office-workflows.md # Working with Office files on macOS
├── specs/                  # Claude Code task management
├── .claude/                # Claude Code agent system config
└── .memory/                # AI memory vault
```

## Documentation

| Document | Description |
|----------|-------------|
| [Keybindings Guide](docs/keybindings.md) | Everyday keyboard shortcuts (Cmd-based), organized by task |
| [Settings Reference](docs/settings.md) | What each config option does and how to change it |
| [Installation](docs/installation.md) | Install Zed, the Claude Code CLI, the `claude-acp` bridge, and the MCP tools for Office editing |
| [Agent System](docs/agent-system/README.md) | Zed agent + Claude Code overview, workflows, command catalog, memory, and architecture |
| [Office Workflows](docs/office-workflows.md) | Word, Excel, PowerPoint, and PDF workflows on macOS, including tracked changes, batch edits, OneDrive tips, and troubleshooting |
| [Agent System Config](.claude/CLAUDE.md) | Full Claude Code system reference (commands, skills, agents) |

## Custom Keybindings

This setup uses **Scheme A** -- a minimal set of custom shortcuts. Everything else uses Zed defaults.

| Shortcut | Action |
|----------|--------|
| Ctrl+H/J/K/L | Move focus between split panes |
| Alt+J/K | Move current line down/up |

(The pane-navigation bindings intentionally use Ctrl so they do not collide with macOS system shortcuts.)

### Adding More Keybindings

Open `keymap.json` (press Cmd+P and type "keymap"). The file has two sections:

1. **Custom bindings** at the top -- your additions go here
2. **Default reference** in comments at the bottom -- check this before adding to avoid conflicts

See [docs/settings.md](docs/settings.md) for the keymap file format and context scoping.

## AI Integration

**Zed Agent Panel** (Cmd+Shift+?): Built-in AI for quick questions and edits. See [docs/agent-system/zed-agent-panel.md](docs/agent-system/zed-agent-panel.md).

**Claude Code** (terminal): Full project management with `/research`, `/plan`, `/implement`, grant/research commands (`/grant`, `/budget`, `/funds`, `/timeline`, `/talk`), and Office document editing (`/edit`, `/convert`). Start it in the terminal (Cmd+`).

## Platform Notes

- **macOS**: Install via Homebrew (`brew install --cask zed`). Open from Applications or Spotlight.
- **macOS keybindings**: All shortcuts use Cmd (shown as in menus). The Option key corresponds to Alt in custom bindings.
- **Config location**: `~/.config/zed/` -- standard for Zed on macOS.
- **Extensions**: Auto-installed on launch via `auto_install_extensions` in settings.json.
- **Office editing**: Requires SuperDoc and openpyxl MCP tools. See [docs/installation.md](docs/installation.md#install-mcp-tools) for setup and [docs/office-workflows.md](docs/office-workflows.md) for workflows.

## Related

- [Claude Code System](.claude/CLAUDE.md) -- Full agent system documentation
- [Task List](specs/TODO.md) -- Current project tasks
