# Zed Configuration

Zed editor configuration for a shared NixOS workstation. Standard keybindings (no vim mode), minimal custom shortcuts, and full AI integration via Claude Code.

**Platform**: NixOS Linux -- the Zed binary is `zeditor` (not `zed`).

## Quick Start

1. Open this project: `zeditor ~/.config/zed`
2. Extensions install automatically on first launch (Markdown, Nix, Claude Code, and more)
3. Theme is One Dark; font is JetBrains Mono

**Essential shortcuts to know right away**:

| Shortcut | What it does |
|----------|-------------|
| Ctrl+P | Open any file by name |
| Ctrl+S | Save |
| Ctrl+Z | Undo |
| Ctrl+Shift+F | Search across all files |
| Ctrl+` | Toggle terminal |
| Ctrl+? | Toggle AI agent panel |
| Ctrl+Shift+P | Command palette (search for any command) |

For the full shortcuts guide, see [docs/guides/keybindings.md](docs/guides/keybindings.md).

## Directory Layout

```
~/.config/zed/
├── settings.json           # Editor settings (theme, fonts, extensions, AI)
├── keymap.json             # Custom shortcuts + default reference
├── tasks.json              # Task runner (LibreOffice, git, export)
├── themes/                 # Custom color themes
├── docs/                   # Documentation
│   ├── settings.md         # Configuration reference
│   ├── agent-system.md     # AI systems overview
│   ├── office-workflows.md # Working with Office files
│   └── guides/
│       └── keybindings.md  # Keyboard shortcuts guide
├── specs/                  # Claude Code task management
├── .claude/                # Claude Code agent system config
└── .memory/                # AI memory vault
```

## Documentation

| Document | Description |
|----------|-------------|
| [Keybindings Guide](docs/guides/keybindings.md) | Everyday keyboard shortcuts, organized by task |
| [Settings Reference](docs/settings.md) | What each config option does and how to change it |
| [Agent System](docs/agent-system.md) | How to use the two AI systems (Zed agent + Claude Code) |
| [Office Workflows](docs/office-workflows.md) | Working with Word, Excel, PowerPoint, and PDF files |
| [Agent System Config](.claude/CLAUDE.md) | Full Claude Code system reference (commands, skills, agents) |

## Custom Keybindings

This setup uses **Scheme A** -- a minimal set of 6 custom shortcuts. Everything else uses Zed defaults.

| Shortcut | Action |
|----------|--------|
| Ctrl+H/J/K/L | Move focus between split panes |
| Alt+J/K | Move current line down/up |

### Adding More Keybindings

Open `keymap.json` (press Ctrl+P and type "keymap"). The file has two sections:

1. **Custom bindings** at the top -- your additions go here
2. **Default reference** in comments at the bottom -- check this before adding to avoid conflicts

See [docs/settings.md](docs/settings.md) for the keymap file format and context scoping.

## AI Integration

**Zed Agent Panel** (Ctrl+?): Built-in AI for quick questions and edits. See [docs/agent-system.md](docs/agent-system.md).

**Claude Code** (terminal): Full project management with `/research`, `/plan`, `/implement`, and document conversion commands. Start it in the terminal (Ctrl+`).

## Platform Notes

- **NixOS**: The binary is `zeditor`, not `zed`. Installed via the NixOS package manager.
- **Linux keybindings**: All shortcuts use Ctrl (not Cmd).
- **Config location**: `~/.config/zed/` -- this is standard for Linux.
- **Extensions**: Auto-installed on launch via `auto_install_extensions` in settings.json.

## Related

- [Claude Code System](.claude/CLAUDE.md) -- Full agent system documentation
- [Task List](specs/TODO.md) -- Current project tasks
