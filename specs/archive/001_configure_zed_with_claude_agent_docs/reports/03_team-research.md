# Research Report: Task #1 (Round 3)

**Task**: Configure Zed with Claude agent system documentation
**Date**: 2026-04-10
**Mode**: Team Research (4 teammates)
**Focus**: Standard Zed keybindings, non-vim leader keys, feature inventory, combined scheme options

## Summary

With vim mode disabled (collaborator requirement), the entire Round 2 keymap.json is incompatible and must be replaced. Zed's defaults already cover most needs (file finder, project search, LSP, git blame). Only 8-12 custom bindings are needed. Three keybinding schemes are presented for user selection. **Correction**: Markdown preview DOES exist in Zed (`Ctrl+K V`).

## Critical Design Change: No Vim Mode

**Reason**: Zed setup is shared with a collaborator unfamiliar with vim.

**Impact on plan**:
- `settings.json`: Remove `vim_mode`, `vim` block, `relative_line_numbers`
- `keymap.json`: Replace entirely (Round 2 version is 100% vim-dependent)
- `docs/settings.md`: Remove vim explanation, add modifier pattern guide
- `README.md`: Simpler quick start (no vim caveat)
- **Risks eliminated**: Tab/Shift-Tab conflict and `space i shift-r` chord issues disappear

## Key Findings

### 1. Zed Defaults Already Cover Most Needs

No custom binding needed for these (all have good defaults):

| Action | Default Shortcut | Notes |
|--------|-----------------|-------|
| File finder | `Ctrl+P` | Fuzzy search, identical to nvim's Ctrl+P |
| Project search | `Ctrl+Shift+F` | Multi-file search with editable results |
| File explorer | `Ctrl+Shift+E` or `Ctrl+B` | Toggle left dock/project panel |
| Terminal | `` Ctrl+` `` | Toggle terminal panel |
| Go to definition | `F12` | Universal LSP standard |
| Find references | `Shift+F12` or `Alt+Shift+F12` | LSP references |
| Rename symbol | `F2` | Universal standard |
| Code actions | `Ctrl+.` | Quick fix menu |
| Git blame | `Alt+G B` | Inline blame toggle |
| Git panel | `Ctrl+Shift+G` | Full staging/commit UI |
| Save all | `Ctrl+Alt+S` | Save all open files |
| Close tab | `Ctrl+W` | Standard |
| Command palette | `Ctrl+Shift+P` | Universal launcher |
| Agent panel | `Ctrl+?` | Claude Code toggle |
| Markdown preview | `Ctrl+K V` (side) / `Ctrl+Shift+V` (full) | **EXISTS** — prior rounds were wrong |

### 2. Correction: Markdown Preview Exists

Prior rounds claimed "Zed has no markdown preview." This is **wrong**. The `default-linux.json` keymap includes:
- `Ctrl+K V` → Open preview side-by-side
- `Ctrl+Shift+V` → Open preview focused

These are built-in keybindings. The preview may depend on a markdown extension being installed.

### 3. Features With No Default Binding (Worth Adding)

| Feature | Gap | Recommended Binding |
|---------|-----|---------------------|
| Pane navigation | Default is `Ctrl+K Ctrl+Arrow` (2-chord) | `Ctrl+H/J/K/L` |
| Line movement | No default | `Alt+J/K` |
| Zen mode / centered layout | No default | `Ctrl+Alt+Z` |
| Toggle soft wrap | No default | `Alt+Z` |
| Duplicate line | Default is `Ctrl+Alt+Shift+Down` (3-modifier) | `Ctrl+Shift+D` |
| Delete line | May need explicit binding | `Ctrl+Shift+K` |
| Toggle inlay hints | No default | `Ctrl+Alt+I` |
| Spawn LibreOffice task | No default per task | `Ctrl+Alt+L` |

### 4. Non-Vim Leader Key Options

Without vim mode, Space cannot be a leader key. Best alternatives:

| Option | Pattern | Pros | Cons |
|--------|---------|------|------|
| **`Ctrl+K` prefix** | `ctrl-k e`, `ctrl-k g` | Zed's built-in convention, mirrors VS Code | Already crowded (~30 bindings); second key after 1-sec wait |
| **`Alt+` single keys** | `alt-e`, `alt-g` | No chord delay, immediate | Limited namespace, can conflict with DE |
| **Comma (`,`) prefix** | `, f b`, `, e` | Completely unbound | 1-second delay on every comma typed — hostile for prose |
| **`Ctrl+Alt+` prefix** | `ctrl-alt-e`, `ctrl-alt-g` | Clean namespace, rarely used by Zed | Not discoverable; less familiar |

**Recommendation**: `Ctrl+K` for Zed-convention actions, `Ctrl+Alt` for custom additions, `Alt` for editing operations.

## Keybinding Scheme Options for User Selection

### Scheme A: Minimal (4 custom bindings)

Only pane navigation + line movement. Trust Zed defaults for everything else.

```json
[
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-k": "workspace::ActivatePaneUp",
      "ctrl-l": "workspace::ActivatePaneRight"
    }
  },
  {
    "context": "Editor",
    "bindings": {
      "alt-j": "editor::MoveLineDown",
      "alt-k": "editor::MoveLineUp"
    }
  }
]
```

| Pros | Cons |
|------|------|
| Zero conflict risk | Fewest ergonomic improvements |
| Collaborator needs zero retraining | Ex-nvim user must fully adapt to Zed defaults |
| Survives Zed updates | `Alt+G B` for git blame stays awkward |

### Scheme B: Power User (16 custom bindings)

Full `Ctrl+Alt+*` mapping of nvim concepts to non-vim keys.

```json
[
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-k": "workspace::ActivatePaneUp",
      "ctrl-l": "workspace::ActivatePaneRight",
      "ctrl-shift-t": "workspace::ToggleBottomDock"
    }
  },
  {
    "context": "Editor",
    "bindings": {
      "alt-j": "editor::MoveLineDown",
      "alt-k": "editor::MoveLineUp",
      "ctrl-shift-k": "editor::DeleteLine",
      "ctrl-shift-d": "editor::DuplicateLineDown",
      "ctrl-shift-b": "tab_switcher::Toggle",
      "ctrl-alt-b": "git::Blame",
      "ctrl-alt-g": "git_panel::ToggleFocus",
      "ctrl-alt-e": "project_panel::ToggleFocus",
      "ctrl-alt-f": "project_search::ToggleFocus",
      "ctrl-alt-c": "pane::SplitRight",
      "ctrl-alt-w": "pane::CloseActiveItem",
      "ctrl-alt-d": "editor::GoToDefinition",
      "ctrl-alt-r": "editor::FindAllReferences",
      "ctrl-alt-n": "editor::Rename",
      "ctrl-alt-a": "editor::ToggleCodeActions",
      "ctrl-alt-i": "editor::Hover"
    }
  }
]
```

| Pros | Cons |
|------|------|
| Near-complete nvim workflow port | Collaborator must learn custom system |
| Consistent `Ctrl+Alt` prefix | Two concurrent mental models |
| All shortcuts are explicit | LSP actions duplicate F-key defaults |

### Scheme C: Balanced (12 custom bindings) — RECOMMENDED

Keeps all Zed defaults, adds only the highest-value ergonomic improvements.

```json
[
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-k": "workspace::ActivatePaneUp",
      "ctrl-l": "workspace::ActivatePaneRight",
      "ctrl-alt-z": [
        "action::Sequence",
        ["workspace::CloseAllDocks", "workspace::ToggleCenteredLayout"]
      ],
      "ctrl-alt-l": ["task::Spawn", {"task_name": "Open in LibreOffice"}]
    }
  },
  {
    "context": "Editor",
    "bindings": {
      "alt-j": "editor::MoveLineDown",
      "alt-k": "editor::MoveLineUp",
      "alt-z": "editor::ToggleSoftWrap",
      "ctrl-shift-d": "editor::DuplicateLineDown",
      "ctrl-shift-k": "editor::DeleteLine",
      "ctrl-alt-b": "git::Blame"
    }
  }
]
```

**What it covers that defaults don't**:
- Pane navigation (biggest daily-driver improvement)
- Line movement (`Alt+J/K`)
- Zen mode (centered layout + close docks)
- Soft wrap toggle (essential for markdown)
- Duplicate line (ergonomic improvement)
- Delete line (VS Code standard)
- Git blame (shorter than `Alt+G B`)
- LibreOffice task launch

**What stays at defaults** (collaborator-friendly):
- `Ctrl+P` file finder, `Ctrl+Shift+F` search, `Ctrl+Shift+E` explorer
- `F12` definition, `F2` rename, `Ctrl+.` code actions
- `Ctrl+?` agent panel, `Ctrl+W` close tab, `` Ctrl+` `` terminal

| Pros | Cons |
|------|------|
| 90% collaborator muscle memory preserved | Primary user must adapt LSP bindings to F-keys |
| Highest-value nvim habits retained | No single-key leader pattern |
| Low conflict risk | `Ctrl+K` pane-up may conflict with chord prefix |
| Eliminates Round 2 vim risks | Fewer total bindings than Scheme B |

### Items Needing Live Testing (All Schemes)

1. **`Ctrl+K` pane-up**: May be intercepted as chord prefix start
2. **`Ctrl+H` in search context**: May conflict with find-and-replace (`Ctrl+H` is default)
3. **`Alt+J/K`**: Should work but confirm on NixOS/DE
4. **`Ctrl+D`**: Verify it does `SelectNextOccurrence` by default

## Complete Default Keybinding Reference

Teammate A produced a comprehensive 250+ binding reference across 17 categories (file ops, navigation, editing, cursor, selection, folding, diagnostics, search, panels, splits, tabs, terminal, AI/agent, inline assist, git, debugger, markdown). Full reference at `03_teammate-a-findings.md`.

**Most relevant categories for documentation**:
- AI/Agent Panel: 25+ bindings (Ctrl+?, Ctrl+N, Ctrl+;, Ctrl+Enter, etc.)
- Panels: 15+ bindings (Ctrl+B, Ctrl+J, Ctrl+Shift+E/G/D/M)
- Search: 15+ bindings (Ctrl+F, Ctrl+H, Ctrl+Shift+F/H)
- Git: 20+ bindings (Alt+G B, Ctrl+Shift+G, Ctrl+G chords)
- Markdown: Ctrl+K V preview, Ctrl+K Ctrl+Q rewrap

## Synthesis

### Conflicts Between Teammates

| Conflict | Resolution |
|----------|------------|
| Teammate B still assumes vim_mode=true | **Corrected**: User explicitly said no vim mode; use non-vim analysis |
| Teammate C says `Ctrl+D` is "SelectNextOccurrence" | **Confirmed**: This IS the Zed default — included in Schemes B and C for explicitness |
| Teammate B recommends `ctrl-k e/f/g` prefix | **Superseded by Scheme C**: `Ctrl+Alt` prefix is cleaner and avoids `Ctrl+K` chord conflicts |
| `Ctrl+H` conflict between search-replace and pane nav | **Context resolves**: `Ctrl+H` in `Workspace` context = pane nav; in `Editor` context = find-replace |

### Recommendation

**Scheme C (Balanced)** with these caveats:
1. Test `Ctrl+K` for pane-up at launch; fallback to `Ctrl+Alt+Up` if intercepted
2. Test `Ctrl+H` in Workspace vs Editor context precedence
3. Keep the full default reference (03_teammate-a-findings.md) in docs for user discovery

The plan must be revised to remove vim_mode and use the selected keybinding scheme.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Complete default Zed keybindings (250+) | completed | high |
| B | Non-vim prefix key patterns, chord syntax | completed | high |
| C | Feature inventory, commonly added bindings | completed | high |
| D | Combined scheme options, plan impact | completed | high |

## References

- Zed default-linux.json: github.com/zed-industries/zed/blob/main/assets/keymaps/default-linux.json
- Zed key bindings docs: https://zed.dev/docs/key-bindings
- Zed vim mode docs: https://zed.dev/docs/vim
- VS Code migration: https://zed.dev/docs/migrate/vs-code
- Zed tasks docs: https://zed.dev/docs/tasks
- jellydn/zed-101-setup (community reference)
- Zed hidden gems blog: https://zed.dev/blog/hidden-gems-part-3
