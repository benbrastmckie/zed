# Implementation Plan: HIV Grand Rounds LA-ART & LA-PrEP PPTX

- **Task**: 49 - HIV Grand Rounds presentation on MXM LA-ART & LA-PrEP program
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/049_hiv_grand_rounds_la_art_prep/reports/01_slides-research.md
- **Artifacts**: plans/01_slides-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: slides
- **Lean Intent**: false

## Overview

Build a 23-slide PPTX presentation for HIV Grand Rounds using python-pptx and the UCSF/ZSFG 16x9 template (`examples/test-files/UCSF_ZSFG_Template_16x9.pptx`). The presentation covers the MXM long-acting ART and PrEP programs with program-level data, 4 patient cases with interactive Poll Everywhere slides, and key takeaways. The script must handle template layout selection, stat callout formatting, two-column layouts, poll slides, a Patient 2 animated timeline figure, and comprehensive speaker notes in the presenter's clinical voice.

### Research Integration

The research report provides a complete 23-slide map with content specifications, speaker notes, layout assignments (Layout 12/24/27/28/30 from the UCSF template), design rules (sparse text, big stat callouts, no patient initials), and the recommended UCSF institutional color palette (navy ~#1B2A4A, teal ~#0095A8). All slide content is fully specified -- no content gaps requiring additional source material.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No active roadmap items. ROADMAP.md is empty.

## Goals & Non-Goals

**Goals**:
- Generate a complete 23-slide PPTX using the UCSF/ZSFG 16x9 template
- Populate all slides with content from the research slide map
- Include speaker notes for every slide in the presenter's voice
- Create stat callout formatting for key numbers (100%, 93%, etc.)
- Build a horizontal timeline figure for Patient 2 (Slide 14)
- Use correct template layouts (Divider-Teal, Bullet-Navy, Two Column, etc.)

**Non-Goals**:
- Embedding live Poll Everywhere links (presenter adds QR codes manually)
- Creating actual slide animations/builds (PPTX static slides only)
- Video or audio embedding
- Custom font installation (use template-provided fonts)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Template layout indices differ from research report assumptions | H | M | Enumerate layouts programmatically in Phase 1; map indices before content population |
| python-pptx not installed or incompatible version | H | L | Check availability in Phase 1; install via pip if needed |
| Patient 2 timeline figure too complex for python-pptx shapes | M | M | Use python-pptx shapes API (arrows, circles, text boxes) with fallback to a simpler table layout |
| Slide 21 content too dense for single slide | M | H | Split into 2 slides at implementation time (21a: demographics/OIs, 21b: pericardial/IRIS) |
| Speaker notes truncation in PPTX format | L | L | python-pptx supports full-length notes; test with sample |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Project Scaffolding and Template Inspection [NOT STARTED]

**Goal**: Set up the Python build environment, inspect the UCSF template to confirm layout indices, and create the build script skeleton.

**Tasks**:
- [ ] Verify python-pptx is available (`python3 -c "import pptx"`) and install if needed
- [ ] Create `specs/049_hiv_grand_rounds_la_art_prep/build/` directory for output
- [ ] Write a template inspection script that enumerates all slide layouts in `UCSF_ZSFG_Template_16x9.pptx` with index, name, and placeholder count
- [ ] Run the inspection script and record the layout-to-index mapping
- [ ] Create the main build script skeleton (`specs/049_hiv_grand_rounds_la_art_prep/build/build_presentation.py`) with: template loading, helper functions for adding slides by layout, speaker notes attachment, and stat callout text box creation
- [ ] Define color constants (NAVY, TEAL, WHITE) and font size constants matching the research report specs

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `specs/049_hiv_grand_rounds_la_art_prep/build/build_presentation.py` - Main build script (create)
- `specs/049_hiv_grand_rounds_la_art_prep/build/inspect_template.py` - Template inspection utility (create)

**Verification**:
- Template inspection script runs and prints all layout names with indices
- Build script skeleton loads the template and creates an empty PPTX without errors
- Layout mapping matches or is reconciled with research report assumptions (Layout 12, 24, 27, 28, 30)

---

### Phase 2: Data Slides (Slides 1-5) [NOT STARTED]

**Goal**: Implement the opening section divider and the 4 program data slides (LA-ART demographics, outcomes, oral vs LA-ART comparison, LA-PrEP data).

**Tasks**:
- [ ] Slide 1: Section divider (Divider-Teal layout) with title "LA-ART & LA-PrEP at MXM", subtitle, presenter name, date
- [ ] Slide 2: Two-column layout (Layout 27) with demographics left column and clinical complexity right column for n=34 cohort
- [ ] Slide 3: Bullet layout (Layout 24) with injection visit data, 93% on-time stat, 100% suppression stat callout, regimen breakdown
- [ ] Slide 4: Two-column white layout (Layout 30) with comparison table (oral vs LA-ART) and mandatory caveat text about non-randomization
- [ ] Slide 5: Bullet white layout (Layout 28) with LA-PrEP cohort data, retention figures, seroconversion data
- [ ] Add speaker notes for all 5 slides using exact text from research report
- [ ] Create stat callout helper: large-font text box for "100%" and "93%" visual anchors on Slide 3

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `specs/049_hiv_grand_rounds_la_art_prep/build/build_presentation.py` - Add slide generation functions

**Verification**:
- Build script generates slides 1-5 with correct layouts
- Two-column slides have content in both columns
- Stat callouts render as large, visually prominent text
- Speaker notes are present and complete for each slide

---

### Phase 3: Patient Cases and Polls (Slides 6-22) [NOT STARTED]

**Goal**: Implement all 4 patient case sections including case dividers, background slides, poll slides, answer/resolution slides, and the Patient 2 timeline figure.

**Tasks**:
- [ ] Slides 6, 13, 16, 20: Case divider slides (Divider-Teal) for Patients 1-4 with context lines
- [ ] Slides 7, 17, 21: Patient background slides with clinical details (consider splitting Slide 21 into 21a/21b if content overflows)
- [ ] Slides 8, 10, 18, 22: Poll slides with question text and answer options (A-E), correct answer notation where applicable
- [ ] Slide 9: Patient 1 Poll 1 answer + clinical course (why D is correct, Phase 1 success, LTFU event)
- [ ] Slide 11: Patient 1 resolution + LEN pharmacology teaching points
- [ ] Slide 12: Patient 1 LTFU + population-level question about LEN + CAB/RPV default
- [ ] Slide 14: Patient 2 timeline figure -- horizontal arrow with colored dose markers (purple=initiation, green=on-time, orange=delayed), lab values below, gold callout boxes for key decisions; implement using python-pptx shapes (lines, ovals, text boxes)
- [ ] Slide 15: Patient 2 update/today with 195+ weeks data and 5 teaching points
- [ ] Slide 19: Patient 3 resolution with visit 2 decision and "I still don't know" closing
- [ ] Add speaker notes for all slides 6-22 from research report

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `specs/049_hiv_grand_rounds_la_art_prep/build/build_presentation.py` - Add patient case slide functions and timeline figure builder

**Verification**:
- All case dividers use Divider-Teal layout consistently
- Poll slides have clearly formatted answer options
- Patient 2 timeline renders as a readable horizontal figure with colored markers
- Slide 21 content fits (or is split across 2 slides)
- Speaker notes present for every slide

---

### Phase 4: Closing Slide, Final Assembly, and Polish [NOT STARTED]

**Goal**: Add the closing takeaways slide, assemble the full deck, and apply formatting consistency.

**Tasks**:
- [ ] Slide 23: Key Takeaways / Thank You with 5 numbered takeaway points and citations block
- [ ] Speaker notes for Slide 23
- [ ] Review and normalize font sizes across all slides (headers: 36pt, sub-headers: 18pt, content: 22pt minimum 14pt)
- [ ] Ensure consistent color usage (navy/teal per slide type)
- [ ] Final build: run the complete script to generate `HIV_Grand_Rounds_MXM.pptx`

**Timing**: 0.5 hours

**Depends on**: 2, 3

**Files to modify**:
- `specs/049_hiv_grand_rounds_la_art_prep/build/build_presentation.py` - Add closing slide, final assembly logic

**Verification**:
- Complete PPTX has 23+ slides (23 base, possibly 24 if Slide 21 was split)
- Final slide has all 5 takeaways and citations
- Font sizes are consistent across the deck

---

### Phase 5: Verification and Build [NOT STARTED]

**Goal**: Run the final build, verify output, and confirm the PPTX is ready for presenter review.

**Tasks**:
- [ ] Execute the build script end-to-end
- [ ] Verify PPTX opens without errors (check file size is reasonable, >500KB)
- [ ] Verify slide count matches expected (23-24 slides)
- [ ] Spot-check 5 slides for: correct layout, content population, speaker notes presence
- [ ] Verify Patient 2 timeline figure renders (shapes present on slide 14)
- [ ] Verify stat callouts on Slide 3 (100%, 93%)
- [ ] Write implementation summary

**Timing**: 0.5 hours (verification only)

**Depends on**: 4

**Files to modify**:
- `specs/049_hiv_grand_rounds_la_art_prep/summaries/01_slides-summary.md` - Implementation summary (create)

**Verification**:
- PPTX file exists at expected path and opens without corruption
- All slides have content and speaker notes
- Timeline figure and stat callouts render correctly

## Testing & Validation

- [ ] Template inspection confirms layout indices match research assumptions
- [ ] Build script runs without Python errors
- [ ] Output PPTX has 23-24 slides
- [ ] Every slide has speaker notes
- [ ] Stat callout text boxes render on Slide 3
- [ ] Patient 2 timeline figure has visible shapes on Slide 14
- [ ] Two-column slides (2, 4) have content in both columns
- [ ] Poll slides (8, 10, 18, 22) have answer options A-E
- [ ] No patient initials appear anywhere (only Patient 1/2/3/4)
- [ ] File size is reasonable (>500KB, <50MB)

## Artifacts & Outputs

- `specs/049_hiv_grand_rounds_la_art_prep/build/build_presentation.py` - Main Python build script
- `specs/049_hiv_grand_rounds_la_art_prep/build/inspect_template.py` - Template layout inspector
- `specs/049_hiv_grand_rounds_la_art_prep/build/HIV_Grand_Rounds_MXM.pptx` - Final presentation output
- `specs/049_hiv_grand_rounds_la_art_prep/summaries/01_slides-summary.md` - Implementation summary

## Rollback/Contingency

The build script is a standalone Python file that generates the PPTX from scratch each run. If the output is unsatisfactory, modify the build script and re-run. The source template (`UCSF_ZSFG_Template_16x9.pptx`) is never modified. If python-pptx shape API proves insufficient for the Patient 2 timeline, fall back to a structured table layout with color-coded cells instead of drawn shapes.
