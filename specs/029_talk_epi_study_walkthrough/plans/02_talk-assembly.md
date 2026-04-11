# Implementation Plan: Talk Assembly -- /epi Workflow Walkthrough (Round 2)

- **Task**: 29 - talk_epi_study_walkthrough
- **Status**: [IMPLEMENTING]
- **Effort**: 9.5 hours
- **Dependencies**: task 28 (R stack upgrade + rerun) - COMPLETED
- **Research Inputs**: specs/029_talk_epi_study_walkthrough/reports/02_talk-research.md
- **Artifacts**: plans/02_talk-assembly.md (this file); examples/epi-slides/**
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Assemble a 14-slide CONFERENCE talk (18 min + 2 min Q&A) that walks a mixed
clinical/informatics audience through the `examples/epi-study/` synthetic RCT
as a showcase of the `/epi` Claude Code workflow. The build uses **Slidev**
with the `academic-clean` theme and reuses the five canonical talk-library
Vue components (FigurePanel, DataTable, CitationBlock, StatResult,
FlowDiagram), plus one new CodeDiff component for the slide 10 before/after
bands. All build artifacts (slides source, theme, components, assets, build
scripts, README) live under `examples/epi-slides/`; the `specs/029_*` tree
retains only this plan and the eventual implementation summary. Definition
of done: `slidev build` produces `dist/` and `slidev export` produces a
14-page PDF, with all figure/table assets rendered from the task-28 enriched
outputs (Cox HR 0.426, pooled MICE OR 3.262, byte-identical SHA256 receipts).

### Research Integration

The round-2 research report provides an authoritative slide-by-slide
specification with three high-emphasis numerical anchors: (1) byte-identical
reproduction across an R stack upgrade with SHA256 receipts, (2) `coxph`
HR 0.426 (PH holds, p < 1e-5), (3) pooled MICE OR 3.262 with 0.77%
deviation from complete-case. Slides 10, 11, and 12 receive major rewrites.
All content slots are filled -- the research report lists zero content gaps.

### Prior Plan Reference

No prior plan. This is the first plan for task 29. (Round 1 research was
superseded by round 2 after task 28 completed the stack upgrade.)

### Roadmap Alignment

No ROADMAP.md consulted in delegation context for this task. The talk
advances the broader goal of surfacing the `/epi` extension as a flagship
example of the agent system's end-to-end workflow.

## Goals & Non-Goals

**Goals**:
- Produce a Slidev deck of exactly 14 slides at `examples/epi-slides/` that
  implements the slide map from report 02 section "Slide Map (Updated)".
- Stand up a reusable `academic-clean` theme and the 5 canonical components
  (+ 1 new CodeDiff) under `examples/epi-slides/components/`.
- Wire all figure and table assets from `examples/epi-study/reports/` so the
  deck reads from the canonical task-28 enriched outputs.
- Ship a `README.md` documenting build/export/watch commands plus speaker
  notes and a rehearsal checklist.
- Verify: `slidev build` and `slidev export` both succeed and the exported
  PDF is exactly 14 pages.

**Non-Goals**:
- Writing any files under `specs/029_*/` other than this plan and (later)
  the implementation summary.
- Delivering a live `/epi` demo or pre-recorded screencap (deferred; see
  report 02 "Open Questions").
- Venue-specific rebranding, author affiliation, or Anthropic acknowledgment
  (deferred -- open questions for `/slides 29 --design`).
- Touying/Polylux variants -- Slidev only, per talk-library default and the
  Vue components already provided by `.claude/context/project/present/talk/`.
- Modifying anything under `examples/epi-study/` (source of truth; read-only).
- A renv lockfile, `flake.nix` pinning, or a CI SHA256 loop (those are
  slide 14 "what's next" items, not deliverables of this plan).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Synthetic-data misquotation (e.g., "KAT reduces relapse 57%" without caveat) | H | M | Amber caveat banner on slides 1, 7, 9, 10, 13; synthetic-DGP strap line on slide 10; speaker notes make the caveat verbatim |
| Slidev component API drift vs talk library Vue source | M | M | Copy components verbatim from `.claude/context/project/present/talk/components/`; pin Slidev version in `package.json`; smoke-test in Phase 2 |
| Asset paths break when deck moved or built outside repo | M | L | Use Slidev `/public/` convention with relative paths; copy (not symlink) assets into `examples/epi-slides/public/assets/` in Phase 3 |
| PDF export differs from live deck (fonts, Mermaid) | M | M | Phase 6 verification renders PDF and compares slide count; include Mermaid diagrams rather than SVG screenshots where possible |
| Over-run 18-minute budget at 14 x 75s | L | M | Slide-level speaker note timing from report 02; phase 5 rehearsal checklist asks speaker to time slide 12 (90s) and slide 6 (60s) |
| `broom.helpers` missing from footnote text becomes stale | L | L | Phase 5 footnote references `logs/rerun_028/branch_probe.txt`; flag if upstream installs land |
| Cox HR 0.426 misquoted as real clinical evidence | H | M | Slide 10 strap line "(synthetic DGP -- slide 7)" + speaker-note verbatim script |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4, 5 | 2, 3 |
| 4 | 6 | 4, 5 |
| 5 | 7 | 6 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Scaffold `examples/epi-slides/` [COMPLETED]

**Goal**: Create the project skeleton under `examples/epi-slides/` with
Slidev installed, directory layout ready for theme/components/assets/slides,
and a README stub.

**Tasks**:
- [ ] Create directory `examples/epi-slides/` with subdirs: `components/`,
      `theme/`, `public/assets/figures/`, `public/assets/tables/`,
      `snippets/`, `scripts/`.
- [ ] Write `package.json` pinning Slidev (`@slidev/cli`,
      `@slidev/theme-default` as a base), Vue 3, and a Mermaid addon
      version. Add `dev`, `build`, `export` npm scripts.
- [ ] Write `slides.md` stub with front-matter declaring `theme:
      ./theme`, title "The /epi Workflow: A Synthetic RCT Walkthrough",
      and an empty body so `slidev dev` starts successfully.
- [ ] Write `README.md` stub with sections: Overview, Prerequisites
      (node, pnpm), Build, Export, Watch, Source of Truth (pointer to
      `examples/epi-study/` and `specs/029_*/reports/02_talk-research.md`).
- [ ] Add `.gitignore` for `node_modules/`, `dist/`, `*.log`.
- [ ] Smoke-test: `pnpm install` (or `npm install`) succeeds; `slidev build`
      on the stub exits 0.

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `examples/epi-slides/package.json` - new
- `examples/epi-slides/slides.md` - new stub
- `examples/epi-slides/README.md` - new stub
- `examples/epi-slides/.gitignore` - new

**Verification**:
- Directory tree matches spec (components/, theme/, public/assets/{figures,tables}/, snippets/, scripts/)
- `slidev build` on stub exits 0
- Git status shows only new files under `examples/epi-slides/`

---

### Phase 2: Theme + Components [COMPLETED]

**Goal**: Stand up the `academic-clean` theme and copy in the five canonical
Vue components plus author one new `CodeDiff` component for slide 10.

**Tasks**:
- [ ] Read `.claude/context/project/present/talk/themes/academic-clean.json`
      and translate its color/font/spacing tokens into a Slidev theme under
      `examples/epi-slides/theme/` (`index.ts`, `styles/index.css`, layouts
      directory with at least `default.vue`, `title.vue`, `section.vue`,
      `two-column.vue`).
- [ ] Add an amber caveat banner layout `caveat.vue` (for slides 1, 7, 9,
      10, 13) that renders a full-width amber strip with the text
      "Synthetic data -- not a clinical finding".
- [ ] Copy the five canonical components verbatim from
      `.claude/context/project/present/talk/components/` into
      `examples/epi-slides/components/`: `FigurePanel.vue`, `DataTable.vue`,
      `CitationBlock.vue`, `StatResult.vue`, `FlowDiagram.vue`.
- [ ] Author `components/CodeDiff.vue`: two-band layout with left "Before"
      and right "After" panels, each accepting a `title`, `lang`, and slot
      content; used by slide 10 for the base-R log-rank vs `coxph` contrast.
- [ ] Register Py/R/Quarto language badges as a small
      `components/LangBadge.vue` used in slide 6 (pipeline anatomy) and
      slide 12 (snapshot dimensions).
- [ ] Smoke-test: render a throwaway slide that instantiates each component
      with dummy data; `slidev build` exits 0.

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `examples/epi-slides/theme/index.ts` - new
- `examples/epi-slides/theme/styles/index.css` - new
- `examples/epi-slides/theme/layouts/default.vue` - new
- `examples/epi-slides/theme/layouts/title.vue` - new
- `examples/epi-slides/theme/layouts/section.vue` - new
- `examples/epi-slides/theme/layouts/two-column.vue` - new
- `examples/epi-slides/theme/layouts/caveat.vue` - new
- `examples/epi-slides/components/FigurePanel.vue` - copied
- `examples/epi-slides/components/DataTable.vue` - copied
- `examples/epi-slides/components/CitationBlock.vue` - copied
- `examples/epi-slides/components/StatResult.vue` - copied
- `examples/epi-slides/components/FlowDiagram.vue` - copied
- `examples/epi-slides/components/CodeDiff.vue` - new
- `examples/epi-slides/components/LangBadge.vue` - new

**Verification**:
- Theme loads; `slidev build` of a smoke-test slide with all six components exits 0
- Amber caveat banner visible and color-matches academic-clean amber token
- No Vue compile errors or component auto-import warnings

---

### Phase 3: Asset Import [COMPLETED]

**Goal**: Copy static figure and table assets from
`examples/epi-study/reports/` into `examples/epi-slides/public/assets/` and
expose text snippets (receipts, code samples) under `snippets/`.

**Tasks**:
- [ ] Copy `examples/epi-study/reports/tables/primary_results.txt`,
      `cox_results.txt`, `sensitivity_mice.txt`, `sensitivity_results.txt`,
      `primary_results_tidy.txt` into
      `examples/epi-slides/public/assets/tables/`.
- [ ] Copy `examples/epi-study/logs/rerun_028/identity_check.txt`,
      `baseline/sha256sums.txt`, `branch_probe.txt`, `branch_decision.txt`,
      `session_info_r.txt`, `session_info_py.txt`, `env_snapshot.txt`,
      `rerun_summary.md` into
      `examples/epi-slides/public/assets/receipts/`.
- [ ] Copy Quarto render
      `examples/epi-study/reports/rendered/consort_report.html` (and
      `consort_report_files/` bootstrap assets) into
      `examples/epi-slides/public/assets/consort/` for slide 8 thumbnail.
- [ ] Extract the grepped `identity_check.txt` "receipts" block (6 IDENTICAL
      lines + SHA256 banner + armKAT headline lines) into
      `snippets/slide12_receipts.txt` for verbatim embedding.
- [ ] Author Mermaid source for CONSORT flow (slide 8) and causal DAG (slide 5)
      under `snippets/mermaid/` so Slidev renders them natively.
- [ ] Author Mermaid source for the 4-command workflow diagram (slide 3).
- [ ] Write `scripts/sync-assets.sh`: re-copies task-28 outputs into
      `public/assets/` so the deck can be refreshed without manual `cp`.
      Idempotent; uses `rsync -a`.
- [ ] Smoke-test: `scripts/sync-assets.sh` succeeds; all target files exist
      with nonzero size.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `examples/epi-slides/public/assets/tables/*.txt` - copied
- `examples/epi-slides/public/assets/receipts/*` - copied
- `examples/epi-slides/public/assets/consort/consort_report.html` - copied
- `examples/epi-slides/snippets/slide12_receipts.txt` - extracted
- `examples/epi-slides/snippets/mermaid/consort_flow.mmd` - new
- `examples/epi-slides/snippets/mermaid/dag.mmd` - new
- `examples/epi-slides/snippets/mermaid/workflow.mmd` - new
- `examples/epi-slides/scripts/sync-assets.sh` - new executable

**Verification**:
- All 5 table files present in `public/assets/tables/`
- All 7 receipt files present in `public/assets/receipts/`
- `consort_report.html` present in `public/assets/consort/`
- `sync-assets.sh` rerun is idempotent (no diff second run)

---

### Phase 4: Author Slides 1-7 (Workflow + Methods) [COMPLETED]

**Goal**: Write slides 1 through 7 of the deck -- the workflow framing and
methods/CONSORT setup -- using the slide map from report 02 as the
authoritative spec.

**Tasks**:
- [ ] Slide 1 "Title & Synthetic-Data Caveat" using `caveat.vue` layout,
      date stamp "re-verified 2026-04-10 (task 28)".
- [ ] Slide 2 "Motivation -- The Scaffolding Tax" (text only, no assets).
- [ ] Slide 3 "The Four-Command Workflow" with Mermaid diagram from
      `snippets/mermaid/workflow.mmd`.
- [ ] Slide 4 "/epi Stage 0 -- Forcing Questions Are the Feature" with the
      self-referential footer callout about task 28 re-running the loop on
      itself; speaker note quoting the research report verbatim.
- [ ] Slide 5 "Study Design (PICO + DAG)" embedding the DAG Mermaid diagram
      from `snippets/mermaid/dag.mmd`.
- [ ] Slide 6 "Pipeline Anatomy -- Python <-> R Handoff" with the 6-row
      script table (including the new `06 quarto render` row) using
      `DataTable.vue`; `LangBadge.vue` for Py/R/Quarto tags.
- [ ] Slide 7 "Data-Generating Process (Honesty Slide)" with caveat banner.
- [ ] Insert speaker notes under each slide's `<!-- -->` comment block,
      matching the research report's speaker-note guidance.
- [ ] Smoke-test: `slidev build` exits 0 and deck opens with 7 slides.

**Timing**: 2 hours

**Depends on**: 2, 3

**Files to modify**:
- `examples/epi-slides/slides.md` - slides 1-7 content

**Verification**:
- `slidev build` produces a deck of 7 slides (intermediate state)
- Mermaid diagrams render (no "failed to parse" errors)
- Speaker notes present for each slide (grep for `<!--`)

---

### Phase 5: Author Slides 8-14 (Results + Reproducibility + Takeaways) [NOT STARTED]

**Goal**: Write slides 8 through 14 -- the high-emphasis results, Cox/MICE
tables, byte-identical receipts, limitations, and takeaways -- per the
slide map in report 02.

**Tasks**:
- [ ] Slide 8 "CONSORT Flow & Table 1" embedding the CONSORT Mermaid diagram;
      footnote "Rendered via Quarto from `consort_report.qmd`"; thumbnail
      link to `public/assets/consort/consort_report.html`.
- [ ] Slide 9 "Primary Result" using `StatResult.vue` for the big OR 3.29
      (95% CI 1.57-6.89, p = 0.0016); tertiary strip "Re-asserted across
      stack upgrade (task 28, 2026-04-10); profile CI 1.595-7.047 agrees to
      4 sig figs"; caveat banner.
- [ ] Slide 10 "Cox Now Runs" using new `CodeDiff.vue`:
      - Before band: hand-written Mantel-Cox log-rank + Gamma-GLM (chi^2 26.5, HR ~0.61)
      - After band: `coxph` HR 0.426 (95% CI 0.311-0.583, p < 1e-5), cox.zph GLOBAL p = 0.55, KM medians TAU 25.4 / KAT 40.5
      - Strap line "(synthetic DGP -- slide 7)" and caveat banner
      - Speaker note verbatim from report 02.
- [ ] Slide 11 "Sensitivity Suite" using `DataTable.vue` with the 6-row
      table (complete-case, per-protocol, single-imp, **MICE pooled**,
      worst-case, best-case); callouts on MICE row (0.77% deviation) and
      worst-case row (tipping-point honesty anchor).
- [ ] Slide 12 "Byte-Identical Across an Environment Upgrade" -- the climax.
      Two-column snapshot diff (snapshot A hostile vs snapshot B full stack,
      8 dimensions from report 02 table); bottom receipts strip from
      `snippets/slide12_receipts.txt` in a `<pre>` block; large caption
      verbatim from report 02. Budget 90 seconds of speaker time (note it).
- [ ] Slide 13 "Limitations & What's Synthetic" with the shrunken list
      (5 items: synthetic data, scale, preregistration, `broom.helpers`
      footnote, Wald vs profile CI); caveat banner.
- [ ] Slide 14 "Takeaways & What's Next" with 3 takeaways mirroring the
      executive summary, and the updated what's-next list (install
      `broom.helpers`, renv lockfile, `flake.nix`, CI loop, fork-ready
      `EPI_ANSWERS.md`); footer "Everything at `examples/epi-study/`,
      receipts at `logs/rerun_028/`".
- [ ] Speaker notes for all 7 slides, with slide 12 flagged as 90 seconds
      and slide 6 (phase 4) re-trimmed to ~60 seconds in the rehearsal
      checklist (see phase 7).
- [ ] Smoke-test: `slidev build` produces exactly 14 slides total.

**Timing**: 2 hours

**Depends on**: 2, 3

**Files to modify**:
- `examples/epi-slides/slides.md` - slides 8-14 content

**Verification**:
- Deck slide count = 14
- Slide 9 OR 3.29 visible
- Slide 10 CodeDiff renders both bands
- Slide 11 DataTable shows 6 rows including MICE pooled
- Slide 12 receipts pre-block renders verbatim from snippet file

---

### Phase 6: Build Verification [NOT STARTED]

**Goal**: Run the full build and export pipeline; verify slide count, PDF
integrity, and that Mermaid/components render in the final output.

**Tasks**:
- [ ] Run `pnpm run build` (Slidev SPA build) -- must exit 0 and produce
      `dist/` with index.html and asset bundles.
- [ ] Run `pnpm run export` (Slidev PDF export via Playwright) -- must exit
      0 and produce `dist/slides-export.pdf`.
- [ ] Verify PDF page count equals 14 (e.g. `pdfinfo` or `qpdf --show-npages`).
- [ ] Spot-check PDF: first page = title caveat, page 10 = CodeDiff both
      bands present, page 12 = receipts verbatim, page 14 = takeaways.
- [ ] Run `slidev export --format png` (or equivalent) to produce per-slide
      PNGs under `dist/slides-png/` for later screencap embedding.
- [ ] Log any build warnings to `scripts/build_check.log`; triage any
      accessibility/contrast warnings from the theme.
- [ ] Confirm no assets reference `examples/epi-study/` directly (all asset
      URLs go through `/assets/`).

**Timing**: 1 hour

**Depends on**: 4, 5

**Files to modify**:
- `examples/epi-slides/dist/` - generated
- `examples/epi-slides/scripts/build_check.log` - generated

**Verification**:
- `dist/slides-export.pdf` exists and is 14 pages
- `dist/index.html` exists
- Build exit codes all 0
- No references to absolute paths outside `examples/epi-slides/` in
  rendered HTML (grep `dist/` for `/examples/epi-study/`)

---

### Phase 7: README + Speaker Notes + Rehearsal Checklist [NOT STARTED]

**Goal**: Finalize `README.md` with full build instructions, document
speaker notes per slide, and provide a rehearsal checklist anchored to the
17.5-minute time budget.

**Tasks**:
- [ ] Expand `README.md` from stub: Overview (pointer to
      `specs/029_*/reports/02_talk-research.md` as the source of truth),
      Prerequisites (node, pnpm, Playwright chromium for PDF export),
      Commands (`pnpm dev`, `pnpm build`, `pnpm export`,
      `scripts/sync-assets.sh`), Output Layout (`dist/`), How to Update
      (re-run sync-assets if `examples/epi-study/` changes).
- [ ] Add README section "Source Materials" linking to the five table files,
      Quarto render, identity check, baseline SHA256 sums.
- [ ] Add README section "Slide Map" with a one-line summary of each of the
      14 slides and their pacing budget (1-9: 70s, 10: 80s, 11: 80s,
      12: 90s, 13-14: 70s).
- [ ] Author `REHEARSAL.md` with the rehearsal checklist: timing targets,
      the three key-message checkpoints, speaker cues for the caveat
      banners, and the "do not attempt live /epi" reminder.
- [ ] Author `SPEAKER_NOTES.md` (optional consolidated view) cross-linking
      to the inline speaker notes in `slides.md`.
- [ ] Document the open questions deferred from report 02 (venue, time
      budget, speaker identity, live demo appetite, caveat wording,
      backup Q&A slides) under a README "Open Questions" section so the
      next `/slides 29 --design` pass has a clear starting point.
- [ ] Final pass: re-run `pnpm build` after README changes to confirm no
      regression.

**Timing**: 0.5 hours

**Depends on**: 6

**Files to modify**:
- `examples/epi-slides/README.md` - expanded
- `examples/epi-slides/REHEARSAL.md` - new
- `examples/epi-slides/SPEAKER_NOTES.md` - new (optional)

**Verification**:
- `README.md` has all sections listed
- `REHEARSAL.md` lists timing for every slide summing to ~17.5 minutes
- Final `pnpm build` still exits 0

---

## Testing & Validation

- [ ] `slidev build` exits 0 from `examples/epi-slides/`
- [ ] `slidev export` produces `dist/slides-export.pdf`
- [ ] PDF page count is exactly 14
- [ ] Every slide renders its referenced asset (no broken image/data refs)
- [ ] Mermaid diagrams on slides 3, 5, 8 render without parse errors
- [ ] All six talk-library components (FigurePanel, DataTable, CitationBlock,
      StatResult, FlowDiagram, CodeDiff) render at least once
- [ ] Amber caveat banner appears on slides 1, 7, 9, 10, 13
- [ ] Slide 9 shows OR 3.29 with 95% CI 1.57-6.89 in StatResult
- [ ] Slide 10 shows Cox HR 0.426 in CodeDiff "After" band
- [ ] Slide 11 shows MICE pooled OR 3.26 row
- [ ] Slide 12 receipts block is verbatim from `snippets/slide12_receipts.txt`
- [ ] `scripts/sync-assets.sh` is idempotent
- [ ] No file written outside `examples/epi-slides/` (except plan and later summary)

## Artifacts & Outputs

- `examples/epi-slides/package.json` -- pinned Slidev/Vue/Mermaid versions
- `examples/epi-slides/slides.md` -- 14-slide Slidev markdown source
- `examples/epi-slides/README.md` -- build/export/watch instructions and slide map
- `examples/epi-slides/REHEARSAL.md` -- timing and rehearsal checklist
- `examples/epi-slides/SPEAKER_NOTES.md` -- consolidated speaker notes
- `examples/epi-slides/theme/` -- academic-clean Slidev theme (index.ts, styles, layouts)
- `examples/epi-slides/components/FigurePanel.vue`
- `examples/epi-slides/components/DataTable.vue`
- `examples/epi-slides/components/CitationBlock.vue`
- `examples/epi-slides/components/StatResult.vue`
- `examples/epi-slides/components/FlowDiagram.vue`
- `examples/epi-slides/components/CodeDiff.vue` -- new for slide 10
- `examples/epi-slides/components/LangBadge.vue` -- new for slides 6 and 12
- `examples/epi-slides/public/assets/tables/*.txt` -- 5 table files from task 28
- `examples/epi-slides/public/assets/receipts/*` -- 7 receipt/provenance files
- `examples/epi-slides/public/assets/consort/consort_report.html`
- `examples/epi-slides/snippets/slide12_receipts.txt`
- `examples/epi-slides/snippets/mermaid/{workflow,dag,consort_flow}.mmd`
- `examples/epi-slides/scripts/sync-assets.sh`
- `examples/epi-slides/scripts/build_check.log`
- `examples/epi-slides/dist/slides-export.pdf` -- 14-page PDF export
- `examples/epi-slides/dist/index.html` -- SPA build
- `specs/029_talk_epi_study_walkthrough/plans/02_talk-assembly.md` -- this plan
- `specs/029_talk_epi_study_walkthrough/summaries/02_talk-assembly-summary.md` -- post-implementation

## Rollback/Contingency

If the Slidev build fails irrecoverably (component incompatibility, theme
bug, Mermaid parse failures), the fallback plan is:

1. Revert `examples/epi-slides/` to the Phase 1 scaffold state (remove
   `slides.md` content and `dist/`), preserving the directory itself.
2. Re-author slides as a flat `slides.md` using only built-in Slidev
   layouts (no custom theme, no custom components), keeping all content
   from the report 02 slide map. This trades polish for reliability and
   can ship in ~2 hours.
3. If Slidev itself is blocked, the contingency is Typst Touying using the
   same asset layout under `examples/epi-slides/touying/`; this is a 4-hour
   rewrite and requires re-authoring components as Touying functions.
4. As a last resort, export the deck as a plain PDF generated from a
   single-file Typst or Markdown document -- ugly but deliverable.

All rollback paths preserve `examples/epi-study/` untouched; no task-28
artifacts are modified or moved under any contingency.
