# Teammate B Findings: Non-Vim Activation Key Patterns for Custom Keybindings in Zed

**Date**: 2026-04-09
**Focus**: Prefix key alternatives for Zed without vim mode — porting nvim leader bindings to a non-modal context

---

## Key Findings

### 1. The Core Problem: Space as Leader Without Vim Mode

In Neovim, `<Space>` works as a leader key because Normal mode treats it as a motion key that can be remapped. Without vim mode, Zed's editor is always in insert mode — pressing Space types a literal space character. There is no built-in leader key concept for non-vim Zed.

**The solution is chord sequences with a modifier prefix.** Zed supports multi-key sequences where keypresses are separated by spaces in the binding string:
```json
"ctrl-k ctrl-e": "project_panel::ToggleFocus"
```
This means `Ctrl+K` then `E` (without Ctrl held for the second key).

### 2. What Keys Are Available as Prefixes (Linux Default Keymap Analysis)

From analysis of `assets/keymaps/default-linux.json`:

**`ctrl-k` is heavily used** — ~30+ bindings already exist under it. It is Zed's built-in "leader key" equivalent (VS Code uses the same pattern). Many slots are taken:
- `ctrl-k ctrl-s` → open keymap (cannot override safely)
- `ctrl-k ctrl-t` → theme selector
- `ctrl-k ctrl-left/right/up/down` → pane navigation (conflicts with our needs)
- `ctrl-k s`, `ctrl-k r`, `ctrl-k p`, `ctrl-k e`, `ctrl-k t`, `ctrl-k u`, `ctrl-k w` → pane/file ops

**Available under `ctrl-k`** (unbound single-letter slots): `a`, `b` (taken: `ctrl-b`), `c` (taken: `ctrl-c`), `d`, `f`, `g`, `h`, `i` (taken: `ctrl-i`), `j` (taken: `ctrl-j`), `m`, `n`, `o` (taken: `ctrl-o`), `v`, `x`, `y`, `z` (taken: `ctrl-z`).

Bare single-letter chords like `ctrl-k e` (without ctrl on second key) are mostly free.

**`ctrl-g` is used for git operations** (ctrl-g ctrl-g for fetch, ctrl-g up/down for push/pull). Avoid.

**`ctrl-;`** → already bound to `editor::ToggleLineNumbers`. Avoid as prefix.

**`ctrl-.`** → already bound to `editor::ToggleCodeActions`. Avoid.

**Completely unbound as prefix candidates:**
- **`ctrl-space`** — Unbound in default keymap (may conflict with IME on some systems)
- **`ctrl-\`** (ctrl-backslash) — Unbound, but awkward to type
- **`alt-;`** — Unbound (semicolons are accessible)
- **`ctrl-'`** — Unbound (apostrophe as prefix)

### 3. Community Patterns for Non-Vim Zed Users

From GitHub discussions and community configs, non-vim Zed users use three patterns:

**Pattern A: Ctrl+K as leader (VS Code style)**
The dominant community approach. Mirrors VS Code's built-in chord system. Users add bindings to the free slots under `ctrl-k`:
```json
{ "bindings": { "ctrl-k f": "file_finder::Toggle" } }
```

**Pattern B: Comma (`,`) as leader**
Seen in community configs (e.g., from the PanKUN blog). Comma is **completely unbound** in the default keymap, making it a clean prefix:
```json
{ "context": "Editor", "bindings": {
  ", f b": "tab_switcher::Toggle",
  ", f i": "file_finder::Toggle",
  ", f o": "projects::OpenRecent"
}}
```
**Downside**: In non-vim mode, `,` types a literal comma with a ~1 second delay before it registers. Every time you type `, ` in text you get a 1-second wait to see if it's a chord.

**Pattern C: Alt+Letter as single-key bindings**
For simple operations, `alt-e`, `alt-t`, etc. work without any chord delay. Many `alt-` slots are free. Downside: limited namespace, can conflict with menu bar on some Linux DEs.

### 4. How Chord Sequences Work Without Vim Mode

Zed's chord system is mode-agnostic — it works purely by context matching, not by modal state. In any context, if you bind `"ctrl-k f"`, Zed intercepts `Ctrl+K`, waits up to 1 second for the next key, and fires the action if `F` follows.

**Context for non-vim bindings:**
```json
{ "context": "Workspace", "bindings": { ... } }  // everywhere
{ "context": "Editor", "bindings": { ... } }      // when editing
```

Unlike vim bindings that require `"Editor && vim_mode == normal"`, non-vim bindings just use `"Editor"` or `"Workspace"`.

**The timeout behavior**: When you press `Ctrl+K`, Zed waits 1 second. If you type the next key within 1 second, the chord fires. If not, the initial keystroke executes its own binding (if any). Since `Ctrl+K` has no standalone action in default Linux keymap (it's purely a prefix), the 1-second wait is silent — no visual feedback that a chord is pending.

### 5. Which Nvim Bindings to Port and How

Analysis of each nvim binding for non-vim Zed:

| Nvim Binding | Action | Non-Vim Status | Recommended Binding |
|---|---|---|---|
| `<Space>e` | File explorer toggle | Port it | `ctrl-k e` or `alt-e` |
| `Ctrl+P` | File finder | **Already default** — `ctrl-p` works | No change needed |
| `<Space>ff` | Project search | Port it | `ctrl-shift-f` (already default!) |
| `Tab`/`Shift-Tab` | Buffer cycling | Conflicts with tab indent in non-vim | Use `ctrl-tab`/`ctrl-shift-tab` |
| `Ctrl+H/J/K/L` | Split navigation | Port directly — same keys work | `ctrl-h/j/k/l` in Workspace context |
| `Ctrl+T` | Terminal toggle | Port directly | `ctrl-t` in Workspace context |
| `<Space>w` | Save all | Default `ctrl-alt-s` works; port optionally | `ctrl-s` (single save) is default |
| `<Space>gl` | Git blame | Port it | `ctrl-k b` (maps to BlameHover by default; use `alt-g b` which is default!) |
| `<Space>id` | Go to definition | **`F12` is default** | No change needed, or add `ctrl-k d` |
| `<Space>ir` | Find references | **`shift-f12` is default** | No change needed, or add `ctrl-k r` (taken! → `ctrl-k alt-r`) |
| `<Space>iR` | Rename symbol | **`F2` is default** | No change needed |
| `<Space>ic` | Code actions | **`ctrl-.` is default** | No change needed |

**Key insight**: Without vim mode, most LSP actions already have default bindings (F2, F12, Shift+F12, Ctrl+.). The main bindings worth porting are the navigation and UI toggles.

---

## Recommended Prefix Schemes

### Option A: `ctrl-k` Extended (VS Code Style) — Recommended

Extend the existing `ctrl-k` prefix with bare-letter chords (no Ctrl on second key). This is the most intuitive for VS Code emigrants and matches Zed's own convention.

**Pro**: Consistent with Zed's built-in `ctrl-k` bindings. No surprise delays when typing. Familiar.
**Con**: `ctrl-k` is already crowded; requires checking for conflicts. Second key must be bare (not `ctrl-key`).

```json
[
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-k e": "project_panel::ToggleFocus",
      "ctrl-k g": "git_panel::ToggleFocus",
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-k h": "workspace::ActivatePaneUp",
      "ctrl-l": "workspace::ActivatePaneRight",
      "ctrl-t": "workspace::ToggleBottomDock"
    }
  }
]
```

Note: `ctrl-k` in Workspace context conflicts with `ctrl-k` prefix in Editor context — Zed will still wait for second key when editor is focused. This is acceptable behavior.

### Option B: `alt-` Single Keys for UI Toggles — Simple

For a non-vim user who wants clean, no-delay bindings, use `alt-` directly:

**Pro**: No chord delay. Immediate feedback. Very discoverable.
**Con**: Limited namespace. `alt-` can conflict with Linux menu bar (rare in Zed). Can't build mnemonic hierarchies.

```json
[
  {
    "context": "Workspace",
    "bindings": {
      "alt-e": "project_panel::ToggleFocus",
      "alt-g": "git_panel::ToggleFocus",
      "alt-t": "terminal_panel::Toggle",
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-k": "workspace::ActivatePaneUp",
      "ctrl-l": "workspace::ActivatePaneRight"
    }
  }
]
```

**Warning**: `alt-e` may conflict with `alt-enter` (cursor selection suggestion). Check with the keymap editor.

### Option C: Vim Mode ON, Non-Vim Habits Preserved — Hybrid

Keep `vim_mode: true` (which is the current plan) and add bindings for both Normal mode (space leader) and for always-active contexts (split navigation). This is not "without vim" but it's the approach that ports most cleanly from nvim.

This is what Round 1 and Round 2 research already documented. The question is whether the user wants vim mode on or off.

---

## Complete Proposed `keymap.json` (Non-Vim Mode)

This assumes `"vim_mode": false` in settings.json. Uses Option A (`ctrl-k` prefix) for UI toggles and direct `ctrl-` for navigation.

```json
[
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-k e": "project_panel::ToggleFocus",
      "ctrl-k g": "git_panel::ToggleFocus",
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-l": "workspace::ActivatePaneRight",
      "ctrl-t": "workspace::ToggleBottomDock"
    }
  },
  {
    "context": "Editor",
    "bindings": {
      "ctrl-p": "file_finder::Toggle",
      "ctrl-k f": "project_search::ToggleFocus",
      "ctrl-tab": "pane::ActivateNextItem",
      "ctrl-shift-tab": "pane::ActivatePreviousItem",
      "ctrl-k c": "pane::SplitRight",
      "ctrl-k x": "pane::CloseActiveItem",
      "ctrl-k w": "workspace::SaveAll",
      "alt-j": "editor::MoveLineDown",
      "alt-k": "editor::MoveLineUp"
    }
  }
]
```

### Notes on Non-Vim Keymap

**`ctrl-h`**: In Workspace context (not Editor), this is safe. In terminal emulators, `ctrl-h` is backspace — but Zed's terminal handles it differently than the editor pane.

**`ctrl-j`**: Usually safe. Default Linux keymap does not bind it at the Workspace level.

**`ctrl-l`**: Default binds `ctrl-shift-l` for select all occurrences. Bare `ctrl-l` should be free in Workspace.

**`ctrl-tab` / `ctrl-shift-tab`**: These are standard browser-style tab cycling. Not bound by default in Zed. Natural choice for buffer switching in non-vim mode.

**`ctrl-k f`**: The `f` slot under `ctrl-k` is free in the default keymap. Maps to project search.

**`ctrl-k c`**: The `c` slot under `ctrl-k` is free (avoid `ctrl-k ctrl-c` which is toggle comments). Bare `ctrl-k c` (no ctrl on second key) should be free.

**`ctrl-k w`**: The bare `ctrl-k w` is bound to `pane::CloseAllItems` by default. This conflicts. Use `ctrl-k s` instead (but `ctrl-k s` is `workspace::SaveWithoutFormat`). Use `ctrl-shift-s` or `ctrl-alt-s` (which is already the default for SaveAll).

**Git blame**: Default `alt-g b` already works for blame. No custom binding needed.

**Go to definition**: Default `F12` already works. No custom binding needed.

**Rename symbol**: Default `F2` already works. No custom binding needed.

**Code actions**: Default `ctrl-.` already works. No custom binding needed.

---

## Revised `keymap.json` (Non-Vim, Conflict-Checked)

```json
[
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-k e": "project_panel::ToggleFocus",
      "ctrl-k g": "git_panel::ToggleFocus",
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-l": "workspace::ActivatePaneRight",
      "ctrl-t": "workspace::ToggleBottomDock"
    }
  },
  {
    "context": "Editor",
    "bindings": {
      "ctrl-p": "file_finder::Toggle",
      "ctrl-k f": "project_search::ToggleFocus",
      "ctrl-tab": "pane::ActivateNextItem",
      "ctrl-shift-tab": "pane::ActivatePreviousItem",
      "ctrl-k v": "pane::SplitRight",
      "ctrl-k x": "pane::CloseActiveItem",
      "alt-j": "editor::MoveLineDown",
      "alt-k": "editor::MoveLineUp"
    }
  }
]
```

**Changes from initial draft:**
- Removed `ctrl-k w` (conflicts with `pane::CloseAllItems`)
- Renamed split binding to `ctrl-k v` (v for vertical split, `v` slot is free)
- Removed SaveAll binding (use default `ctrl-alt-s`)
- Removed git blame (use default `alt-g b`)

---

## Evidence and Examples

### Confirmed: Zed `ctrl-k` as Dominant Prefix (from default-linux.json)

```
ctrl-k ctrl-s  → zed::OpenKeymap
ctrl-k ctrl-t  → theme_selector::Toggle
ctrl-k ctrl-left/right/up/down → workspace::ActivatePane*
ctrl-k s       → workspace::SaveWithoutFormat
ctrl-k r       → editor::RevealInFileManager
ctrl-k p       → editor::CopyPath
```

This demonstrates `ctrl-k` is already Zed's built-in leader key convention.

### Community Example: Comma Leader (from PanKUN blog)

```json
", f b": "tab_switcher::Toggle",
", f i": "file_finder::Toggle",
", f o": "projects::OpenRecent"
```

No context specified, so these are global bindings. Comma is fully unbound in the default keymap.

### VS Code `ctrl+k` as Leader (from VS Code docs)

VS Code uses `ctrl+k` as a prefix for ~20+ built-in chords. This is the precedent Zed's default keymap follows. Zed's own migration guide explicitly lists: `"Split panes: Cmd+K, Arrow Keys"` as the VS Code-style equivalent.

### Official Docs: Chord Syntax

From zed.dev/docs/key-bindings:
> "Each key in the `"bindings"` map is a sequence of keypresses separated with a space."
> `"cmd-k cmd-s": "zed::OpenKeymap"` — Cmd-K followed by Cmd-S.

No vim mode required for chord sequences.

---

## Confidence Level

**High** (confirmed from official sources / source code):
- Chord sequences work without vim mode — mode-agnostic feature of Zed's input system
- `ctrl-k` is Zed's primary built-in prefix (confirmed from default-linux.json)
- `ctrl-k ctrl-s` opens keymap — cannot be overridden safely
- `ctrl-.` is default code actions — no need to port `<Space>ic`
- `F12` / `Shift+F12` / `F2` are default LSP actions
- Comma (`,`) is completely unbound in default keymap
- `ctrl-;` is already bound to `editor::ToggleLineNumbers`

**Medium** (based on keymap analysis, needs live testing):
- `ctrl-tab` / `ctrl-shift-tab` for buffer cycling — should be free but may conflict with system or terminal
- `ctrl-h`, `ctrl-j`, `ctrl-l` at Workspace level — likely free but depends on GTK/DE key handling
- `ctrl-k e`, `ctrl-k f`, `ctrl-k v`, `ctrl-k g` (bare letter, not ctrl+letter) — free based on source analysis
- `ctrl-k x` for close active item — `x` slot appears free

**Low** (untested):
- Comma prefix in Editor context — technically works but 1-second delay makes it hostile for normal typing
- `alt-j` / `alt-k` for line move — likely free but `alt-j` conflicts on some DEs with window manipulation

---

## Recommendation for This Project

**The user has vim mode ON** (current plan from rounds 1-2). The non-vim analysis above is for reference if vim mode is disabled.

Given `vim_mode: true`, the Round 2 keymap (space-leader in Normal mode + ctrl-h/j/k/l in Workspace) remains the right approach. The non-vim alternative is relevant only if the user decides to disable vim mode for collaborator use.

**If vim mode is ever disabled**, use Option A (`ctrl-k` prefix) as the primary replacement for Space leader, supplemented by direct `ctrl-` bindings for split navigation. Avoid comma prefix due to typing latency. Use `alt-` single keys sparingly for the most common toggles.

---

## Sources

- [Zed Key Bindings Documentation](https://zed.dev/docs/key-bindings)
- [Zed VS Code Migration Guide](https://zed.dev/docs/migrate/vs-code)
- [Zed Default Linux Keymap (raw)](https://raw.githubusercontent.com/zed-industries/zed/main/assets/keymaps/default-linux.json)
- [Leader key in Zed? Discussion #26818](https://github.com/zed-industries/zed/discussions/26818)
- [Vim mode leader key Discussion #6661](https://github.com/zed-industries/zed/discussions/6661)
- [Upcoming keymap.json changes Discussion #34570](https://github.com/zed-industries/zed/discussions/34570)
- [PanKUN Blog: Recommended Zed keymap.json Settings](https://breadmotion.github.io/WebSite/blog/en/blog_00024.html)
- [VS Code Keyboard Shortcuts Reference](https://code.visualstudio.com/docs/configure/keybindings)
- [VS Code Leader Key Extension](https://marketplace.visualstudio.com/items?itemName=JimmyZJX.leaderkey)
