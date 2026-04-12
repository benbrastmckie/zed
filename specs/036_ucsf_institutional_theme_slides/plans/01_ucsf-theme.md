# Implementation Plan: Add UCSF Institutional Theme to Slides Workflow

- **Task**: 36 - Add UCSF institutional theme to slides workflow
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/036_ucsf_institutional_theme_slides/reports/01_team-research.md (team synthesis of 4 teammate findings)
- **Artifacts**: plans/01_ucsf-theme.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create the UCSF institutional Slidev theme JSON file following the established two-theme schema, register it in the talk library index and extensions manifest, and add it as a selectable option in the `/slides --design` D1 forcing question. The UCSF brand palette (navy #052049, Pacific Blue #0093D0, teal #16A0AC) and typography (Garamond headings with Georgia fallback, Arial body) are fully specified from PPTX extraction. Four files are touched: one new theme JSON, three edits to existing registration points.

### Research Integration

Five research reports were synthesized (4 teammate findings + 1 team synthesis). Key findings integrated:

- **Color mapping**: PPTX `theme1.xml` "UCSF Classic" scheme fully extracted; 10 palette values mapped to existing schema fields
- **Font fallback**: Garamond is NOT available on NixOS; use `Garamond, Georgia, 'Times New Roman', serif` fallback chain (Teammate C, high confidence)
- **Schema scope**: Existing schema is sufficient; do NOT extend with `variants`, `logo`, or `slide_layouts` sections (Teammate A + C consensus)
- **Error color**: Use standard #dc2626 for `error` (semantic consistency), not UCSF magenta (team synthesis resolution)
- **Phantom themes C/D**: Out of scope; add UCSF as option E alongside existing A-D (all teammates agree)
- **Optional institution block**: Add non-breaking `institution` field with UCSF name/full_name for future institutional slide template compatibility (Teammate D recommendation, pairs with existing `title-institutional.md`)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Create `ucsf-institutional.json` matching the exact schema of `academic-clean.json` and `clinical-teal.json`
- Register theme in `talk/index.json` so the slides-agent can discover and recommend it
- Add option E to the `/slides --design` D1 question so users can select the UCSF theme
- Add theme file path to `extensions.json` installed_files for the present extension

**Non-Goals**:
- Extending the theme JSON schema (no `variants`, `logo`, `slide_layouts` sections)
- Fixing phantom themes C (Conference Bold) and D (Minimal Dark) -- separate task
- Creating UCSF-specific Vue layout components or CSS files
- Building a PPTX-to-theme extraction pipeline
- Installing Garamond font on the system

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Garamond unavailable at render time | M | H | Fallback chain: Garamond, Georgia, 'Times New Roman', serif |
| Phantom themes C/D confuse users alongside new E | L | M | Out of scope; document as known issue for separate task |
| extensions.json path inserted at wrong position | L | L | Insert immediately after existing theme entries (after line 112) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Create UCSF Theme JSON [NOT STARTED]

**Goal**: Create the theme specification file with UCSF brand colors and typography

**Tasks**:
- [ ] Create `.claude/context/project/present/talk/themes/ucsf-institutional.json` following the exact schema of `academic-clean.json`
- [ ] Map UCSF palette: background #ffffff, text #1a202c, heading #052049, accent #0093D0, accent_light #e6f2fa, muted #5f6b7a, highlight #16A0AC, success #32A03E, warning #d97706, error #dc2626
- [ ] Set typography: heading_font `Garamond, Georgia, 'Times New Roman', serif`, body_font `Arial, 'Helvetica Neue', sans-serif`, code_font `'Courier New', monospace`
- [ ] Set heading_weight 700, body_weight 400, heading_size 2rem, body_size 1.1rem, caption_size 0.85rem
- [ ] Set borders: divider `1px solid #d1d5db`, accent_bar `3px solid #0093D0`, table_header `2px solid #052049`
- [ ] Add optional `institution` block: `{ "name": "UCSF", "full_name": "University of California, San Francisco" }`
- [ ] Set slidev_config: theme "none", highlighter "shiki", css "unocss"

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `.claude/context/project/present/talk/themes/ucsf-institutional.json` - CREATE new theme file

**Verification**:
- File exists and is valid JSON
- Schema matches `academic-clean.json` structure (same top-level keys: name, description, use_case, palette, typography, spacing, borders, footer, slidev_config, plus optional institution)
- All 10 palette colors present
- Font fallback chain includes Georgia after Garamond

---

### Phase 2: Register Theme in Talk Library and Extensions [NOT STARTED]

**Goal**: Make the theme discoverable by the slides-agent and tracked in the extensions manifest

**Tasks**:
- [ ] Add entry to `talk/index.json` `categories.themes.items[]` array: `{ "name": "ucsf-institutional", "file": "ucsf-institutional.json", "description": "UCSF institutional palette: navy/blue, Garamond headings" }`
- [ ] Add file path `.claude/context/project/present/talk/themes/ucsf-institutional.json` to `.claude/extensions.json` installed_files for the present extension (after line 112, adjacent to existing theme entries)

**Timing**: 10 minutes

**Depends on**: 1

**Files to modify**:
- `.claude/context/project/present/talk/index.json` - ADD item to themes array
- `.claude/extensions.json` - ADD path to present extension installed_files

**Verification**:
- `jq '.categories.themes.items | length' talk/index.json` returns 3
- `jq '.categories.themes.items[-1].name' talk/index.json` returns "ucsf-institutional"
- `extensions.json` contains the new theme path in the present extension's installed_files array

---

### Phase 3: Add Theme to /slides Design Question [NOT STARTED]

**Goal**: Make UCSF theme selectable during the `/slides --design` D1 forcing question

**Tasks**:
- [ ] Edit `.claude/commands/slides.md` D1 question (around lines 337-340) to add option E after the existing D option:
  ```
  E) UCSF Institutional - Navy/blue palette, Garamond serif headings (UCSF presentations)
  ```
- [ ] Verify the D1 question text flows naturally with the new option

**Timing**: 5 minutes

**Depends on**: 2

**Files to modify**:
- `.claude/commands/slides.md` - ADD option E to D1 theme question

**Verification**:
- D1 question lists 5 options (A through E)
- Option E text mentions UCSF, navy/blue, and Garamond
- No other changes to the slides command file

## Testing & Validation

- [ ] `ucsf-institutional.json` passes JSON lint (no syntax errors)
- [ ] Theme JSON has identical top-level keys to `academic-clean.json` (plus optional `institution`)
- [ ] All hex color values are valid 6-digit hex codes with `#` prefix
- [ ] `talk/index.json` lists 3 themes (academic-clean, clinical-teal, ucsf-institutional)
- [ ] `extensions.json` present extension installed_files includes the new theme path
- [ ] `slides.md` D1 question lists options A through E with UCSF as E

## Artifacts & Outputs

- `.claude/context/project/present/talk/themes/ucsf-institutional.json` (new file)
- `.claude/context/project/present/talk/index.json` (edited)
- `.claude/extensions.json` (edited)
- `.claude/commands/slides.md` (edited)
- `specs/036_ucsf_institutional_theme_slides/plans/01_ucsf-theme.md` (this plan)

## Rollback/Contingency

All changes are additive (one new file, three array/list insertions). Rollback is straightforward:
1. Delete `ucsf-institutional.json`
2. Remove the theme entry from `talk/index.json` items array
3. Remove the file path from `extensions.json` installed_files
4. Remove option E from `slides.md` D1 question
