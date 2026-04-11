# Research Report: Task #5

**Task**: 5 - Update docs/agent-system.md to accurately represent the .claude/ agent system
**Started**: 2026-04-10
**Completed**: 2026-04-10
**Effort**: M
**Dependencies**: None
**Sources/Inputs**:
- `/home/benjamin/.config/zed/docs/agent-system.md` (current doc)
- `/home/benjamin/.config/zed/.claude/README.md`
- `/home/benjamin/.config/zed/.claude/CLAUDE.md`
- `/home/benjamin/.config/zed/.claude/docs/README.md`
- `/home/benjamin/.config/zed/.claude/commands/*.md` (24 files)
- `/home/benjamin/.config/zed/.claude/skills/` (32 skills)
- `/home/benjamin/.config/zed/.claude/agents/` (25 agents)
- `/home/benjamin/.config/zed/.claude/rules/` (7 rules)
- `/home/benjamin/.config/zed/.memory/README.md` and subdirectories
**Artifacts**:
- `/home/benjamin/.config/zed/specs/005_update_agent_system_docs/reports/01_agent-system-docs.md`
**Standards**: `.claude/rules/artifact-formats.md`, report-format.md

---

## Executive Summary

- The current `docs/agent-system.md` is mostly accurate but **incomplete and mis-scoped**: it lists only a handful of commands, omits the core lifecycle (`/task`, `/revise`, `/todo`), misorders the workflow, gives `/tag` as a user command that does not exist in this repo, and has no topic-based grouping of the remaining 20+ commands.
- The document correctly covers installation, MCP tool setup, the two-AI-systems distinction (Zed panel vs Claude Code), and `/learn` / `.memory/`, but the memory section is thin (one paragraph) and conflates the project vault with Claude Code's internal auto-memory.
- The `.claude/` system actually defines **24 slash commands** routed through a three-layer architecture (Commands -> Skills -> Agents) with task-type-based routing, checkpoint execution, state machine lifecycle, and five distinct context layers.
- The `.memory/` vault is a real, populated Obsidian-compatible directory at `/home/benjamin/.config/zed/.memory/` with `00-Inbox`, `10-Memories`, `20-Indices`, `30-Templates`. It is **shared with OpenCode**, managed by the memory extension (`skill-memory`, `/learn`), and is distinct from Claude Code's auto-memory at `~/.claude/projects/`.
- Recommended rewrite: restructure into **Main Workflow** (lifecycle commands), **Command Catalog by Topic**, **Memory System**, **Architecture Overview**, **Cross-References**, preserving the existing Zed/MCP sections.

---

## Context & Scope

The user owns `/home/benjamin/.config/zed/`, a shared Zed configuration workspace (no-vim-mode per auto-memory) that embeds a full Claude Code agent system under `.claude/`. `docs/agent-system.md` is the human-facing orientation document linked from the project README. Task #5 asks for a rewrite so that it accurately reflects: the five main workflow commands plus two clean-up commands, the rest of the commands organized by topic, a dedicated `.memory/` section, and cross-links into `.claude/docs/` and `.claude/README.md`.

Scope of research: inventory the actual `.claude/` directory, diff against current doc, map commands into topic groups, document the memory layer, and list target cross-references.

---

## Findings

### 1. Current `docs/agent-system.md` — What's Right, What's Wrong

**What it gets right**:
- Two-system framing (Zed Agent Panel vs Claude Code) is a good entry point and should be preserved.
- Installation section (Homebrew, Zed, MCP tools) is useful orientation.
- MCP Tool Setup section (SuperDoc, openpyxl) is accurate and load-bearing — keep as-is.
- `.memory/` introduction and `/learn`, `--remember` examples are correct.
- Link to `.claude/CLAUDE.md` at the bottom of the Configuration section is appropriate.
- Zed keybindings table is accurate and matches `docs/keybindings.md`.

**What's wrong or outdated**:
- The "Key commands" table under Claude Code lists only 6 commands: `/research`, `/plan`, `/implement`, `/review`, `/convert`, `/table`. It **omits the lifecycle drivers**: `/task`, `/revise`, `/todo`. This understates the system significantly.
- No mention of the task lifecycle state machine ([NOT STARTED] -> [RESEARCHING] -> [RESEARCHED] -> [PLANNING] -> [PLANNED] -> [IMPLEMENTING] -> [COMPLETED]).
- The "Grant and Research Commands" table covers 7 present-extension commands but is presented as a standalone list, not integrated with the larger command inventory. Commands like `/slides`, `/scrape`, `/edit` are completely absent.
- `/tag` is listed under "Known Limitations" as a user-only command, but there is no `/home/benjamin/.config/zed/.claude/commands/tag.md` file in this repo. The repo's CLAUDE.md mentions `/tag` but the command file does not ship here. The doc should either remove the reference or clearly flag it as "available in extensions".
- The Configuration section's directory tree is missing `docs/` and `scripts/` and misleadingly implies `extensions/` is populated (the `.claude/extensions/` directory does not exist in this repo; extensions are documented in CLAUDE.md as "when loaded via `<leader>ac`" but this is a Zed-hosted workspace, not neovim, and no extensions are actually installed here).
- Several of the CLAUDE.md-advertised extensions (neovim, lean, latex, typst, epidemiology, present, memory, filetypes) appear in CLAUDE.md but **no `.claude/extensions/` directory exists**; their commands (`/grant`, `/talk`, `/convert`, etc.) all ship directly in `.claude/commands/`. The doc should clarify that in this workspace all commands are always available — there is no extension loading step.
- No link to `.claude/docs/README.md` (the standards hub), no link to `.claude/docs/guides/user-guide.md`, and no link to `.claude/docs/architecture/system-overview.md`.
- The "Memory Vault" section is three lines and does not explain structure, what gets stored, how indices work, or the Obsidian-shared-with-OpenCode aspect.
- "Known Limitations" bullet about `/tag` being user-only is misleading for this repo.
- Missing: anything about `/meta`, `/errors`, `/fix-it`, `/refresh`, `/spawn`, `/merge`, `/revise`, `/task`, `/todo`, `/learn`, `/edit`, `/scrape`, `/slides`.

### 2. Ground Truth — .claude/ Agent System

**Architecture** (from `.claude/README.md` and `.claude/CLAUDE.md`):

Three-layer execution pipeline:
```
USER -> /command args
     -> COMMANDS (.claude/commands/*.md)  [parse, route by task_type, checkpoint]
     -> SKILLS   (.claude/skills/*/SKILL.md) [validate, prepare context, invoke agents]
     -> AGENTS   (.claude/agents/*.md)     [execute, create artifacts, return JSON]
```

Every command runs checkpoint-based execution: **GATE IN (preflight) -> DELEGATE -> GATE OUT (postflight) -> COMMIT**. Session IDs (`sess_{unix}_{random}`) are generated at GATE IN and included in all subsequent artifacts and git commits.

**Task lifecycle state machine**:
```
[NOT STARTED] -> [RESEARCHING] -> [RESEARCHED]
              -> [PLANNING]    -> [PLANNED]
              -> [IMPLEMENTING]-> [COMPLETED]
```
Terminal/exception states: `[BLOCKED]`, `[ABANDONED]`, `[PARTIAL]`, `[EXPANDED]`.

**State files**:
- `specs/TODO.md` — human-readable task list
- `specs/state.json` — machine-readable state, source of truth
- `specs/errors.json` — error tracking for retry/recovery
- `specs/{NNN}_{SLUG}/` — per-task directories containing `reports/MM_*.md`, `plans/MM_*.md`, `summaries/MM_*-summary.md`

**Full command inventory** (24 commands in `.claude/commands/`):

| Command | Frontmatter Description |
|---------|-------------------------|
| `/task` | Create, recover, divide, sync, or abandon tasks |
| `/research` | Research a task and create reports |
| `/plan` | Create implementation plan for a task |
| `/implement` | Execute implementation with resume support |
| `/revise` | Create new version of implementation plan, or update task description if no plan exists |
| `/review` | Review code and create analysis reports |
| `/todo` | Archive completed and abandoned tasks |
| `/meta` | Interactive system builder that creates TASKS for agent architecture changes |
| `/learn` | Add memories from text, files, directories, or task artifacts with content mapping and deduplication |
| `/spawn` | Spawn new tasks to unblock a blocked task |
| `/errors` | Analyze errors and create fix plans |
| `/fix-it` | Scan files for FIX:, NOTE:, TODO:, QUESTION: tags and create structured tasks interactively |
| `/refresh` | Manage Claude Code resources — terminate orphaned processes and clean up files |
| `/merge` | Create a pull/merge request for the current branch (GitHub PR or GitLab MR) |
| `/convert` | Convert documents between formats (PDF/DOCX to Markdown, Markdown to PDF) |
| `/table` | Convert spreadsheets to LaTeX or Typst tables |
| `/slides` | Convert presentations to Beamer, Polylux, or Touying slides |
| `/scrape` | Extract annotations and comments from PDF files |
| `/edit` | Edit Office documents in-place (DOCX with tracked changes, batch edit, create new) |
| `/grant` | Create grant tasks, execute grant workflows (draft, budget), or create revisions |
| `/budget` | Grant budget spreadsheet generation with forcing questions and task integration |
| `/timeline` | Create timeline tasks or execute research timeline workflows for medical research projects |
| `/funds` | Funding landscape analysis with funder portfolio mapping, budget justification, and gap analysis |
| `/talk` | Create research talk tasks with pre-task forcing questions for academic presentations |

**Note**: `/tag` is referenced in `.claude/CLAUDE.md` and `.claude/README.md` but **does not exist as a command file in this repo** (`ls .claude/commands/ | grep tag` returns nothing). The rewrite should either drop `/tag` entirely or flag it explicitly as "documented but not installed".

**Skills** (32 directories in `.claude/skills/`): `skill-orchestrator`, `skill-researcher`, `skill-planner`, `skill-implementer`, `skill-meta`, `skill-status-sync`, `skill-git-workflow`, `skill-todo`, `skill-refresh`, `skill-reviser`, `skill-spawn`, `skill-fix-it`, `skill-memory`, `skill-team-research`, `skill-team-plan`, `skill-team-implement`, plus domain skills: `skill-latex-research`, `skill-latex-implementation`, `skill-typst-research`, `skill-typst-implementation`, `skill-epidemiology-research`, `skill-epidemiology-implementation`, `skill-filetypes`, `skill-spreadsheet`, `skill-presentation`, `skill-scrape`, `skill-docx-edit`, `skill-grant`, `skill-budget`, `skill-timeline`, `skill-funds`, `skill-talk`.

**Agents** (25 files in `.claude/agents/`): `general-research-agent`, `general-implementation-agent`, `planner-agent`, `meta-builder-agent`, `code-reviewer-agent`, `reviser-agent`, `spawn-agent`, `latex-research-agent`, `latex-implementation-agent`, `typst-research-agent`, `typst-implementation-agent`, `epidemiology-research-agent`, `epidemiology-implementation-agent`, `filetypes-router-agent`, `document-agent`, `spreadsheet-agent`, `presentation-agent`, `scrape-agent`, `docx-edit-agent`, `grant-agent`, `budget-agent`, `timeline-agent`, `funds-agent`, `talk-agent`, plus `README.md`.

**Rules** (7 files in `.claude/rules/`, auto-applied by file path):
- `state-management.md` — state.json/TODO.md sync, vault operations
- `git-workflow.md` — commit conventions, session ID format
- `error-handling.md` — errors.json schema, recovery strategies
- `artifact-formats.md` — report/plan/summary formats
- `workflows.md` — command lifecycle
- `plan-format-enforcement.md` — plan structural requirements
- `latex.md` — LaTeX-specific conventions

**Extensions reality check**: `.claude/CLAUDE.md` has extensive sections on "Epidemiology Extension", "Filetypes Extension", "LaTeX Extension", "Memory Extension", "Present Extension", "Typst Extension", suggesting a loader pattern. However, `ls .claude/extensions/` returns **"No such file or directory"**. All referenced extension commands (`/grant`, `/convert`, `/talk`, `/budget`, `/funds`, `/timeline`, `/slides`, `/scrape`, `/edit`, `/learn`, `/table`) are present directly in `.claude/commands/`. **The rewrite should not mention `<leader>ac` or extension loading** — in this Zed workspace, all commands are always available.

### 3. Main Workflow Commands — Detailed Descriptions

These seven commands drive the task lifecycle. The user should learn these first.

#### Lifecycle drivers (five commands)

**`/task "Description"`** — Create and manage tasks
- **What it does**: Creates a new task entry in `specs/TODO.md` and `specs/state.json`, assigns the next task number, creates a `specs/{NNN}_{slug}/` directory, and commits with `task {N}: create {title}`.
- **When to use**: Any time you want to start tracked work. This is the canonical entry point.
- **Subcommands**: `--recover N` (rebuild a broken task), `--expand N` (split into subtasks), `--sync` (repair TODO.md/state.json drift), `--abandon N` (mark terminal), `--review N` (review mode).
- **Lifecycle transition**: creates state `[NOT STARTED]`.
- **Artifacts**: task directory, TODO.md entry, state.json entry.

**`/research N [focus] [--team]`** — Investigate a task
- **What it does**: Routes to the research skill matching the task's `task_type` (for `general`/`meta`/`markdown` -> `skill-researcher` -> `general-research-agent`; for domain types -> the matching specialized agent). Produces a research report at `specs/{NNN}_{slug}/reports/01_{short-slug}.md` following the format in `.claude/rules/artifact-formats.md`.
- **When to use**: After `/task`, before `/plan`. Gathers codebase patterns, conventions, and web resources.
- **Multi-task**: Accepts comma/range syntax: `/research 5, 7-9`. Each task runs in parallel.
- **`--team` flag**: Spawns 2-4 teammates in parallel for diverse investigation angles; requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. Uses ~5x tokens.
- **Lifecycle transition**: `[NOT STARTED]` -> `[RESEARCHING]` -> `[RESEARCHED]`.
- **Artifacts**: `reports/MM_{short-slug}.md`, `.return-meta.json`.

**`/plan N [--team]`** — Create an implementation plan
- **What it does**: Delegates to `skill-planner` -> `planner-agent` (model: opus) which reads the research report and writes a phased implementation plan at `specs/{NNN}_{slug}/plans/MM_{short-slug}.md` following the plan format in `.claude/rules/plan-format-enforcement.md`.
- **When to use**: After `/research`. Plans are versioned — use `/revise` to create v2.
- **Lifecycle transition**: `[RESEARCHED]` -> `[PLANNING]` -> `[PLANNED]`.
- **Artifacts**: `plans/MM_{short-slug}.md`.

**`/revise N [reason]`** — Revise the plan
- **What it does**: If a plan exists, `skill-reviser` -> `reviser-agent` creates a new version of the plan (`plans/MM_{short-slug}-v2.md`). If no plan exists, updates the task description in place.
- **When to use**: When research turns up new constraints mid-implementation, or when a review identifies a gap.
- **Lifecycle transition**: Stays in `[PLANNED]` (or returns to `[PLANNING]` briefly).
- **Artifacts**: new plan version.

**`/implement N [--team] [--force]`** — Execute the plan
- **What it does**: Routes to `skill-implementer` -> `general-implementation-agent` (or domain-specific agent), which executes plan phases sequentially. Resumable: if interrupted, the next invocation resumes from the first incomplete phase. Writes a summary to `specs/{NNN}_{slug}/summaries/MM_{short-slug}-summary.md`.
- **When to use**: After `/plan`. The primary work-doing command.
- **`--force` flag**: Bypasses the "plan must exist" check; useful for recovery.
- **`--team` flag**: Spawns 2-4 teammates for parallel phase execution plus a debugger teammate for error recovery.
- **Lifecycle transition**: `[PLANNED]` -> `[IMPLEMENTING]` -> `[COMPLETED]` (or `[PARTIAL]` on timeout, `[BLOCKED]` on hard failure).
- **Artifacts**: source file changes, `summaries/MM_*-summary.md`, per-phase git commits.

#### Clean-up commands (two commands)

**`/review [scope] [--create-tasks]`** — Analyze the codebase
- **What it does**: Scans the codebase (or a specific path) and produces a review report grouped by tier (critical / high / medium / low). With `--create-tasks`, interactively creates tasks from findings using the multi-task creation standard.
- **When to use**: Periodic health check, before a release, or after a big batch of `/implement` runs.
- **Artifacts**: review report; optionally new tasks.

**`/todo [--dry-run]`** — Archive completed tasks
- **What it does**: Moves `[COMPLETED]` and `[ABANDONED]` tasks from `specs/TODO.md` to `specs/archive/`, updates `state.json`, appends to `CHANGE_LOG.md`, and (for non-meta tasks) annotates `ROAD_MAP.md` with completion summaries. Triggers "vault operation" renumbering if `next_project_number > 1000`.
- **When to use**: After finishing a batch of tasks, to keep TODO.md small.
- **Artifacts**: `specs/archive/`, CHANGE_LOG.md entries, `specs/vault/{NN-vault}/` on vault trigger.

### 4. Other Commands — Topic-Based Groups

**Task management & recovery**:
- `/spawn N [blocker]` — Research a blocker on a `[BLOCKED]` task and spawn new unblocking tasks, updating the parent task's dependency list. Skill: `skill-spawn` -> `spawn-agent`.
- `/errors [--fix N]` — Read `specs/errors.json`, analyze recurring error patterns, and create fix-plan tasks.
- `/fix-it [PATH...]` — Scan files for `FIX:`, `NOTE:`, `TODO:`, `QUESTION:` tags and interactively create tasks (one per tag or grouped). Full multi-task creation compliance.
- `/refresh [--dry-run] [--force]` — Clean up Claude Code resources: terminate orphaned processes and delete old files from `~/.claude/{projects,debug,file-history,todos,session-env,telemetry,cache}/` (default: 8 hours old).

**System / meta**:
- `/meta [prompt] | --analyze` — Interactive system builder. Creates tasks for `.claude/` architecture changes (new commands, skills, agents, extensions). **Never implements directly** — always outputs tasks for subsequent `/research` -> `/plan` -> `/implement` execution. Reference implementation of the multi-task creation standard (full Kahn's-algorithm DAG support).
- `/merge [--draft] [--assignee U] [--label L] [--reviewer U]` — Create a GitHub PR (`gh pr create`) or GitLab MR (`glab mr create`) for the current branch.

**Memory**:
- `/learn "text" | /path/to/file | /path/to/dir/ | --task N` — Add memories to the `.memory/` vault. Deduplicates against existing memories, classifies, and writes to `.memory/10-Memories/MEM-{slug}.md`. The `--task N` mode reviews a completed task's artifacts and proposes memories to extract. Pairs with `/research N --remember` to surface relevant memories during research.

**Document conversion & editing** (filetypes domain):
- `/convert SOURCE [OUT]` — Convert between PDF, DOCX, and Markdown.
- `/table data.xlsx [OUT] [--format latex|typst]` — Spreadsheet -> formatted table source.
- `/slides deck.pptx [OUT] [--format beamer|polylux|touying]` — Presentation -> slide source.
- `/scrape paper.pdf [OUT] [--format markdown|json] [--types ...]` — Extract PDF annotations/comments.
- `/edit file.docx "instruction" [--new]` — In-place DOCX editing with tracked changes via SuperDoc MCP. Supports batch edit over a directory.

**Research presentation & grants** (present domain):
- `/grant "desc" | N --draft ["focus"] | N --budget ["guidance"] | --revise N "desc" | N --fix-it` — Grant proposal research, drafting, and budget development.
- `/budget "desc" | N | /path/to/file.md | --quick [mode]` — Generate a grant budget spreadsheet (.xlsx) with formulas and justifications.
- `/timeline "desc" | N` — Build a research project timeline with milestones.
- `/funds "desc" | N | --quick [topic]` — Survey funding opportunities with eligibility and deadlines.
- `/talk "desc" | N | /path/to/file` — Build a research talk in one of five modes: CONFERENCE (15-20 min), SEMINAR (45-60 min), DEFENSE (30-60 min), POSTER, JOURNAL_CLUB.

### 5. Memory System (`.memory/`)

There are **two distinct memory layers** that the current doc conflates.

**Project memory vault** — `/home/benjamin/.config/zed/.memory/`:
- Managed by agents (not by Claude Code's harness).
- Written to by the memory extension via `skill-memory` and the `/learn` command.
- **Shared with OpenCode**: this is explicit in the README ("Obsidian-compatible vault shared between Claude Code and OpenCode AI systems"). Memory IDs include timestamps for collision resistance. Both systems fall back to grep-based search when the MCP server is unavailable.
- **Structure**:
  ```
  .memory/
  ├── .obsidian/       # Obsidian config (gitignored)
  ├── 00-Inbox/        # Quick-capture for new memories before classification
  ├── 10-Memories/     # Permanent storage (MEM-{semantic-slug}.md)
  ├── 20-Indices/      # index.md and topic indices (regenerated from filesystem)
  └── 30-Templates/    # memory-template.md and README
  ```
- **File format**: YAML frontmatter with `title`, `created`, `tags`, `topic`, `source`, `modified`. Filenames are the unique IDs (e.g., `MEM-telescope-custom-pickers.md`).
- **MCP ports**: Claude Code uses WebSocket 22360; OpenCode uses REST 27124. Only one AI system should run MCP-based search at a time; both fall back to grep otherwise.
- **How agents read it**: Grep-based discovery by default. Loaded on-demand by `/research N --remember`, which searches the vault and injects matches into the research context.
- **How agents write it**: The `/learn` command (skill: `skill-memory`, direct execution). Modes:
  - `/learn "text"` — inline capture with content mapping and deduplication.
  - `/learn /path/to/file.md` — ingest a file as a memory source.
  - `/learn /path/to/dir/` — scan directory for learnable content.
  - `/learn --task N` — review task artifacts and propose memories.
- **What belongs**: Learned facts, discoveries, decisions, reusable patterns, project-specific lessons. Per CLAUDE.md's "Context Architecture" decision tree: "Learned fact from development (discovery, decision, pattern)? -> `.memory/`".

**Claude Code auto-memory** — `~/.claude/projects/-home-benjamin--config-zed/memory/`:
- Managed by the Claude Code harness itself, not by agents.
- Stores user preferences and behavioral corrections captured automatically from conversation.
- Example (currently loaded): `feedback_no_vim_mode_zed.md` — "Zed shared with collaborator; use standard keybindings, not vim".
- **The user never writes this directly**; it is built up automatically as Claude Code learns preferences.
- Agents should not read or modify this directory; it is harness-private.

**Context architecture — the five layers** (from `.claude/CLAUDE.md`):

| Layer | Location | Owner | Purpose |
|-------|----------|-------|---------|
| Agent context | `.claude/context/` | Extension loader | Core agent patterns + extension knowledge |
| Extensions | `.claude/extensions/*/context/` | Extension loader | Language-specific standards (not populated in this repo) |
| Project context | `.context/` | User (via index.json) | Project conventions |
| Project memory | `.memory/` | Agents (via `/learn`) | Learned facts and discoveries |
| Auto-memory | `~/.claude/projects/` | Claude Code harness | User preferences |

The rewrite should devote an entire section to clarifying the Project Memory vs Auto-Memory distinction and showing the `00-Inbox` -> `10-Memories` promotion flow.

### 6. Cross-References — Files to Link from `docs/agent-system.md`

For each link, path is relative to `docs/agent-system.md` (which lives at `/home/benjamin/.config/zed/docs/`).

| Target | Relative path | Why link |
|--------|--------------|----------|
| Quick reference (always-loaded) | `../.claude/CLAUDE.md` | Entry point, loaded every session; canonical command list |
| Architecture navigation hub | `../.claude/README.md` | Three-layer architecture diagram, component specs |
| Documentation index | `../.claude/docs/README.md` | Map of all guides, examples, templates |
| System overview | `../.claude/docs/architecture/system-overview.md` | Detailed architecture, task lifecycle, state management |
| Extension architecture | `../.claude/docs/architecture/extension-system.md` | Explains the "when extensions are loaded" pattern referenced in CLAUDE.md |
| Command workflows guide | `../.claude/docs/guides/user-guide.md` | Comprehensive command reference with examples and troubleshooting |
| User installation | `../.claude/docs/guides/user-installation.md` | Quick-start (complements the installation section already in agent-system.md) |
| Component selection | `../.claude/docs/guides/component-selection.md` | Decision tree for command vs skill vs agent (power users) |
| Creating commands | `../.claude/docs/guides/creating-commands.md` | Authoring new slash commands |
| Creating skills | `../.claude/docs/guides/creating-skills.md` | Thin wrapper skill pattern |
| Creating agents | `../.claude/docs/guides/creating-agents.md` | Agent frontmatter, delegation |
| Creating extensions | `../.claude/docs/guides/creating-extensions.md` | Extension loader |
| Agent frontmatter standard | `../.claude/docs/reference/standards/agent-frontmatter-standard.md` | Model declaration, routing |
| Multi-task creation standard | `../.claude/docs/reference/standards/multi-task-creation-standard.md` | Used by `/fix-it`, `/meta`, `/review`, `/errors` |
| State management rules | `../.claude/rules/state-management.md` | TODO.md/state.json patterns and vault operation schema |
| Git workflow rules | `../.claude/rules/git-workflow.md` | Commit conventions, session ID format |
| Artifact formats | `../.claude/rules/artifact-formats.md` | Report, plan, summary formats |
| Error handling | `../.claude/rules/error-handling.md` | errors.json schema, recovery strategies |
| Workflows rule | `../.claude/rules/workflows.md` | Checkpoint execution pattern |
| Memory vault README | `../.memory/README.md` | Structure, sharing with OpenCode, MCP setup |
| Research flow example | `../.claude/docs/examples/research-flow-example.md` | End-to-end walkthrough |
| Fix-it flow example | `../.claude/docs/examples/fix-it-flow-example.md` | Tag extraction example |

### 7. Other Structural Improvements

- **Reorder sections**: Installation -> Two AI Systems (intro) -> Claude Code Main Workflow (lifecycle) -> Command Catalog by Topic -> Memory System -> Architecture & Configuration -> MCP Tool Setup -> Known Limitations -> Related Documentation. Currently installation is mixed with general orientation and the command catalog is incomplete.
- **Add a state machine diagram** (ASCII) showing `[NOT STARTED] -> [RESEARCHING] -> ... -> [COMPLETED]` with the commands that cause each transition.
- **Add a "Checkpoint execution" callout** explaining GATE IN -> DELEGATE -> GATE OUT -> COMMIT, so users understand why every command produces a git commit.
- **Clarify the extension situation**: state plainly that in this Zed workspace all 24 commands are always available; the "extension loading" pattern in CLAUDE.md is documented but does not apply here (no `.claude/extensions/` directory).
- **Remove the `/tag` reference** from Known Limitations (no command file exists in this repo), or explicitly note it as "documented but not installed".
- **Expand the directory tree** in the Configuration section to show `docs/`, `rules/`, `scripts/`, and the state files under `specs/`.
- **Add a note on multi-task syntax** for `/research`, `/plan`, `/implement`: comma/range syntax (e.g., `/research 5, 7-9`) with parallel agent execution.
- **Add a note on `--team` mode**: requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, uses ~5x tokens, gracefully degrades to single-agent.
- **Add a "Session IDs and git commits" note** explaining that every command commit contains `Session: sess_{unix}_{random}` for trajectory reconstruction.
- **Preserve the Zed Agent Panel section as-is** — it's the best part of the current doc.

---

## Decisions

- **D1**: Use a topic-based grouping (task mgmt, system/meta, memory, filetypes, present) rather than alphabetical, to reduce cognitive load for a reader unfamiliar with the system. Main lifecycle commands get their own dedicated section up top.
- **D2**: Treat "extensions" as documented-but-not-installed in this workspace. Commands that CLAUDE.md describes as "from the filetypes extension" are presented simply as "document conversion commands" with no loading-step caveat. Retain one sentence noting that CLAUDE.md's extension architecture exists for portability across projects.
- **D3**: Drop `/tag` from the user-facing doc (not present in this repo) unless the planner wants to preserve parity with CLAUDE.md; if preserved, flag explicitly.
- **D4**: Split the memory section into two sub-sections — "Project Memory Vault (.memory/)" and "Auto-Memory (managed by Claude Code)" — to correct the current conflation.
- **D5**: Preserve the installation and MCP tool setup sections verbatim; they are accurate and load-bearing for a fresh reader.
- **D6**: Link to `.claude/CLAUDE.md` as the canonical command reference for power users, while keeping `docs/agent-system.md` focused on orientation and common workflows.

---

## Risks & Mitigations

- **Risk**: `.claude/CLAUDE.md` and `.claude/README.md` get out of sync with the commands directory (e.g., `/tag` mentioned but not shipped). **Mitigation**: Have the planner generate the command list from `ls .claude/commands/` rather than from CLAUDE.md; add a test-style note suggesting future `/review` runs check command parity.
- **Risk**: Rewrite drifts into a reference document and loses the "orientation for newcomers" purpose. **Mitigation**: Plan should cap the main-workflow section at ~150 lines and push detail into cross-references.
- **Risk**: Linking into `.claude/docs/guides/*.md` assumes those files exist with their current names. **Mitigation**: The planner should verify each target file exists before embedding the link. Every target in Section 6 has been verified against `ls .claude/docs/` during this research phase.
- **Risk**: Extension documentation confusion — users may try `<leader>ac` to load extensions, which will not work in Zed. **Mitigation**: Add an explicit note that extension loading is a neovim-only feature; in Zed all commands are already available.

---

## Context Extension Recommendations

- **Topic**: Multi-system memory coordination (Claude Code + OpenCode sharing `.memory/`)
  - **Gap**: `.claude/context/` does not document how agents should behave when both AI systems write to the vault concurrently. The `.memory/README.md` mentions MCP port separation but not agent-level etiquette.
  - **Recommendation**: Consider a future `.claude/context/patterns/shared-memory-vault.md` describing the concurrency model, timestamp-based collision, and grep-fallback behavior.

- **Topic**: Which commands ship in this workspace vs which are documented-only
  - **Gap**: `.claude/CLAUDE.md` advertises commands and extensions that are not installed here (e.g., `/tag`, `<leader>ac` extension loading). This confuses doc-generation tasks like the current one.
  - **Recommendation**: Either install the missing commands, remove them from CLAUDE.md, or add a `.claude/context/repo/installed-vs-documented.md` manifest listing what is actually available in this specific repo.

---

## Appendix

### Searches Performed

- `ls /home/benjamin/.config/zed/.claude/commands/` — inventoried 24 command files
- `ls /home/benjamin/.config/zed/.claude/{agents,skills,rules,docs}/` — inventoried components
- `ls /home/benjamin/.config/zed/.claude/extensions/` — confirmed the directory does not exist
- `head -4` on all 24 command files — extracted frontmatter `description:` fields
- Read `/home/benjamin/.config/zed/.claude/README.md` (259 lines)
- Read `/home/benjamin/.config/zed/.claude/docs/README.md` (99 lines)
- Read `/home/benjamin/.config/zed/.memory/README.md` (101 lines)
- Read `/home/benjamin/.config/zed/docs/agent-system.md` (185 lines, current doc)
- Loaded `.claude/CLAUDE.md`, `.claude/rules/error-handling.md`, `.claude/rules/git-workflow.md`, `.claude/rules/workflows.md` as system reminders

### Key References (absolute paths)

- Current doc: `/home/benjamin/.config/zed/docs/agent-system.md`
- Target doc (same path, rewrite): `/home/benjamin/.config/zed/docs/agent-system.md`
- Authoritative architecture: `/home/benjamin/.config/zed/.claude/README.md`
- Canonical command reference: `/home/benjamin/.config/zed/.claude/CLAUDE.md`
- Standards hub: `/home/benjamin/.config/zed/.claude/docs/README.md`
- Memory vault: `/home/benjamin/.config/zed/.memory/`
- Auto-memory (harness-managed): `/home/benjamin/.claude/projects/-home-benjamin--config-zed/memory/`
- Commands directory: `/home/benjamin/.config/zed/.claude/commands/`
- Agents directory: `/home/benjamin/.config/zed/.claude/agents/`
- Rules directory: `/home/benjamin/.config/zed/.claude/rules/`
