# Implementation Plan: HIV Grand Rounds PPTX Presentation

- **Task**: 52 - HIV Grand Rounds: MXM LA-ART & LA-PrEP presentation for UCSF/ZSFG
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: specs/052_hiv_grand_rounds_la_art_prep/reports/01_slides-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: present
- **Lean Intent**: false

## Overview

Build a 23-slide PPTX presentation using python-pptx for Nicky Mehtani's HIV Grand Rounds talk at UCSF/ZSFG. The presentation covers MXM clinic's long-acting ART (n=34, 100% viral suppression) and PrEP (n=68) programs through four patient cases with Poll Everywhere audience interaction. The output is a single .pptx file with UCSF institutional theming (navy/teal palette, Garamond headings), speaker notes in the presenter's voice, and stat callout formatting throughout.

### Research Integration

The research report (787 lines) provides a complete slide-by-slide map for all 23 slides including content, speaker notes, layout specifications, and visual guidance. Key design decisions confirmed: UCSF institutional theme, case-based message order (100% suppression -> LEN as population protection -> act on opportunity -> novel IRIS questions), four patient cases with polls as primary content.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items found.

## Goals & Non-Goals

**Goals**:
- Produce a polished, presentation-ready PPTX file with all 23 slides
- Implement UCSF/ZSFG visual identity (navy #1B2A4A, teal #0095A8, Garamond/Arial fonts)
- Include complete speaker notes for every slide in Nicky's voice
- Create stat callout formatting for key numbers (100%, 93%, 85%, etc.)
- Build Patient 2 horizontal timeline figure(s) with colored dose markers
- Generate Poll Everywhere placeholder slides with answer options

**Non-Goals**:
- Live Poll Everywhere integration (static placeholders only)
- Slide animations or transitions (PPTX static builds only)
- Video or audio embedding
- Recreating an exact UCSF master template (build theme from scratch with correct colors/fonts)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Garamond font not available on build system | M | M | Use Garamond as font name in PPTX (renders on systems with it); fallback renders in Times New Roman, which is acceptable |
| Patient 2 timeline complexity exceeds python-pptx shape capabilities | H | M | Build timeline using basic shapes (circles, lines, textboxes) rather than SmartArt; split across 2 slides if needed |
| Slide 5 and 21 too dense for single slide | M | H | Plan for optional split during assembly; research report already flags this |
| python-pptx not installed in environment | H | L | pip install as first step; verify import before proceeding |
| UCSF template file not available | M | H | Build theme programmatically from scratch using documented colors, fonts, and layouts |
| Color/font rendering differences across platforms | L | M | Use standard Office-compatible hex colors and system fonts |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

### Phase 1: Python Project Setup and Theme Foundation [COMPLETED]

**Goal**: Set up python-pptx environment and create the base PPTX template with UCSF/ZSFG theme colors, fonts, and reusable slide layout helpers.

**Tasks**:
- [ ] Verify python-pptx is installed; install if missing (`pip install python-pptx`)
- [ ] Create the main build script at `specs/052_hiv_grand_rounds_la_art_prep/build_slides.py`
- [ ] Define color constants: NAVY (#1B2A4A), TEAL (#0095A8), WHITE (#FFFFFF), LIGHT_GRAY (#F5F5F5)
- [ ] Define font constants: HEADING_FONT = "Garamond", BODY_FONT = "Arial", heading sizes (36pt, 28pt), body sizes (22pt, 18pt, 14pt)
- [ ] Create helper functions for slide layouts:
  - `add_teal_divider(prs, title, subtitle)` -- Layout 12 equivalent (teal background, centered text)
  - `add_navy_bullet(prs, title, bullets, speaker_notes)` -- Layout 24 equivalent (navy bg, white text, bullet list)
  - `add_navy_two_column(prs, title, left_content, right_content, speaker_notes)` -- Layout 27 equivalent
  - `add_white_bullet(prs, title, bullets, speaker_notes)` -- Layout 28 equivalent (white bg, navy text)
  - `add_white_two_column(prs, title, left_content, right_content, speaker_notes)` -- Layout 30 equivalent
  - `add_poll_slide(prs, question, options, speaker_notes)` -- Poll Everywhere placeholder
- [ ] Create helper for stat callout formatting (large centered number with label below)
- [ ] Create a test slide to verify font, color, and layout rendering

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `specs/052_hiv_grand_rounds_la_art_prep/build_slides.py` -- create main build script

**Verification**:
- Script runs without errors
- Test PPTX opens in LibreOffice/PowerPoint with correct navy/teal colors
- Helper functions produce correctly themed slides

---

### Phase 2: Slide Builder Architecture and Content Data [COMPLETED]

**Goal**: Structure the slide-building pipeline and encode all 23 slides' content as data (text, speaker notes, layout type) so each slide can be built by calling the appropriate helper.

**Tasks**:
- [ ] Create a `build_presentation()` function that orchestrates all 23 slides in sequence
- [ ] Define slide content data for slides 1-5 (Title, LA-ART Demographics, LA-ART Outcomes, Oral vs LA-ART Comparison, LA-PrEP)
- [ ] Define slide content data for slides 6-12 (Patient 1: divider, background, poll 1, answer, poll 2, resolution, 2nd LTFU)
- [ ] Define slide content data for slides 13-15 (Patient 2: divider, timeline, teaching points)
- [ ] Define slide content data for slides 16-19 (Patient 3: divider, background, poll 3, resolution)
- [ ] Define slide content data for slides 20-22 (Patient 4: divider, background, poll 4)
- [ ] Define slide content data for slide 23 (Takeaways/Thank You)
- [ ] Add speaker notes text for all 23 slides (copy from research report verbatim)
- [ ] Wire `build_presentation()` to call layout helpers with content data

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `specs/052_hiv_grand_rounds_la_art_prep/build_slides.py` -- extend with content data and builder

**Verification**:
- All 23 slides generated in correct order
- Each slide uses the correct layout helper (teal divider, navy bullet, white two-column, poll, etc.)
- Speaker notes present on every slide

---

### Phase 3: Data and Comparison Slides (Slides 1-5) [COMPLETED]

**Goal**: Polish the opening section slides with stat callouts, the oral vs. LA-ART comparison table, and proper visual hierarchy for data-dense slides.

**Tasks**:
- [ ] Slide 1 (Title Divider): Teal background, "Long-Acting ART & PrEP at MXM", presenter name, event, date
- [ ] Slide 2 (LA-ART Demographics): Two-column navy slide with demographic data left, clinical complexity right; stat callouts for 85% and 32%
- [ ] Slide 3 (LA-ART Outcomes): Navy slide with 100% as large centered stat callout, 93% as secondary, sparse delivery/timeliness bullets
- [ ] Slide 4 (Oral vs LA-ART): White two-column with comparison table (3 rows); 100% values in teal highlight; caveat in italics at bottom
- [ ] Slide 5 (LA-PrEP): White bullet slide with cohort/delivery/retention data; stat callouts for 90% retention and 2 seroconversions; assess density and split to 2 slides if needed
- [ ] Verify all stat callout numbers use large font (44-60pt) with label below (18pt)

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `specs/052_hiv_grand_rounds_la_art_prep/build_slides.py` -- refine slide 1-5 builders

**Verification**:
- Slides 1-5 render with correct visual hierarchy
- Stat callouts are visually prominent
- Comparison table on slide 4 is readable with caveat visible
- Slide 5 is not overcrowded (split if needed)

---

### Phase 4: Case Slides with Polls and Patient 2 Timeline (Slides 6-22) [COMPLETED]

**Goal**: Build all four patient case sections including poll placeholder slides and the Patient 2 horizontal timeline figure.

**Tasks**:
- [ ] Slides 6, 13, 16, 20 (Case Dividers): Teal dividers with patient number and optional subtitle
- [ ] Slide 7 (Patient 1 Background): Navy slide with demographics/HIV history; callout box for "Y181C + M184V = RPV excluded"
- [ ] Slides 8, 10 (Patient 1 Polls): Poll placeholder slides with question and 5 answer options (A-E)
- [ ] Slide 9 (Patient 1 Answer + Course): Navy slide with answer reveal (D highlighted in green/teal), rationale bullets, clinical course summary
- [ ] Slide 11 (Patient 1 Resolution): Two teaching point callout boxes + "VL UNDETECTABLE" stat callout
- [ ] Slide 12 (Patient 1 2nd LTFU): Population-level question in large teal text as visual anchor
- [ ] Slide 14 (Patient 2 Timeline): Build horizontal timeline using python-pptx shapes:
  - Horizontal arrow line (navy)
  - Colored circles above: purple (initiation), green (on-time), orange (delayed)
  - Lab values as text below at key timepoints
  - Gold callout boxes for key decisions (W0: add LEN, genotype returns)
  - Split across 2 slides if timeline is too long for one
- [ ] Slide 15 (Patient 2 Teaching Points): "195+ weeks" stat callout, numbered teaching points
- [ ] Slide 17 (Patient 3 Background): Two-column or bullet with "NOT our patient" emphasis
- [ ] Slide 18 (Patient 3 Poll): Poll placeholder with options A-E
- [ ] Slide 19 (Patient 3 Resolution): Two-part structure (Visit 1 + Visit 2), closing quote in italics
- [ ] Slide 21 (Patient 4 Background): Dense clinical data; stat callouts for CD4 <35 and VL 255,000; assess whether to split into 2 slides
- [ ] Slide 22 (Patient 4 Poll + Discussion): Poll placeholder with IRIS discussion points

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `specs/052_hiv_grand_rounds_la_art_prep/build_slides.py` -- implement case slide builders and timeline figure

**Verification**:
- All 4 case sections render with correct divider -> content -> poll -> resolution flow
- Poll slides have readable question and 5 options
- Patient 2 timeline has colored circles, lab annotations, and gold callout boxes
- Dense slides (17, 21) are readable; split if over 7 bullet points

---

### Phase 5: Closing Slide, Speaker Notes Polish, and Full Assembly [COMPLETED]

**Goal**: Complete slide 23, do a full pass on all speaker notes for voice consistency, and verify the complete 23-slide deck assembles correctly.

**Tasks**:
- [ ] Slide 23 (Takeaways): White/light background with 5 numbered takeaways; bold key phrases as visual anchors; citations in smaller font at bottom
- [ ] Full speaker notes review: ensure all 23 slides have notes matching the research report
- [ ] Verify Nicky's voice in notes: casual, thoughtful, street medicine perspective, first-person
- [ ] Remove any patient initials or identifiable information from all slides
- [ ] Verify slide order matches research report slide map (1-23)
- [ ] Run build script end-to-end; verify output PPTX path

**Timing**: 0.5 hours

**Depends on**: 3, 4

**Files to modify**:
- `specs/052_hiv_grand_rounds_la_art_prep/build_slides.py` -- finalize slide 23 and notes polish

**Verification**:
- Slide 23 has all 5 takeaways with citations
- All speaker notes present and consistent in voice
- No patient initials appear anywhere
- Complete deck has exactly 23 slides (or 24-25 if splits were needed)

---

### Phase 6: Build, Verify, and Output Final PPTX [COMPLETED]

**Goal**: Execute the build script, verify the output PPTX, and confirm deliverable quality.

**Tasks**:
- [ ] Run `python build_slides.py` to generate final PPTX
- [ ] Verify output file exists and has reasonable size (>500KB)
- [ ] Open and inspect: correct slide count, readable text, proper colors
- [ ] Verify stat callouts render at intended size
- [ ] Verify Patient 2 timeline shapes render correctly
- [ ] Verify all poll slides have question + 5 options
- [ ] Verify speaker notes appear in notes view for all slides
- [ ] Move final PPTX to expected output location
- [ ] Create implementation summary

**Timing**: 0.5 hours

**Depends on**: 5

**Files to modify**:
- `specs/052_hiv_grand_rounds_la_art_prep/build_slides.py` -- any final fixes discovered during verification
- `specs/052_hiv_grand_rounds_la_art_prep/HIV_Grand_Rounds_MXM.pptx` -- output file

**Verification**:
- PPTX file opens without errors
- 23+ slides present with correct themes
- Speaker notes on every slide
- No rendering artifacts or missing text
- File ready for presenter review

## Testing & Validation

- [ ] python-pptx script runs without errors on clean execution
- [ ] Output PPTX has correct slide count (23, or 24-25 with density splits)
- [ ] Every slide has speaker notes
- [ ] No patient initials or identifiable information on any slide
- [ ] Stat callouts (100%, 93%, 85%, 32%, 195+, etc.) render at large font size
- [ ] Color scheme matches UCSF institutional theme (navy #1B2A4A, teal #0095A8)
- [ ] Patient 2 timeline renders with colored circles and annotations
- [ ] Poll slides have readable questions and all 5 answer options
- [ ] Comparison table on slide 4 includes caveat text
- [ ] Slide 23 has all 5 takeaways and citations

## Artifacts & Outputs

- `specs/052_hiv_grand_rounds_la_art_prep/plans/01_implementation-plan.md` -- this plan
- `specs/052_hiv_grand_rounds_la_art_prep/build_slides.py` -- python-pptx build script
- `specs/052_hiv_grand_rounds_la_art_prep/HIV_Grand_Rounds_MXM.pptx` -- final presentation

## Rollback/Contingency

- If python-pptx fails to install: use alternative library (e.g., python-docx for basic XML manipulation, or fall back to manual PPTX assembly guidance)
- If timeline shapes prove too complex: replace with a simple table-based timeline layout
- If font rendering is problematic: fall back to Arial throughout (still professional)
- If density splits push slide count beyond 25: consolidate Patient 4 background or merge Visit 1/Visit 2 on Patient 3 resolution
- All source content is preserved in the research report; the build script can be re-run with modifications at any time
