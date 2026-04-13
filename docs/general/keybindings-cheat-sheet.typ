// Zed Keybindings Cheat Sheet
// Synced with keybindings.md and keymap.json on 2026-04-13

#set page(
  paper: "a4",
  flipped: true,
  margin: (top: 1.2cm, bottom: 1.4cm, left: 1cm, right: 1cm),
  columns: 3,
  footer: context {
    set text(7pt, fill: luma(120))
    line(length: 100%, stroke: 0.4pt + luma(180))
    v(2pt)
    grid(
      columns: (1fr, 1fr),
      [#text(weight: "bold")[Legend:]
        #text(
          fill: luma(80),
        )[ #sym.star.filled = custom binding (keymap.json) #h(1em) #sym.arrow.r = sequential press (chord) #h(1em) #sym.dagger = platform-adaptive (Ctrl on Linux, Cmd on macOS)]],
      align(right)[Ctrl = fixed Ctrl on all platforms unless marked #sym.dagger #h(1em) _April 2026_],
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
#shortcut(key-combo("Ctrl", "H"), [Focus pane left], custom: true)
#shortcut(key-combo("Ctrl", "L"), [Focus pane right], custom: true)
#shortcut(key-combo("Ctrl/Cmd", "Enter"), [Open file under cursor #sym.dagger], custom: true)

#section("File Explorer", clr-explorer)

#shortcut(key-combo("h"), [Collapse / go to parent], ctx: "project panel")
#shortcut(key-combo("j"), [Select next entry], ctx: "project panel")
#shortcut(key-combo("k"), [Select previous entry], ctx: "project panel")
#shortcut(key-combo("l"), [Open / expand], ctx: "project panel")

#colbreak()

#section("Editing", clr-editing)

#shortcut(key-combo("Ctrl", "A"), [Select all])
#shortcut(key-combo("Ctrl", "D"), [Select next occurrence])
#shortcut(key-combo("Ctrl", "/"), [Toggle comment])
#shortcut(key-combo("Ctrl", "Shift", "K"), [Delete line])
#shortcut(key-combo("Alt", "K"), [Move line up], custom: true)
#shortcut(key-combo("Alt", "J"), [Move line down], custom: true)
#shortcut(key-combo("Ctrl", ">"), [Indent], custom: true)
#shortcut(key-combo("Ctrl", "<"), [Outdent], custom: true)
#shortcut(key-combo("Alt", "R"), [Reload file from disk], custom: true)

#section("Search & Replace", clr-search)

#shortcut(key-combo("Ctrl", "F"), [Find in file])
#shortcut(key-combo("Ctrl", "Shift", "F"), [Search all files])
#shortcut(key-combo("Ctrl", "Shift", "H"), [Replace across files])

#section("Panels & Layout", clr-panels)

#shortcut(key-combo("Ctrl", "B"), [Toggle left sidebar])
#shortcut(key-combo("Ctrl/Cmd", "Shift", "E"), [File explorer #sym.dagger], custom: true)
#shortcut(key-combo("Ctrl/Cmd", "?"), [Toggle right dock / agent panel #sym.dagger], custom: true)
#shortcut(key-combo("Ctrl", "`"), [Toggle terminal])
#shortcut(key-combo("Ctrl", "\\"), [Split pane right])
#shortcut(key-combo("Ctrl", "Shift", "\\"), [Split pane down])
#shortcut(key-combo("Ctrl", "H"), [Focus pane left], custom: true)
#shortcut(key-combo("Ctrl", "L"), [Focus pane right], custom: true)
#shortcut(key-combo("Ctrl/Cmd", "Shift", "C"), [Copy file path #sym.dagger], custom: true)

#section("Preview", clr-markdown)

#shortcut(chord(("Ctrl", "K"), ("V",)), [Markdown side-by-side])
#shortcut(key-combo("Ctrl", "Shift", "V"), [Markdown full tab])
#shortcut(key-combo("Alt", "Shift", "E"), [Build PDF (Typst / Slidev)], custom: true)
#shortcut(key-combo("Alt", "Shift", "P"), [Preview in browser (Typst / Slidev)], custom: true)

#colbreak()

#section("AI & Agent Panel", clr-ai)

#shortcut(key-combo("Ctrl", "Shift", "A"), [Launch Claude Code CLI], custom: true)
#shortcut(key-combo("Ctrl", "N"), [New thread], ctx: "agent panel")
#shortcut(key-combo("Shift", "Alt", "J"), [Recent threads])
#shortcut(key-combo("Ctrl", "Shift", "H"), [Thread history], ctx: "agent panel")
#shortcut(key-combo("Ctrl", "Shift", "R"), [Review agent changes])
#shortcut(key-combo("Enter"), [Send message], ctx: "agent panel")
#shortcut(key-combo("Shift", "Alt", "Escape"), [Expand message editor])
#shortcut(key-combo("Ctrl", ">"), [Add selection to thread], ctx: "agent panel")
#shortcut(key-combo("Ctrl", "Alt", "/"), [Toggle model selector])
#shortcut(key-combo("Alt", "L"), [Cycle favorite models], ctx: "agent panel")
#shortcut(key-combo("Ctrl", "Alt", "P"), [Manage profiles])
#shortcut(key-combo("Shift", "Tab"), [Cycle profiles], ctx: "agent panel")
#shortcut(key-combo("Ctrl/Cmd", ";"), [Inline assist #sym.dagger], ctx: "editor")
// Note: Ctrl/Cmd+Enter is the Zed default for inline assist but is
// overridden by the custom "Open file under cursor" binding above.

#section("Optional / Advanced", clr-advanced)

#shortcut(key-combo("Alt", "V"), [Toggle vim mode (off by default)], custom: true)
