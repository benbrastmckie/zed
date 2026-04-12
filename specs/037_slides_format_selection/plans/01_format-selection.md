# Implementation Plan: Slides Format Selection

- **Task**: 37 - slides_format_selection
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/037_slides_format_selection/reports/01_format-selection.md
- **Artifacts**: plans/01_format-selection.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan adds a new Step 0.0 forcing question to the `/slides` command that asks users to choose between Slidev (default) and PowerPoint output formats. The choice is stored as `forcing_data.output_format` and propagated through the pipeline. All hardcoded "Slidev" references in output messages and documentation are updated to be format-conditional. The skill layer requires no changes since it passes `forcing_data` as-is.

### Research Integration

Research report `01_format-selection.md` identified 7 Slidev references across 4 files, confirmed the forcing question pattern used by `/budget` and `/funds` commands, mapped the forcing_data flow (command -> skill -> agent), and confirmed that skill-slides needs no modifications. The agent file needs only a minor awareness update.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No active roadmap items. ROADMAP.md is empty.

## Goals & Non-Goals

**Goals**:
- Add Step 0.0 format selection question following existing AskUserQuestion pattern
- Store choice as `forcing_data.output_format` with values `slidev` or `pptx`
- Make Slidev the default when user does not specify
- Update all output messages to reflect chosen format
- Update CLAUDE.md documentation to mention both formats

**Non-Goals**:
- Implementing actual PPTX generation pipeline (separate future task)
- Creating PPTX-specific templates in the talk library
- Modifying the skill-slides passthrough layer
- Changing research or planning phases (format-agnostic)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Existing tasks lack output_format in forcing_data | M | H | Default to "slidev" when field is missing |
| PPTX pipeline does not exist yet | L | H | This task only stores the choice; generation is a separate task |
| Step numbering confusion with 0.0 prefix | L | L | 0.0 is explicitly requested in task description; no renumbering needed |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Step 0.0 and Update Forcing Data Assembly [NOT STARTED]

**Goal**: Insert the format selection forcing question and include output_format in the forcing_data JSON object.

**Tasks**:
- [ ] Add `### Step 0.0: Output Format` section before Step 0.1 in `slides.md` with AskUserQuestion presenting Slidev (default) and PPTX options
- [ ] Update Step 0.4 forcing_data JSON assembly to include `"output_format": "{selected_format}"` field
- [ ] Add default handling: if user skips or is ambiguous, default to `"slidev"`

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/commands/slides.md` - Add Step 0.0 section (~15 lines), update Step 0.4 JSON block

**Verification**:
- Step 0.0 appears before Step 0.1 with AskUserQuestion pattern
- forcing_data JSON includes output_format field
- Default value documented as "slidev"

---

### Phase 2: Update Output Messages in slides.md [NOT STARTED]

**Goal**: Make all Slidev-specific output text conditional on the chosen format.

**Tasks**:
- [ ] Update Overview paragraph (line 14) to mention both Slidev and PowerPoint formats
- [ ] Update Stage 1 Step 6 output (line 246): conditional "Generate Slidev presentation" vs "Generate PowerPoint presentation"
- [ ] Update Core Command Integration table (line 431): conditional Slidev/PowerPoint text
- [ ] Update Output Formats section (line 464): conditional Slidev/PowerPoint text
- [ ] Add `Output Format: {output_format}` line to task creation output blocks

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `.claude/commands/slides.md` - Update 4 Slidev references and 2 output blocks

**Verification**:
- All output messages use format-conditional text
- Grep for hardcoded "Slidev" in output messages returns zero matches (only format-conditional references remain)
- Output blocks include format indicator

---

### Phase 3: Update Documentation and Agent Awareness [NOT STARTED]

**Goal**: Update CLAUDE.md documentation and add output_format awareness to slides-agent.md.

**Tasks**:
- [ ] Update CLAUDE.md Present Extension description (line 485): "Typst and Slidev formats" -> "Typst, Slidev, and PowerPoint formats"
- [ ] Update CLAUDE.md Talk Library description (line 539): note Slidev-compatible templates with future PPTX support
- [ ] Update slides-agent.md forcing_data parsing section to include `output_format` field with default fallback to "slidev"

**Timing**: 20 minutes

**Depends on**: 1

**Files to modify**:
- `.claude/CLAUDE.md` - Update 2 description strings
- `.claude/agents/slides-agent.md` - Add output_format to forcing_data parsing (~3 lines)

**Verification**:
- CLAUDE.md mentions both Slidev and PowerPoint in Present Extension section
- slides-agent.md parses output_format with "slidev" default

## Testing & Validation

- [ ] Verify Step 0.0 follows AskUserQuestion pattern consistent with Step 0.1-0.3
- [ ] Verify forcing_data JSON includes output_format field
- [ ] Verify all output messages are format-conditional (grep for remaining hardcoded "Slidev" in output blocks)
- [ ] Verify CLAUDE.md documentation reflects both formats
- [ ] Verify slides-agent.md reads output_format with default fallback
- [ ] Verify no changes to skill-slides/SKILL.md (passthrough layer)

## Artifacts & Outputs

- `specs/037_slides_format_selection/plans/01_format-selection.md` (this plan)
- Modified files: `.claude/commands/slides.md`, `.claude/CLAUDE.md`, `.claude/agents/slides-agent.md`

## Rollback/Contingency

All changes are to markdown specification files. Rollback via `git revert` of the implementation commit. No runtime code, no database changes, no build artifacts.
