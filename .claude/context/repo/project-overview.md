# Zed Configuration Project

## Project Overview

This is a Zed editor configuration for macOS with full Claude Code integration, designed for epidemiology research, grant development, and medical research workflows. The configuration uses standard keybindings (no vim mode), minimal custom shortcuts, and AI-powered research automation.

**Purpose**: Provide a productive Zed + Claude Code environment for epidemiology and medical research, with structured workflows for study design, grant proposals, and document management.

## Technology Stack

**Editor:** Zed
**AI Framework:** Claude Code (terminal CLI + ACP bridge)
**Platform:** macOS 11+
**Theme:** One Dark
**Font:** Fira Code

## Project Structure

```
~/.config/zed/
├── settings.json           # Editor settings (theme, fonts, extensions, AI)
├── keymap.json             # Custom shortcuts + default reference
├── tasks.json              # Task runner (git, export, Claude Code)
├── themes/                 # Custom color themes
├── docs/                   # Human-readable documentation
│   ├── general/            # Installation, keybindings, settings reference
│   ├── agent-system/       # AI systems overview, commands, architecture
│   └── workflows/          # Agent lifecycle, epi, grants, Office file workflows
├── specs/                  # Claude Code task management
│   ├── TODO.md             # Task list
│   ├── state.json          # Task state
│   └── {NNN}_{SLUG}/      # Task artifacts (reports, plans, summaries)
├── .claude/                # Claude Code agent system config
│   ├── CLAUDE.md           # Always-loaded quick reference
│   ├── README.md           # Architecture navigation hub
│   ├── commands/           # Slash commands
│   ├── skills/             # Skill definitions
│   ├── agents/             # Agent definitions
│   ├── rules/              # Auto-applied rules
│   ├── context/            # Domain knowledge
│   └── docs/               # System documentation
└── .memory/                # Shared AI memory vault
```

## Key Workflows

### Research and Development
- `/task`, `/research`, `/plan`, `/implement` -- structured task lifecycle
- `/epi` -- epidemiology study design and R-based analysis
- `/grant`, `/budget`, `/funds`, `/timeline` -- grant development
- `/slides` -- research talk creation

### Document Management
- `/edit` -- Word document editing with tracked changes
- `/convert` -- format conversion (PDF, DOCX, Markdown)
- `/table` -- spreadsheet to LaTeX/Typst tables
- `/scrape` -- PDF annotation extraction

### System Maintenance
- `/review`, `/errors`, `/fix-it` -- code quality and error tracking
- `/meta` -- agent system modifications
- `/todo` -- task archival

## Related Documentation

- `docs/` -- Human-readable documentation for users
- `.claude/README.md` -- Claude Code framework architecture
- `.memory/README.md` -- Shared AI memory vault
