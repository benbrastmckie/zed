# Implementation Plan: Improve Slidev Review Pipeline

- **Task**: 34 - Improve Slidev review pipeline to catch rendering issues during first implementation
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_team-research.md
- **Artifacts**: plans/01_improve-slidev-pipeline.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The Slidev implementation pipeline currently forces agents to reconstruct project scaffolding from prose documentation, leading to six (now seven) classes of rendering errors that are only caught during manual post-hoc debugging. This plan creates a concrete template scaffold directory, fixes two `npx slidev` bugs (should be `npx @slidev/cli`), enhances the Playwright verification script to capture `console.error` messages, updates pitfalls documentation with all seven issue classes, and ensures context loading is explicit rather than implicit. Done when: template directory exists with four files, pitfalls doc covers all seven issues with prevention guidance, Playwright script captures both `pageerror` and `console.error`, and index.json entries are current.

### Research Integration

Integrated findings from `reports/01_team-research.md` (4-teammate team research):
- Teammate A: Identified `npx slidev` bug in both slidev-pitfalls.md (line 44) and playwright-verify.mjs (line 17); confirmed no template directory exists; found stale index.json entry
- Teammate B: Proposed three-layer error model (pre-flight, slidev build, Playwright); identified `console.error` gap vs existing `pageerror` capture
- Critic: Identified 7th issue class (footer/absolute positioning overlap); flagged NixOS/Playwright tension; noted implicit context loading fragility
- Teammate D: Confirmed Slidev as committed long-term tool; template scaffold is highest leverage deliverable

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No active roadmap items. ROADMAP.md is empty.

## Goals & Non-Goals

**Goals**:
- Create a Slidev project template directory that agents copy when scaffolding new decks
- Fix the `npx slidev` -> `npx @slidev/cli` bug in pitfalls doc and Playwright script
- Add `page.on('console')` error capture to the Playwright verification script
- Document all seven issue classes with prevention (not just fix) guidance
- Update index.json to reflect current file state and register new template files
- Ensure slidev-pitfalls.md is explicitly loaded for slides task types

**Non-Goals**:
- Nix devShell for Slidev toolchain (future improvement, not in scope)
- CI integration for Playwright verification
- CSS smoke-test framework for theme conflicts
- Automated Slidev version compatibility checking
- Rewriting the Playwright script from scratch (targeted enhancements only)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Template files drift from upstream Slidev versions | M | H | Add version comment to template package.json; document staleness check in pitfalls |
| NixOS Playwright incompatibility remains unresolved | M | H | Document workaround in pitfalls (executablePath option); keep `slidev build` as fallback validation |
| index.json line_count becomes stale again after edits | L | H | Use `wc -l` during implementation to get exact count |
| Implicit context loading still misses pitfalls doc | H | M | Add explicit load_when entry for slides-agent and present task types |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Create Slidev Project Template Directory [COMPLETED]

**Goal**: Extract the four canonical scaffold files from `examples/epi-slides/` into a reusable template directory that agents copy when creating new Slidev decks.

**Tasks**:
- [ ] Create directory `.claude/context/project/present/talk/templates/slidev-project/`
- [ ] Copy `examples/epi-slides/package.json` to template directory, generalizing: replace `"name": "epi-slides"` with `"name": "DECK_NAME"` and `"description"` with a placeholder; add a comment-style field `"_slidev_template_version": "52.14"` for staleness tracking
- [ ] Copy `examples/epi-slides/.npmrc` to template directory (verbatim: `shamefully-hoist=true`)
- [ ] Copy `examples/epi-slides/vite.config.ts` to template directory (verbatim)
- [ ] Copy `examples/epi-slides/lz-string-esm.js` to template directory (verbatim)
- [ ] Add a `README.md` to the template directory explaining purpose, contents, and version tracking

**Timing**: 0.75 hours

**Depends on**: none

**Files to modify**:
- `.claude/context/project/present/talk/templates/slidev-project/package.json` - new file
- `.claude/context/project/present/talk/templates/slidev-project/.npmrc` - new file
- `.claude/context/project/present/talk/templates/slidev-project/vite.config.ts` - new file
- `.claude/context/project/present/talk/templates/slidev-project/lz-string-esm.js` - new file
- `.claude/context/project/present/talk/templates/slidev-project/README.md` - new file

**Verification**:
- All five files exist in the template directory
- package.json has generic placeholders (not epi-slides-specific)
- vite.config.ts contains the lz-string alias
- .npmrc contains `shamefully-hoist=true`

---

### Phase 2: Update slidev-pitfalls.md with All Seven Issue Classes [COMPLETED]

**Goal**: Transform the pitfalls document from a mix of setup notes and fix instructions into comprehensive prevention-oriented documentation covering all seven known issue classes, with the corrected CLI command.

**Tasks**:
- [ ] Fix line 44: change `npx slidev` to `npx @slidev/cli` in the Version Alignment section
- [ ] Add a "Project Scaffolding" section at the top referencing the template directory from Phase 1, explaining that agents should copy the four template files when creating new decks
- [ ] Promote "Black boxes on inline code" (Shiki CSS) from the Fixing Common Errors list to a full prevention section under Project Setup, explaining the root cause (Shiki syntax highlighter overrides custom theme `<code>` styles) and the fix (`!important` overrides in theme CSS)
- [ ] Promote "Vue components in markdown tables" from the Fixing Common Errors list to a full prevention section, explaining the root cause (Vue/MDC parser fails silently inside pipe tables) and the fix (use HTML `<table>` elements)
- [ ] Add 7th issue class: "Footer and Absolute Positioning Overlap" section documenting that `position: absolute` in slide content causes overlap with footer elements; recommend flow positioning or Slidev's `::bottom::` slot
- [ ] Add "Pre-Playwright Validation" section documenting `slidev build` as a required first-pass check before running Playwright (catches lz-string crashes, CLI version issues, Vue compile errors without launching a browser)
- [ ] Add NixOS Playwright workaround documentation: `executablePath` option for system chromium, `slidev build` as fallback when browser automation is unavailable
- [ ] Add template version staleness note: check `_slidev_template_version` in template package.json against current Slidev release before using

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `.claude/context/project/present/talk/patterns/slidev-pitfalls.md` - major update

**Verification**:
- All seven issue classes have dedicated prevention sections (not just fix instructions)
- `npx @slidev/cli` appears where `npx slidev` was (no remaining instances of bare `npx slidev`)
- Template directory is referenced in the scaffolding section
- `slidev build` pre-validation step is documented

---

### Phase 3: Fix Playwright Verification Script and Update index.json [COMPLETED]

**Goal**: Fix the CLI command bug in the Playwright script, add `console.error` capture, and update index.json to reflect current file states and register the new template directory.

**Tasks**:
- [ ] In `playwright-verify.mjs` line 17: change `['npx', 'slidev', ...]` to `['npx', '@slidev/cli', ...]`
- [ ] Add `page.on('console', msg => ...)` handler that captures `error`-type console messages into the `slideErrors` array, alongside the existing `pageerror` handler (around line 67)
- [ ] Add a comment documenting the NixOS `executablePath` workaround option in the `chromium.launch()` call
- [ ] Update the index.json entry for `slidev-pitfalls.md`: correct `line_count` to actual value after Phase 2 edits, update `summary` and `description` fields
- [ ] Add index.json entry for the new `templates/slidev-project/` directory (or a representative file like the README)
- [ ] Ensure the slidev-pitfalls.md index.json entry has `load_when` that includes `slides-agent`, `present` task types, and `/slides` command so it is explicitly loaded (not relying on implicit context discovery)

**Timing**: 0.75 hours

**Depends on**: 1

**Files to modify**:
- `.claude/context/project/present/talk/templates/playwright-verify.mjs` - bug fix + enhancement
- `.claude/context/index.json` - update stale entry, add new entries, fix load_when

**Verification**:
- `playwright-verify.mjs` spawns `@slidev/cli` not `slidev`
- Script has both `pageerror` and `console` error listeners
- `grep -c 'npx.*slidev' playwright-verify.mjs` shows only the corrected `@slidev/cli` form
- index.json entry for slidev-pitfalls.md has correct line_count
- index.json has entry for slidev-project template

---

### Phase 4: Integration Verification [COMPLETED]

**Goal**: Verify all changes are internally consistent and the pipeline improvements work end-to-end.

**Tasks**:
- [ ] Verify no remaining instances of bare `npx slidev` (without `@slidev/cli`) across all modified files: `grep -r "npx slidev" .claude/context/project/present/`
- [ ] Verify the template package.json is valid JSON with `node -e "require('./package.json')"`
- [ ] Verify all index.json entries have correct file paths that resolve to existing files
- [ ] Verify slidev-pitfalls.md covers all seven issue classes by checking section headers
- [ ] Verify playwright-verify.mjs has both `pageerror` and `console` listeners
- [ ] Cross-check that the template files in `.claude/context/project/present/talk/templates/slidev-project/` match the structure documented in slidev-pitfalls.md

**Timing**: 0.5 hours

**Depends on**: 2, 3

**Files to modify**:
- No new modifications expected; fixes only if verification catches issues

**Verification**:
- All grep checks return expected results
- JSON files parse without errors
- No stale cross-references between pitfalls doc, template directory, and index.json

## Testing & Validation

- [ ] `grep -rn "npx slidev" .claude/context/project/present/` returns only `npx @slidev/cli` forms
- [ ] Template directory contains all four scaffold files plus README
- [ ] `node -e "JSON.parse(require('fs').readFileSync('.claude/context/project/present/talk/templates/slidev-project/package.json'))"` succeeds
- [ ] index.json is valid JSON after edits
- [ ] slidev-pitfalls.md has sections for all seven issue classes
- [ ] playwright-verify.mjs contains `page.on('console'` in addition to `page.on('pageerror'`

## Artifacts & Outputs

- `specs/034_improve_slidev_review_pipeline/plans/01_improve-slidev-pipeline.md` (this plan)
- `.claude/context/project/present/talk/templates/slidev-project/` (new template directory with 5 files)
- `.claude/context/project/present/talk/patterns/slidev-pitfalls.md` (updated)
- `.claude/context/project/present/talk/templates/playwright-verify.mjs` (updated)
- `.claude/context/index.json` (updated entries)

## Rollback/Contingency

All changes are to `.claude/context/` files (agent system configuration, not user-facing code). Rollback via `git checkout .claude/context/` restores the previous state. The `examples/epi-slides/` source files are read-only inputs and are not modified. If the template approach proves insufficient, the fallback is to continue with prose-based scaffolding instructions in the pitfalls document (current state).
