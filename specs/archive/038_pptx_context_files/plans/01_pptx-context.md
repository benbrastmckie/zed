# Implementation Plan: PPTX Context Files for Slides-Agent

- **Task**: 38 - pptx_context_files
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/038_pptx_context_files/reports/01_pptx-context.md
- **Artifacts**: plans/01_pptx-context.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create context files that enable the slides-agent to generate PowerPoint (.pptx) output using python-pptx. This involves three deliverables: a pattern document (`pptx-generation.md`) documenting API patterns for slide creation, a template directory (`pptx-project/`) with theme mappings and a generation script skeleton, and an update to `talk/index.json` to register the new files. All deliverables are text-based context files paralleling the existing Slidev template structure.

### Research Integration

The research report (01_pptx-context.md) provided comprehensive findings:
- Complete mapping of CSS theme properties (palette, typography, spacing) to python-pptx API calls (RGBColor, Pt, Inches)
- Five Vue component equivalents documented with python-pptx generation patterns (DataTable, FigurePanel, CitationBlock, StatResult, FlowDiagram)
- Recommended template approach: Python generation script rather than binary .pptx, since context files must be text-based
- Standard 16:9 widescreen (13.333 x 7.5 inches) with Blank layout for maximum control

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No active roadmap items. The roadmap is empty (Phase 1 has no items yet).

## Goals & Non-Goals

**Goals**:
- Create `pptx-generation.md` pattern document covering all python-pptx API patterns the slides-agent needs
- Create `theme_mappings.json` translating all three themes (academic-clean, clinical-teal, ucsf-institutional) to PPTX constants
- Create `generate_deck.py` skeleton script demonstrating theme-aware PPTX generation
- Create `pptx-project/README.md` with usage instructions
- Update `talk/index.json` to register new template and pattern entries

**Non-Goals**:
- Producing runnable Python code (this is a meta task -- context files guide the agent, not end users)
- Creating binary .pptx template files
- Modifying the existing Slidev templates or Vue components
- Adding python-pptx as a project dependency

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Theme color mappings are inaccurate (CSS hex to RGBColor) | M | L | Research report verified mappings against python-pptx docs; use exact hex values from theme JSON |
| Component patterns are too complex for agent to follow | M | M | Keep patterns concise with copy-paste-ready code blocks; test readability |
| index.json schema changes break existing entries | H | L | Only add new entries; do not modify existing ones |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Pattern Document and Theme Mappings [COMPLETED]

**Goal**: Create the two highest-value context files -- the pattern document that directly guides the slides-agent, and the theme mappings JSON it references.

**Tasks**:
- [ ] Create `.claude/context/project/present/talk/patterns/pptx-generation.md` with sections: imports/setup, slide creation, theme application, five component patterns (DataTable, FigurePanel, CitationBlock, StatResult, FlowDiagram), speaker notes, export, error handling
- [ ] Create `.claude/context/project/present/talk/templates/pptx-project/theme_mappings.json` containing PPTX-specific constants for all three themes (RGBColor hex strings, font names, Pt sizes, Inches positions, layout indices)
- [ ] Verify theme_mappings.json values match the source theme JSON files (academic-clean.json, clinical-teal.json, ucsf-institutional.json)

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `.claude/context/project/present/talk/patterns/pptx-generation.md` - New file: python-pptx API pattern document
- `.claude/context/project/present/talk/templates/pptx-project/theme_mappings.json` - New file: theme color/font/layout constants

**Verification**:
- pptx-generation.md covers all seven sections from research recommendations
- theme_mappings.json has entries for all three themes with palette, typography, and spacing keys
- Code examples in pptx-generation.md reference theme_mappings.json loading pattern

---

### Phase 2: Template Directory Completion [COMPLETED]

**Goal**: Complete the pptx-project template directory with generation script skeleton and README.

**Tasks**:
- [ ] Create `.claude/context/project/present/talk/templates/pptx-project/generate_deck.py` -- skeleton Python script demonstrating theme-aware PPTX generation (loads theme_mappings.json, creates slides with themed formatting, saves output)
- [ ] Create `.claude/context/project/present/talk/templates/pptx-project/README.md` -- usage instructions, theme selection, file descriptions, copy workflow paralleling slidev-project/README.md

**Timing**: 0.5 hours

**Depends on**: 1

**Files to modify**:
- `.claude/context/project/present/talk/templates/pptx-project/generate_deck.py` - New file: skeleton generation script
- `.claude/context/project/present/talk/templates/pptx-project/README.md` - New file: usage instructions

**Verification**:
- generate_deck.py imports match patterns documented in pptx-generation.md
- README.md describes all files in pptx-project/ directory
- Directory structure parallels slidev-project/ conventions

---

### Phase 3: Index Registration [COMPLETED]

**Goal**: Register new files in the talk library manifest so the slides-agent can discover them.

**Tasks**:
- [ ] Update `.claude/context/project/present/talk/index.json` to add pptx-project template entry under `categories.templates.items`
- [ ] Update `.claude/context/project/present/talk/index.json` to add pptx-generation pattern entry under `categories.patterns.items`
- [ ] Verify updated index.json is valid JSON

**Timing**: 0.5 hours

**Depends on**: 2

**Files to modify**:
- `.claude/context/project/present/talk/index.json` - Add entries for new pptx-generation pattern and pptx-project template

**Verification**:
- index.json parses as valid JSON (use `jq .` to validate)
- New entries follow the same schema as existing entries
- Pattern entry includes description field
- Template entry includes description and file references

## Testing & Validation

- [ ] All new files are valid: JSON files parse with `jq`, Markdown files have proper headings, Python file has valid syntax
- [ ] theme_mappings.json color values match source theme JSON hex values
- [ ] pptx-generation.md component patterns cover all five Vue components
- [ ] index.json has new entries for both the pattern and template
- [ ] pptx-project/ directory has four files: theme_mappings.json, generate_deck.py, README.md (3 files total, plus theme_mappings.json)
- [ ] No existing files were modified except index.json

## Artifacts & Outputs

- `.claude/context/project/present/talk/patterns/pptx-generation.md` - python-pptx API pattern document
- `.claude/context/project/present/talk/templates/pptx-project/theme_mappings.json` - Theme constants for PPTX
- `.claude/context/project/present/talk/templates/pptx-project/generate_deck.py` - Skeleton generation script
- `.claude/context/project/present/talk/templates/pptx-project/README.md` - Usage instructions
- `.claude/context/project/present/talk/index.json` - Updated manifest (existing file)

## Rollback/Contingency

All changes are additive (new files plus one JSON update). Rollback by:
1. Deleting `.claude/context/project/present/talk/templates/pptx-project/` directory
2. Deleting `.claude/context/project/present/talk/patterns/pptx-generation.md`
3. Reverting index.json to its previous version via `git checkout -- .claude/context/project/present/talk/index.json`
