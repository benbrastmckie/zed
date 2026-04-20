# Teammate C (Critic) Findings: Zed Keybindings on macOS

**Task**: 76 - Troubleshoot Zed keybindings on macOS and update cheat sheet
**Role**: Critic -- identify gaps, blind spots, and risks
**Completed**: 2026-04-19
**Confidence Level**: High (findings verified against Zed source and documentation)

## Executive Summary

Five categories of problems were identified, ranging from a direct settings contradiction (vim_mode enabled while comments say disabled) to a systematically incorrect cheat sheet that shows `Ctrl` where macOS users actually press `Cmd`. Several of the "custom" ctrl bindings duplicate what Zed's vim mode already provides natively, creating redundancy and potential conflict. Migration from ctrl to cmd carries real risks around macOS system shortcut collisions and terminal passthrough behavior.

---

## 1. vim_mode Contradiction (CRITICAL)

### Key Finding

**settings.json line 4 says "No vim mode" but line 5 says `"vim_mode": true`.** This is not a cosmetic issue -- it means the configuration is actively lying to anyone reading the comments.

### Evidence

```jsonc
// settings.json
// No vim mode -- standard keybindings for all users    <-- LINE 4
"vim_mode": true,                                        <-- LINE 5
```

Meanwhile, keymap.json line 224 says:
```
"Toggle vim mode (off by default)"
```

And the cheat sheet (line 224) repeats the claim:
```typst
#shortcut(key-combo("Alt", "V"), [Toggle vim mode (off by default)], custom: true)
```

### Why This Matters

With `vim_mode: true`, Zed loads the entire vim keybinding layer. This adds contexts (`vim_mode == normal`, `vim_mode == visual`, `vim_mode == insert`, `VimControl`) and **overrides several ctrl- bindings**. Specifically:

| Key | Vim Mode Default | Custom Binding | Conflict? |
|-----|-----------------|----------------|-----------|
| `ctrl-o` | `pane::GoBack` (VimControl) | `pane::GoBack` (Workspace/Editor) | Redundant -- same action, but custom binding is unnecessary if vim mode is on |
| `ctrl-i` | `pane::GoForward` (VimControl) | `pane::GoForward` (Workspace/Editor) | Redundant -- same action |
| `ctrl-h` | `editor::Backspace` (insert mode) | `workspace::ActivatePaneLeft` (Workspace/Editor) | **CONFLICT in insert mode** -- ctrl-h will delete character instead of switching pane |
| `ctrl-l` | (no direct conflict in normal) | `workspace::ActivatePaneRight` | Low risk, but vim `ctrl-l` traditionally redraws screen |

**The ctrl-o and ctrl-i custom bindings are entirely redundant when vim_mode is true.** Vim mode already maps these to the exact same actions (`pane::GoBack` and `pane::GoForward`) in the `VimControl && !menu` context. The custom bindings exist because the author believed vim mode was off.

### Recommended Approach

1. Fix the comment to match reality, OR disable vim_mode if it was not intentionally enabled
2. If vim_mode stays on: remove the redundant ctrl-o/ctrl-i custom bindings
3. Document that ctrl-h behaves differently in insert mode vs normal mode

---

## 2. Cheat Sheet Is Systematically Wrong for macOS (CRITICAL)

### Key Finding

The cheat sheet shows `Ctrl` for 25+ Zed default shortcuts that are actually `Cmd` on macOS. This is not a minor labeling issue -- it means a user printing this cheat sheet and pressing what it says will get wrong results for the majority of listed shortcuts.

### Evidence

Zed's macOS defaults (from `default-macos.json`) use `cmd-` for standard editor operations. The cheat sheet shows `Ctrl` for all of these:

| Cheat Sheet Shows | Actual macOS Key | Action |
|-------------------|------------------|--------|
| `Ctrl+P` | `Cmd+P` | Open file by name |
| `Ctrl+S` | `Cmd+S` | Save file |
| `Ctrl+Z` | `Cmd+Z` | Undo |
| `Ctrl+Shift+Z` | `Cmd+Shift+Z` | Redo |
| `Ctrl+C` | `Cmd+C` | Copy |
| `Ctrl+X` | `Cmd+X` | Cut |
| `Ctrl+V` | `Cmd+V` | Paste |
| `Ctrl+Shift+P` | `Cmd+Shift+P` | Command palette |
| `Ctrl+,` | `Cmd+,` | Open settings |
| `Ctrl+A` | `Cmd+A` | Select all |
| `Ctrl+D` | `Cmd+D` | Select next occurrence |
| `Ctrl+/` | `Cmd+/` | Toggle comment |
| `Ctrl+F` | `Cmd+F` | Find in file |
| `Ctrl+Shift+F` | `Cmd+Shift+F` | Search all files |
| `Ctrl+Shift+H` | `Cmd+Shift+H` | Replace across files |
| `Ctrl+B` | `Cmd+B` | Toggle left sidebar |
| `Ctrl+\` | `Cmd+\` | Split pane right |
| `Ctrl+Shift+\` | `Cmd+Shift+\` | Split pane down |
| `Ctrl+N` | `Cmd+N` | New thread (agent panel) |
| `Ctrl+Shift+K` | `Cmd+Shift+K` | Delete line |

**Count: At least 20 shortcuts are mislabeled.** The cheat sheet does use `Ctrl/Cmd` notation for platform-adaptive (`secondary-`) bindings, but fails to apply this logic to Zed defaults which are `Cmd` on macOS.

The footer says "Ctrl = fixed on all platforms" which is only true for the custom bindings, not the Zed defaults listed above.

### Root Cause

The cheat sheet appears to have been written from a Linux/Windows perspective (or from a generic "VSCode keymap" reference) and then not adapted for macOS. The `base_keymap: "VSCode"` setting means Zed follows VSCode conventions, which on macOS use `Cmd` for primary shortcuts.

### Recommended Approach

1. Replace all Zed-default `Ctrl` with `Cmd` in the macOS cheat sheet
2. Keep `Ctrl` only for the custom bindings that explicitly use `ctrl-` in keymap.json
3. Consider generating separate cheat sheets per platform, or use `Cmd/Ctrl` notation with a platform legend
4. The footer legend needs updating: currently misleading about what "Ctrl" means

---

## 3. Context Conflicts and Shadows

### Key Finding: ctrl-h Terminal Backspace

The custom keymap binds `ctrl-h` to `workspace::ActivatePaneLeft` in both Workspace and Editor contexts. However:

- **Zed default**: `ctrl-h` maps to `editor::Backspace` on macOS (this is the traditional Unix terminal backspace)
- **Vim insert mode**: `ctrl-h` also maps to `editor::Backspace`
- **Terminal context**: `ctrl-h` sends ASCII backspace (0x08) to the shell

The custom binding overrides `ctrl-h` in Editor context, which means **Find and Replace (`ctrl-h` in VSCode convention) is no longer accessible via keyboard**. The keymap.json comments on line 64 acknowledge this intentionally, but the cheat sheet does not mention that Find and Replace has been displaced. Users who expect Cmd+Alt+F or Ctrl+H for find/replace will be confused.

### Key Finding: ctrl-shift-a Context Limitation

The task description reports that `ctrl-shift-a` (Claude Code launcher) "only works when the PDF is open, not when the .typ file is open." This is explained by context resolution:

- The binding exists in `Workspace` and `Terminal` contexts
- Zed's default `ctrl-shift-a` maps to `editor::SelectToBeginningOfLine` in Editor context
- **Editor context bindings take precedence over Workspace context bindings** (deeper in context tree wins)
- So when an Editor (including .typ files) is focused, the default `editor::SelectToBeginningOfLine` wins
- When a non-editor view (like PDF preview) is focused, the Workspace binding activates

**This is the root cause of the reported bug.** The fix requires either:
- Adding `ctrl-shift-a` to the Editor context block (overriding SelectToBeginningOfLine)
- Switching to a different key that does not conflict with an Editor-context default

### Key Finding: ctrl-> Agent Thread Conflict

The keymap.json already addresses this (lines 88-105) by nulling out `ctrl->` at the Workspace level and re-declaring it as indent in `Editor && mode == full`. However, the cheat sheet on line 213 still lists `Ctrl+>` as "Add selection to thread" in the agent panel context. If the null binding at Workspace level truly kills this, the cheat sheet entry is wrong -- the action is no longer available via that shortcut.

### Key Finding: Cmd+Shift+H Dual Meaning

The cheat sheet lists `Ctrl+Shift+H` for both:
- Line 181: "Replace across files" (Zed default, actually Cmd+Shift+H on macOS)
- Line 209: "Thread history" in agent panel context

On macOS, `Cmd+Shift+H` serves double duty depending on whether the agent panel is focused. This is not a bug (context-dependent is intentional), but the cheat sheet does not clarify this. A user seeing both entries will be confused about which they get.

---

## 4. Unvalidated Assumptions

### Is `secondary-` Actually Working?

The `secondary-` modifier is documented by Zed as mapping to `Cmd` on macOS and `Ctrl` on Linux/Windows. The keymap.json uses it for:
- `secondary-?` (Toggle right dock)
- `secondary-shift-e` (Toggle left dock / file explorer)
- `secondary-shift-c` (Copy path)
- `secondary-enter` (Open file under cursor)

**Validation concern**: The Zed default-macos.json does NOT use `secondary-` for any bindings. It uses `cmd-` directly. While `secondary-` is documented, it is not used in Zed's own defaults. If this modifier has any edge-case bugs (which is possible for a less-tested code path), these bindings could silently fail.

**Specific risk with `secondary-?`**: On macOS, this maps to `Cmd+?`. The Zed default for `cmd-?` is `agent::ToggleFocus`. The custom binding maps it to `workspace::ToggleRightDock`. These are different actions -- ToggleRightDock toggles the entire right dock, while agent::ToggleFocus specifically toggles the agent panel. If the agent panel is the only right dock item, these may appear identical, but they are semantically different. The comment on line 173 of keymap.json notes this potential conflict with "(verify)".

### macOS Cmd+H: Confirmed System Shortcut

Verified: `Cmd+H` is a macOS system-level shortcut for "Hide Application." It cannot be reliably overridden by applications. Apple treats it as a protected shortcut. This confirms that using `cmd-h` for pane navigation would hide Zed instead of switching panes. The current `ctrl-h` binding is correct for this specific case.

However, this creates an inconsistency: `ctrl-h` / `ctrl-l` for pane navigation means the pair uses `ctrl` (physical Control key), while most other editor shortcuts use `Cmd`. Users must remember which modifier to use for which action.

### Typst Extension Keybindings

The Typst extension (`tinymist`) may register its own keybindings for preview and compilation. The custom `Alt+Shift+E` (Build PDF) and `Alt+Shift+P` (Preview in Browser) dispatch to shell scripts. If the Typst language server or extension registers competing bindings for similar actions, there could be silent conflicts. This was not validated.

---

## 5. Migration Risks: ctrl to cmd/secondary

### Risk Matrix

| Migration | Risk Level | Issue |
|-----------|-----------|-------|
| `ctrl-h` to `cmd-h` | **BLOCKED** | macOS hides the app. Cannot use Cmd+H. |
| `ctrl-l` to `cmd-l` | **High** | Zed default `cmd-l` is `editor::SelectLine`. Would lose select-line functionality. |
| `ctrl-q` to `cmd-q` | **BLOCKED** | macOS/Zed quits the app. Cannot use Cmd+Q. |
| `ctrl-o` to `cmd-o` | **High** | Zed default `cmd-o` is `workspace::Open` (open file dialog). Would lose file-open. |
| `ctrl-i` to `cmd-i` | **Medium** | No obvious Zed default conflict, but some apps use Cmd+I for italic. |
| `ctrl-shift-a` to `cmd-shift-a` | **Medium** | No default Zed binding found. Could work, but verify no extension conflicts. |
| `ctrl->` to `cmd->` | **Low** | Cmd+] already does indent. Redundant. |
| `ctrl-<` to `cmd-<` | **Low** | Cmd+[ already does outdent. Redundant. |

### Cross-Platform Concerns

If the user uses this configuration on both macOS and Linux:
- `secondary-` bindings adapt automatically (good)
- `ctrl-` bindings work the same on both (good, but awkward on macOS)
- `cmd-` bindings only work on macOS (breaks Linux)
- Recommendation: use `secondary-` for anything that should be Cmd on macOS and Ctrl on Linux

### Terminal Passthrough

- `ctrl-` keys pass through to terminal applications (bash, vim, etc.) -- this is standard terminal behavior
- `cmd-` keys are typically intercepted by the GUI application and do NOT pass through to the terminal
- The current `ctrl-shift-a` for Claude Code in Terminal context relies on this passthrough -- switching to `cmd-shift-a` would need testing to confirm Zed still routes it correctly in Terminal context

### Vim Mode Interaction

If vim_mode stays enabled:
- `ctrl-o` and `ctrl-i` are already handled by vim mode (no migration needed)
- Migrating pane navigation to cmd variants would avoid the ctrl-h insert-mode backspace conflict
- But cmd-h and cmd-l are blocked (see risk matrix above)
- Alternative: use `ctrl-w h` / `ctrl-w l` (vim's native pane navigation), but this requires a two-key chord

---

## 6. Additional Issues Not Raised in Scope

### Indent/Outdent Redundancy

The custom bindings add `ctrl->` and `ctrl-<` for indent/outdent. But Zed's macOS defaults already provide `Cmd+]` and `Cmd+[` for the same actions. The custom bindings are redundant with the defaults. Unless the user specifically needs `ctrl->` on Linux (where `Cmd+]` does not exist), these could be removed.

### cheat sheet "Ctrl+G" for Go to Line

The cheat sheet shows `Ctrl+G` for "Go to line." On macOS with VSCode keymap, this is actually `Ctrl+G` (not Cmd+G). This is one of the rare cases where the cheat sheet might be correct, because Zed preserves `Ctrl+G` even on macOS. This should be verified -- it is listed as `(verify)` in the keymap.json reference section but the cheat sheet presents it without qualification.

### Missing Cheat Sheet Entries

The cheat sheet does not document:
- `Alt+V` for vim toggle is listed but the current state (enabled by default) is misrepresented
- `Cmd+W` for close tab (Zed default) -- the user has `Ctrl+Q` as custom, but Cmd+W still works
- No mention that `Ctrl+H` displaces Find and Replace

---

## Consolidated Recommendations

1. **Fix the vim_mode contradiction immediately** -- either update the comment or change the setting. This is causing real confusion and rendering some custom bindings redundant.

2. **Fix ctrl-shift-a by adding it to the Editor context block** -- this is the root cause of the reported "only works with PDF open" bug.

3. **Rewrite the cheat sheet with correct macOS modifiers** -- replace Zed-default `Ctrl` with `Cmd` throughout. This is the single largest accuracy problem.

4. **Do NOT migrate ctrl-h, ctrl-l, ctrl-q, or ctrl-o to cmd variants** -- each has a blocking macOS system shortcut or Zed default conflict.

5. **Consider using `secondary-` for ctrl-shift-a** -- `secondary-shift-a` would give Cmd+Shift+A on macOS (no known conflict) and Ctrl+Shift+A on Linux.

6. **Remove redundant ctrl-o/ctrl-i bindings if vim_mode stays enabled** -- vim mode already provides these exact bindings.

7. **Verify all `(verify)` entries in the keymap.json reference** before updating the cheat sheet -- several defaults are guesses that have not been confirmed.

---

## Sources

- [Zed Key Bindings Documentation](https://zed.dev/docs/key-bindings)
- [Zed Vim Mode Documentation](https://zed.dev/docs/vim)
- [Zed default-macos.json](https://github.com/zed-industries/zed/blob/main/assets/keymaps/default-macos.json)
- [Zed vim.json keybindings](https://github.com/zed-industries/zed/blob/main/assets/keymaps/vim.json)
- [Zed Tasks Documentation](https://zed.dev/docs/tasks)
- [macOS Cmd+H system shortcut discussion](https://discussions.apple.com/thread/6892439)
- [Zed GitHub Issue #39370 - vim mode global keybind conflicts](https://github.com/zed-industries/zed/issues/39370)
- [Zed GitHub Issue #30542 - custom keybinding conflicts with vim mode](https://github.com/zed-industries/zed/issues/30542)
