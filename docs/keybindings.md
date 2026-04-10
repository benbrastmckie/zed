# Keyboard Shortcuts Guide

A practical guide to the most useful keyboard shortcuts in Zed. Shortcuts marked with * are custom (defined in `keymap.json`); everything else is a Zed default.

## Quick Reference

| Shortcut | What it does |
|----------|-------------|
| Ctrl+P | Open a file by name |
| Ctrl+S | Save the current file |
| Ctrl+Z | Undo |
| Ctrl+Shift+Z or Ctrl+Y | Redo |
| Ctrl+C | Copy selected text |
| Ctrl+X | Cut selected text |
| Ctrl+V | Paste |
| Ctrl+F | Find text in current file |
| Ctrl+Shift+F | Search across all files in the project |
| Ctrl+W | Close the current tab |
| Ctrl+Tab | Switch to the next tab |
| Ctrl+` | Open or close the terminal |
| Ctrl+? * | Toggle the right sidebar (agent panel) |
| Ctrl+B | Show or hide the left sidebar |
| Alt+J * | Move the current line down |
| Alt+K * | Move the current line up |

## How do I open a file?

**By name (fastest)**: Press **Ctrl+P**, start typing the filename, then press Enter when you see it in the list. You do not need to type the full name -- a few letters are usually enough.

**From the file explorer**: Press **Ctrl+Shift+E** to open the project panel on the left. Click any file to open it. Press **Ctrl+B** to toggle the sidebar if you want more screen space.

**Save**: Press **Ctrl+S** to save the current file. **Ctrl+Shift+S** saves all open files.

## How do I work with tabs?

- **Ctrl+Tab** moves to the next tab
- **Ctrl+Shift+Tab** moves to the previous tab
- **Ctrl+W** closes the current tab
- **Ctrl+Shift+T** reopens the last closed tab

If you have split panes (two files side by side), use these custom shortcuts to move between them:

- **Ctrl+H** * -- Focus the pane to the left
- **Ctrl+L** * -- Focus the pane to the right

To create a split: **Ctrl+\\** splits the current view to the right. **Ctrl+Shift+\\** splits it downward.

## How do I edit text?

All the standard shortcuts work:

- **Ctrl+Z** to undo, **Ctrl+Y** to redo
- **Ctrl+C** to copy, **Ctrl+X** to cut, **Ctrl+V** to paste
- **Ctrl+A** to select all text in the file
- **Ctrl+D** to select the next matching word (useful for editing several identical words at once)
- **Ctrl+/** to comment or uncomment a line

### Moving lines

- **Alt+J** * -- Move the current line down
- **Alt+K** * -- Move the current line up

These are handy for reordering items in a list or moving a paragraph.

### Deleting lines

- **Ctrl+Shift+K** deletes the entire current line

## How do I find something?

**In the current file**: Press **Ctrl+F**. Type your search term and press Enter to jump through matches. Press Escape to close the search bar.

**Find and replace** (current file): Use the command palette (**Ctrl+Shift+P**) and search for "find and replace". The default Ctrl+H is remapped to pane navigation.

**Across all files in the project**: Press **Ctrl+Shift+F**. This opens a project-wide search panel. Type your term and results appear from every file.

**Replace across all files**: Press **Ctrl+Shift+H**.

## How do I use the AI agent?

Zed has a built-in AI agent panel, inline assist, edit predictions, and integration with Claude Code.

> **Verify shortcuts**: Zed updates frequently. Press **Ctrl+K Ctrl+S** to open the keybinding editor and confirm any shortcut listed here.

### Agent panel -- Opening and focus

- **Ctrl+?** * -- Toggle the right sidebar (agent panel lives here; custom override of `agent::ToggleFocus` to `workspace::ToggleRightDock`)
- **Ctrl+Shift+A** -- Open agent panel (alternative)

### Agent panel -- Thread management

- **Ctrl+N** -- Start a new thread (when agent panel is focused; may be context-dependent -- verify with Ctrl+K Ctrl+S)
- **Shift+Alt+J** -- Recent threads menu (jump to a past conversation)
- **Ctrl+Shift+H** -- View all thread history
- **Ctrl+Shift+R** -- Review changes (diff view of agent edits)
- **Double-Enter** -- Send queued message immediately (interrupts current generation)

### Agent panel -- Message editor

- **Enter** -- Send message (default; changes to **Ctrl+Enter** if `agent.use_modifier_to_send` is enabled in settings)
- **Shift+Alt+Escape** -- Expand message editor (full-size editor for longer prompts)
- **Ctrl+>** -- Add selection to thread (select text in a buffer first)
- **Ctrl+Shift+V** -- Paste raw text (without formatting)

### Agent panel -- Thread navigation (thread pane focused)

- **Arrow keys** -- Scroll thread
- **Page Up / Page Down** -- Scroll by page
- **Home / End** -- Jump to top/bottom
- **Shift+Page Up / Shift+Page Down** -- Jump between messages

### Agent panel -- Thread navigation (message editor focused)

- **Ctrl+Alt+Home / End** -- Jump to thread top/bottom
- **Ctrl+Alt+Page Up / Page Down** -- Jump to previous/next message
- **Ctrl+Alt+Shift+Page Up / Page Down** -- Jump to previous/next prompt
- **Ctrl+Alt+Up / Down** -- Scroll thread up/down

### Model and profile management

- **Ctrl+Alt+/** -- Toggle model selector (switch between language models)
- **Alt+L** -- Cycle favorite models (quick-cycle without opening selector)
- **Ctrl+Alt+P** -- Manage profiles
- **Shift+Tab** -- Cycle profiles (when agent panel is focused)

### Inline assist

- **Ctrl+Enter** -- Open inline assistant (select text first; works in editors, terminal, and rules library)
- **Ctrl+;** -- May also trigger inline assist (older default; verify with Ctrl+K Ctrl+S as this may have changed)

### Edit predictions (AI code completion)

- **Tab** -- Accept edit prediction (when no completions menu is visible and indentation is unambiguous)
- **Alt+L** -- Accept edit prediction (use when Tab conflicts, e.g. completions menu is open)
- **Alt+]** -- Next edit prediction (cycle through alternatives)
- **Alt+[** -- Previous edit prediction

### External agents (Claude ACP)

Claude ACP has no default keybinding. To add one, put this in `keymap.json`:

```json
{
  "bindings": {
    "ctrl-alt-c": ["agent::NewExternalAgentThread", { "agent_name": "claude-acp" }]
  }
}
```

Debug ACP communication via the command palette: search for `dev: open acp logs`.

### Claude Code (terminal-based)

Claude Code runs in the terminal (Ctrl+` to open). It has deeper project management features. Common commands:

- `/research` -- Investigate a topic
- `/plan` -- Create an implementation plan
- `/implement` -- Execute a plan
- `/convert` -- Convert document formats

## How do I use the terminal?

Press **Ctrl+`** (backtick, the key below Escape) to toggle the terminal panel at the bottom of the screen. You can run any command here, including `git` commands and Claude Code.

## How do I preview Markdown files?

- **Ctrl+K V** opens a side-by-side preview (press Ctrl+K, release, then press V)
- **Ctrl+Shift+V** opens the preview in a full tab

## How do I use Git?

Zed has built-in Git support:

- **Ctrl+Shift+G** opens the Git panel (stage, commit, push)
- **Alt+G B** shows who last edited each line (git blame)

For more control, use the terminal (Ctrl+`) and run git commands directly.

## How do I open the command palette?

Press **Ctrl+Shift+P** to open the command palette. You can search for any Zed command here -- it is useful when you cannot remember a shortcut.

## How do I go to a specific line?

Press **Ctrl+G**, type the line number, and press Enter.

## How do I navigate code?

- **F12** jumps to where something is defined
- **Alt+Left** goes back to where you were before
- **Alt+Right** goes forward again

## How do I open settings?

Press **Ctrl+,** to open the settings file. Changes take effect when you save.

## Adding more shortcuts

Open `keymap.json` (search for it with Ctrl+P). The file contains custom bindings at the top and a commented reference of Zed defaults at the bottom. To add a new shortcut, add a new entry in the custom bindings section following the existing pattern. See [docs/settings.md](../settings.md) for details on the keymap format.
