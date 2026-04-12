# Implementation Plan: Add PPTX Assembly Workflow to slides-agent

- **Task**: 39 - Add PowerPoint assembly workflow to slides-agent
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: 37 (completed), 38 (completed)
- **Research Inputs**: specs/039_pptx_agent_assembly/reports/01_pptx-assembly.md
- **Artifacts**: plans/01_pptx-assembly.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add an `assemble_pptx` workflow branch to `.claude/agents/slides-agent.md` that generates a `.pptx` file from a slide-mapped research report. The agent currently only implements the `slides_research` workflow (Stages 0-8); this task adds a conditional branch after Stage 1b that routes to new PPTX assembly stages when `workflow_type == "assemble"` and `output_format == "pptx"`. The new stages read the slide-mapped report, generate a Python script using pptx-generation.md patterns and theme_mappings.json constants, execute it via Bash, and verify the output file.

### Research Integration

Research report `01_pptx-assembly.md` identified:
- The agent already parses `workflow_type` and resolves `output_format` but has no assembly branch
- Task 38 created comprehensive PPTX infrastructure (pptx-generation.md, theme_mappings.json, generate_deck.py)
- Slide pattern JSON files are format-agnostic and can drive both Slidev and PPTX assembly
- The `build_deck()` function in pptx-generation.md provides the assembly pattern the agent should follow
- Report parsing uses structured `### Slide {position}: {type}` sections with Status, Content, and Speaker Notes

### Roadmap Alignment

No ROADMAP.md items defined yet. This task advances the present extension's PPTX output capability.

## Goals & Non-Goals

**Goals**:
- Add workflow branching logic after Stage 1b to route `assemble` workflows to new stages
- Define PPTX assembly stages (A1-A8) that read the slide-mapped report and produce a `.pptx` file
- Add context references for pptx-generation.md and theme_mappings.json
- Document the output directory structure (`talks/{N}_{slug}/`)
- Handle edge cases: missing images, large tables, SVG files, missing python-pptx

**Non-Goals**:
- Implementing Slidev assembly (separate future task)
- Modifying skill-slides routing (task 40)
- Creating new Python libraries or packages
- Modifying the existing slides_research workflow stages

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Agent definition becomes too long (300+ lines added) | H | M | Use concise stage descriptions; reference pptx-generation.md for code patterns rather than inlining |
| Report parsing instructions are ambiguous | M | M | Define explicit regex/section markers for slide extraction |
| python-pptx dependency missing at runtime | M | L | Include pip install check in Stage A5 |
| Generated script has bugs on first run | M | M | Include error handling stage with retry guidance |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Add Workflow Branching and Context References [COMPLETED]

**Goal**: Insert conditional branching after Stage 1b and add PPTX-specific context references to the agent definition.

**Tasks**:
- [ ] Add PPTX context references to the "Load by Content Need" section:
  - `talk/patterns/pptx-generation.md` (load when `output_format == "pptx"`)
  - `talk/templates/pptx-project/theme_mappings.json` (load when `output_format == "pptx"`)
  - `talk/templates/pptx-project/generate_deck.py` (reference skeleton)
- [ ] Add Stage 1c: Workflow Branching after Stage 1b that checks `workflow_type`:
  - If `"slides_research"`: continue to existing Stages 2-8 (no change)
  - If `"assemble"`: check `output_format` and branch to assembly stages
  - If `output_format == "pptx"`: proceed to Stages A1-A8
  - If `output_format == "slidev"`: note "Slidev assembly not yet implemented" and write failed metadata
- [ ] Update the agent Overview section to mention both `slides_research` and `assemble_pptx` workflows

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `.claude/agents/slides-agent.md` - Add context refs and branching logic

**Verification**:
- Stage 1c branching logic is clear and covers all workflow_type/output_format combinations
- Context references include both pptx-generation.md and theme_mappings.json
- Existing stages 0-8 are untouched

---

### Phase 2: Define PPTX Assembly Stages (A1-A8) [COMPLETED]

**Goal**: Write the complete PPTX assembly workflow as new stages in slides-agent.md.

**Tasks**:
- [ ] Stage A1: Read slide-mapped research report
  - Find report in `specs/{NNN}_{SLUG}/reports/` (most recent `*_slides-research.md`)
  - Parse into per-slide data: extract `### Slide {position}: {type}` sections
  - For each slide: extract Status (mapped/needs-input/optional-skip), Content block, Speaker Notes block
  - Store as structured list of slide data dicts
- [ ] Stage A2: Resolve design decisions
  - Read theme from `design_decisions.theme` in state.json task metadata (if set)
  - If not set, use "Recommended Theme" from the research report
  - If neither, default to `academic-clean`
  - Read talk_type from forcing_data for pattern-to-type mapping
- [ ] Stage A3: Map slide types to PPTX components
  - For each parsed slide, determine the PPTX component function:
    - `title` -> title slide with subtitle, authors, date
    - `motivation`, `background`, `objectives`, `discussion`, `limitations`, `conclusions`, `acknowledgments` -> bullet content slides
    - `methods` -> bullet or flow diagram depending on content keywords
    - `results-primary`, `results-secondary`, `results-additional` -> table, figure, stat, or content depending on content
  - Build the structured slide data list for `build_deck()` pattern
- [ ] Stage A4: Generate Python assembly script
  - Create output directory `talks/{N}_{slug}/`
  - Copy `theme_mappings.json` from templates to output directory
  - Generate `generate_deck.py` in output directory using:
    - pptx-generation.md helper functions (copy relevant helpers)
    - Slide data from Stage A3 hardcoded as Python data structures
    - Theme name from Stage A2 as default `--theme` argument
    - Output filename as `{slug}.pptx`
  - Include `safe_add_picture()` for image resilience
  - Include `add_pptx_table_paginated()` for large tables
- [ ] Stage A5: Execute assembly script
  - Check python-pptx is installed: `pip show python-pptx`
  - If not installed: `pip install python-pptx`
  - Run: `cd talks/{N}_{slug} && python generate_deck.py --theme {theme} --output {slug}.pptx`
  - Capture stdout/stderr for error reporting
- [ ] Stage A6: Verify output and handle errors
  - Check that `talks/{N}_{slug}/{slug}.pptx` exists
  - Report file size as verification
  - If script failed: log error, include stderr in metadata, write `partial` status
- [ ] Stage A7: Write final metadata
  - Write to metadata_file_path with status `"assembled"` (or skill-defined success status)
  - Include artifact path to generated .pptx
  - Include artifact path to generate_deck.py (for reproducibility)
  - Include slide count and theme used in metadata
- [ ] Stage A8: Return brief text summary
  - Report: slide count, theme, output path, file size
  - 3-6 bullet points, NOT JSON

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `.claude/agents/slides-agent.md` - Add Stages A1-A8

**Verification**:
- All 8 assembly stages are present and complete
- Each stage references the correct context files and patterns
- Report parsing regex/format is explicitly documented
- Error handling covers missing images, failed scripts, missing dependencies
- Output directory structure matches `talks/{N}_{slug}/` convention

---

### Phase 3: Update Error Handling and Critical Requirements [NOT STARTED]

**Goal**: Extend the agent's error handling section and critical requirements to cover the assembly workflow.

**Tasks**:
- [ ] Add assembly-specific error handling subsections:
  - "python-pptx Not Installed": install via pip, retry
  - "Script Execution Failure": capture stderr, write partial status, include error in metadata
  - "Missing Images": document that `safe_add_picture()` creates placeholder rectangles
  - "SVG Not Supported": note that SVG must be converted to PNG before insertion
  - "Report Not Found": fail with clear error message pointing to slides_research workflow
- [ ] Update MUST DO list to include:
  - Load pptx-generation.md and theme_mappings.json when output_format is pptx
  - Generate a self-contained, executable Python script
  - Verify the output .pptx file exists before writing success metadata
- [ ] Update MUST NOT list to include:
  - Do not inline large code blocks from pptx-generation.md (reference instead)
  - Do not skip the pip install check
  - Do not hardcode theme colors (always read from theme_mappings.json)
- [ ] Add the slide type-to-component mapping table from research (Appendix) as a reference section in the agent

**Timing**: 45 minutes

**Depends on**: 2

**Files to modify**:
- `.claude/agents/slides-agent.md` - Extend error handling and requirements sections

**Verification**:
- Error handling covers all risks identified in research
- Critical requirements updated for assembly workflow
- Slide type mapping table is present for implementer reference
- Agent definition reads coherently end-to-end with both workflows

## Testing & Validation

- [ ] Read the modified slides-agent.md and verify Stage 1c branching covers: slides_research, assemble+pptx, assemble+slidev
- [ ] Verify all 8 assembly stages (A1-A8) are present with correct stage numbering
- [ ] Confirm context references include pptx-generation.md and theme_mappings.json
- [ ] Confirm the report parsing format matches the Stage 4 output format from slides_research
- [ ] Verify error handling section addresses all 6 risks from the research report
- [ ] Check that the agent definition remains under 600 lines total (avoid bloat)
- [ ] Verify no existing stages (0-8) were modified

## Artifacts & Outputs

- `.claude/agents/slides-agent.md` - Modified agent definition with assemble_pptx workflow
- `specs/039_pptx_agent_assembly/plans/01_pptx-assembly.md` - This plan
- `specs/039_pptx_agent_assembly/summaries/01_pptx-assembly-summary.md` - Execution summary (created during implementation)

## Rollback/Contingency

The only file modified is `.claude/agents/slides-agent.md`. If implementation fails:
1. `git checkout -- .claude/agents/slides-agent.md` restores the original agent definition
2. All new content is appended after existing stages, so partial implementation can be reverted by removing the added sections
3. The existing `slides_research` workflow remains fully functional regardless of assembly workflow state
