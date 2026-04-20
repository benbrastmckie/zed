# Research Report: Task #76 -- Teammate A Findings

**Task**: 76 - Troubleshoot Zed keybindings on macOS and update cheat sheet
**Focus**: Per-binding conflict analysis, root cause diagnosis for reported issues
**Completed**: 2026-04-19
**Confidence Level**: High (based on Zed source keymaps, macOS system docs, and vim.json analysis)

## Executive Summary

- The `ctrl+shift+a` failure when editing `.typ` files is caused by **Zed's vim mode** binding `ctrl-shift-a` to `assistant::InlineAssist` in insert mode, which shadows the custom `task::Spawn` binding. It works when the PDF is open because the PDF viewer is not an Editor context and vim mode is inactive there.
- The `cmd+shift+c` (CopyPath) inconsistency is caused by the binding only existing in the `Editor` context -- it does not fire from Workspace, Terminal, or non-editor panel contexts.
- Switching pane navigation from `ctrl-h/l` to `cmd-h/l` is **not safe** -- `cmd+h` is the macOS system "Hide application" shortcut and `cmd+l` is Zed's default `editor::SelectLine`.
- A `secondary-` (Cmd on macOS) approach is viable for some bindings but each must be evaluated individually against both macOS system shortcuts and Zed defaults.

## Key Findings

### 1. Root Cause: `ctrl+shift+a` Only Works with PDF Open

**Diagnosis**: This is a vim mode context conflict.

The Zed vim keymap (`vim.json`) binds `ctrl-shift-a` to `assistant::InlineAssist` in the `vim_mode == insert` context. The user's `settings.json` has `"vim_mode": true`.

**Why it works with PDF open**: When the PDF preview pane is focused, the active context is a Workspace-level viewer, not an Editor with vim mode. The vim binding is inactive, so the Workspace-level `task::Spawn` binding takes effect.

**Why it fails with .typ open**: When editing a `.typ` file, the context is `Editor` with `vim_mode == insert` (or normal). The vim-mode binding for `ctrl-shift-a` -> `assistant::InlineAssist` fires at the Editor level, which takes precedence over the Workspace-level `task::Spawn` binding due to Zed's context tree resolution (lower/more-specific nodes win).

**Additional complication**: In vim normal mode, `ctrl-shift-a` is not bound by vim.json, so the binding may actually work in vim normal mode but fail in insert mode. This explains the intermittent nature -- it depends on which vim mode the user is in.

**Fix options**:
1. **Override in Editor context**: Add `"ctrl-shift-a": ["task::Spawn", { "task_name": "Claude Code" }]` to the Editor context bindings (already exists for Workspace and Terminal, but not Editor).
2. **Add vim-specific override**: Add a binding block with `"context": "vim_mode == insert"` that maps `ctrl-shift-a` to the task spawn.
3. **Change the keybinding entirely**: Use a different chord that has no vim conflicts (e.g., `alt-shift-a` or `ctrl-alt-a`).

**Recommended**: Option 1 (add to Editor context). This is the simplest fix and matches the existing pattern where `ctrl-h`, `ctrl-l`, `ctrl-o`, `ctrl-i`, and `ctrl-q` are already duplicated in the Editor block to shadow Zed defaults.

### 2. Root Cause: `cmd+shift+c` (CopyPath) Inconsistency

**Diagnosis**: The CopyPath binding is only declared in the `Editor` context (line 77 of keymap.json: `"secondary-shift-c": "workspace::CopyPath"`). It is not bound in:
- Workspace context (top-level)
- Terminal context
- ProjectPanel context

This means pressing `Cmd+Shift+C` only works when an Editor pane is focused. If focus is on the terminal, agent panel, project panel, or any other non-editor context, the binding does not fire.

Additionally, Zed's default macOS keymap binds `cmd+shift+c` to `collab_panel::ToggleFocus`, which could intercept the keystroke in some contexts.

**Fix**: Add `"secondary-shift-c": "workspace::CopyPath"` to the Workspace context block so it works regardless of focus. The Workspace context acts as a catch-all since it's the root of the context tree.

### 3. Per-Binding Analysis: ctrl to cmd Migration

#### `ctrl-h` -> `cmd-h` (ActivatePaneLeft)

| Factor | Assessment |
|--------|------------|
| macOS system | **BLOCKED** -- `Cmd+H` = Hide Application (system-level, intercepted before Zed sees it) |
| Zed default | `cmd-h` -> `zed::Hide` in default-macos.json |
| Vim default | `ctrl-h` -> `editor::Backspace` in Picker > Editor context only |
| Recommendation | **Keep `ctrl-h`** -- cannot override macOS system Hide |

Even if Zed remaps `cmd-h` internally, macOS intercepts `Cmd+H` at the system level before the application receives it. This cannot be overridden without modifying macOS System Preferences > Keyboard > Shortcuts, which is fragile and non-portable.

#### `ctrl-l` -> `cmd-l` (ActivatePaneRight)

| Factor | Assessment |
|--------|------------|
| macOS system | No system conflict |
| Zed default | `cmd-l` -> `editor::SelectLine` in Editor context |
| Vim default | No conflict |
| Recommendation | **Possible but costly** -- loses SelectLine |

`Cmd+L` could technically work for pane navigation, but it would sacrifice Zed's `editor::SelectLine` default, which is a commonly used editing shortcut. The user would need to rebind SelectLine to something else (e.g., `cmd+shift+l`).

**Verdict**: Not recommended unless the user explicitly confirms they rarely use SelectLine.

#### `ctrl-o` -> `cmd-o` (GoBack / Jump List)

| Factor | Assessment |
|--------|------------|
| macOS system | No direct conflict |
| Zed default | `cmd-o` -> `workspace::Open` (Open File dialog) |
| Vim default | `ctrl-o` -> `pane::GoBack` in VimControl context (matches user intent) |
| Recommendation | **Keep `ctrl-o`** -- losing Open File dialog is high cost; vim convention is ctrl-o anyway |

The vim keybinding `ctrl-o` for jump-back is already standard vim behavior and is natively supported by Zed's vim.json. Changing to `cmd-o` would conflict with the fundamental "Open File" shortcut.

#### `ctrl-i` -> `cmd-i` (GoForward / Jump List)

| Factor | Assessment |
|--------|------------|
| macOS system | No direct conflict |
| Zed default | `cmd-i` -> `editor::ShowSignatureHelp` in Editor; `agent::ToggleProfileSelector` in AgentPanel |
| Vim default | `ctrl-i` -> `pane::GoForward` in VimControl context (matches user intent) |
| Recommendation | **Keep `ctrl-i`** -- losing ShowSignatureHelp is bad for development; vim convention is ctrl-i |

Similar to ctrl-o, the vim convention for jump-forward is ctrl-i. Changing to cmd-i would sacrifice signature help, which is useful for Python/R development configured in this setup.

#### `ctrl-q` -> `cmd-q` (CloseActiveItem)

| Factor | Assessment |
|--------|------------|
| macOS system | **BLOCKED** -- `Cmd+Q` = Quit Application (system-level) |
| Zed default | `cmd-q` -> `zed::Quit` |
| Vim default | `ctrl-q` -> `vim::ToggleVisualBlock` in VimControl; `vim::PushLiteral` in insert/replace/waiting |
| Recommendation | **Keep `ctrl-q` BUT note vim conflict** |

`Cmd+Q` is a hard block (quits the app). However, `ctrl-q` has its own problem: in vim mode, `ctrl-q` is bound to `vim::ToggleVisualBlock` (equivalent of `ctrl-v` in standard vim, remapped because `ctrl-v` is paste on some platforms). The user's custom binding may shadow this vim functionality.

**Action needed**: The user should decide whether they use vim visual block mode. If so, consider moving close-tab to a different binding or adding an explicit vim-context null-out.

#### `ctrl-shift-a` -> `cmd-shift-a` (Claude Code CLI)

| Factor | Assessment |
|--------|------------|
| macOS system | No system conflict |
| Zed default | `cmd-shift-a` -> `editor::SelectToBeginningOfLine` in Editor |
| Vim default | `ctrl-shift-a` -> `assistant::InlineAssist` in vim insert mode |
| Recommendation | **Consider switching to `secondary-shift-a`** (Cmd on macOS) |

Switching to `cmd-shift-a` (via `secondary-shift-a`) would sacrifice `editor::SelectToBeginningOfLine`, which has a vim-native equivalent (`v0` or `vg^`). Since the user has vim mode enabled, losing this Zed default is low cost. This would also fix the vim insert-mode conflict described in Finding 1.

However, the simpler fix is to keep `ctrl-shift-a` and add the Editor-context override (Finding 1, Option 1). This avoids changing any muscle memory.

#### `ctrl->` / `ctrl-<` (Indent/Outdent)

| Factor | Assessment |
|--------|------------|
| macOS system | No conflict |
| Zed default | `ctrl->` -> `agent::AddSelectionToThread` (already nulled out in user config) |
| Alternative | Zed default `cmd+]` / `cmd+[` already provides indent/outdent |
| Recommendation | **Optional change to `cmd->` / `cmd-<`** or just use built-in `cmd+]`/`cmd+[` |

The user already has elaborate null-out blocks to defeat the agent thread binding. Since Zed natively binds `Cmd+]` and `Cmd+[` to indent/outdent, the `ctrl->` / `ctrl-<` bindings are redundant on macOS and could be removed to simplify the keymap.

### 4. Summary: Recommended Modifier Strategy

| Binding | Current | Recommended | Rationale |
|---------|---------|-------------|-----------|
| Pane left | `ctrl-h` | **Keep `ctrl-h`** | Cmd+H = macOS Hide (hard block) |
| Pane right | `ctrl-l` | **Keep `ctrl-l`** | Cmd+L = SelectLine (high cost to lose) |
| Jump back | `ctrl-o` | **Keep `ctrl-o`** | Cmd+O = Open File; vim convention |
| Jump forward | `ctrl-i` | **Keep `ctrl-i`** | Cmd+I = SignatureHelp; vim convention |
| Close tab | `ctrl-q` | **Keep `ctrl-q`** | Cmd+Q = Quit (hard block); note vim conflict |
| Claude Code | `ctrl-shift-a` | **Keep, add Editor override** | Fix via context, not modifier change |
| Copy path | `secondary-shift-c` | **Add to Workspace context** | Fix inconsistency by broadening context |
| Indent/Outdent | `ctrl->` / `ctrl-<` | **Consider removing** | Redundant with Cmd+]/[ |

### 5. Vim Mode Conflicts Inventory

With `vim_mode: true`, these custom bindings conflict with vim defaults:

| Custom Binding | Vim Default Action | Conflict Severity |
|----------------|-------------------|-------------------|
| `ctrl-shift-a` (Claude Code) | `assistant::InlineAssist` (insert mode) | **High** -- causes the reported bug |
| `ctrl-q` (close tab) | `vim::ToggleVisualBlock` (normal mode) | **Medium** -- affects vim power users |
| `ctrl-o` (jump back) | `pane::GoBack` (VimControl) | **None** -- same action, compatible |
| `ctrl-i` (jump forward) | `pane::GoForward` (VimControl) | **None** -- same action, compatible |
| `ctrl-h` (pane left) | `editor::Backspace` (Picker only) | **Low** -- only in Picker context |
| `ctrl-l` (pane right) | `editor::ScrollCursorCenter` | **Low** -- vim `zz` provides same function |

## Recommended Approach

### Immediate Fixes (address reported bugs)

1. **Add `ctrl-shift-a` to the Editor context block** in keymap.json to override the vim insert-mode `assistant::InlineAssist` binding. This is one line added to the existing Editor bindings block.

2. **Add `secondary-shift-c` (CopyPath) to the Workspace context block** so it fires from any focus state, not just Editor.

### Optional Improvements

3. **Remove `ctrl->` / `ctrl-<` indent/outdent blocks** if the user is comfortable with Zed's built-in `Cmd+]` / `Cmd+[` for the same function. This eliminates 15+ lines of null-out boilerplate.

4. **Add a comment in the ZED DEFAULT REFERENCE section** noting the vim-mode `ctrl-q` conflict with `vim::ToggleVisualBlock` for future reference.

### Do Not Change

5. **Keep all `ctrl-` modifiers as `ctrl-`**. The original rationale (avoiding macOS system and Zed default conflicts) is sound. The analysis confirms that `cmd-h` and `cmd-q` are hard-blocked by macOS, while `cmd-l`, `cmd-o`, and `cmd-i` would sacrifice valuable Zed defaults.

## Evidence / Sources

- Zed default macOS keymap: `zed-industries/zed/assets/keymaps/default-macos.json`
- Zed vim keymap: `zed-industries/zed/assets/keymaps/vim.json` -- confirms `ctrl-shift-a` -> `assistant::InlineAssist` in `vim_mode == insert`
- macOS system shortcuts: [Apple Support - Mac keyboard shortcuts](https://support.apple.com/en-us/102650) -- confirms Cmd+H = Hide, Cmd+Q = Quit
- Zed keybinding docs: [Zed Key Bindings](https://zed.dev/docs/key-bindings) -- context tree resolution rules
- Zed vim mode docs: [Zed Vim Mode](https://zed.dev/docs/vim) -- vim-specific context predicates
- User's keymap.json, settings.json, and .zed/tasks.json -- examined directly

## Appendix

### Debug Technique

To verify the `ctrl+shift+a` conflict in real-time, the user can run `dev: open key context view` from Zed's command palette while editing a `.typ` file. This will show the active contexts including `vim_mode == insert` and confirm which binding is winning.

### Search Queries Used

- "Zed editor default keybindings macOS cmd+h cmd+l cmd+o cmd+i conflicts"
- "Zed editor task::Spawn context binding not working specific file type typst"
- "Zed editor keybinding context resolution priority workspace editor terminal"
- "macOS system keyboard shortcuts cmd+H hide conflicts"
- "Zed editor vim mode ctrl+shift+a keybinding conflict"
- "Zed editor CopyPath keybinding inconsistent not working context"
- Fetched: `zed-industries/zed/assets/keymaps/default-macos.json`
- Fetched: `zed-industries/zed/assets/keymaps/vim.json`
