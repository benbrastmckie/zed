# Implementation Plan: HIV Grand Rounds PPTX Assembly

- **Task**: 47 - HIV Grand Rounds: MXM LA-ART & LA-PrEP presentation
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_slides-research.md
- **Artifacts**: plans/01_slides-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: slides
- **Lean Intent**: false

## Overview

Build a 23-slide PPTX presentation for Dr. Nicky Mehtani's HIV Grand Rounds talk on LA-ART and LA-PrEP delivery through the MXM street medicine program at UCSF/ZSFG. The implementation uses python-pptx to generate slides from the UCSF/ZSFG 16x9 institutional template (`examples/test-files/UCSF_ZSFG_Template_16x9.pptx`), applying specified layouts (12, 24, 27, 28, 30, 35) with navy/teal color scheme, Garamond/Arial typography, stat callouts, a custom Patient 2 timeline figure, and four Poll Everywhere interactive slides. Definition of done: a single `.pptx` file containing all 23 slides with speaker notes, matching the source document specifications.

### Research Integration

The research report (`reports/01_slides-research.md`) provides a complete slide map for all 23 slides with template layout assignments, content specifications, speaker notes text, and design rules. All content gaps are resolved. Key implementation challenges identified: Patient 2 timeline figure (slide 14) requires programmatic construction, Patient 4 background (slide 21) may need splitting, and Poll Everywhere slides need standalone formatting.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No active roadmap items. ROADMAP.md is empty.

## Goals & Non-Goals

**Goals**:
- Generate a complete 23-slide PPTX using the UCSF/ZSFG institutional template
- Apply correct template layouts per slide map (Layout 12, 24, 27, 28, 30, 35)
- Include all speaker notes verbatim from source specifications
- Create stat callout visual elements (100%, 93%, etc.) as prominent text boxes
- Build Patient 2 horizontal timeline figure programmatically
- Format Poll Everywhere questions with answer options that work standalone
- Produce a self-contained python-pptx script that can regenerate the deck

**Non-Goals**:
- Embedding live Poll Everywhere interactivity (slides show question text only)
- Animation or progressive reveal effects
- Custom graphics beyond what python-pptx can render (no external image files)
- Video or audio embedding
- Presenter view configuration

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Template layout indices differ from research report | H | M | Inspect template with python-pptx to verify layout names and indices before building slides |
| Garamond font not available on build system | M | M | Fall back to Georgia or Times New Roman; note in script comments |
| Patient 2 timeline too complex for python-pptx shapes | M | M | Use simplified horizontal bar with text annotations; avoid fine-grained SVG-style rendering |
| Slide 21 content overflow (Patient 4 background) | M | H | Split into 2 slides as source document suggests; adjust slide count to 24 |
| Two-column layouts may not match expected placeholder positions | M | M | Enumerate placeholders in template inspection phase; adapt positioning |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Template Inspection and Script Scaffold [NOT STARTED]

**Goal**: Inspect the UCSF/ZSFG template to map layout indices to names and placeholder positions, then create the python-pptx script scaffold with helper functions.

**Tasks**:
- [ ] Write a template inspection script that enumerates all slide layouts (index, name, placeholder count/types/positions) from `examples/test-files/UCSF_ZSFG_Template_16x9.pptx`
- [ ] Run inspection and document layout mapping (verify Layout 12, 24, 27, 28, 30, 35 match expected names)
- [ ] Create main assembly script `specs/047_hiv_grand_rounds_la_art_prep/build_deck.py` with:
  - Template loading and output path configuration
  - Color constants (NAVY=#1B2A4A, TEAL=#0095A8, WHITE=#FFFFFF)
  - Font helper functions (Garamond headers, Arial body, size presets)
  - Stat callout helper (large number + label text box with teal/navy accent)
  - Speaker notes helper (add notes to slide)
  - Two-column content helper (populate left/right placeholders)
  - Bullet list helper (populate content placeholder with bullet items)

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `specs/047_hiv_grand_rounds_la_art_prep/build_deck.py` - Create main assembly script
- `specs/047_hiv_grand_rounds_la_art_prep/inspect_template.py` - Create template inspection utility

**Verification**:
- Template inspection produces layout index-to-name mapping
- Script scaffold imports correctly and helper functions are defined
- Color and font constants match design specifications

---

### Phase 2: Data Slides and Case Dividers (Slides 1-6, 13, 16, 20) [NOT STARTED]

**Goal**: Build the opening section (slides 1-5), all four case divider slides (6, 13, 16, 20), using template layouts and populating content from the research report.

**Tasks**:
- [ ] Slide 1 (Layout 12 -- Divider Teal): Title slide with presenter info, event, date
- [ ] Slide 2 (Layout 27 -- Two Column Navy): LA-ART demographics (left) and clinical complexity (right) with stat highlights
- [ ] Slide 3 (Layout 24 -- Bullet Navy): Delivery and outcomes with stat callouts for 100% and 93%
- [ ] Slide 4 (Layout 30 -- Two Column White): Oral vs. LA-ART comparison with caveat box (text box with border)
- [ ] Slide 5 (Layout 28 -- Bullet White): LA-PrEP data overview
- [ ] Slide 6 (Layout 12 -- Divider Teal): Case divider "Patient 1"
- [ ] Slide 13 (Layout 12 -- Divider Teal): Case divider "Patient 2"
- [ ] Slide 16 (Layout 12 -- Divider Teal): Case divider "Patient 3"
- [ ] Slide 20 (Layout 12 -- Divider Teal): Case divider "Patient 4"
- [ ] Add speaker notes to all slides in this phase

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `specs/047_hiv_grand_rounds_la_art_prep/build_deck.py` - Add slide-building functions

**Verification**:
- Script generates slides 1-6, 13, 16, 20 with correct layouts
- Two-column slides populate both columns
- Stat callouts render as large visually prominent elements
- Speaker notes present on every slide

---

### Phase 3: Patient Cases and Poll Slides (Slides 7-12, 14-15, 17-19, 21-23) [NOT STARTED]

**Goal**: Build all patient case content slides, poll question slides, and the closing takeaways slide, including the Patient 2 timeline figure.

**Tasks**:
- [ ] Slides 7-12 (Patient 1 case): Background, Poll 1, Poll 1 answer, Poll 2, Resolution + LEN pharmacology, LTFU + population question
- [ ] Slide 14 (Patient 2 timeline): Build horizontal timeline figure using python-pptx shapes -- navy arrow, color-coded dose circles (purple=initiation, green=on-time, orange=delayed), lab value annotations below, decision callout boxes; may split to 2 slides for readability
- [ ] Slide 15 (Patient 2 update): Today's status with stat callout for ~195+ weeks
- [ ] Slides 17-19 (Patient 3 case): Background, Poll 3, Resolution with multi-visit narrative
- [ ] Slides 21-22 (Patient 4 case): Background (split to 2 slides if content overflows -- adjust to slides 21a/21b + 22 for poll), Poll 4 with discussion points
- [ ] Slide 23 (Takeaways): Five key messages + citations on closing layout
- [ ] Poll slides (8, 10, 18, 22): Format with question title, lettered answer options, highlight correct answer where applicable, "Poll Everywhere" branding text
- [ ] Add speaker notes to all slides in this phase

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `specs/047_hiv_grand_rounds_la_art_prep/build_deck.py` - Add remaining slide functions

**Verification**:
- All 23 slides (or 24 if Patient 4 splits) are generated
- Patient 2 timeline renders with color-coded elements and annotations
- Poll slides show question + answer options in readable format
- Speaker notes present on every slide

---

### Phase 4: Assembly, Polish, and Output [NOT STARTED]

**Goal**: Run the complete script end-to-end, verify slide order and count, fix layout or formatting issues, and produce the final PPTX output.

**Tasks**:
- [ ] Run `build_deck.py` end-to-end and verify it produces a valid PPTX file
- [ ] Verify slide count matches 23 (or 24 with Patient 4 split)
- [ ] Verify slide order matches the source document slide map
- [ ] Spot-check font sizes (headers >= 36pt, body >= 14pt, content ~22pt)
- [ ] Verify caveat box on slide 4 has visible border/background
- [ ] Verify stat callouts are visually prominent (large font, color accent)
- [ ] Confirm no patient initials appear anywhere (only "Patient 1/2/3/4")
- [ ] Fix any layout, positioning, or text overflow issues found during review
- [ ] Save final output to `specs/047_hiv_grand_rounds_la_art_prep/HIV_Grand_Rounds_MXM.pptx`

**Timing**: 45 minutes

**Depends on**: 2, 3

**Files to modify**:
- `specs/047_hiv_grand_rounds_la_art_prep/build_deck.py` - Final adjustments
- `specs/047_hiv_grand_rounds_la_art_prep/HIV_Grand_Rounds_MXM.pptx` - Generated output

**Verification**:
- PPTX opens without errors
- Slide count and order match specification
- All speaker notes populated
- No text overflow or clipping on any slide
- Patient naming convention respected throughout

---

### Phase 5: Documentation and Cleanup [NOT STARTED]

**Goal**: Add script usage documentation, clean up inspection artifacts, and create the execution summary.

**Tasks**:
- [ ] Add docstring and usage instructions to `build_deck.py` (dependencies: python-pptx; how to regenerate)
- [ ] Remove or archive `inspect_template.py` if no longer needed
- [ ] Verify script is idempotent (re-running produces identical output)
- [ ] Create execution summary

**Timing**: 30 minutes

**Depends on**: 4

**Files to modify**:
- `specs/047_hiv_grand_rounds_la_art_prep/build_deck.py` - Add documentation header
- `specs/047_hiv_grand_rounds_la_art_prep/summaries/01_slides-summary.md` - Execution summary

**Verification**:
- Script has clear usage instructions
- Re-running script produces valid PPTX
- Summary captures final slide count, any deviations from plan

## Testing & Validation

- [ ] `python build_deck.py` runs without errors
- [ ] Output PPTX has exactly 23 slides (or 24 if Patient 4 was split)
- [ ] Every slide has speaker notes
- [ ] Slide layouts match research report mapping (Layout 12 for dividers, 24/28 for bullets, 27/30 for two-column)
- [ ] Stat callouts (100%, 93%, ~195+) are visually prominent
- [ ] Patient 2 timeline figure has color-coded dose markers and lab annotations
- [ ] Poll slides display question text and all answer options
- [ ] No real patient initials appear anywhere in the deck
- [ ] Caveat box on slide 4 is visually distinct (bordered or shaded)
- [ ] Font sizes meet minimum (14pt body, 36pt headers)

## Artifacts & Outputs

- `specs/047_hiv_grand_rounds_la_art_prep/plans/01_slides-plan.md` - This plan
- `specs/047_hiv_grand_rounds_la_art_prep/build_deck.py` - Python assembly script
- `specs/047_hiv_grand_rounds_la_art_prep/inspect_template.py` - Template inspection utility
- `specs/047_hiv_grand_rounds_la_art_prep/HIV_Grand_Rounds_MXM.pptx` - Final presentation
- `specs/047_hiv_grand_rounds_la_art_prep/summaries/01_slides-summary.md` - Execution summary

## Rollback/Contingency

The assembly script is the source of truth; the PPTX is a generated artifact. If the output is unsatisfactory, modify the script and re-run. If the UCSF/ZSFG template layouts do not match expected indices, fall back to blank slide layouts with manually positioned text boxes matching the navy/teal color scheme. If python-pptx cannot render the Patient 2 timeline adequately, simplify to a table-based timeline with color-coded cell backgrounds.
