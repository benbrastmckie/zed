# Research Report: Task #35

**Task**: Create Zed keybindings cheat sheet in Typst
**Date**: 2026-04-11
**Mode**: Team Research (4 teammates)

## Summary

The keybindings documentation contains ~71 entries across 12 domains, with 12 custom bindings (requiring keymap.json) and a large AI/Agent panel section (22 entries). The cheat sheet should be a hardcoded Typst document organized progressively from essential to specialized, using Linux-native key labels (Ctrl, not Cmd), with visual distinction between default and custom bindings. A two-page landscape A4 layout with two columns is the recommended format, avoiding external Typst packages.

## Key Findings

### Primary Approach (from Teammate A)

- **71 keybinding entries** across 12 domains; AI/Agent panel is the largest (22 entries)
- **12 custom bindings** all use `Ctrl+` or `Alt+` modifiers -- visually distinguishable with a star marker
- **Proposed section order** (fundamental to specialized): Essentials -> Navigation -> Editing -> Search -> Panels -> AI/Agent -> Git -> Markdown/Slidev -> File Explorer
- **Typst layout**: Landscape A4, two-column, 8-9pt font, hand-rolled `#key()` function for key chips (rounded box with grey fill), colored section headers via `#block()`, no external packages needed
- **AI section treatment**: Needs subsection headers or a wider single-column block due to its size

### Alternative Approaches (from Teammate B)

Four layout strategies identified:

1. **Landscape A4, two-column dense grid** -- classic cheat sheet, fits one page at 7.5pt (tight)
2. **Portrait A4, three-column** -- more readable at 8.5-9pt, needs manual `#colbreak()` placement
3. **Two-page booklet** -- page 1 everyday, page 2 AI/advanced; no font compromise; natural beginner/power-user split
4. **Boxed sections with `boxed-sheet` package** -- color-coded domain boxes; requires color printing

**Typst packages found**: `cram-snap` (table-based layout), `keyle` (key chip styling), `boxed-sheet` (concept blocks). All on typst.app/universe.

**Recommendation from B**: Two-page booklet is the strongest alternative given the AI section size.

### Gaps and Shortcomings (from Critic)

Critical issues identified:

1. **Platform notation mismatch**: The docs use `Cmd` (macOS) but the user is on Linux. On Linux, both "Zed default Cmd+" and "custom Ctrl+" collapse to `Ctrl+`. The cheat sheet MUST use `Ctrl` as primary notation.

2. **Undocumented bindings in keymap.json**:
   - `Ctrl+Enter` -> `editor::OpenFile` (open file under cursor) -- completely absent from docs
   - ProjectPanel `h/j/k/l` navigation -- entire vim-style file explorer mode, not documented

3. **Contradiction: Alt+V vim toggle vs "no vim mode" memory** -- Resolution: vim mode is off by default; Alt+V is an opt-in toggle. Include in advanced/optional section.

4. **Docs say `Cmd+H`/`Cmd+L` for pane navigation but keymap.json uses `ctrl-h`/`ctrl-l`** -- docs are wrong for Linux users.

5. **Chord bindings** (`Ctrl+K V`, `Alt+G B`) need distinct visual treatment -- sequential key presses, not simultaneous. Use arrow separator.

6. **`Alt+L` has dual meaning**: accept edit prediction (editor) vs cycle favorite models (agent panel). Context must be clear.

7. **Many defaults marked "(verify)"** in keymap.json -- uncertain accuracy. Recommend omitting unverified shortcuts.

8. **`Ctrl+H` remaps find-and-replace to pane navigation** -- needs explicit note.

### Strategic Horizons (from Teammate D)

1. **No auto-generation** -- the learning-first organization requires editorial judgment; hardcoded Typst is appropriate with a sync-date comment header
2. **Output location**: `docs/general/keybindings-cheat-sheet.typ` (parallel to existing `.md`)
3. **Platform handling**: Single note at top ("On Linux: Ctrl replaces Cmd") suffices; custom bindings are already portable
4. **~55 curated bindings** is the target (trim the full 71 for a learning document)
5. **Existing project Typst palette**: navy-dark/navy-light colors from research-timeline.typ could be referenced for visual consistency
6. **Avoid external packages** for simplicity and portability

## Synthesis

### Conflicts Resolved

| Conflict | Resolution | Reasoning |
|----------|-----------|-----------|
| Platform notation (Cmd vs Ctrl) | **Use Ctrl throughout** with a one-line footer note for macOS users | The user is on Linux; a Linux-first cheat sheet is more useful than a macOS-first one with a footnote. Teammate C's argument is stronger than D's. |
| Layout (1-page vs 2-page) | **Two-page landscape A4** | Teammates A and B both note the AI section (22 entries) makes single-page tight at readable font sizes. The two-page booklet (B's Approach 3) provides natural beginner/power-user split matching the learning goal. D also targets 2 pages. |
| Packages vs hand-rolled | **No external packages** | Teammates A, C, and D all favor self-contained Typst. B identifies packages but notes hand-rolled is equally viable. Avoiding dependencies is simpler and more portable. |
| Organization (by function vs by context) | **Hybrid: function-first with context annotations** | A and D recommend function/workflow ordering (essential -> specialized) which matches the learning goal. C recommends context-based (Global/Editor/Agent Panel) to avoid Alt+L ambiguity. Resolution: organize by function but add context tags (e.g., small "Agent" badge) on context-dependent bindings. |
| Vim-related bindings | **Include as optional/advanced section** | Alt+V toggle and ProjectPanel hjkl are real bindings. Label them as "Optional" or "Power User" to respect the collaborator concern from user memory. |
| Unverified bindings | **Omit "(verify)" shortcuts** | For a reliable learning tool, include only confirmed bindings. Unverified ones can be added after manual verification. |

### Gaps Identified

1. **Ctrl+Enter (open file under cursor)** is undocumented but useful -- should be included in cheat sheet and the source docs should be updated separately
2. **ProjectPanel hjkl** is undocumented -- include in File Explorer section
3. **No verification of Zed defaults on Linux** -- the cheat sheet assumes macOS docs are accurate after Cmd->Ctrl substitution; some defaults may differ on Linux
4. **No dark mode / print considerations** -- if the user prints on a dark background or uses a dark PDF viewer, color choices matter

### Recommendations

**Layout**:
- Two-page landscape A4, two-column layout
- 8.5-9pt body text (readable without being cramped)
- Page 1: Essentials, Navigation, Editing, Search & Replace, Panels & Sidebars
- Page 2: AI & Claude Code (full subsections), Git, Markdown & Slidev, File Explorer, Optional/Advanced (vim toggle)
- Colored section header bands, one accent color per domain

**Visual Design**:
- Key chips: rounded grey boxes using `#box(fill: luma(230), stroke: luma(180), radius: 2pt, ...)`
- Custom binding indicator: `*` star after key chord, with legend at bottom
- Chord (sequential) bindings: use thin arrow `->` separator instead of `+`
- Context-dependent bindings: small italic context tag (e.g., _(agent panel)_)
- Section colors: use project palette (navy-light for AI, teal for navigation, etc.)

**Content**:
- ~55-60 curated bindings (trim from 71 by omitting unverified defaults)
- Add the 2 undocumented bindings (Ctrl+Enter, ProjectPanel hjkl)
- Use Ctrl throughout for Linux; footer note for macOS equivalent
- Hardcoded content with sync-date comment header
- Output to `docs/general/keybindings-cheat-sheet.typ`

**Typography**:
- No external packages -- use Typst stdlib (grid, box, block, table)
- Hand-rolled `#key()` and `#chord()` functions for key rendering
- `#section()` function for colored header bands

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach (layout, section order, Typst snippets) | completed | high |
| B | Alternative approaches (4 layouts, Typst packages) | completed | high |
| C | Critic (platform issues, undocumented bindings, contradictions) | completed | high |
| D | Strategic horizons (location, maintainability, learning focus) | completed | high |

## References

- `/home/benjamin/.config/zed/docs/general/keybindings.md` -- Source keybindings documentation (222 lines)
- `/home/benjamin/.config/zed/keymap.json` -- Authoritative custom binding definitions (191 lines)
- VS Code keyboard shortcuts PDF -- Design reference for two-column landscape layout
- Typst Universe packages: `cram-snap` (v0.2.2), `keyle` (v0.2.0), `boxed-sheet` -- evaluated but not recommended
- User memory: `feedback_no_vim_mode_zed.md` -- vim mode off by default, shared with collaborator
- User memory: `project_zed_keymap_context_shadowing.md` -- context shadowing patterns in keymap.json
