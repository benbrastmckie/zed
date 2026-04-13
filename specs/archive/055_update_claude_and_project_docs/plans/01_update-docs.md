# Implementation Plan: Task #55

- **Task**: 55 - Update all documentation in .claude/, README.md, and docs/
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/055_update_claude_and_project_docs/reports/01_team-research.md
- **Artifacts**: plans/01_update-docs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: true

## Overview

The recent batch of .claude/ changes introduced a new slide planning capability (skill-slide-planning + slide-planner-agent), adopted the `present:slides` compound task type, and added a PostToolUse validation hook -- none of which are reflected in CLAUDE.md, agents/README.md, or docs/. This plan addresses 14 documentation updates identified by team research, organized into 4 phases by documentation area.

### Research Integration

Key findings from team research (4 teammates, high confidence):
- 6 Must-Do items centered on CLAUDE.md tables and agents/README.md
- 5 Should-Do items covering docs/ and Present Extension routing tables
- 3 Could-Do housekeeping items (git-workflow.md, grant-development.md)
- The `languages[]?` jq example fix (research item #4) was verified as already resolved in the current CLAUDE.md

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No active roadmap items. ROADMAP.md is empty.

## Goals & Non-Goals

**Goals**:
- Bring CLAUDE.md Skill-to-Agent and Agents tables up to date with slide-planner-agent
- Fix Present Extension routing to reflect `present:slides` compound task type and `skill-slide-planning` for plan routing
- Document the validate-plan-write.sh PostToolUse hook
- Update agents/README.md and docs/ to reflect new capabilities

**Non-Goals**:
- Modifying any functional code (agents, skills, commands, hooks)
- Cleaning up .claude_OLD/ or context/index.json.backup (separate maintenance tasks)
- Rewriting or restructuring docs/ beyond the targeted updates
- Updating extension manifest files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stale information in docs/ files not caught by research | L | M | Cross-check each file against current skill/agent definitions before editing |
| Present Extension routing table has additional stale entries | M | L | Verify all rows against actual skill files during Phase 1 |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: CLAUDE.md Core Tables and Present Extension [COMPLETED]

**Goal**: Fix all 6 Must-Do items in .claude/CLAUDE.md -- the central configuration index.

**Tasks**:
- [ ] Add `skill-slide-planning | slide-planner-agent | opus | Interactive slide planning with narrative arc review` to Skill-to-Agent Mapping table
- [ ] Add `slide-planner-agent | Interactive slide design and per-slide planning` to Agents table
- [ ] Fix Present Extension Skill-Agent Mapping table: add `skill-slide-planning | slide-planner-agent | opus | Interactive slide design planning` row
- [ ] Fix Present Extension Language Routing table: change `present | slides | skill-slides | skill-slides` to `present | slides | skill-slide-planning | skill-slides` for plan routing, and use `present:slides` compound value
- [ ] Add Hooks section (or append to Rules References) documenting `validate-plan-write.sh` PostToolUse hook for artifact validation

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `.claude/CLAUDE.md` - Skill-to-Agent table, Agents table, Present Extension section, Rules References

**Verification**:
- Grep CLAUDE.md for `slide-planner-agent` -- should appear in 3 locations (Skill-to-Agent, Agents, Present Extension)
- Grep CLAUDE.md for `skill-slide-planning` -- should appear in 2 locations (Skill-to-Agent, Present Extension routing)
- Grep CLAUDE.md for `validate-plan-write` -- should appear at least once
- Grep CLAUDE.md for `present:slides` -- should appear in Language Routing table

---

### Phase 2: agents/README.md [COMPLETED]

**Goal**: Add slide-planner-agent to the agents directory README and note that extension agents are documented in CLAUDE.md extension sections.

**Tasks**:
- [ ] Add `slide-planner-agent.md | Interactive slide design planning with 5-stage Q&A` row to Agent Files table
- [ ] Add note below table: "Extension-specific agents (epi, filetypes, latex, python, typst, present) are documented in their respective CLAUDE.md extension sections."

**Timing**: 15 minutes

**Depends on**: 1

**Files to modify**:
- `.claude/agents/README.md` - Agent Files table, explanatory note

**Verification**:
- Grep agents/README.md for `slide-planner-agent` -- should appear once in table
- Grep agents/README.md for `extension` -- should appear in explanatory note

---

### Phase 3: docs/ Directory Updates [COMPLETED]

**Goal**: Update user-facing documentation in docs/ to reflect slide planning capability and present:slides routing.

**Tasks**:
- [ ] `docs/agent-system/commands.md`: Add note that `/plan` on slides tasks triggers interactive 5-stage design review via skill-slide-planning, not generic planning
- [ ] `docs/agent-system/README.md`: Add sentence about slide planning in Present extension description
- [ ] `docs/workflows/grant-development.md`: Update `/plan` description for slides tasks if it references the old routing

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `docs/agent-system/commands.md` - /plan command description
- `docs/agent-system/README.md` - Present extension description
- `docs/workflows/grant-development.md` - Slides workflow description (if applicable)

**Verification**:
- Grep docs/ for `slide-planning` or `skill-slide-planning` -- should appear in commands.md and README.md
- Review grant-development.md for any stale slides references

---

### Phase 4: Housekeeping Fixes [COMPLETED]

**Goal**: Address Could-Do items that improve documentation consistency.

**Tasks**:
- [ ] `.claude/rules/git-workflow.md`: Remove or update the stale `Co-Authored-By: Claude Opus 4.5` example in commit format section (conflicts with user preference to omit Co-Authored-By entirely)
- [ ] `README.md` (root): Optionally add note about `/slides` + `/plan` interactive behavior in domain commands table, if such a table exists

**Timing**: 15 minutes

**Depends on**: 2, 3

**Files to modify**:
- `.claude/rules/git-workflow.md` - Commit message format section
- `README.md` - Domain commands table (conditional)

**Verification**:
- Grep git-workflow.md for `Co-Authored-By` -- should either be removed or note the user preference
- Verify README.md is consistent with CLAUDE.md present extension section

## Testing & Validation

- [ ] Run `grep -c 'slide-planner-agent' .claude/CLAUDE.md` -- expect 3+
- [ ] Run `grep -c 'skill-slide-planning' .claude/CLAUDE.md` -- expect 2+
- [ ] Run `grep -c 'validate-plan-write' .claude/CLAUDE.md` -- expect 1+
- [ ] Run `grep -c 'present:slides' .claude/CLAUDE.md` -- expect 1+
- [ ] Run `grep -c 'slide-planner' .claude/agents/README.md` -- expect 1
- [ ] Verify no remaining references to `languages[]?` in jq examples
- [ ] Cross-check all modified tables against actual skill/agent file existence

## Artifacts & Outputs

- Updated `.claude/CLAUDE.md` with corrected tables and new hook documentation
- Updated `.claude/agents/README.md` with slide-planner-agent entry
- Updated `docs/agent-system/commands.md` with slide planning note
- Updated `docs/agent-system/README.md` with present extension update
- Updated `docs/workflows/grant-development.md` (if applicable)
- Updated `.claude/rules/git-workflow.md` with corrected commit examples
- Optionally updated `README.md`

## Rollback/Contingency

All changes are documentation-only edits to markdown files. Rollback via `git checkout -- <file>` for any individual file, or `git reset HEAD~1` to undo the entire commit.
