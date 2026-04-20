# Research Report: Task #76 -- macOS Keybinding Specification (Round 2)

**Task**: 76 - Troubleshoot Zed keybindings on macOS and update cheat sheet
**Started**: 2026-04-19T14:00:00Z
**Completed**: 2026-04-19T14:45:00Z
**Effort**: medium
**Dependencies**: Round 1 team research (01_team-research.md)
**Sources/Inputs**:
- Round 1 team research and all 4 teammate findings
- `/Users/nmehtani/.config/zed/keymap.json` (current bindings)
- `/Users/nmehtani/.config/zed/settings.json` (editor settings)
- `/Users/nmehtani/.config/zed/docs/general/keybindings-cheat-sheet.typ` (Typst cheat sheet)
- `/Users/nmehtani/.config/zed/docs/general/keybindings.md` (markdown guide)
**Artifacts**:
- `specs/076_troubleshoot_zed_keybindings_macos/reports/02_macos-keybinding-spec.md` (this report)
**Standards**: report-format.md, artifact-formats.md

## Executive Summary

- vim_mode is now OFF (`"vim_mode": false` in settings.json, comment already correct). The `ctrl-o` and `ctrl-i` custom bindings are NEEDED since vim mode no longer provides them natively.
- The `ctrl-shift-a` bug (only works with PDF open) is resolved by vim_mode being off, but the Editor-context override should still be added as a safety measure against future vim-mode toggling via Alt+V.
- The `secondary-shift-c` (CopyPath) fix still needed: add to Workspace context for universal access.
- The cheat sheet requires a complete macOS rewrite: replace all Zed-default "Ctrl" with "Cmd", replace all "Alt" with "Opt", drop the dagger/platform-adaptive notation since we are macOS-only.
- `ctrl->` / `ctrl-<` indent/outdent bindings should be REMOVED (redundant with Cmd+]/[, and they require elaborate null-out boilerplate).

---

## Context & Scope

Round 1 identified three root causes and a systematic cheat sheet accuracy problem. The user has since clarified:

1. **vim_mode is OFF** -- The user turned off vim mode. Custom bindings like `ctrl-o`, `ctrl-i`, `ctrl-h`, `ctrl-l` are essential because vim mode no longer provides them.
2. **macOS-only cheat sheet** -- No need for cross-platform notation. Use `Cmd` for Zed defaults, `Ctrl` only where keymap.json explicitly uses `ctrl-`, and `Opt` instead of `Alt` for the Option key.
3. **Minimize vim conflicts** -- While vim_mode is off, avoid gratuitous conflicts so users could toggle vim mode on temporarily via Alt+V.
4. **Build on Round 1** -- Produce concrete, actionable specifications for implementation.

---

## A. Keymap.json Changes Specification

### A1. Add `ctrl-shift-a` to Editor Context (SAFETY FIX)

**Why**: With vim_mode off, the original bug (vim insert-mode `assistant::InlineAssist` shadowing `task::Spawn`) is resolved. However, Zed's own default Editor binding `ctrl-shift-a` -> `editor::SelectToBeginningOfLine` still exists and could shadow the Workspace-level binding. Adding it to the Editor context ensures it always works, even if the user temporarily enables vim mode via Alt+V.

**Change**: Add one line to the existing Editor context block (lines 67-86 of keymap.json).

```jsonc
// In the Editor context block, add:
"ctrl-shift-a": ["task::Spawn", { "task_name": "Claude Code" }],
```

**Full Editor block after change**:
```jsonc
{
  "context": "Editor",
  "bindings": {
    "alt-j": "editor::MoveLineDown",
    "alt-k": "editor::MoveLineUp",
    "ctrl-q": "pane::CloseActiveItem",
    "ctrl-h": "workspace::ActivatePaneLeft",
    "ctrl-l": "workspace::ActivatePaneRight",
    "ctrl-o": "pane::GoBack",
    "ctrl-i": "pane::GoForward",
    "ctrl-shift-a": ["task::Spawn", { "task_name": "Claude Code" }],
    "secondary-shift-c": "workspace::CopyPath",
    "secondary-shift-e": "workspace::ToggleLeftDock",
    "alt-shift-e": ["task::Spawn", { "task_name": "Build PDF" }],
    "alt-shift-p": ["task::Spawn", { "task_name": "Preview in Browser" }],
    "secondary-enter": "editor::OpenFile",
    "alt-r": "editor::ReloadFile"
  }
}
```

Note: `ctrl->` and `ctrl-<` are removed from this block (see A4 below).

### A2. Add `secondary-shift-c` to Workspace Context (BUG FIX)

**Why**: CopyPath only works when an Editor pane is focused. Adding it to Workspace makes it work from any context (terminal, project panel, agent panel).

**Change**: Add one line to the first Workspace context block (lines 37-49 of keymap.json).

```jsonc
// In the Workspace context block, add:
"secondary-shift-c": "workspace::CopyPath",
```

**Full first Workspace block after change**:
```jsonc
{
  "context": "Workspace",
  "bindings": {
    "ctrl-h": "workspace::ActivatePaneLeft",
    "ctrl-l": "workspace::ActivatePaneRight",
    "secondary-?": "workspace::ToggleRightDock",
    "secondary-shift-e": "workspace::ToggleLeftDock",
    "secondary-shift-c": "workspace::CopyPath",
    "ctrl-shift-a": ["task::Spawn", { "task_name": "Claude Code" }],
    "ctrl-q": "pane::CloseActiveItem",
    "ctrl-o": "pane::GoBack",
    "ctrl-i": "pane::GoForward",
    "alt-v": "workspace::ToggleVimMode"
  }
}
```

### A3. Keep `ctrl-o` / `ctrl-i` Custom Bindings (CONFIRMED NEEDED)

**Why**: With vim_mode off, Zed does NOT provide `ctrl-o` -> `pane::GoBack` or `ctrl-i` -> `pane::GoForward` natively. These were only provided by the vim keybinding layer. The custom bindings are essential for jump-list navigation.

**Decision**: Keep all four declarations (Workspace + Editor for each). No changes needed.

### A4. Remove `ctrl->` / `ctrl-<` Indent/Outdent (SIMPLIFICATION)

**Why**: Zed natively provides `Cmd+]` (indent) and `Cmd+[` (outdent) on macOS. The custom `ctrl->` / `ctrl-<` bindings are redundant and require 15+ lines of null-out boilerplate to defeat Zed's default `ctrl->` -> `agent::AddSelectionToThread`. Removing them simplifies the keymap significantly.

**Changes -- remove these three blocks entirely**:

1. Remove from Editor context block (lines 83-84):
   ```jsonc
   // DELETE these two lines:
   "ctrl->": "editor::Indent",
   "ctrl-<": "editor::Outdent"
   ```

2. Remove the Workspace null-out block (lines 92-98):
   ```jsonc
   // DELETE this entire block:
   {
     "context": "Workspace",
     "bindings": {
       "ctrl->": null,
       "ctrl-<": null
     }
   },
   ```

3. Remove the `Editor && mode == full` block (lines 99-105):
   ```jsonc
   // DELETE this entire block:
   {
     "context": "Editor && mode == full",
     "bindings": {
       "ctrl->": "editor::Indent",
       "ctrl-<": "editor::Outdent"
     }
   },
   ```

**Impact**: Users use `Cmd+]` / `Cmd+[` for indent/outdent instead. This is the standard macOS convention.

### A5. Review of `secondary-` Bindings (ALL CORRECT)

| Binding | Context | Action | Status |
|---------|---------|--------|--------|
| `secondary-?` | Workspace | `workspace::ToggleRightDock` | OK -- maps to Cmd+? on macOS |
| `secondary-shift-e` | Workspace + Editor | `workspace::ToggleLeftDock` | OK -- maps to Cmd+Shift+E |
| `secondary-shift-c` | Editor (adding Workspace) | `workspace::CopyPath` | FIX -- add to Workspace (A2) |
| `secondary-enter` | Editor | `editor::OpenFile` | OK -- maps to Cmd+Enter |

All `secondary-` bindings correctly resolve to Cmd on macOS. No changes needed beyond A2.

### A6. Update Header Comment Block

The header comment (lines 1-32) needs updating to reflect:
- Binding count changes (removal of `ctrl->` / `ctrl-<` reduces from 17 to 15 unique custom bindings)
- Remove the two indent/outdent entries from the `ctrl-` category listing
- Update the total entry count

### A7. Update ZED DEFAULT REFERENCE Section

Several entries need corrections:
- Remove `ctrl->` / `ctrl-<` references from the custom entries
- Add `Cmd+]` / `Cmd+[` to the Editing section (Zed defaults, no custom override)
- Fix entries marked `(verify)` where confirmed:
  - `Ctrl+G` for Go to Line is correct (Zed keeps Ctrl+G on macOS, not Cmd+G)
  - `Ctrl+Tab` / `Ctrl+Shift+Tab` are correct (Zed keeps Ctrl+Tab on macOS)
  - `Ctrl+\`` for terminal is correct (Zed keeps Ctrl+\` on macOS)

---

## B. Cheat Sheet Rewrite Specification

### B0. Guiding Principles for macOS-Only Cheat Sheet

1. **Cmd** for all Zed defaults (these use `cmd-` on macOS)
2. **Ctrl** only for custom bindings that explicitly use `ctrl-` in keymap.json
3. **Opt** (not "Alt") for all Option-key bindings (macOS convention)
4. **Star marker** for custom bindings from keymap.json
5. **No dagger marker** -- the platform-adaptive notation is unnecessary for a macOS-only sheet
6. **No "Ctrl/Cmd" hybrid notation** -- everything is resolved to the macOS key

### B1. Footer Rewrite

**Current footer** (line 17-21):
```typst
[#sym.star.filled#h(4pt)Custom binding (keymap.json)],
[#sym.arrow.r#h(4pt)Sequential press (chord)],
[#sym.dagger#h(4pt)Platform-adaptive (Ctrl#sym.space.thin/#sym.space.thin Cmd)],
align(right)[Ctrl = fixed on all platforms #h(1em) _April 2026_],
```

**New footer** (remove dagger, clarify Ctrl meaning):
```typst
grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 1.5em,
  align: horizon,
  [#sym.star.filled#h(4pt)Custom binding (keymap.json)],
  [#sym.arrow.r#h(4pt)Sequential press (chord)],
  align(right)[Ctrl bindings use the Control key (not Cmd) #h(1em) _April 2026_],
)
```

### B2. Complete Entry-by-Entry Mapping

#### Essentials Section

| # | Current | Corrected macOS | Custom? | Notes |
|---|---------|-----------------|---------|-------|
| 1 | `key-combo("Ctrl", "P")` Open file by name | `key-combo("Cmd", "P")` | No | Zed default |
| 2 | `key-combo("Ctrl", "S")` Save file | `key-combo("Cmd", "S")` | No | Zed default |
| 3 | `key-combo("Ctrl", "Z")` Undo | `key-combo("Cmd", "Z")` | No | Zed default |
| 4 | `key-combo("Ctrl", "Shift", "Z")` Redo | `key-combo("Cmd", "Shift", "Z")` | No | Zed default |
| 5 | `key-combo("Ctrl", "C")` Copy | `key-combo("Cmd", "C")` | No | Zed default |
| 6 | `key-combo("Ctrl", "X")` Cut | `key-combo("Cmd", "X")` | No | Zed default |
| 7 | `key-combo("Ctrl", "V")` Paste | `key-combo("Cmd", "V")` | No | Zed default |
| 8 | `key-combo("Ctrl", "Q")` Close tab | `key-combo("Ctrl", "Q")` | YES | custom ctrl- binding |
| 9 | `key-combo("Ctrl", "Shift", "P")` Command palette | `key-combo("Cmd", "Shift", "P")` | No | Zed default |
| 10 | `key-combo("Ctrl", ",")` Open settings | `key-combo("Cmd", ",")` | No | Zed default |

#### Navigation Section

| # | Current | Corrected macOS | Custom? | Notes |
|---|---------|-----------------|---------|-------|
| 11 | `key-combo("Ctrl", "G")` Go to line | `key-combo("Ctrl", "G")` | No | Zed keeps Ctrl+G on macOS |
| 12 | `key-combo("F12")` Go to definition | `key-combo("F12")` | No | No change |
| 13 | `key-combo("Ctrl", "O")` Jump back | `key-combo("Ctrl", "O")` | YES | custom ctrl- binding |
| 14 | `key-combo("Ctrl", "I")` Jump forward | `key-combo("Ctrl", "I")` | YES | custom ctrl- binding |
| 15 | `key-combo("Alt", "Left")` Go back | `key-combo("Opt", "Left")` | No | Alt->Opt rename |
| 16 | `key-combo("Alt", "Right")` Go forward | `key-combo("Opt", "Right")` | No | Alt->Opt rename |
| 17 | `key-combo("Ctrl", "Tab")` Next tab | `key-combo("Ctrl", "Tab")` | No | Zed keeps Ctrl+Tab on macOS |
| 18 | `key-combo("Ctrl", "Shift", "Tab")` Previous tab | `key-combo("Ctrl", "Shift", "Tab")` | No | Zed keeps Ctrl+Shift+Tab on macOS |
| 19 | `key-combo("Ctrl", "Shift", "T")` Reopen closed tab | `key-combo("Cmd", "Shift", "T")` | No | Zed default |
| 20 | `key-combo("Ctrl", "H")` Focus pane left | `key-combo("Ctrl", "H")` | YES | custom ctrl- binding |
| 21 | `key-combo("Ctrl", "L")` Focus pane right | `key-combo("Ctrl", "L")` | YES | custom ctrl- binding |
| 22 | `key-combo("Ctrl/Cmd", "Enter")` Open file under cursor | `key-combo("Cmd", "Enter")` | YES | secondary- resolves to Cmd on macOS |

#### File Explorer Section

| # | Current | Corrected macOS | Custom? | Notes |
|---|---------|-----------------|---------|-------|
| 23-26 | h/j/k/l entries | No change | YES | Bare keys, no modifier. Context label correct. |

#### Editing Section

| # | Current | Corrected macOS | Custom? | Notes |
|---|---------|-----------------|---------|-------|
| 27 | `key-combo("Ctrl", "A")` Select all | `key-combo("Cmd", "A")` | No | Zed default |
| 28 | `key-combo("Ctrl", "D")` Select next occurrence | `key-combo("Cmd", "D")` | No | Zed default |
| 29 | `key-combo("Ctrl", "/")` Toggle comment | `key-combo("Cmd", "/")` | No | Zed default |
| 30 | `key-combo("Ctrl", "Shift", "K")` Delete line | `key-combo("Cmd", "Shift", "K")` | No | Zed default |
| 31 | `key-combo("Alt", "K")` Move line up | `key-combo("Opt", "K")` | YES | Alt->Opt |
| 32 | `key-combo("Alt", "J")` Move line down | `key-combo("Opt", "J")` | YES | Alt->Opt |
| 33 | `key-combo("Ctrl", ">")` Indent | **REMOVE** | -- | Redundant with Cmd+] |
| 34 | `key-combo("Ctrl", "<")` Outdent | **REMOVE** | -- | Redundant with Cmd+[ |
| 35 | `key-combo("Alt", "R")` Reload file from disk | `key-combo("Opt", "R")` | YES | Alt->Opt |

**Add new entries for indent/outdent**:
- `key-combo("Cmd", "]")` Indent line (Zed default, not custom)
- `key-combo("Cmd", "[")` Outdent line (Zed default, not custom)

#### Search & Replace Section

| # | Current | Corrected macOS | Custom? | Notes |
|---|---------|-----------------|---------|-------|
| 36 | `key-combo("Ctrl", "F")` Find in file | `key-combo("Cmd", "F")` | No | Zed default |
| 37 | `key-combo("Ctrl", "Shift", "F")` Search all files | `key-combo("Cmd", "Shift", "F")` | No | Zed default |
| 38 | `key-combo("Ctrl", "Shift", "H")` Replace across files | `key-combo("Cmd", "Shift", "H")` | No | Zed default |

#### Panels & Layout Section

| # | Current | Corrected macOS | Custom? | Notes |
|---|---------|-----------------|---------|-------|
| 39 | `key-combo("Ctrl", "B")` Toggle left sidebar | `key-combo("Cmd", "B")` | No | Zed default |
| 40 | `key-combo("Ctrl/Cmd", "Shift", "E")` File explorer | `key-combo("Cmd", "Shift", "E")` | YES | secondary- -> Cmd. Remove dagger. |
| 41 | `key-combo("Ctrl/Cmd", "?")` Toggle right dock | `key-combo("Cmd", "?")` | YES | secondary- -> Cmd. Remove dagger. |
| 42 | `key-combo("Ctrl", "\`")` Toggle terminal | `key-combo("Ctrl", "\`")` | No | Zed keeps Ctrl+` on macOS |
| 43 | `key-combo("Ctrl", "\\")` Split pane right | `key-combo("Cmd", "\\")` | No | Zed default |
| 44 | `key-combo("Ctrl", "Shift", "\\")` Split pane down | `key-combo("Cmd", "Shift", "\\")` | No | Zed default |
| 45 | `key-combo("Ctrl", "H")` Focus pane left | **REMOVE** (duplicate of #20) | -- | Already listed in Navigation |
| 46 | `key-combo("Ctrl", "L")` Focus pane right | **REMOVE** (duplicate of #21) | -- | Already listed in Navigation |
| 47 | `key-combo("Ctrl/Cmd", "Shift", "C")` Copy file path | `key-combo("Cmd", "Shift", "C")` | YES | secondary- -> Cmd. Remove dagger. |

#### Preview Section

| # | Current | Corrected macOS | Custom? | Notes |
|---|---------|-----------------|---------|-------|
| 48 | `chord(("Ctrl", "K"), ("V",))` Markdown side-by-side | `chord(("Cmd", "K"), ("V",))` | No | Zed default |
| 49 | `key-combo("Ctrl", "Shift", "V")` Markdown full tab | `key-combo("Cmd", "Shift", "V")` | No | Zed default |
| 50 | `key-combo("Alt", "Shift", "E")` Build PDF | `key-combo("Opt", "Shift", "E")` | YES | Alt->Opt |
| 51 | `key-combo("Alt", "Shift", "P")` Preview in browser | `key-combo("Opt", "Shift", "P")` | YES | Alt->Opt |

#### AI & Agent Panel Section

| # | Current | Corrected macOS | Custom? | Notes |
|---|---------|-----------------|---------|-------|
| 52 | `key-combo("Ctrl", "Shift", "A")` Launch Claude Code CLI | `key-combo("Ctrl", "Shift", "A")` | YES | custom ctrl- binding, stays Ctrl |
| 53 | `key-combo("Ctrl", "N")` New thread | `key-combo("Cmd", "N")` | No | Zed default, ctx: agent panel |
| 54 | `key-combo("Shift", "Alt", "J")` Recent threads | `key-combo("Shift", "Opt", "J")` | No | Alt->Opt |
| 55 | `key-combo("Ctrl", "Shift", "H")` Thread history | `key-combo("Cmd", "Shift", "H")` | No | Zed default, ctx: agent panel |
| 56 | `key-combo("Ctrl", "Shift", "R")` Review agent changes | `key-combo("Cmd", "Shift", "R")` | No | Zed default |
| 57 | `key-combo("Enter")` Send message | No change | No | ctx: agent panel |
| 58 | `key-combo("Shift", "Alt", "Escape")` Expand message editor | `key-combo("Shift", "Opt", "Escape")` | No | Alt->Opt |
| 59 | `key-combo("Ctrl", ">")` Add selection to thread | `key-combo("Cmd", ">")` | No | Zed default (note: custom null-out removed) |
| 60 | `key-combo("Ctrl", "Alt", "/")` Toggle model selector | `key-combo("Ctrl", "Opt", "/")` | No | Alt->Opt. Note: this is actually Ctrl+Opt, not Cmd+Opt -- verify. |
| 61 | `key-combo("Alt", "L")` Cycle favorite models | `key-combo("Opt", "L")` | No | Alt->Opt, ctx: agent panel |
| 62 | `key-combo("Ctrl", "Alt", "P")` Manage profiles | `key-combo("Ctrl", "Opt", "P")` | No | Alt->Opt. Note: verify if Ctrl or Cmd. |
| 63 | `key-combo("Shift", "Tab")` Cycle profiles | No change | No | ctx: agent panel |
| 64 | `key-combo("Ctrl/Cmd", ";")` Inline assist | `key-combo("Cmd", ";")` | No | Zed default, remove dagger |

**Entry 59 note**: With the removal of the `ctrl->` null-out blocks (A4), Zed's default `Cmd+>` -> `agent::AddSelectionToThread` is restored in Agent Panel context. The cheat sheet should now correctly show `Cmd+>` for this action.

#### Optional / Advanced Section

| # | Current | Corrected macOS | Custom? | Notes |
|---|---------|-----------------|---------|-------|
| 65 | `key-combo("Alt", "V")` Toggle vim mode (off by default) | `key-combo("Opt", "V")` Toggle vim mode (off by default) | YES | Alt->Opt |

### B3. Typst Code Changes Summary

The `shortcut()` helper has a `custom: true` parameter that renders the star. No changes needed to the helper functions. The key changes are:

1. **Global search-and-replace for Zed defaults**: `"Ctrl"` -> `"Cmd"` for all non-custom entries
2. **Global search-and-replace**: `"Alt"` -> `"Opt"` for all entries
3. **Keep `"Ctrl"` only for**: Ctrl+Q, Ctrl+O, Ctrl+I, Ctrl+H, Ctrl+L, Ctrl+Shift+A, Ctrl+G, Ctrl+Tab, Ctrl+Shift+Tab, Ctrl+`
4. **Remove all `"Ctrl/Cmd"` notation**: replace with just `"Cmd"`
5. **Remove dagger references**: delete the `sym.dagger` footer entry, remove `#sym.dagger` from any entry descriptions
6. **Remove duplicate entries**: Ctrl+H and Ctrl+L appear in both Navigation and Panels sections -- keep only in Navigation
7. **Remove indent/outdent entries**: `Ctrl+>` and `Ctrl+<` -- replace with `Cmd+]` and `Cmd+[`
8. **Update footer**: see B1 above

### B4. Entries That Retain "Ctrl" (Not "Cmd")

These bindings genuinely use the Control key on macOS:

| Entry | Key | Reason |
|-------|-----|--------|
| Close tab | Ctrl+Q | Custom `ctrl-q` (Cmd+Q = quit app) |
| Jump back | Ctrl+O | Custom `ctrl-o` (Cmd+O = open file) |
| Jump forward | Ctrl+I | Custom `ctrl-i` (Cmd+I = signature help) |
| Focus pane left | Ctrl+H | Custom `ctrl-h` (Cmd+H = hide app) |
| Focus pane right | Ctrl+L | Custom `ctrl-l` (Cmd+L = select line) |
| Claude Code CLI | Ctrl+Shift+A | Custom `ctrl-shift-a` (avoids conflicts) |
| Go to line | Ctrl+G | Zed default (Zed keeps Ctrl+G on macOS) |
| Next tab | Ctrl+Tab | Zed default (platform-agnostic) |
| Previous tab | Ctrl+Shift+Tab | Zed default (platform-agnostic) |
| Toggle terminal | Ctrl+` | Zed default (platform-agnostic) |

---

## C. Settings.json Changes

### C1. vim_mode -- No Change Needed

Current state is already correct:
```jsonc
// No vim mode -- standard keybindings for all users
"vim_mode": false,
```

The comment matches the value. No fix needed. (Round 1 identified a contradiction where `vim_mode` was `true` but the comment said "No vim mode" -- this has already been resolved.)

### C2. No Other Settings Changes Required

The settings.json is clean and consistent. No changes needed.

---

## D. Keybindings.md Changes Summary

The markdown guide (`docs/general/keybindings.md`) needs these updates to match the new macOS-only cheat sheet:

### D1. Header Section (lines 1-12)

**Current**: Uses "platform-neutral notation" and explains `Ctrl/Cmd` dual notation extensively.

**Change**: Rewrite to state this is a macOS guide. Replace the modifier key reference:
- Remove the dual `Ctrl/Cmd` explanation
- State: "This guide uses macOS notation. Cmd is the Command key. Ctrl is the Control key (used for specific custom bindings). Opt is the Option key."
- Simplify the custom binding explanation: "Shortcuts marked with \* are custom (defined in `keymap.json`). Custom bindings using Ctrl intentionally avoid Cmd to prevent collisions with macOS system shortcuts."

### D2. Quick Reference Table (lines 16-41)

Replace all `Ctrl/Cmd` with `Cmd` and all `Alt` with `Opt`:
- `Ctrl/Cmd+P` -> `Cmd+P`
- `Ctrl/Cmd+S` -> `Cmd+S`
- `Ctrl/Cmd+Z` -> `Cmd+Z`
- `Ctrl/Cmd+Shift+Z` -> `Cmd+Shift+Z`
- etc.
- `Alt+V` -> `Opt+V`
- `Alt+J` -> `Opt+J`
- `Alt+K` -> `Opt+K`
- `Alt+Shift+E` -> `Opt+Shift+E`
- `Alt+Shift+P` -> `Opt+Shift+P`

Keep `Ctrl` for: Ctrl+O, Ctrl+I, Ctrl+Shift+A, Ctrl+Tab

### D3. Body Sections

Throughout the document, apply the same substitutions:
- All `Ctrl/Cmd+X` -> `Cmd+X`
- All `Alt+X` -> `Opt+X`
- Keep `Ctrl` only for the custom ctrl- bindings and the three Zed defaults that use Ctrl on macOS (Ctrl+G, Ctrl+Tab, Ctrl+`)

### D4. Remove Cross-Platform References

- Line 65: `Ctrl/Cmd+\\` -> `Cmd+\\`
- Line 92: Remove the note about `Ctrl/Cmd+H` being remapped -- instead note that "Find and Replace is accessible via the command palette (Cmd+Shift+P, search 'find and replace') since Ctrl+H is used for pane navigation."
- Line 182: Remove `xdg-open` reference (Linux-only) -- use `open` (macOS command)

### D5. Remove Indent/Outdent References

If `ctrl->` / `ctrl-<` are removed from keymap.json, remove any references in keybindings.md. Add `Cmd+]` / `Cmd+[` to the editing section as the standard indent/outdent shortcuts.

### D6. "Adding more shortcuts" Section (line 226-228)

Update to reflect macOS-only context:
- Remove `secondary-` modifier explanation for cross-platform
- Instead explain: "For new custom bindings, use `secondary-` modifier (which maps to Cmd on macOS). Use explicit `ctrl-` only to avoid collisions with Cmd-based shortcuts."

---

## Decisions

1. **Keep `ctrl-o` and `ctrl-i`** -- Essential with vim mode off. These are the only way to navigate the jump list.
2. **Remove `ctrl->` / `ctrl-<`** -- Redundant with `Cmd+]` / `Cmd+[`. Eliminates 15+ lines of null-out boilerplate in keymap.json.
3. **Add `ctrl-shift-a` to Editor context** -- Safety measure for vim-mode toggling, even though the primary bug is resolved.
4. **Add `secondary-shift-c` to Workspace context** -- Fixes CopyPath only working from Editor.
5. **Use "Opt" not "Alt" in documentation** -- macOS convention. The physical key is labeled with the Option symbol.
6. **Drop dagger/platform-adaptive notation** -- macOS-only sheet does not need it. Everything resolves to a specific key.
7. **Drop duplicate pane navigation entries** -- Ctrl+H/L appear in both Navigation and Panels sections; keep only in Navigation.

---

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Removing `ctrl->` / `ctrl-<` breaks muscle memory | Low | User has `Cmd+]` / `Cmd+[` as alternatives (standard macOS) |
| Vim mode toggle (Opt+V) re-introduces conflicts | Medium | Editor-context `ctrl-shift-a` override provides safety; document known vim conflicts |
| Agent panel `Cmd+>` restored after null-out removal | Low | This is correct behavior -- Zed default for agent context |
| Some "Zed defaults" in cheat sheet may be wrong | Medium | Entries from keymap.json `(verify)` section should be tested with `dev: Open Key Context View` |
| `Cmd+Shift+H` dual meaning (replace files / thread history) | Low | Document context dependency in cheat sheet with `ctx:` annotation |

---

## Appendix

### Binding Count After Changes

| Category | Before | After | Change |
|----------|--------|-------|--------|
| Custom bindings (unique) | 17 | 15 | -2 (removed indent/outdent) |
| Custom entries (across contexts) | 26 | 26 | +2 (added ctrl-shift-a to Editor, secondary-shift-c to Workspace), -2 (removed indent/outdent from Editor) |
| Workspace blocks | 2 | 1 | Merge: remove the null-out Workspace block |
| `Editor && mode == full` block | 1 | 0 | Removed (was only for indent/outdent) |

### Bindings That Remain Ctrl on macOS (Complete List)

Custom (6):
- `ctrl-h` -- ActivatePaneLeft
- `ctrl-l` -- ActivatePaneRight
- `ctrl-o` -- GoBack
- `ctrl-i` -- GoForward
- `ctrl-q` -- CloseActiveItem
- `ctrl-shift-a` -- Claude Code CLI

Zed defaults that keep Ctrl on macOS (3):
- `ctrl-g` -- Go to Line
- `ctrl-tab` / `ctrl-shift-tab` -- Tab switching
- `` ctrl-` `` -- Toggle terminal

### All "Alt" -> "Opt" Replacements in Cheat Sheet

- `Alt+Left` -> `Opt+Left`
- `Alt+Right` -> `Opt+Right`
- `Alt+K` -> `Opt+K`
- `Alt+J` -> `Opt+J`
- `Alt+R` -> `Opt+R`
- `Alt+V` -> `Opt+V`
- `Alt+Shift+E` -> `Opt+Shift+E`
- `Alt+Shift+P` -> `Opt+Shift+P`
- `Shift+Alt+J` -> `Shift+Opt+J`
- `Shift+Alt+Escape` -> `Shift+Opt+Escape`
- `Alt+L` -> `Opt+L`
- `Ctrl+Alt+/` -> `Ctrl+Opt+/`
- `Ctrl+Alt+P` -> `Ctrl+Opt+P`

### Search Queries Used

- None (Round 2 relied on Round 1 research findings and direct file analysis)

### References

- Round 1: `specs/076_troubleshoot_zed_keybindings_macos/reports/01_team-research.md`
- Teammate findings: `01_teammate-{a,b,c,d}-findings.md`
- Zed keybinding architecture: documented in Teammate B findings
- macOS system shortcuts: documented in Teammate B findings
