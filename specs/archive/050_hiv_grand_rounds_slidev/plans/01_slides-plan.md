# Implementation Plan: HIV Grand Rounds Slidev Presentation

- **Task**: 50 - HIV Grand Rounds: MXM LA-ART & LA-PrEP presentation (Slidev)
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/050_hiv_grand_rounds_slidev/reports/01_slides-research.md
- **Artifacts**: plans/01_slides-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: slides
- **Lean Intent**: false

## Overview

Build a 23-slide Slidev presentation for HIV Grand Rounds covering the MXM long-acting ART and PrEP programs at UCSF/ZSFG. The presentation uses the ucsf-institutional theme (navy/Pacific Blue palette, Garamond serif headings) with custom layouts for divider slides, poll slides, and two-column content. The slide-mapped research report provides complete content for all 23 slides including speaker notes, so the implementation focus is on project scaffolding, theme/layout authoring, content generation with Vue components, and Playwright verification. Output is a fully functional Slidev project at `talks/50_hiv_grand_rounds_slidev/`.

### Research Integration

The research report at `specs/050_hiv_grand_rounds_slidev/reports/01_slides-research.md` provides a complete 23-slide map with per-slide content, layout recommendations, speaker notes in the presenter's clinical voice, design rules (sparse text, big stat callouts, no patient initials), and the recommended ucsf-institutional color palette (navy #052049, Pacific Blue #0093D0, teal highlight #16A0AC). All slides are status "mapped" with no content gaps. Key implementation notes from the report: Slide 14 (Patient 2 timeline) needs progressive v-click reveal; Slide 21 (Patient 4) may need splitting due to content density; poll slides need placeholder slots for Poll Everywhere QR codes.

### Prior Plan Reference

Task 49 produced a PPTX plan for the same content. Key learnings: 5-phase structure worked well (scaffold, data slides, case slides, closing, verification); Slide 21 content density was flagged as high-risk and should be split; Patient 2 timeline (Slide 14) required the most design effort; template layout inspection was a valuable early step. The Slidev version does not need template inspection (layouts are authored, not discovered) but benefits from the same phase grouping by slide sections. Effort was estimated at 5 hours for PPTX; Slidev should be slightly less due to markdown simplicity vs python-pptx API, but theme authoring adds overhead. Estimated 4 hours.

### Roadmap Alignment

No active roadmap items for this task.

## Goals & Non-Goals

**Goals**:
- Scaffold a complete Slidev project with scaffold template files, pnpm configuration, and lz-string ESM shim
- Author custom Slidev layouts: `divider-teal`, `poll`, `two-cols-navy`, `stat-callout`
- Generate `slides.md` with all 23 slides, correct layout frontmatter, and speaker notes as HTML comments
- Implement the ucsf-institutional theme as CSS custom properties (navy headings, serif fonts, UCSF color palette)
- Use Vue components (StatResult, DataTable) where appropriate for slides 3 and 4
- Build progressive v-click reveal for Patient 2 timeline (Slide 14) and poll answer slides
- Include Poll Everywhere placeholder slots on poll slides (presenter fills QR codes manually)
- Verify all slides render via Playwright

**Non-Goals**:
- Embedding live Poll Everywhere iframes or functional QR codes
- Mermaid diagrams (timeline uses CSS/HTML, not mermaid)
- PDF export optimization (presenter uses web-based Slidev SPA)
- Custom Vue components beyond what exists in the talk library

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Custom layouts (divider-teal, poll) may not render as expected in Slidev | H | M | Test each layout with a minimal slide before populating all content; use slidev build early to catch Vue errors |
| Shiki inline code black boxes on dark-background slides | M | H | Apply !important CSS overrides for inline code per slidev-pitfalls.md |
| Slide 21 (Patient 4) too dense for single slide | M | H | Split into 21a (demographics/OIs) and 21b (pericardial/IRIS) during Phase 3 |
| Patient 2 timeline v-click progressive reveal too complex | M | M | Use styled HTML divs with v-click directives; fall back to simple bullet list if CSS timeline breaks |
| pnpm or Node.js not available on build machine | H | L | Check availability in Phase 1; document manual install steps |
| Vue components from talk library incompatible with Slidev version | M | L | Copy components and test with slidev build; use plain markdown fallback if components fail |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Project Scaffolding and Theme Setup [NOT STARTED]

**Goal**: Create the Slidev project directory with all scaffold files, custom CSS theme derived from ucsf-institutional.json, and custom layouts for the 4 non-standard slide types.

**Tasks**:
- [ ] Create project directory `talks/50_hiv_grand_rounds_slidev/`
- [ ] Copy scaffold files from `.claude/context/project/present/talk/templates/slidev-project/` (package.json, .npmrc, vite.config.ts, lz-string-esm.js)
- [ ] Update package.json: replace DECK_NAME with `hiv-grand-rounds-slidev`, DECK_DESCRIPTION with task description
- [ ] Read `ucsf-institutional.json` theme and generate `talks/50_hiv_grand_rounds_slidev/style.css` with CSS custom properties (--slidev-theme-primary: #052049, --slidev-theme-accent: #0093D0, heading font Garamond/Georgia serif, body font Arial sans-serif)
- [ ] Add Shiki inline code CSS override (`:not(pre) > code` with !important) per slidev-pitfalls.md
- [ ] Create `talks/50_hiv_grand_rounds_slidev/layouts/` directory
- [ ] Author `layouts/divider-teal.vue` -- teal (#16A0AC) background, centered white text, section title + subtitle slots
- [ ] Author `layouts/poll.vue` -- styled layout with prominent question text, answer choices as lettered list, Poll Everywhere placeholder area
- [ ] Author `layouts/two-cols-navy.vue` -- navy (#052049) dark background, two-column grid, white text
- [ ] Author `layouts/stat-callout.vue` -- large centered stat number with supporting bullet content below
- [ ] Copy needed Vue components from talk library to `talks/50_hiv_grand_rounds_slidev/components/`: StatResult.vue, DataTable.vue, CitationBlock.vue
- [ ] Run `pnpm install` (if available) to verify project builds
- [ ] Create a minimal `slides.md` with 1 test slide per custom layout, run `npx @slidev/cli build` to confirm no Vue compile errors

**Timing**: 1.5 hours

**Depends on**: none

**Files to create**:
- `talks/50_hiv_grand_rounds_slidev/package.json` - Copied from scaffold
- `talks/50_hiv_grand_rounds_slidev/.npmrc` - Copied from scaffold
- `talks/50_hiv_grand_rounds_slidev/vite.config.ts` - Copied from scaffold
- `talks/50_hiv_grand_rounds_slidev/lz-string-esm.js` - Copied from scaffold
- `talks/50_hiv_grand_rounds_slidev/style.css` - UCSF institutional theme CSS
- `talks/50_hiv_grand_rounds_slidev/layouts/divider-teal.vue` - Teal divider layout
- `talks/50_hiv_grand_rounds_slidev/layouts/poll.vue` - Poll question layout
- `talks/50_hiv_grand_rounds_slidev/layouts/two-cols-navy.vue` - Navy two-column layout
- `talks/50_hiv_grand_rounds_slidev/layouts/stat-callout.vue` - Stat callout layout
- `talks/50_hiv_grand_rounds_slidev/components/StatResult.vue` - Stat display component
- `talks/50_hiv_grand_rounds_slidev/components/DataTable.vue` - Data table component
- `talks/50_hiv_grand_rounds_slidev/components/CitationBlock.vue` - Citation component

**Verification**:
- `pnpm install` completes without errors
- `npx @slidev/cli build` completes with 0 exit code on test slides
- Each custom layout renders without Vue compile errors

---

### Phase 2: Data Slides (Slides 1-5) and Case Dividers [NOT STARTED]

**Goal**: Author the opening divider, 4 program data slides, and 4 case divider slides in slides.md. These are the slides with the most structured data content.

**Tasks**:
- [ ] Replace test slides.md with production frontmatter (theme: none, title, author "Nicky Mehtani, MD MPH", date "April 2026", transition: slide-left, mdc: true)
- [ ] Slide 1: divider-teal layout -- "LA-ART & LA-PrEP at MXM", subtitle "HIV Grand Rounds, UCSF/ZSFG", presenter, date
- [ ] Slide 2: two-cols-navy layout -- LA-ART demographics (left) and clinical complexity (right) for n=34 cohort
- [ ] Slide 3: stat-callout layout -- "100% virally suppressed" as hero stat, 747 injections, 93% on time, regimen breakdown below
- [ ] Slide 4: default layout -- Oral vs LA-ART comparison table (markdown table; no Vue components in table cells), caveat text below
- [ ] Slide 5: default layout -- LA-PrEP data (n=68 prescribed, 52 initiated, retention stats, 2 seroconversions, key message)
- [ ] Slides 6, 13, 16, 20: divider-teal layout -- Patient 1/2/3/4 case dividers with brief context lines
- [ ] Add speaker notes as `<!-- Speaker notes: ... -->` HTML comments for all 9 slides
- [ ] Run `npx @slidev/cli build` to verify no errors on data slides

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `talks/50_hiv_grand_rounds_slidev/slides.md` - Replace with production content (slides 1-6, 13, 16, 20)

**Verification**:
- `npx @slidev/cli build` exits 0
- 9 slides present in output (data + dividers)
- Speaker notes present for each slide

---

### Phase 3: Patient Case Slides (Slides 7-12, 14-15, 17-19, 21-22) [NOT STARTED]

**Goal**: Author all patient case content slides, poll slides, and the Patient 2 timeline slide with progressive reveal. This is the largest content phase covering 14 slides.

**Tasks**:
- [ ] Slides 7, 9: Patient 1 background and poll answer/course -- default layout with v-click reveals on answer slide
- [ ] Slide 8: Patient 1 Poll 1 -- poll layout with question and 5 answer choices (mark D as correct in speaker notes only)
- [ ] Slide 10: Patient 1 Poll 2 -- poll layout with 5 answer choices
- [ ] Slide 11: Patient 1 resolution + LEN pharmacology -- default layout with styled teaching point callout boxes (use CSS bordered div or blockquote styling)
- [ ] Slide 12: Patient 1 LTFU + population question -- default layout
- [ ] Slide 14: Patient 2 timeline -- default layout with custom HTML/CSS horizontal timeline using v-click steps for progressive reveal (Phase 1 -> Pre-genotype decision -> Genotype returns -> Phase 2); use colored markers (purple initiation, green on-time, orange delayed) and lab value annotations
- [ ] Slide 15: Patient 2 today update -- default layout with 5 teaching points
- [ ] Slides 17, 19: Patient 3 background and resolution -- default layout
- [ ] Slide 18: Patient 3 Poll 3 -- poll layout
- [ ] Slide 21a: Patient 4 demographics and OI history -- default layout (first half of original slide 21 content)
- [ ] Slide 21b: Patient 4 pericardial history and IRIS question -- default layout (second half; makes total 24 slides in deck)
- [ ] Slide 22: Patient 4 Poll 4 -- poll layout with 5 answer choices, "no correct answer" noted
- [ ] Add speaker notes for all 14-15 slides (15 if slide 21 split)
- [ ] Run `npx @slidev/cli build` to verify all slides compile

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `talks/50_hiv_grand_rounds_slidev/slides.md` - Add patient case slides after data section

**Verification**:
- `npx @slidev/cli build` exits 0
- v-click directives on Slide 9 and Slide 14 do not cause build errors
- Timeline slide (14) uses HTML/CSS elements with v-click, not mermaid
- Slide 21 split into 21a and 21b if content too dense

---

### Phase 4: Closing Slide and Final Polish [NOT STARTED]

**Goal**: Author the closing/takeaways slide, verify slide count, and polish any styling issues across the full deck.

**Tasks**:
- [ ] Slide 23: Closing slide -- default or custom end layout with 5 numbered takeaways, citations list, and "Thank you" element
- [ ] Add speaker notes for closing slide
- [ ] Review full slides.md for consistent formatting: frontmatter separators (---), layout declarations, speaker note format
- [ ] Verify total slide count matches expected (23 or 24 if slide 21 was split)
- [ ] Check that all dark-background slides (divider-teal, two-cols-navy) have white text styling
- [ ] Verify no Vue components appear inside markdown pipe tables (use HTML tables if needed per slidev-pitfalls.md)
- [ ] Run `npx @slidev/cli build` for full deck validation

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- `talks/50_hiv_grand_rounds_slidev/slides.md` - Add closing slide, polish formatting

**Verification**:
- Full deck builds without errors
- Slide count is 23-24
- All slides have speaker notes
- No markdown table contains Vue components

---

### Phase 5: Playwright Slide Verification [NOT STARTED]

**Goal**: Verify every slide renders without errors using Playwright, fix any broken slides, and confirm the deck is presentation-ready.

**Tasks**:
- [ ] Copy `.claude/context/project/present/talk/templates/playwright-verify.mjs` to `talks/50_hiv_grand_rounds_slidev/scripts/verify-slides.mjs`
- [ ] Start Slidev dev server in background (`pnpm dev &`)
- [ ] Run `node scripts/verify-slides.mjs --screenshots` to test every slide
- [ ] Fix any slides that report VISIBLE ERROR or console errors
- [ ] Re-run verification until all slides pass (exit code 0)
- [ ] Run `pnpm run export` to produce final PDF (if Playwright/chromium available)
- [ ] Verify PDF page count matches slide count
- [ ] Stop dev server

**Timing**: 0.5-1 hour

**Depends on**: 4

**Files to modify**:
- `talks/50_hiv_grand_rounds_slidev/scripts/verify-slides.mjs` - Copied from template
- `talks/50_hiv_grand_rounds_slidev/slides.md` - Fix any broken slides found during verification

**Verification**:
- `verify-slides.mjs` exits 0 (all slides pass)
- No "An error occurred on this slide" on any page
- Screenshots directory shows all slides rendering with content (no blank slides)
- PDF export matches slide count (if Playwright available; otherwise note as manual step)

## Testing & Validation

- [ ] `pnpm install` completes without errors in project directory
- [ ] `npx @slidev/cli build` exits 0 for the full deck
- [ ] Playwright verification script exits 0 for all slides
- [ ] All 23-24 slides have speaker notes in HTML comment format
- [ ] Custom layouts (divider-teal, poll, two-cols-navy, stat-callout) render correctly
- [ ] No Shiki black boxes on dark-background slides
- [ ] No Vue components inside markdown pipe tables
- [ ] v-click progressive reveals work on slides 9 and 14
- [ ] Poll slides have visible placeholder area for Poll Everywhere QR codes

## Artifacts & Outputs

- `talks/50_hiv_grand_rounds_slidev/slides.md` - Main presentation file (23-24 slides)
- `talks/50_hiv_grand_rounds_slidev/style.css` - UCSF institutional theme CSS
- `talks/50_hiv_grand_rounds_slidev/package.json` - Project configuration
- `talks/50_hiv_grand_rounds_slidev/.npmrc` - pnpm configuration
- `talks/50_hiv_grand_rounds_slidev/vite.config.ts` - Vite alias configuration
- `talks/50_hiv_grand_rounds_slidev/lz-string-esm.js` - ESM shim
- `talks/50_hiv_grand_rounds_slidev/layouts/` - Custom Vue layouts (4 files)
- `talks/50_hiv_grand_rounds_slidev/components/` - Vue components (3 files)
- `talks/50_hiv_grand_rounds_slidev/scripts/verify-slides.mjs` - Playwright verification
- `specs/050_hiv_grand_rounds_slidev/plans/01_slides-plan.md` - This plan file

## Rollback/Contingency

The entire Slidev project is contained in `talks/50_hiv_grand_rounds_slidev/`. If the implementation fails or the presentation needs to be reverted, delete or rename the project directory. The research report and plan remain in `specs/050_hiv_grand_rounds_slidev/` and can be used to regenerate. If custom layouts prove too fragile, fall back to Slidev's built-in `default`, `center`, `two-cols`, and `cover` layouts with CSS class overrides for theming. If Playwright verification is unavailable on the build machine (NixOS Chromium issues), use `npx @slidev/cli build` as a compile-only check and defer visual verification to manual browser inspection.
