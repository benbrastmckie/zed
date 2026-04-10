# Teammate D: Horizons

**Task**: #9 - Populate docs/workflows/ with workflows for all .claude/commands/
**Angle**: Long-term alignment, strategic direction, creative/unconventional angles
**Started**: 2026-04-10T21:00:00Z

---

## Roadmap Alignment

No `specs/ROAD_MAP.md` exists in this repository. There is no formal roadmap to align against.

However, the project's trajectory is legible from state.json. The eight completed tasks form a clear arc:

1. Initial Zed configuration (keybindings, settings)
2. Documentation expansion: agent-system.md split into a full docs/agent-system/ directory
3. Installation guide macOS revision
4. Office workflow guide migrated into docs/workflows/ (task 8)
5. **Task 9** (this task): populating docs/workflows/ for all remaining commands

This is not coincidental. The project is systematically building a **layered documentation pyramid**:

- Layer 1 (done): Technical specs in `.claude/` (command files, agent files, rules)
- Layer 2 (done): Reference docs in `docs/agent-system/` (commands.md, architecture.md)
- Layer 3 (in progress): Narrative workflows in `docs/workflows/`

Task 9 completes Layer 3. This is the last major documentation gap visible from the current task list.

**Strategic implication**: Completing task 9 effectively closes the "documentation phase" of this project. The next natural phase would be either (a) content extensions (new commands, new extensions) or (b) automation/generation of docs. Task 9 could serve as the pivot point.

---

## Scalability Analysis (1-year horizon)

### Current inventory

- 24 commands in `.claude/commands/`
- 6 docs in `docs/workflows/` (only agent-lifecycle fully covers command workflows)
- `docs/agent-system/commands.md` covers all 24 in terse catalog form
- No ROAD_MAP.md, so no formal roadmap constraints

### Command growth projection

If this project follows typical Claude Code agent system patterns:
- Extensions add 2-5 commands each (epidemiology, latex, typst, present, memory, filetypes already loaded)
- A conservative estimate: 30-50 commands within 12 months
- An aggressive estimate (new extensions): 60-80 commands

### The scaling problem with 1:1 workflow-per-command

At current pace (1 workflow doc per command group), the docs/workflows/ directory would grow to 10-15 files at 50 commands — still manageable. The **real problem is maintenance**:

- Each command is documented in THREE places: `.claude/commands/*.md`, `docs/agent-system/commands.md`, and `docs/workflows/*.md`
- When a command changes (new flag, new mode), all three must be updated
- Currently there is no automation or source-of-truth enforcement

**At 50 commands, triple-maintenance becomes a real tax on system evolution.**

### The sustainable architecture

The most scalable architecture separates stable narrative from volatile detail:

- **docs/workflows/** = "Why and when" (narrative, rarely changes)
- **docs/agent-system/commands.md** = "What exists" (catalog, changes when commands are added/removed)
- **.claude/commands/*.md** = "How exactly" (authoritative spec, changes when behavior changes)

This means docs/workflows/ should NOT attempt to document every flag and mode. It should document **user journeys and decision points** — content that is stable across minor command changes.

**Specific recommendation**: Workflow docs should be written at the "when would I use this?" level, not the "what flags does it accept?" level. Flags belong in commands.md.

---

## Creative/Unconventional Angles

### 1. User-journey clustering (vs. command-group clustering)

The current docs/workflows/ README groups by document type (office, agent-system). An alternative is clustering by **what the user is trying to accomplish**:

- **"I want to track a development task"** → task + research + plan + implement + todo
- **"I want to fix a problem I noticed"** → fix-it + errors + spawn + review
- **"I want to write a grant"** → grant + budget + timeline + funds
- **"I want to give a talk"** → talk + (convert for slides)
- **"I want to work with documents"** → edit + convert + table + slides + scrape
- **"I want to maintain my system"** → refresh + meta + tag + merge + learn

These journeys are **more intuitive for new users** than command groupings, because users think about goals, not tool categories. The 24 commands map cleanly onto 6 user journeys.

This approach also scales well: a new command either fits an existing journey or warrants a new journey file — both are obvious editorial decisions.

### 2. Documentation as code (auto-generation from frontmatter)

Every `.claude/commands/*.md` file has YAML frontmatter:

```yaml
description: Grant budget spreadsheet generation with forcing questions and task integration
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(date:*), Read, Edit, AskUserQuestion
argument-hint: "[description]" | TASK_NUMBER | /path/to/file.md | --quick [mode]
model: opus
```

This frontmatter is **sufficient to auto-generate** the terse catalog rows in `commands.md`. A script or Claude Code task could:
1. Read all `argument-hint` values
2. Read all `description` values
3. Reconstruct the commands.md table automatically

This would eliminate one maintenance surface and ensure commands.md is always accurate. The workflows docs would remain handwritten (they contain narrative and judgment), but the catalog would be generated.

### 3. Mermaid flowcharts for complex commands

Some commands have multi-mode behavior that prose explains poorly. Examples:

- `/grant` has 5 modes (task creation, draft, budget, fix-it, revise)
- `/task` has 6 submodes (create, recover, expand, sync, abandon, review)
- `/implement` has a complex resume-from-phase behavior

A Mermaid flowchart showing decision trees would be more scannable than prose for these commands. Example for `/grant`:

```mermaid
flowchart TD
    A[/grant ...] --> B{argument shape?}
    B -->|"description string"| C[Task Creation mode]
    B -->|"N --draft"| D[Draft narrative]
    B -->|"N --budget"| E[Budget development]
    B -->|"N --fix-it"| F[Tag scan]
    B -->|"--revise N"| G[Revision task]
```

Zed's markdown preview renders Mermaid natively, making this immediately useful without tooling.

### 4. Machine-readable workflow docs (dual-purpose)

If workflow docs include structured YAML frontmatter (similar to command files), they could be indexed and loaded by Claude Code agents as context. For example:

```yaml
---
commands: [grant, budget, timeline, funds, talk]
journey: research-grants
triggers: ["grant proposal", "R01", "NIH", "funding"]
---
```

The context index (`index.json`) could then route agents to the relevant workflow doc when the user's task description contains trigger terms. This converts workflow docs from **human reference** into **agent routing context** — a genuine dual-purpose without extra maintenance.

---

## Dual-Purpose Opportunities

### Workflow docs as agent context

The most compelling dual-purpose opportunity: workflow docs loaded into the context index as "when the user asks about X, load this workflow" guidance.

Current `index.json` routing is command-centric (load context when agent is `general-research-agent`, or task type is `grant`). Workflow docs could extend this with **intent-centric routing**: when the user's task description matches "I want to track a development task," load agent-lifecycle.md as context.

This would make workflow docs actively useful during task execution, not just for human readers.

### The "commands.md duplication" problem

`docs/agent-system/commands.md` already provides a terse command catalog. `docs/workflows/` provides narrative. There is a risk of creating a third documentation surface that duplicates both.

The clean boundary:
- `commands.md` = what commands exist and what flags they accept (generated from frontmatter ideally)
- `workflows/` = when to use which commands and in what order (judgment and narrative)

If this boundary is maintained, workflow docs can link to commands.md for flag details rather than re-documenting them, keeping each doc focused and non-redundant.

### Workflow docs as onboarding

New users of this Zed config don't know which commands exist or how they relate. A "Start here" workflow doc structured as a decision tree ("What do you want to do?") would serve onboarding better than either commands.md or agent-lifecycle.md.

This "decision guide" already exists in a rudimentary form in docs/workflows/README.md but could be expanded significantly.

---

## Follow-up Task Opportunities

Researching this task reveals several natural follow-up improvements:

### 1. Command documentation gaps (high value, low effort)

Several commands have minimal documentation in their `.claude/commands/*.md` files. Candidates:

- `learn.md` — No YAML frontmatter `allowed-tools`, `argument-hint`, or `model` fields. Body is structured around XML tags (`<argument_parsing>`) rather than the standard prose format used by other commands.
- `merge.md` — Well-documented, but the flags table body is empty (missing `Default` column values). Minor but creates an incomplete reference.
- `tag.md` — Referenced in CLAUDE.md routing table but appears to not exist as a standalone command file in `.claude/commands/`. If it does not exist, it cannot be properly documented.

### 2. Auto-generation script for commands.md catalog

A single-task meta improvement: write a Bash script or Claude task that reads `description` and `argument-hint` frontmatter from all `.claude/commands/*.md` files and regenerates the commands.md table rows. Would eliminate a maintenance surface when commands are added.

### 3. Context index entries for workflow docs

After workflow docs are written, a follow-up task could add each to `.claude/context/index.json` with appropriate `load_when` triggers, making them available as agent context during relevant task types.

### 4. "Start here" onboarding workflow

A `getting-started.md` in `docs/workflows/` aimed at new users who have never used Claude Code before. Would complement agent-lifecycle.md (which assumes familiarity with the concept) with a more guided, decision-tree format.

---

## Confidence: high

The trajectory analysis is based on directly observed state.json data (8 completed tasks). The scalability analysis rests on counts and file structure that are directly verifiable. Creative angles are clearly labeled as proposals, not findings.

The main uncertainty: whether the project owner prioritizes handwritten narrative docs vs. generated/structured docs. Both are defensible; the answer shapes whether Mermaid diagrams and frontmatter-based generation are worthwhile investments.
