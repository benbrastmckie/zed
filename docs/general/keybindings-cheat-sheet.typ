// Zed Keybindings Cheat Sheet
// Synced with keybindings.md and keymap.json on 2026-04-11

#set page(
  paper: "a4",
  flipped: true,
  margin: (top: 1.2cm, bottom: 1.4cm, left: 1cm, right: 1cm),
  columns: 2,
  footer: context {
    set text(7pt, fill: luma(120))
    line(length: 100%, stroke: 0.4pt + luma(180))
    v(2pt)
    grid(
      columns: (1fr, 1fr),
      [#text(weight: "bold")[Legend:]
        #text(
          fill: luma(80),
        )[ #sym.star.filled = custom binding (keymap.json) #h(1em) #sym.arrow.r = sequential press (chord)]],
      align(right)[Linux notation. On macOS, substitute Cmd for Ctrl. #h(1em) _April 2026_],
    )
  },
)

#set text(8.5pt, font: "Liberation Sans")
#set par(leading: 0.5em, spacing: 0.65em)

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
    text(7.5pt, font: "Liberation Mono", weight: "medium", k),
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
    columns: (5.2cm, 1fr),
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
    text(9pt, weight: "bold", fill: color.darken(15%), title),
  )
  v(2pt)
}

// ====================================================================
// HEADER
// ====================================================================

#align(center)[
  #text(16pt, weight: "bold", fill: luma(30))[Zed Keybindings Cheat Sheet]
  #h(1em)
  #text(9pt, fill: luma(100))[Organized from essential to specialized]
]
#v(2pt)
#line(length: 100%, stroke: 0.6pt + luma(200))
#v(4pt)

// ====================================================================
// PAGE 1 -- Everyday Use
// ====================================================================

#section("Essentials", clr-essentials)

#shortcut(key-combo("Ctrl", "P"), [Open file by name])
#shortcut(key-combo("Ctrl", "S"), [Save file])
#shortcut(key-combo("Ctrl", "Z"), [Undo])
#shortcut(key-combo("Ctrl", "Shift", "Z"), [Redo])
#shortcut(key-combo("Ctrl", "C"), [Copy])
#shortcut(key-combo("Ctrl", "X"), [Cut])
#shortcut(key-combo("Ctrl", "V"), [Paste])
#shortcut(key-combo("Ctrl", "Q"), [Close tab], custom: true)
#shortcut(key-combo("Ctrl", "Shift", "P"), [Command palette])
#shortcut(key-combo("Ctrl", ","), [Open settings])

#section("Navigation", clr-navigation)

#shortcut(key-combo("Ctrl", "G"), [Go to line])
#shortcut(key-combo("F12"), [Go to definition])
#shortcut(key-combo("Ctrl", "O"), [Jump back], custom: true)
#shortcut(key-combo("Ctrl", "I"), [Jump forward], custom: true)
#shortcut(key-combo("Alt", "Left"), [Go back])
#shortcut(key-combo("Alt", "Right"), [Go forward])
#shortcut(key-combo("Ctrl", "Tab"), [Next tab])
#shortcut(key-combo("Ctrl", "Shift", "Tab"), [Previous tab])
#shortcut(key-combo("Ctrl", "Shift", "T"), [Reopen closed tab])
#shortcut(key-combo("Ctrl", "Enter"), [Open file under cursor], custom: true)

#section("Editing", clr-editing)

#shortcut(key-combo("Ctrl", "A"), [Select all])
#shortcut(key-combo("Ctrl", "D"), [Select next occurrence])
#shortcut(key-combo("Ctrl", "/"), [Toggle comment])
#shortcut(key-combo("Ctrl", "Shift", "K"), [Delete line])
#shortcut(key-combo("Alt", "K"), [Move line up], custom: true)
#shortcut(key-combo("Alt", "J"), [Move line down], custom: true)
#shortcut(key-combo("Ctrl", "]"), [Indent])
#shortcut(key-combo("Ctrl", "["), [Outdent])

#colbreak()

#section("Search & Replace", clr-search)

#shortcut(key-combo("Ctrl", "F"), [Find in file])
#shortcut(key-combo("Ctrl", "Shift", "F"), [Search all files])
#shortcut(key-combo("Ctrl", "Shift", "H"), [Replace across files])

#section("Panels & Layout", clr-panels)

#shortcut(key-combo("Ctrl", "B"), [Toggle left sidebar])
#shortcut(key-combo("Ctrl", "Shift", "E"), [File explorer], custom: true)
#shortcut(key-combo("Ctrl", "?"), [Toggle right dock / agent panel], custom: true)
#shortcut(key-combo("Ctrl", "`"), [Toggle terminal])
#shortcut(key-combo("Ctrl", "\\"), [Split pane right])
#shortcut(key-combo("Ctrl", "Shift", "\\"), [Split pane down])
#shortcut(key-combo("Ctrl", "H"), [Focus pane left], custom: true)
#shortcut(key-combo("Ctrl", "L"), [Focus pane right], custom: true)
#shortcut(key-combo("Ctrl", "Shift", "C"), [Copy file path], custom: true)

// ====================================================================
// PAGE 2 -- Specialized
// ====================================================================

#pagebreak()

#section("AI & Agent Panel", clr-ai)

#shortcut(key-combo("Ctrl", "Shift", "A"), [Launch Claude Code CLI], custom: true)
#shortcut(key-combo("Ctrl", "N"), [New thread], ctx: "agent panel")
#shortcut(key-combo("Shift", "Alt", "J"), [Recent threads])
#shortcut(key-combo("Ctrl", "Shift", "H"), [Thread history], ctx: "agent panel")
#shortcut(key-combo("Ctrl", "Shift", "R"), [Review agent changes])
#shortcut(key-combo("Enter"), [Send message], ctx: "agent panel")
#shortcut(key-combo("Shift", "Alt", "Escape"), [Expand message editor])
#shortcut(key-combo("Ctrl", ">"), [Add selection to thread])
#shortcut(key-combo("Ctrl", "Alt", "/"), [Toggle model selector])
#shortcut(key-combo("Alt", "L"), [Cycle favorite models], ctx: "agent panel")
#shortcut(key-combo("Ctrl", "Alt", "P"), [Manage profiles])
#shortcut(key-combo("Shift", "Tab"), [Cycle profiles], ctx: "agent panel")
#shortcut(key-combo("Ctrl", "Enter"), [Inline assist], ctx: "editor")

#section("Edit Predictions", clr-ai)

#shortcut(key-combo("Tab"), [Accept prediction])
#shortcut(key-combo("Alt", "L"), [Accept prediction (alt)], ctx: "editor")
#shortcut(key-combo("Alt", "]"), [Next prediction])
#shortcut(key-combo("Alt", "["), [Previous prediction])

#colbreak()

#section("Git", clr-git)

#shortcut(key-combo("Ctrl", "Shift", "G"), [Git panel])
#shortcut(chord(("Alt", "G"), ("B",)), [Git blame])

#section("Markdown", clr-markdown)

#shortcut(chord(("Ctrl", "K"), ("V",)), [Preview side-by-side])
#shortcut(key-combo("Ctrl", "Shift", "V"), [Preview full tab])

#section("Build / Preview (Typst + Slidev)", clr-slidev)

#shortcut(key-combo("Alt", "Shift", "E"), [Build PDF], custom: true)
#shortcut(key-combo("Alt", "Shift", "P"), [Preview in browser], custom: true)
#shortcut([], text(7.5pt, fill: luma(120))[Dispatches by file extension: .typ #sym.arrow.r Typst, .md #sym.arrow.r Slidev])

#section("File Explorer", clr-explorer)

#shortcut(key-combo("h"), [Collapse / go to parent], ctx: "project panel")
#shortcut(key-combo("j"), [Select next entry], ctx: "project panel")
#shortcut(key-combo("k"), [Select previous entry], ctx: "project panel")
#shortcut(key-combo("l"), [Open / expand], ctx: "project panel")

#section("Optional / Advanced", clr-advanced)

#shortcut(key-combo("Alt", "V"), [Toggle vim mode (off by default)], custom: true)
