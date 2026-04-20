---
title: "Zed keybindings Scheme A (minimal custom set)"
created: 2026-04-15
tags: [CONFIG, zed, keybindings, shortcuts]
topic: "zed/keybindings"
source: "keymap.json"
modified: 2026-04-15
retrieval_count: 0
last_retrieved: null
keywords: [keybindings, shortcuts, keymap, modifiers, bindings, scheme, zed]
summary: "Scheme A custom keybindings with 17 unique bindings across three modifier categories"
---

# Zed Keybindings Scheme A

17 unique custom bindings (26 entries across contexts). Three modifier categories:

## Modifier Categories

### secondary- (platform-adaptive: Ctrl on Linux, Cmd on macOS)
- **Secondary+?** — Toggle right dock (agent panel)
- **Secondary+Shift+E** — Toggle left dock / file explorer (Workspace + Editor)
- **Secondary+Shift+C** — Copy file path (Editor)
- **Secondary+Enter** — Open file under cursor (Editor)

### ctrl- (fixed Ctrl on ALL platforms, including macOS)
- **Ctrl+H / Ctrl+L** — Pane navigation left/right (Workspace + Editor)
- **Ctrl+O / Ctrl+I** — Jump list back/forward (Workspace + Editor)
- **Ctrl+Q** — Close tab (Workspace + Editor)
- **Ctrl+Shift+A** — Launch Claude Code CLI (Workspace + Terminal)
- **Ctrl+> / Ctrl+<** — Indent/outdent (Editor; nulled at Workspace to override agent::AddSelectionToThread)

### alt- (fixed Alt on all platforms)
- **Alt+V** — Toggle vim mode (Workspace)
- **Alt+J / Alt+K** — Move line down/up (Editor)
- **Alt+R** — Reload file from disk (Editor)
- **Alt+Shift+E** — Build PDF via task::Spawn (Typst/Slidev dispatcher)
- **Alt+Shift+P** — Preview in browser via task::Spawn (Typst/Slidev dispatcher)

## Project Panel Navigation (hjkl without vim mode)
Context: `ProjectPanel && not_editing`
- **h** — Collapse selected entry
- **j** — Select next
- **k** — Select previous
- **l** — Open file / expand directory

## Key Zed Defaults (macOS reference)
- Cmd+P (file finder), Cmd+S (save), Cmd+Shift+F (project search)
- Cmd+` (terminal), Cmd+Shift+P (command palette), Cmd+, (settings)
- Ctrl+Tab / Ctrl+Shift+Tab (tab switching)
- F12 (go to definition), Cmd+D (select next occurrence)
- Cmd+/ (toggle comment), Cmd+Shift+K (delete line)

## Connections
<!-- Add links to related memories using [[filename]] syntax -->
