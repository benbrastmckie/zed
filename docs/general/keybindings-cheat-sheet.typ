// Zed Keybindings Cheat Sheet
// Synced with keybindings.md and keymap.json on 2026-04-19

#set page(
  paper: "us-letter",
  flipped: true,
  margin: (top: 1.2cm, bottom: 1.4cm, left: 1cm, right: 1cm),
  columns: 3,
  footer: context {
    set text(8.5pt, fill: luma(70))
    line(length: 100%, stroke: 0.4pt + luma(180))
    v(3pt)
    grid(
      columns: (1fr, 1fr, 1fr),
      column-gutter: 1.5em,
      align: horizon,
      [#sym.star.filled#h(4pt)Custom binding (keymap.json)],
      [#sym.arrow.r#h(4pt)Sequential press (chord)],
      align(right)[Ctrl bindings use the Control key (not Cmd) #h(1em) _April 2026_],
    )
  },
)

#set text(7.5pt, font: "Liberation Sans")
#set par(leading: 0.45em, spacing: 0.55em)

// --- Color palette for section headers ---
#let clr-essentials = rgb("#2563eb")   // blue
#let clr-navigation = rgb("#0d9488")   // teal
#let clr-editing = rgb("#7c3aed")   // purple
#let clr-search = rgb("#d97706")   // amber
#let clr-panels = rgb("#059669")   // emerald
#let clr-ai = rgb("#1e3a5f")   // navy
#let clr-git = rgb("#dc2626")   // red
#let clr-markdown = rgb("#6366f1")   // indigo
#let clr-slidev = rgb("#db2777")   // pink
#let clr-explorer = rgb("#65a30d")   // lime
#let clr-advanced = rgb("#78716c")   // stone

// --- Helper functions ---

/// Render a single key as a rounded chip
#let key(k) = {
  box(
    fill: luma(232),
    stroke: 0.5pt + luma(175),
    radius: 2pt,
    inset: (x: 3pt, y: 1.5pt),
    text(6.5pt, font: "Liberation Mono", weight: "medium", k),
  )
}

/// Render a key combination (simultaneous press), e.g. key-combo("Ctrl", "Shift", "P")
#let key-combo(..keys) = {
  let items = keys.pos()
  for (i, k) in items.enumerate() {
    key(k)
    if i < items.len() - 1 {
      text(7pt, fill: luma(140), sym.plus)
    }
  }
}

/// Render a chord (sequential press), e.g. chord(("Ctrl", "K"), ("V",))
/// Each argument is an array of simultaneous keys
#let chord(first, second) = {
  key-combo(..first)
  h(2pt)
  text(8pt, fill: luma(100), weight: "bold", sym.arrow.r)
  h(2pt)
  key-combo(..second)
}

/// Render a shortcut row: keys + description + optional custom marker
#let shortcut(keys, description, custom: false, ctx: none) = {
  grid(
    columns: (3.6cm, 1fr),
    column-gutter: 4pt,
    align(left, keys),
    {
      text(description)
      if ctx != none {
        h(3pt)
        text(7pt, style: "italic", fill: luma(100), [_(#ctx)_])
      }
      if custom {
        h(2pt)
        text(7.5pt, fill: luma(100), sym.star.filled)
      }
    },
  )
}

/// Render a section header band
#let section(title, color) = {
  v(4pt)
  block(
    width: 100%,
    fill: color.lighten(85%),
    stroke: (left: 2.5pt + color),
    inset: (x: 6pt, y: 3pt),
    text(8pt, weight: "bold", fill: color.darken(15%), title),
  )
  v(2pt)
}

// ====================================================================
// HEADER
// ====================================================================

#place(
  top,
  scope: "parent",
  float: true,
  {
    text(13pt, weight: "bold", fill: luma(30))[Zed Keybindings Cheat Sheet]
    v(2pt)
    line(length: 100%, stroke: 0.6pt + luma(200))
    v(4pt)
  },
)

// ====================================================================
// CONTENT
// ====================================================================

#section("Essentials", clr-essentials)

#shortcut(key-combo("Cmd", "P"), [Open file by name])
#shortcut(key-combo("Cmd", "S"), [Save file])
#shortcut(key-combo("Cmd", "Z"), [Undo])
#shortcut(key-combo("Cmd", "Shift", "Z"), [Redo])
#shortcut(key-combo("Cmd", "C"), [Copy])
#shortcut(key-combo("Cmd", "X"), [Cut])
#shortcut(key-combo("Cmd", "V"), [Paste])
#shortcut(key-combo("Ctrl", "Q"), [Close tab], custom: true)
#shortcut(key-combo("Cmd", "Shift", "P"), [Command palette])
#shortcut(key-combo("Cmd", ","), [Open settings])

#section("Navigation", clr-navigation)

#shortcut(key-combo("Ctrl", "G"), [Go to line])
#shortcut(key-combo("F12"), [Go to definition])
#shortcut(key-combo("Ctrl", "O"), [Jump back], custom: true)
#shortcut(key-combo("Ctrl", "I"), [Jump forward], custom: true)
#shortcut(key-combo("Opt", "Left"), [Go back])
#shortcut(key-combo("Opt", "Right"), [Go forward])
#shortcut(key-combo("Ctrl", "Tab"), [Next tab])
#shortcut(key-combo("Ctrl", "Shift", "Tab"), [Previous tab])
#shortcut(key-combo("Cmd", "Shift", "T"), [Reopen closed tab])
#shortcut(key-combo("Ctrl", "H"), [Focus pane left], custom: true)
#shortcut(key-combo("Ctrl", "L"), [Focus pane right], custom: true)
#shortcut(key-combo("Cmd", "Enter"), [Open file under cursor], custom: true)

#section("File Explorer", clr-explorer)

#shortcut(key-combo("h"), [Collapse / go to parent], ctx: "project panel")
#shortcut(key-combo("j"), [Select next entry], ctx: "project panel")
#shortcut(key-combo("k"), [Select previous entry], ctx: "project panel")
#shortcut(key-combo("l"), [Open / expand], ctx: "project panel")

#colbreak()

#section("Editing", clr-editing)

#shortcut(key-combo("Cmd", "A"), [Select all])
#shortcut(key-combo("Cmd", "D"), [Select next occurrence])
#shortcut(key-combo("Cmd", "/"), [Toggle comment])
#shortcut(key-combo("Cmd", "Shift", "K"), [Delete line])
#shortcut(key-combo("Opt", "K"), [Move line up], custom: true)
#shortcut(key-combo("Opt", "J"), [Move line down], custom: true)
#shortcut(key-combo("Cmd", "]"), [Indent line])
#shortcut(key-combo("Cmd", "["), [Outdent line])
#shortcut(key-combo("Opt", "R"), [Reload file from disk], custom: true)

#section("Search & Replace", clr-search)

#shortcut(key-combo("Cmd", "F"), [Find in file])
#shortcut(key-combo("Cmd", "Shift", "F"), [Search all files])
#shortcut(key-combo("Cmd", "Shift", "H"), [Replace across files])

#section("Panels & Layout", clr-panels)

#shortcut(key-combo("Cmd", "B"), [Toggle left sidebar])
#shortcut(key-combo("Cmd", "Shift", "E"), [File explorer], custom: true)
#shortcut(key-combo("Cmd", "?"), [Toggle right dock / agent panel], custom: true)
#shortcut(key-combo("Ctrl", "`"), [Toggle terminal])
#shortcut(key-combo("Cmd", "\\"), [Split pane right])
#shortcut(key-combo("Cmd", "Shift", "\\"), [Split pane down])
#shortcut(key-combo("Cmd", "Shift", "C"), [Copy file path], custom: true)

#section("Preview", clr-markdown)

#shortcut(chord(("Cmd", "K"), ("V",)), [Markdown side-by-side])
#shortcut(key-combo("Cmd", "Shift", "V"), [Markdown full tab])
#shortcut(key-combo("Opt", "Shift", "E"), [Build PDF (Typst / Slidev)], custom: true)
#shortcut(key-combo("Opt", "Shift", "P"), [Preview in browser (Typst / Slidev)], custom: true)

#colbreak()

#section("AI & Agent Panel", clr-ai)

#shortcut(key-combo("Ctrl", "Shift", "A"), [Launch Claude Code CLI], custom: true)
#shortcut(key-combo("Cmd", "N"), [New thread], ctx: "agent panel")
#shortcut(key-combo("Shift", "Opt", "J"), [Recent threads])
#shortcut(key-combo("Cmd", "Shift", "H"), [Thread history], ctx: "agent panel")
#shortcut(key-combo("Cmd", "Shift", "R"), [Review agent changes])
#shortcut(key-combo("Enter"), [Send message], ctx: "agent panel")
#shortcut(key-combo("Shift", "Opt", "Escape"), [Expand message editor])
#shortcut(key-combo("Cmd", ">"), [Add selection to thread], ctx: "agent panel")
#shortcut(key-combo("Ctrl", "Opt", "/"), [Toggle model selector])
#shortcut(key-combo("Opt", "L"), [Cycle favorite models], ctx: "agent panel")
#shortcut(key-combo("Ctrl", "Opt", "P"), [Manage profiles])
#shortcut(key-combo("Shift", "Tab"), [Cycle profiles], ctx: "agent panel")
#shortcut(key-combo("Cmd", ";"), [Inline assist], ctx: "editor")
// Note: Cmd+Enter is the Zed default for inline assist but is
// overridden by the custom "Open file under cursor" binding above.

#section("Optional / Advanced", clr-advanced)

#shortcut(key-combo("Opt", "V"), [Toggle vim mode (off by default)], custom: true)
