# Keyboard Shortcuts Guide (macOS)

A practical guide to the most useful keyboard shortcuts in Zed on macOS. Shortcuts marked with \* are custom (defined in `keymap.json`); everything else is a Zed default.

### Modifier Key Reference

- **Cmd** -- The Command key. Used by most Zed defaults (Cmd+S to save, Cmd+P to open files, etc.).
- **Ctrl** -- The Control key. Used for specific custom bindings that intentionally avoid Cmd to prevent collisions with macOS system shortcuts (e.g., Cmd+Q quits the app). Includes: `Ctrl+Q`, `Ctrl+J`, `Ctrl+K`, `Ctrl+Shift+A`.
- **Opt** -- The Option key. Used for custom and Zed default bindings that need a third modifier.

## Quick Reference

| Shortcut             | What it does                                   |
| -------------------- | ---------------------------------------------- |
| Cmd+P                | Open a file by name                            |
| Cmd+S                | Save the current file                          |
| Cmd+Z                | Undo                                           |
| Cmd+Shift+Z          | Redo                                           |
| Cmd+C                | Copy selected text                             |
| Cmd+X                | Cut selected text                              |
| Cmd+V                | Paste                                          |
| Cmd+F                | Find text in current file                      |
| Cmd+Shift+F          | Search across all files in the project         |
| Cmd+W                | Close the current tab                          |
| Ctrl+Tab             | Switch to the next tab                         |
| Ctrl+`               | Open or close the terminal                     |
| Cmd+O \*             | Jump back (vim-style jump list)                |
| Cmd+I \*             | Jump forward (vim-style jump list)             |
| Cmd+Enter \*         | Open file under cursor (overrides inline assist default) |
| Opt+V \*             | Toggle vim mode on/off                         |
| Ctrl+Shift+A \*      | Launch Claude Code CLI                         |
| Cmd+? \*             | Toggle the right sidebar (agent panel)         |
| Cmd+B                | Show or hide the left sidebar                  |
| Cmd+Shift+C \*       | Copy full path of the active file to clipboard |
| Ctrl+J \*            | Move the current line down                     |
| Ctrl+K \*            | Move the current line up                       |
| Opt+Shift+E \*       | Build PDF (Typst compile or Slidev export)     |
| Opt+Shift+P \*       | Preview in browser (Typst PDF or Slidev dev)   |

## How do I open a file?

**By name (fastest)**: Press **Cmd+P**, start typing the filename, then press Enter when you see it in the list. You do not need to type the full name -- a few letters are usually enough.

**From the file explorer**: Press **Cmd+Shift+E** \* to open the project panel on the left. Click any file to open it. Press **Cmd+B** to toggle the sidebar if you want more screen space.

**Copy file path**: Press **Cmd+Shift+C** \* to copy the full path of the active file to your clipboard.

**Save**: Press **Cmd+S** to save the current file. **Cmd+Shift+S** saves all open files.

## How do I work with tabs?

- **Ctrl+Tab** moves to the next tab
- **Ctrl+Shift+Tab** moves to the previous tab
- **Ctrl+Q** \* closes the current tab
- **Cmd+Shift+T** reopens the last closed tab

If you have split panes (two files side by side), use these custom shortcuts to move between them:

- **Cmd+H** \* -- Focus the pane to the left (overrides macOS Hide)
- **Cmd+L** \* -- Focus the pane to the right

To create a split: **Cmd+\\** splits the current view to the right. **Cmd+Shift+\\** splits it downward.

## How do I edit text?

All the standard shortcuts work:

- **Cmd+Z** to undo, **Cmd+Shift+Z** to redo
- **Cmd+C** to copy, **Cmd+X** to cut, **Cmd+V** to paste
- **Cmd+A** to select all text in the file
- **Cmd+D** to select the next matching word (useful for editing several identical words at once)
- **Cmd+/** to comment or uncomment a line
- **Cmd+]** to indent, **Cmd+[** to outdent

### Moving lines

- **Ctrl+J** \* -- Move the current line down
- **Ctrl+K** \* -- Move the current line up

These are handy for reordering items in a list or moving a paragraph.

### Deleting lines

- **Cmd+Shift+K** deletes the entire current line

## How do I find something?

**In the current file**: Press **Cmd+F**. Type your search term and press Enter to jump through matches. Press Escape to close the search bar.

**Find and replace** (current file): Use the command palette (**Cmd+Shift+P**) and search for "find and replace", or use **Cmd+Opt+F**.

**Across all files in the project**: Press **Cmd+Shift+F**. This opens a project-wide search panel. Type your term and results appear from every file.

**Replace across all files**: Press **Cmd+Shift+H**.

## How do I use the AI agent?

Zed has a built-in AI agent panel, inline assist, edit predictions, and integration with Claude Code.

> **Verify shortcuts**: Zed updates frequently. Press **Cmd+K Cmd+S** to open the keybinding editor and confirm any shortcut listed here.

### Claude Code CLI (primary AI interface)

- **Ctrl+Shift+A** \* -- Launch Claude Code in a terminal panel (full CLI with subagents, `--team` mode, skills, and hooks). Works from Workspace, Editor, and Terminal contexts. See [../agent-system/zed-agent-panel.md](../agent-system/zed-agent-panel.md) for details on the dual-mode setup.

### Agent panel -- Opening and focus

- **Cmd+?** \* -- Toggle the right sidebar (agent panel lives here; custom override of `agent::ToggleFocus` to `workspace::ToggleRightDock`)

### Agent panel -- Thread management

- **Cmd+N** -- Start a new thread (when agent panel is focused; may be context-dependent -- verify with Cmd+K Cmd+S)
- **Shift+Opt+J** -- Recent threads menu (jump to a past conversation)
- **Cmd+Shift+H** -- View all thread history
- **Cmd+Shift+R** -- Review changes (diff view of agent edits)
- **Double-Enter** -- Send queued message immediately (interrupts current generation)

### Agent panel -- Message editor

- **Enter** -- Send message (default; changes to **Cmd+Enter** if `agent.use_modifier_to_send` is enabled in settings)
- **Shift+Opt+Escape** -- Expand message editor (full-size editor for longer prompts)
- **Cmd+>** -- Add selection to thread (select text in a buffer first)
- **Cmd+Shift+V** -- Paste raw text (without formatting)

### Agent panel -- Thread navigation (thread pane focused)

- **Arrow keys** -- Scroll thread
- **Page Up / Page Down** -- Scroll by page
- **Home / End** -- Jump to top/bottom
- **Shift+Page Up / Shift+Page Down** -- Jump between messages

### Agent panel -- Thread navigation (message editor focused)

- **Cmd+Opt+Home / End** -- Jump to thread top/bottom
- **Cmd+Opt+Page Up / Page Down** -- Jump to previous/next message
- **Cmd+Opt+Shift+Page Up / Page Down** -- Jump to previous/next prompt
- **Cmd+Opt+Up / Down** -- Scroll thread up/down

### Model and profile management

- **Ctrl+Opt+/** -- Toggle model selector (switch between language models)
- **Opt+L** -- Cycle favorite models (quick-cycle without opening selector)
- **Ctrl+Opt+P** -- Manage profiles
- **Shift+Tab** -- Cycle profiles (when agent panel is focused)

### Inline assist

- **Cmd+Enter** -- Zed's default for inline assist, but **overridden** in Editor context by the custom "Open file under cursor" binding (`secondary-enter` in `keymap.json`). Use **Cmd+;** or the command palette (search "inline assist") instead.
- **Cmd+;** -- Open inline assistant (select text first; works in editors, terminal, and rules library)

### Edit predictions (AI code completion)

- **Tab** -- Accept edit prediction (when no completions menu is visible and indentation is unambiguous)
- **Opt+L** -- Accept edit prediction (use when Tab conflicts, e.g. completions menu is open)
- **Opt+]** -- Next edit prediction (cycle through alternatives)
- **Opt+[** -- Previous edit prediction

### External agents (Claude ACP)

The agent panel (Cmd+? to toggle) connects to Claude Code via the `claude-acp` bridge. It runs in SDK isolation mode, so subagent spawning and `--team` mode are not available. Use it for quick questions and simple edits.

Debug ACP communication via the command palette: search for `dev: open acp logs`.

### Claude Code (terminal task)

**Ctrl+Shift+A** \* launches the full Claude Code CLI as a terminal task. This is the primary path for multi-step work:

- `/research` -- Investigate a topic
- `/plan` -- Create an implementation plan
- `/implement` -- Execute a plan
- `/convert` -- Convert document formats

The keybinding is configured in `keymap.json` using `task::Spawn` with `task_name: "Claude Code"`, and works from both Workspace and Terminal contexts. The terminal opens in the dock panel (position controlled by `terminal.dock` in `settings.json`).

## How do I build or preview Typst / Slidev files?

Two keybindings work for both Typst (`.typ`) and Slidev (`.md`) files -- they detect the file extension and dispatch automatically:

- **Opt+Shift+E** \* -- **Build PDF**. For `.typ` files, runs `typst compile`. For Slidev `.md` files, exports to PDF via Playwright (Chromium is downloaded automatically on first use).
- **Opt+Shift+P** \* -- **Preview in browser**. For `.typ` files, opens the compiled PDF with `open` (compiles first if needed). For Slidev `.md` files, launches the dev server and opens the presentation in your browser; press Ctrl+C in the terminal to stop.

## How do I use the terminal?

Press **Ctrl+`** (backtick, the key below Escape) to toggle the terminal panel at the bottom of the screen. You can run any command here, including `git` commands and Claude Code.

## How do I preview Markdown files?

- **Cmd+Shift+V** opens the preview in a full tab
- For side-by-side preview, use the command palette (Cmd+Shift+P) and search "markdown preview"

## How do I use Git?

Zed has built-in Git support:

- **Cmd+Shift+G** opens the Git panel (stage, commit, push)
- **Cmd+Shift+B** \* shows who last edited each line (git blame)

For more control, use the terminal (Ctrl+`) and run git commands directly.

## How do I open the command palette?

Press **Cmd+Shift+P** to open the command palette. You can search for any Zed command here -- it is useful when you cannot remember a shortcut.

## How do I go to a specific line?

Press **Ctrl+G**, type the line number, and press Enter.

## How do I navigate code?

- **F12** jumps to where something is defined
- **Cmd+O** \* goes back to where you were before (jump list; overrides Open file)
- **Cmd+I** \* goes forward again (jump list)
- **Opt+Left** goes back (Zed default, same effect)
- **Opt+Right** goes forward (Zed default, same effect)

## How do I toggle vim mode?

Press **Opt+V** \* to toggle vim mode on and off. When vim mode is active, Zed enables modal editing (normal, insert, visual modes). Press the same shortcut again to return to standard editing. This is useful if you want vim keybindings temporarily for a specific task without committing to them full-time.

## How do I open settings?

Press **Cmd+,** to open the settings file. Changes take effect when you save.

## Adding more shortcuts

Open `keymap.json` (search for it with Cmd+P). The file contains custom bindings at the top and a commented reference of Zed defaults at the bottom. To add a new shortcut, add a new entry in the custom bindings section following the existing pattern. For new bindings, prefer the `secondary-` modifier (e.g., `"secondary-shift-n"` maps to Cmd+Shift+N on macOS). Use explicit `ctrl-` only when you need to avoid collisions with Cmd-based shortcuts (e.g., Cmd+Q quits the app). See [settings.md](settings.md) for details on the keymap format.
