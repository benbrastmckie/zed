# Implementation Plan: Update Talk Library and Slides Documentation for PowerPoint Support

- **Task**: 41 - Update talk library index and slides documentation for PowerPoint support
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Dependencies**: Tasks 37-40 (completed)
- **Research Inputs**: specs/041_slides_pptx_documentation/reports/01_pptx-docs.md
- **Artifacts**: plans/01_pptx-docs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: true

## Overview

Tasks 37-40 implemented PowerPoint output support for the slides workflow (format selection forcing question, PPTX assembly stages A1-A8, format-aware routing). However, three documentation files still reference Slidev-only output or mark PPTX as "planned." This plan updates those files to reflect the current dual-format (Slidev + PowerPoint) reality.

### Research Integration

Research report (01_pptx-docs.md) identified exactly 3 files needing updates with specific line-level edits. It also confirmed that 15 content template files should NOT be modified (they are correctly Slidev-specific) and that presentation-types.md is already format-agnostic.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Update index.json top-level and templates category descriptions to mention both Slidev and PPTX
- Generalize talk-structure.md "Slidev Implementation Notes" section to cover both output formats
- Remove outdated "(PPTX support planned)" from CLAUDE.md present extension section

**Non-Goals**:
- Modifying the 15 Slidev-specific content template files (they are correctly labeled)
- Adding PPTX template sections to individual content files
- Changing presentation-types.md (already format-agnostic)
- Modifying Vue component descriptions (correctly Slidev-specific)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Overgeneralizing Slidev-specific docs | L | L | Research confirmed exactly which references are format-specific vs. generic |
| Missing a stale Slidev-only reference | L | L | Research grep covered all present-related files |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

Phases within the same wave can execute in parallel.

### Phase 1: Update Documentation Files [COMPLETED]

**Goal**: Update all three files identified by research to reflect dual-format support.

**Tasks**:
- [ ] Edit `talk/index.json` line 3: change description from `"Research presentation library for Slidev-based academic talks"` to `"Research presentation library for Slidev and PowerPoint academic talks"`
- [ ] Edit `talk/index.json` line 62: change templates description from `"Reusable scripts and templates for Slidev projects"` to `"Reusable scripts and templates for Slidev and PowerPoint projects"`
- [ ] Edit `patterns/talk-structure.md` lines 108-109: rename section from `### Slidev Implementation Notes` to `### Format-Specific Implementation Notes` and add PPTX reference line pointing to `talk/patterns/pptx-generation.md`
- [ ] Edit `.claude/CLAUDE.md` present extension Talk Library section: change `"Slidev-compatible markdown templates for slide types (PPTX support planned)"` to `"Content templates for slide types (Slidev markdown and PowerPoint via python-pptx)"`
- [ ] Verify no JSON syntax errors in index.json after edit
- [ ] Verify talk-structure.md renders correctly with new section heading

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `.claude/context/project/present/talk/index.json` - Update 2 description strings
- `.claude/context/project/present/patterns/talk-structure.md` - Generalize implementation notes section
- `.claude/CLAUDE.md` - Update Talk Library bullet in present extension section

**Verification**:
- `jq . index.json` succeeds (valid JSON)
- Grep for `"PPTX support planned"` returns zero matches
- Grep for `"Slidev-based"` in index.json returns zero matches
- Section heading in talk-structure.md says "Format-Specific" not "Slidev"

## Testing & Validation

- [ ] `jq . .claude/context/project/present/talk/index.json` parses without error
- [ ] `grep -r "PPTX support planned" .claude/` returns no matches
- [ ] `grep "Slidev-based" .claude/context/project/present/talk/index.json` returns no matches
- [ ] talk-structure.md contains references to both slidev-pitfalls.md and pptx-generation.md

## Artifacts & Outputs

- plans/01_pptx-docs.md (this plan)
- summaries/01_pptx-docs-summary.md (after implementation)

## Rollback/Contingency

All changes are documentation-only string edits in 3 files. Revert with `git checkout -- <file>` for any file if needed. No functional code is affected.
