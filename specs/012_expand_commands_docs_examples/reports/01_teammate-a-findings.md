# Teammate A Findings: Lifecycle Commands

**Task 12**: Expand docs/agent-system/commands.md with examples and explanations
**Focus**: The 7 Lifecycle Commands — /task, /research, /plan, /implement, /revise, /review, /todo
**Sources**: `.claude/commands/{task,research,plan,implement,revise,review,todo}.md` + `docs/agent-system/commands.md`

---

## Current State of commands.md

The file already has a **Lifecycle** section (lines 7–89) with one-sentence descriptions and a single usage example per command. Each entry is intentionally terse by design ("Each entry is intentionally terse: one-sentence summary, minimal example, flag list, and link"). The task is to expand these with richer explanations and additional usage examples without turning the file into a full reference manual.

---

## Command Analysis

### /task

**What it does**: Creates and manages tasks in the system. Without flags it records a new task entry in `specs/TODO.md` and `specs/state.json`, auto-detects task type from keywords in the description, and normalizes the description (slug expansion, verb inference, capitalization). It does NOT execute anything related to the description — it only records it. With flags it handles lifecycle management: recover archived tasks, expand a task into subtasks, sync state/TODO divergences, or abandon tasks.

**Key behaviors**:
- Auto-detects `task_type` from keywords (neovim, lean4, meta, python, typst, latex, etc.)
- Normalizes descriptions: expands snake_case slugs, infers missing action verbs (Fix/Update/Add/Implement), capitalizes
- DOES NOT read or interpret the description — it only stores it
- Creates task directories lazily (on first artifact write), not at creation time
- Directory uses 3-digit padding (`specs/015_slug/`) but TODO.md uses unpadded numbers

**Usage examples**:
```
# Create a general task
/task "Add dark-mode toggle to settings page"

# Create a task (auto-detects type from "neovim" keyword)
/task "Fix neovim LSP configuration for Python"

# Recover an archived task back to active
/task --recover 42

# Abandon tasks (accepts ranges)
/task --abandon 7, 8-10

# Expand a task into subtasks (breaks large task into 2-5 sub-items)
/task --expand 15

# Sync TODO.md and state.json when they've drifted
/task --sync

# Review incomplete phases of a task and optionally create follow-up tasks
/task --review 23
```

**Edge cases**:
- `--recover` supports ranges: `--recover 343-345`
- `--review N` inspects plan phases, shows incomplete ones, offers interactive selection to create follow-up tasks. Does NOT modify the reviewed task's status.
- `--expand` creates 2–5 subtasks and marks original as `[EXPANDED]`
- Description transformation is not applied when input starts with a recognized action verb or contains file paths/quoted strings

---

### /research

**What it does**: Investigates a task and produces a research report in `specs/{NNN}_{SLUG}/reports/`. Routes to different research agents based on the task's `task_type` (e.g., epidemiology tasks go to `epidemiology-research-agent`). Accepts a focus prompt to direct the investigation toward a specific angle. Supports researching multiple tasks in parallel using comma/range syntax.

**Key behaviors**:
- Status transitions: `[NOT STARTED]` → `[RESEARCHING]` → `[RESEARCHED]`
- Allowed input statuses: `not_started`, `researched`, `planned`, `partial`, `blocked` (re-research is allowed)
- `--team` spawns 2–4 parallel research agents that each investigate a different angle, then synthesizes findings. Costs ~5x tokens.
- `--remember` flag (requires memory extension) searches the memory vault for prior relevant knowledge before researching
- Multi-task mode runs all tasks fully independently and in parallel; partial success is normal
- Focus prompt (free text after task number) narrows the investigation

**Usage examples**:
```
# Basic research on task 5
/research 5

# Research with a focus on a specific aspect
/research 5 focus on API design and backward compatibility

# Research multiple tasks in parallel
/research 7, 22-24, 59

# Team research (parallel agents, ~5x cost)
/research 5 --team

# Team research with custom team size
/research 5 --team --team-size 4

# Research augmented with memory vault
/research 5 --remember

# Multi-task team research (combine flags)
/research 7, 22-24 --team
```

**Edge cases**:
- Re-researching an already-researched task is explicitly allowed (status `researched` is a valid input)
- If the task is `completed` or `abandoned`, the command aborts with a recommendation
- Team mode gracefully degrades to single-agent if `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` env var is not set
- Multi-task: failure of one task does not block others; failed tasks remain in `[RESEARCHING]` for manual retry

---

### /plan

**What it does**: Creates a phased implementation plan by reading the task's research report and decomposing the work into logical phases with goals, steps, and risk mitigations. Writes the plan to `specs/{NNN}_{SLUG}/plans/`. Works on any non-terminal task status (not just `researched`) — useful when circumstances change mid-flight.

**Key behaviors**:
- Status transitions: any non-terminal → `[PLANNING]` → `[PLANNED]`
- A prior plan file is passed to the planner for context (revision-aware planning)
- `--team` spawns 2–3 agents that generate alternative plan approaches in parallel, then synthesizes into a final plan with trade-off analysis
- Routing: task type determines the planning skill (extension-based). Falls back to `skill-planner` / `planner-agent` (opus model) for general tasks
- Supports multi-task batch mode (comma/range syntax) with parallel agent dispatch

**Usage examples**:
```
# Plan a single task
/plan 5

# Plan multiple tasks in parallel
/plan 7, 22-24, 59

# Team planning (generates multiple candidate plans, synthesizes best)
/plan 5 --team

# Team planning with 3 teammates
/plan 5 --team --team-size 3

# Re-plan after research changed (re-runs planner with prior plan as context)
/plan 5
```

**Edge cases**:
- `/plan` on a `not_started` task (no research report) works — the planner will note the lack of research but still generates a plan
- Re-planning after `/revise` is the normal workflow: run `/plan` again to get a fresh plan
- Completed and abandoned tasks are the only states that abort; all others proceed

---

### /implement

**What it does**: Executes an implementation plan phase by phase. On each run it scans the plan for the first incomplete phase (`[NOT STARTED]`, `[IN PROGRESS]`, or `[PARTIAL]`) and starts or resumes there. When interrupted (timeout, error), progress is preserved in the plan file's phase markers and the next `/implement` call automatically picks up where it left off. Creates a completion summary in `specs/{NNN}_{SLUG}/summaries/`.

**Key behaviors**:
- Status transitions: planned/partial → `[IMPLEMENTING]` → `[COMPLETED]` (or `[PARTIAL]` on interrupt)
- **Resume**: scans plan phase markers on every run — `[NOT STARTED]`=start, `[IN PROGRESS]`/`[PARTIAL]`=resume, `[COMPLETED]`=skip
- `--force` lets you re-implement a `[COMPLETED]` task (skips the "already done" abort)
- `--team` spawns parallel agents for independent phases; dependent phases wait for prerequisites. A debugger agent can be spawned on build errors
- Requires a plan file — aborts if none found ("Run /plan N first")
- On completion writes `completion_summary` to state.json, which `/todo` uses for ROADMAP.md annotation

**Usage examples**:
```
# Implement task 5 (starts from first incomplete phase)
/implement 5

# Resume after interruption (same command — auto-detects resume point)
/implement 5

# Implement multiple tasks in parallel
/implement 7, 22-24, 59

# Team implementation (parallel phases)
/implement 5 --team

# Re-implement a completed task (e.g., to apply additional changes)
/implement 5 --force

# Multi-task with force (useful after /revise on completed tasks)
/implement 10-12 --force
```

**Edge cases**:
- Interrupted implementations leave phases marked `[PARTIAL]`; re-running resumes automatically
- Abandoned tasks cannot be implemented — must be recovered with `/task --recover N` first
- Partial commit is made per-phase so progress is never lost even mid-implementation
- `--team` is ~5x token cost; `--force` on an already-complete task restarts from the first incomplete/all phases

---

### /revise

**What it does**: Creates a new version of an implementation plan by running the reviser agent, which loads the current plan and synthesizes a revised version using any new research or the provided revision reason. If no plan exists yet, it updates the task description instead. The revised plan file replaces (same artifact number) the prior plan rather than incrementing the sequence.

**Key behaviors**:
- Works on ANY task status — no valid status restrictions except task must exist
- Two code paths: plan revision (if plan file exists) vs. description update (if no plan)
- The revision reason (free text after task number) guides the reviser agent
- After revision, status is set to `[PLANNED]` regardless of prior status
- Artifact numbering: revised plan uses the SAME sequence number as the old plan (not incremented)
- The reviser agent (opus model) discovers new research artifacts and synthesizes them into the revision

**Usage examples**:
```
# Revise plan for task 5 (opens reviser agent to synthesize new plan)
/revise 5

# Revise with an explicit reason to guide the revision
/revise 5 "Reviewer feedback: split phase 2 into smaller chunks"

# Revise a task whose description needs updating (no plan yet)
/revise 3 "Scope has changed: now includes API documentation"

# Re-plan after new research was added
/research 5 focus on edge cases
/revise 5 "Incorporate new edge case findings from research"
```

**Edge cases**:
- No status restriction — can revise a task that is `[IMPLEMENTING]`, `[PARTIAL]`, or even `[COMPLETED]` (use with `--force` on /implement to re-execute)
- Revision reason is optional; without it the reviser agent still discovers new research and revises based on its judgment
- If no plan file exists, revision falls back to description update mode (status unchanged)

---

### /review

**What it does**: Analyzes the codebase for issues, categorizes findings by severity (Critical/High/Medium/Low), cross-references the ROADMAP.md for progress, and writes a review report to `specs/reviews/review-{DATE}.md`. Optionally creates tasks for identified issues. Includes roadmap integration: marks completed items in ROADMAP.md and suggests next priorities.

**Key behaviors**:
- Default behavior: analyze codebase, generate report, present interactive issue selection via AskUserQuestion
- `--create-tasks` flag: auto-creates tasks for all Critical/High issues without prompting
- Scans for: TODO/FIXME comments, security issues, error handling gaps, code quality, missing docs
- Roadmap integration: parses `specs/ROADMAP.md`, cross-references completed tasks, auto-annotates items as done
- Maintains review history in `specs/reviews/state.json`
- Optional scope argument: file path, directory, or "all" (default)

**Usage examples**:
```
# Full codebase review (default)
/review

# Review and auto-create tasks for critical/high issues
/review --create-tasks

# Review a specific directory
/review src/

# Review a specific file
/review src/components/Modal.tsx

# Review with scope and task creation
/review .claude/ --create-tasks
```

**Edge cases**:
- If `specs/ROADMAP.md` doesn't exist, `/review` creates it from a default template before proceeding
- Roadmap annotations only fire for high-confidence matches (explicit `roadmap_items` field, or `(Task N)` references)
- Task Order section in TODO.md is also parsed and can be managed interactively
- Without `--create-tasks`, the command presents an interactive group-selection dialog to let the user choose which issues to turn into tasks

---

### /todo

**What it does**: Archives completed and abandoned tasks from the active list. Moves task data from `specs/state.json` to `specs/archive/state.json`, moves task directories to `specs/archive/`, updates TODO.md, annotates ROADMAP.md with completion data from task summaries, and displays any CLAUDE.md update suggestions from meta tasks. Run routinely after completing a batch of work to keep the active list clean.

**Key behaviors**:
- `--dry-run`: previews what would be archived without making changes — useful before large archive operations
- Roadmap annotation: uses `completion_summary` and `roadmap_items` fields from state.json to annotate ROADMAP.md items as done
- Meta tasks get separate treatment: their `claudemd_suggestions` field is displayed for user review rather than written to ROADMAP.md
- Detects and handles orphaned directories (in `specs/` not tracked in any state file) and misplaced directories (tracked in archive but physically in `specs/`)
- Vault operation: when `next_project_number > 1000`, triggers a vault archival with user confirmation and task renumbering
- CHANGE_LOG.md is updated with each archive run

**Usage examples**:
```
# Archive all completed and abandoned tasks
/todo

# Preview what would be archived (safe, no changes)
/todo --dry-run

# Normal workflow: review what will be archived, then archive
/todo --dry-run
/todo
```

**Edge cases**:
- Only `completed` and `abandoned` tasks are archived; `partial`, `blocked`, and `not_started` remain active
- Orphaned directories (exist on disk but not in state.json) trigger an interactive prompt asking how to handle them
- Meta tasks use `claudemd_suggestions` (not ROADMAP.md) to convey what `.claude/CLAUDE.md` sections should be added/updated/removed
- CHANGE_LOG.md is required/created at `specs/CHANGE_LOG.md`; if it doesn't exist, `/todo` creates it

---

## Key Findings Summary

1. **Multi-task syntax** (`/research 7, 22-24, 59`) is one of the most powerful but least-documented features across `/research`, `/plan`, and `/implement`. Each task is researched/planned/implemented by a parallel agent. This deserves prominent mention.

2. **Resume behavior** in `/implement` is implicit and automatic — the same command always resumes correctly; there is no `--resume` flag. This is a common point of confusion worth clarifying.

3. **`/revise` has no status restriction** — it can operate on any task in any status. This makes it useful for mid-implementation course corrections.

4. **`/task --review N`** is an underrated subcommand that analyzes plan phase completion and helps create follow-up tasks for incomplete phases. It's conceptually different from `/review` (which reviews the codebase).

5. **`/todo --dry-run`** is safe and informative; users should always run it first before a big archive operation. The current commands.md shows this example but doesn't explain why.

6. **Team mode** (`--team`) is available for `/research`, `/plan`, and `/implement` with different teammate limits (2–4, 2–3, 2–4 respectively). Each uses ~5x tokens and requires the env var `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

7. **`/review` vs `/task --review N`** may confuse users: `/review` analyzes the codebase for issues; `/task --review N` analyzes a specific task's plan phases for completion status.

8. **Roadmap integration** runs through both `/review` and `/todo` — `/review` identifies what's done and annotates ROADMAP.md; `/todo` does the same at archive time using `completion_summary` fields.

---

## Confidence Level

**High** — All findings come directly from reading the command source files in `.claude/commands/`. No inference required; the command implementations are detailed and explicit.

Minor uncertainty: the `/review` command source file is very long (400+ lines) and the portion covering Task Order management was only partially read. The core review behavior, scope flags, `--create-tasks` flag, and roadmap integration were all fully read. The Task Order feature (parsing TODO.md Task Order section) is a secondary feature not currently documented in commands.md.
