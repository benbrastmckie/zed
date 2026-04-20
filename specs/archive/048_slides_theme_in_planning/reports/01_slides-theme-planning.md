# Research Report: Task #48

**Task**: 48 - slides_theme_in_planning
**Started**: 2026-04-12T00:00:00Z
**Completed**: 2026-04-12T00:30:00Z
**Effort**: 1 hour
**Dependencies**: None
**Sources/Inputs**:
- `.claude/commands/slides.md` -- Full /slides command definition (STAGE 3 design confirmation)
- `.claude/skills/skill-slides/SKILL.md` -- Skill routing and workflow dispatch
- `.claude/agents/slides-research-agent.md` -- Research agent definition
- `.claude/agents/pptx-assembly-agent.md` -- PPTX assembly agent, design_decisions consumption
- `.claude/agents/slidev-assembly-agent.md` -- Slidev assembly agent, design_decisions consumption
- `.claude/agents/planner-agent.md` -- General planner agent definition
- `.claude/skills/skill-planner/SKILL.md` -- Planner skill routing and delegation
- `.claude/commands/plan.md` -- /plan command routing
- `specs/state.json` -- Task 29 real-world design_decisions data
**Artifacts**:
- `specs/048_slides_theme_in_planning/reports/01_slides-theme-planning.md` (this file)
**Standards**: report-format.md, artifact-formats.md

## Executive Summary

- The current `/slides N --design` flow (STAGE 3 in slides.md) creates `design_decisions` as a standalone interactive step between research and planning. This is an extra manual invocation the user must remember.
- Assembly agents (pptx-assembly-agent, slidev-assembly-agent) already read `design_decisions.theme` from state.json with a fallback chain (design_decisions -> research report "Recommended Theme" -> default `academic-clean`). This fallback chain should remain unchanged.
- The planner-agent is a generic agent with no slides-specific knowledge. Moving design questions into `/plan` requires either: (a) a slides-specific planning skill wrapper, or (b) injecting design questions into skill-planner before delegation.
- The recommended approach is to create a new `skill-slides-plan` that wraps `skill-planner`, running design questions as a pre-delegation step and storing `design_decisions` in state.json before the planner-agent executes. This keeps the planner-agent generic and follows the existing extension routing pattern.
- Task 29 confirms the real-world flow worked correctly: design_decisions were created via `--design`, stored in state.json, and later consumed by the slidev-assembly-agent.

## Context & Scope

This research analyzes the current `/slides --design` flow and identifies all touchpoints that need modification to move visual theme selection into the `/plan` phase. The goal is to eliminate the separate `--design` invocation by asking design questions interactively during planning, while ensuring assembly agents continue to find `design_decisions` in state.json at implementation time.

### Constraints
- The planner-agent must remain generic (no slides-specific logic)
- Assembly agents' existing fallback chain must continue to work
- The research report must already exist before design questions are asked (theme/message ordering depends on research findings)
- The forcing questions pattern (AskUserQuestion) is already used in STAGE 0 of slides.md

## Findings

### 1. Current design_decisions Flow (Complete Map)

**Creation** -- STAGE 3 of `slides.md` (lines 353-478):
1. User runs `/slides N --design` after research is complete
2. Command validates task status is "researched" or "planned"
3. Command reads the research report to extract key messages and themes
4. Three AskUserQuestion prompts collect: theme (D1), message ordering (D2), section emphasis (D3)
5. Results stored in `state.json` as `design_decisions` object on the task entry:
   ```json
   {
     "theme": "academic-clean",
     "message_order": "1-2-3 (workflow -> rigor -> reproducibility)",
     "section_emphasis": ["results_cox_mice_tipping_point", "reproducibility_provenance"],
     "confirmed_at": "2026-04-11T02:32:57Z"
   }
   ```

**Propagation** -- skill-slides SKILL.md:
- Lines 55-58 document that `--design` is handled at command level, not by the skill
- The skill passes `forcing_data` (including `output_format`) to assembly agents via delegation context
- The skill does NOT explicitly pass `design_decisions` -- assembly agents read them directly from state.json

**Consumption** -- Both assembly agents (Stage A2/S2 "Resolve Design Decisions"):
1. Check `design_decisions.theme` in state.json task metadata
2. Fallback: read "Recommended Theme" from research report
3. Final fallback: default to `academic-clean`

Only `design_decisions.theme` is consumed by assembly agents. The `message_order` and `section_emphasis` fields are implicitly used by the planner when creating the implementation plan (the planner reads state.json task data), but neither the planner-agent nor the assembly agents have explicit code paths for these fields.

### 2. Current /plan Routing for Slides Tasks

The `/plan` command (plan.md, STAGE 2) uses extension routing:
1. Reads `task_type` from state.json (for slides tasks: `"slides"` or `"present"`)
2. Checks extension manifests for plan routing: `jq '.routing.plan[$tt]' manifest.json`
3. The present extension has NO plan routing override (confirmed: `extensions.json` has no `routing` field)
4. Falls through to default `skill-planner`

Therefore, `/plan N` for a slides task currently invokes the generic `skill-planner` -> `planner-agent` chain with no slides-specific behavior.

### 3. Task 29 Real-World Flow Analysis

Task 29 (talk_epi_study_walkthrough) is the only completed slides task. Its flow was:
1. `/slides "description"` -- Created task with forcing_data (STAGE 0+1)
2. `/slides 29` -- Research delegation via skill-slides (STAGE 2)
3. `/slides 29 --design` -- Design confirmation (STAGE 3), stored `design_decisions`
4. `/plan 29` -- Generic planner created plan (plan references "academic-clean" theme from task metadata)
5. `/implement 29` -- Slidev assembly agent read `design_decisions.theme` from state.json

Key observations:
- The design_decisions were created at `2026-04-11T02:32:57Z` (separate step)
- The plan (02_talk-assembly.md) references "academic-clean theme" showing the planner DID read task metadata
- The assembly agent correctly resolved the theme from design_decisions
- `message_order` and `section_emphasis` influenced the plan indirectly (planner read all task metadata)

### 4. Planner Agent Extensibility

The planner-agent (planner-agent.md) is fully generic:
- Receives delegation context with `task_context`, `research_path`, `prior_plan_path`, `roadmap_path`
- Reads task description and research findings
- Has no mechanism for interactive questions (no AskUserQuestion in its allowed tools)
- Cannot ask design questions itself

The skill-planner (SKILL.md) is a thin wrapper:
- Validates input, does preflight status update, spawns planner-agent, does postflight
- Has `AskUserQuestion` in its parent command but NOT in its own allowed-tools
- The command layer (plan.md) has `allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read, Edit` -- no AskUserQuestion

This means design questions cannot be asked by the planner-agent or skill-planner. They must be asked either:
- At the command layer (/plan or /slides)
- By a new slides-specific planning skill that runs before delegating to skill-planner

### 5. Architecture Options

**Option A: Inject design questions into plan.md command**
- Add slides-specific logic to the generic /plan command
- Pro: Minimal new files
- Con: Pollutes generic command with extension-specific logic; violates separation of concerns

**Option B: Create skill-slides-plan as pre-planner wrapper**
- New skill that: (1) asks design questions, (2) stores design_decisions, (3) delegates to skill-planner
- Pro: Follows extension routing pattern; keeps planner-agent generic; matches how skill-slides wraps research
- Con: One more skill file to maintain

**Option C: Modify skill-slides to handle planning workflow**
- Add `workflow_type: "plan"` to existing skill-slides routing
- Pro: Reuses existing skill; consistent with how skill-slides already routes research and assembly
- Con: skill-slides would need AskUserQuestion in its allowed-tools; grows the skill's scope

**Option D: Add design questions to skill-planner with task-type detection**
- skill-planner checks if task_type is "slides" and asks design questions before spawning planner-agent
- Pro: No new files; contained change
- Con: Breaks the "thin wrapper" principle; adds task-type-specific logic to a generic skill

### Recommended Approach: Option C (Modify skill-slides)

Option C is the best fit because:
1. skill-slides already handles two workflow types (slides_research, assemble). Adding a third (plan) is natural.
2. The present extension already owns the slides workflow end-to-end. Planning is the missing piece.
3. skill-slides already has access to task metadata (forcing_data, design_decisions) and understands the slides domain.
4. The `/plan` command already supports extension routing -- adding `"plan": "skill-slides"` to the present extension's routing would activate it.
5. After asking design questions and storing design_decisions, skill-slides can delegate to skill-planner (or directly to planner-agent) for the actual plan creation.

Implementation sketch:
```
/plan N (slides task)
  -> plan.md extension routing finds "skill-slides" for plan
  -> skill-slides receives workflow_type="plan"
  -> Stage: Read research report, extract key messages
  -> Stage: Ask design questions (D1-D3) via AskUserQuestion
  -> Stage: Store design_decisions in state.json
  -> Stage: Delegate to planner-agent (passing research + design_decisions in context)
  -> Stage: Postflight (status update, artifact linking, git commit)
```

### 6. Changes Required (All Touchpoints)

**File: `.claude/extensions.json`**
- Add routing configuration for present extension: `"routing": {"plan": {"slides": "skill-slides"}}`
- Or: add a manifest.json for the present extension with this routing

**File: `.claude/skills/skill-slides/SKILL.md`**
- Add `workflow_type: "plan"` to routing table
- Add plan preflight status (planning) and success status (planned)
- Add design questions stage (move D1-D3 from slides.md STAGE 3)
- Add delegation to planner-agent (or skill-planner) after design questions
- Ensure AskUserQuestion is in allowed-tools (already listed in the skill header)

**File: `.claude/commands/slides.md`**
- Remove STAGE 3: DESIGN CONFIRMATION entirely
- Remove `--design` from input type detection (GATE IN Step 2)
- Remove `--design` from syntax documentation
- Update recommended workflow output to remove the `/slides N --design` step
- Update the "Core Command Integration" table to show `/plan N` routes to skill-slides

**File: `.claude/agents/planner-agent.md`** (minimal or no change)
- No change needed if skill-slides delegates to planner-agent directly
- The planner-agent already reads all task metadata from state.json, so design_decisions will be available

**File: `.claude/agents/pptx-assembly-agent.md`** (no change)
- Already reads `design_decisions.theme` from state.json with fallback chain
- No modification needed

**File: `.claude/agents/slidev-assembly-agent.md`** (no change)
- Already reads `design_decisions.theme` from state.json with fallback chain
- No modification needed

**File: `.claude/commands/plan.md`** (minimal change)
- The extension routing logic already exists; it just needs the present extension to declare routing
- No code changes to plan.md itself

**File: `specs/state.json`** (runtime, no code change)
- design_decisions will be stored before the plan is created, not after research
- Same JSON structure, same location on the task object

### 7. Design Question Timing Consideration

The design questions depend on the research report (theme recommendation, key messages for ordering, sections for emphasis). The research report MUST exist before design questions can be asked. This is naturally guaranteed because:
- `/plan N` requires the task to be in "researched" status (or later)
- Research report exists by the time `/plan` runs
- skill-slides can read the research report before asking design questions

If the user skips `/slides N --design` and goes directly to `/plan N`, the design questions will be asked during planning. If the user already ran `--design` (legacy flow or re-confirmation), the existing design_decisions can be detected and the user can be asked "Design decisions already exist. Use existing or reconfigure?"

## Decisions

1. **Option C selected**: Modify skill-slides to handle `workflow_type: "plan"` rather than creating a new skill or modifying generic planner components.
2. **Remove --design flag**: The separate design confirmation step becomes unnecessary once design questions are integrated into planning.
3. **Preserve assembly agent fallback chains**: No changes to pptx-assembly-agent or slidev-assembly-agent.
4. **Extension routing**: Use the existing plan.md extension routing mechanism to route slides tasks to skill-slides.

## Recommendations

1. **Phase 1**: Add `workflow_type: "plan"` support to skill-slides SKILL.md with design question stages
2. **Phase 2**: Add extension routing for present/slides plan to enable `/plan N` dispatch
3. **Phase 3**: Remove STAGE 3 and `--design` flag from slides.md command
4. **Phase 4**: Update documentation (recommended workflow output, CLAUDE.md command reference)
5. **Phase 5**: Verify end-to-end by tracing the flow for a hypothetical new slides task

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing slides tasks that used --design | Medium | Low | design_decisions in state.json are already stored; removal of --design doesn't affect stored data |
| skill-slides growing too complex with three workflow types | Low | Medium | Each workflow type is self-contained; clear stage separation |
| Extension routing not picking up skill-slides for plan | High | Low | Verified plan.md extension routing logic exists and is tested |
| Planner-agent missing design_decisions if skill-slides stores them after delegation | High | Low | Store design_decisions BEFORE delegating to planner-agent |

## Appendix

### Search Queries Used
- Grep for `design_decisions` across `.claude/` directory
- Read of all six primary files listed in Sources/Inputs
- Task 29 state.json data for real-world validation

### Key File Locations
- `/home/benjamin/.config/zed/.claude/commands/slides.md` -- STAGE 3 to remove (lines 353-478)
- `/home/benjamin/.config/zed/.claude/skills/skill-slides/SKILL.md` -- Add workflow_type=plan routing
- `/home/benjamin/.config/zed/.claude/commands/plan.md` -- Extension routing logic (lines 312-342)
- `/home/benjamin/.config/zed/.claude/extensions.json` -- Present extension config (needs routing field)

### design_decisions Schema (from task 29)
```json
{
  "theme": "academic-clean",
  "message_order": "1-2-3 (workflow -> rigor -> reproducibility)",
  "section_emphasis": [
    "results_cox_mice_tipping_point",
    "reproducibility_provenance",
    "tooling_epi_workflow",
    "methods_consort"
  ],
  "confirmed_at": "2026-04-11T02:32:57Z",
  "based_on_report": "specs/029_talk_epi_study_walkthrough/reports/02_talk-research.md",
  "session_id": "sess_1760000029_d1"
}
```
