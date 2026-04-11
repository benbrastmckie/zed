# Zed Configuration Project

## Project Overview

This is a Zed IDE configuration for R and Python development, built on top of a Claude Code agent system that provides structured task management, extension-based domain support, and automated development workflows.

**Purpose**: Maintain a productive Zed development environment with an integrated AI-assisted task lifecycle for research, planning, and implementation.

## Technology Stack

**Editor:** Zed
**Development Languages:** R, Python
**AI Integration:** Claude Code agent system (`.claude/`)
**Task Management:** Structured lifecycle via `/task`, `/research`, `/plan`, `/implement`

## Project Structure

```
.                            # Repository root (~/.config/zed/)
├── settings.json           # Zed editor settings
├── keymap.json             # Zed keybindings
├── tasks.json              # Zed task runner definitions
├── themes/                 # Custom color themes
├── README.md               # User-facing documentation
├── docs/                   # Documentation
│   ├── README.md           # Documentation index
│   ├── general/            # Installation, keybindings
│   ├── agent-system/       # Agent system user docs
│   ├── toolchain/          # Tool guides (Slidev, extensions)
│   └── workflows/          # Workflow decision guides
├── examples/               # Example configurations
├── scripts/                # Utility scripts
├── specs/                  # Task management artifacts
│   ├── TODO.md             # Task list
│   ├── state.json          # Machine-readable task state
│   └── {NNN}_{SLUG}/       # Per-task directories
│       ├── reports/        # Research reports
│       ├── plans/          # Implementation plans
│       └── summaries/      # Completion summaries
├── .claude/                # Claude Code agent system
│   ├── CLAUDE.md           # Session-loaded reference
│   ├── README.md           # Architecture navigation hub
│   ├── extensions.json     # Extension registry
│   ├── commands/           # Slash commands
│   ├── skills/             # Skill definitions
│   ├── agents/             # Agent definitions
│   ├── rules/              # Auto-applied rules
│   ├── context/            # Domain knowledge and patterns
│   ├── docs/               # System documentation
│   ├── hooks/              # Git/lifecycle hooks
│   ├── scripts/            # Utility scripts
│   └── templates/          # Artifact templates
├── .memory/                # Learned project knowledge
└── .context/               # Project conventions
```

## Core Systems

### Zed Configuration

The Zed editor configuration includes:
- `settings.json` -- Editor preferences, LSP settings, language-specific configuration
- `keymap.json` -- Custom keybindings (standard mode, no vim emulation)
- `tasks.json` -- Task runner definitions for common operations
- `themes/` -- Custom color themes

### Claude Code Agent System

The `.claude/` directory contains a structured agent system for AI-assisted development:
- **Commands** parse user input and route to skills
- **Skills** validate context and invoke agents
- **Agents** execute work and produce artifacts
- **Extensions** add domain-specific capabilities (epidemiology, LaTeX, Typst, grants, etc.)

Extensions are registered in `.claude/extensions.json` and their context is pre-merged into the agent system.

### Task Lifecycle

Tasks flow through a structured lifecycle:
```
[NOT STARTED] -> [RESEARCHING] -> [RESEARCHED]
    -> [PLANNING] -> [PLANNED]
    -> [IMPLEMENTING] -> [COMPLETED]
```

Each phase produces artifacts (reports, plans, summaries) stored in `specs/{NNN}_{SLUG}/`.

## Development Workflow

### Standard Workflow

1. Edit Zed configuration files (settings, keybindings, themes)
2. Test changes by reloading Zed
3. Document in `docs/` as needed

### AI-Assisted Workflow

1. `/task "Description"` -- Create tracked work item
2. `/research N` -- Investigate approaches
3. `/plan N` -- Create phased implementation plan
4. `/implement N` -- Execute plan with git commits
5. `/todo` -- Archive completed tasks

## Related Documentation

- `README.md` -- User-facing project overview
- `.claude/CLAUDE.md` -- Agent system quick reference
- `.claude/README.md` -- Agent system architecture
- `docs/README.md` -- Documentation index
