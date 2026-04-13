# Keyboard Shortcuts Guide

A practical guide to the most useful keyboard shortcuts in Zed. This guide uses platform-neutral notation. Shortcuts marked with \* are custom (defined in `keymap.json`); everything else is a Zed default.

### Modifier Key Reference

Zed defaults use **Cmd** on macOS and **Ctrl** on Linux for most built-in shortcuts (e.g., Cmd+S / Ctrl+S to save). This guide writes these as **Ctrl/Cmd** where they follow Zed's platform convention.

Custom bindings (\*) fall into two categories:

- **Ctrl/Cmd** (platform-adaptive) -- Uses Zed's `secondary-` modifier: Ctrl on Linux, Cmd on macOS. Four bindings use this: `Ctrl/Cmd+?`, `Ctrl/Cmd+Shift+E`, `Ctrl/Cmd+Shift+C`, `Ctrl/Cmd+Enter`.
- **Ctrl** (fixed on all platforms) -- Always Ctrl, even on macOS. These intentionally avoid Cmd to prevent collisions with Zed defaults (e.g., Cmd+Q quits the app). Includes: `Ctrl+H`, `Ctrl+L`, `Ctrl+O`, `Ctrl+I`, `Ctrl+Q`, `Ctrl+Shift+A`, `Ctrl+>`, `Ctrl+<`.

## Quick Reference

| Shortcut             | What it does                                   |
| -------------------- | ---------------------------------------------- |
| Ctrl/Cmd+P           | Open a file by name                            |
| Ctrl/Cmd+S           | Save the current file                          |
| Ctrl/Cmd+Z           | Undo                                           |
| Ctrl/Cmd+Shift+Z     | Redo                                            |
| Ctrl/Cmd+C           | Copy selected text                             |
| Ctrl/Cmd+X           | Cut selected text                              |
| Ctrl/Cmd+V           | Paste                                          |
| Ctrl/Cmd+F           | Find text in current file                      |
| Ctrl/Cmd+Shift+F     | Search across all files in the project         |
| Ctrl/Cmd+W           | Close the current tab                          |
| Ctrl+Tab             | Switch to the next tab                         |
| Ctrl/Cmd+`           | Open or close the terminal                     |
| Ctrl+O \*            | Jump back (like vim Ctrl+O; Ctrl on all platforms) |
| Ctrl+I \*            | Jump forward (like vim Ctrl+I; Ctrl on all platforms) |
| Ctrl/Cmd+Enter \*    | Open file under cursor (overrides inline assist default) |
| Alt+V \*             | Toggle vim mode on/off                         |
| Ctrl+Shift+A \*      | Launch Claude Code CLI (Ctrl on all platforms) |
| Ctrl/Cmd+? \*        | Toggle the right sidebar (agent panel)         |
| Ctrl/Cmd+B           | Show or hide the left sidebar                  |
| Ctrl/Cmd+Shift+C \*  | Copy full path of the active file to clipboard |
| Alt+J \*             | Move the current line down                     |
| Alt+K \*             | Move the current line up                       |
| Alt+Shift+E \*       | Build PDF (Typst compile or Slidev export)     |
| Alt+Shift+P \*       | Preview in browser (Typst PDF or Slidev dev)   |

## How do I open a file?

**By name (fastest)**: Press **Ctrl/Cmd+P**, start typing the filename, then press Enter when you see it in the list. You do not need to type the full name -- a few letters are usually enough.

**From the file explorer**: Press **Ctrl/Cmd+Shift+E** \* to open the project panel on the left. Click any file to open it. Press **Ctrl/Cmd+B** to toggle the sidebar if you want more screen space.

**Copy file path**: Press **Ctrl/Cmd+Shift+C** \* to copy the full path of the active file to your clipboard.

**Save**: Press **Ctrl/Cmd+S** to save the current file. **Ctrl/Cmd+Shift+S** saves all open files.

## How do I work with tabs?

- **Ctrl+Tab** moves to the next tab
- **Ctrl+Shift+Tab** moves to the previous tab
- **Ctrl+Q** \* closes the current tab (Ctrl on all platforms)
- **Ctrl/Cmd+Shift+T** reopens the last closed tab

If you have split panes (two files side by side), use these custom shortcuts to move between them:

- **Ctrl+H** \* -- Focus the pane to the left (Ctrl on all platforms)
- **Ctrl+L** \* -- Focus the pane to the right (Ctrl on all platforms)

To create a split: **Ctrl/Cmd+\\** splits the current view to the right. **Ctrl/Cmd+Shift+\\** splits it downward.

## How do I edit text?

All the standard shortcuts work:

- **Ctrl/Cmd+Z** to undo, **Ctrl/Cmd+Y** to redo
- **Ctrl/Cmd+C** to copy, **Ctrl/Cmd+X** to cut, **Ctrl/Cmd+V** to paste
- **Ctrl/Cmd+A** to select all text in the file
- **Ctrl/Cmd+D** to select the next matching word (useful for editing several identical words at once)
- **Ctrl/Cmd+/** to comment or uncomment a line

### Moving lines

- **Alt+J** \* -- Move the current line down
- **Alt+K** \* -- Move the current line up

These are handy for reordering items in a list or moving a paragraph.

### Deleting lines

- **Ctrl/Cmd+Shift+K** deletes the entire current line

## How do I find something?

**In the current file**: Press **Ctrl/Cmd+F**. Type your search term and press Enter to jump through matches. Press Escape to close the search bar.

**Find and replace** (current file): Use the command palette (**Ctrl/Cmd+Shift+P**) and search for "find and replace". The default Ctrl/Cmd+H is remapped to pane navigation (Ctrl on all platforms).

**Across all files in the project**: Press **Ctrl/Cmd+Shift+F**. This opens a project-wide search panel. Type your term and results appear from every file.

**Replace across all files**: Press **Ctrl/Cmd+Shift+H**.

## How do I use the AI agent?

Zed has a built-in AI agent panel, inline assist, edit predictions, and integration with Claude Code.

> **Verify shortcuts**: Zed updates frequently. Press **Ctrl/Cmd+K Ctrl/Cmd+S** to open the keybinding editor and confirm any shortcut listed here.

### Claude Code CLI (primary AI interface)

- **Ctrl+Shift+A** \* -- Launch Claude Code in a terminal panel (full CLI with subagents, `--team` mode, skills, and hooks). Works from any context including inside a terminal. See [../agent-system/zed-agent-panel.md](../agent-system/zed-agent-panel.md) for details on the dual-mode setup.

### Agent panel -- Opening and focus

- **Ctrl/Cmd+?** \* -- Toggle the right sidebar (agent panel lives here; custom override of `agent::ToggleFocus` to `workspace::ToggleRightDock`)

### Agent panel -- Thread management

- **Ctrl/Cmd+N** -- Start a new thread (when agent panel is focused; may be context-dependent -- verify with Ctrl/Cmd+K Ctrl/Cmd+S)
- **Shift+Alt+J** -- Recent threads menu (jump to a past conversation)
- **Ctrl/Cmd+Shift+H** -- View all thread history
- **Ctrl/Cmd+Shift+R** -- Review changes (diff view of agent edits)
- **Double-Enter** -- Send queued message immediately (interrupts current generation)

### Agent panel -- Message editor

- **Enter** -- Send message (default; changes to **Ctrl/Cmd+Enter** if `agent.use_modifier_to_send` is enabled in settings)
- **Shift+Alt+Escape** -- Expand message editor (full-size editor for longer prompts)
- **Ctrl/Cmd+>** -- Add selection to thread (select text in a buffer first)
- **Ctrl/Cmd+Shift+V** -- Paste raw text (without formatting)

### Agent panel -- Thread navigation (thread pane focused)

- **Arrow keys** -- Scroll thread
- **Page Up / Page Down** -- Scroll by page
- **Home / End** -- Jump to top/bottom
- **Shift+Page Up / Shift+Page Down** -- Jump between messages

### Agent panel -- Thread navigation (message editor focused)

- **Ctrl/Cmd+Alt+Home / End** -- Jump to thread top/bottom
- **Ctrl/Cmd+Alt+Page Up / Page Down** -- Jump to previous/next message
- **Ctrl/Cmd+Alt+Shift+Page Up / Page Down** -- Jump to previous/next prompt
- **Ctrl/Cmd+Alt+Up / Down** -- Scroll thread up/down

### Model and profile management

- **Ctrl/Cmd+Alt+/** -- Toggle model selector (switch between language models)
- **Alt+L** -- Cycle favorite models (quick-cycle without opening selector)
- **Ctrl/Cmd+Alt+P** -- Manage profiles
- **Shift+Tab** -- Cycle profiles (when agent panel is focused)

### Inline assist

- **Ctrl/Cmd+Enter** -- Zed's default for inline assist, but **overridden** in Editor context by the custom "Open file under cursor" binding (`secondary-enter` in `keymap.json`). Use **Ctrl/Cmd+;** or the command palette (search "inline assist") instead.
- **Ctrl/Cmd+;** -- Open inline assistant (select text first; works in editors, terminal, and rules library)

### Edit predictions (AI code completion)

- **Tab** -- Accept edit prediction (when no completions menu is visible and indentation is unambiguous)
- **Alt+L** -- Accept edit prediction (use when Tab conflicts, e.g. completions menu is open)
- **Alt+]** -- Next edit prediction (cycle through alternatives)
- **Alt+[** -- Previous edit prediction

### External agents (Claude ACP)

The agent panel (Ctrl/Cmd+? to toggle) connects to Claude Code via the `claude-acp` bridge. It runs in SDK isolation mode, so subagent spawning and `--team` mode are not available. Use it for quick questions and simple edits.

Debug ACP communication via the command palette: search for `dev: open acp logs`.

### Claude Code (terminal task)

**Ctrl+Shift+A** \* (Ctrl on all platforms) launches the full Claude Code CLI as a terminal task. This is the primary path for multi-step work:

- `/research` -- Investigate a topic
- `/plan` -- Create an implementation plan
- `/implement` -- Execute a plan
- `/convert` -- Convert document formats

The keybinding is configured in `keymap.json` using `task::Spawn` with `task_name: "Claude Code"`, and works from both Workspace and Terminal contexts. The terminal opens in the dock panel (position controlled by `terminal.dock` in `settings.json`).

## How do I build or preview Typst / Slidev files?

Two keybindings work for both Typst (`.typ`) and Slidev (`.md`) files -- they detect the file extension and dispatch automatically:

- **Alt+Shift+E** \* -- **Build PDF**. For `.typ` files, runs `typst compile`. For Slidev `.md` files, exports to PDF via Playwright (Chromium is downloaded automatically on first use).
- **Alt+Shift+P** \* -- **Preview in browser**. For `.typ` files, opens the compiled PDF with `xdg-open` (compiles first if needed). For Slidev `.md` files, launches the dev server and opens the presentation in your browser; press Ctrl+C in the terminal to stop.

## How do I use the terminal?

Press ``Ctrl/Cmd+` `` (backtick, the key below Escape) to toggle the terminal panel at the bottom of the screen. You can run any command here, including `git` commands and Claude Code.

## How do I preview Markdown files?

- **Ctrl/Cmd+K V** opens a side-by-side preview (press Ctrl/Cmd+K, release, then press V)
- **Ctrl/Cmd+Shift+V** opens the preview in a full tab

## How do I use Git?

Zed has built-in Git support:

- **Ctrl/Cmd+Shift+G** opens the Git panel (stage, commit, push)
- **Alt+G B** shows who last edited each line (git blame)

For more control, use the terminal (Ctrl/Cmd+`) and run git commands directly.

## How do I open the command palette?

Press **Ctrl/Cmd+Shift+P** to open the command palette. You can search for any Zed command here -- it is useful when you cannot remember a shortcut.

## How do I go to a specific line?

Press **Ctrl/Cmd+G**, type the line number, and press Enter.

## How do I navigate code?

- **F12** jumps to where something is defined
- **Ctrl+O** \* goes back to where you were before (jump list, like vim)
- **Ctrl+I** \* goes forward again (jump list, like vim)
- **Alt+Left** goes back (Zed default, same effect)
- **Alt+Right** goes forward (Zed default, same effect)

## How do I toggle vim mode?

Press **Alt+V** \* to toggle vim mode on and off. When vim mode is active, Zed enables modal editing (normal, insert, visual modes). Press the same shortcut again to return to standard editing. This is useful if you want vim keybindings temporarily for a specific task without committing to them full-time.

## How do I open settings?

Press **Ctrl/Cmd+,** to open the settings file. Changes take effect when you save.

## Adding more shortcuts

Open `keymap.json` (search for it with Ctrl/Cmd+P). The file contains custom bindings at the top and a commented reference of Zed defaults at the bottom. To add a new shortcut, add a new entry in the custom bindings section following the existing pattern. For new cross-platform bindings, prefer the `secondary-` modifier (e.g., `"secondary-shift-n"` maps to Cmd+Shift+N on macOS and Ctrl+Shift+N on Linux). Use explicit `ctrl-` only when you need to avoid collisions with Zed's Cmd-based macOS defaults. See [settings.md](settings.md) for details on the keymap format.
