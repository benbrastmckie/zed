# Implementation Plan: HIV Grand Rounds PPTX Presentation

- **Task**: 54 - HIV Grand Rounds: MXM LA-ART & LA-PrEP presentation for UCSF/ZSFG (CONFERENCE talk, 20-25 min, pptx)
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: Research report (01_slides-research.md), UCSF_ZSFG_Template_16x9.pptx
- **Research Inputs**: specs/054_hiv_grand_rounds_pptx_v2/reports/01_slides-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: present
- **Lean Intent**: false

## Overview

Build a 23-slide PPTX presentation using python-pptx, consuming the UCSF/ZSFG 16x9 institutional template. The script reads the template's named layouts (Layout 12 teal dividers, Layout 24/27 navy content, Layout 28/30 white content), populates each slide with the content from the research report's slide map, and writes complete speaker notes. The output is a single `.pptx` file ready for presenter review.

### Research Integration

The research report provides a complete slide-by-slide content map for all 23 slides including: template layout assignments, content text, stat callouts, two-column layouts, poll placeholders, timeline visualization specs, and full speaker notes in the presenter's voice. Template layout indices (12, 24, 27, 28, 30, 35) are confirmed from the UCSF/ZSFG template file available at `examples/test-files/UCSF_ZSFG_Template_16x9.pptx`.

### Prior Plan Reference

No prior plan. Task 53 produced a Slidev version of the same content; this task produces a PPTX version using python-pptx with different tooling and output format.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Generate a complete 23-slide PPTX from the UCSF/ZSFG 16x9 template
- Apply correct layout per slide (teal dividers, navy content, white content)
- Include stat callout text boxes (100%, 93%, 85%, etc.) as prominent visual elements
- Include Poll Everywhere placeholder slides for Polls 1-4
- Create Patient 2 timeline visualization using python-pptx shapes
- Populate all speaker notes with clinical voice text from the research report
- Use anonymized patient identifiers (Patient 1/2/3/4, no initials)

**Non-Goals**:
- PowerPoint animations or transitions (python-pptx does not support these)
- Embedded Poll Everywhere live integration (placeholder text/QR boxes only)
- Custom fonts beyond what the template provides (Garamond/Arial are template-resident)
- Image or photograph insertion (no clinical images in this talk)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Template layout indices differ from research report | H | L | Enumerate layouts from template file at script start; map by name if indices shift |
| python-pptx limited shape control for timeline visualization | M | M | Use simple rectangles + lines + text boxes; avoid complex SVG paths |
| Stat callout formatting (large bold numbers) may not render as expected | M | M | Use explicit font size (72-96pt), bold, color on text runs; test with LibreOffice |
| Speaker notes truncation in python-pptx | L | L | Write notes as plain text; python-pptx handles notes reliably |
| Two-column layouts may have unexpected placeholder positions | M | M | Inspect template placeholders programmatically before populating |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Template Inspection and Script Scaffolding [NOT STARTED]

**Goal**: Verify template layout structure and create the python-pptx script skeleton with helper functions.

**Tasks**:
- [ ] Write a template inspection script that enumerates all layouts in `UCSF_ZSFG_Template_16x9.pptx`, printing index, name, and placeholder details
- [ ] Run inspection and confirm layout indices match the research report (Layout 12, 24, 27, 28, 30, 35)
- [ ] Create the main build script (`build_pptx.py`) with:
  - Template loading and layout index constants
  - Helper function: `add_divider_slide(prs, title, subtitle, notes)` -- Layout 12
  - Helper function: `add_navy_slide(prs, title, content, notes)` -- Layout 24
  - Helper function: `add_navy_two_col(prs, title, left, right, notes)` -- Layout 27
  - Helper function: `add_white_slide(prs, title, content, notes)` -- Layout 28
  - Helper function: `add_white_two_col(prs, title, left, right, notes)` -- Layout 30
  - Helper function: `add_stat_callout(slide, number, label, position)` -- large bold stat text box
  - Helper function: `set_speaker_notes(slide, text)` -- notes pane text
- [ ] Verify script runs without error (generates empty presentation from template)

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `specs/054_hiv_grand_rounds_pptx_v2/inspect_template.py` - Template layout inspector
- `specs/054_hiv_grand_rounds_pptx_v2/build_pptx.py` - Main build script skeleton

**Verification**:
- `inspect_template.py` outputs layout names and placeholder details
- `build_pptx.py` runs and produces a valid .pptx file (even if empty)
- Layout indices confirmed or remapped based on inspection output

---

### Phase 2: Data Overview Slides (Slides 1-5) [NOT STARTED]

**Goal**: Populate the first five slides covering program-level data: title slide, demographics, outcomes, oral vs. LA-ART comparison, and LA-PrEP data.

**Tasks**:
- [ ] Slide 1 (Layout 12 divider): Title "Long-Acting ART & PrEP at MXM", subtitle, event line
- [ ] Slide 2 (Layout 27 navy two-col): Demographics left column, Clinical Complexity right column with 85% stat callout
- [ ] Slide 3 (Layout 24 navy): Three stat callouts (100%, 93%, 747) at top, bullet content below, regimen line
- [ ] Slide 4 (Layout 30 white two-col): Oral vs. LA-ART comparison table (left), caveat box (right) with source line
- [ ] Slide 5 (Layout 28 white): LA-PrEP data with stat callouts (68, 90%, 2), cohort line, delivery breakdown, footer note
- [ ] Add complete speaker notes for all 5 slides from research report

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `specs/054_hiv_grand_rounds_pptx_v2/build_pptx.py` - Add slides 1-5 content functions

**Verification**:
- Generated PPTX opens and displays 5 slides with correct layouts
- Stat callouts are visually prominent (large font, correct color)
- Speaker notes present on all 5 slides
- Two-column slides have content in both columns

---

### Phase 3: Patient Case Slides (Slides 6-22) [NOT STARTED]

**Goal**: Build all 17 patient case slides including four case dividers, clinical backgrounds, four poll placeholders, answer/resolution slides, and Patient 2 timeline visualization.

**Tasks**:
- [ ] Slide 6 (Layout 12 divider): Patient 1 case divider
- [ ] Slide 7 (Layout 28 white): Patient 1 background -- demographics, HIV history, genotype
- [ ] Slide 8 (Layout 28 white): Poll 1 -- "Would you start this patient on LA-ART?" with answer choices A-E and Poll Everywhere placeholder box
- [ ] Slide 9 (Layout 28 white or 24 navy): Poll 1 answer reveal + clinical course (Phase 1: 14 months)
- [ ] Slide 10 (Layout 28 white): Poll 2 -- "In addition to drawing HIV VL + RNA genotype..." with answer choices A-E
- [ ] Slide 11 (Layout 24 navy or 27 navy): Patient 1 resolution with LEN pharmacology teaching points
- [ ] Slide 12 (Layout 24 navy): Patient 1 LTFU status + population-level question highlight box
- [ ] Slide 13 (Layout 12 divider): Patient 2 case divider
- [ ] Slide 14 (Layout 28 white): Patient 2 timeline Part 1 -- horizontal timeline with colored dose markers (rectangles), lab values annotated below, decision callout box. Use python-pptx shapes (rectangles for dose markers, lines for timeline arrow, text boxes for annotations)
- [ ] Slide 15 (Layout 24 navy): Patient 2 update/today -- timeline Part 2, LEN monotherapy outcome, CAPELLA data, key points
- [ ] Slide 16 (Layout 12 divider): Patient 3 case divider
- [ ] Slide 17 (Layout 28 white): Patient 3 background -- demographics, HIV history, recent events, MXM presentation
- [ ] Slide 18 (Layout 28 white): Poll 3 -- "He will not accept oral ART or labs..." with answer choices A-E
- [ ] Slide 19 (Layout 24 navy): Patient 3 resolution -- Visit 1/Visit 2, 403B emergency supply, closing quote
- [ ] Slide 20 (Layout 12 divider): Patient 4 case divider
- [ ] Slide 21 (Layout 28 white or 30 two-col): Patient 4 background -- demographics/history left, OIs/pericardial right
- [ ] Slide 22 (Layout 28 white): Poll 4 -- IRIS context box + answer choices A-E + current lean notation
- [ ] Add complete speaker notes for all 17 slides from research report

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `specs/054_hiv_grand_rounds_pptx_v2/build_pptx.py` - Add slides 6-22 content functions

**Verification**:
- All 17 case slides render with correct layouts
- Four teal divider slides (6, 13, 16, 20) visually distinct from content slides
- Poll slides have clear answer choice formatting and placeholder area
- Patient 2 timeline (Slide 14) shows horizontal arrow with colored dose markers
- Speaker notes present on all 17 slides

---

### Phase 4: Closing Slide and Final Assembly [NOT STARTED]

**Goal**: Add the takeaways/thank-you slide, run final generation, and verify the complete 23-slide deck.

**Tasks**:
- [ ] Slide 23 (Layout 12 divider or Layout 24 navy): Key Takeaways -- 5 numbered points with bold emphasis, citation footer, thank you + contact info
- [ ] Add speaker notes for Slide 23
- [ ] Run full build script to generate final PPTX
- [ ] Open generated PPTX and verify:
  - Exactly 23 slides
  - Correct layout alternation (teal dividers, navy content, white content)
  - All stat callouts visible and appropriately sized
  - All speaker notes populated
  - No placeholder text remaining
  - Patient identifiers use Patient 1/2/3/4 (no initials)
- [ ] Fix any rendering issues found during verification
- [ ] Add a README or usage note at top of build_pptx.py documenting how to regenerate

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- `specs/054_hiv_grand_rounds_pptx_v2/build_pptx.py` - Add slide 23, main execution block
- `specs/054_hiv_grand_rounds_pptx_v2/HIV_Grand_Rounds_PPTX.pptx` - Final output file

**Verification**:
- `python build_pptx.py` runs without errors
- Output file opens in LibreOffice/PowerPoint
- 23 slides total with correct sequencing
- All speaker notes match research report content
- Visual spot-check of stat callouts, two-column layouts, and timeline

## Testing & Validation

- [ ] Template layout indices verified against actual template file
- [ ] Script runs end-to-end without errors: `python build_pptx.py`
- [ ] Output PPTX has exactly 23 slides
- [ ] Each slide uses the correct layout (divider vs. navy vs. white)
- [ ] Stat callouts (100%, 93%, 85%, 747, 68, 90%, 2) are visually prominent
- [ ] All four Poll Everywhere placeholder slides have clear answer formatting
- [ ] Patient 2 timeline visualization renders dose markers and annotations
- [ ] All 23 slides have populated speaker notes
- [ ] No patient initials -- only Patient 1/2/3/4 designations
- [ ] File opens without errors in LibreOffice Impress

## Artifacts & Outputs

- `specs/054_hiv_grand_rounds_pptx_v2/plans/01_implementation-plan.md` - This plan
- `specs/054_hiv_grand_rounds_pptx_v2/inspect_template.py` - Template layout inspector utility
- `specs/054_hiv_grand_rounds_pptx_v2/build_pptx.py` - Python-pptx build script
- `specs/054_hiv_grand_rounds_pptx_v2/HIV_Grand_Rounds_PPTX.pptx` - Final presentation output

## Rollback/Contingency

The build script is fully regenerative -- delete the output PPTX and re-run `python build_pptx.py` to produce a fresh copy. If python-pptx cannot handle a specific layout feature (e.g., timeline shapes), fall back to simpler text-based representations on those slides. The template file is never modified; all operations create a new file from the template copy.
