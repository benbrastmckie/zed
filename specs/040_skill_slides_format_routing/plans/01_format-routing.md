# Implementation Plan: Task #40

- **Task**: 40 - Update skill-slides for format-specific assembly routing
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: Task 39 (slides-agent PPTX assembly workflow)
- **Research Inputs**: specs/040_skill_slides_format_routing/reports/01_format-routing.md
- **Artifacts**: plans/01_format-routing.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: true

## Overview

This plan bridges the gap between the output_format forcing question (task 37) and the slides-agent PPTX assembly workflow (task 39). The skill-slides SKILL.md must read `output_format` from `forcing_data`, pass it to the slides-agent delegation context, adjust commit messages and return summaries based on format, and the present extension manifest must add the `:assemble` routing suffix for the implement path. The changes are small and well-scoped across two files.

### Research Integration

Key findings from the research report:
- `forcing_data.output_format` already flows through to the agent via the forcing_data passthrough, but the skill does not inspect or document it
- The slides-agent (task 39) already branches at Stage 1c based on `workflow_type` and `output_format`
- The present manifest routing for slides implement is `"skill-slides"` without the `:assemble` suffix (unlike grant which uses `"skill-grant:assemble"`)
- Commit messages and return summaries are currently format-agnostic (Slidev-hardcoded)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items are currently defined. This task is part of the PPTX assembly feature chain (tasks 37-40).

## Goals & Non-Goals

**Goals**:
- Add `output_format` extraction and routing in skill-slides SKILL.md
- Update commit messages to reflect chosen format (PPTX vs Slidev)
- Update return summaries to show format-appropriate file lists
- Add `:assemble` suffix to manifest implement routing for slides
- Maintain backward compatibility (default to Slidev when `output_format` absent)

**Non-Goals**:
- Implementing the actual Slidev assembly workflow (future task)
- Modifying the slides-agent branching logic (already done in task 39)
- Changing the `/slides` command forcing questions (already done in task 37)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Manifest is sourced from nvim, changes need propagation | M | M | Update source manifest in nvim; verify zed copy matches |
| Implement command may not parse `:assemble` suffix for slides | H | L | Grant already uses this pattern successfully; verify before changing |
| Breaking existing research workflow | H | L | Only modify assemble-related code paths; research path unchanged |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Update skill-slides SKILL.md with format-aware routing [COMPLETED]

**Goal**: Add output_format extraction, format-specific commit messages, and format-specific return summaries to the skill.

**Tasks**:
- [ ] Add `output_format` extraction from `forcing_data` at Stage 2 (Preflight), defaulting to `"slidev"` when absent
- [ ] Document `output_format` in the Stage 4 delegation context JSON, showing it flows through forcing_data
- [ ] Update Stage 9 commit message: `assemble` case should branch on `output_format` to produce `"assemble PPTX presentation"` or `"assemble Slidev presentation"`
- [ ] Update Stage 11 Assemble Success return summary: PPTX variant lists `.pptx` and `generate_deck.py`; Slidev variant lists `slides.md`, `style.css`, `README.md`

**Timing**: 0.75 hours

**Depends on**: none

**Files to modify**:
- `.claude/skills/skill-slides/SKILL.md` - Add format-aware routing at Stages 2, 4, 9, 11

**Verification**:
- Stage 2 extracts `output_format` with `"slidev"` default
- Stage 9 commit message branches on format
- Stage 11 return summary shows format-appropriate file lists
- Research workflow (slides_research) is unchanged

---

### Phase 2: Update present extension manifest routing [COMPLETED]

**Goal**: Add `:assemble` suffix to the slides implement routing in the present extension manifest, matching the grant pattern.

**Tasks**:
- [ ] Update nvim source manifest (`/home/benjamin/.config/nvim/.claude/extensions/present/manifest.json`): change `"present:slides": "skill-slides"` to `"skill-slides:assemble"` in the `routing.implement` section
- [ ] Verify the zed copy of the manifest matches (or will be propagated by the extension loader)

**Timing**: 0.25 hours

**Depends on**: none

**Files to modify**:
- `/home/benjamin/.config/nvim/.claude/extensions/present/manifest.json` - Update implement routing for slides

**Verification**:
- `routing.implement["present:slides"]` equals `"skill-slides:assemble"`
- Grant routing pattern (`"skill-grant:assemble"`) is unchanged
- Research routing for slides is unchanged

---

### Phase 3: Integration verification and documentation alignment [IN PROGRESS]

**Goal**: Verify the full routing chain works end-to-end and update any documentation that references the old routing.

**Tasks**:
- [ ] Verify implement command parses `skill-slides:assemble` correctly by tracing the routing logic (same pattern as grant)
- [ ] Check that the merged extensions.json or zed-side manifest reflects the updated routing
- [ ] Verify skill-slides `workflow_type` defaults correctly: `slides_research` when invoked from `/slides N` or `/research`, `assemble` when invoked from `/implement`
- [ ] Review CLAUDE.md present extension section for any routing table updates needed

**Timing**: 0.5 hours

**Depends on**: 1, 2

**Files to modify**:
- `.claude/CLAUDE.md` - Update present extension routing table if needed (currently shows `skill-slides` without `:assemble`)
- `.claude/extensions.json` - Verify merged routing reflects the manifest change

**Verification**:
- Full chain: `/implement N` -> manifest lookup -> `skill-slides:assemble` -> skill extracts `workflow_type=assemble` + `output_format` from forcing_data -> slides-agent receives both values
- Backward compatibility: tasks without `output_format` in forcing_data default to Slidev

## Testing & Validation

- [ ] Read skill-slides SKILL.md and confirm `output_format` extraction with default at Stage 2
- [ ] Read skill-slides SKILL.md and confirm format-branched commit messages at Stage 9
- [ ] Read skill-slides SKILL.md and confirm format-branched return summaries at Stage 11
- [ ] Read present manifest and confirm `:assemble` suffix on slides implement routing
- [ ] Trace implement command routing for `present:slides` task_type through manifest lookup

## Artifacts & Outputs

- Modified `.claude/skills/skill-slides/SKILL.md` with format-aware assembly routing
- Modified `/home/benjamin/.config/nvim/.claude/extensions/present/manifest.json` with `:assemble` suffix
- Potentially updated `.claude/CLAUDE.md` and `.claude/extensions.json` for documentation alignment

## Rollback/Contingency

Revert the two file changes (SKILL.md and manifest.json). The skill defaults to `slides_research` workflow and the manifest reverts to `"skill-slides"` without suffix. No data migration or state changes required since this is purely routing logic.
