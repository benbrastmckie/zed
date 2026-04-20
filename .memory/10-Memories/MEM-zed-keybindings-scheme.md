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
- **Cmd+H / Cmd+L** — Pane navigation left/right (Workspace + Editor; overrides macOS Hide)
- **Cmd+O / Cmd+I** — Jump list back/forward (Workspace + Editor; Cmd+O overrides Open file)
- **Ctrl+Q** — Close tab (Workspace + Editor)
- **Ctrl+Shift+A** — Launch Claude Code CLI (Workspace + Terminal)
- **Ctrl+> / Ctrl+<** — Indent/outdent (Editor; nulled at Workspace to override agent::AddSelectionToThread)

### cmd- (Cmd on macOS)
- **Cmd+H / Cmd+L** — Focus pane left/right (Workspace + Editor + Terminal; overrides macOS Hide)
- **Cmd+J / Cmd+K** — Explorer navigation down/up (ProjectPanel)

### alt- (Opt on macOS)
- **Opt+V** — Toggle vim mode (Workspace)
- **Ctrl+J / Ctrl+K** — Move line down/up (Editor)
- **Opt+R** — Reload file from disk (Editor)
- **Opt+Shift+E** — Preview in browser via task::Spawn (Typst/Slidev dispatcher)
- **Opt+Shift+P** — Build PDF via task::Spawn (Typst/Slidev dispatcher)

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
