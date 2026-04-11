# Keyboard Shortcuts Guide

This guide assumes macOS. The Cmd key is used where other platforms use Ctrl.

A practical guide to the most useful keyboard shortcuts in Zed. Shortcuts marked with \* are custom (defined in `keymap.json`); everything else is a Zed default.

## Quick Reference

| Shortcut             | What it does                                   |
| -------------------- | ---------------------------------------------- |
| Cmd+P                | Open a file by name                            |
| Cmd+S                | Save the current file                          |
| Cmd+Z                | Undo                                           |
| Cmd+Shift+Z or Cmd+Y | Redo                                           |
| Cmd+C                | Copy selected text                             |
| Cmd+X                | Cut selected text                              |
| Cmd+V                | Paste                                          |
| Cmd+F                | Find text in current file                      |
| Cmd+Shift+F          | Search across all files in the project         |
| Cmd+W                | Close the current tab                          |
| Cmd+Tab              | Switch to the next tab                         |
| Cmd+`                | Open or close the terminal                     |
| Ctrl+O \*            | Jump back (like vim Ctrl+O)                     |
| Ctrl+I \*            | Jump forward (like vim Ctrl+I)                  |
| Alt+V \*             | Toggle vim mode on/off                          |
| Ctrl+Shift+A \*      | Launch Claude Code CLI (primary AI interface)   |
| Ctrl+? \*            | Toggle the right sidebar (agent panel)          |
| Cmd+B                | Show or hide the left sidebar                  |
| Cmd+Shift+C \*       | Copy full path of the active file to clipboard |
| Alt+J \*             | Move the current line down                     |
| Alt+K \*             | Move the current line up                       |
| Alt+Shift+P \*       | Preview current Slidev file in browser           |
| Alt+Shift+E \*       | Export current Slidev file to PDF                |

## How do I open a file?

**By name (fastest)**: Press **Cmd+P**, start typing the filename, then press Enter when you see it in the list. You do not need to type the full name -- a few letters are usually enough.

**From the file explorer**: Press **Cmd+Shift+E** to open the project panel on the left. Click any file to open it. Press **Cmd+B** to toggle the sidebar if you want more screen space.

**Copy file path**: Press **Cmd+Shift+C** \* to copy the full path of the active file to your clipboard.

**Save**: Press **Cmd+S** to save the current file. **Cmd+Shift+S** saves all open files.

## How do I work with tabs?

- **Cmd+Tab** moves to the next tab
- **Cmd+Shift+Tab** moves to the previous tab
- **Cmd+W** closes the current tab
- **Cmd+Shift+T** reopens the last closed tab

If you have split panes (two files side by side), use these custom shortcuts to move between them:

- **Cmd+H** \* -- Focus the pane to the left
- **Cmd+L** \* -- Focus the pane to the right

To create a split: **Cmd+\\** splits the current view to the right. **Cmd+Shift+\\** splits it downward.

## How do I edit text?

All the standard shortcuts work:

- **Cmd+Z** to undo, **Cmd+Y** to redo
- **Cmd+C** to copy, **Cmd+X** to cut, **Cmd+V** to paste
- **Cmd+A** to select all text in the file
- **Cmd+D** to select the next matching word (useful for editing several identical words at once)
- **Cmd+/** to comment or uncomment a line

### Moving lines

- **Alt+J** \* -- Move the current line down
- **Alt+K** \* -- Move the current line up

These are handy for reordering items in a list or moving a paragraph.

### Deleting lines

- **Cmd+Shift+K** deletes the entire current line

## How do I find something?

**In the current file**: Press **Cmd+F**. Type your search term and press Enter to jump through matches. Press Escape to close the search bar.

**Find and replace** (current file): Use the command palette (**Cmd+Shift+P**) and search for "find and replace". The default Cmd+H is remapped to pane navigation.

**Across all files in the project**: Press **Cmd+Shift+F**. This opens a project-wide search panel. Type your term and results appear from every file.

**Replace across all files**: Press **Cmd+Shift+H**.

## How do I use the AI agent?

Zed has a built-in AI agent panel, inline assist, edit predictions, and integration with Claude Code.

> **Verify shortcuts**: Zed updates frequently. Press **Cmd+K Cmd+S** to open the keybinding editor and confirm any shortcut listed here.

### Claude Code CLI (primary AI interface)

- **Ctrl+Shift+A** \* -- Launch Claude Code in a terminal panel (full CLI with subagents, `--team` mode, skills, and hooks). Works from any context including inside a terminal. See [../agent-system/zed-agent-panel.md](../agent-system/zed-agent-panel.md) for details on the dual-mode setup.

### Agent panel -- Opening and focus

- **Ctrl+?** \* -- Toggle the right sidebar (agent panel lives here; custom override of `agent::ToggleFocus` to `workspace::ToggleRightDock`)

### Agent panel -- Thread management

- **Cmd+N** -- Start a new thread (when agent panel is focused; may be context-dependent -- verify with Cmd+K Cmd+S)
- **Shift+Alt+J** -- Recent threads menu (jump to a past conversation)
- **Cmd+Shift+H** -- View all thread history
- **Cmd+Shift+R** -- Review changes (diff view of agent edits)
- **Double-Enter** -- Send queued message immediately (interrupts current generation)

### Agent panel -- Message editor

- **Enter** -- Send message (default; changes to **Cmd+Enter** if `agent.use_modifier_to_send` is enabled in settings)
- **Shift+Alt+Escape** -- Expand message editor (full-size editor for longer prompts)
- **Cmd+>** -- Add selection to thread (select text in a buffer first)
- **Cmd+Shift+V** -- Paste raw text (without formatting)

### Agent panel -- Thread navigation (thread pane focused)

- **Arrow keys** -- Scroll thread
- **Page Up / Page Down** -- Scroll by page
- **Home / End** -- Jump to top/bottom
- **Shift+Page Up / Shift+Page Down** -- Jump between messages

### Agent panel -- Thread navigation (message editor focused)

- **Cmd+Alt+Home / End** -- Jump to thread top/bottom
- **Cmd+Alt+Page Up / Page Down** -- Jump to previous/next message
- **Cmd+Alt+Shift+Page Up / Page Down** -- Jump to previous/next prompt
- **Cmd+Alt+Up / Down** -- Scroll thread up/down

### Model and profile management

- **Cmd+Alt+/** -- Toggle model selector (switch between language models)
- **Alt+L** -- Cycle favorite models (quick-cycle without opening selector)
- **Cmd+Alt+P** -- Manage profiles
- **Shift+Tab** -- Cycle profiles (when agent panel is focused)

### Inline assist

- **Cmd+Enter** -- Open inline assistant (select text first; works in editors, terminal, and rules library)
- **Cmd+;** -- May also trigger inline assist (older default; verify with Cmd+K Cmd+S as this may have changed)

### Edit predictions (AI code completion)

- **Tab** -- Accept edit prediction (when no completions menu is visible and indentation is unambiguous)
- **Alt+L** -- Accept edit prediction (use when Tab conflicts, e.g. completions menu is open)
- **Alt+]** -- Next edit prediction (cycle through alternatives)
- **Alt+[** -- Previous edit prediction

### External agents (Claude ACP)

The agent panel (Ctrl+? to toggle) connects to Claude Code via the `claude-acp` bridge. It runs in SDK isolation mode, so subagent spawning and `--team` mode are not available. Use it for quick questions and simple edits.

Debug ACP communication via the command palette: search for `dev: open acp logs`.

### Claude Code (terminal task)

**Ctrl+Shift+A** \* launches the full Claude Code CLI as a terminal task. This is the primary path for multi-step work:

- `/research` -- Investigate a topic
- `/plan` -- Create an implementation plan
- `/implement` -- Execute a plan
- `/convert` -- Convert document formats

The keybinding is configured in `keymap.json` using `task::Spawn` with `task_name: "Claude Code"`, and works from both Workspace and Terminal contexts. The terminal opens in the dock panel (position controlled by `terminal.dock` in `settings.json`).

## How do I work with Slidev presentations?

With a Slidev markdown file open:

- **Alt+Shift+P** \* -- Launch the Slidev dev server and open the presentation in your browser. The terminal stays running; press Ctrl+C in it to stop the server.
- **Alt+Shift+E** \* -- Export the presentation to PDF. The PDF is written next to the source file (e.g. `slides-export.pdf`). Requires Playwright (Chromium is downloaded automatically on first use).

## How do I use the terminal?

Press ``Cmd+` `` (backtick, the key below Escape) to toggle the terminal panel at the bottom of the screen. You can run any command here, including `git` commands and Claude Code.

## How do I preview Markdown files?

- **Cmd+K V** opens a side-by-side preview (press Cmd+K, release, then press V)
- **Cmd+Shift+V** opens the preview in a full tab

## How do I use Git?

Zed has built-in Git support:

- **Cmd+Shift+G** opens the Git panel (stage, commit, push)
- **Alt+G B** shows who last edited each line (git blame)

For more control, use the terminal (Cmd+`) and run git commands directly.

## How do I open the command palette?

Press **Cmd+Shift+P** to open the command palette. You can search for any Zed command here -- it is useful when you cannot remember a shortcut.

## How do I go to a specific line?

Press **Cmd+G**, type the line number, and press Enter.

## How do I navigate code?

- **F12** jumps to where something is defined
- **Ctrl+O** \* goes back to where you were before (jump list, like vim)
- **Ctrl+I** \* goes forward again (jump list, like vim)
- **Alt+Left** goes back (Zed default, same effect)
- **Alt+Right** goes forward (Zed default, same effect)

## How do I toggle vim mode?

Press **Alt+V** \* to toggle vim mode on and off. When vim mode is active, Zed enables modal editing (normal, insert, visual modes). Press the same shortcut again to return to standard editing. This is useful if you want vim keybindings temporarily for a specific task without committing to them full-time.

## How do I open settings?

Press **Cmd+,** to open the settings file. Changes take effect when you save.

## Adding more shortcuts

Open `keymap.json` (search for it with Cmd+P). The file contains custom bindings at the top and a commented reference of Zed defaults at the bottom. To add a new shortcut, add a new entry in the custom bindings section following the existing pattern. On macOS, use `cmd` as the modifier key (e.g., `"cmd-shift-n"` for Cmd+Shift+N). See [settings.md](settings.md) for details on the keymap format.
