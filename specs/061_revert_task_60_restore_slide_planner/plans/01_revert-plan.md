# Implementation Plan: Revert Task 60 and Restore slide-planner-agent

- **Task**: 61 - Revert task 60 implementation and restore slide-planner-agent references
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/061_revert_task_60_restore_slide_planner/reports/01_revert-audit.md
- **Artifacts**: plans/01_revert-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Task 60 incorrectly removed slide-planner-agent and skill-slide-planning references from 14+ files across docs/, .claude/, and command files, treating them as stale. The root cause was commit 191655c3 (extension loader sync) which overwrote CLAUDE.md with an nvim-origin version that lacked zed-specific present extension additions. This plan reverts the 4 task-60 commits, then re-adds the 4 CLAUDE.md table entries that were removed by the earlier 191655c3 commit (not by task 60 itself), and finally verifies cross-reference consistency.

### Research Integration

Research report `01_revert-audit.md` identified all 4 commits to revert (198c9270 through 41023fd4), cataloged 17+ affected files, documented the expected conflict points (TODO.md and state.json), and provided exact table entries to re-add to CLAUDE.md.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Revert all 4 task-60 commits, restoring 12+ files to their pre-task-60 state
- Re-add slide-planner-agent and skill-slide-planning to the 4 CLAUDE.md tables (fixing the 191655c3 regression)
- Restore the Co-Authored-By note in git-workflow.md
- Restore the Hooks section in CLAUDE.md
- Verify full cross-reference consistency across CLAUDE.md, index.json, docs/, agents/README.md, and skill files

**Non-Goals**:
- Re-applying any valid improvements from task 60 (e.g., pymupdf additions to document-agent.md) -- these can be done in a separate task
- Fixing the root cause of the extension loader sync regression (commit 191655c3) -- that is a separate concern
- Modifying TODO.md or state.json status for task 60 -- that is handled by the orchestrator postflight

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TODO.md/state.json conflicts during revert | M | H | Use `--no-commit` to stage all reverts, then manually resolve conflicts before committing |
| Reverting document-agent.md loses pymupdf improvements | L | H | Accept the loss; improvements can be re-applied in a future task separate from incorrect removals |
| Reverting filetypes context loses valid updates | L | H | Same approach -- re-apply valid changes separately |
| index.json key reordering causes semantic issues | L | L | Key order is functionally irrelevant in JSON; the pre-task-60 order was working |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Revert Task 60 Commits [IN PROGRESS]

**Goal**: Revert all 4 task-60 commits in reverse chronological order using a compound no-commit revert, resolving TODO.md/state.json conflicts manually.

**Tasks**:
- [ ] Run `git revert --no-commit 41023fd4` (implementation phase 2)
- [ ] Run `git revert --no-commit 258361ee` (implementation phase 1)
- [ ] Run `git revert --no-commit 23ffeecd` (plan creation)
- [ ] Run `git revert --no-commit 198c9270` (research completion)
- [ ] Resolve TODO.md conflict: keep task 61 entry, ensure task 60 entry reflects its pre-completion state (or is marked for abandonment by orchestrator)
- [ ] Resolve state.json conflict: revert task 60 completion data, keep task 61 entry
- [ ] Verify staged changes look correct with `git diff --staged`
- [ ] Commit the compound revert

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `.claude/CLAUDE.md` -- Restore Hooks section, present extension table entries
- `.claude/context/index.json` -- Restore slide-planner-agent in 5 agent arrays
- `.claude/context/index.json.backup` -- Same
- `.claude/extensions.json` -- Restore format
- `.claude/rules/git-workflow.md` -- Restore Co-Authored-By note
- `.claude/skills/skill-slides/SKILL.md` -- Restore routing note
- `.claude/agents/README.md` -- Restore slide-planner-agent row
- `.claude/agents/document-agent.md` -- Restore pre-task-60 conversion table
- `.claude/context/project/filetypes/domain/conversion-tables.md` -- Restore
- `.claude/context/project/filetypes/tools/dependency-guide.md` -- Restore
- `.claude/context/project/filetypes/tools/tool-detection.md` -- Restore
- `docs/agent-system/README.md` -- Restore skill-slide-planning references
- `docs/agent-system/commands.md` -- Restore skill-slide-planning references
- `docs/workflows/grant-development.md` -- Restore skill-slide-planning references
- `.claude/commands/implement.md` -- Restore PostToolUse hook wording
- `.claude/commands/plan.md` -- Restore PostToolUse hook wording
- `.claude/commands/research.md` -- Restore PostToolUse hook wording
- `specs/TODO.md` -- Conflict resolution
- `specs/state.json` -- Conflict resolution

**Verification**:
- `git diff --staged` shows correct reversals for all task-60 changes
- TODO.md contains task 61 entry
- state.json contains task 61 entry
- Task 60 artifacts (specs/060_*) are removed by revert

---

### Phase 2: Re-add slide-planner-agent to CLAUDE.md Tables [NOT STARTED]

**Goal**: Add the 4 slide-planner-agent/skill-slide-planning entries to CLAUDE.md tables that were removed by the earlier commit 191655c3 (not by task 60), completing the restoration.

**Tasks**:
- [ ] Add to Skill-to-Agent Mapping table (after skill-orchestrator row): `| skill-slide-planning | slide-planner-agent | opus | Interactive slide design planning |`
- [ ] Add to Agents table (after spawn-agent row): `| slide-planner-agent | Interactive slide design and per-slide planning |`
- [ ] Add to Present Extension Skill-Agent Mapping table (after slidev-assembly-agent row): `| skill-slide-planning | slide-planner-agent | opus | Interactive slide design planning |`
- [ ] Fix Present Extension Language Routing table: change `present` / `slides` / `skill-slides` row to `present:slides` / `slides` / `skill-slide-planning` / `skill-slides`
- [ ] Verify all 4 table entries are present and correctly formatted

**Timing**: 20 minutes

**Depends on**: 1

**Files to modify**:
- `.claude/CLAUDE.md` -- Add 4 table entries

**Verification**:
- Grep for `slide-planner-agent` in CLAUDE.md returns 4+ matches
- Grep for `skill-slide-planning` in CLAUDE.md returns 3+ matches
- Table formatting is consistent with surrounding rows

---

### Phase 3: Cross-Reference Verification [NOT STARTED]

**Goal**: Verify that all references to slide-planner-agent and skill-slide-planning are consistent across the codebase.

**Tasks**:
- [ ] Verify slide-planner-agent appears in: CLAUDE.md (4 tables), index.json (5 agent array entries), agents/README.md (1 row), agents/slide-planner-agent.md (exists)
- [ ] Verify skill-slide-planning appears in: CLAUDE.md (3 tables), skills/skill-slide-planning/SKILL.md (exists), docs/agent-system/commands.md, docs/agent-system/README.md, docs/workflows/grant-development.md
- [ ] Verify Co-Authored-By note is present in git-workflow.md
- [ ] Verify Hooks section is present in CLAUDE.md under Rules References
- [ ] Verify skill-slides/SKILL.md references slide-planner-agent correctly
- [ ] Run `grep -r "slide-planner" .claude/ docs/` and confirm expected count of references
- [ ] Fix any inconsistencies found

**Timing**: 15 minutes

**Depends on**: 2

**Files to modify**:
- Any files found to have inconsistencies (expected: none if phases 1-2 execute correctly)

**Verification**:
- All cross-reference checks pass
- No orphaned or missing references to slide-planner-agent or skill-slide-planning

## Testing & Validation

- [ ] `grep -c "slide-planner-agent" .claude/CLAUDE.md` returns 4+
- [ ] `grep -c "skill-slide-planning" .claude/CLAUDE.md` returns 3+
- [ ] `jq '.entries[] | select(any(.load_when.agents[]?; . == "slide-planner-agent"))' .claude/context/index.json` returns 5 entries
- [ ] `grep "slide-planner-agent" .claude/agents/README.md` returns 1 row
- [ ] `grep "Co-Authored-By" .claude/rules/git-workflow.md` returns the note line
- [ ] `grep "Hooks" .claude/CLAUDE.md` returns the Hooks subsection
- [ ] docs/agent-system/commands.md contains `skill-slide-planning` (not `skill-slides` as research skill)
- [ ] docs/workflows/grant-development.md contains `skill-slide-planning` in 2 places

## Artifacts & Outputs

- `specs/061_revert_task_60_restore_slide_planner/plans/01_revert-plan.md` (this file)
- `specs/061_revert_task_60_restore_slide_planner/summaries/01_revert-summary.md` (after implementation)

## Rollback/Contingency

If the revert introduces unexpected issues:
1. Run `git revert HEAD` to undo the revert commit
2. This restores the task-60 state, which is functional (just missing slide-planner references)
3. Investigate the specific issue and create a targeted fix instead of a bulk revert
4. If only the CLAUDE.md table additions (Phase 2) cause issues, they can be independently reverted without affecting the Phase 1 revert
