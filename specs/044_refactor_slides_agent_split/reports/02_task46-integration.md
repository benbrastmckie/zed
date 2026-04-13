# Research Report: Task #44 (Round 2 - Task 46 Integration Analysis)

**Task**: 44 - Refactor slides system: split slides-agent into three focused agents
**Started**: 2026-04-12T00:00:00Z
**Completed**: 2026-04-12T00:20:00Z
**Effort**: Small (analysis only, no new file exploration needed)
**Dependencies**: Task 46 (candidate for absorption)
**Sources/Inputs**:
- `specs/044_refactor_slides_agent_split/reports/01_slides-agent-split.md` (round 1 report)
- `specs/046_enrich_slides_task_description/reports/01_enrich-slides-description.md` (task 46 report)
- `.claude/commands/slides.md` (497 lines -- the shared target file)
- `.claude/skills/skill-slides/SKILL.md` (routing skill)
**Artifacts**:
- `specs/044_refactor_slides_agent_split/reports/02_task46-integration.md`
**Standards**: report-format.md, artifact-management.md

## Executive Summary

- Task 46 targets a single file (`slides.md` Stage 1, Steps 2-4) that task 44 also touches, making them share a modification surface
- Task 46's changes are small and self-contained: add a Step 2.5 (description enrichment) and update Steps 3-4 to use the enriched string -- approximately 20-30 lines of new content in slides.md
- Task 44's scope for slides.md is listed as "VERIFY -- likely no change needed" in the round 1 report (item #12 in the file list), but task 46 upgrades this to a definite modification
- Integration is a natural fit: task 46 adds a step to the command file that task 44 is already modifying as part of the broader refactor; no architectural conflict exists
- Recommended approach: absorb task 46 as an additional sub-phase within one of task 44's implementation phases, specifically the phase that handles slides.md and documentation updates

## Context & Scope

Task 44 splits the monolithic slides-agent into three focused agents and updates routing, context index, extensions.json, and CLAUDE.md. Task 46 enriches the /slides command's task creation to include source material paths and forcing data in the description field. This round-2 report analyzes whether task 46 should be folded into task 44's implementation plan.

## Findings

### 1. File Overlap Analysis

| File | Task 44 Action | Task 46 Action | Overlap |
|------|---------------|---------------|---------|
| `.claude/commands/slides.md` | Verify/minor update (routing references) | Modify Stage 1 Steps 2-4 | **Direct overlap** |
| `.claude/skills/skill-slides/SKILL.md` | Modify (three-way dispatch) | No change | None |
| `.claude/agents/slides-agent.md` | Delete (replace with 3 agents) | No change | None |
| `.claude/agents/slides-research-agent.md` | Create | No change | None |
| `.claude/agents/pptx-assembly-agent.md` | Create | No change | None |
| `.claude/agents/slidev-assembly-agent.md` | Create | No change | None |
| `.claude/extensions.json` | Modify (installed_files) | No change | None |
| `.claude/context/index.json` | Modify (agent references) | No change | None |
| `.claude/CLAUDE.md` | Modify (skill-to-agent table) | No change | None |
| `specs/state.json` | No change | No change (format preserved) | None |
| `specs/TODO.md` | No change | No change (format preserved) | None |

**Summary**: Only `slides.md` is touched by both tasks. The overlap is in the same file but different sections -- task 44 would touch the routing/delegation references while task 46 modifies Stage 1 task creation logic. There is no conflicting edit.

### 2. Integration Feasibility

**Why integration works well**:

1. **Non-conflicting edits**: Task 44's changes to slides.md are about verifying/updating agent name references in Stages 2-3 (research delegation and core command integration). Task 46's changes are in Stage 1 (task creation). These are different sections of the file.

2. **Single-pass editing**: If implementing task 44 already requires opening and editing slides.md, adding the task 46 enrichment step is incremental work in the same editing session.

3. **No dependency ordering issue**: Task 46's description enrichment happens at task creation time (Stage 0 + Stage 1) -- before any agent is invoked. Task 44's agent split affects what happens when `/research N` or `/implement N` is called. These are temporally independent in the user workflow.

4. **Scope is small**: Task 46 adds approximately 20-30 lines to slides.md (a new Step 2.5 plus minor modifications to Steps 3-4). This is well within the scope of a single implementation phase.

### 3. Dependency Ordering

Task 46's changes to Stage 1 are **order-independent** relative to task 44's changes:

- Task 44 does not restructure Stage 0 or Stage 1 of slides.md. It primarily affects Stage 2 (research delegation) by updating which agent name is referenced, and the Core Command Integration table.
- Task 46 only modifies Stage 1 Steps 2-4.
- Neither task adds or removes stages that the other depends on.

Therefore, task 46's edits can happen **during** task 44 implementation -- in the same phase that handles slides.md verification, or as a separate small phase. The order does not matter.

### 4. Concrete Integration Plan

**Recommended approach**: Add a sub-step to whichever task 44 phase handles "slides.md verification" (round 1 report item #12).

Specific edits to absorb from task 46:

#### Edit 1: Add Step 2.5 to Stage 1 (between current Steps 2 and 3)

Insert after line ~196 (after "Max 50 characters" in Step 2):

```markdown
### Step 2.5: Enrich Description

Construct an enriched description incorporating forcing data:

1. Start with the base description:
   - If `input_type="description"`: use the user's original text
   - If `input_type="file_path"`: synthesize from file content and audience_context

2. Append structured details:
   - Talk type and output format: "({talk_type} talk, {output_format} format)"
   - Source materials with relative paths (strip repository root)
   - Audience context summary (first sentence or key phrase, ~20 words max)

3. The enriched description replaces `$desc` for both state.json and TODO.md.

**Path relativization**: Detect the git repository root (`git rev-parse --show-toplevel`)
and strip it from absolute paths. Fall back to basename for paths outside the repo.

**Target format**:
```
{base_description}. {talk_type} talk ({duration}), {output_format} output.
Source: {relative_paths}. Audience: {audience_summary}.
```
```

#### Edit 2: Update Step 3 (state.json)

Change `--arg desc "$description"` to `--arg desc "$enriched_description"` in the jq command.

#### Edit 3: Update Step 4 (TODO.md)

Ensure the `**Description**: {description}` block uses the enriched description variable.

#### Edit 4: Handle file_path input

When `input_type="file_path"`, construct the base description from the file's first heading and audience context before enrichment.

### 5. Updated File Modification List for Task 44

Incorporating task 46, the round 1 report's file list changes:

| # | File | Action | Details |
|---|------|--------|---------|
| 1 | `.claude/agents/slides-agent.md` | DELETE | Replaced by 3 new agents |
| 2 | `.claude/agents/slides-research-agent.md` | CREATE | Research workflow |
| 3 | `.claude/agents/pptx-assembly-agent.md` | CREATE | PPTX assembly |
| 4 | `.claude/agents/slidev-assembly-agent.md` | CREATE | Slidev assembly |
| 5 | `.claude/skills/skill-slides/SKILL.md` | MODIFY | Three-way agent dispatch |
| 6 | `.claude/extensions.json` | MODIFY | Update installed_files |
| 7 | `.claude/context/index.json` | MODIFY | Update agent references |
| 8 | `.claude/CLAUDE.md` | MODIFY | Update skill-to-agent table |
| 9 | `.claude/context/project/present/talk/templates/pptx-project/README.md` | MODIFY | Agent name references |
| 10 | `.claude/context/project/present/talk/patterns/pptx-generation.md` | MODIFY | Agent name reference |
| **11** | **`.claude/commands/slides.md`** | **MODIFY** | **Add Step 2.5 (description enrichment), update Steps 3-4 + verify routing refs** |

Item #12 from round 1 (slides.md -- "VERIFY") is now upgraded to item #11 (slides.md -- "MODIFY") with specific edits.

## Decisions

1. **Absorb task 46 into task 44**: The overlap is clean, the scope is small, and executing them separately would require editing the same file twice.

2. **Implementation phase placement**: Add the description enrichment as part of the "documentation and command updates" phase of task 44's implementation plan -- the phase that handles CLAUDE.md, slides.md, and other documentation files.

3. **Task 46 disposition**: After task 44 absorbs task 46's scope, mark task 46 as ABANDONED with a note that its scope was merged into task 44.

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Scope creep from absorption | Low | Low | Task 46 is 4 small edits to one file, well-defined and self-contained |
| Description enrichment complexity for file_path input | Medium | Low | Start with simple "first heading + forcing data" approach; can iterate |
| Path relativization edge cases | Low | Low | Fall back to basename for non-repo paths |

## Appendix

### Task 46 Scope Summary (from its research report)

- **Problem**: `/slides` stores forcing data in state.json but uses only raw `$desc` for description
- **Solution**: Add Step 2.5 to Stage 1 that constructs enriched description from base + forcing_data
- **Files**: Only `slides.md` (Stage 1 Steps 2-4)
- **Effort**: ~30 lines of new content in slides.md

### Cross-Reference

- Round 1 report: `specs/044_refactor_slides_agent_split/reports/01_slides-agent-split.md`
- Task 46 report: `specs/046_enrich_slides_task_description/reports/01_enrich-slides-description.md`
- Target command file: `.claude/commands/slides.md` (497 lines)
