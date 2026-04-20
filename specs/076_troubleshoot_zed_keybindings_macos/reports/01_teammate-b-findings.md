# Research Report: Teammate B Findings -- macOS System Defaults and Zed Keybinding Architecture

**Task**: 76 - Troubleshoot Zed keybindings on macOS and update cheat sheet
**Role**: Teammate B (Alternative Approaches)
**Started**: 2026-04-19T12:00:00Z
**Completed**: 2026-04-19T12:30:00Z
**Effort**: medium
**Dependencies**: None
**Sources/Inputs**: Apple Support docs, Zed docs, Zed GitHub (default-macos.json, PR #26390), DefKey reserved shortcuts, codebase keymap.json
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- macOS Cmd+H (Hide) and Cmd+Q (Quit) are system-reserved shortcuts that cannot be disabled through System Settings alone; apps can override Cmd+H via their menu structure, but macOS intercepts it first
- Zed's `secondary-` modifier (added March 2025, PR #26390) maps to Cmd on macOS and Ctrl on Linux/Windows, providing the correct abstraction for cross-platform bindings
- The current keymap.json correctly uses `ctrl-` (not `cmd-` or `secondary-`) for bindings that would collide with macOS system shortcuts (H, L, O, I, Q)
- Several Cmd+Shift combinations (E, C, K, H) are only Finder-specific on macOS and can be safely overridden by Zed -- the current config already does this for some
- Context hierarchy is the key to understanding why a keybinding works in one panel but not another

## 1. macOS System-Level Keybindings: Complete Analysis

### Truly Global / System-Reserved (Cannot Be Overridden by Apps)

These shortcuts are intercepted by macOS before reaching any application:

| Shortcut | Action | Can Disable? | Notes |
|----------|--------|-------------|-------|
| Cmd+Tab | Switch apps | No | WindowServer level |
| Cmd+Space | Spotlight | Yes* | System Settings > Keyboard > Shortcuts > Spotlight |
| Cmd+H | Hide front app | Workaround only | See detailed analysis below |
| Cmd+Q | Quit front app | Workaround only | See detailed analysis below |
| Cmd+M | Minimize window | Workaround only | Menu-bar driven |
| Cmd+` | Cycle app windows | No | WindowServer level |
| Shift+Cmd+Q | Log out | Yes | System Settings > Keyboard > Shortcuts |
| Shift+Cmd+3/4/5 | Screenshots | Yes | System Settings > Keyboard > Shortcuts > Screenshots |
| Ctrl+F2/F3 | Focus menu/Dock | Yes | System Settings > Keyboard > Shortcuts > Keyboard |

*Cmd+Space can be reassigned to a different shortcut in System Settings > Keyboard > Keyboard Shortcuts > Spotlight.

### App-Overridable (Finder-Specific or Standard Menu Items)

These are standard macOS conventions but NOT enforced globally. Applications can and do override them:

| Shortcut | macOS Default | Finder-Specific? | Safe to Override in Zed? |
|----------|---------------|-------------------|--------------------------|
| Cmd+L | No system default | N/A | YES -- safe |
| Cmd+O | Open file/folder | No (app convention) | Zed already uses this (workspace::Open) |
| Cmd+I | Get Info (Finder) | Yes | YES -- safe in non-Finder apps |
| Cmd+A | Select All | No (app convention) | Risky -- users expect Select All |
| Cmd+N | New window/document | No (app convention) | Risky -- users expect New File |
| Cmd+Shift+A | Show Apps/Launchpad (macOS Tahoe 26+) | System-level on Tahoe | CAUTION -- new in macOS 26 |
| Cmd+Shift+C | Computer window (Finder) | Yes | YES -- safe |
| Cmd+Shift+E | Eject disk (Finder) | Yes | YES -- safe |
| Cmd+Shift+K | Network window (Finder) | Yes | YES -- safe |
| Cmd+Shift+H | Home folder (Finder) | Yes | YES -- safe |
| Cmd+> | No system default | N/A | YES -- safe |
| Cmd+< | No system default | N/A | YES -- safe |

### Detailed Analysis: Cmd+H (Hide)

Cmd+H is one of the most problematic shortcuts on macOS:

1. **How it works**: macOS creates a "Hide [AppName]" menu item in every app's application menu. Cmd+H is the system-assigned shortcut for this menu item.
2. **Can apps override it?** Technically yes -- an app can assign Cmd+H to a different action in its own menus, and macOS will route to the app's menu item instead. However, if no menu item claims Cmd+H, macOS defaults to hiding the app.
3. **Can it be disabled in System Settings?** No. There is no toggle in System Settings > Keyboard > Keyboard Shortcuts for Cmd+H.
4. **Workarounds**:
   - **Per-app menu remap**: System Settings > Keyboard > Keyboard Shortcuts > App Shortcuts > add Zed > Menu Title "Hide Zed" > assign to an obscure key combo (e.g., Ctrl+Opt+Cmd+H)
   - **BetterTouchTool**: Can intercept Cmd+H globally or per-app and reassign it
   - **Karabiner-Elements**: Can remap at the input event level
5. **Zed's behavior**: Zed's default-macos.json binds `cmd-h` to `zed::Hide`, which is the standard macOS hide behavior. This means if you rebind `cmd-h` in your keymap.json to a different Zed action, Zed will execute YOUR action instead of hiding. The current config uses `ctrl-h` to avoid the conflict entirely.

### macOS Tahoe (26) Warning: Cmd+Shift+A

On macOS Tahoe (released 2025), Apple introduced Cmd+Shift+A as a system shortcut to show/hide the new "Apps" view (replacing Launchpad). This is a NEW system-level shortcut. The current keymap.json does NOT use Cmd+Shift+A (it uses Ctrl+Shift+A for Claude Code), so there is no conflict. However, if a future keybinding change moves to `secondary-shift-a` (which maps to Cmd+Shift+A on macOS), it would collide with this system shortcut on Tahoe.

## 2. Zed Default Keybindings on macOS

Based on the official `default-macos.json` from the Zed repository:

| Key Combo | Zed Default Action | Context | Notes |
|-----------|-------------------|---------|-------|
| Cmd+H | `zed::Hide` | Global | Passes through to macOS hide behavior |
| Cmd+L | `editor::SelectLine` | Editor | Also: `editor::ScrollCursorCenter` (Editor), `pane::SplitRight` (FileFinder) |
| Cmd+O | `workspace::Open` | Global | Opens folder/file dialog |
| Cmd+I | `editor::ShowSignatureHelp` | Editor | Also: `agent::ToggleProfileSelector` (AgentPanel) |
| Cmd+Q | `zed::Quit` | Global | Standard quit |
| Cmd+Shift+A | `file_finder::ToggleSplitMenu` | FileFinder | Context-specific, not global |
| Cmd+Shift+C | `collab_panel::ToggleFocus` | Global | Also: `keymap_editor::CopyContext` |
| Cmd+Shift+E | `project_panel::ToggleFocus` | Workspace | Also: `pane::RevealInProjectPanel` (Editor mode==full) |
| Cmd+Shift+K | (not bound by default) | -- | Available for custom use |
| Cmd+Shift+H | `agent::OpenHistory` (AgentPanel), `search::ToggleReplace` (Pane/Workspace) | Context-dependent | Multiple bindings across contexts |
| Cmd+> | `agent::AddSelectionToThread` | Editor, Terminal, AcpThread | Added for agent workflow |
| Cmd+< | (not bound by default) | -- | Available for custom use |

### Key Insight: Multi-Action Bindings

Zed frequently binds the same key combo to different actions in different contexts. For example, Cmd+L does three different things depending on whether you're in the Editor, or in the FileFinder. This is by design -- the context system ensures only the relevant action fires.

## 3. Context-Specific Behavior: How Zed's Context System Works

### The Context Tree

Zed's UI forms a tree structure. Each node in the tree pushes context identifiers:

```
Workspace (root)
  os=macos
  keyboard_layout=com.apple.keylayout.QWERTY
  ├── Dock
  │   ├── Terminal
  │   └── ProjectPanel
  │       └── not_editing (attribute)
  ├── Pane
  │   ├── Editor
  │   │   ├── mode=full (main editor)
  │   │   ├── mode=single_line (search input)
  │   │   ├── extension=typ
  │   │   └── vim_mode=normal|insert|visual
  │   ├── FileFinder
  │   ├── ProjectSearchView
  │   └── KeymapEditor
  └── AgentPanel
      └── AcpThread
```

### How Context Affects Which Binding Fires

1. **Focus determines active context**: When you click in an Editor, the focus path is `Workspace > Pane > Editor`. When you click the ProjectPanel, it's `Workspace > Dock > ProjectPanel`.

2. **Lower nodes win**: A binding with context `"Editor"` takes precedence over the same key bound in `"Workspace"`. This is why the current keymap.json re-declares `ctrl-h` and `ctrl-l` in both Workspace AND Editor contexts -- without the Editor-context override, Zed's default Editor-context Ctrl+H (find/replace) would shadow the Workspace-level pane navigation.

3. **Later definitions win at the same level**: User keymap.json loads AFTER Zed's defaults, so user bindings automatically override defaults at the same context level.

4. **Context expressions enable precision**:
   - `"Editor && mode == full"` -- only main code editors, not search inputs
   - `"ProjectPanel && not_editing"` -- project panel but not when renaming a file
   - `"Editor && extension == typ"` -- only Typst files

### Why a Binding Might Work in One Context But Not Another

Example scenario from the task description: `ctrl+shift+a` works in a PDF viewer context but not in a Typst editor context.

Possible explanations:
- The binding is defined in a context that matches the PDF viewer but not the Typst editor
- A different binding in the Editor context (which matches the Typst editor) shadows it
- The Typst editor pushes additional context attributes (like `extension=typ`) that change matching
- The PDF viewer may be in a Pane with no Editor context, so Workspace-level bindings are unshadowed

**Debugging tool**: Use `dev: open key context view` from the command palette to see exactly what contexts are active at the current cursor position.

## 4. The `secondary-` Modifier in Zed

### What It Is

The `secondary-` modifier was added to Zed in March 2025 (PR #26390 by mikayla-maki). It provides a platform-adaptive modifier:

| Platform | `secondary-` maps to |
|----------|---------------------|
| macOS | `cmd` (Command key) |
| Linux | `ctrl` (Control key) |
| Windows | `ctrl` (Control key) |

### When to Use It

Use `secondary-` when you want **platform-idiomatic behavior** -- the binding should use Cmd on macOS and Ctrl on Linux/Windows. This is appropriate for:
- Actions that mirror standard OS conventions (copy, paste, save, etc.)
- New custom bindings where you want "the primary modifier" on each platform
- Cross-platform configs shared between macOS and Linux machines

### When NOT to Use It

Do NOT use `secondary-` when:
- The binding would collide with a macOS system shortcut (Cmd+H, Cmd+Q, Cmd+M)
- You explicitly want Ctrl on macOS (e.g., vim-style navigation like Ctrl+O/Ctrl+I)
- You want the binding to be the SAME physical key on all platforms

### Current Usage in keymap.json

The existing config uses `secondary-` for exactly 4 bindings:
1. `secondary-?` -- Toggle right dock (Cmd+? on macOS, Ctrl+? on Linux)
2. `secondary-shift-e` -- Toggle left dock / file explorer
3. `secondary-shift-c` -- Copy file path
4. `secondary-enter` -- Open file under cursor

All other custom bindings use explicit `ctrl-` to avoid macOS Cmd collisions.

### Does It Work in All Contexts?

Yes. The `secondary-` modifier is resolved at the GPUI keystroke parsing level, before context matching occurs. It works identically to writing `cmd-` on macOS -- the only difference is that it becomes `ctrl-` on other platforms. Context rules, precedence, and shadowing all work the same way.

## 5. Alternative Keybinding Strategies

### Strategy A: Keep Current Approach (Recommended)

**Philosophy**: Use `ctrl-` for bindings that would collide with macOS system shortcuts; use `secondary-` for bindings that should feel native on each platform.

**Pros**:
- Zero collisions with macOS system shortcuts
- Muscle memory works: Ctrl+H/L for panes, Ctrl+O/I for jump list
- `secondary-` bindings (?, Shift+E, Shift+C, Enter) feel native on macOS

**Cons**:
- Ctrl as a modifier on macOS feels slightly foreign (it is not the "primary" modifier)
- Two different modifier philosophies in the same keymap can be confusing

### Strategy B: Migrate to `cmd-` with System Settings Workarounds

**Philosophy**: Use Cmd for everything on macOS and disable conflicting system shortcuts.

**Steps to disable Cmd+H for Zed**:
1. Open System Settings > Keyboard > Keyboard Shortcuts > App Shortcuts
2. Click "+", select "Zed" (or "All Applications")
3. Menu Title: "Hide Zed" (exact text from the menu bar)
4. Shortcut: assign to something unused like Ctrl+Opt+Cmd+H
5. Now Cmd+H is free for Zed to use as pane navigation

**For Cmd+Q**:
1. Same approach: remap "Quit Zed" to Ctrl+Opt+Cmd+Q in App Shortcuts
2. Or use Zed's built-in `cmd-q` -> `zed::Quit` binding (which works, but you lose the ability to quit)

**Pros**:
- All bindings use Cmd, feels native on macOS
- Consistent modifier across all custom bindings

**Cons**:
- Requires per-machine System Settings changes (not portable)
- Other apps still use Cmd+H to hide -- muscle memory breaks
- If Zed updates change menu text, the workaround breaks
- Cmd+Q remapping is dangerous (easy to quit unexpectedly)

### Strategy C: Use `secondary-` for Everything Safe, `ctrl-` for Conflicts

**Philosophy**: Maximize `secondary-` usage, falling back to `ctrl-` only where absolutely necessary.

**Safe to convert from `ctrl-` to `secondary-`**:
- `ctrl-l` -> `secondary-l` (Cmd+L on macOS = `editor::SelectLine` in Zed default -- CONFLICT with Zed's own default! NOT safe)
- `ctrl-o` -> `secondary-o` (Cmd+O on macOS = `workspace::Open` in Zed default -- CONFLICT! NOT safe)
- `ctrl-i` -> `secondary-i` (Cmd+I on macOS = `editor::ShowSignatureHelp` in Zed default -- CONFLICT! NOT safe)
- `ctrl-q` -> `secondary-q` (Cmd+Q on macOS = `zed::Quit` -- CONFLICT! NOT safe)
- `ctrl->` -> `secondary->` (Cmd+> on macOS = `agent::AddSelectionToThread` in Zed default -- CONFLICT!)
- `ctrl-<` -> `secondary-<` (No Zed default -- safe, but inconsistent with `ctrl->`)

**Result**: NONE of the current `ctrl-` bindings can safely become `secondary-` because they ALL collide with either macOS system shortcuts or Zed's own defaults on macOS.

**Verdict**: The current approach (Strategy A) is already optimal.

### Strategy D: Alt-Based Modifiers for Custom Actions

**Philosophy**: Reserve Alt (Option) for all custom/non-standard bindings.

The current config already uses Alt for:
- Alt+V (vim toggle)
- Alt+J/K (line movement)
- Alt+R (reload file)
- Alt+Shift+E (build PDF)
- Alt+Shift+P (preview)

Alt is the safest modifier on macOS because:
- macOS uses very few Alt (Option) shortcuts by default
- Zed uses few Alt shortcuts by default
- No collision with system-level shortcuts

**Potential Alt-based alternatives for ctrl- bindings**:
| Current | Alt Alternative | Mnemonic |
|---------|----------------|----------|
| Ctrl+H | Alt+H | H for left pane |
| Ctrl+L | Alt+L | L for right pane (CONFLICT: Alt+L is "accept edit prediction" in Zed default) |
| Ctrl+O | Alt+O | O for go back |
| Ctrl+I | (keep Ctrl+I) | Alt+I not available? |

This strategy introduces new conflicts with Zed's Alt defaults and loses vim-style mnemonics.

## macOS Shortcuts Safe to Remap in System Settings

These macOS System Settings shortcuts can be safely reassigned or disabled without breaking core macOS functionality:

| Shortcut | Default Function | How to Disable |
|----------|-----------------|----------------|
| Cmd+Space | Spotlight | System Settings > Keyboard > Shortcuts > Spotlight |
| Shift+Cmd+3/4/5 | Screenshots | System Settings > Keyboard > Shortcuts > Screenshots |
| Ctrl+Up/Down | Mission Control / App Expose | System Settings > Keyboard > Shortcuts > Mission Control |
| Ctrl+Left/Right | Switch Desktop | System Settings > Keyboard > Shortcuts > Mission Control |
| F11 | Show Desktop | System Settings > Keyboard > Shortcuts > Mission Control |
| Cmd+Shift+A | Show Apps (Tahoe) | System Settings > Keyboard > Shortcuts > Launchpad & Dock |

## Decisions

1. The current keymap.json strategy of using `ctrl-` for conflict-prone bindings is correct and should be preserved
2. The `secondary-` modifier should only be used for bindings where Cmd behavior is desired on macOS and does not conflict with system or Zed defaults
3. Cmd+H cannot be safely reclaimed for pane navigation without per-machine System Settings workarounds

## Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| macOS Tahoe Cmd+Shift+A system shortcut | Low | Current config uses Ctrl+Shift+A, no conflict. Document for future reference. |
| Zed updates changing default keybindings | Medium | Pin to explicit `ctrl-`/`cmd-` rather than relying on Zed defaults. Monitor Zed changelogs. |
| Ctrl modifier feeling non-native on macOS | Low | This is a deliberate trade-off. Document the reasoning in the cheat sheet. |
| `secondary-` behavior changing in future Zed versions | Low | It is a stable API (PR #26390 merged March 2025). Monitor for breaking changes. |

## Confidence Level

**High (0.85)** for the macOS system shortcut analysis -- Apple's documentation is clear and the behavior is well-tested across the community.

**High (0.90)** for the Zed context system analysis -- sourced directly from Zed's official documentation and default keymap source.

**Medium-High (0.80)** for the `secondary-` modifier analysis -- sourced from the PR that introduced it, but the feature is relatively new and documentation was added in a follow-up PR.

**High (0.85)** for the strategy recommendation -- the current approach is demonstrably correct based on the collision analysis.

## Appendix

### Search Queries Used
1. "macOS system keyboard shortcuts Cmd+H hide Cmd+Q quit global cannot override"
2. "Zed editor default keybindings macOS Cmd+H Cmd+L Cmd+O Cmd+I"
3. "Zed editor context system keybindings Workspace Editor Terminal ProjectPanel"
4. "macOS disable Cmd+H hide application System Settings keyboard shortcuts"
5. "macOS which Cmd shortcuts are truly global system-level cannot be intercepted"
6. "zed-industries zed source code secondary modifier keystroke mapping"

### References
- [Mac keyboard shortcuts - Apple Support](https://support.apple.com/en-us/102650)
- [Zed Key Bindings Documentation](https://zed.dev/docs/key-bindings)
- [Zed default-macos.json](https://github.com/zed-industries/zed/blob/main/assets/keymaps/default-macos.json)
- [PR #26390: Add secondary meta key to GPUI](https://github.com/zed-industries/zed/pull/26390)
- [Reserved macOS Shortcuts - DefKey](https://defkey.com/reserved-apple-macos-shortcuts)
- [Actions and Keybindings - DeepWiki](https://deepwiki.com/zed-industries/zed/3.3-actions-and-keybindings)
- [Disable Cmd+H - Apple Community](https://discussions.apple.com/thread/6892439)
- [macOS Tahoe Launchpad replacement](https://www.macworld.com/article/2830963/macos-tahoe-apps-replaces-launchpad.html)
