# AI Agent System

This project has two AI systems available. This document explains what each one does and how to get started.

## Installation

### Prerequisites

- macOS 11 (Big Sur) or newer
- An internet connection
- About 20-30 minutes for initial setup

### Step 1: Install Homebrew

Open **WezTerm** (or any terminal) and paste this line:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the on-screen instructions (you may need your Mac password). Close and reopen the terminal when it finishes. Verify with:

```
brew --version
```

### Step 2: Install Zed

```
brew install --cask zed
```

Open Zed from Applications or Spotlight (Cmd+Space, type "Zed") to confirm it launches.

### Step 3: Connect MCP tools

See the [MCP Tool Setup](#mcp-tool-setup) section below.

## Two AI Systems

### 1. Zed Agent Panel (Built-in)

Zed ships with an AI agent panel that can read and edit files in your project.

**Open it**: Press **Cmd+Shift+?** (toggles the right sidebar where the agent panel lives).

**How to use it**:
1. Press **Cmd+Shift+?** to open the panel (or **Cmd+Shift+A**)
2. Press **Cmd+N** to start a new thread (when panel is focused)
3. Type a question or instruction
4. Press **Enter** to send (or **Cmd+Enter** if `agent.use_modifier_to_send` is enabled)

The agent can see your open files and make edits directly. It is good for quick questions and simple edits.

**Inline assist**: Select some text, then press **Cmd+Enter** to open the inline assistant. (Older versions used **Cmd+;** -- verify with **Cmd+K Cmd+S**.)

### Keybindings Quick Reference

| Shortcut | What it does | Context |
|----------|-------------|---------|
| Cmd+Shift+? * | Toggle right sidebar (agent panel) | Global |
| Cmd+N | New thread | Agent panel focused |
| Enter | Send message | Message editor |
| Shift+Alt+J | Recent threads menu | Agent panel |
| Cmd+Shift+H | Full thread history | Agent panel |
| Cmd+Shift+R | Review agent changes (diff) | Agent panel |
| Cmd+Alt+/ | Toggle model selector | Agent panel |
| Alt+L | Cycle favorite models | Agent panel |
| Cmd+Enter | Inline assist | Text selected in editor |
| Tab / Alt+L | Accept edit prediction | Editor |
| Alt+] / Alt+[ | Next/previous edit prediction | Editor |

For the full list including thread navigation, profile management, and external agent setup, see [keybindings.md](keybindings.md#how-do-i-use-the-ai-agent).

### 2. Claude Code (Terminal-based)

Claude Code is a more powerful system that runs in the terminal. It has a full project management framework with research, planning, and implementation workflows.

**Start it**: Open the terminal (Cmd+`) and run `claude` or use the Claude Code extension (auto-installed).

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

### Grant and Research Commands

Claude Code includes specialized commands for academic and research work. Each command asks clarifying questions before producing output, and each creates a resumable task (close Zed and come back later with the same command and task number).

| Command | What it does | Example |
|---------|-------------|---------|
| `/grant "description"` | Create and manage grant proposals | `/grant "NSF CAREER proposal on computational epidemiology"` |
| `/grant N --draft "focus"` | Draft specific proposal sections | `/grant 42 --draft "specific aims page"` |
| `/grant N --budget "guidance"` | Build a budget for an existing grant | `/grant 42 --budget "3-year R01, two postdocs, one graduate student"` |
| `/budget "description"` | Generate a formatted budget spreadsheet (.xlsx) with formulas | `/budget "NIH R01 detailed budget, 5 years, $300K direct costs per year"` |
| `/funds "description"` | Survey funding opportunities with eligibility and deadlines | `/funds "NIH and NSF funding landscape for machine learning in clinical trials"` |
| `/timeline "description"` | Build a project timeline with milestones | `/timeline "R01 project timeline, 5 years, 3 specific aims"` |
| `/talk "description"` | Create research presentations from your materials | `/talk "20-minute conference talk on our survival analysis paper"` |

## MCP Tool Setup

MCP (Model Context Protocol) tools give Claude the ability to edit Word and Excel files properly, preserving formatting and tracked changes. You never interact with these tools directly -- they work behind the scenes when Claude needs them.

### SuperDoc -- Word document editing

SuperDoc lets Claude edit .docx files with full formatting and tracked-changes support. Install it by running this in the terminal:

```
claude mcp add --scope user superdoc -- npx @superdoc-dev/mcp
```

### openpyxl -- Spreadsheet editing

The openpyxl tool lets Claude read and edit .xlsx files (values, formulas, rows). Install it:

```
claude mcp add --scope user openpyxl -- npx @jonemo/openpyxl-mcp
```

### Verify both tools

```
claude mcp list
```

You should see `superdoc` and `openpyxl` in the output. If either is missing, re-run the `claude mcp add` command with `--scope user`.

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
- Claude Code requires a terminal session (Cmd+`) to run
- Some agent system commands (like `/tag`) are user-only and cannot be run by other agents
- Each request uses API credits -- Claude Code runs on a subscription or pay-per-use model; frequent large edits use more credits than simple questions
- Complex formatting (embedded charts, SmartArt) may need manual touch-up in Word after Claude edits

## Related Documentation

- [Settings reference](settings.md) -- Agent block in settings.json
- [Keybindings guide](keybindings.md) -- Agent panel shortcuts
- [Office workflows](office-workflows.md) -- Document editing and conversion commands
- [README](../README.md) -- Navigation hub
