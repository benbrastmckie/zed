# Implementation Plan: Update Docs for Agent System Reload

- **Task**: 13 - update_docs_for_agent_system_reload
- **Status**: [IMPLEMENTING]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/013_update_docs_for_agent_system_reload/reports/01_team-research.md
- **Artifacts**: plans/01_update-docs-agent-reload.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The `.claude/` agent system reload replaced the epidemiology extension v1.0.0 with v2.0.0, renaming agents/skills (`epidemiology-*` to `epi-*`), adding the `/epi` command, and expanding context files. The `docs/` directory needs 9 targeted updates: fix stale counts, add missing command documentation, create a new workflow guide, correct Neovim-specific keybinding references, and fix a broken routing table in `.claude/context/routing.md`. Done when all 9 action items from research are addressed and documentation is internally consistent.

### Research Integration

Integrated findings from team research report (4 teammates: diff analysis, component rename tracking, gap/inconsistency critique, strategic horizons). Key findings: no old extension names leaked into docs/ (rename is net-zero for search-replace), the `/epi` command is entirely undocumented, command/residual counts are stale by 1, and `.claude/context/routing.md` has a functional break mapping to deleted skill names.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add `/epi` command entry to the command catalog with correct format
- Fix all stale numeric counts (command count 24->25, residual count 17->18)
- Create epidemiology workflow narrative doc analogous to grant-development.md
- Fix stale routing.md skill names that would break `epidemiology` task type routing
- Correct Neovim-specific `<leader>ac` references in Zed-facing workflow docs
- Fix stale keybinding reference in agent-system README

**Non-Goals**:
- Restructuring docs/ directory layout (confirmed unnecessary by research)
- Updating `.claude/agents/README.md` extension agent coverage (separate concern)
- Duplicating routing tables into architecture.md (defers to CLAUDE.md)
- Reviewing PPTX conversion API changes in convert-documents.md (low priority, deferred)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Count drift if more commands added before implementation | L | L | Verify counts at implementation time against actual command files |
| New epi workflow doc copies Neovim-specific patterns from grant-development.md | M | M | Research confirmed the `<leader>ac` anti-pattern; explicitly avoid it |
| routing.md fix breaks other routing entries | M | L | Only modify the epidemiology row; verify all other rows unchanged |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Fix Critical Stale References [COMPLETED]

**Goal**: Resolve all HIGH-priority items -- the routing break, missing command entry, and stale counts.

**Tasks**:
- [ ] Fix `.claude/context/routing.md` line 15: change `skill-epidemiology-research` to `skill-epi-research` and `skill-epidemiology-implementation` to `skill-epi-implement`
- [ ] Add `/epi` command entry to `docs/agent-system/commands.md` in a new "Epidemiology" section (after Grant development), following existing entry format (2-sentence description, example, flags, source link)
- [ ] Update command count in `docs/agent-system/commands.md` line 3 from "24" to "25"
- [ ] Update residual count in `docs/workflows/agent-lifecycle.md` line 3 from "17" to "18"

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/context/routing.md` - Fix stale skill names on epidemiology row
- `docs/agent-system/commands.md` - Add /epi entry, update count
- `docs/workflows/agent-lifecycle.md` - Update residual count

**Verification**:
- `grep -c "skill-epidemiology" .claude/context/routing.md` returns 0
- `grep "skill-epi-research" .claude/context/routing.md` returns the epidemiology row
- `grep "25 slash commands" docs/agent-system/commands.md` returns a match
- `grep "remaining 18" docs/workflows/agent-lifecycle.md` returns a match
- `/epi` appears in commands.md with description, example, and source link

---

### Phase 2: Create Epidemiology Workflow Doc and Update Index [NOT STARTED]

**Goal**: Create the new narrative workflow guide and register it in the workflows README.

**Tasks**:
- [ ] Create `docs/workflows/epidemiology-analysis.md` covering: when to use `/epi`, task type routing (`epi`, `epi:study`, `epidemiology`), available R-based analysis capabilities, example workflow from task creation through implementation, relationship to research/plan/implement lifecycle
- [ ] Ensure the new doc does NOT include `<leader>ac` or other Neovim-specific keybinding references (use Zed-appropriate alternatives or omit)
- [ ] Add epidemiology row to `docs/workflows/README.md` in a new "Epidemiology" section following the existing table pattern
- [ ] Review `docs/workflows/convert-documents.md` for PPTX API accuracy (action item 9, low priority -- note any issues as comments but do not block on this)

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `docs/workflows/epidemiology-analysis.md` - New file
- `docs/workflows/README.md` - Add epidemiology section with link

**Verification**:
- `docs/workflows/epidemiology-analysis.md` exists and contains `/epi` usage examples
- `grep "<leader>" docs/workflows/epidemiology-analysis.md` returns no matches
- `docs/workflows/README.md` contains a link to `epidemiology-analysis.md`

---

### Phase 3: Fix Stale Keybinding and Extension Loader References [NOT STARTED]

**Goal**: Correct Neovim-specific references that are inaccurate in the Zed workspace context.

**Tasks**:
- [ ] Fix `docs/agent-system/README.md` stale keybinding: replace "Cmd+Shift+?" with the correct Zed keybinding (`Ctrl+?` for assistant panel or `Ctrl+Shift+A` for terminal task, as appropriate from context)
- [ ] Fix `docs/workflows/grant-development.md` line 5: replace or remove `<leader>ac` reference with Zed-appropriate note about extension loading
- [ ] Fix `docs/workflows/memory-and-learning.md` line 5: same treatment as grant-development.md

**Timing**: 20 minutes

**Depends on**: 1

**Files to modify**:
- `docs/agent-system/README.md` - Fix keybinding reference
- `docs/workflows/grant-development.md` - Fix `<leader>ac` reference
- `docs/workflows/memory-and-learning.md` - Fix `<leader>ac` reference

**Verification**:
- `grep "Cmd+Shift+?" docs/agent-system/README.md` returns no matches
- `grep "<leader>" docs/workflows/grant-development.md` returns no matches
- `grep "<leader>" docs/workflows/memory-and-learning.md` returns no matches

## Testing & Validation

- [ ] All 9 research action items addressed (cross-reference against consolidated action items table)
- [ ] No stale `skill-epidemiology-*` references remain in `.claude/context/routing.md`
- [ ] Command count in commands.md matches actual command file count
- [ ] No Neovim-specific `<leader>` keybindings appear in Zed-facing docs
- [ ] New epidemiology workflow doc is self-consistent and links correctly from README
- [ ] All modified files parse correctly (no broken markdown links)

## Artifacts & Outputs

- `specs/013_update_docs_for_agent_system_reload/plans/01_update-docs-agent-reload.md` (this plan)
- `docs/workflows/epidemiology-analysis.md` (new workflow guide)
- Modified: `docs/agent-system/commands.md`, `docs/workflows/agent-lifecycle.md`, `docs/workflows/README.md`, `docs/agent-system/README.md`, `docs/workflows/grant-development.md`, `docs/workflows/memory-and-learning.md`, `.claude/context/routing.md`

## Rollback/Contingency

All changes are to markdown documentation files. Revert with `git checkout HEAD -- docs/ .claude/context/routing.md` if any changes introduce inconsistencies. The new `docs/workflows/epidemiology-analysis.md` file can be deleted independently without affecting other docs.
