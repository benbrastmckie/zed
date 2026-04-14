# Command Catalog

Quick-reference catalog of all 25 slash commands. For a workflow tutorial, see [agent-lifecycle.md](../workflows/agent-lifecycle.md). For full command reference with examples and edge cases, see [user-guide.md](../../.claude/docs/guides/user-guide.md). For how commands, skills, and agents connect, see [architecture.md](architecture.md).

Each entry follows a standard template: 2-sentence explanation, up to 2 examples, flags, and source link.

## Lifecycle

The six core workflow commands that move a task from creation through completion. See [agent-lifecycle.md](../workflows/agent-lifecycle.md) for the state machine.

### /task

Create a new task or manage existing ones. Use this as the entry point for any new piece of work, or to recover, expand, sync, or abandon tasks already in the pipeline.

```
/task "Add a dark-mode toggle to the settings page"
/task --review 5
```

**Flags**: `--recover N`, `--expand N`, `--sync`, `--abandon N`, `--review N`

See [`.claude/commands/task.md`](../../.claude/commands/task.md) · [user guide](../../.claude/docs/guides/user-guide.md#task-command).

### /research

Investigate a task and produce a research report, routing to the appropriate research agent based on task type. Use `--remember` to search the memory vault for prior relevant knowledge before researching.

```
/research 5
/research 5, 7-9 --remember
```

**Flags**: `[focus]`, `--team`, `--remember`, multi-task syntax (`5, 7-9`)

See [`.claude/commands/research.md`](../../.claude/commands/research.md) · [user guide](../../.claude/docs/guides/user-guide.md#research-command).

### /plan

Create a phased implementation plan from research findings. Supports multi-task syntax to plan several tasks in parallel, each with its own agent.

```
/plan 5
/plan 5, 7-9 --team
```

**Flags**: `--team`, multi-task syntax

**Note**: For `present` tasks with `slides` subtype, `/plan` routes to `skill-slide-planning` instead of the generic planner, running an interactive 5-stage design review (narrative arc, per-slide feedback, visual layout) before producing the slide plan.

See [`.claude/commands/plan.md`](../../.claude/commands/plan.md) · [user guide](../../.claude/docs/guides/user-guide.md#plan-command).

### /implement

Execute a plan phase-by-phase. Automatically detects the first incomplete phase and resumes there — re-running the same command after an interruption picks up where it left off.

```
/implement 5
/implement 5 --force
```

**Flags**: `--team`, `--force`, multi-task syntax

See [`.claude/commands/implement.md`](../../.claude/commands/implement.md) · [user guide](../../.claude/docs/guides/user-guide.md#implement-command).

### /revise

Create a new plan version, or update the task description if no plan exists. Works on tasks in any status — use it after a blocker is discovered or reviewer feedback arrives.

```
/revise 5
/revise 5 "address reviewer comments on error handling"
```

See [`.claude/commands/revise.md`](../../.claude/commands/revise.md) · [user guide](../../.claude/docs/guides/user-guide.md#revise-command).

### /todo

Archive completed and abandoned tasks, update CHANGE_LOG.md and ROADMAP.md, and trigger vault operations when task numbers exceed 1000. Run `--dry-run` first to preview what will be archived.

```
/todo
/todo --dry-run
```

See [`.claude/commands/todo.md`](../../.claude/commands/todo.md) · [user guide](../../.claude/docs/guides/user-guide.md#todo-command).

## Review & Recovery

Commands for auditing the codebase and recovering from blockers.

### /review

Analyze the codebase and produce a tier-grouped review report. Distinct from `/task --review N`, which inspects a specific task's plan phases for completion.

```
/review
/review --create-tasks
```

See [`.claude/commands/review.md`](../../.claude/commands/review.md) · [user guide](../../.claude/docs/guides/user-guide.md#review-command).

### /spawn

Research a blocker on a `[BLOCKED]` task, then spawn new unblocking tasks with a dependency graph. Spawned tasks start at `[RESEARCHED]` status, skipping the research phase.

```
/spawn 5 "openpyxl crashes on merged cells"
```

See [`.claude/commands/spawn.md`](../../.claude/commands/spawn.md).

### /errors

Read `specs/errors.json`, analyze recurring patterns, and automatically create fix-plan tasks. Intentionally non-interactive — designed for fast triage without confirmation prompts.

```
/errors
/errors --fix 12
```

See [`.claude/commands/errors.md`](../../.claude/commands/errors.md).

### /fix-it

Scan files for `FIX:`, `NOTE:`, `TODO:`, `QUESTION:` tags, then interactively select and group matches into tasks. Accepts multiple paths to widen the scan.

```
/fix-it src/
/fix-it src/ docs/ .claude/
```

See [`.claude/commands/fix-it.md`](../../.claude/commands/fix-it.md) · [example](../../.claude/docs/examples/fix-it-flow-example.md).

## System & Housekeeping

Process cleanup, system building, version tagging, and pull requests.

### /refresh

Terminate orphaned Claude Code processes and delete stale files from `~/.claude/`. Files modified within the last hour are never deleted regardless of threshold.

```
/refresh --dry-run
/refresh --force
```

See [`.claude/commands/refresh.md`](../../.claude/commands/refresh.md).

### /meta

Interactive system builder for `.claude/` architecture changes (commands, skills, agents). Always creates tasks for subsequent `/research` -> `/plan` -> `/implement` execution — never implements directly.

```
/meta
/meta --analyze
```

See [`.claude/commands/meta.md`](../../.claude/commands/meta.md).

### /tag

Create a semantic version tag. This is a user-only command and cannot be invoked by agents — no command file exists.

```
/tag --patch
/tag --minor
```

See [`.claude/CLAUDE.md`](../../.claude/CLAUDE.md) for the routing table.

### /merge

Create a GitHub PR or GitLab MR for the current branch, with automatic platform detection. Uses `--fill` internally to auto-populate title and body from commit history.

```
/merge
/merge --draft --reviewer jane
```

**Flags**: `--draft`, `--assignee U`, `--label L`, `--reviewer U`

See [`.claude/commands/merge.md`](../../.claude/commands/merge.md).

## Memory

### /learn

Add memories to the [`.memory/`](context-and-memory.md) vault using one of three operations: UPDATE (high overlap with existing memory), EXTEND (partial overlap), or CREATE (new topic). Deduplicates against existing memories and classifies automatically.

```
/learn "macOS permissions dialog appears the first time Claude edits Word while Word is open"
/learn --task 5
```

See [`.claude/commands/learn.md`](../../.claude/commands/learn.md) · [context-and-memory.md](context-and-memory.md).

## Documents

Document and spreadsheet manipulation commands. Require MCP tools; see [installation.md](../general/installation.md#install-mcp-tools).

### /convert

Convert between PDF, DOCX, and Markdown, with automatic format detection from the file extension. Requires the appropriate MCP tool to be configured for the target format.

```
/convert report.pdf
/convert draft.md
```

See [`.claude/commands/convert.md`](../../.claude/commands/convert.md) · [convert-documents workflow](../workflows/convert-documents.md).

### /table

Convert spreadsheets to LaTeX or Typst tables. Use `--sheet` to select a specific sheet from multi-sheet workbooks.

```
/table data.xlsx
/table budget.csv --format typst
```

**Flags**: `--format latex|typst`, `--sheet NAME`

See [`.claude/commands/table.md`](../../.claude/commands/table.md).

### /scrape

Extract PDF annotations, highlights, and comments into Markdown or JSON. Useful for collecting reviewer feedback or reading notes from annotated papers.

```
/scrape paper.pdf
/scrape paper.pdf --format json
```

**Flags**: `--format markdown|json`, `--types ...`

See [`.claude/commands/scrape.md`](../../.claude/commands/scrape.md).

### /edit

Edit DOCX files in-place with tracked changes via the SuperDoc MCP, or create new documents. XLSX editing is not yet available.

```
/edit report.docx "Fix the methodology section"
/edit --new memo.docx "Draft a Q2 budget review memo"
```

**Flags**: `--new`

See [`.claude/commands/edit.md`](../../.claude/commands/edit.md) · [edit-word-documents workflow](../workflows/edit-word-documents.md).

## Research & Grants

Commands for grant proposals, budgets, timelines, funding analysis, and research talks. The commands in this group — `/grant`, `/budget`, `/timeline`, `/funds`, and `/slides` — begin with interactive forcing questions that scope the task before any work starts. This pattern ensures the right parameters are locked in early (funder, budget type, talk mode, etc.) and avoids rework.

### /grant

Research, draft, and develop grant proposals through multiple modes: create a task, draft narrative sections, build a budget, or create a revision. Use `--fix-it` to scan a grant directory for outstanding FIX:/TODO: tags.

```
/grant "NIH R01 on community-level TB surveillance"
/grant 12 --draft "focus on aims"
```

**Flags**: `--draft [focus]`, `--budget [guidance]`, `--revise N "description"`, `--fix-it`

See [`.claude/commands/grant.md`](../../.claude/commands/grant.md).

### /budget

Generate a grant budget spreadsheet (.xlsx) with formulas and justifications. Creates a task at `[NOT STARTED]` — run `/research N` next to begin development. Accepts a file path as context input.

```
/budget "R01 5-year modular"
/budget ~/grants/r01-aims.md
```

**Flags**: `--quick [mode]`

See [`.claude/commands/budget.md`](../../.claude/commands/budget.md).

### /timeline

Build a research project timeline with milestones. Output is Typst format — run `typst compile` to produce a PDF.

```
/timeline "3-year cohort study with 6-month follow-up waves"
/timeline 12
```

See [`.claude/commands/timeline.md`](../../.claude/commands/timeline.md).

### /funds

Survey funding opportunities with eligibility, deadlines, and portfolio analysis across four analysis modes. Use `--quick` for a lightweight scan without forcing questions.

```
/funds "global health TB surveillance"
/funds --quick "infectious disease modeling"
```

**Flags**: `--quick [topic]`

See [`.claude/commands/funds.md`](../../.claude/commands/funds.md).

### /slides

Create a research talk task with three input modes: a description string, an existing task number, or a file path as primary source material. After forcing questions, presents a design confirmation before proceeding.

```
/slides "Conference talk on survival analysis methods"
/slides ~/papers/my-paper.pdf
```

Five talk modes: CONFERENCE, SEMINAR, DEFENSE, POSTER, JOURNAL_CLUB. PPTX-to-slide conversion has moved to `/convert --format beamer|polylux|touying`.

**Flags**: `--critic [path|prompt]` -- Run interactive slide critique with rubric evaluation on existing slide materials.

See [`.claude/commands/slides.md`](../../.claude/commands/slides.md).

## Epidemiology

### /epi

Create epidemiology study tasks with structured forcing questions that scope study design, data sources, and R analysis preferences before task creation. Accepts a description string, an existing task number, or a file path as study protocol input.

```
/epi "Cohort study of vaccine effectiveness in elderly populations"
/epi 12
```

Three input modes: description string (runs 10 forcing questions, creates task at `[NOT STARTED]`), task number (delegates to research), or file path (reads as study protocol, then scopes). Task types: `epi`, `epi:study`, `epidemiology`.

See [`.claude/commands/epi.md`](../../.claude/commands/epi.md) · [epidemiology workflow](../workflows/epidemiology-analysis.md).

## See also

- [agent-lifecycle.md](../workflows/agent-lifecycle.md) — State machine and the six lifecycle commands in narrative form
- [architecture.md](architecture.md) — How commands, skills, and agents fit together
- [user-guide.md](../../.claude/docs/guides/user-guide.md) — Comprehensive command reference with examples
- [`.claude/commands/`](../../.claude/commands/) — Individual command source files
