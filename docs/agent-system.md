# AI Agent System

This project has two AI systems available. This document explains what each one does and how to get started.

## Two AI Systems

### 1. Zed Agent Panel (Built-in)

Zed ships with an AI agent panel that can read and edit files in your project.

**Open it**: Press **Ctrl+?**

**How to use it**:
1. Press Ctrl+? to open the panel
2. Press Ctrl+N to start a new conversation
3. Type a question or instruction
4. Press Ctrl+Enter to send

The agent can see your open files and make edits directly. It is good for quick questions and simple edits.

**Inline assist**: Select some text, then press **Ctrl+;** to ask the AI to modify just that selection.

### 2. Claude Code (Terminal-based)

Claude Code is a more powerful system that runs in the terminal. It has a full project management framework with research, planning, and implementation workflows.

**Start it**: Open the terminal (Ctrl+`) and run `claude` or use the Claude Code extension (auto-installed).

**Key commands**:

| Command | What it does |
|---------|-------------|
| `/research N` | Investigate a topic, search the web, read docs |
| `/plan N` | Create a step-by-step implementation plan |
| `/implement N` | Execute a plan, creating and modifying files |
| `/review` | Analyze the codebase for issues |
| `/convert file.pdf` | Convert documents between formats |
| `/table data.xlsx` | Convert spreadsheets to tables |

The `N` is a task number. Tasks are tracked in `specs/TODO.md`.

## Project Discovery

When Claude Code starts in this directory, it automatically reads:

- `.claude/CLAUDE.md` -- The main configuration file describing all available commands, skills, and agents
- `.claude/context/repo/project-overview.md` -- This project's structure and conventions
- `.claude/rules/` -- Behavioral rules applied automatically based on file paths

You do not need to explain the project structure to Claude Code each time -- it discovers this on its own.

## Memory Vault

Claude Code maintains a memory vault in `.memory/` that stores facts, decisions, and discoveries from past sessions. This means it can recall context from previous work.

To add a memory manually: `/learn "some fact or decision"`

To use memories during research: `/research N --remember`

## Configuration

The agent system configuration lives in `.claude/`:

```
.claude/
├── CLAUDE.md       # Main reference (start here)
├── commands/       # Slash command definitions
├── skills/         # Skill routing logic
├── agents/         # Agent behavior definitions
├── rules/          # Auto-applied behavioral rules
├── context/        # Domain knowledge files
└── extensions/     # Language-specific support
```

For the complete system documentation, see [.claude/CLAUDE.md](../.claude/CLAUDE.md).

## Known Limitations

- The Zed agent panel and Claude Code are independent -- they do not share conversation history
- Claude Code requires a terminal session (Ctrl+`) to run
- Some agent system commands (like `/tag`) are user-only and cannot be run by other agents
- MCP context servers are not yet configured in this setup (may be added later)

## Related Documentation

- [Settings reference](settings.md) -- Agent block in settings.json
- [Keybindings guide](guides/keybindings.md) -- Agent panel shortcuts
- [Office workflows](office-workflows.md) -- Document conversion commands
- [README](../README.md) -- Navigation hub
