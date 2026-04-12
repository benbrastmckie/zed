# Implementation Plan: Fix /meta creating tasks at RESEARCHED status without research artifacts

- **Task**: 42 - Fix /meta creating tasks at RESEARCHED status without research artifacts
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/042_fix_meta_researched_status/reports/01_meta-research-fix.md
- **Artifacts**: plans/01_meta-status-fix.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The meta-builder-agent specifies a Stage 5.5 (GenerateResearchArtifacts) that creates `01_meta-research.md` files for each task, but the LLM agent consistently skips this step at runtime. Tasks end up at RESEARCHED status with no actual report files. This plan removes Stage 5.5, changes task creation to use NOT STARTED status, and updates all downstream references across three files and one standards document. The fix aligns /meta with the /slides pattern where pre-task interview data is metadata, not a research artifact.

### Research Integration

The research report at `reports/01_meta-research-fix.md` identified 17 specific edit locations across 3 files. Key findings:
- Six change sites in `meta-builder-agent.md` (Stage 5.5 deletion, Stage 6 state.json template, Stage 6 TODO.md template)
- Five change sites in `skill-meta/SKILL.md` (return examples, status references, notes)
- Three change sites in `multi-task-creation-standard.md` (compliance table, enhanced features, stage description)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items are directly advanced by this task. This is an internal agent system correctness fix.

## Goals & Non-Goals

**Goals**:
- Remove Stage 5.5 (GenerateResearchArtifacts) from meta-builder-agent.md
- Change all /meta task creation to use `not_started` status instead of `researched`
- Remove artifact array references from state.json and TODO.md templates in the agent
- Update skill-meta SKILL.md return examples to reflect NOT STARTED status
- Update multi-task-creation-standard.md to remove Stage 5.5 references
- Ensure /meta-created tasks follow the normal `/research -> /plan -> /implement` lifecycle

**Non-Goals**:
- Storing interview context as forcing_data (task description already captures this)
- Changing the interview flow itself (Stages 1-5 remain unchanged)
- Retroactively fixing existing tasks that were created with incorrect RESEARCHED status

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Users accustomed to running `/plan N` directly after `/meta` get status error | M | M | next_steps output already says "Run /research N"; clear messaging in return |
| meta-builder-agent.md is large; changes span multiple sections | M | L | Each change is isolated; Stage 5.5 removal is a clean block deletion |
| Interview context perceived as lost when Stage 5.5 removed | L | L | Interview context is already captured in task description field |
| Existing tasks with "researched" status but no artifacts | L | L | Already broken; running `/research N` on them works regardless |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Remove Stage 5.5 and update Stage 6 in meta-builder-agent.md [NOT STARTED]

**Goal**: Remove the GenerateResearchArtifacts stage and update all status/artifact references in the agent definition.

**Tasks**:
- [ ] Change Stage 5 "Yes" dispatch from Stage 5.5 to Stage 6 (line ~592)
- [ ] Delete entire Stage 5.5 section (lines ~594-691)
- [ ] Change `"status": "researched"` to `"status": "not_started"` in Stage 6 state.json template (line ~779)
- [ ] Remove `"artifacts"` array from Stage 6 state.json template (lines ~782-789)
- [ ] Remove RESEARCHED status note (line ~792)
- [ ] Change `[RESEARCHED]` to `[NOT STARTED]` in Stage 6 TODO.md template (line ~798)
- [ ] Remove `- **Research**:` line from TODO.md template (line ~801)
- [ ] Update Python code block to remove `research_path` variable and research line from format string (lines ~827-836)

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/agents/meta-builder-agent.md` - Remove Stage 5.5, update Stage 6 templates

**Verification**:
- Stage 5.5 section no longer exists in the file
- No occurrences of `"status": "researched"` in Stage 6 templates
- No occurrences of `[RESEARCHED]` in TODO.md template sections
- Stage 5 "Yes" path references Stage 6 directly
- No `"artifacts"` array in the state.json template within Stage 6

---

### Phase 2: Update skill-meta SKILL.md return examples [NOT STARTED]

**Goal**: Update the expected return examples and documentation in the skill definition to reflect NOT STARTED status.

**Tasks**:
- [ ] Change summary text from "Tasks start in RESEARCHED status" to NOT STARTED (line ~132)
- [ ] Remove research artifact entries from artifacts array, keep task directory entries (lines ~137-151)
- [ ] Change `"tasks_status": "researched"` to `"tasks_status": "not_started"` in metadata (line ~160)
- [ ] Change next_steps to `"Run /research 430 to begin research on first task"` (line ~163)
- [ ] Replace RESEARCHED rationale note block with NOT STARTED lifecycle note (lines ~166-167)

**Timing**: 15 minutes

**Depends on**: 1

**Files to modify**:
- `.claude/skills/skill-meta/SKILL.md` - Update return examples and status references

**Verification**:
- No occurrences of `"researched"` in the Expected Return: Interactive Mode section
- next_steps references `/research` not `/plan`
- Note block explains normal lifecycle, not RESEARCHED rationale

---

### Phase 3: Update multi-task-creation-standard.md [NOT STARTED]

**Goal**: Remove Stage 5.5 / GenerateResearchArtifacts references from the compliance standard.

**Tasks**:
- [ ] Remove "Research Generation" row from Reference Implementation table (line ~373)
- [ ] Change State Updates description to "Interview Stage 6 (batch insertion with NOT STARTED status)" (line ~374)
- [ ] Remove Stage 5.5 bullet from Enhanced Stages description (line ~378)
- [ ] Remove "Research Gen" column from Current Compliance Status table (lines ~384-391)
- [ ] Remove or simplify "Enhanced /meta Features" bullets referencing Stage 5.5 (lines ~394-397)

**Timing**: 15 minutes

**Depends on**: 1

**Files to modify**:
- `.claude/docs/reference/standards/multi-task-creation-standard.md` - Remove Stage 5.5 references

**Verification**:
- No occurrences of "Stage 5.5" or "GenerateResearchArtifacts" in the file
- No "Research Gen" column in the compliance table
- State Updates description mentions NOT STARTED

---

### Phase 4: End-to-end verification [NOT STARTED]

**Goal**: Verify all changes are consistent and no stale references remain.

**Tasks**:
- [ ] Grep entire `.claude/` directory for "Stage 5.5" to confirm no remaining references
- [ ] Grep for "GenerateResearchArtifacts" across the codebase
- [ ] Grep `meta-builder-agent.md` for `"researched"` to confirm no stale status values in templates
- [ ] Verify `meta-builder-agent.md` Stage 5 -> Stage 6 flow reads correctly
- [ ] Verify `SKILL.md` return examples are internally consistent (artifacts match summary)
- [ ] Verify `multi-task-creation-standard.md` table columns are aligned after column removal

**Timing**: 15 minutes

**Depends on**: 2, 3

**Files to modify**:
- None (read-only verification)

**Verification**:
- Zero grep hits for "Stage 5.5" and "GenerateResearchArtifacts" in `.claude/`
- Zero grep hits for `"status": "researched"` in meta-builder-agent.md Stage 6 context
- All modified files have consistent internal references

## Testing & Validation

- [ ] No occurrences of "Stage 5.5" or "GenerateResearchArtifacts" in `.claude/` directory
- [ ] `meta-builder-agent.md` Stage 5 "Yes" dispatches to Stage 6
- [ ] `meta-builder-agent.md` Stage 6 state.json template uses `"status": "not_started"` and has no `"artifacts"` array
- [ ] `meta-builder-agent.md` Stage 6 TODO.md template uses `[NOT STARTED]` and has no `- **Research**:` line
- [ ] `skill-meta/SKILL.md` interactive mode return shows `"tasks_status": "not_started"`
- [ ] `multi-task-creation-standard.md` has no "Research Gen" column or Stage 5.5 references

## Artifacts & Outputs

- `specs/042_fix_meta_researched_status/plans/01_meta-status-fix.md` (this plan)
- `specs/042_fix_meta_researched_status/summaries/01_meta-status-fix-summary.md` (after implementation)

## Rollback/Contingency

All changes are to `.claude/` documentation and agent definition files. Rollback is straightforward via `git checkout` of the three affected files:
- `.claude/agents/meta-builder-agent.md`
- `.claude/skills/skill-meta/SKILL.md`
- `.claude/docs/reference/standards/multi-task-creation-standard.md`

No runtime code, configuration, or user data is modified.
