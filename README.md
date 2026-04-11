# Zed IDE Configuration with Claude Code Agent System

A Zed editor configuration for macOS that pairs first-class **R** and **Python** language support with a **Claude Code agent system** -- a structured task lifecycle that turns research, planning, and implementation into tracked, resumable workflows. Domain extensions for epidemiology, grant development, document conversion, and memory capture layer on top of the core system.

**Platform**: macOS 11 (Big Sur) or newer.

## Quick Start

On a fresh Mac, the fastest path is the installation wizard:

```
git clone <repo-url> ~/.config/zed
cd ~/.config/zed
bash scripts/install/install.sh
```

The wizard walks through six groups (base tools, shell utilities, Python, R, typesetting, MCP servers) with accept/skip/cancel prompts. Non-interactive shortcuts: `bash scripts/install/install.sh --dry-run` (preview), `--check` (health report), `--preset epi-demo`, `--preset writing`, `--preset everything`, or `--only base,python --yes`. See [docs/general/installation.md](docs/general/installation.md#installation-wizard-recommended) for the full walkthrough and [docs/toolchain/README.md](docs/toolchain/README.md) for per-group detail.

**Prefer to install by hand?**

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

## How It Works

The agent system turns development work into tracked tasks with a predictable lifecycle. You create a task with `/task`, investigate it with `/research` (which produces a report), design a solution with `/plan` (which produces a phased plan), and execute it with `/implement` (which works through each phase, committing as it goes). When you are done, `/todo` archives completed tasks. If something goes wrong, `/implement` resumes from the last incomplete phase.

### Walkthrough: Adding a New Language Server

```
# 1. Create a task
/task "Add TOML language server support"

# 2. Research approaches (produces a report)
/research 34

# 3. Create a phased plan
/plan 34

# 4. Execute the plan (commits after each phase)
/implement 34

# 5. Archive when done
/todo
```

Each step produces artifacts in `specs/034_add_toml_language_server/` -- reports, plans, and summaries -- so you can always see what was investigated, decided, and built.

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

### Task Lifecycle

Commands that drive work through the research-plan-implement cycle:

| Command | What it does |
|---------|-------------|
| `/task` | Create a new tracked task |
| `/research` | Investigate a topic, library, or codebase and write a report |
| `/plan` | Create a phased implementation plan from research |
| `/implement` | Execute a plan, resuming from any incomplete phase |
| `/revise` | Create a new version of an existing plan |
| `/todo` | Archive completed and abandoned tasks |

### Domain Extensions

Specialized commands that add domain-specific capabilities on top of the core lifecycle:

**Epidemiology** -- Design and run R-based epidemiological studies with structured analysis phases:

| Command | What it does |
|---------|-------------|
| `/epi` | Design and run epidemiology studies in R |

**Grant Development** -- Research proposals, budgets, timelines, and funding analysis:

| Command | What it does |
|---------|-------------|
| `/grant` | Develop grant proposals with narrative drafting |
| `/budget` | Generate grant budgets with justification |
| `/funds` | Analyze funding landscape and funder portfolios |
| `/timeline` | Plan research project timelines |
| `/slides` | Create research talks and presentations |

**Document Tools** -- Convert, edit, and extract from Office and PDF files:

| Command | What it does |
|---------|-------------|
| `/convert` | Convert between PDF, DOCX, Markdown, and other formats |
| `/edit` | Edit Word documents with tracked changes |
| `/table` | Convert spreadsheets to LaTeX/Typst tables |
| `/scrape` | Extract annotations from PDFs |

**Memory** -- Persistent knowledge across sessions:

| Command | What it does |
|---------|-------------|
| `/learn` | Save knowledge to the memory vault for future sessions |

### Housekeeping

Commands for code quality, error tracking, and system maintenance:

| Command | What it does |
|---------|-------------|
| `/review` | Review code and produce an analysis report |
| `/errors` | Analyze error patterns and create fix plans |
| `/fix-it` | Scan files for FIX:/TODO:/NOTE: tags and create tasks |
| `/refresh` | Clean up orphaned processes and old files |
| `/meta` | System builder for modifying the agent system itself |
| `/merge` | Create a pull/merge request for the current branch |

For the full command catalog, see [docs/agent-system/commands.md](docs/agent-system/commands.md).

## Common Scenarios

| I want to... | Start here |
|---|---|
| Design and run an epidemiology study in R | [Epidemiology workflow](docs/workflows/epidemiology-analysis.md) |
| Develop a grant proposal or budget | [Grant development](docs/workflows/grant-development.md) |
| Edit a collaborator's Word document | [Office file editing](docs/workflows/edit-word-documents.md) |
| Convert a PDF to Markdown (or back) | [Document conversion](docs/workflows/convert-documents.md) |
| Investigate and fix codebase issues | [Maintenance workflow](docs/workflows/maintenance-and-meta.md) |

For the complete decision guide, see [docs/workflows/README.md](docs/workflows/README.md#decision-guide).

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

**Claude Code** (Ctrl+Shift+A): The primary AI interface. Provides a structured task lifecycle (`/task`, `/research`, `/plan`, `/implement`) for tracked, resumable development work. Domain extensions add specialized capabilities for epidemiology (`/epi`), grant and research development (`/grant`, `/budget`, `/funds`, `/timeline`, `/slides`), document tools (`/edit`, `/convert`, `/table`, `/scrape`), and persistent memory (`/learn`).

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
