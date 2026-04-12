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
       #text(fill: luma(80))[ #sym.star.filled = custom binding (keymap.json) #h(1em) #sym.arrow.r = sequential press (chord)]],
      align(right)[Linux notation. On macOS, substitute Cmd for Ctrl. #h(1em) _April 2026_],
    )
  },
)

#set text(8.5pt, font: "Liberation Sans")
#set par(leading: 0.5em, spacing: 0.65em)

// --- Color palette for section headers ---
#let clr-essentials = rgb("#2563eb")   // blue
#let clr-navigation = rgb("#0d9488")   // teal
#let clr-editing    = rgb("#7c3aed")   // purple
#let clr-search     = rgb("#d97706")   // amber
#let clr-panels     = rgb("#059669")   // emerald
#let clr-ai         = rgb("#1e3a5f")   // navy
#let clr-git        = rgb("#dc2626")   // red
#let clr-markdown   = rgb("#6366f1")   // indigo
#let clr-slidev     = rgb("#db2777")   // pink
#let clr-explorer   = rgb("#65a30d")   // lime
#let clr-advanced   = rgb("#78716c")   // stone

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

// Content will be populated in Phase 2
