# Zed Editor Configuration Project

## Project Overview

This is a Zed editor configuration repository providing a structured development environment for R and Python, with a Claude Code agent system for tracked research, planning, and implementation workflows. The configuration supports macOS, Debian/Ubuntu, and Arch/Manjaro.

**Purpose**: Maintain a productive Zed development environment with organized configuration, language support, and AI-assisted task management.

## Technology Stack

**Editor**: Zed (modern code editor)
**Theme**: One Dark
**Font**: Fira Code (14pt buffer, 15pt UI)
**Languages**: R (r-language-server), Python (pyright + ruff), Markdown (prettier)
**AI Integration**: Claude Code via ACP (Agent Client Protocol)
**Platform**: macOS 11+, Debian/Ubuntu, Arch/Manjaro

## Project Structure

```
~/.config/zed/
├── settings.json             # Editor settings (theme, fonts, LSP, extensions, ACP)
├── keymap.json               # Custom shortcuts + default reference
├── tasks.json                # Task runner definitions
├── themes/                   # Custom color themes
├── scripts/
│   └── install/              # Installation wizard and per-group scripts
├── docs/                     # Documentation
│   ├── general/              # Installation, keybindings, settings, R/Python setup
│   ├── agent-system/         # AI systems overview, commands, architecture
│   ├── toolchain/            # External dependency docs (R, Python, LaTeX, Typst, MCP)
│   └── workflows/            # Agent lifecycle, epi, grants, Office file workflows
├── examples/                 # Runnable end-to-end examples
│   ├── epi-study/            # Synthetic RCT analysis
│   ├── epi-slides/           # Conference deck example
│   └── test-files/           # Test fixtures for filetypes extension
├── talks/                    # Research talk artifacts
├── prompts/                  # Prompt library database
├── .zed/                     # Zed workspace-local settings
│   └── scripts/              # Workspace scripts
│       └── tasks.json        # Workspace task definitions
├── .memory/                  # AI memory vault (Obsidian-backed)

specs/                        # Task management
├── TODO.md                   # Task list
├── state.json                # Task state
└── {NNN}_{SLUG}/             # Task artifacts
    ├── reports/
    ├── plans/
    └── summaries/

.claude/                      # Claude Code configuration
├── CLAUDE.md                 # Main reference (loaded every session)
├── README.md                 # Architecture navigation hub
├── commands/                 # Slash commands
├── skills/                   # Skill definitions
├── agents/                   # Agent definitions
├── rules/                    # Auto-applied rules
├── context/                  # Domain knowledge
├── docs/                     # Guides, examples, standards
├── extensions.json           # Active extension registry
└── scripts/                  # Utility scripts
```

## Editor Configuration

### Settings (settings.json)

- Vim mode enabled with VSCode base keymap
- One Dark theme with Fira Code font
- Auto-install extensions: python, ruff, r, markdown-oxide, markdownlint, csv, nix, toml, git-firefly, codebook
- Format on save enabled globally
- Language-specific: Python (4-space tabs, pyright + ruff), R (2-space tabs, r-language-server), Markdown (prettier)
- Terminal docked right with bash shell
- Claude Code ACP integration via agent_servers configuration

### Keybindings (keymap.json)

- Ctrl+Shift+A: Launch Claude Code CLI
- Ctrl+H/L: Move focus between split panes
- Alt+J/K: Move current line down/up

## AI-Assisted Workflow

1. **Create Task**: `/task "Description"` - Create tracked work item
2. **Research**: `/research N` - Investigate and produce a report
3. **Planning**: `/plan N` - Create phased implementation plan
4. **Implementation**: `/implement N` - Execute plan phase by phase
5. **Archive**: `/todo` - Archive completed tasks

## Domain Extensions

Active extensions (from .claude/extensions.json):

- **Epidemiology**: R-based study design, statistical modeling, causal inference (`/epi`)
- **Present**: Grant proposals, budgets, timelines, funding analysis, research talks (`/grant`, `/budget`, `/funds`, `/timeline`, `/slides`)
- **LaTeX**: Document typesetting with compilation support
- **Typst**: Modern typesetting alternative to LaTeX
- **Filetypes**: Office document conversion and editing (`/convert`, `/edit`, `/table`, `/scrape`)
- **Memory**: Persistent knowledge vault (`/learn`, `--remember`)
- **Python**: Python development patterns and tools

## Verification Commands

```bash
# Check Zed is installed
command -v zed

# Check Claude Code CLI
claude --version

# Check language servers
command -v pyright ruff

# Check R
command -v R Rscript

# Run installation health check
bash scripts/install/install.sh --check
```

## Related Documentation

- `.claude/CLAUDE.md` - Claude Code agent system quick reference
- `docs/general/installation.md` - Full installation walkthrough
- `docs/agent-system/README.md` - AI systems overview
- `docs/toolchain/README.md` - External dependency reference
