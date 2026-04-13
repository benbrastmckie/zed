# Implementation Plan: Move Theme Selection into Planning Phase

- **Task**: 48 - slides_theme_in_planning
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/048_slides_theme_in_planning/reports/01_slides-theme-planning.md
- **Artifacts**: plans/01_slides-theme-planning.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The `/slides` command currently requires a separate `--design` invocation (STAGE 3) to select visual theme, message ordering, and section emphasis. This plan moves those design questions into the `/plan N` phase for slides tasks by adding a `workflow_type: "plan"` route to skill-slides, enabling extension routing from plan.md, and removing the now-redundant `--design` entry point from slides.md. Done when: `/plan N` for a slides task asks design questions, stores `design_decisions` in state.json, then delegates to planner-agent; `--design` flag is removed; assembly agents continue to read `design_decisions` without modification.

### Research Integration

Research report `01_slides-theme-planning.md` identified five architecture options and recommended Option C: modify skill-slides to handle `workflow_type: "plan"` as a pre-planner wrapper. Key findings integrated:
- Assembly agents (pptx, slidev) read `design_decisions.theme` from state.json with a three-level fallback chain (design_decisions -> research report "Recommended Theme" -> default `academic-clean`). No changes needed to assembly agents.
- The planner-agent is generic and cannot use AskUserQuestion. Design questions must be asked before delegation.
- plan.md already has extension routing logic that checks `.claude/extensions/*/manifest.json`, but manifest files are not installed to the `.claude/extensions/` directory -- they exist only in the source directory. The present extension's manifest (at source) routes `present:slides` plan to `skill-planner`. However, slides tasks in state.json use `task_type: "slides"` (not `present:slides`), so routing needs to match the `"slides"` key.
- The `--design` workflow is entirely command-level (slides.md STAGE 3). skill-slides currently handles only `slides_research` and `assemble` workflow types.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items found (roadmap is empty).

## Goals & Non-Goals

**Goals**:
- Design questions (theme, message ordering, section emphasis) asked during `/plan N` for slides tasks
- `design_decisions` stored in state.json before planner-agent receives delegation
- Remove `--design` flag and STAGE 3 from slides.md
- Assembly agents continue to work without modification
- Extension routing correctly dispatches slides plan tasks to skill-slides

**Non-Goals**:
- Changing the design questions themselves (D1, D2, D3 content stays the same)
- Modifying planner-agent to be slides-aware
- Adding new themes or changing theme definitions
- Changing the assembly agents' fallback chain

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Extension routing not finding manifest for installed extension | High | Medium | Plan.md routing checks `.claude/extensions/*/manifest.json` but manifests may not be installed. Phase 1 addresses this by installing the manifest or using extensions.json routing. |
| Task type mismatch (`slides` vs `present:slides`) | High | Medium | Research shows tasks use `task_type: "slides"`. Routing must match this key, not just `present:slides`. |
| Skill-slides growing complex with three workflow types | Low | Medium | Each workflow is self-contained with clear stage separation. |
| Existing tasks that already have design_decisions | Low | Low | Stored design_decisions are unaffected. Skill-slides can detect existing design_decisions and offer to reuse or reconfigure. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add plan workflow to skill-slides [COMPLETED]

**Goal**: Add `workflow_type: "plan"` support to skill-slides SKILL.md so it can ask design questions and delegate to planner-agent.

**Tasks**:
- [ ] Add `plan` to the Workflow Type Routing table in SKILL.md (lines 50-53): preflight status `planning`, success status `planned`, markers `[PLANNING]` -> `[PLANNED]`
- [ ] Update the Note at lines 55-58 to remove the statement that `--design` is handled at command level; replace with documentation that design questions are now part of the plan workflow
- [ ] Add `workflow_type: "plan"` case to Stage 2 preflight (lines 120-129)
- [ ] Add new Stage 3.5 (between postflight marker and delegation): "Design Questions" stage that reads the research report, extracts key messages, and asks D1 (theme), D2 (message ordering), D3 (section emphasis) via AskUserQuestion -- move the exact question text from slides.md STAGE 3 Steps 3.D1-D3
- [ ] Add design_decisions storage step: write `design_decisions` object to state.json on the task entry (same schema as current STAGE 3 Step 4)
- [ ] Add detection for existing design_decisions: if `design_decisions` already exists on the task, ask user "Design decisions already exist. Use existing or reconfigure?"
- [ ] Update Stage 4 delegation context routing table to include: `plan` -> `planner-agent` (target agent), passing `research_path`, `artifact_number`, `roadmap_path` in delegation context
- [ ] Update Stage 5 routing table to include `plan` workflow type -> `planner-agent`
- [ ] Add postflight status mapping for plan workflow in Stage 7: meta_status `planned` -> final status `planned`, TODO marker `[PLANNED]`

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `.claude/skills/skill-slides/SKILL.md` - Add plan workflow type with design question stages, delegation to planner-agent, and postflight status mapping

**Verification**:
- SKILL.md contains `plan` in routing table
- Design questions D1-D3 are present in the skill
- Delegation context for planner-agent includes research_path
- Postflight handles `planned` status

---

### Phase 2: Enable extension routing for slides plan tasks [COMPLETED]

**Goal**: Ensure `/plan N` for slides tasks routes to skill-slides instead of the default skill-planner.

**Tasks**:
- [ ] Investigate how plan.md extension routing resolves in practice: check if manifests at source path (`/home/benjamin/.config/nvim/.claude/extensions/present/manifest.json`) are checked, or only installed paths (`.claude/extensions/*/manifest.json`)
- [ ] Update the present extension manifest at the source location to route `"slides": "skill-slides"` in addition to `"present:slides": "skill-slides"` (update the plan routing block)
- [ ] If plan.md only checks installed paths, install manifest.json to `.claude/extensions/present/manifest.json` and update extensions.json `installed_files` list accordingly
- [ ] Alternatively: if the routing mechanism needs adjustment, update plan.md STAGE 2 extension routing to also check extensions.json routing data (not just manifest files)
- [ ] Verify that task_type `"slides"` (as stored in state.json) matches the routing key

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `/home/benjamin/.config/nvim/.claude/extensions/present/manifest.json` - Update plan routing to include `"slides": "skill-slides"`
- `.claude/commands/plan.md` - If needed, adjust extension routing to find manifests or use extensions.json
- `.claude/extensions.json` - If manifest installation needed, add to installed_files

**Verification**:
- Running the routing logic for a task with `task_type: "slides"` resolves to `skill-slides`
- The present extension manifest contains `"slides": "skill-slides"` in `routing.plan`

---

### Phase 3: Remove --design from slides.md [NOT STARTED]

**Goal**: Remove the `--design` entry point and STAGE 3 from slides.md since design questions are now part of the plan workflow.

**Tasks**:
- [ ] Remove `--design` syntax line from the Syntax section (line 22: `/slides 500 --design`)
- [ ] Remove the `--design` row from the Input Types table (line 31)
- [ ] Remove the `--design` detection block from GATE IN Step 2 (lines 143-146): the `if echo "$ARGUMENTS" | grep -qE '^[0-9]+.*--design'` branch
- [ ] Remove the `If --design:` handler from Step 3 (lines 170-171)
- [ ] Remove the entire STAGE 3: DESIGN CONFIRMATION section (lines 353-478)
- [ ] Update the research success output (lines 341-349): remove the `Next: /slides {N} --design` line; keep only `Next: /plan {N}`
- [ ] Update the Core Command Integration table (line 489): change `/plan N` routing from `skill-planner` to `skill-slides (plan workflow)`
- [ ] Update the recommended workflow in STAGE 1 Step 6 output (lines 302-306): remove any reference to `--design`; the workflow should be: 1. /research N, 2. /plan N, 3. /implement N
- [ ] Update Output Formats section (lines 511-540): remove any `--design` references from success output templates

**Timing**: 30 minutes

**Depends on**: 2

**Files to modify**:
- `.claude/commands/slides.md` - Remove STAGE 3, --design flag detection, --design syntax, and update workflow references

**Verification**:
- No occurrences of `--design` in slides.md
- No STAGE 3 section exists
- Input type detection handles only: task_number, file_path, description
- Recommended workflow output shows /research -> /plan -> /implement (no --design step)

---

### Phase 4: Update documentation and CLAUDE.md references [NOT STARTED]

**Goal**: Update CLAUDE.md command reference tables and present extension documentation to reflect the removal of `--design` and the new plan routing.

**Tasks**:
- [ ] Update `.claude/CLAUDE.md` Present Extension Commands table: remove `/slides 500 --design` syntax
- [ ] Verify the CLAUDE.md Present Extension section's "Language Routing" table is correct (slides plan should route to skill-slides, not skill-planner; but this table shows skill-level routing, not plan.md routing -- verify if this table needs updating)
- [ ] Update `SKILL.md` header comment block to list `planner-agent` as a subagent for `workflow_type=plan`
- [ ] Verify pptx-assembly-agent.md and slidev-assembly-agent.md need no changes (confirm assembly agents' Stage A2/S2 "Resolve Design Decisions" still works -- they read from state.json, which is populated before planning)
- [ ] Grep for any remaining references to `--design` across `.claude/` directory and fix any found

**Timing**: 30 minutes

**Depends on**: 3

**Files to modify**:
- `.claude/CLAUDE.md` - Update Present Extension command table to remove --design syntax
- `.claude/skills/skill-slides/SKILL.md` - Update header subagent comment (line 8) to include planner-agent

**Verification**:
- `grep -r "\-\-design" .claude/` returns no results (except possibly historical references in research reports)
- CLAUDE.md command table shows `/slides N` for research (no --design variant)
- skill-slides SKILL.md header lists planner-agent as a subagent

## Testing & Validation

- [ ] Trace the routing path: for a task with `task_type: "slides"`, verify plan.md extension routing resolves to `skill-slides`
- [ ] Verify skill-slides SKILL.md handles `workflow_type: "plan"` with correct stage sequence: validate -> preflight -> design questions -> store design_decisions -> delegate planner-agent -> postflight
- [ ] Verify design_decisions schema matches what assembly agents expect: `{theme, message_order, section_emphasis, confirmed_at}`
- [ ] Verify no `--design` references remain in slides.md
- [ ] Verify assembly agents' fallback chain is intact: design_decisions.theme -> research report "Recommended Theme" -> `academic-clean` default
- [ ] Confirm slides.md input type detection handles only three cases: description, task_number, file_path

## Artifacts & Outputs

- `specs/048_slides_theme_in_planning/plans/01_slides-theme-planning.md` (this file)
- Modified files:
  - `.claude/skills/skill-slides/SKILL.md`
  - `.claude/commands/slides.md`
  - `/home/benjamin/.config/nvim/.claude/extensions/present/manifest.json`
  - `.claude/commands/plan.md` (if routing adjustment needed)
  - `.claude/CLAUDE.md`
  - `.claude/extensions.json` (if manifest installation needed)

## Rollback/Contingency

All changes are to markdown specification files within `.claude/`. If the refactored flow does not work correctly:
1. Revert the git commit(s) from this task to restore STAGE 3 and `--design` in slides.md
2. Revert skill-slides SKILL.md to remove the plan workflow type
3. Revert manifest.json routing changes
4. No runtime state is affected (state.json task data is unchanged; design_decisions schema is the same)
