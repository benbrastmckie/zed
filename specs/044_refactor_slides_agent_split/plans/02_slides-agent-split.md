# Implementation Plan: Refactor slides-agent into three focused agents

- **Task**: 44 - Refactor slides system: split slides-agent into three focused agents
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_slides-agent-split.md, reports/02_task46-integration.md
- **Artifacts**: plans/02_slides-agent-split.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - plan-format.md
  - status-markers.md
  - artifact-management.md
  - tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The current `slides-agent.md` (554 lines) combines two distinct workflows -- format-agnostic content research (Stages 0-8) and PPTX-specific assembly (Stages A1-A8) -- into a single monolithic agent. This wastes context budget because each invocation loads all context regardless of which workflow runs. The plan splits this agent into three focused agents (slides-research-agent, pptx-assembly-agent, slidev-assembly-agent), updates all routing and documentation, and integrates task 46's description enrichment into the `/slides` command. Definition of done: the three new agents exist, skill-slides dispatches correctly, slides-agent.md is deleted, all references are updated, and task 46's changes are absorbed.

### Research Integration

Two research reports inform this plan:

1. **01_slides-agent-split.md** (Round 1): Full analysis of the current slides-agent structure, stage mapping, context reference audit, file modification list, and proposed agent-to-stage mappings. Key findings: zero context overlap between research and assembly workflows; skill already branches on workflow_type; 10 files need modification.

2. **02_task46-integration.md** (Round 2): Analysis of absorbing task 46 (enrich /slides task description). Key findings: only `slides.md` overlaps between tasks 44 and 46; changes are in different sections (Stage 1 vs Stages 2-3); approximately 20-30 lines of new content; no dependency ordering conflict.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items defined yet.

## Goals & Non-Goals

**Goals**:
- Split slides-agent.md into slides-research-agent.md (~200 lines), pptx-assembly-agent.md (~250 lines), and slidev-assembly-agent.md (~250 lines)
- Reduce per-invocation context loading by 40-60% by having each agent load only its required context
- Update skill-slides routing to dispatch to the correct agent based on workflow_type and output_format
- Update all references in extensions.json, context/index.json, CLAUDE.md, and related documentation
- Absorb task 46: add Step 2.5 (description enrichment) to slides.md Stage 1
- Create a functional slidev-assembly-agent (replacing the current "not yet implemented" stub)
- Preserve all existing slides_research and assemble_pptx functionality exactly

**Non-Goals**:
- Redesigning the talk pattern library or content templates
- Adding new talk modes or slide types
- Changing the skill-slides postflight pattern or command lifecycle
- Modifying the `/slides` forcing questions (Stage 0)
- Optimizing the pptx-generation.md reference document itself

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Slidev assembly agent is new functionality, not just a refactor | M | H | Start with skeleton matching PPTX assembly structure; reference existing Slidev templates and components already in talk library |
| Extension source directory sync -- changes must update both installed and source paths | L | M | Verify extensions.json `source_dir` field; update `installed_files` array only (source extension in nvim repo is separate) |
| Context index entry edits may break other agents' context loading | M | L | Only replace `slides-agent` strings with new agent names; verify no collateral edits to other agent arrays |
| Skill-slides routing change introduces dispatch bugs | M | L | The skill already branches on workflow_type; adding output_format branching is a small, testable delta |
| Task 46 description enrichment interacts with file_path input edge cases | L | M | Implement simple "first heading + forcing data" approach; fall back to basename for non-repo paths |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 2, 3, 4 |
| 4 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Create the three new agent files [COMPLETED]

**Goal**: Extract research and PPTX assembly workflows from slides-agent.md into two new agents, and create a new slidev-assembly-agent, without deleting the original yet.

**Tasks**:
- [ ] Create `.claude/agents/slides-research-agent.md` with frontmatter (`name: slides-research-agent`, `model: opus`), overview, agent metadata, allowed tools, context references (research-only: presentation-types.md, talk-structure.md, talk/index.json, patterns/{mode}.json, contents/), and execution flow (Stages 0-8 from current agent, adapted with agent_type "slides-research-agent" and delegation_path updated)
- [ ] Create `.claude/agents/pptx-assembly-agent.md` with frontmatter (`name: pptx-assembly-agent`, `model: opus`), overview, agent metadata, allowed tools, context references (assembly-only: pptx-generation.md, theme_mappings.json, generate_deck.py), and execution flow (Stages 0, 1, A1-A8 from current agent, adapted with agent_type "pptx-assembly-agent")
- [ ] Create `.claude/agents/slidev-assembly-agent.md` with frontmatter (`name: slidev-assembly-agent`, `model: opus`), overview, agent metadata, allowed tools, context references (Slidev-only: slidev-pitfalls.md, slidev-project/README.md, contents/, components/, themes/), and execution flow (Stages 0, 1, S1-S8 implementing Slidev markdown generation from research report using content templates and project scaffold)
- [ ] Ensure each agent has its own error handling and critical requirements sections tailored to its workflow
- [ ] Verify no cross-workflow context references leak into the wrong agent

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `.claude/agents/slides-research-agent.md` - CREATE (~200 lines)
- `.claude/agents/pptx-assembly-agent.md` - CREATE (~250 lines)
- `.claude/agents/slidev-assembly-agent.md` - CREATE (~250 lines)

**Verification**:
- Each agent file has valid frontmatter with `name` and `model` fields
- slides-research-agent references only research context (no pptx-generation.md, no slidev-pitfalls.md)
- pptx-assembly-agent references only PPTX context (no talk-structure.md, no slidev templates)
- slidev-assembly-agent references only Slidev context (no pptx-generation.md)
- All three agents have Stage 0 early metadata, delegation context parsing, error handling, and critical requirements

---

### Phase 2: Update skill-slides routing [COMPLETED]

**Goal**: Modify skill-slides to dispatch to the correct agent based on workflow_type and output_format, replacing the single slides-agent dispatch.

**Tasks**:
- [ ] Update SKILL.md description and overview to reference three agents instead of one
- [ ] Modify Stage 5 (Invoke Subagent) to implement three-way routing:
  - `workflow_type=slides_research` -> `slides-research-agent`
  - `workflow_type=assemble` + `output_format=pptx` -> `pptx-assembly-agent`
  - `workflow_type=assemble` + `output_format=slidev` -> `slidev-assembly-agent`
- [ ] Update the delegation_path in Stage 4 delegation context to use the specific agent name
- [ ] Update Stage 9 git commit message to include the correct agent name reference
- [ ] Update the frontmatter comment block listing subagent context and tools

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `.claude/skills/skill-slides/SKILL.md` - MODIFY (routing logic in Stages 4-5)

**Verification**:
- SKILL.md Stage 5 dispatches to three different agent names based on workflow_type + output_format
- No remaining references to `slides-agent` (as a single agent name) in SKILL.md
- Delegation context in Stage 4 uses the resolved agent name

---

### Phase 3: Update context index and extensions.json [COMPLETED]

**Goal**: Update all context/index.json entries and extensions.json installed_files to reference the new agent names instead of slides-agent.

**Tasks**:
- [ ] In `.claude/context/index.json`, replace agent references:
  - `presentation-types.md`: `["slides-agent"]` -> `["slides-research-agent"]`
  - `talk-structure.md`: `["slides-agent"]` -> `["slides-research-agent"]`
  - `slidev-pitfalls.md`: `["slides-agent", ...]` -> `["slidev-assembly-agent", ...]`
  - `slidev-project/README.md`: `["slides-agent", ...]` -> `["slidev-assembly-agent", ...]`
- [ ] Add new context/index.json entries for PPTX assembly context:
  - `project/present/talk/patterns/pptx-generation.md` -> agents: `["pptx-assembly-agent"]`
  - `project/present/talk/templates/pptx-project/theme_mappings.json` -> agents: `["pptx-assembly-agent"]`
  - `project/present/talk/templates/pptx-project/generate_deck.py` -> agents: `["pptx-assembly-agent"]`
  - `project/present/talk/templates/pptx-project/README.md` -> agents: `["pptx-assembly-agent"]`
  - `project/present/talk/index.json` -> agents: `["slides-research-agent"]`
- [ ] In `.claude/extensions.json`, update the present extension's `installed_files`:
  - Replace `".claude/agents/slides-agent.md"` with three entries: `".claude/agents/slides-research-agent.md"`, `".claude/agents/pptx-assembly-agent.md"`, `".claude/agents/slidev-assembly-agent.md"`

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `.claude/context/index.json` - MODIFY (update 4 existing entries, add 5 new entries)
- `.claude/extensions.json` - MODIFY (update installed_files array)

**Verification**:
- `grep -c "slides-agent" .claude/context/index.json` returns 0 (no remaining references to old agent name)
- `jq '.extensions[] | select(.installed_files | any(test("slides-agent.md")))' .claude/extensions.json` returns empty
- New PPTX context entries exist with `pptx-assembly-agent` in agents array
- talk/index.json entry exists with `slides-research-agent` in agents array

---

### Phase 4: Update slides.md command and absorb task 46 [COMPLETED]

**Goal**: Update the `/slides` command file to reference new agent names where applicable, and add the description enrichment step from task 46.

**Tasks**:
- [ ] Verify and update any references to `slides-agent` in slides.md (Stage 2 research delegation, Core Command Integration table) to use the appropriate new agent names
- [ ] Add Step 2.5 (Enrich Description) to Stage 1, between current Steps 2 and 3:
  - Construct enriched description from base description + forcing data
  - Include talk type, output format, source material relative paths, audience context summary
  - Handle both `input_type="description"` and `input_type="file_path"` cases
  - Relativize paths using `git rev-parse --show-toplevel`
  - Target format: `{base_description}. {talk_type} talk ({duration}), {output_format} output. Source: {relative_paths}. Audience: {audience_summary}.`
- [ ] Update Step 3 (state.json write) to use the enriched description variable
- [ ] Update Step 4 (TODO.md write) to use the enriched description in the description block

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `.claude/commands/slides.md` - MODIFY (add Step 2.5, update Steps 3-4, verify agent name refs)

**Verification**:
- No remaining references to `slides-agent` as an agent name in slides.md
- Step 2.5 exists with description enrichment logic
- Steps 3 and 4 reference the enriched description variable
- Both input_type cases (description, file_path) are handled in Step 2.5

---

### Phase 5: Update documentation and delete old agent [NOT STARTED]

**Goal**: Update CLAUDE.md skill-to-agent documentation, update any remaining references in PPTX documentation files, and delete the original slides-agent.md.

**Tasks**:
- [ ] In `.claude/CLAUDE.md`, update the Present Extension skill-to-agent table:
  - Replace single `skill-slides | slides-agent | opus | Research talk material synthesis and presentation assembly` row with three rows:
    - `skill-slides | slides-research-agent | opus | Research talk material synthesis`
    - `skill-slides | pptx-assembly-agent | opus | PowerPoint presentation assembly`
    - `skill-slides | slidev-assembly-agent | opus | Slidev presentation assembly`
- [ ] Update `.claude/context/project/present/talk/templates/pptx-project/README.md` to reference `pptx-assembly-agent` instead of `slides-agent`
- [ ] Update `.claude/context/project/present/talk/patterns/pptx-generation.md` to reference `pptx-assembly-agent` instead of `slides-agent` (line 3 reference)
- [ ] Delete `.claude/agents/slides-agent.md`

**Timing**: 30 minutes

**Depends on**: 2, 3, 4

**Files to modify**:
- `.claude/CLAUDE.md` - MODIFY (skill-to-agent table in Present Extension section)
- `.claude/context/project/present/talk/templates/pptx-project/README.md` - MODIFY (agent name reference)
- `.claude/context/project/present/talk/patterns/pptx-generation.md` - MODIFY (agent name reference)
- `.claude/agents/slides-agent.md` - DELETE

**Verification**:
- `grep -r "slides-agent" .claude/` returns no hits (excluding git history)
- CLAUDE.md shows three separate agent rows under Present Extension
- `ls .claude/agents/slides-agent.md` returns "No such file"
- `ls .claude/agents/slides-research-agent.md .claude/agents/pptx-assembly-agent.md .claude/agents/slidev-assembly-agent.md` all exist

---

### Phase 6: End-to-end validation and task 46 cleanup [NOT STARTED]

**Goal**: Run a comprehensive grep to ensure no stale references remain, verify the three new agents are well-formed, and mark task 46 as abandoned (absorbed into task 44).

**Tasks**:
- [ ] Run `grep -r "slides-agent" .claude/` and confirm zero matches (the old agent name should not appear anywhere)
- [ ] Run `grep -r "slides-agent" specs/` to ensure no spec artifacts reference the old name (research reports are historical, so they are acceptable)
- [ ] Verify each new agent file has: valid frontmatter (name, model), Context References section, Execution Flow with Stage 0, Error Handling section, Critical Requirements section
- [ ] Verify context/index.json is valid JSON: `jq empty .claude/context/index.json`
- [ ] Verify extensions.json is valid JSON: `jq empty .claude/extensions.json`
- [ ] Verify skill-slides SKILL.md references all three new agents in the routing table
- [ ] Mark task 46 as ABANDONED in state.json and TODO.md with note "Scope absorbed into task 44"

**Timing**: 30 minutes

**Depends on**: 5

**Files to modify**:
- `specs/state.json` - MODIFY (mark task 46 as abandoned)
- `specs/TODO.md` - MODIFY (mark task 46 as abandoned)

**Verification**:
- Zero stale `slides-agent` references in `.claude/` directory
- All JSON files pass `jq empty` validation
- Task 46 shows `[ABANDONED]` status in both state.json and TODO.md
- Three new agent files exist and have complete structure

## Testing & Validation

- [ ] `grep -rn "slides-agent" .claude/` returns zero matches (no stale references)
- [ ] `jq empty .claude/context/index.json` succeeds (valid JSON)
- [ ] `jq empty .claude/extensions.json` succeeds (valid JSON)
- [ ] Each of the three new agent files has frontmatter with `name:` and `model: opus`
- [ ] `slides-research-agent.md` does not reference `pptx-generation.md` or `slidev-pitfalls.md`
- [ ] `pptx-assembly-agent.md` does not reference `talk-structure.md` or `slidev-project/`
- [ ] `slidev-assembly-agent.md` does not reference `pptx-generation.md`
- [ ] skill-slides SKILL.md Stage 5 contains routing logic for all three agents
- [ ] slides.md contains Step 2.5 (description enrichment) with both input_type paths
- [ ] CLAUDE.md Present Extension table shows three agent rows for skill-slides

## Artifacts & Outputs

- `plans/02_slides-agent-split.md` - This implementation plan
- `.claude/agents/slides-research-agent.md` - New research workflow agent
- `.claude/agents/pptx-assembly-agent.md` - New PPTX assembly agent
- `.claude/agents/slidev-assembly-agent.md` - New Slidev assembly agent
- `.claude/agents/slides-agent.md` - DELETED (replaced by above three)
- `.claude/skills/skill-slides/SKILL.md` - Updated routing
- `.claude/commands/slides.md` - Updated with description enrichment (task 46)
- `.claude/context/index.json` - Updated agent references
- `.claude/extensions.json` - Updated installed_files
- `.claude/CLAUDE.md` - Updated skill-to-agent documentation

## Rollback/Contingency

If the refactor introduces issues:
1. The original `slides-agent.md` is preserved in git history and can be restored with `git checkout HEAD~1 -- .claude/agents/slides-agent.md`
2. Revert skill-slides routing by restoring the single-agent dispatch pattern
3. Revert context/index.json and extensions.json agent name changes
4. The task 46 description enrichment in slides.md is independent and can remain even if the agent split is reverted
