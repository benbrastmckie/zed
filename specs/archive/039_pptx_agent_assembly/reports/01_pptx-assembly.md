# Research Report: Task #39

**Task**: 39 - Add PowerPoint assembly workflow to slides-agent
**Started**: 2026-04-12T00:00:00Z
**Completed**: 2026-04-12T00:10:00Z
**Effort**: 3 hours (estimated)
**Dependencies**: 37 (completed), 38 (completed)
**Sources/Inputs**:
- Codebase: `.claude/agents/slides-agent.md` (current agent definition)
- Codebase: `.claude/skills/skill-slides/SKILL.md` (skill wrapper)
- Codebase: `.claude/commands/slides.md` (command definition)
- Codebase: `.claude/context/project/present/talk/patterns/pptx-generation.md` (python-pptx API patterns)
- Codebase: `.claude/context/project/present/talk/templates/pptx-project/generate_deck.py` (skeleton script)
- Codebase: `.claude/context/project/present/talk/templates/pptx-project/theme_mappings.json` (PPTX theme constants)
- Codebase: `.claude/context/project/present/talk/patterns/conference-standard.json` (slide pattern example)
- Codebase: `.claude/context/project/present/talk/themes/*.json` (3 theme definitions)
- Codebase: `.claude/context/project/present/talk/index.json` (talk library index)
**Artifacts**:
- `specs/039_pptx_agent_assembly/reports/01_pptx-assembly.md` (this report)
**Standards**: report-format.md, artifact-management.md

## Executive Summary

- The slides-agent currently defines `workflow_type: "slides_research|assemble"` but only implements the `slides_research` workflow (Stages 0-8). The `assemble` workflow has no implementation in the agent definition.
- Task 38 created comprehensive PPTX generation infrastructure: `pptx-generation.md` (829 lines of python-pptx patterns), `theme_mappings.json` (PPTX-specific theme constants), and `generate_deck.py` (skeleton script with working helpers).
- Task 37 added `forcing_data.output_format` selection (Step 0.0 in `/slides`), stored as `"slidev"` or `"pptx"`, which reaches the agent via delegation context. The agent's Stage 1b already resolves this value.
- The slide pattern JSON files (conference-standard.json, etc.) are format-agnostic -- they define slide position, type, required status, content_focus, and template references. These can drive both Slidev and PPTX assembly.
- Implementation requires adding a new `assemble_pptx` workflow branch to slides-agent.md that reads the slide-mapped research report, generates a Python script using pptx-generation.md patterns, and produces a `.pptx` file.

## Context & Scope

This research examines the existing slides-agent architecture and the PPTX infrastructure from tasks 37 and 38 to determine exactly what changes are needed to add `assemble_pptx` capability to the slides-agent. The scope is limited to the agent definition file; task 40 handles the skill-level routing changes.

## Findings

### 1. Current Slides-Agent Structure

The slides-agent (`/home/benjamin/.config/zed/.claude/agents/slides-agent.md`) is a 305-line agent definition with:

**Frontmatter**: `name: slides-agent`, `model: opus`

**Allowed Tools**: Read, Write, Edit, Glob, Grep, Bash, WebSearch, WebFetch

**Execution Flow** (8 stages, all for `slides_research` workflow):
- Stage 0: Initialize early metadata (`.return-meta.json`)
- Stage 1: Parse delegation context (extracts `workflow_type`, `forcing_data`, etc.)
- Stage 1b: Resolve output format from `forcing_data.output_format` (defaults to `"slidev"`)
- Stage 2: Load talk pattern (conference-standard.json, etc.)
- Stage 3: Load source materials (task references, file paths)
- Stage 4: Map content to slide structure
- Stage 5: Identify content gaps
- Stage 6: Create slide-mapped report
- Stage 7: Write final metadata
- Stage 8: Return brief text summary

**Key observation**: The agent already parses `workflow_type: "slides_research|assemble"` in the delegation context (Stage 1, line 105), and resolves `output_format` in Stage 1b, but there is no conditional branching -- all stages assume `slides_research`. The `assemble` workflow needs to be added as a separate branch after Stage 1b.

### 2. PPTX Infrastructure from Task 38

Task 38 created three files in `.claude/context/project/present/talk/`:

**`patterns/pptx-generation.md`** (829 lines):
- Complete python-pptx API reference with code patterns
- 7 sections: Imports/Setup, Slide Creation, Theme Application, Component Patterns, Speaker Notes, Export, Error Handling
- 5 component helpers mirroring Vue components:
  - `add_pptx_table()` -- equivalent to `DataTable.vue`
  - `add_pptx_figure()` -- equivalent to `FigurePanel.vue`
  - `add_pptx_citation()` -- equivalent to `CitationBlock.vue`
  - `add_pptx_stat_result()` -- equivalent to `StatResult.vue`
  - `add_pptx_flow_diagram()` -- equivalent to `FlowDiagram.vue`
- `build_deck()` function: Complete assembly pattern that takes structured slide data and produces a .pptx file
- Error handling: `safe_add_picture()` for missing images, `add_pptx_table_paginated()` for overflow
- Dependencies: python-pptx >= 1.0.0, Python 3.8+

**`templates/pptx-project/theme_mappings.json`** (125 lines):
- Three themes with PPTX-specific values: `academic-clean`, `clinical-teal`, `ucsf-institutional`
- Each theme has: `palette` (10 hex colors), `typography` (font names, pt sizes, bold flags), `spacing` (inches), `borders` (colors, widths)
- Typography uses concrete values (e.g., `heading_size_pt: 32`, `body_size_pt: 18`) rather than CSS units
- Font names are single values (e.g., `"Georgia"`) rather than CSS fallback chains

**`templates/pptx-project/generate_deck.py`** (291 lines):
- Working skeleton script with `--theme` and `--output` CLI args
- Demonstrates: title slide, content slide with bullets, table slide
- Uses all helper functions from pptx-generation.md
- 16:9 widescreen: `slide_width=Inches(13.333)`, `slide_height=Inches(7.5)`

### 3. Slide Pattern JSON Files

Four pattern files exist, all format-agnostic:

| Pattern | Mode | Slides | Path |
|---------|------|--------|------|
| conference-standard.json | CONFERENCE | 12 | `talk/patterns/conference-standard.json` |
| seminar-deep-dive.json | SEMINAR | 35 | `talk/patterns/seminar-deep-dive.json` |
| defense-grant.json | DEFENSE | 30 | `talk/patterns/defense-grant.json` |
| journal-club.json | JOURNAL_CLUB | 12 | `talk/patterns/journal-club.json` |

Each slide entry has: `position`, `type`, `required`, `content_focus`, `template` (nullable path to content template), `notes`. The `template` field points to Slidev markdown templates in `contents/`, but the `type` field (e.g., `"title"`, `"methods"`, `"results-primary"`) maps directly to the `build_deck()` slide type dispatcher in `pptx-generation.md`.

**Mapping from pattern `type` to `build_deck()` slide types**:
- `title` -> `"title"` (title slide)
- `motivation`, `background`, `objectives`, `discussion`, `limitations`, `conclusions`, `acknowledgments` -> `"content"` (bullet slides)
- `methods` -> `"content"` or `"flow"` (depending on content)
- `results-primary`, `results-secondary`, `results-additional` -> `"table"`, `"figure"`, `"stat"`, or `"content"` (depending on content in research report)

### 4. Theme Definitions

Three theme JSON files exist at `talk/themes/`:

| Theme | Heading Font | Body Font | Accent Color | Use Case |
|-------|-------------|-----------|--------------|----------|
| academic-clean | Georgia (serif) | Helvetica Neue | #3b5998 (muted blue) | Standard academic talks |
| clinical-teal | Segoe UI | Segoe UI | #0d9488 (teal) | Clinical/medical conferences |
| ucsf-institutional | Garamond (serif) | Arial | #0093D0 (Pacific Blue) | UCSF presentations |

The theme JSON files use CSS units (rem, px) while `theme_mappings.json` uses python-pptx units (pt, inches). The agent should load from `theme_mappings.json` for PPTX assembly, not from the CSS-based theme files.

### 5. Skill-Slides Delegation and Workflow Types

The skill-slides SKILL.md (318 lines) routes two workflow types:

| Workflow | Trigger | Preflight Status | Success Status |
|----------|---------|-----------------|----------------|
| `slides_research` | `/research N` or `/slides N` | researching | researched |
| `assemble` | `/implement N` | implementing | completed |

Delegation context passed to slides-agent (Stage 4 of skill):
```json
{
  "session_id": "...",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "slides", "skill-slides"],
  "task_context": { "task_number": N, "task_name": "...", "task_type": "slides" },
  "workflow_type": "slides_research|assemble",
  "forcing_data": { "output_format": "slidev|pptx", "talk_type": "...", ... },
  "metadata_file_path": "specs/{NNN}_{SLUG}/.return-meta.json"
}
```

**Important**: Task 40 will update skill-slides to pass `assemble_slidev` or `assemble_pptx` based on `forcing_data.output_format`. For task 39, the agent should handle `workflow_type: "assemble"` and check `output_format` internally to decide which assembly path to take.

### 6. Output Format Flow (Task 37)

The `output_format` value flows through the system as follows:

1. `/slides "description"` command (Step 0.0) asks user to choose SLIDEV or PPTX
2. Stored as `forcing_data.output_format` in state.json task metadata
3. Skill-slides reads it from state.json and passes it in delegation context as `forcing_data`
4. Slides-agent Stage 1b resolves: reads `forcing_data.output_format`, defaults to `"slidev"` if missing
5. Agent stores as `output_format` variable for downstream use

The agent already resolves this value but currently only uses it for report metadata. The `assemble` workflow needs to branch on this value.

## Decisions

- The `assemble_pptx` workflow should be added as new stages (e.g., Stages 9-14) in slides-agent.md, conditional on `workflow_type == "assemble"` and `output_format == "pptx"`.
- The agent should generate a complete Python script in the task's output directory, then execute it via Bash to produce the .pptx file.
- Theme selection should use `design_decisions.theme` from state.json if available, otherwise recommend based on `forcing_data.audience_context`.
- The slide-mapped research report from the `slides_research` phase is the primary input -- the agent parses it to extract per-slide content.

## Recommendations

### Implementation Approach

1. **Add workflow branching after Stage 1b**: Insert a conditional check for `workflow_type`. If `"slides_research"`, continue to existing Stages 2-8. If `"assemble"`, branch to new assembly stages.

2. **New assembly stages** (for both Slidev and PPTX, but task 39 focuses on PPTX):
   - Stage A1: Read slide-mapped research report from `specs/{NNN}_{SLUG}/reports/`
   - Stage A2: Read design decisions from state.json (theme, message_order, section_emphasis)
   - Stage A3: Parse report into structured slide data (extract content per slide position)
   - Stage A4: Generate PPTX assembly script (Python, using pptx-generation.md patterns)
   - Stage A5: Copy theme_mappings.json to output directory
   - Stage A6: Execute script via Bash (`python generate_deck.py`)
   - Stage A7: Verify output .pptx exists
   - Stage A8: Write final metadata with assembled status
   - Stage A9: Return brief text summary

3. **Output directory**: `talks/{N}_{slug}/` (consistent with skill-slides assemble success message) containing:
   - `generate_deck.py` (generated Python script)
   - `theme_mappings.json` (copied from templates)
   - `{slug}.pptx` (generated presentation)
   - `images/` (if any figures referenced)

4. **Report parsing**: The slide-mapped research report uses a structured format:
   ```markdown
   ### Slide {position}: {type}
   **Template**: ...
   **Status**: mapped | needs-input | optional-skip
   **Content**: ...
   **Speaker Notes**: ...
   ```
   The agent should parse these sections and map each to a `build_deck()` slide data dict.

5. **Context references to add**: The agent should load `pptx-generation.md` and `theme_mappings.json` when `output_format == "pptx"`.

### Backward Compatibility

- The existing `slides_research` stages (0-8) remain unchanged
- If `workflow_type == "assemble"` and `output_format == "slidev"`, the agent should follow the existing Slidev assembly path (which does not exist yet but is out of scope for task 39)
- If `output_format` is missing, default to `"slidev"` per Stage 1b

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| python-pptx not installed | Script execution fails | Check `pip show python-pptx` before execution; install if missing via `pip install python-pptx` |
| Missing images referenced in report | Script crashes on `add_picture()` | Use `safe_add_picture()` pattern from pptx-generation.md |
| SVG images not supported | python-pptx rejects SVG | Document in agent: convert SVG to PNG before insertion |
| Report parsing fails | Incorrect slide data extraction | Define strict parsing regex for slide sections; fall back to content-only slides |
| Font not available on target system | PowerPoint uses fallback | Use cross-platform fonts (Arial, Georgia, Courier New) per pptx-generation.md guidance |
| Large tables exceed slide height | Content overflow | Use `add_pptx_table_paginated()` for tables with >8 rows |

## Appendix

### Files to Modify
- `.claude/agents/slides-agent.md` -- Add assemble workflow branch with PPTX assembly stages

### Files to Reference (read-only during implementation)
- `.claude/context/project/present/talk/patterns/pptx-generation.md` -- Python-pptx API patterns
- `.claude/context/project/present/talk/templates/pptx-project/theme_mappings.json` -- Theme constants
- `.claude/context/project/present/talk/templates/pptx-project/generate_deck.py` -- Skeleton script
- `.claude/context/project/present/talk/patterns/conference-standard.json` -- Example slide pattern

### Slide Type to Component Mapping
| Slide Type (pattern) | PPTX Component | Notes |
|----------------------|----------------|-------|
| title | `add_titled_slide()` + subtitle textbox | Authors, affiliations, date |
| motivation | `add_titled_slide()` + bullets | Clinical/scientific question |
| background | `add_titled_slide()` + bullets + citations | Literature context |
| objectives | `add_titled_slide()` + numbered bullets | Specific aims |
| methods | `add_titled_slide()` + flow diagram or bullets | Study design |
| results-primary | `add_titled_slide()` + figure/table/stat | Main finding |
| results-secondary | `add_titled_slide()` + table/figure | Secondary outcomes |
| discussion | `add_titled_slide()` + bullets + citations | Interpretation |
| limitations | `add_titled_slide()` + bullets | Study limitations |
| conclusions | `add_titled_slide()` + bullets | Key takeaways |
| acknowledgments | `add_titled_slide()` + bullets | Funding, collaborators |
