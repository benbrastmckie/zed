# Teammate A Findings: Zed Keybindings Cheat Sheet (Typst Layout)

## Key Findings

### Keybinding Inventory

All keybindings extracted from `/home/benjamin/.config/zed/docs/general/keybindings.md` and cross-referenced with `keymap.json`. Custom bindings (marked `*`) use `Ctrl+` prefix to avoid collision with Zed's `Cmd+` defaults.

**Section breakdown by domain:**

| Domain | Count | Notes |
|--------|-------|-------|
| File operations | 6 | Save, open, close, reopen, path copy |
| Navigation (tabs/panes) | 8 | Tabs, pane splits, pane focus |
| Code navigation | 6 | Jump list, go-to-def, go-to-line, symbol |
| Editing | 10 | Standard edit, multi-cursor, comment, line ops |
| Search | 4 | File, project, replace |
| AI / Agent panel | 22 | Claude Code CLI, inline assist, thread mgmt, model select |
| Terminal | 1 | Toggle |
| Git | 2 | Panel, blame |
| Panels & settings | 5 | Sidebars, command palette, settings |
| Slidev | 2 | Preview, export |
| Vim mode | 1 | Toggle |
| File explorer (hjkl) | 4 | Panel-specific nav |

Total: ~71 keybinding entries. The AI/Agent section is unusually large (22 entries) and should be treated as a subsection-rich domain requiring visual separation.

### Custom vs Default Split

Custom bindings (12 unique, 16 entries in keymap.json) all use `Ctrl+` or `Alt+` modifiers. This is a meaningful visual distinction — the cheat sheet should mark custom bindings clearly (e.g., with a star glyph or color accent).

---

## Recommended Approach

### Proposed Section Order (Fundamental → Specialized)

1. **Essentials** — The 10 shortcuts nearly every session touches: `Cmd+P`, `Cmd+S`, `Cmd+Z/Y`, `Cmd+C/X/V`, `Cmd+F`, `Cmd+W`
2. **Navigation** — Tabs (`Cmd+Tab`, `Ctrl+Tab`, `Cmd+Shift+T`), pane splits and focus (`Cmd+\`, `Ctrl+H/L`), jump list (`Ctrl+O/I`), code nav (`F12`, `Cmd+G`)
3. **Editing** — Multi-cursor (`Cmd+D`), comment (`Cmd+/`), line ops (`Alt+J/K`, `Cmd+Shift+K`), indent (`Cmd+]/[`)
4. **Search & Replace** — `Cmd+F`, `Cmd+Shift+F`, `Cmd+Shift+H`, `Cmd+Alt+F`
5. **Panels & Sidebars** — `Cmd+B`, `Cmd+Shift+E`/`Ctrl+Shift+E`, `Ctrl+``, `Ctrl+?`, `Cmd+Shift+G`, `Cmd+Shift+P`, `Cmd+,`
6. **AI / Agent Panel** — Subsections: Claude Code CLI, agent panel focus/management, inline assist, edit predictions, model/profile management, thread navigation
7. **Git** — `Cmd+Shift+G`, `Alt+G B`
8. **Markdown & Slidev** — `Cmd+K V`, `Cmd+Shift+V`, `Alt+Shift+P`, `Alt+Shift+E`
9. **File Explorer** — `h/j/k/l` navigation (panel-specific, least universal)

Rationale: Sections 1-4 are used by every developer every session. Sections 5-6 are workflow-specific (panels and AI are heavily used but not universal first-day knowledge). Sections 7-9 are specialized or context-dependent.

### Typst Layout Strategy

**Overall structure**: Two-column layout for most sections, three-column for Essentials. Use `grid()` with fractional column widths `(1fr, 1fr)` or `(auto, 1fr)` where key labels are auto-sized and descriptions fill remaining width.

**Page setup**:
```typst
#set page(
  paper: "a4",
  margin: (x: 10mm, y: 10mm),
  flipped: true  // Landscape for cheat sheet density
)
#set text(font: "Inter", size: 8pt)
```
Or use `"us-letter"` in portrait at 8–9pt for a half-sheet / wallet card form factor.

**Section headers**: Colored background boxes using `#block()` with `fill:` — one accent color per domain group (e.g., blue for navigation, green for editing, amber for AI).

**Key rendering**: Inline box with rounded corners and a light grey fill — matching the common "keyboard key" visual convention in cheat sheets.

**Custom binding indicator**: A small star `★` or colored dot rendered inline after the key chip to flag custom (`*`) bindings.

---

## Evidence / Examples (Typst Code Snippets)

### Key chip rendering
```typst
// Renders a single key as a rounded pill
#let key(k) = box(
  fill: luma(230),
  stroke: luma(180),
  radius: 2pt,
  inset: (x: 4pt, y: 2pt),
  baseline: 20%,
  text(font: "JetBrains Mono", size: 7.5pt, k)
)

// Renders a chord: Cmd+P
#let chord(..keys) = keys.pos().map(key).join(text(size: 7pt, " + "))
```

Usage: `#chord("Cmd", "P")` → renders two key chips joined by `+`.

### Section header with color band
```typst
#let section(title, color: blue.lighten(60%)) = block(
  width: 100%,
  fill: color,
  inset: (x: 6pt, y: 3pt),
  radius: 3pt,
  text(weight: "bold", size: 8.5pt, title)
)
```

### Two-column keybinding row
```typst
#let row(keys, desc, custom: false) = grid(
  columns: (auto, 1fr),
  gutter: 4pt,
  [#keys #if custom { text(fill: red.darken(20%), " ★") }],
  text(desc)
)
```

### Full section block pattern
```typst
#section("Navigation", color: teal.lighten(70%))
#v(2pt)
#row(chord("Cmd", "P"), "Open file by name")
#row(chord("Ctrl", "O"), "Jump back", custom: true)
#row(chord("Ctrl", "I"), "Jump forward", custom: true)
#row(chord("F12"), "Go to definition")
#v(4pt)
```

### Multi-column page layout
```typst
#show: columns.with(2, gutter: 8mm)
// All content flows across 2 columns automatically
```

Or use an explicit grid for full layout control:
```typst
#grid(
  columns: (1fr, 1fr),
  column-gutter: 8mm,
  [/* left column content */],
  [/* right column content */]
)
```

### Compact three-column Essentials table
```typst
#table(
  columns: (auto, auto, 1fr),
  stroke: none,
  inset: 3pt,
  ..essentials.map(e => (chord(..e.keys), e.custom_star, e.desc)).flatten()
)
```

### Packages to consider
- **No external packages needed** for core layout — Typst stdlib `grid`, `table`, `box`, `block` are sufficient.
- `tablex` (if using Typst 0.10 or earlier) for more flexible table strokes, but Typst 0.11+ `table` with `stroke` selectors covers this natively.
- For icons (Mac ⌘, ⌃, ⌥ symbols): use Unicode directly — `"⌘"`, `"⌃"`, `"⌥"`, `"⇧"` render cleanly in most system fonts. Alternatively, display literal text labels (`"Cmd"`, `"Ctrl"`) for clarity.

---

## Confidence Level

**High** — The keybinding corpus is fully inventoried (71 entries across 12 domains). Typst layout techniques are based on established stdlib patterns (grid, box, block, text styling) that are stable across Typst 0.11+. Section ordering is derived directly from the documentation structure and general "most used first" UX principles.

**Moderate** on exact visual design choices** — color palette, font choice (Inter vs system default), and whether to use landscape A4 vs portrait half-sheet will depend on the user's intended output medium (print vs screen PDF). The code snippets above are valid Typst 0.11+ but should be verified by compiling before finalizing.

**Note on AI section**: The AI / Agent panel section is the largest and most subdivided. It should either be broken into two sub-columns with a shared header, or placed as its own single-column wide block to retain readability. Flattening 22 entries into a compact grid without subsection labels would make it unusable.
