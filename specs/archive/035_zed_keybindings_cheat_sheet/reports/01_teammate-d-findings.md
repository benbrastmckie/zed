# Teammate D Findings: Strategic Direction (HORIZONS)

Task 35 -- Create Zed Keybindings Cheat Sheet in Typst

---

## Key Findings

### 1. Source Material is Already Well-Structured

`docs/general/keybindings.md` (222 lines) has a clear organization:
- A Quick Reference table (25 entries, including all 12 custom bindings)
- Workflow sections organized by user task ("How do I open a file?", "How do I use the AI agent?", etc.)
- Custom bindings are clearly marked with `*`
- Annotations note when shortcuts should be verified against Zed's keybinding editor

The document distinguishes between macOS (Cmd) and implicitly handles Linux/Windows (Ctrl replaces Cmd). Custom bindings use Ctrl+ exclusively to avoid Cmd collisions on macOS.

### 2. The Source of Truth is keymap.json, Not the Docs

`keymap.json` (191 lines) is the authoritative record of every custom binding. It includes:
- 12 unique custom bindings across 4 context groups (Workspace, Terminal, Editor, ProjectPanel)
- Comprehensive inline comments distinguishing custom vs. default bindings
- A full ZED DEFAULT REFERENCE section (commented) listing all defaults

The `.md` docs are derived from `keymap.json` but maintained separately. They can drift. The cheat sheet should either (a) be regenerable from `keymap.json` or (b) clearly note that it was generated at a point in time and may need updating.

### 3. The Repo Is macOS-Primary but Linux Is a Real Target

`README.md` explicitly states "Platform: macOS 11 (Big Sur) or newer." However:
- `keymap.json` uses Ctrl+, not Cmd+, for all custom bindings -- these work identically on Linux
- The user runs this config on Linux (confirmed by env: `Platform: linux`)
- Custom bindings are macOS/Linux portable. Only Zed defaults differ (Cmd on macOS = Ctrl on Linux for most shortcuts)

This means the cheat sheet needs to handle platform-specific key label differences for the "default" shortcuts column. The custom bindings column is platform-independent.

### 4. The Intended Audience Is a Learner, Not a Power User

The task description specifies "for learning" and requests organization "from most basic/fundamental to less used or specific." This implies:
- The cheat sheet should be a pedagogical tool, not an exhaustive reference
- Progressive disclosure is the right structure (essentials first, advanced last)
- Grouping by workflow (not by modifier key) matches how learners think
- Custom shortcuts should be visually differentiated so the learner understands what comes from Zed vs. what was added

### 5. No Existing Typst Infrastructure for Cheat Sheets

The only existing `.typ` file in the repo is the research-timeline template at `.claude/context/project/present/templates/typst/research-timeline.typ`. That template shows the project's Typst style: navy/slate color palette, table-heavy layout, professional typography. There is no established cheat-sheet template.

The output should live at `docs/general/keybindings-cheat-sheet.typ` (with compiled PDF alongside) -- parallel to `docs/general/keybindings.md` as the typeset companion document.

### 6. Auto-Generation vs. Hardcoded Content

`keymap.json` is machine-readable JSON. Typst can read JSON via `json()`. A parameterized Typst template could theoretically read `keymap.json` directly, but:
- `keymap.json` only contains custom bindings; defaults would need a second data source
- The learning-oriented organization (by workflow, not by context) requires editorial judgment that a script cannot supply
- The `*` marker for custom bindings and the "verify" annotations in the docs add signal that is absent from the raw JSON

**Recommendation**: Hardcoded Typst document is appropriate for this use case. The cheat sheet should be considered a snapshot artifact, with a comment header noting the source files and date of last sync. This is lower complexity and produces a better learning document.

### 7. Cross-Platform Key Label Strategy

The cheat sheet should use macOS labels (Cmd, Option) as primary since the README declares macOS as primary, but add a one-line note: "On Linux/Windows, substitute Ctrl for Cmd." Custom bindings (Ctrl+, Alt+) need no translation note since they are identical on all platforms.

---

## Recommended Approach

### Strategic Recommendations

1. **Location**: `docs/general/keybindings-cheat-sheet.typ` and compiled `docs/general/keybindings-cheat-sheet.pdf`. Parallel to the existing `.md` source, in the docs/general/ directory.

2. **Structure (learning-first, progressive disclosure)**:
   - **Section 1: Essential (learn these first)** -- File operations, save, undo/redo, find, command palette
   - **Section 2: Navigation** -- Tabs, split panes, jump list (Ctrl+O/I), go to line, go to definition
   - **Section 3: Editing** -- Selection, line move (Alt+J/K), comment, delete line, multi-cursor
   - **Section 4: Panels and Sidebar** -- Terminal toggle, left/right dock, file explorer, git panel
   - **Section 5: AI and Claude** -- Claude Code launcher, agent panel, inline assist, edit predictions
   - **Section 6: Vim Mode and Project Panel** -- Alt+V toggle, hjkl navigation (for users who want it)
   - **Section 7: Workflows** -- Slidev preview/export, markdown preview, settings

3. **Visual differentiation**: Use a colored tag or background to distinguish custom (`*`) from Zed default bindings. The learner needs to know which shortcuts require `keymap.json` to be installed.

4. **Platform note**: Single line at top: "macOS labels. On Linux/Windows: Ctrl replaces Cmd."

5. **Layout**: Two-column per section (shortcut | description). Compact but readable. A4 or letter paper in landscape orientation fits ~60-80 bindings on 1-2 pages. Keep it to 2 pages maximum for usability.

6. **No auto-generation**: Hardcoded content is appropriate. Add a sync note in a comment header:
   ```typst
   // Source: docs/general/keybindings.md + keymap.json
   // Last synced: 2026-04-11
   ```

7. **Future-proofing**: Document clearly in the file header which source files need to be checked when Zed or `keymap.json` changes. A "verify with Cmd+K Cmd+S" reminder in a footer or callout box serves learners well.

### What to Exclude

- The full agent panel navigation sub-sections (too granular for a learning tool)
- "Verify" annotations -- these belong in the `.md` reference, not the cheat sheet
- The project panel hjkl bindings -- useful but niche; consider a footnote or sidebar

### Output Artifact Path

`/home/benjamin/.config/zed/docs/general/keybindings-cheat-sheet.typ`

The PDF is compiled via `typst compile docs/general/keybindings-cheat-sheet.typ` and should be committed alongside the source.

---

## Evidence / Examples

### Binding counts by section (from keymap.json + keybindings.md)

| Section | Estimated Bindings | Priority |
|---------|-------------------|----------|
| File operations | 7 | Essential |
| Navigation (tabs, panes, code) | 10 | Essential |
| Editing | 8 | Essential |
| Panels/sidebars | 6 | Core |
| AI / Claude | 14 | Core (this user's primary workflow) |
| Vim mode + project panel | 5 | Advanced |
| Workflows (Slidev, Markdown) | 5 | Workflow-specific |

Total: ~55 bindings -- easily fits on 2 pages in a two-column compact layout.

### Custom bindings (the 12 that require keymap.json)

```
Ctrl+H / Ctrl+L   Pane navigation
Ctrl+O / Ctrl+I   Jump list (back/forward)
Alt+V             Toggle vim mode
Ctrl+Shift+A      Launch Claude Code
Ctrl+?            Toggle right dock
Ctrl+Shift+E      Toggle left dock
Ctrl+Shift+C      Copy file path
Alt+J / Alt+K     Move line down/up
Alt+Shift+P       Slidev preview
Alt+Shift+E       Slidev export PDF
```

These 12 form the "installed" layer. Visually distinguishing them helps the learner understand the two-tier system (Zed defaults + this config).

### Existing Typst style (from research-timeline.typ)

```typst
#let navy-dark = rgb("#1e3a5f")
#let navy-medium = rgb("#2c5282")
#let navy-light = rgb("#ebf4ff")
#let text-muted = rgb("#64748b")
#let border-light = rgb("#e2e8f0")
```

The cheat sheet should use a compatible but simpler palette. A lighter accent color for custom bindings (e.g., the navy-light background on custom rows) would match the project's visual language.

---

## Confidence Level

**High confidence** on:
- Location (docs/general/ is the right place)
- Hardcoded vs. auto-generated (hardcoded wins for learning-focused document)
- Section structure (learning-first ordering is clearly supported by task description)
- Platform handling (single note suffices; custom bindings are already portable)

**Medium confidence** on:
- Exact page count (2 pages is a target, not guaranteed -- depends on chosen font size and layout density)
- Whether to include AI panel sub-navigation detail (lean toward omitting for learning context)

**Lower confidence** on:
- Whether the user wants a print-ready PDF vs. a screen-only document (affects color choices and layout density)
- Specific Typst packages available in the user's environment (the research-timeline.typ uses `@preview/gantty:0.5.1`; the cheat sheet should avoid external packages or use widely available ones)
