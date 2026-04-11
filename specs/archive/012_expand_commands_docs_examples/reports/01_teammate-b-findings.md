# Teammate B Findings: Maintenance & Memory Commands

**Task**: Expand docs/agent-system/commands.md with examples and explanations for each command.
**Focus**: Maintenance & Memory commands — /spawn, /errors, /fix-it, /refresh, /meta, /tag, /merge, /learn
**Date**: 2026-04-10

---

## Current State of commands.md

The existing `docs/agent-system/commands.md` already has entries for all eight commands in the Maintenance and Memory sections, but they are intentionally terse — one-sentence summary, minimal example, and flag list. The stated goal was for each entry to be "terse." The task is to add 2-3 sentence explanations, practical multi-flag examples, key behaviors, and edge-case notes.

---

## Command Research

### /spawn

**Source**: `.claude/commands/spawn.md`

**What it does**: `/spawn` handles blocked or stalled tasks by invoking a spawn-agent that analyzes the blocker, decomposes the work into minimal prerequisite tasks, and establishes dependency relationships in state.json. The parent task is marked `[BLOCKED]`, and the newly created subtasks get statuses of `[RESEARCHED]` so they can move immediately to planning. A spawn analysis report is written to `specs/{NNN}_{SLUG}/reports/02_spawn-analysis.md`.

**When to use it**: Use when an implementation is stuck (status: `blocked`, `partial`, or `implementing`) and you need to identify and create prerequisite work. Can also be used preemptively on `planned` or `not_started` tasks when scope seems too large.

**Examples**:
```
# Auto-detect blocker from task context
/spawn 241

# Provide explicit blocker description to guide analysis
/spawn 241 "missing state validation utilities before recovery can be implemented"

# Preemptive decomposition before implementation starts
/spawn 150 "task scope is too large, need to break down"
```

**Key behaviors**:
- Allowed statuses: `implementing`, `partial`, `blocked`, `planned`, `researched`, `not_started`
- Blocked on: `completed` (nothing to spawn), `abandoned` (recover first), `researching`/`planning` (wait)
- Creates a dependency graph: spawned subtasks must complete before the parent task can resume
- Git commit is handled internally by skill-spawn (command does not commit separately)
- Output includes a dependency graph and ordered next steps

**Edge cases**:
- If task is `abandoned`, recover it with `/task --recover N` before spawning
- Blocker description is optional but improves analysis quality significantly
- GATE OUT verifies both parent status update and new task existence; retries skill on failure

---

### /errors

**Source**: `.claude/commands/errors.md`

**What it does**: `/errors` reads `specs/errors.json`, groups errors by type and severity, identifies recurring patterns and root causes, writes an analysis report to `specs/errors/analysis-{DATE}.md`, and automatically creates fix tasks for significant patterns. The `--fix N` mode implements the actual fixes for a specific error-fix task and marks affected errors as resolved.

**When to use it**: Run after encountering repeated failures, hanging implementations, or build errors to get a structured diagnosis and actionable task backlog. The `--fix N` mode is used after a fix task has been planned and you want to execute the fixes.

**Examples**:
```
# Analyze all errors and create fix tasks automatically
/errors

# Implement fixes for a specific error-fix task
/errors --fix 12
```

**Key behaviors**:
- Default mode is fully automatic — no interactive selection prompt
- Groups errors by: type, severity, recurrence count, and command/agent context
- Report structure: summary table, critical unfixed list with root cause analysis, recommended fix plan
- Fix mode marks individual errors as `fixed` with `fixed_date` and `fix_task` fields in errors.json
- Git commit after fix mode: `errors: fix {N} errors (task {M})`

**Edge cases**:
- Intentionally does not support interactive selection (design choice for quick triage)
- No dependency support between fix tasks — creation is sequential
- If `errors.json` is empty or absent, the command will find nothing to analyze

---

### /fix-it

**Source**: `.claude/commands/fix-it.md`

**What it does**: `/fix-it` scans source files for embedded `FIX:`, `NOTE:`, `TODO:`, and `QUESTION:` tags and then interactively guides the user through creating structured tasks from the findings. The command always shows findings before creating anything — there is no dry-run flag because the interactive flow itself is preview-first.

**When to use it**: Use when you have accumulated inline annotations in source code that represent deferred work. Run on a specific directory or file to scope the scan, or with no arguments to scan the entire project.

**Examples**:
```
# Scan entire project
/fix-it

# Scan a specific directory
/fix-it nvim/lua/Layer1/

# Scan a specific file
/fix-it docs/04-Metalogic.tex

# Scan multiple paths
/fix-it nvim/lua/ .claude/agents/
```

**Key behaviors**:
- Four tag types produce different task kinds:
  - `FIX:` -> single combined fix-it-task
  - `NOTE:` -> fix-it-task + learn-it-task (with dependency: learn runs first)
  - `TODO:` -> individual tasks per item (or topic-grouped)
  - `QUESTION:` -> research tasks (language detected from content keywords, not file type)
- When multiple TODOs are selected, offers three grouping options: suggested topic groups, separate tasks, or single combined task
- Supports Lua (`--`), LaTeX (`%`), Markdown (`<!--`), Python/Shell/YAML (`#`) comment styles
- Git commit happens automatically after task creation

**Edge cases**:
- `--dry-run` flag was removed; the interactive flow serves the same purpose
- For >20 TODO items, a "Select all" option is added to the selection prompt
- NOTE: tags create a dependency chain — learn-it task must complete before fix-it task runs
- Language detection for QUESTION: research tasks uses keyword matching (e.g., `nvim`, `lsp` -> neovim; `.claude`, `command` -> meta)

---

### /refresh

**Source**: `.claude/commands/refresh.md`

**What it does**: `/refresh` cleans up two categories of accumulated Claude Code resources: orphaned background processes (detached processes without a controlling terminal) and stale files in `~/.claude/` directories including session logs, debug output, file history, telemetry, and cache. It can reclaim several gigabytes on heavily-used systems.

**When to use it**: Run periodically when `~/.claude/` grows large (the command shows current size), or after a session where Claude Code processes may have been abandoned. Also useful before a long implementation run to ensure a clean environment.

**Examples**:
```
# Interactive mode: shows status, prompts for confirmation and age threshold
/refresh

# Preview what would be cleaned without making changes
/refresh --dry-run

# Skip prompts, clean with 8-hour default threshold
/refresh --force
```

**Key behaviors**:
- Interactive mode (no flags) asks for age threshold: 8 hours (default), 2 days, or clean slate
- Safety margin: files modified within the last hour are never deleted regardless of threshold
- Protected files never deleted: `sessions-index.json`, `settings.json`, `.credentials.json`, `history.jsonl`
- Process cleanup only targets TTY="?" processes (no controlling terminal); never kills active sessions
- Shows a directory-by-directory breakdown of cleanable size before acting

**Edge cases**:
- If `~/.claude/` is >5GB, start with "2 days" threshold to preserve recent work
- Permission errors may occur for some processes; root access or manual kill may be needed
- `--force` uses the 8-hour default — there is no way to combine `--force` with a custom age threshold without modifying the skill

---

### /meta

**Source**: `.claude/commands/meta.md`

**What it does**: `/meta` is an interactive system builder for making changes to the `.claude/` agent architecture. It conducts a structured interview (or parses a direct prompt) to understand the required changes, then creates tasks in TODO.md and state.json for subsequent `/research` -> `/plan` -> `/implement` execution. It never directly modifies `.claude/` files — everything goes through the task system.

**When to use it**: Use when you want to add a new command, skill, agent, or rule to the agent system, or make significant changes to existing components. The `--analyze` flag provides a read-only inventory of the current system without creating tasks.

**Examples**:
```
# Start the full 7-stage interactive interview
/meta

# Direct prompt for an abbreviated flow with confirmation
/meta "add a new command for exporting logs"

# Read-only analysis of current .claude/ structure
/meta --analyze
```

**Key behaviors**:
- Three modes: interactive (7-stage interview), prompt (abbreviated flow), analyze (read-only)
- FORBIDDEN to directly create commands, skills, rules, or context files
- Interactive mode uses AskUserQuestion for multi-turn conversation across 7 stages: DetectExistingSystem, InitiateInterview, GatherDomainInfo, IdentifyUseCases, AssessComplexity, ReviewAndConfirm, CreateTasks
- This is the reference implementation of the 8-component multi-task creation standard
- Supports both internal dependencies (between newly created tasks) and external dependencies (on existing tasks) via Kahn's algorithm topological sort

**Edge cases**:
- Always requires explicit user confirmation before creating tasks (mandatory in Stage 5/ReviewAndConfirm)
- `/meta --analyze` produces an inventory but never modifies any files
- Tasks created by `/meta` are of type `meta` and route to `skill-implementer` for execution

---

### /tag

**Source**: No dedicated command file exists. Documented only in `.claude/CLAUDE.md` and `docs/guides/user-guide.md`.

**What it does**: `/tag` creates a semantic version tag on the current git commit following semver conventions (patch, minor, major). It is a user-only command that cannot be invoked by agents or other skills — it represents a human-controlled deployment gate.

**When to use it**: Use after completing a significant milestone or release-worthy set of changes. The appropriate flag selects the version bump level.

**Examples**:
```
# Bump patch version (bug fixes, small changes)
/tag --patch

# Bump minor version (new features, backwards-compatible)
/tag --minor

# Bump major version (breaking changes)
/tag --major
```

**Key behaviors**:
- User-only command: cannot be invoked by agents (no skill-tag file exists as an invokable agent skill)
- Uses semantic versioning conventions (patch/minor/major)
- No dedicated command file — behavior is defined directly in system routing tables

**Edge cases**:
- No dedicated `.claude/commands/tag.md` file was found; the command is defined at the system level
- Confidence on implementation details is lower than other commands due to missing source file

---

### /merge

**Source**: `.claude/commands/merge.md`

**What it does**: `/merge` creates a GitHub Pull Request or GitLab Merge Request for the current branch. It automatically detects the platform from the git remote URL, pushes the branch to origin with upstream tracking if needed, and creates the PR/MR via the `gh` or `glab` CLI using `--fill` to auto-populate title and description from commit history.

**When to use it**: Use at the end of a feature branch or task branch when work is ready for review and merging. Must be on a non-main branch.

**Examples**:
```
# Create PR/MR with auto-detected platform and filled description
/merge

# Create as draft (work in progress, not ready for review)
/merge --draft

# Assign to a user and request review
/merge --assignee johndoe --reviewer janesmith

# Target a non-default branch (e.g., develop instead of main)
/merge --target develop

# Full options: draft, assignee, label, reviewer
/merge --draft --assignee johndoe --label "wip" --reviewer janesmith
```

**Key behaviors**:
- Platform detection: URL pattern matching first (github.com/gitlab.com), then CLI availability fallback
- Automatically runs `git push -u origin HEAD` before creating PR/MR
- Uses `--fill`/`--fill --yes` to populate title and body from commit messages
- Default target branch is `main`; override with `--target BRANCH`
- Supports `--title` and `--body` for custom descriptions (overrides --fill content)

**Edge cases**:
- Stops with a clear error if on `main` or `master` branch
- Platform detection fails on self-hosted or custom domain remotes — requires CLI auth fallback
- If PR/MR already exists for the branch, the CLI shows the existing URL rather than erroring
- Enterprise GitHub/GitLab requires CLI configured with instance URL

---

### /learn

**Source**: `.claude/commands/learn.md`

**What it does**: `/learn` adds knowledge to the `.memory/` vault using four input modes: inline text, single file, directory scan, or task artifact review. It performs content mapping (segmenting large inputs into topic chunks), searches for related existing memories via MCP search or grep fallback, and executes three memory operations: UPDATE (merge into existing), EXTEND (append to existing), or CREATE (new memory file). Deduplication is built into the process.

**When to use it**: Use to capture important knowledge discovered during development — patterns, configurations, techniques, insights. The `--task N` mode is especially useful after completing a task to harvest research findings and implementation decisions into long-term memory.

**Examples**:
```
# Add inline text as memory
/learn "Use pcall() in Lua for safe function calls that might error"

# Import a single file into the memory vault
/learn ~/notes/debugging.md

# Scan a directory for learnable content (interactive selection)
/learn ~/papers/

# Harvest knowledge from a completed task's artifacts
/learn --task 142
```

**Key behaviors**:
- Four modes with priority chain: `--task` -> directory path (ends with `/`) -> file path -> text
- Memory operations: UPDATE (high overlap), EXTEND (partial overlap), CREATE (new topic)
- Task mode: presents artifact list for user selection, then classifies each segment into [TECHNIQUE], [PATTERN], [CONFIG], [WORKFLOW], [INSIGHT], or [SKIP]
- Directory mode: excludes `.git/`, `node_modules/`, `__pycache__`, binary files; 100KB per file limit, hard cap at 200 files
- Gracefully degrades to grep-based search if MCP is unavailable
- Updates both category and topic sections of `.memory/20-Indices/index.md`

**Edge cases**:
- Directory path must end with `/` or the path is detected via filesystem check — ambiguous paths default to file mode
- Files under 500 tokens become a single memory segment (no chunking)
- If all segments are skipped during interactive review, no memories are created and no files are written
- `--task N` mode requires the task directory to exist at `specs/{NNN}_{SLUG}/`
- Task mode supports an optional `--category PATTERN` filter to focus extraction

---

## Key Findings

1. **No tag.md command file**: `/tag` has no dedicated command file in `.claude/commands/`. It is defined only in routing tables in CLAUDE.md. This is a gap in documentation coverage — the examples and behavior must be inferred from system-level documentation.

2. **Interactive vs automatic design split**: `/fix-it` and `/meta` are fully interactive (always show findings before acting). `/errors` intentionally bypasses interaction for quick triage. This design philosophy difference is worth documenting explicitly.

3. **User-only enforcement for /tag**: The "user-only" constraint on `/tag` is a meaningful security boundary — agents cannot trigger version tags. This should be called out in documentation.

4. **`/refresh` safety margins**: The 1-hour safety margin (files modified in the last hour are never deleted) and the list of protected files are important for user confidence. Worth including in expanded docs.

5. **`/learn` deduplication workflow**: The three-operation model (UPDATE/EXTEND/CREATE) with content mapping and MCP-backed similarity search is more sophisticated than a simple "add a note." The memory extension requires the memory extension to be loaded.

6. **`/merge` `--fill` behavior**: The command uses `--fill` to auto-populate PR/MR content from git commit history — this is a key usability detail not visible from the flag list alone.

7. **`/spawn` output includes dependency graph**: The spawn output produces a visual dependency chain showing the order in which spawned tasks and the parent task should be completed.

---

## Confidence Level

| Command | Confidence | Notes |
|---------|------------|-------|
| /spawn | High | Full source file available, detailed execution steps |
| /errors | High | Full source file available |
| /fix-it | High | Full source file available, extensive examples |
| /refresh | High | Full source file available, clear safety semantics |
| /meta | High | Full source file available, reference implementation |
| /tag | Low-Medium | No command file found; behavior inferred from CLAUDE.md and user-guide.md routing tables only |
| /merge | High | Full source file available, platform-specific flag mapping documented |
| /learn | High | Full source file available, four-mode workflow well-documented |

**Overall Confidence**: High for 7 of 8 commands. The `/tag` command lacks a dedicated source file and may have additional implementation details not captured here.
