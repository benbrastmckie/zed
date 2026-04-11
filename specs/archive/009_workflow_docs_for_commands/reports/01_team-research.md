# Research Report: Task #9 — Populate docs/workflows/ with command workflow guides

**Task**: 9
**Date**: 2026-04-10
**Mode**: Team Research (4 teammates)
**Session**: sess_1775854733_93c456

---

## Summary

`docs/workflows/` currently covers 12 of 24 commands via `agent-lifecycle.md` (7 lifecycle
commands) and `convert-documents.md` + `edit-word-documents.md` (5 document commands). Two
thematic clusters and one single-command cluster are genuinely undocumented in workflow form:
maintenance/meta (`/errors`, `/fix-it`, `/review`, `/refresh`, `/meta`, `/merge`), grant
development (`/grant`, `/budget`, `/timeline`, `/funds`, `/talk`), and memory (`/learn`). In
addition, `/revise` and `/spawn` are referenced but not fully explained in `agent-lifecycle.md`.

The recommended approach: **extend `agent-lifecycle.md`** with dedicated sections for `/revise`
and `/spawn`, and **create three new files** — `maintenance-and-meta.md`, `grant-development.md`,
`memory-and-learning.md` — then update `README.md` to register them and add decision-guide
rows. New files follow the gold-standard pattern set by `convert-documents.md`: decision-guide
table at top, per-command scenario-driven sections, minimal examples, `See also` cross-links,
and explicit deference to `docs/agent-system/commands.md` for flag-level reference.

The critic raised valid concerns about depth, duplication, and maintenance that the plan must
address explicitly. The horizons teammate identified this task as the likely closing move of a
three-layer documentation pyramid (specs -> reference -> narrative) and flagged a user-journey
organization as a viable alternative grouping.

---

## Key Findings

### Current coverage (from Teammates A and B)

| Status | Count | Commands |
|--------|-------|----------|
| Fully covered in workflows/ | 12 | `/task`, `/research`, `/plan`, `/implement`, `/todo`, `/convert`, `/table`, `/slides`, `/scrape`, `/edit`, plus 2 partial |
| Referenced but not explained | 2 | `/revise`, `/spawn` (agent-lifecycle.md mentions them in passing) |
| Not covered at all | 10 | `/errors`, `/fix-it`, `/review`, `/refresh`, `/meta`, `/merge`, `/grant`, `/budget`, `/timeline`, `/funds`, `/talk`, `/learn` |

Note: `/tag` is user-only (agents cannot invoke it) and extremely simple (`/tag --patch`).
Teammate B recommends documenting it briefly inside `maintenance-and-meta.md` under merge/tag.

### Style pattern established by existing docs (from Teammates A and B)

- Goal-oriented headings ("Creating a task", "Resuming after a break")
- Decision-guide table at top mapping "I want to..." to command
- Per-command sections with a 1-2 sentence description, a minimal example block,
  and a "When to use" hint
- Short, user-facing voice: "you", "Claude", macOS keybindings (`Cmd+\``)
- `See also` section at the end cross-linking sibling workflow docs and
  `docs/agent-system/commands.md`
- Workflow docs explicitly defer flag-level reference to `commands.md`

### Primary approach (Teammate A, high confidence)

**Three new files + one extension**:

| Workflow Doc | Commands Covered | New / Extend |
|--------------|------------------|--------------|
| `agent-lifecycle.md` | add `/revise`, `/spawn` sections | extend |
| `maintenance-and-meta.md` | `/errors`, `/fix-it`, `/review`, `/refresh`, `/meta`, `/merge`, `/tag` | new |
| `grant-development.md` | `/grant`, `/budget`, `/timeline`, `/funds`, `/talk` | new |
| `memory-and-learning.md` | `/learn` (+ `--remember` on `/research`) | new |
| `README.md` | update Contents + decision guide rows | update |

Narrative arcs for the new files:

- **maintenance-and-meta.md** — "You noticed something off in the codebase or the agent system.
  Here is how to investigate, clean up, and ship the fix." Covers review → errors/fix-it scans
  → meta-level system changes → refresh → merge/tag.
- **grant-development.md** — "You are developing a research proposal or talk." Covers the
  forcing-questions pattern, task creation, /research + /plan + /implement loop as applied to
  grant/budget/timeline/funds/talk artifacts.
- **memory-and-learning.md** — "You want Claude to remember something across sessions, or draw
  on prior learnings." Covers `/learn` modes (text, file, directory, task) and the `--remember`
  flag on `/research`.

### Alternative framings worth considering (Teammate B, medium confidence)

Two alternative grouping schemes were explored:

- **By output artifact**: task artifacts / codebase intelligence / memory / documents /
  research outputs / infrastructure. Natural for "I want to produce X" thinking but creates a
  heterogeneous infrastructure bucket and splits lifecycle commands awkwardly.
- **By user role/intent**: developer / quality reviewer / admin / academic / document user /
  knowledge builder. Scannable but role boundaries are fuzzy and it breaks from the existing
  file style.

Teammate B recommends the primary approach (command-cluster grouping) as the best fit for
existing conventions but suggests the "I want to..." framing permeate section headings within
each file.

### Strategic framing (Teammate D, high confidence)

- No formal ROAD_MAP.md exists, but trajectory shows a three-layer documentation pyramid:
  `.claude/commands/` (authoritative spec) → `docs/agent-system/commands.md` (terse catalog) →
  `docs/workflows/` (narrative). Task 9 closes the third layer.
- At 50+ commands (a plausible 1-year horizon), triple-maintenance becomes a tax. Workflow docs
  should stay at the "when and why" level, not the "what flags" level, so they remain stable
  across minor command changes.
- Follow-up opportunities: auto-generating commands.md rows from command frontmatter; adding
  workflow docs to `.claude/context/index.json` for intent-based routing; a `getting-started.md`
  onboarding doc.

### Critical issues to address in the plan (Teammate C, high confidence)

The plan must make explicit decisions on these ambiguities, which the task description leaves
open:

1. **Audience**: treat `docs/workflows/` as human-facing narrative (consistent with existing
   files) — not as agent context injection.
2. **Depth**: aim for the current `convert-documents.md` depth (~80-120 lines with examples,
   decision table, cross-links), not one-line catalog entries.
3. **Extension caveats**: add a standard "Requires the `{extension}` extension" callout to
   every section documenting an extension-gated command, using a consistent format.
4. **Link policy**: defer flag reference to `docs/agent-system/commands.md`; link into
   `.claude/commands/*.md` only when users need the authoritative flag list. Do NOT duplicate
   flag tables.
5. **Existing files**: leave `convert-documents.md`, `edit-word-documents.md`,
   `edit-spreadsheets.md`, `tips-and-troubleshooting.md` as-is; only `agent-lifecycle.md` and
   `README.md` are modified.
6. **Maintenance**: acknowledge the staleness risk in a short note in `README.md` ("these docs
   are narrative — see `commands.md` for the authoritative flag reference") so readers know
   where to go when something looks out of date.

---

## Synthesis

### Conflicts Resolved

- **Teammate A vs. Teammate C on scope.** A proposed extending `agent-lifecycle.md` AND
  creating three new files. C questioned whether this level of depth is warranted given
  four existing documentation layers. **Resolution**: follow A's scope but adopt C's depth
  discipline — each new file stays in the 80-150 line range, explicitly defers to
  `commands.md` for flag reference, and does not repeat content from existing docs. This
  preserves coverage while controlling maintenance burden.

- **Teammate B vs. Teammate A on grouping.** B explored artifact- and role-based alternatives.
  **Resolution**: use A's command-cluster grouping (it matches existing file conventions), but
  adopt B's "I want to..." phrasing for section headings within each file. This gives the
  scannability advantage without breaking the established directory structure.

- **Teammate D vs. Teammate C on future-proofing.** D suggested agent-routable frontmatter and
  Mermaid diagrams as forward-looking enhancements. C warned against over-engineering and
  scope creep. **Resolution**: defer all future-proofing (frontmatter, Mermaid, index.json
  registration) to follow-up tasks. This task produces handwritten narrative docs in the
  current style. A brief note-to-self can be captured in the plan for future consideration.

### Gaps Identified

- **`/tag` coverage is ambiguous.** Teammate D noted `/tag` may not exist as a standalone
  file in `.claude/commands/` even though CLAUDE.md references it. **Action for planner**:
  verify `.claude/commands/tag.md` exists before planning a section on it; if missing, note
  as a follow-up task and document it briefly in the maintenance-and-meta file with the
  caveat "(user-only command)".

- **`/learn` frontmatter irregularities.** Teammate D noted `learn.md` has a non-standard
  frontmatter format. This is a potential follow-up task but does not block workflow doc
  writing. **Action for planner**: proceed with narrative based on observed behavior, flag
  the frontmatter issue as a follow-up.

- **`edit-spreadsheets.md` does not correspond to a slash command.** Teammates A and B both
  noted this file documents an MCP tool flow, not a slash command. It is out of scope for
  this task but should be mentioned in README.md as a sibling doc.

### Recommendations

**Recommended file set** (in order of priority):

1. **agent-lifecycle.md** (extend): add "Revising a plan (`/revise`)" and "Unblocking a
   blocked task (`/spawn`)" sections to the existing file. These are small additions
   (10-25 lines each).

2. **maintenance-and-meta.md** (new, ~140 lines): cover `/review`, `/errors`, `/fix-it`,
   `/refresh`, `/meta`, `/merge`, and a brief `/tag` mention. Organize around the narrative
   "keeping the system healthy". Decision guide at top, per-command sections below.

3. **grant-development.md** (new, ~160 lines): cover `/grant`, `/budget`, `/timeline`,
   `/funds`, `/talk`. Organize around the forcing-questions + task + research/plan/implement
   pattern. Each command gets a section with a minimal example and a cross-link to the
   relevant task-type in `docs/agent-system/commands.md`. Add "Requires the `present`
   extension" callout at the top.

4. **memory-and-learning.md** (new, ~90 lines): cover `/learn` in its four modes (text,
   file, directory, task), plus the `--remember` flag on `/research`. Add "Requires the
   `memory` extension" callout at the top.

5. **README.md** (update): add four new Contents table rows (one for extended
   agent-lifecycle.md sections is not needed), four new decision-guide rows, and any new
   common scenarios entries.

**Implementation order for the planner**: README.md update last (depends on new files being
in place); otherwise, files are independent and can be written in any order or in parallel.

**Content constraints for every new section**:
- 1-3 sentence intro explaining the command's purpose and when to reach for it
- 1-2 minimal usage examples in code blocks
- Cross-link to `docs/agent-system/commands.md` for flag reference
- Extension callout if applicable
- No flag tables (defer to commands.md)
- No raw agent/skill implementation details

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach | completed | high |
| B | Alternatives & prior art | completed | medium |
| C | Critic | completed | high |
| D | Horizons | completed | high |

## References

- `docs/workflows/agent-lifecycle.md` — gold-standard lifecycle narrative
- `docs/workflows/convert-documents.md` — gold-standard pattern for new files
- `docs/workflows/README.md` — decision guide and Contents table to update
- `docs/agent-system/commands.md` — terse catalog, link target for flag details
- `.claude/commands/*.md` — 24 authoritative command specifications
- `.claude/docs/guides/user-guide.md` — internal authoritative reference for advanced use
- `specs/009_workflow_docs_for_commands/reports/01_teammate-a-findings.md`
- `specs/009_workflow_docs_for_commands/reports/01_teammate-b-findings.md`
- `specs/009_workflow_docs_for_commands/reports/01_teammate-c-findings.md`
- `specs/009_workflow_docs_for_commands/reports/01_teammate-d-findings.md`
