# Command Catalog

All 24 slash commands in this workspace, grouped by topic. The **Lifecycle** group covers the seven commands from [workflow.md](workflow.md); the other groups are specialty commands layered on top. For full command specifications, see [`.claude/docs/guides/user-guide.md`](../../.claude/docs/guides/user-guide.md) and the individual files in `.claude/commands/`.

Each entry is intentionally terse: one-sentence summary, minimal example, flag list, and link into `.claude/`. For examples and edge cases, follow the links.

## Lifecycle

The seven main-workflow commands. See [workflow.md](workflow.md) for the state machine.

### /task

Create and manage tasks.

```
/task "Add a dark-mode toggle to the settings page"
```

**Flags**: `--recover N`, `--expand N`, `--sync`, `--abandon N`, `--review N`

See [`.claude/commands/task.md`](../../.claude/commands/task.md) · [user guide](../../.claude/docs/guides/user-guide.md#task).

### /research

Investigate a task and produce a research report.

```
/research 5
```

**Flags**: `[focus]`, `--team`, `--remember`, multi-task syntax (`5, 7-9`)

See [`.claude/commands/research.md`](../../.claude/commands/research.md) · [user guide](../../.claude/docs/guides/user-guide.md#research).

### /plan

Create a phased implementation plan from research.

```
/plan 5
```

**Flags**: `--team`, multi-task syntax

See [`.claude/commands/plan.md`](../../.claude/commands/plan.md) · [user guide](../../.claude/docs/guides/user-guide.md#plan).

### /implement

Execute a plan phase-by-phase; resumable on interrupt.

```
/implement 5
```

**Flags**: `--team`, `--force`, multi-task syntax

See [`.claude/commands/implement.md`](../../.claude/commands/implement.md) · [user guide](../../.claude/docs/guides/user-guide.md#implement).

### /revise

Create a new plan version (or update task description if no plan exists).

```
/revise 5
```

See [`.claude/commands/revise.md`](../../.claude/commands/revise.md) · [user guide](../../.claude/docs/guides/user-guide.md#revise).

### /review

Analyze the codebase and produce a tier-grouped review report.

```
/review
/review --create-tasks
```

See [`.claude/commands/review.md`](../../.claude/commands/review.md) · [user guide](../../.claude/docs/guides/user-guide.md#review).

### /todo

Archive completed/abandoned tasks; update CHANGE_LOG and ROAD_MAP.

```
/todo
/todo --dry-run
```

See [`.claude/commands/todo.md`](../../.claude/commands/todo.md) · [user guide](../../.claude/docs/guides/user-guide.md#todo).

## Maintenance

Task recovery, error tracking, tag scanning, and cleanup.

### /spawn

Research a blocker on a `[BLOCKED]` task and spawn new unblocking tasks.

```
/spawn 5 "openpyxl crashes on merged cells"
```

See [`.claude/commands/spawn.md`](../../.claude/commands/spawn.md).

### /errors

Read `specs/errors.json`, analyze recurring patterns, create fix-plan tasks.

```
/errors
/errors --fix 12
```

See [`.claude/commands/errors.md`](../../.claude/commands/errors.md).

### /fix-it

Scan files for `FIX:`, `NOTE:`, `TODO:`, `QUESTION:` tags and interactively create tasks.

```
/fix-it src/
```

See [`.claude/commands/fix-it.md`](../../.claude/commands/fix-it.md) · [example](../../.claude/docs/examples/fix-it-flow-example.md).

### /refresh

Terminate orphaned Claude Code processes and delete stale files from `~/.claude/`.

```
/refresh --dry-run
/refresh --force
```

See [`.claude/commands/refresh.md`](../../.claude/commands/refresh.md).

### /meta

Interactive system builder for `.claude/` architecture changes (commands, skills, agents). **Never implements directly** — outputs tasks for subsequent `/research` -> `/plan` -> `/implement` execution.

```
/meta
/meta --analyze
```

See [`.claude/commands/meta.md`](../../.claude/commands/meta.md).

### /tag

Create a semantic version tag (user-only command; cannot be invoked by agents).

```
/tag --patch
/tag --minor
/tag --major
```

See [`.claude/commands/tag.md`](../../.claude/commands/tag.md).

### /merge

Create a GitHub PR or GitLab MR for the current branch.

```
/merge
/merge --draft --reviewer jane
```

**Flags**: `--draft`, `--assignee U`, `--label L`, `--reviewer U`

See [`.claude/commands/merge.md`](../../.claude/commands/merge.md).

## Memory

### /learn

Add memories to the [`.memory/`](context-and-memory.md) vault. Four modes: inline text, single file, directory scan, or task artifact review.

```
/learn "macOS permissions dialog appears the first time Claude edits Word while Word is open"
/learn ~/notes/debugging.md
/learn ~/papers/
/learn --task 5
```

Deduplicates against existing memories and classifies automatically. See [`.claude/commands/learn.md`](../../.claude/commands/learn.md) and [context-and-memory.md](context-and-memory.md) for the full two-layer memory model.

## Documents

Document and spreadsheet manipulation commands. Require MCP tools; see [../installation.md](../installation.md#install-mcp-tools).

### /convert

Convert between PDF, DOCX, and Markdown.

```
/convert report.pdf
/convert notes.docx
/convert draft.md
```

See [`.claude/commands/convert.md`](../../.claude/commands/convert.md) · [office workflows](../office-workflows.md).

### /table

Convert spreadsheets to LaTeX or Typst tables.

```
/table data.xlsx
/table budget.csv --format typst
```

**Flags**: `--format latex|typst`

See [`.claude/commands/table.md`](../../.claude/commands/table.md).

### /slides

Convert presentations to Beamer, Polylux, or Touying source.

```
/slides deck.pptx --format beamer
```

**Flags**: `--format beamer|polylux|touying`

See [`.claude/commands/slides.md`](../../.claude/commands/slides.md).

### /scrape

Extract PDF annotations, highlights, and comments.

```
/scrape paper.pdf
/scrape paper.pdf --format json
```

**Flags**: `--format markdown|json`, `--types ...`

See [`.claude/commands/scrape.md`](../../.claude/commands/scrape.md).

### /edit

In-place DOCX editing with tracked changes via the SuperDoc MCP. Supports batch edit over a directory and new-document creation.

```
/edit report.docx "Fix the methodology section"
/edit ~/Contracts/ "Replace 'ACME' with 'NewCo' using tracked changes"
/edit --new memo.docx "Draft a Q2 budget review memo"
```

**Flags**: `--new`

See [`.claude/commands/edit.md`](../../.claude/commands/edit.md) · [office workflows](../office-workflows.md).

## Research & Grants

Commands for grant proposals, budgets, timelines, funding analysis, and research talks.

### /grant

Grant proposal research, drafting, and budget development.

```
/grant "NIH R01 on community-level TB surveillance"
/grant 12 --draft "focus on aims"
/grant 12 --budget "5-year modular budget"
/grant --revise 12 "address reviewer comments"
```

See [`.claude/commands/grant.md`](../../.claude/commands/grant.md).

### /budget

Generate a grant budget spreadsheet (.xlsx) with formulas and justifications.

```
/budget "R01 5-year modular"
/budget 12
/budget --quick
```

**Flags**: `--quick [mode]`

See [`.claude/commands/budget.md`](../../.claude/commands/budget.md).

### /timeline

Build a research project timeline with milestones.

```
/timeline "3-year cohort study with 6-month follow-up waves"
/timeline 12
```

See [`.claude/commands/timeline.md`](../../.claude/commands/timeline.md).

### /funds

Survey funding opportunities with eligibility and deadlines.

```
/funds "global health TB surveillance"
/funds 12
/funds --quick "infectious disease modeling"
```

**Flags**: `--quick [topic]`

See [`.claude/commands/funds.md`](../../.claude/commands/funds.md).

### /talk

Build a research talk. Five modes:

```
/talk "job talk on epidemic modeling"
/talk 12
/talk ~/papers/my-paper.pdf
```

| Mode | Duration | Slides | Use case |
|------|----------|--------|----------|
| CONFERENCE | 15-20 min | 12-18 | Conference platform presentations |
| SEMINAR | 45-60 min | 30-45 | Departmental seminars, job talks |
| DEFENSE | 30-60 min | 25-40 | Grant defense, thesis defense |
| POSTER | N/A | 1 | Poster session presentations |
| JOURNAL_CLUB | 15-30 min | 10-15 | Paper review for journal club |

See [`.claude/commands/talk.md`](../../.claude/commands/talk.md).

## See also

- [workflow.md](workflow.md) — State machine and the seven lifecycle commands in narrative form
- [architecture.md](architecture.md) — How commands, skills, and agents fit together
- [`.claude/docs/guides/user-guide.md`](../../.claude/docs/guides/user-guide.md) — Comprehensive command reference with examples
- [`.claude/commands/`](../../.claude/commands/) — Individual command source files
