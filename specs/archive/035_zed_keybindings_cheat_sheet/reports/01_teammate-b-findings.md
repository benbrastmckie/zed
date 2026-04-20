# Teammate B Findings: Alternative Approaches for Zed Keybindings Cheat Sheet

## Key Findings

### Source Document Summary

The keybindings document at `/home/benjamin/.config/zed/docs/general/keybindings.md` contains:
- ~71 keybinding entries across 12 functional domains
- A clear custom-vs-default split: custom bindings are already marked with `*` in the source
- A substantial AI/Agent panel section (~22 entries) with rich subsection structure
- macOS-oriented (Cmd key), with a note that Ctrl maps to Cmd on other platforms
- Content arranged as a narrative FAQ ("How do I...?"), not a flat table — the cheat sheet will need to re-organize this

### Custom vs. Default Annotation Patterns

The source uses an asterisk (`*`) suffix on custom bindings. This is an established convention:
- **Microsoft Word documentation** uses `*` to flag shortcuts that conflict with or differ from system defaults
- The `keyle` Typst package (typst.app/universe) renders keyboard keys with styled chips; custom bindings can be differentiated using a color accent, a superscript star `★`, or a differently colored key chip
- Common design patterns for "custom vs. default" distinction:
  1. **Color accent**: custom keys rendered in a distinct accent color (e.g., amber or teal vs. neutral gray for defaults)
  2. **Symbol annotation**: `★` or `•` glyph inline after the key chord
  3. **Background band**: custom rows get a faint colored row background
  4. **Legend + section grouping**: a small legend at the bottom of the sheet; custom bindings may also be grouped together in a "Custom Bindings" section at the end

### Page Format Considerations

- **Single-page landscape A4**: maximum density, print-friendly, classic cheat sheet form factor. Works well if the font is 7–8pt. The AI section (~22 entries) makes this tight.
- **Single-page landscape A4 with two-tier structure**: a "Quick Reference" panel at the top (the 10–15 most essential shortcuts), then a detailed reference grid below — matches the existing document structure (Quick Reference table + narrative sections).
- **Two-page portrait A4**: more breathing room, allows 9–10pt font, suitable for a PDF reference kept on a second monitor. Sections can be larger and more navigable.
- **Folded half-sheet (A5 landscape)**: single A4 sheet, folded to create a 4-panel wallet card. Common for small reference cards.

The AI/Agent panel section's size (22 entries + 6 subsections) is the main constraint. A single-page format will require either abbreviating it heavily or giving it its own half-column.

---

## Alternative Approaches

### Approach 1: Landscape A4, Two-Column Dense Grid (Classic Cheat Sheet)

**Layout**: Landscape A4, two equal columns, 8mm gutter, 8mm margins, 7.5–8pt font.

**Organization**:
- Left column: Essentials, Navigation, Editing, Search, Panels/Sidebars
- Right column: AI/Agent Panel (full subsection tree), Git, Markdown/Slidev, Vim mode, custom binding legend

**Custom binding treatment**: Each key chord in the "custom" set rendered with a `★` suffix and a teal/amber accent on the key chip. A two-line legend at the bottom right: `★ = custom binding (keymap.json)`.

**Packages**: No external packages needed. Use Typst stdlib `grid`, `box`, `block`. The `keyle` package (typst.app/universe, v0.2.0) could provide pre-styled key chips (deep-blue or type-writer themes), but a hand-rolled `#let key(k)` function is equally viable and avoids a dependency.

**Pros**:
- Fits on one page — single printable artifact
- Classic cheat sheet look familiar to developers
- Landscape maximizes horizontal space for key-chord + description rows

**Cons**:
- 7.5pt is small; fine for screen viewing, borderline for print
- The AI section will need aggressive abbreviation or creative sub-column nesting
- No room for usage notes or contextual callouts

---

### Approach 2: Portrait A4, Three-Column Sectioned Reference (Readable Reference Card)

**Layout**: Portrait A4, three columns using `#show: columns.with(3, gutter: 6mm)`, 10mm margins, 8.5–9pt font.

**Organization**:
Sections flow naturally across columns:
1. Quick Reference (top-of-first-column highlight box with the ~10 most essential shortcuts)
2. File Operations
3. Navigation (tabs, panes, code nav)
4. Editing
5. Search & Replace
6. Panels & Settings
7. AI/Agent Panel (spans full column width with subsection headers)
8. Git / Markdown / Slidev
9. Terminal, Vim Mode
10. Custom Bindings Legend (footer)

**Custom binding treatment**: Custom rows get a faint warm-yellow row tint (`luma(250)` or `rgb("fffbe6")`) in addition to `★`. The color difference is immediately visible without needing to read the legend.

**Pros**:
- More readable font size (8.5–9pt)
- Three columns in portrait give good information density without being overwhelming
- The "Quick Reference" callout box at the top mirrors the source document structure
- Easier to extend (can become two pages if content grows)

**Cons**:
- Portrait orientation is less common for developer cheat sheets
- Column breaks in auto-flow mode (`columns.with(3)`) may split sections awkwardly; may need manual `#colbreak()` placement

---

### Approach 3: Two-Page Booklet (Structured Reference Manual)

**Layout**: Two-page portrait A4 (or A5 booklet printed on one sheet). Page 1 covers the "everyday" shortcuts; page 2 covers AI/agent panel and specialized workflows.

**Page 1**: Essentials, Navigation, Editing, Search, Panels, Git, Terminal
**Page 2**: AI/Agent Panel (full, with subsections), Markdown/Slidev, Vim mode, Custom bindings reference table, tips on adding new shortcuts

**Custom binding treatment**: A dedicated "Custom Bindings" section on page 2 lists all `*`-marked shortcuts in one place, alongside a note about `keymap.json`. On page 1, custom shortcuts are marked with `★` but also noted as "see Custom section, p.2".

**Typst implementation**: Use `#pagebreak()` explicitly between the two pages. Consistent header with document title and macOS version note on both pages.

**Pros**:
- No font-size compromise — can use 9–10pt for full legibility
- AI/Agent panel gets a full half-page; no abbreviation needed
- The two-page structure mirrors a "beginner page" (p.1) + "power user page" (p.2) split that is pedagogically natural given the document's narrative structure
- Easy to print double-sided as a folded 4-panel booklet

**Cons**:
- Two pages means two artifacts to manage and print
- Less portable as a "quick reference" — requires flipping pages

---

### Approach 4: Domain-Grouped Single Page with Boxed Sections (using `boxed-sheet` template)

**Layout**: Use the `boxed-sheet` Typst Universe package (5-column default, configurable). Each functional domain becomes a color-coded "concept block". Columns set to 4 for this content volume.

**Key design feature**: Each section is a self-contained colored box. Color encodes domain:
- Blue: Navigation
- Green: Editing
- Purple: AI/Agent
- Amber: Custom bindings
- Neutral gray: Essentials/standard

**Custom binding treatment**: Custom bindings go in amber-tinted boxes. The color of the box itself signals "this is custom". No need for `★` annotations — the box color is the legend.

**Pros**:
- Visually distinctive — looks polished and scan-friendly
- Color-coding encodes domain at a glance (no need to read section headers)
- `boxed-sheet` package handles column layout and box rendering automatically

**Cons**:
- The `boxed-sheet` package's 5-column default may be too dense for keyboard shortcut rows (key-chord + description needs ~2–3fr width)
- Color printing required to benefit from the color-coding scheme; grayscale print degrades usability
- The package is an external dependency; may require pinning version in typst.toml

---

## Evidence / Examples

### Official VS Code Cheat Sheet (design reference)
The official Microsoft VS Code keyboard shortcuts PDF uses a **two-column landscape layout** at roughly 8–9pt. Sections are separated by bold colored headers (blue for the VS Code brand color). No custom/default distinction is needed since all shortcuts are official, but section headers carry the visual hierarchy.
Source: https://code.visualstudio.com/shortcuts/keyboard-shortcuts-macos.pdf

### Relevant Typst Universe Packages Found

| Package | Layout | Key Feature | Version |
|---------|--------|-------------|---------|
| `knowledge-key` | Compact, single-page | Minimal wrapper; `title`, `authors`, `body` params | 1.0.2 |
| `boxed-sheet` | 5-col default, A4 | Color-coded concept blocks, auto color cycling | latest |
| `cram-snap` | Landscape A4, adjustable cols | Table-based, `theader` colspan, 1cm margins, 2fr/3fr cols | 0.2.2 |
| `summy` | 5-col default | 5.5pt font, line_skip control, very dense | latest |
| `keyle` | Inline utility | Styled key chips (deep-blue, typewriter themes), `+` separator | 0.2.0 |

**Recommended**: `cram-snap` for structure + `keyle` for key chip styling. `cram-snap`'s table-based layout with `2fr/3fr` column proportions (key | description) maps directly to the shortcut-list format. `keyle` provides pre-built key chip themes that match common cheat sheet aesthetics without custom CSS/Typst code.

Alternative: hand-rolled solution (no external packages) as prototyped in Teammate A's findings — fully viable and avoids version-pinning concerns.

### Custom vs. Default Annotation Precedents
- **Microsoft Word docs**: asterisk `*` with a footnote legend — clean, low-visual-noise approach
- **Hotkey Cheatsheet (hotkeycheatsheet.com)**: uses color-coded category badges inline with each entry
- **99designs Adobe Illustrator cheat sheet**: uses icon-based category markers in the left margin
- **Quire keyboard cheat sheet**: groups custom/app-specific shortcuts in a separate section with a colored band divider

### Page Size Decision Rationale

With ~71 entries and a 22-entry AI section, the options rank as follows by feasibility:
1. **Two-page portrait A4** — most feasible without compromising readability
2. **Landscape A4, two-column** — feasible with aggressive abbreviation of the AI section
3. **Three-column portrait A4** — feasible with careful `#colbreak()` placement
4. **Folded A5 card** — requires heavy abbreviation; AI section must be cut to ~8 entries

---

## Confidence Level

**High** on package availability and Typst layout mechanics — all packages verified on typst.app/universe, Typst stdlib layout patterns are stable in 0.11+.

**High** on custom-vs-default annotation approaches — asterisk/star convention is well-established in technical documentation.

**Moderate** on single-page feasibility — whether 71 entries (especially the 22-entry AI section) fit on one landscape A4 page at readable font size depends on how aggressively descriptions are abbreviated. A compile test is needed to confirm.

**Low** on `boxed-sheet` package suitability — its 5-column default is designed for study notes, not keyboard shortcut rows; would need significant configuration tuning to work well for this use case.
