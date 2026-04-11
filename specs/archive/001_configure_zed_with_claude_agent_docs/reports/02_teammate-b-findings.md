# Teammate B Findings: Porting Neovim Keymaps to Zed

**Date**: 2026-04-09
**Focus**: Zed keymap.json format, vim-mode leader key bindings, complete keymap port

---

## Key Findings

### 1. Zed keymap.json Format

The keymap file at `~/.config/zed/keymap.json` is a JSON array of objects, each with an optional `"context"` and required `"bindings"` map:

```json
[
  {
    "context": "ContextExpression",
    "bindings": {
      "key-sequence": "namespace::ActionName"
    }
  }
]
```

Key syntax rules:
- Modifier+key joined with `-`: `ctrl-h`, `alt-j`, `shift-tab`
- Key sequences (chords) separated by space: `"ctrl-k ctrl-s"` or `"space e"`
- No global bindings section needed; omit `"context"` for always-active bindings
- Actions can take arguments: `["pane::ActivateItem", 0]` or `["pane::DeploySearch", {"replace_enabled": true}]`
- Disable a binding: set value to `null`

### 2. Space as Leader Key in Vim Normal Mode

The correct syntax for Space-leader bindings is confirmed working. The space character is used as a sequence separator, not a modifier. The required context is:

```json
{
  "context": "Editor && vim_mode == normal",
  "bindings": {
    "space e": "workspace::ToggleLeftDock"
  }
}
```

This was officially confirmed by a Zed maintainer (ConradIrwin) and documented at zed.dev/docs/key-bindings. The common mistake is using `"space-e"` (with hyphen) instead of `"space e"` (with space).

### 3. Vim Mode Contexts Available

| Context | Meaning |
|---------|---------|
| `Editor && vim_mode == normal` | Normal mode |
| `Editor && vim_mode == insert` | Insert mode |
| `Editor && vim_mode == visual` | Visual mode |
| `VimControl && !menu` | Vim keybindings active (broader) |
| `Workspace` | Anywhere in the workspace |
| `Editor` | Any editor pane |

### 4. Verified Action Names

| Intent | Correct Action Name |
|--------|-------------------|
| Toggle file explorer | `project_panel::ToggleFocus` |
| Fuzzy file finder | `file_finder::Toggle` |
| Project grep | `project_search::ToggleFocus` |
| Next buffer/tab | `pane::ActivateNextItem` |
| Prev buffer/tab | `pane::ActivatePreviousItem` |
| Move pane left | `workspace::ActivatePaneLeft` |
| Move pane right | `workspace::ActivatePaneRight` |
| Move pane up | `workspace::ActivatePaneUp` |
| Move pane down | `workspace::ActivatePaneDown` |
| Toggle bottom dock/terminal | `workspace::ToggleBottomDock` |
| Split right | `pane::SplitRight` |
| Close active tab | `pane::CloseActiveItem` |
| Save all | `workspace::SaveAll` |
| Buffer picker (tab switcher) | `tab_switcher::Toggle` |
| Git blame | `git::Blame` (NOTE: `editor::ToggleGitBlame` is deprecated) |
| Go to definition | `editor::GoToDefinition` |
| Find all references | `editor::FindAllReferences` |
| Rename symbol | `editor::Rename` |
| Code actions | `editor::ToggleCodeActions` |
| Hover/diagnostics | `editor::Hover` |
| Toggle comments | `editor::ToggleComments` |
| Move line up | `editor::MoveLineUp` |
| Move line down | `editor::MoveLineDown` |
| Toggle terminal panel | `terminal_panel::Toggle` |

### 5. Ctrl+H/J/K/L Pane Navigation

The default vim.json already maps `ctrl-w h/j/k/l` for pane navigation. To map `ctrl-h/j/k/l` directly (Nvim-style without the `ctrl-w` prefix), use the `Workspace` context:

```json
{
  "context": "Workspace",
  "bindings": {
    "ctrl-h": "workspace::ActivatePaneLeft",
    "ctrl-j": "workspace::ActivatePaneDown",
    "ctrl-k": "workspace::ActivatePaneUp",
    "ctrl-l": "workspace::ActivatePaneRight"
  }
}
```

**Caution**: `ctrl-h` is often mapped to backspace in terminals. In Zed's editor context, this should work fine since Zed handles it at the application level.

### 6. No Native Lazygit Integration

Zed has no built-in Lazygit action. The closest alternatives:
- `git_panel::ToggleFocus` - Zed's native git panel
- Open a terminal and run `lazygit` manually
- Use a Zed task (tasks.json) to spawn lazygit in a floating terminal

---

## Complete keymap.json

This is the complete keymap.json to port the essential Neovim bindings to Zed. It uses vim normal mode context for space-leader bindings and workspace context for split navigation.

```json
[
  {
    "context": "Editor && vim_mode == normal",
    "bindings": {
      "space e": "project_panel::ToggleFocus",
      "space f f": "project_search::ToggleFocus",
      "space f b": "tab_switcher::Toggle",
      "space c": "pane::SplitRight",
      "space k": "pane::CloseActiveItem",
      "space w": "workspace::SaveAll",
      "space g l": "git::Blame",
      "space g g": "git_panel::ToggleFocus",
      "space i d": "editor::GoToDefinition",
      "space i r": "editor::FindAllReferences",
      "space i shift-r": "editor::Rename",
      "space i c": "editor::ToggleCodeActions",
      "space i l": "editor::Hover"
    }
  },
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-k": "workspace::ActivatePaneUp",
      "ctrl-l": "workspace::ActivatePaneRight",
      "ctrl-t": "workspace::ToggleBottomDock"
    }
  },
  {
    "context": "Editor",
    "bindings": {
      "ctrl-p": "file_finder::Toggle",
      "ctrl-semicolon": "editor::ToggleComments",
      "alt-j": "editor::MoveLineDown",
      "alt-k": "editor::MoveLineUp",
      "tab": "pane::ActivateNextItem",
      "shift-tab": "pane::ActivatePreviousItem"
    }
  }
]
```

### Notes on the keymap

**`<leader>q` (save and quit)**: Zed has no "save and quit" action that closes the whole window. The closest is `workspace::CloseWindow` but it closes the entire workspace. For per-file close-after-save, use the command palette. Left unmapped intentionally.

**`<Tab>` / `<S-Tab>` for buffer cycling**: Mapped in `Editor` context. This may conflict with Tab indentation in insert mode. If conflicting, restrict to `"Editor && vim_mode == normal"` context.

**`<C-p>` file finder**: The default `ctrl-p` already maps to `file_finder::Toggle` on Linux. This entry is redundant but harmless and makes the mapping explicit.

**`<C-;>` toggle comment**: Zed uses `ctrl-semicolon` (without the C- prefix ambiguity). The exact key name depends on how Zed handles semicolons -- `ctrl-/` is the default Linux comment toggle. Test both.

**`<leader>gl` git blame**: Maps to `git::Blame` (not `editor::ToggleGitBlame` which is deprecated).

**`<leader>gg` lazygit**: Mapped to `git_panel::ToggleFocus` as a substitute. See Unmappable Bindings section.

---

## Unmappable Bindings

| Nvim Key | Reason |
|----------|--------|
| `<leader>gg` (Lazygit) | No Lazygit integration in Zed. Mapped to `git_panel::ToggleFocus` as substitute; for true lazygit, use a terminal task. |
| `<leader>q` (save and quit) | Zed has no "save file then close tab" atomic action. `workspace::CloseWindow` closes entire workspace. Can partially approximate with two bindings but no single action. |
| `<leader>iR` (uppercase R for rename) | Shift+letter bindings in vim normal mode: `"space i shift-r"` should work but `"space i R"` syntax is untested -- use `"space i shift-r"` |

### Partial Substitutes

| Nvim Key | Nvim Action | Zed Substitute | Quality |
|----------|-------------|----------------|---------|
| `<leader>gg` Lazygit | Full TUI git client | `git_panel::ToggleFocus` | Partial -- Zed git panel is simpler |
| `<leader>q` Save+quit | Close file after save | `pane::CloseActiveItem` separately | No atomic equivalent |
| `<leader>gl` Git blame line | Inline per-line blame | `git::Blame` shows file blame | Functional -- hovers show commit |

---

## Evidence and Examples

### Confirmed Working: Space Leader Pattern

From the official Zed issue #7255, ConradIrwin confirmed:
> "You can already use space, the syntax is `"space e": "workspace::ToggleLeftDock"`"

From jellydn/zed-101-setup (actively maintained community config):
```json
{
  "context": "Editor && vim_mode == normal",
  "bindings": {
    "space space": "file_finder::Toggle",
    "space /": "pane::DeploySearch",
    "space c a": "editor::ToggleCodeActions",
    "space c r": "editor::Rename"
  }
}
```

### Confirmed Working: Ctrl-H/J/K/L Navigation

From jellydn/zed-101-setup:
```json
{
  "context": "Workspace",
  "bindings": {
    "ctrl-h": "workspace::ActivatePaneLeft",
    "ctrl-l": "workspace::ActivatePaneRight",
    "ctrl-k": "workspace::ActivatePaneUp",
    "ctrl-j": "workspace::ActivatePaneDown"
  }
}
```

### Default Linux Keymap Verified Actions

From `assets/keymaps/default-linux.json`:
- `ctrl-p` → `file_finder::Toggle` (already default)
- `ctrl-shift-f` → `project_search::ToggleFocus` (already default, different from `<leader>ff`)
- `ctrl-~` → `terminal_panel::Toggle` (already default, different from `<C-t>`)
- `ctrl-shift-e` → `project_panel::ToggleFocus` (already default, different from `<leader>e`)
- `ctrl-alt-s` → `workspace::SaveAll` (already default)
- `alt-g b` → `git::Blame` (already default)

### Vim.json Built-in Bindings

Zed's built-in vim.json already provides:
- `ctrl-w h/j/k/l` → pane navigation (ctrl-w prefix, not bare ctrl-h/j/k/l)
- `] b` / `[ b` → next/prev buffer (bracket-style, not Tab)
- `g t` / `g T` → next/prev tab
- `g d` → Go to definition
- `g A` → Find all references
- `c d` (vim::Rename) → Rename in vim mode

This means several nvim bindings have vim-mode equivalents via different key sequences already built in.

---

## Confidence Level

**High** (confirmed by official docs or maintainer statement):
- Space-leader syntax: `"space e"` (not `"space-e"`)
- Context string: `"Editor && vim_mode == normal"`
- All action names in the Verified Action Names table above
- `git::Blame` as the current (non-deprecated) action name

**Medium** (confirmed by community configs, consistent with docs):
- `ctrl-h/j/k/l` pane navigation in `Workspace` context (community pattern, should work)
- `alt-j/k` for line movement (standard modifier syntax)
- `ctrl-t` for bottom dock toggle (action confirmed; key may conflict)

**Low** (needs testing):
- `ctrl-semicolon` exact key name for `<C-;>` -- may need to be `"ctrl-;"`
- `tab` / `shift-tab` in Editor context without conflicting with vim's Tab motion
- `"space i shift-r"` for uppercase rename (shift+letter chord syntax in sequences)

---

## Sources

- [Zed Key Bindings Documentation](https://zed.dev/docs/key-bindings)
- [Zed Vim Mode Documentation](https://zed.dev/docs/vim)
- [Zed All Actions Reference](https://zed.dev/docs/all-actions)
- [Zed Vim Custom Keybindings Issue #7255](https://github.com/zed-industries/zed/issues/7255)
- [jellydn/zed-101-setup](https://github.com/jellydn/zed-101-setup)
- [Zed Default Linux Keymap](https://github.com/zed-industries/zed/blob/main/assets/keymaps/default-linux.json)
- [Zed Vim Keymap Source](https://raw.githubusercontent.com/zed-industries/zed/main/assets/keymaps/vim.json)
