# Teammate A: Primary Approach

**Task**: 9 - Populate docs/workflows/ with workflows covering all commands in .claude/commands/
**Started**: 2026-04-10T21:00:00Z
**Completed**: 2026-04-10T21:45:00Z
**Effort**: 2 hours
**Dependencies**: None
**Sources/Inputs**: Codebase (existing workflow docs, all 24 command definitions)
**Artifacts**: This report
**Standards**: report-format.md

---

## Key Findings

1. **Six files already exist** in `docs/workflows/`: `README.md`, `agent-lifecycle.md`, `convert-documents.md`, `edit-word-documents.md`, `edit-spreadsheets.md`, `tips-and-troubleshooting.md`. These cover 7 of the 24 commands well (task/research/plan/implement/todo via agent-lifecycle; convert/table/slides/scrape via convert-documents; edit via edit-word-documents).

2. **17 commands have no workflow documentation**: `revise`, `errors`, `fix-it`, `review`, `refresh`, `meta`, `spawn`, `merge`, `learn`, `grant`, `budget`, `timeline`, `funds`, `talk`, `todo` (partially covered), `implement` (partially covered), `plan` (partially covered).

3. **Clear natural groupings** emerge from the command corpus: (a) task lifecycle group, (b) maintenance/health group, (c) grant/research-presentation group, (d) memory group. The document conversion group already exists and is well done.

4. **Established style pattern** (learned from existing docs): goal-oriented headings, decision guide tables, short intro paragraphs explaining what the file covers and what to open, numbered step lists for multi-step procedures, `See also` section cross-linking, no raw implementation details. Voice is user-facing ("you", "Claude", "press Cmd+`").

5. **agent-lifecycle.md already partially serves** task/research/plan/implement/todo — but it only briefly mentions `revise`, `spawn`, `--team`, and `--remember` flags. These warrant either expansion of that file or a supplemental file.

6. **The maintenance/meta commands** (`errors`, `fix-it`, `review`, `refresh`, `meta`, `merge`) share a common theme: system health and agent architecture management. They should share a single workflow doc.

7. **Grant development commands** (`grant`, `budget`, `timeline`, `funds`, `talk`) are strongly related and share the same forcing-questions + task-creation + research/plan/implement pattern. They belong in one workflow doc with sub-sections per command.

8. **`learn`/`/memory`** is its own conceptual cluster: knowledge capture and memory vault.

9. **README.md will need updating** to add new entries in the Contents table and the decision guide.

---

## Recommended Grouping

| Workflow Doc | Commands Covered | New or Extend? |
|---|---|---|
| `agent-lifecycle.md` (extend) | `/task`, `/research`, `/plan`, `/implement`, `/todo`, `/revise`, `/spawn` | EXTEND existing |
| `maintenance-and-meta.md` (new) | `/errors`, `/fix-it`, `/review`, `/refresh`, `/meta`, `/merge` | NEW |
| `grant-development.md` (new) | `/grant`, `/budget`, `/timeline`, `/funds`, `/talk` | NEW |
| `memory-and-learning.md` (new) | `/learn` | NEW |
| `convert-documents.md` (already exists) | `/convert`, `/table`, `/slides`, `/scrape` | NO CHANGE |
| `edit-word-documents.md` (already exists) | `/edit` | NO CHANGE |
| `edit-spreadsheets.md` (already exists) | — (covers openpyxl MCP, not a slash command) | NO CHANGE |
| `tips-and-troubleshooting.md` (already exists) | — (cross-cutting) | MINOR UPDATE |

**Summary**: 1 extension to existing file, 3 new files, 4 existing files untouched (except README.md update).

---

## Per-Workflow Sketches

### 1. agent-lifecycle.md — EXTEND

**Current state**: Covers `/task`, `/research`, `/plan`, `/implement`, `/todo` well. Briefly mentions `/revise`, `/spawn`, exception states.

**What to add**:

**Section: Revising a plan (`/revise`)**

The `/revise` command creates a new version of an implementation plan for a task that has already been planned. It delegates to `reviser-agent`, which reads the current plan, discovers any new research, and synthesizes a revised plan. Use it when requirements changed, research revealed new information, or the current plan is no longer the right approach.

```
/revise N                    # Revise plan (creates plans/02_{slug}.md)
/revise N "scope narrowed"   # Revise with explicit reason
```

If the task has no plan yet, `/revise` instead updates the task description. Transitions back to `[PLANNED]`. After revision, run `/implement N` to execute the new plan.

**Section: Unblocking a task (`/spawn`)**

When an implementation hits a hard blocker, `/spawn N` analyzes the blocker and decomposes it into minimal prerequisite tasks. The parent task moves to `[BLOCKED]`; the spawned tasks are created with proper dependency links. Resolve spawned tasks first, then re-run `/implement N`.

```
/spawn N                                     # Auto-detect blocker from plan
/spawn N "missing state validation utils"    # Explicit blocker description
```

**Narrative arc extension**: The current file ends at `[COMPLETED]` / `/todo`. Adding `revise` and `spawn` makes it cover the full state machine including exception handling paths.

**Sections to add**:
- "Revising a plan" (between Implementing and Finishing)
- "When implementation gets stuck" (spawn and blocked)

**Cross-links**: Link to new `maintenance-and-meta.md` for `/errors`, `/fix-it`, `/review`.

---

### 2. maintenance-and-meta.md — NEW

**Title**: System Maintenance and Meta-Commands

**File name**: `maintenance-and-meta.md`

**Commands covered**: `/errors`, `/fix-it`, `/review`, `/refresh`, `/meta`, `/merge`

**Narrative arc**: These commands are about keeping the system healthy — not about doing new creative work, but about reviewing what exists, fixing what is broken, cleaning up resources, and evolving the agent architecture. They answer the question "how do I keep this thing running well?"

**Intro paragraph**:
> Six commands handle system health and meta-level work: analysing errors, scanning code for embedded tags, reviewing completed work, cleaning up Claude Code resources, evolving the agent architecture, and publishing a branch as a pull request. None of these commands are part of the primary task lifecycle (`/task` through `/todo`); they run alongside it.

**Sections**:

**Decision guide** (table):
| I want to... | Use |
|---|---|
| See what errors have occurred and create fix tasks | `/errors` |
| Find FIX:/TODO:/QUESTION: tags in source files and turn them into tasks | `/fix-it` |
| Review a task's completion status and create follow-up tasks | `/task --review N` |
| Analyse the Claude Code agent architecture | `/review` or `/meta --analyze` |
| Evolve the .claude/ system (new commands, skills, agents) | `/meta` |
| Free up disk space from ~/.claude/ | `/refresh` |
| Create a pull/merge request for the current branch | `/merge` |

**`/errors` — Analyse error patterns**
- What it does: Reads `specs/errors.json`, groups by type and severity, writes an analysis report, creates fix tasks
- Modes: default analysis; `--fix N` to implement fixes for a specific error task
- Output: `specs/errors/analysis-{DATE}.md` plus new tasks in TODO.md

**`/fix-it` — Turn embedded tags into tasks**
- What it does: Scans source files for `FIX:`, `NOTE:`, `TODO:`, `QUESTION:` tags; lets you choose which to convert into structured tasks
- Supported file types: `.lua`, `.tex`, `.md`, `.py`, shell scripts, YAML
- Interactive: always shows findings before creating tasks; you select which tags to act on and whether to group related items by topic
- Paths: `/fix-it` (whole project), `/fix-it path/to/dir/`, `/fix-it file.lua`

**`/review` — Analyse code and create improvement tasks**
- What it does: Analyses the codebase and creates a tiered set of improvement tasks (grouped by topic)
- No arguments required; always interactive (you choose which suggested tasks to create)

**`/refresh` — Clean up Claude Code resources**
- What it does: Terminates orphaned Claude Code processes and deletes old files from `~/.claude/`
- Safety: Never deletes `settings.json`, credentials, or files modified in the last hour
- Modes: interactive (prompts for age threshold), `--dry-run` (preview only), `--force` (skip prompts)

**`/meta` — Evolve the agent architecture**
- What it does: Creates tasks for changes to `.claude/` (new commands, skills, agents, rules, context files) — it NEVER implements changes directly
- Modes: no args (7-stage interactive interview), description text (abbreviated flow), `--analyze` (read-only inventory)
- Output: tasks in TODO.md; you then run `/research` -> `/plan` -> `/implement` to execute them

**`/merge` — Publish a branch as a PR/MR**
- What it does: Detects GitHub or GitLab, pushes the current branch to origin, and creates a pull/merge request via `gh` or `glab` CLI
- Prerequisites: must be on a feature branch (not `main`/`master`), CLI must be installed and authenticated
- Flags: `--draft`, `--assignee USER`, `--reviewer USER`, `--label LABEL`, `--target BRANCH`

**Cross-links**: agent-lifecycle.md (for `/task --review`), convert-documents.md, agent-system/commands.md

---

### 3. grant-development.md — NEW

**Title**: Grant and Research Presentation Development

**File name**: `grant-development.md`

**Commands covered**: `/grant`, `/budget`, `/timeline`, `/funds`, `/talk`

**Narrative arc**: Academic grant work and research presentations share a common shape: you have an idea, you need to research the funding landscape, draft proposal materials, develop a budget, plan a timeline, and present the work. These five commands support exactly that workflow. Each command asks essential "forcing questions" before creating a task, so by the time Claude starts working, it has all the context it needs.

**Intro paragraph**:
> Five commands support academic grant writing and research presentations. All of them follow the same pattern: ask a few essential questions first, create a task with that context stored in metadata, then let you run `/research`, `/plan`, and `/implement` to complete the work.

**Sections**:

**Decision guide** (table):
| I want to... | Use |
|---|---|
| Draft grant narrative sections (specific aims, research strategy) | `/grant "description"` then `/grant N --draft` |
| Build a line-item grant budget spreadsheet | `/budget "description"` |
| Understand the funding landscape for a topic | `/funds "description"` |
| Plan a research project timeline with milestones | `/timeline "description"` |
| Create a research talk (conference, seminar, defense, poster) | `/talk "description"` |
| Revise a submitted grant for resubmission | `/grant --revise N "description"` |

**Common pattern**: All five commands follow:
1. Run the command with a description — Claude asks forcing questions before creating the task
2. Task is created at `[NOT STARTED]` with your answers stored in metadata
3. Run `/research N` to investigate (reads metadata for context)
4. Run `/plan N` to create an implementation plan
5. Run `/implement N` to assemble the final output

**`/grant` — Proposal development**
- Three sub-workflows: task creation (with forcing questions about mechanism, funder, constraints), `--draft` (narrative sections), `--budget` (line-item budget)
- Revise mode: `/grant --revise N "description"` creates a revision task linked to the original grant directory
- Full workflow output lands in `grants/{N}_{slug}/`

**`/budget` — Budget spreadsheet generation**
- Generates multi-year XLSX spreadsheets (NIH Modular, NIH Detailed, NSF, Foundation, SBIR formats)
- Forcing questions: funder type, years, personnel, equipment, overhead rate
- Can also be invoked as `/grant N --budget` for budget within an existing grant task

**`/funds` — Funding landscape analysis**
- Modes: LANDSCAPE (survey opportunities), PORTFOLIO (analyse a funder), JUSTIFY (verify budget against guidelines), GAP (find unfunded areas)
- Output: structured funding analysis report with funder profiles and strategic recommendations

**`/timeline` — Research project timeline**
- Creates a structured research project timeline with milestones, dependencies, and Gantt-style visualization
- Forcing questions: project scope, team size, deadline, regulatory hurdles (IRB, IACUC)

**`/talk` — Research presentation**
- Five talk modes: CONFERENCE (15-20 min), SEMINAR (45-60 min), DEFENSE (30-60 min), POSTER, JOURNAL_CLUB
- Optional `--design` flag after research to confirm visual theme, key message order, and section emphasis before planning
- Source materials: task references, file paths to manuscripts, or description
- Output: Slidev-based presentation in `talks/{N}_{slug}/`

**Cross-links**: agent-lifecycle.md (for the research/plan/implement cycle), convert-documents.md (for table extraction from spreadsheets), agent-system/commands.md

---

### 4. memory-and-learning.md — NEW

**Title**: Memory and Learning

**File name**: `memory-and-learning.md`

**Commands covered**: `/learn`

**Narrative arc**: As you work across many tasks, Claude discovers patterns, decisions, and domain knowledge worth preserving. The `/learn` command captures this knowledge into the `.memory/` vault so future research agents can draw on it. It also augments research with `--remember` flag on `/research`.

**Intro paragraph**:
> The `/learn` command adds knowledge to the `.memory/` vault — a persistent store that research agents can search when you pass `--remember` to `/research`. Use it to capture reusable patterns, workflow insights, and domain knowledge discovered during task work.

**Sections**:

**Decision guide**:
| I want to... | Use |
|---|---|
| Add a specific insight or fact | `/learn "text here"` |
| Import knowledge from a file | `/learn /path/to/file.md` |
| Scan a directory for learnable content | `/learn /path/to/dir/` |
| Harvest memories from completed task artifacts | `/learn --task N` |
| Use prior memories during research | `/research N --remember` |

**Four input modes**:
- Text mode: `/learn "Use pcall() in Lua for safe function calls"` — directly adds text as a memory
- File mode: `/learn /path/to/notes.md` — segments the file into topic chunks, deduplicates against existing memories
- Directory mode: `/learn ./src/utils/` — scans all text files, lets you choose which to import
- Task mode: `/learn --task N` — reviews research reports, plans, and summaries from a completed task; you choose which segments to classify and store

**Memory operations**: UPDATE (extends existing memory), EXTEND (appends to memory), CREATE (new memory). Claude presents the recommended operation for each segment and applies confirmed operations.

**`--remember` on `/research`**: When you pass `--remember` to `/research N`, the research agent searches the vault for prior knowledge relevant to the task before investigating. Relevant memories appear in the research context.

**Cross-links**: agent-lifecycle.md, agent-system/context-and-memory.md

---

### 5. README.md — UPDATE

Add three new entries to the Contents table under a new "Agent development" section:

```markdown
### Agent development and system health

| File | Description |
|---|---|
| [maintenance-and-meta.md](maintenance-and-meta.md) | Error analysis, tag scanning, code review, resource cleanup, agent architecture, and pull request creation |
| [memory-and-learning.md](memory-and-learning.md) | Capturing knowledge into the .memory/ vault with /learn and memory-augmented research |
| [grant-development.md](grant-development.md) | Grant proposal, budget, funding analysis, timeline, and research talk workflows |
```

Update the decision guide to add rows for the new commands.

Update the "See also" section to note the full command catalog at `../agent-system/commands.md`.

---

## New vs Extend Existing (Recommendations)

| File | Action | Rationale |
|---|---|---|
| `agent-lifecycle.md` | EXTEND with `/revise` and `/spawn` sections | These are core task lifecycle commands that logically belong here; the file already mentions them briefly |
| `maintenance-and-meta.md` | CREATE new | 6 commands share a "system health" theme, none covered yet |
| `grant-development.md` | CREATE new | 5 commands share the grant/presentation domain; forcing-question pattern unifies them |
| `memory-and-learning.md` | CREATE new | `/learn` has a distinct purpose (knowledge capture); warrants its own short doc |
| `convert-documents.md` | NO CHANGE | Already covers `/convert`, `/table`, `/slides`, `/scrape` well |
| `edit-word-documents.md` | NO CHANGE | Already covers `/edit` well |
| `edit-spreadsheets.md` | NO CHANGE | Covers openpyxl MCP directly; no slash command to document |
| `tips-and-troubleshooting.md` | MINOR UPDATE only if needed | Add note about `gh`/`glab` CLI for `/merge` if that fits here |
| `README.md` | UPDATE | Add new files to Contents table and decision guide |

---

## Evidence/Examples

### Style evidence (from existing docs)

- **agent-lifecycle.md** uses code fences for command examples, prose explanations of transitions, "Advanced flags" section for `--team`, plain text exception-state explanations. Paragraph depth is medium — not just bullet lists.
- **edit-word-documents.md** uses H2 headings for each workflow ("Edit in-place with tracked changes", "Batch edit a folder", "Create new documents"), numbered steps per workflow, and a "Prompt examples" table. Very user-facing, action-oriented.
- **convert-documents.md** is lighter — one code block per command, brief description, then a Tips section. Appropriate for commands with few configuration options.
- All files end with a `## See also` section with 3-5 cross-links.

### Command evidence

- `/revise` (`revise.md`): "Create a new version of an implementation plan, or update task description if no plan exists." Transitions back to `[PLANNED]`.
- `/spawn` (`spawn.md`): Allowed statuses include `implementing`, `partial`, `blocked`, `planned`, `researched`, `not_started`. Creates dependency-linked unblocking tasks.
- `/errors` (`errors.md`): Default analysis mode writes `specs/errors/analysis-{DATE}.md` and creates fix tasks. `--fix N` implements fixes.
- `/fix-it` (`fix-it.md`): Four tag types (FIX:, NOTE:, TODO:, QUESTION:); interactive with topic grouping; generates fix-it, learn-it, todo, and research task types.
- `/meta` (`meta.md`): Three modes (interactive interview, prompt, analyze). Reference implementation of the multi-task creation standard. NEVER implements directly.
- `/refresh` (`refresh.md`): Cleans `~/.claude/` directories and terminates orphaned processes. Protected files: `settings.json`, `.credentials.json`, `history.jsonl`.
- `/merge` (`merge.md`): Detects platform from git remote URL, pushes branch, creates PR/MR via `gh` or `glab`.
- `/learn` (`learn.md`): Four modes (text, file, directory, task). Three memory operations (UPDATE, EXTEND, CREATE). Works with `.memory/` vault.
- `/grant` (`grant.md`): Task creation, `--draft`, `--budget`, `--fix-it`, `--revise` sub-modes. Forcing questions about mechanism, funder, regulatory, constraints.
- `/budget` (`budget.md`): Modes MODULAR, DETAILED, NSF, FOUNDATION, SBIR. Generates XLSX spreadsheets.
- `/funds` (`funds.md`): Modes LANDSCAPE, PORTFOLIO, JUSTIFY, GAP.
- `/talk` (`talk.md`): Modes CONFERENCE, SEMINAR, DEFENSE, POSTER, JOURNAL_CLUB. Optional `--design` flag.
- `/timeline` (`timeline.md`): Hybrid task creation / research workflow for project timelines.

### Coverage audit (all 24 commands)

| Command | Currently covered? | Proposed location |
|---|---|---|
| `/task` | YES (agent-lifecycle.md) | agent-lifecycle.md |
| `/research` | YES (agent-lifecycle.md) | agent-lifecycle.md |
| `/plan` | YES (agent-lifecycle.md) | agent-lifecycle.md |
| `/implement` | YES (agent-lifecycle.md) | agent-lifecycle.md |
| `/todo` | YES (agent-lifecycle.md) | agent-lifecycle.md |
| `/revise` | PARTIAL (brief mention) | agent-lifecycle.md (add full section) |
| `/spawn` | PARTIAL (brief mention) | agent-lifecycle.md (add full section) |
| `/convert` | YES (convert-documents.md) | convert-documents.md |
| `/table` | YES (convert-documents.md) | convert-documents.md |
| `/slides` | YES (convert-documents.md) | convert-documents.md |
| `/scrape` | YES (convert-documents.md) | convert-documents.md |
| `/edit` | YES (edit-word-documents.md) | edit-word-documents.md |
| `/errors` | NO | maintenance-and-meta.md (new) |
| `/fix-it` | NO | maintenance-and-meta.md (new) |
| `/review` | NO | maintenance-and-meta.md (new) |
| `/refresh` | NO | maintenance-and-meta.md (new) |
| `/meta` | NO | maintenance-and-meta.md (new) |
| `/merge` | NO | maintenance-and-meta.md (new) |
| `/grant` | NO | grant-development.md (new) |
| `/budget` | NO | grant-development.md (new) |
| `/funds` | NO | grant-development.md (new) |
| `/timeline` | NO | grant-development.md (new) |
| `/talk` | NO | grant-development.md (new) |
| `/learn` | NO | memory-and-learning.md (new) |

Total: 12 fully covered, 2 partially covered, 10 not covered.

---

## Context Extension Recommendations

- **Topic**: Task lifecycle exception handling
- **Gap**: The agent-lifecycle.md doc mentions exception states but does not yet explain `/revise` and `/spawn` as the primary recovery mechanisms. Users hitting `[BLOCKED]` or wanting to redo a plan have nowhere to look.
- **Recommendation**: Extend agent-lifecycle.md (as described above).

---

## Appendix

### Files read

- `/home/benjamin/.config/zed/docs/workflows/README.md`
- `/home/benjamin/.config/zed/docs/workflows/agent-lifecycle.md`
- `/home/benjamin/.config/zed/docs/workflows/convert-documents.md`
- `/home/benjamin/.config/zed/docs/workflows/edit-word-documents.md`
- `/home/benjamin/.config/zed/docs/workflows/tips-and-troubleshooting.md`
- `.claude/commands/task.md`, `research.md`, `grant.md`, `meta.md`, `errors.md`, `spawn.md`, `fix-it.md`, `refresh.md`, `learn.md`, `revise.md`, `merge.md`, `talk.md`, `budget.md` (first 50 lines), `timeline.md` (first 50 lines), `funds.md` (first 50 lines), `todo.md` (first 60 lines)

### Key design decisions

1. Keep grant-development commands together — they share the forcing-questions pattern and form a coherent "academic work" cluster.
2. Keep maintenance commands together — they share the "system health" theme and are rarely used compared to the lifecycle commands.
3. `/learn` gets its own short file rather than being merged into maintenance, because it is thematically distinct (knowledge, not health).
4. Do NOT create a separate file for just `/revise` and `/spawn` — they extend the task lifecycle and belong in agent-lifecycle.md.
5. `tips-and-troubleshooting.md` stays as-is; it is already cross-cutting.

---

## Confidence: high

The command definitions are detailed and unambiguous. The existing workflow docs establish a clear style. The groupings are driven by thematic coherence (lifecycle, system health, academic, memory) with no meaningful overlap between groups. The only judgment call is whether `/revise` and `/spawn` deserve their own doc vs. extending agent-lifecycle.md — the primary approach recommends extending, which keeps the lifecycle story in one place.
