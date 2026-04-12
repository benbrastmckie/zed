# Implementation Plan: Zed Keybindings Cheat Sheet

- **Task**: 35 - Zed Keybindings Cheat Sheet
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/035_zed_keybindings_cheat_sheet/reports/01_team-research.md
- **Artifacts**: plans/01_keybindings-cheat-sheet.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

Create a two-page landscape A4 Typst cheat sheet for Zed keybindings, organized progressively from essential to specialized. The document uses Linux-native key labels (Ctrl, not Cmd), hand-rolled key chip styling, colored section headers, and visual distinction between default and custom bindings. Content is curated from docs/general/keybindings.md and keymap.json (~55-60 entries from 71 total, omitting unverified defaults). Definition of done: a compilable Typst file at docs/general/keybindings-cheat-sheet.typ that produces a readable two-page PDF.

### Research Integration

Integrated from team research report (01_team-research.md, 4 teammates):
- Teammate A: Section ordering (essential to specialized), Typst layout snippets, `#key()` function design
- Teammate B: Layout alternatives evaluated (landscape two-page booklet selected), Typst packages evaluated and rejected
- Teammate C: Platform notation corrections (Ctrl not Cmd for Linux), undocumented bindings (Ctrl+Enter, ProjectPanel hjkl), chord binding visual treatment, Alt+L dual-context issue
- Teammate D: Output location (docs/general/), hardcoded content rationale, ~55 curated binding target, no external packages

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No active roadmap items. This task creates a user-facing documentation artifact.

## Goals & Non-Goals

**Goals**:
- Create a well-organized, printable Typst cheat sheet for learning Zed keybindings
- Organize bindings progressively from fundamental to specialized
- Visually distinguish custom bindings (from keymap.json) from Zed defaults
- Use Linux-native notation (Ctrl) throughout with a macOS footnote
- Include undocumented but confirmed bindings (Ctrl+Enter, ProjectPanel hjkl)
- Produce a two-page landscape A4 document readable at 8.5-9pt

**Non-Goals**:
- Auto-generating the cheat sheet from keymap.json (hardcoded is appropriate for learning-first organization)
- Supporting external Typst packages (self-contained document)
- Covering every possible Zed shortcut (curated ~55-60 most useful)
- Including unverified "(verify)" defaults from keymap.json reference section
- Dark mode or theme variants

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Content overflow on two pages | M | M | Target ~55 bindings; AI section may need tighter layout or subsection trimming |
| Typst compilation issues on user system | L | L | Use only Typst stdlib features; test with `typst compile` |
| Incorrect key notation after Cmd-to-Ctrl mapping | M | M | Cross-reference keymap.json (authoritative) for every custom binding; note defaults with lower confidence |
| Alt+L dual meaning causes confusion | L | H | Add explicit context tags: "(editor)" and "(agent panel)" |
| Chord bindings visually ambiguous | M | M | Use arrow separator for sequential keys (Ctrl+K -> V) distinct from simultaneous keys (Ctrl+Shift+A) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Document Scaffold and Helper Functions [NOT STARTED]

**Goal**: Create the Typst file with page setup, color palette, and reusable helper functions for key chips and section headers.

**Tasks**:
- [ ] Create `docs/general/keybindings-cheat-sheet.typ` with landscape A4 page setup (two columns, 8.5pt body)
- [ ] Define color palette for section headers (8-9 distinct section colors; consider navy, teal, green, orange, purple, etc.)
- [ ] Implement `#key()` function: renders a single key as a rounded grey box (fill: luma(230), stroke: luma(180), radius: 2pt)
- [ ] Implement `#chord()` function: renders sequential key presses with arrow separator (e.g., Ctrl+K -> V)
- [ ] Implement `#shortcut()` function: takes key sequence and description, renders as a row with optional custom-binding star marker
- [ ] Implement `#section()` function: renders colored header band with section title
- [ ] Add document header with title, sync date comment, and platform note ("Linux notation; on macOS substitute Cmd for Ctrl")
- [ ] Add footer legend explaining star marker (custom binding) and arrow separator (chord/sequential press)
- [ ] Verify compilation with `typst compile`

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `docs/general/keybindings-cheat-sheet.typ` - Create new file

**Verification**:
- File compiles without errors via `typst compile docs/general/keybindings-cheat-sheet.typ`
- Output PDF shows landscape A4 with two columns, header, footer legend, and sample section

---

### Phase 2: Content Population (All Sections) [NOT STARTED]

**Goal**: Populate all keybinding sections with curated content, organized from essential to specialized across two pages.

**Tasks**:
- [ ] **Page 1 sections** (everyday use):
  - [ ] Essentials: Open file (Ctrl+P), Save (Ctrl+S), Undo/Redo, Copy/Cut/Paste, Close tab (Ctrl+W), Command palette (Ctrl+Shift+P), Settings (Ctrl+,)
  - [ ] Navigation: Go to line (Ctrl+G), Go to definition (F12), Jump list back/forward (Ctrl+O*/Ctrl+I*), Alt+Left/Right (defaults), Tab switching (Ctrl+Tab, Ctrl+Shift+Tab), Reopen tab (Ctrl+Shift+T), Open file under cursor (Ctrl+Enter*)
  - [ ] Editing: Select all (Ctrl+A), Select next occurrence (Ctrl+D), Comment toggle (Ctrl+/), Delete line (Ctrl+Shift+K), Move line up/down (Alt+K*/Alt+J*), Indent/outdent (Ctrl+]/Ctrl+[)
  - [ ] Search & Replace: Find in file (Ctrl+F), Search all files (Ctrl+Shift+F), Replace all files (Ctrl+Shift+H), Note about Ctrl+H being remapped
  - [ ] Panels & Layout: Toggle left sidebar (Ctrl+B), File explorer (Ctrl+Shift+E*), Toggle right dock/agent panel (Ctrl+?*), Terminal (Ctrl+`), Split pane right/down (Ctrl+\, Ctrl+Shift+\), Pane navigation (Ctrl+H*/Ctrl+L*), Copy path (Ctrl+Shift+C*)
- [ ] **Page 2 sections** (specialized):
  - [ ] AI & Agent Panel: Claude Code CLI (Ctrl+Shift+A*), New thread (Ctrl+N), Recent threads (Shift+Alt+J), Thread history (Ctrl+Shift+H), Review changes (Ctrl+Shift+R), Send message (Enter/Double-Enter), Expand editor (Shift+Alt+Escape), Add selection (Ctrl+>), Model selector (Ctrl+Alt+/), Cycle models (Alt+L _(agent panel)_), Manage profiles (Ctrl+Alt+P), Cycle profiles (Shift+Tab), Inline assist (Ctrl+Enter)
  - [ ] Edit Predictions: Accept (Tab), Accept alternate (Alt+L _(editor)_), Next/prev prediction (Alt+]/Alt+[)
  - [ ] Git: Git panel (Ctrl+Shift+G), Git blame (Alt+G -> B)
  - [ ] Markdown: Preview side-by-side (Ctrl+K -> V), Preview full tab (Ctrl+Shift+V)
  - [ ] Slidev: Preview (Alt+Shift+P*), Export PDF (Alt+Shift+E*)
  - [ ] File Explorer (ProjectPanel): h/j/k/l navigation (when panel focused, no vim mode needed)
  - [ ] Optional/Advanced: Vim toggle (Alt+V* -- off by default, opt-in)
- [ ] Ensure custom bindings are marked with star (*)
- [ ] Add context tags for dual-meaning keys (Alt+L in editor vs agent panel)
- [ ] Use `#chord()` for sequential bindings: Ctrl+K -> V, Alt+G -> B
- [ ] Balance content across two pages with appropriate `#pagebreak()`
- [ ] Verify compilation

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `docs/general/keybindings-cheat-sheet.typ` - Add all section content

**Verification**:
- All ~55-60 bindings present across sections
- Custom bindings marked with star
- Chord bindings use arrow notation
- Context tags present on Alt+L entries
- Two pages, no overflow onto third page
- Compiles cleanly

---

### Phase 3: Visual Polish and Final Verification [NOT STARTED]

**Goal**: Refine layout, spacing, and typography for print readability; compile final PDF and verify against source documents.

**Tasks**:
- [ ] Adjust column breaks and spacing so content fills both pages evenly without orphaned sections
- [ ] Fine-tune key chip sizing and padding for readability at 8.5-9pt
- [ ] Verify every custom binding against keymap.json (12 custom bindings, all should have star markers)
- [ ] Verify key notation accuracy: cross-check at least 10 default bindings against keybindings.md
- [ ] Ensure section color contrast is sufficient for monochrome printing (not just color-dependent)
- [ ] Add sync-date comment at top of file: `// Synced with keybindings.md and keymap.json on {date}`
- [ ] Compile final PDF and visually inspect both pages
- [ ] Update docs/general/keybindings.md to add a cross-reference note mentioning the cheat sheet file

**Timing**: 30 minutes

**Depends on**: 2

**Files to modify**:
- `docs/general/keybindings-cheat-sheet.typ` - Layout refinements
- `docs/general/keybindings.md` - Add cross-reference to cheat sheet

**Verification**:
- Final PDF is two pages, landscape A4
- All text readable at printed size (no text smaller than 8pt)
- Star markers match the 12 custom bindings in keymap.json
- No compilation warnings
- keybindings.md mentions the cheat sheet

## Testing & Validation

- [ ] `typst compile docs/general/keybindings-cheat-sheet.typ` succeeds without errors or warnings
- [ ] Output PDF is exactly two pages in landscape A4 orientation
- [ ] All 12 custom bindings from keymap.json are present and marked with star
- [ ] Ctrl notation used throughout (no Cmd references except in footer note)
- [ ] Chord bindings (Ctrl+K -> V, Alt+G -> B) use arrow separator
- [ ] Alt+L entries have context disambiguation tags
- [ ] Section ordering progresses from essential to specialized
- [ ] Font size is 8-9.5pt range (readable without magnification)

## Artifacts & Outputs

- `docs/general/keybindings-cheat-sheet.typ` - Typst source file (primary artifact)
- `docs/general/keybindings-cheat-sheet.pdf` - Compiled PDF output
- `docs/general/keybindings.md` - Updated with cross-reference

## Rollback/Contingency

The cheat sheet is a new file with no dependencies on existing functionality. Rollback is simply deleting `docs/general/keybindings-cheat-sheet.typ` and its compiled PDF, and reverting the one-line cross-reference addition to keybindings.md. If Typst compilation fails on the target system, verify Typst is installed (`typst --version`) and that no external packages are referenced.
