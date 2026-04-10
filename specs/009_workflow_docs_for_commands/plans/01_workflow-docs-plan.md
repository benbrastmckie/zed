# Implementation Plan: Workflow Docs for Commands

- **Task**: 9 - workflow_docs_for_commands
- **Status**: [COMPLETED]
- **Completed**: 2026-04-10
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_team-research.md
- **Artifacts**: plans/01_workflow-docs-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Populate `docs/workflows/` with narrative workflow guides covering all 24 commands. Research identified 10 undocumented commands and 2 partially covered commands across three thematic clusters: maintenance/meta, grant development, and memory. The approach is to extend `agent-lifecycle.md` with `/revise` and `/spawn` sections, create three new files (`maintenance-and-meta.md`, `grant-development.md`, `memory-and-learning.md`), and update `README.md` to register the new files. Done when every command appears in at least one workflow doc and `README.md` reflects the full set.

### Research Integration

Integrated findings from `reports/01_team-research.md` (4-teammate team research):
- Coverage gap analysis: 12 covered, 2 partial, 10 missing
- Style pattern: decision-guide table, scenario-driven sections, minimal examples, cross-links
- Recommended grouping: command-cluster with "I want to..." headings
- Depth target: 80-160 lines per new file, matching `convert-documents.md`
- Content constraints: defer flag tables to `commands.md`, add extension callouts

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROAD_MAP.md found.

## Goals & Non-Goals

**Goals**:
- Every command in `.claude/commands/` is covered by at least one workflow doc
- New files follow the gold-standard pattern set by `convert-documents.md` (decision table, scenarios, cross-links)
- `README.md` reflects the complete set of workflow docs with updated decision guide
- Extension-gated commands carry a "Requires the `{extension}` extension" callout

**Non-Goals**:
- Duplicating flag-level reference from `docs/agent-system/commands.md`
- Adding agent-routable frontmatter or Mermaid diagrams (future task)
- Modifying `convert-documents.md`, `edit-word-documents.md`, `edit-spreadsheets.md`, or `tips-and-troubleshooting.md`
- Registering workflow docs in `.claude/context/index.json`

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Content drift from commands.md | M | M | Defer all flag detail to commands.md; workflow docs cover "when and why" only |
| Inconsistent style across new files | M | L | Use convert-documents.md as template; verify each file has decision table + See also |
| Missing extension callouts | L | L | Checklist verification in Phase 5 |
| `/tag` command spec missing | L | L | Document briefly as "(user-only)" in maintenance file |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4 | -- |
| 2 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Extend agent-lifecycle.md with /revise and /spawn [COMPLETED]

**Goal**: Add dedicated sections for `/revise` and `/spawn` to the existing lifecycle doc, completing partial coverage.

**Tasks**:
- [ ] Add "Revising a plan" section after the "Implementing" section covering `/revise N` usage, when to use (plan is outdated, new research available), and a minimal example
- [ ] Add "Unblocking a blocked task" section in the "Exception states" area covering `/spawn N` usage, when to use (task is [BLOCKED]), and a minimal example
- [ ] Add cross-links to the new sections from the exception-states bullet list
- [ ] Verify the file stays consistent with existing style (goal-oriented headings, user-facing voice)

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `docs/workflows/agent-lifecycle.md` - Add /revise and /spawn sections (~20-30 lines total)

**Verification**:
- `/revise` and `/spawn` each have a heading, 1-2 sentence description, minimal example, and cross-link
- Existing content unchanged

---

### Phase 2: Create maintenance-and-meta.md [COMPLETED]

**Goal**: Document the maintenance and system-building command cluster: `/review`, `/errors`, `/fix-it`, `/refresh`, `/meta`, `/merge`, `/tag`.

**Tasks**:
- [ ] Create `docs/workflows/maintenance-and-meta.md`
- [ ] Write decision-guide table at top mapping "I want to..." to each command
- [ ] Write per-command sections with scenario-driven headings: "Reviewing code quality" (`/review`), "Finding and fixing errors" (`/errors`, `/fix-it`), "Cleaning up resources" (`/refresh`), "Changing the agent system" (`/meta`), "Shipping changes" (`/merge`, `/tag`)
- [ ] Each section: 1-3 sentence intro, 1-2 minimal usage examples, cross-link to commands.md
- [ ] Note `/tag` as user-only
- [ ] Add "See also" section at bottom
- [ ] Target ~120-150 lines

**Timing**: 0.75 hours

**Depends on**: none

**Files to modify**:
- `docs/workflows/maintenance-and-meta.md` - New file

**Verification**:
- All 7 commands covered: /review, /errors, /fix-it, /refresh, /meta, /merge, /tag
- Decision table present; See also section present
- No flag tables (deferred to commands.md)
- Line count in 100-160 range

---

### Phase 3: Create grant-development.md [COMPLETED]

**Goal**: Document the grant/presentation development command cluster: `/grant`, `/budget`, `/timeline`, `/funds`, `/talk`.

**Tasks**:
- [ ] Create `docs/workflows/grant-development.md`
- [ ] Add "Requires the `present` extension" callout at top
- [ ] Write decision-guide table mapping grant/budget/timeline/funds/talk intents
- [ ] Write per-command sections with scenario-driven headings: "Starting a grant proposal" (`/grant`), "Building a budget" (`/budget`), "Planning a research timeline" (`/timeline`), "Exploring funding sources" (`/funds`), "Preparing a research talk" (`/talk`)
- [ ] Explain the forcing-questions pattern (commands ask clarifying questions before creating the task)
- [ ] Each section: 1-3 sentence intro, 1-2 minimal examples, cross-link to commands.md
- [ ] Add "See also" section
- [ ] Target ~120-160 lines

**Timing**: 0.75 hours

**Depends on**: none

**Files to modify**:
- `docs/workflows/grant-development.md` - New file

**Verification**:
- All 5 commands covered: /grant, /budget, /timeline, /funds, /talk
- Extension callout present
- Decision table present; See also section present
- Line count in 100-170 range

---

### Phase 4: Create memory-and-learning.md [COMPLETED]

**Goal**: Document the memory command: `/learn` in all four modes, plus the `--remember` flag on `/research`.

**Tasks**:
- [ ] Create `docs/workflows/memory-and-learning.md`
- [ ] Add "Requires the `memory` extension" callout at top
- [ ] Write decision-guide table mapping memory intents to modes
- [ ] Write sections: "Saving text as memory" (`/learn "text"`), "Learning from a file" (`/learn /path`), "Scanning a directory" (`/learn /path/to/dir/`), "Harvesting task artifacts" (`/learn --task N`), "Using memories in research" (`/research N --remember`)
- [ ] Each section: 1-3 sentence intro, minimal example
- [ ] Add "See also" section
- [ ] Target ~80-100 lines

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `docs/workflows/memory-and-learning.md` - New file

**Verification**:
- All 4 `/learn` modes covered plus `--remember` flag
- Extension callout present
- Decision table present; See also section present
- Line count in 70-110 range

---

### Phase 5: Update README.md [COMPLETED]

**Goal**: Register new files in the Contents table, add decision-guide rows, and add common-scenario entries to the README.

**Tasks**:
- [ ] Add "Maintenance and system building" section to Contents table with `maintenance-and-meta.md`
- [ ] Add "Grant development" section to Contents table with `grant-development.md`
- [ ] Add "Memory" section to Contents table with `memory-and-learning.md`
- [ ] Add decision-guide rows: "Investigate code quality or errors" -> maintenance-and-meta.md, "Build or modify the agent system" -> maintenance-and-meta.md, "Develop a grant proposal or research talk" -> grant-development.md, "Save or recall knowledge across sessions" -> memory-and-learning.md, "Revise a plan or unblock a task" -> agent-lifecycle.md
- [ ] Add 1-2 common-scenarios entries (e.g., "Developing a grant proposal", "Investigating and fixing codebase issues")
- [ ] Add staleness note: "These docs are narrative guides -- see commands.md for the authoritative flag reference"
- [ ] Verify all links resolve correctly

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3, 4

**Files to modify**:
- `docs/workflows/README.md` - Update Contents, decision guide, common scenarios

**Verification**:
- Every new/extended file appears in Contents table
- Every undocumented command now reachable via at least one decision-guide row
- All links resolve to existing files/anchors
- Staleness note present

## Testing & Validation

- [ ] Every command in `.claude/commands/` is referenced in at least one workflow doc
- [ ] All new files have: decision-guide table, per-command sections, See also section
- [ ] Extension callouts present on grant-development.md and memory-and-learning.md
- [ ] No flag tables duplicated from commands.md
- [ ] README.md decision guide covers all 24 commands (directly or via link to existing docs)
- [ ] Line counts within target ranges (no file exceeds 170 lines)

## Artifacts & Outputs

- `docs/workflows/agent-lifecycle.md` - Extended with /revise and /spawn sections
- `docs/workflows/maintenance-and-meta.md` - New file (~120-150 lines)
- `docs/workflows/grant-development.md` - New file (~120-160 lines)
- `docs/workflows/memory-and-learning.md` - New file (~80-100 lines)
- `docs/workflows/README.md` - Updated Contents, decision guide, common scenarios

## Rollback/Contingency

All changes are additive: three new files and extensions to two existing files. Rollback is `git revert` of the implementation commits. No destructive modifications to existing content.
