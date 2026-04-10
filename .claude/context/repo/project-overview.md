# Zed Editor Configuration

## Project Overview

This repository contains the Zed editor configuration for a shared workstation on NixOS Linux. The configuration prioritizes standard keybindings (no vim mode) and accessibility for both technical and non-technical users. Claude Code integration via ACP (Agent Communication Protocol) provides AI-assisted editing and project management.

**Purpose**: Maintain a clean, well-documented Zed configuration that works for all collaborators on this machine.

## Technology Stack

**Editor**: Zed (binary: `zeditor` on NixOS)
**Configuration Format**: JSON / JSONC (JSON with comments)
**Platform**: NixOS Linux
**Version**: 0.230.x
**AI Integration**: Claude Code (via ACP extension), Zed built-in agent panel

## Project Structure

```
~/.config/zed/
├── settings.json           # Editor settings (theme, fonts, languages, agent, extensions)
├── keymap.json             # Custom keybindings + default reference comments
├── tasks.json              # Task runner definitions (LibreOffice, git, export)
├── themes/                 # Custom color themes
├── README.md               # Navigation hub and quick start
├── docs/                   # User-facing documentation
│   ├── settings.md         # Configuration reference
│   ├── agent-system.md     # AI systems overview
│   ├── office-workflows.md # Linux Office file workflows
│   └── guides/
│       └── keybindings.md  # Keyboard shortcuts guide
├── specs/                  # Task management artifacts
│   ├── TODO.md             # Task list
│   ├── state.json          # Task state
│   └── {NNN}_{SLUG}/      # Task directories
├── .claude/                # Claude Code agent system
│   ├── CLAUDE.md           # Agent system reference
│   ├── commands/           # Slash commands
│   ├── skills/             # Skill definitions
│   ├── agents/             # Agent definitions
│   ├── rules/              # Auto-applied rules
│   └── context/            # Domain knowledge
└── .memory/                # Learned facts and decisions
```

## Configuration Overview

### Settings (settings.json)

- **Theme**: One Dark
- **Font**: JetBrains Mono, size 14
- **Keybinding base**: VSCode (standard Ctrl-based shortcuts)
- **No vim mode** -- standard keybindings only
- **Auto-installed extensions**: markdown-oxide, markdownlint, codebook, csv, claude-code-extension, nix, toml, git-firefly
- **Agent**: Anthropic Claude models for built-in AI

### Custom Keybindings (keymap.json)

Scheme A (minimal) -- only 6 custom bindings:
- **Pane navigation**: Ctrl+H/J/K/L to move between split panes
- **Line movers**: Alt+J/K to move lines up/down

All other shortcuts are Zed defaults. The keymap.json file includes commented reference sections listing important defaults by category.

### Tasks (tasks.json)

- **Open in LibreOffice**: Opens current file in LibreOffice
- **Export Agent System**: Runs .claude/ export script
- **Git Status**: Shows short git status

## Development Workflow

### Standard Workflow

1. Open project: `zeditor ~/.config/zed`
2. Find files: Ctrl+P
3. Edit with standard shortcuts (Ctrl+C/V/Z, etc.)
4. Use terminal: Ctrl+`
5. Search project: Ctrl+Shift+F
6. Save: Ctrl+S

### AI-Assisted Workflow

Two AI systems are available:

1. **Zed Agent Panel** (Ctrl+?): Built-in AI for quick edits and questions
2. **Claude Code** (via ACP): Full agent system with research, planning, and implementation commands (`/research`, `/plan`, `/implement`)

## Common Tasks

### Editing Configuration

1. Open settings: Ctrl+, (or edit `settings.json` directly)
2. Open keymap: Command palette (Ctrl+Shift+P) then "Open Keymap"
3. Changes take effect immediately on save

### Adding Keybindings

1. Open `keymap.json`
2. Add a new binding object with context and bindings
3. Reference the default list in comments before overriding

### Working with Office Files

1. Use task runner: "Open in LibreOffice" task
2. Use Claude Code: `/convert`, `/table`, `/slides`, `/scrape` commands
3. See `docs/office-workflows.md` for detailed workflows

## Verification Commands

```bash
# Verify Zed is installed
zeditor --version

# Open this project
zeditor ~/.config/zed

# Validate JSON config files
python3 -m json.tool settings.json > /dev/null
python3 -c "import json, re; json.loads(re.sub(r',\s*([}\]])', r'\1', re.sub(r'//.*', '', open('keymap.json').read())))"
python3 -m json.tool tasks.json > /dev/null
```

## Related Documentation

- `docs/guides/keybindings.md` -- Keyboard shortcuts guide for everyday use
- `docs/settings.md` -- Configuration reference
- `docs/agent-system.md` -- AI systems overview
- `docs/office-workflows.md` -- Linux Office file workflows
- `.claude/CLAUDE.md` -- Agent system reference
