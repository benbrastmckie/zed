# Implementation Plan: HIV Grand Rounds Slidev Presentation

- **Task**: 53 - HIV Grand Rounds: MXM LA-ART & LA-PrEP presentation for UCSF/ZSFG (CONFERENCE talk, 20-25 min, slidev)
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/053_hiv_grand_rounds_slidev/reports/01_slides-research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: present
- **Lean Intent**: false

## Overview

Build a 23-slide Slidev presentation for HIV Grand Rounds at UCSF/ZSFG covering MXM's long-acting ART and PrEP programs. The presentation uses a UCSF institutional theme (navy #1B2A4A, teal #0095A8, Garamond headings) and features four case-based patient stories with interactive Poll Everywhere questions. Key technical challenges include a custom animated timeline component for Patient 2 (slide 14), stat callout layouts, comparison tables, and progressive v-click reveals throughout.

### Research Integration

The slide-mapped research report (01_slides-research.md) provides complete content for all 23 slides including speaker notes, clinical data, poll questions with answers, and the Patient 2 timeline sequence. No content gaps were identified. User-confirmed design decisions: ucsf-institutional theme, message order 1,2,3 (outcomes -> LEN protection -> low-barrier philosophy), expanded patient case presentations.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap items directly applicable to this presentation task.

## Goals & Non-Goals

**Goals**:
- Produce a complete, buildable Slidev project with 23 slides matching the research report structure
- Implement UCSF institutional theming (navy/teal palette, Garamond serif headings, Arial body)
- Include all speaker notes as Slidev presenter notes
- Create Poll Everywhere placeholder slides with QR code/link areas
- Build an animated horizontal timeline component for Patient 2 (slide 14) with v-click progressive reveal
- Use stat callout styling for key data points (100% suppression, 195+ weeks, etc.)
- Ensure the deck runs with `npx slidev` and exports cleanly

**Non-Goals**:
- Live Poll Everywhere integration (placeholders only; presenter adds real links)
- PDF export optimization (standard Slidev export is sufficient)
- Custom Vue component library beyond the timeline (use CSS/layout for stat callouts and tables)
- Mobile responsiveness (presentation display only)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Garamond font unavailable in browser | M | M | Use @font-face with Google Fonts EB Garamond; fallback to Georgia, serif |
| Patient 2 timeline too complex for single slide | H | M | Design as scrollable horizontal layout with v-clicks; split into 2 slides if needed during implementation |
| Slidev version incompatibility with custom CSS | M | L | Pin Slidev version in package.json; test early in Phase 1 |
| Speaker notes too long for Slidev presenter view | L | L | Keep notes verbatim from research; presenter view handles scrolling |
| 23 slides exceed 25-min target pacing | M | L | Research report already calibrated to ~1 min/slide average; case slides get more time, data slides less |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Project Scaffolding and Theme [NOT STARTED]

**Goal**: Create a working Slidev project with UCSF institutional theme applied, producing a title slide that renders correctly.

**Tasks**:
- [ ] Create Slidev project directory structure at `specs/053_hiv_grand_rounds_slidev/presentation/`
- [ ] Create `package.json` with Slidev dependencies (pinned version), build scripts
- [ ] Create `slides.md` with frontmatter configuration (theme: none, title, info, presenter notes enabled)
- [ ] Create `styles/` directory with custom CSS theme:
  - [ ] `styles/index.css` -- Global overrides: navy (#1B2A4A), teal (#0095A8), gold (#FDB515), white backgrounds
  - [ ] `@font-face` declarations for EB Garamond (headings) and Inter/Arial (body)
  - [ ] Slide layout classes: `.divider-teal` (teal bg, white text), `.content-navy` (navy accents), `.content-white` (clean white)
  - [ ] Stat callout class: large centered number with label below
  - [ ] Comparison table styling matching clinical paper aesthetic
  - [ ] Poll slide styling with placeholder box for QR code
- [ ] Write Slide 1 (Title/Section Opener) as validation that theme renders correctly
- [ ] Verify `npx slidev` launches and displays the title slide with correct fonts and colors

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `specs/053_hiv_grand_rounds_slidev/presentation/package.json` -- Project config
- `specs/053_hiv_grand_rounds_slidev/presentation/slides.md` -- Slide deck entry point
- `specs/053_hiv_grand_rounds_slidev/presentation/styles/index.css` -- Theme CSS

**Verification**:
- `npx slidev` starts without errors
- Title slide shows navy/teal color scheme and Garamond heading font
- Presenter view accessible with speaker notes

---

### Phase 2: Data Overview Slides (Slides 2-5) [NOT STARTED]

**Goal**: Build the four data-heavy slides covering LA-ART demographics, outcomes, oral vs. LA-ART comparison, and LA-PrEP data.

**Tasks**:
- [ ] Slide 2: LA-ART Demographics -- Two-column layout (navy accent), demographics left, clinical complexity right, using bullet lists with bold labels
- [ ] Slide 3: LA-ART Delivery & Outcomes -- Stat callout "100%" at top, bullet list of injection data, current regimens breakdown at bottom
- [ ] Slide 4: Oral vs. LA-ART Comparison -- White background, comparison table with highlighted LA-ART column, caveat box below table with distinct styling (border/background)
- [ ] Slide 5: LA-PrEP at MXM -- Bullet layout, key metrics, retention data, seroconversion callout, gift card disruption note
- [ ] Add speaker notes to all four slides (verbatim from research report)
- [ ] Apply v-click animations where appropriate (reveal data points progressively on slides 2-3)

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `specs/053_hiv_grand_rounds_slidev/presentation/slides.md` -- Slides 2-5 content

**Verification**:
- All four slides render with correct layout and styling
- Comparison table on slide 4 is readable with proper column alignment
- Stat callout "100%" is visually prominent on slide 3
- Speaker notes appear in presenter view for all slides

---

### Phase 3: Patient 2 Timeline Component (Slides 13-15) [NOT STARTED]

**Goal**: Build the most technically complex element -- Patient 2's animated horizontal timeline -- plus the surrounding case slides.

**Tasks**:
- [ ] Slide 13: Patient 2 case divider -- Teal divider template with patient descriptor
- [ ] Slide 14: Patient 2 timeline -- Build as a custom HTML/CSS layout within the slide:
  - [ ] Horizontal arrow base (dark navy SVG or CSS)
  - [ ] Dose circles above timeline: colored by type (purple=initiation, green=on-time, orange=delayed)
  - [ ] Lab values below timeline at key timepoints
  - [ ] Right-side callout boxes (gold/yellow) for key decisions/results
  - [ ] Use v-click to progressively reveal timeline segments:
    - Click 1: Baseline (W-29) with loading dose
    - Click 2: Doses 2-5 with delays and VL drop
    - Click 3: Dose 6 viremia + LEN addition
    - Click 4: Genotype returns, INSTI resistance, disengagement
    - Click 5: W38 return, VL undetectable
    - Click 6: W42 re-initiation, W107 publication data
  - [ ] If single slide is too cramped, split into slide 14a (timeline through viremia) and 14b (resolution through publication)
- [ ] Slide 15: Patient 2 update/today -- Stat callout "195+ weeks", teaching points as numbered list, CAPELLA trial reference
- [ ] Add speaker notes for all three slides

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `specs/053_hiv_grand_rounds_slidev/presentation/slides.md` -- Slides 13-15 content
- `specs/053_hiv_grand_rounds_slidev/presentation/styles/index.css` -- Timeline-specific CSS (dose circles, arrow, callout boxes)

**Verification**:
- Timeline renders as horizontal layout with colored dose markers
- v-click progressive reveal works through all 6 stages
- Colors match scheme (purple, green, orange circles; gold callout boxes)
- Speaker notes for slide 14 are comprehensive (longest notes in deck)

---

### Phase 4: Patient Cases and Polls (Slides 6-12, 16-22) [NOT STARTED]

**Goal**: Complete all remaining patient case slides, poll slides, and resolution slides.

**Tasks**:
- [ ] **Patient 1 block (slides 6-12)**:
  - [ ] Slide 6: Case divider -- Teal, "Patient 1", brief descriptor
  - [ ] Slide 7: Background -- Two-column or bullet, demographics, HIV history, genotype (Y181C + M184V), baseline labs
  - [ ] Slide 8: Poll 1 -- Poll Everywhere placeholder, "Would you start LA-ART?", 5 options with (D) marked correct in notes
  - [ ] Slide 9: Poll 1 Answer + Clinical Course -- Answer reveal with reasoning for each option, Phase 1 success (14 months), disappearance narrative
  - [ ] Slide 10: Poll 2 -- "What do you do today?", 5 options
  - [ ] Slide 11: Resolution + LEN Pharmacology -- VL undetectable stat callout, two teaching points (low-barrier, LEN tail), Phase 2 success, citation
  - [ ] Slide 12: LTFU + Population Question -- Current status, silver lining hypothesis, population-level question callout box, discussion prompt
- [ ] **Patient 3 block (slides 16-19)**:
  - [ ] Slide 16: Case divider -- Teal
  - [ ] Slide 17: Background -- Dense bullet, hospital course, Care Everywhere data, patient demands
  - [ ] Slide 18: Poll 3 -- "What do you do?", 5 options
  - [ ] Slide 19: Resolution -- Visit 1 (sent away), Visit 2 (emergency Cabenuva), "Why this was hard" section, closing line
- [ ] **Patient 4 block (slides 20-22)**:
  - [ ] Slide 20: Case divider -- Teal
  - [ ] Slide 21: Background -- Dense clinical content (may need content overflow handling or smaller font), pericardial history, IRIS context
  - [ ] Slide 22: Poll 4 -- "What do you do?", 5 options with discussion points, Nicky's lean toward E
- [ ] Add speaker notes to all 17 slides
- [ ] Apply v-click reveals on poll answer slides (show question first, then reveal correct answer)
- [ ] Ensure consistent styling across all case divider slides

**Timing**: 1.5 hours

**Depends on**: 2, 3

**Files to modify**:
- `specs/053_hiv_grand_rounds_slidev/presentation/slides.md` -- Slides 6-12, 16-22 content

**Verification**:
- All four case divider slides (6, 13, 16, 20) use identical teal divider styling
- Poll slides (8, 10, 18, 22) have clear placeholder areas for Poll Everywhere QR codes
- Poll answer reveals use v-click for progressive disclosure
- Slide 21 (Patient 4, dense content) is readable without text overflow
- Speaker notes present on all 17 slides

---

### Phase 5: Closing Slide, Final Assembly, and Testing [NOT STARTED]

**Goal**: Add the closing/takeaways slide, verify full deck order, test navigation, and ensure presenter mode works end-to-end.

**Tasks**:
- [ ] Slide 23: Takeaways / Thank You -- 5 numbered takeaways with bold key phrases, citations section at bottom, closing layout
- [ ] Verify slide ordering matches research report (1-23 in correct sequence)
- [ ] Test full slide navigation (forward/backward through all 23+ slides including v-click steps)
- [ ] Test presenter mode with speaker notes on all slides
- [ ] Verify all v-click animations work correctly (especially Patient 2 timeline)
- [ ] Check font rendering (EB Garamond headings, Arial/Inter body text)
- [ ] Verify color consistency across all slide types (divider-teal, content-navy, content-white)
- [ ] Test slide export (`npx slidev export`) produces PDF
- [ ] Fix any layout issues, text overflow, or styling inconsistencies discovered during testing

**Timing**: 0.5 hours

**Depends on**: 4

**Files to modify**:
- `specs/053_hiv_grand_rounds_slidev/presentation/slides.md` -- Slide 23, any fixes
- `specs/053_hiv_grand_rounds_slidev/presentation/styles/index.css` -- Any style fixes

**Verification**:
- Complete 23-slide deck renders without errors
- All speaker notes visible in presenter mode
- PDF export succeeds
- No broken layouts or missing styles
- Timeline animation on slide 14 plays through correctly

## Testing & Validation

- [ ] `npx slidev` launches successfully from the presentation directory
- [ ] All 23 slides render with correct content matching research report
- [ ] UCSF institutional theme applied: navy/teal colors, Garamond headings
- [ ] Speaker notes present on all 23 slides
- [ ] v-click animations work on data slides and poll answer slides
- [ ] Patient 2 timeline (slide 14) progressive reveal works through all stages
- [ ] Stat callouts ("100%", "195+ weeks") are visually prominent
- [ ] Comparison table (slide 4) is readable with proper alignment
- [ ] Case divider slides (4 total) have consistent teal styling
- [ ] Poll slides (4 total) have clear QR code/link placeholder areas
- [ ] PDF export via `npx slidev export` produces valid output
- [ ] Total slide count matches 23 (or 24 if Patient 2 timeline is split)

## Artifacts & Outputs

- `specs/053_hiv_grand_rounds_slidev/presentation/package.json` -- Slidev project configuration
- `specs/053_hiv_grand_rounds_slidev/presentation/slides.md` -- Complete 23-slide deck
- `specs/053_hiv_grand_rounds_slidev/presentation/styles/index.css` -- UCSF institutional theme CSS
- `specs/053_hiv_grand_rounds_slidev/summaries/01_implementation-summary.md` -- Post-implementation summary

## Rollback/Contingency

The entire presentation is self-contained in `specs/053_hiv_grand_rounds_slidev/presentation/`. If implementation fails, delete that directory and re-run `/implement 53`. The source material (research report and original markdown) remain unmodified. If the Patient 2 timeline proves too complex for pure CSS/HTML, fall back to a simplified bullet-point timeline without the horizontal arrow visualization.
