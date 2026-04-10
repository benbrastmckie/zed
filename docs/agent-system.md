# AI Agent System

This project hosts two AI systems: Zed's built-in Agent Panel for quick, in-editor assistance, and a terminal-based Claude Code framework with full research, planning, and implementation workflows. This document is an orientation guide. For the authoritative power-user reference, see [`.claude/CLAUDE.md`](../.claude/CLAUDE.md).

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

Zed ships with an AI agent panel that can read and edit files in your project. It is good for quick questions and simple edits.

### 2. Claude Code (Terminal-based)

Claude Code is a more powerful system that runs in the terminal. It has a full project-management framework with research, planning, and implementation workflows, a task state machine, and structured artifact outputs. Start it by opening the terminal (Cmd+`) and running `claude`.

Claude Code in this workspace ships **24 slash commands** that are **always available** — there is no extension loading step. (The `.claude/CLAUDE.md` file describes a cross-project extension loader for portability, but it does not apply here.)

See the [Claude Code user guide](../.claude/docs/guides/user-guide.md) for the comprehensive command reference with examples and troubleshooting.

## Claude Code: Main Workflow

Seven commands drive the task lifecycle: five lifecycle drivers and two clean-up commands. Learn these first.

### Task lifecycle state machine

```
[NOT STARTED] ──/research──▶ [RESEARCHING] ──▶ [RESEARCHED]
              ──/plan──────▶ [PLANNING]    ──▶ [PLANNED]
              ──/implement─▶ [IMPLEMENTING]──▶ [COMPLETED]

Exception states: [BLOCKED]  [ABANDONED]  [PARTIAL]  [EXPANDED]
```

Every command runs a **checkpoint execution pipeline**: GATE IN (preflight) → DELEGATE (skill/agent) → GATE OUT (postflight) → COMMIT. A session ID of the form `sess_{unix}_{random}` is generated at GATE IN and threaded through the delegation chain into the final git commit body, so you can always reconstruct a command's trajectory. See [`.claude/rules/workflows.md`](../.claude/rules/workflows.md) and [`.claude/rules/git-workflow.md`](../.claude/rules/git-workflow.md).

Artifacts for each task live under `specs/{NNN}_{slug}/`:
```
specs/{NNN}_{slug}/
├── reports/MM_{short-slug}.md       # from /research
├── plans/MM_{short-slug}.md         # from /plan
└── summaries/MM_{short-slug}-summary.md  # from /implement
```

See [`.claude/rules/artifact-formats.md`](../.claude/rules/artifact-formats.md) for the full naming and versioning spec.

### Lifecycle drivers

**`/task "Description"`** — Create and manage tasks. Creates a new entry in `specs/TODO.md` and `specs/state.json`, assigns the next task number, creates a `specs/{NNN}_{slug}/` directory, and commits. Subcommands: `--recover N` (rebuild a broken task), `--expand N` (split into subtasks), `--sync` (repair TODO.md/state.json drift), `--abandon N` (mark terminal), `--review N` (review mode). Creates state `[NOT STARTED]`.

**`/research N [focus] [--team] [--remember]`** — Investigate a task. Routes by the task's `task_type` to the matching research skill and agent (for `general`/`meta`/`markdown`, that is `skill-researcher` → `general-research-agent`). Produces a report at `reports/MM_{short-slug}.md`. The `--remember` flag searches the project memory vault and injects matches into the research context. Transitions `[NOT STARTED]` → `[RESEARCHING]` → `[RESEARCHED]`.

**`/plan N [--team]`** — Create an implementation plan. Delegates to `skill-planner` → `planner-agent` (model: `opus`), which reads the research report and writes a phased plan at `plans/MM_{short-slug}.md`. See the [agent frontmatter standard](../.claude/docs/reference/standards/agent-frontmatter-standard.md) for how agents declare models. Transitions `[RESEARCHED]` → `[PLANNING]` → `[PLANNED]`.

**`/revise N [reason]`** — Revise the plan (or update the task description if no plan exists). Delegates to `skill-reviser` → `reviser-agent` and creates a new plan version (e.g., `plans/02_{short-slug}.md`).

**`/implement N [--team] [--force]`** — Execute the plan. Routes to `skill-implementer` → `general-implementation-agent` (or a domain agent), which executes phases sequentially. **Resumable**: if interrupted, the next invocation picks up at the first incomplete phase. Writes `summaries/MM_{short-slug}-summary.md`. Transitions `[PLANNED]` → `[IMPLEMENTING]` → `[COMPLETED]` (or `[PARTIAL]` on timeout, `[BLOCKED]` on hard failure).

### Clean-up commands

**`/review [scope] [--create-tasks]`** — Analyze the codebase and produce a tier-grouped review report (critical / high / medium / low). With `--create-tasks`, interactively creates tasks from findings using the [multi-task creation standard](../.claude/docs/reference/standards/multi-task-creation-standard.md).

**`/todo [--dry-run]`** — Archive `[COMPLETED]` and `[ABANDONED]` tasks from `specs/TODO.md` to `specs/archive/`, update `state.json`, append to `CHANGE_LOG.md`, and annotate `ROAD_MAP.md` with non-meta task completion summaries. Triggers a **vault operation** (task renumbering) when `next_project_number > 1000`; see [`.claude/rules/state-management.md`](../.claude/rules/state-management.md) for the vault schema.

### Multi-task syntax

`/research`, `/plan`, and `/implement` accept comma and range syntax: `/research 5, 7-9` runs tasks 5, 7, 8, and 9 in parallel, each with its own agent. Flags apply to all tasks in the batch.

### Team mode (`--team`)

Passing `--team` to `/research`, `/plan`, or `/implement` spawns multiple parallel teammates (2-4) for diverse investigation or parallel phase execution. Team mode requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in the environment, uses roughly 5× the tokens of single-agent mode, and gracefully degrades to single-agent if the harness does not support it.

For a full walkthrough, see the [research flow example](../.claude/docs/examples/research-flow-example.md).

## Command Catalog by Topic

The remaining 17 commands, grouped by topic. Together with the seven main-workflow commands above, this is the full inventory of `.claude/commands/` in this repo.

### Task management & recovery

| Command | Purpose |
|---------|---------|
| `/spawn N [blocker]` | Research a blocker on a `[BLOCKED]` task and spawn new unblocking tasks, updating the parent task's dependency list. |
| `/errors [--fix N]` | Read `specs/errors.json`, analyze recurring error patterns, and create fix-plan tasks. |
| `/fix-it [PATH...]` | Scan files for `FIX:`, `NOTE:`, `TODO:`, `QUESTION:` tags and interactively create tasks. See the [fix-it flow example](../.claude/docs/examples/fix-it-flow-example.md). |
| `/refresh [--dry-run] [--force]` | Clean up Claude Code resources: terminate orphaned processes and delete stale files from `~/.claude/{projects,debug,file-history,todos,session-env,telemetry,cache}/`. |

### System / meta

| Command | Purpose |
|---------|---------|
| `/meta [prompt]` or `/meta --analyze` | Interactive system builder for `.claude/` architecture changes (new commands, skills, agents). **Never implements directly** — always outputs tasks for subsequent `/research` → `/plan` → `/implement` execution. Reference implementation of the multi-task creation standard. |
| `/merge [--draft] [--assignee U] [--label L] [--reviewer U]` | Create a GitHub PR (`gh pr create`) or GitLab MR (`glab mr create`) for the current branch. |

### Memory

| Command | Purpose |
|---------|---------|
| `/learn "text"` or `/learn /path/to/file` or `/learn /path/to/dir/` or `/learn --task N` | Add memories to the [`.memory/`](#memory-system) vault. Four modes: inline text capture, single-file ingest, directory scan, or review of a completed task's artifacts. Deduplicates against existing memories and classifies automatically. |

See the [Memory System](#memory-system) section below for the full two-layer model.

### Document conversion & editing

| Command | Purpose |
|---------|---------|
| `/convert SOURCE [OUT]` | Convert between PDF, DOCX, and Markdown. |
| `/table data.xlsx [OUT] [--format latex\|typst]` | Spreadsheet → formatted table source. |
| `/slides deck.pptx [OUT] [--format beamer\|polylux\|touying]` | Presentation → slide source. |
| `/scrape paper.pdf [OUT] [--format markdown\|json] [--types ...]` | Extract PDF annotations, highlights, and comments. |
| `/edit file.docx "instruction" [--new]` | In-place DOCX editing with tracked changes via the SuperDoc MCP. Supports batch edit over a directory. |

### Research presentation & grants

| Command | Purpose |
|---------|---------|
| `/grant "desc"` / `/grant N --draft ["focus"]` / `/grant N --budget ["guidance"]` / `/grant --revise N "desc"` | Grant proposal research, drafting, and budget development. |
| `/budget "desc"` / `/budget N` / `/budget --quick [mode]` | Generate a grant budget spreadsheet (.xlsx) with formulas and justifications. |
| `/timeline "desc"` / `/timeline N` | Build a research project timeline with milestones. |
| `/funds "desc"` / `/funds N` / `/funds --quick [topic]` | Survey funding opportunities with eligibility and deadlines. |
| `/talk "desc"` / `/talk N` / `/talk /path/to/file` | Build a research talk. Five modes: |

**`/talk` modes**:

| Mode | Duration | Slides | Use case |
|------|----------|--------|----------|
| CONFERENCE | 15-20 min | 12-18 | Conference platform presentations |
| SEMINAR | 45-60 min | 30-45 | Departmental seminars, job talks |
| DEFENSE | 30-60 min | 25-40 | Grant defense, thesis defense |
| POSTER | N/A | 1 | Poster session presentations |
| JOURNAL_CLUB | 15-30 min | 10-15 | Paper review for journal club |

## Memory System

Claude Code in this workspace uses **two distinct memory layers**. Keeping them straight matters: one is agent-managed and shared with OpenCode; the other is harness-private.

### Project memory vault (`.memory/`)

**Location**: `/home/benjamin/.config/zed/.memory/`

A real, populated [Obsidian](https://obsidian.md)-compatible vault managed by agents via the `skill-memory` skill and the `/learn` command. **Shared with OpenCode**: both AI systems read and write the same vault, using timestamped memory IDs for collision resistance. See [`.memory/README.md`](../.memory/README.md) for the full structure and sharing protocol.

**Structure**:
```
.memory/
├── 00-Inbox/        # Quick capture before classification
├── 10-Memories/     # Permanent storage (MEM-{semantic-slug}.md)
├── 20-Indices/      # index.md and topic indices
└── 30-Templates/    # memory-template.md and README
```

**File format**: YAML frontmatter with `title`, `created`, `tags`, `topic`, `source`, `modified`. Filenames are unique IDs (e.g., `MEM-telescope-custom-pickers.md`).

**Write path** — the `/learn` command has four modes:
- `/learn "text"` — inline capture
- `/learn /path/to/file.md` — ingest a file as a memory source
- `/learn /path/to/dir/` — scan a directory for learnable content
- `/learn --task N` — review a completed task's artifacts and propose memories

**Read path** — grep-based discovery by default. Both AI systems fall back to grep when their respective MCP servers (Claude Code on WebSocket 22360, OpenCode on REST 27124) are unavailable. The `/research N --remember` flag searches the vault and injects matches into the research context.

**What belongs here**: learned facts, discoveries, decisions, reusable patterns, project-specific lessons.

### Auto-memory (Claude Code harness)

**Location**: `~/.claude/projects/-home-benjamin--config-zed/memory/`

Managed by the Claude Code harness, **not by agents**. Stores user preferences and behavioral corrections captured automatically from conversation (for example, `feedback_no_vim_mode_zed.md`: "Zed shared with collaborator; use standard keybindings, not vim").

You never write to this directory directly, and agents never read from or modify it. It is harness-private. If you want Claude Code to remember something across sessions at the project level, use `/learn` (which writes to `.memory/`) — not the auto-memory layer.

### Context architecture — five layers

Claude Code agents pull context from five distinct layers. Each has a different owner and purpose.

| Layer | Location | Owner | Purpose |
|-------|----------|-------|---------|
| Agent context | `.claude/context/` | Extension loader | Core agent patterns, formats, workflows |
| Extensions | `.claude/extensions/*/context/` | Extension loader | Language-specific standards (not populated in this workspace) |
| Project context | `.context/` | User (via `index.json`) | Project conventions not covered by extensions |
| Project memory | `.memory/` | Agents (via `/learn`) | Learned facts, discoveries, decisions |
| Auto-memory | `~/.claude/projects/` | Claude Code harness | User preferences, behavioral corrections |

## Architecture & Configuration

### Three-layer execution pipeline

```
USER → /command args
     → COMMANDS (.claude/commands/*.md)       [parse, route by task_type, checkpoint]
     → SKILLS   (.claude/skills/*/SKILL.md)   [validate, prepare context, invoke agents]
     → AGENTS   (.claude/agents/*.md)         [execute, create artifacts, return metadata]
```

Commands are thin routers; skills handle validation and context loading; agents do the actual work and write artifacts. See [`.claude/README.md`](../.claude/README.md) for the full architecture diagram and component specifications, and [`.claude/docs/architecture/system-overview.md`](../.claude/docs/architecture/system-overview.md) for the detailed walkthrough.

### State files

- `specs/TODO.md` — human-readable task list (source of truth for users)
- `specs/state.json` — machine-readable state (source of truth for commands)
- `specs/errors.json` — error tracking for retry and recovery; see [`.claude/rules/error-handling.md`](../.claude/rules/error-handling.md)
- `specs/{NNN}_{slug}/` — per-task directories with `reports/`, `plans/`, and `summaries/` subdirectories

TODO.md and state.json must stay synchronized; both are updated atomically. See [`.claude/rules/state-management.md`](../.claude/rules/state-management.md) for the sync protocol and vault schema.

### Configuration layout

```
.
├── specs/                    # Task management
│   ├── TODO.md              # Human-readable task list
│   ├── state.json           # Machine-readable state
│   ├── errors.json          # Error tracking
│   └── {NNN}_{SLUG}/        # Per-task artifacts
└── .claude/
    ├── CLAUDE.md            # Always-loaded quick reference
    ├── README.md            # Architecture navigation hub
    ├── commands/            # 24 slash command definitions
    ├── skills/              # 32 skill routers
    ├── agents/              # 25 agent specifications
    ├── rules/               # Auto-applied behavioral rules
    ├── context/             # Core agent context (patterns, formats)
    ├── docs/                # Guides, examples, standards
    └── scripts/             # Utility scripts (e.g., update-task-status.sh)
```

For help navigating the system, see the [documentation index](../.claude/docs/README.md), and for deeper dives:

- [System overview](../.claude/docs/architecture/system-overview.md) — architecture and lifecycle
- [Extension system](../.claude/docs/architecture/extension-system.md) — how the loader works (relevant for portability)
- [Component selection](../.claude/docs/guides/component-selection.md) — command vs skill vs agent decision tree
- [Creating commands](../.claude/docs/guides/creating-commands.md), [skills](../.claude/docs/guides/creating-skills.md), [agents](../.claude/docs/guides/creating-agents.md), and [extensions](../.claude/docs/guides/creating-extensions.md)

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

## Zed Agent Panel

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

## Known Limitations

- The Zed agent panel and Claude Code are independent — they do not share conversation history.
- Claude Code requires a terminal session (Cmd+`) to run.
- Extension loading (the `<leader>ac` pattern described in `.claude/CLAUDE.md`) is a **neovim-only** feature. In this Zed workspace, all 24 commands are always available and no loading step is required.
- Each request uses API credits — Claude Code runs on a subscription or pay-per-use model; frequent large edits use more credits than simple questions.
- Complex formatting (embedded charts, SmartArt) may need manual touch-up in Word after Claude edits.

## Related Documentation

### Canonical references
- [`.claude/CLAUDE.md`](../.claude/CLAUDE.md) — Always-loaded quick reference; canonical command list
- [`.claude/README.md`](../.claude/README.md) — Architecture navigation hub
- [`.claude/docs/README.md`](../.claude/docs/README.md) — Documentation index

### Architecture
- [System overview](../.claude/docs/architecture/system-overview.md) — Detailed architecture, task lifecycle, state management
- [Extension system](../.claude/docs/architecture/extension-system.md) — Extension loader pattern (portability reference)

### Guides
- [User guide](../.claude/docs/guides/user-guide.md) — Comprehensive command reference with examples
- [User installation](../.claude/docs/guides/user-installation.md) — Quick-start
- [Component selection](../.claude/docs/guides/component-selection.md) — Command vs skill vs agent decision tree
- [Creating commands](../.claude/docs/guides/creating-commands.md)
- [Creating skills](../.claude/docs/guides/creating-skills.md)
- [Creating agents](../.claude/docs/guides/creating-agents.md)
- [Creating extensions](../.claude/docs/guides/creating-extensions.md)

### Standards
- [Agent frontmatter standard](../.claude/docs/reference/standards/agent-frontmatter-standard.md)
- [Multi-task creation standard](../.claude/docs/reference/standards/multi-task-creation-standard.md)

### Rules
- [State management](../.claude/rules/state-management.md)
- [Git workflow](../.claude/rules/git-workflow.md)
- [Artifact formats](../.claude/rules/artifact-formats.md)
- [Error handling](../.claude/rules/error-handling.md)
- [Workflows](../.claude/rules/workflows.md)

### Examples
- [Research flow example](../.claude/docs/examples/research-flow-example.md)
- [Fix-it flow example](../.claude/docs/examples/fix-it-flow-example.md)

### Memory vault
- [`.memory/README.md`](../.memory/README.md) — Structure, sharing with OpenCode, MCP setup

### Local project docs
- [Settings reference](settings.md) — Agent block in `settings.json`
- [Keybindings guide](keybindings.md) — Agent panel shortcuts
- [Office workflows](office-workflows.md) — Document editing and conversion commands
- [README](../README.md) — Navigation hub
