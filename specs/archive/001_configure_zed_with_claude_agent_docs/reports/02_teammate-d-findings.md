# Research Report: Task 1 — Teammate D Round 2 (Horizons)

**Task**: 1 - Configure Zed with Claude agent system documentation
**Role**: Horizons — Zed-specific integration details, tasks.json, workspace configuration, .memory/ integration
**Round**: 2
**Date**: 2026-04-09

---

## Key Findings

### 1. How Claude Code Discovers .claude/ in Zed

The discovery mechanism works as follows:

**ACP workspace root = Zed's opened folder.** When a user opens `~/.config/zed/` in Zed and starts a Claude Code thread, the ACP adapter uses that folder as the working directory. Claude Code then discovers CLAUDE.md files by searching upward from the working directory, reading them in order. For this project:

1. `~/.config/zed/.claude/CLAUDE.md` — loaded as project-level context (in `.claude/` directory)
2. `~/.config/CLAUDE.md` — loaded as parent-level context (directory above)

This is identical to terminal-based Claude Code. The ACP adapter passes the Zed workspace root to the Claude Code CLI as its working directory. The `.claude/` directory is automatically treated as the configuration root for the project.

**Critical user action**: The user must open `~/.config/zed/` as the Zed project (not a parent or subdirectory) to get the correct `.claude/` context. If a user opens `~/.config/` instead, Claude Code will find the root CLAUDE.md and potentially the nvim config's CLAUDE.md first, which could cause confusion.

**Multi-folder limitation**: If the user adds multiple folders to a Zed project, Claude Code ACP always uses the first folder in the folder list as the working directory. There is no way to change this without using a workaround (`zed -n ~/.config/zed/` to open a fresh window with only the zed config). This is a known Zed limitation, tracked in discussion #49862 on the Zed GitHub.

**Implication for documentation**: The `docs/agent-system.md` should explicitly state that Claude Code is activated by opening `~/.config/zed/` as the Zed project root. The mechanism is transparent once users understand that "Zed's opened folder = Claude Code's working directory."

### 2. tasks.json: Complete Schema and Agent System Applications

Zed supports custom tasks in two locations:
- **Global**: `~/.config/zed/tasks.json` (applies to all projects)
- **Project-level**: `.zed/tasks.json` (applies when this project is open)

**Complete task schema**:
```json
[
  {
    "label": "Human-readable task name",
    "command": "shell-command",
    "args": ["arg1", "arg2"],
    "env": {"KEY": "value"},
    "cwd": "/optional/working/directory",
    "use_new_terminal": false,
    "allow_concurrent_runs": false,
    "reveal": "always",
    "hide": "never",
    "shell": "system",
    "save": "all",
    "tags": ["optional-tag"],
    "reevaluate_context": false
  }
]
```

**Available variables**: `$ZED_FILE`, `$ZED_FILENAME`, `$ZED_DIRNAME`, `$ZED_RELATIVE_FILE`, `$ZED_WORKTREE_ROOT`, `$ZED_SELECTED_TEXT`, `$ZED_ROW`, `$ZED_COLUMN`, `$ZED_SYMBOL`, `$ZED_LANGUAGE`, `$ZED_STEM`.

**Keybinding to spawn a task**:
```json
{
  "context": "Workspace",
  "bindings": {
    "ctrl-shift-r": ["task::Spawn", {"task_name": "task label"}]
  }
}
```

**Useful tasks for this project**:

The primary Claude Code interaction is via the Agent Panel, not tasks.json. However, tasks.json is valuable for:

1. **Open in LibreOffice** — After SuperDoc edits a DOCX, open it for review:
   ```json
   {
     "label": "Open in LibreOffice",
     "command": "libreoffice",
     "args": ["$ZED_FILE"],
     "reveal": "never"
   }
   ```

2. **Git status** — Quick terminal command for state review:
   ```json
   {
     "label": "Git Status",
     "command": "git",
     "args": ["status"],
     "cwd": "$ZED_WORKTREE_ROOT"
   }
   ```

3. **Export .claude/ to markdown** — Runs the existing export script:
   ```json
   {
     "label": "Export Agent System to Markdown",
     "command": "bash",
     "args": [".claude/scripts/export-to-markdown.sh"],
     "cwd": "$ZED_WORKTREE_ROOT"
   }
   ```

**Assessment**: Tasks.json is a useful secondary workflow tool for this project, primarily for opening LibreOffice on edited DOCX files and running utility scripts. It is NOT a replacement for the Claude Code Agent Panel for running `.claude/` commands. The `docs/agent-system.md` should mention tasks.json as an enhancement, not a primary workflow.

### 3. Zed Workspace Configuration: One Folder, One Workspace

Zed uses a strict "one folder, one workspace" model. Key facts:

- **No multi-root workspaces**: Unlike VS Code, there is no `.code-workspace` or equivalent multi-folder workspace format.
- **Correct way to open this project**: `zeditor ~/.config/zed/` opens the zed config directory as the workspace root.
- **Project-level settings**: `.zed/settings.json` in the workspace root overrides user settings for that project. Cannot set `vim_mode` or theme (those are user-level only).
- **The user-level settings.json already applies globally**: Everything in `~/.config/zed/settings.json` applies to all Zed windows regardless of which project is open.

**For this project specifically**: There is no need for `.zed/settings.json` unless specific per-project overrides are needed (e.g., different tab size for JSON files in this directory). The Markdown format-on-save=off setting should be at user level, not project level, since Markdown files throughout all projects benefit from this.

**Recommendation**: Keep configuration in user-level `settings.json`. Create a `.zed/settings.json` only if there are genuine project-specific needs.

### 4. The .memory/ Vault and Zed Integration

Reading `/home/benjamin/.config/zed/.memory/README.md` reveals the vault's structure and purpose:

**What the vault is**: An Obsidian-compatible shared memory vault used by both Claude Code and OpenCode. Memories are created via the `/learn` command and stored as Markdown files with YAML frontmatter.

**Vault structure**:
```
.memory/
├── 00-Inbox/        # Quick capture for new memories
├── 10-Memories/     # Stored memory entries (currently empty: only README.md)
├── 20-Indices/      # Navigation and organization
└── 30-Templates/    # Memory entry templates
```

**Current state**: The vault exists but is unpopulated — `10-Memories/` contains only a README. No memories have been created yet for the Zed config project.

**Zed-specific settings for .memory/ interaction**:

1. **Markdown editing in .memory/**: The `soft_wrap: editor_width` and `format_on_save: off` settings are essential for comfortable memory reading/editing in Zed. These should be in the user-level settings.json under the `languages.Markdown` block.

2. **Obsidian-compatible links**: The `[[filename]]` wiki-link syntax used in memory entries is not rendered as clickable links in Zed (Zed does not support wiki-link navigation). This is acceptable since .memory/ is primarily read by Claude Code, not navigated in Zed.

3. **No special Zed configuration needed**: The `/learn` command creates and manages memories entirely through Claude Code. The user doesn't need Zed to understand or navigate the vault — they interact with it through Claude Code commands.

**What the agent-system.md should document about .memory/**:
- The vault exists at `.memory/` and stores learned facts from tasks
- The `/learn` command creates memories (text, file, directory, or task-based)
- The `/research N --remember` flag searches vault for prior knowledge
- Memories use MEM-{slug}.md filename format
- Point to `.memory/README.md` for full details, do not duplicate

### 5. What docs/agent-system.md Needs to Cover

The `.claude/README.md` already covers the agent system comprehensively (commands, skills, agents, extensions, architecture, state management). The Zed-level `docs/agent-system.md` should NOT duplicate this.

**Unique Zed-context content for agent-system.md** (not in .claude/README.md):

1. **How to start Claude Code in Zed**: Open Agent Panel → click `+` → select "New Claude Code Thread" (or use `Ctrl+?` or configured keybinding). Run `/login` on first use.

2. **Why the project must be opened correctly**: Claude Code uses Zed's workspace root as its working directory. Open `~/.config/zed/` specifically to activate the `.claude/` system.

3. **Built-in AI vs. Claude Code**: Zed has a built-in AI assistant (configured via the `assistant` block in settings.json). Claude Code is a separate ACP agent with access to `.claude/` commands. Only Claude Code can run `/research`, `/plan`, `/implement`, etc.

4. **ACP slash commands**: Custom slash commands from `.claude/commands/` are fully supported in Zed's Claude Code integration. The commands in `.claude/commands/` are automatically available as slash commands in the Agent Panel.

5. **The .memory/ vault**: Brief description + link to `.memory/README.md`.

6. **Current limitations vs. terminal Claude Code**: Some built-in slash commands may not be available in Zed's ACP integration; custom commands from `.claude/commands/` work fine.

7. **How to verify the agent system is loaded**: Ask Claude Code to show the task list or run `/todo` — if the CLAUDE.md hierarchy is loaded correctly, it will have access to specs/TODO.md.

### 6. Creative Approaches for Agent System Workflow

**Snippets for common .claude/ patterns**:

Zed supports snippets at `~/.config/zed/snippets/snippets.json` (global) or `~/.config/zed/snippets/markdown.json` (Markdown-specific). Useful snippets for `.claude/` work:

```json
{
  "Task command": {
    "prefix": "task",
    "body": "/task \"${1:description}\"",
    "description": "Create a new agent task"
  },
  "Research command": {
    "prefix": "research",
    "body": "/research ${1:N}",
    "description": "Research a task"
  },
  "Memory frontmatter": {
    "prefix": "mem",
    "body": "---\ntitle: \"${1:Title}\"\ncreated: ${2:2026-04-09}\ntags: ${3:tag1, tag2}\ntopic: \"${4:topic}\"\nsource: \"${5:user input}\"\n---\n\n$0",
    "description": "Memory vault entry frontmatter"
  }
}
```

These are modest enhancements — users already know what commands to type. But for less-frequent commands (`/grant`, `/timeline`, `/funds`), snippets reduce cognitive load.

**Zed's terminal panel for Claude Code CLI**: The Agent Panel runs Claude Code via ACP. For some operations (like checking `claude mcp list` or running the export script), the built-in terminal (`Ctrl+\`` or similar) is useful. The docs should mention both interfaces.

**File panel for navigating specs/**: Zed's file panel (project tree) is useful for browsing task artifacts in `specs/{NNN}_{SLUG}/reports/`. The soft-wrap setting for Markdown ensures reports are readable when opened in Zed.

---

## Recommended Approach

### For docs/agent-system.md

Structure it as a thin bridge document (~100-150 lines):

```
1. The Two AI Systems in Zed (built-in assistant vs. Claude Code)
2. Starting Claude Code (keybinding, /login, first use)
3. Project Discovery (open ~/.config/zed/, workspace root = working directory)
4. Available Commands (point to .claude/README.md for full list, show 3-4 key commands)
5. The Memory Vault (what it is, /learn, /research --remember, link to .memory/README.md)
6. tasks.json Enhancements (LibreOffice open, export script)
7. Known Limitations (ACP vs terminal parity, multi-folder restriction)
```

**Do not duplicate** the command reference table from `.claude/README.md`. Instead, show 3 representative commands and link to the full reference.

### For tasks.json

Create `~/.config/zed/tasks.json` with 2-3 practical tasks:
- Open current file in LibreOffice
- Export agent system to markdown
- Git status in worktree root

### For .zed/settings.json

Only create if genuine project-specific overrides are needed. Markdown settings (format-off, soft-wrap) should be user-level.

### For project-overview.md

This is the highest-priority fix (confirmed by all teammates in Round 1). Replace the Neovim content with Zed-appropriate content before any agent work in this directory.

---

## Evidence

**Workspace root discovery** (from Zed GitHub discussion #49862):
> "When a Zed project has multiple folders, the agent always uses the first folder added to the project."

This confirms that opening `~/.config/zed/` alone (as a single-folder project) is the correct approach. The CLAUDE.md hierarchy loads automatically from that root.

**Custom slash commands work** (from Zed ACP docs):
> "Custom slash commands are fully supported, and have been merged into skills."

This means all `.claude/commands/*.md` files are available as slash commands in the Zed Agent Panel.

**Workspace root = working directory** (from ACP DeepWiki):
> "The agent uses the current working directory as the project root by default. Configuration files in `<cwd>/.claude/` take precedence over user-level settings."

**tasks.json variables available** (from Zed docs):
- `$ZED_WORKTREE_ROOT` — can be used to ensure tasks run in the correct directory
- `$ZED_FILE` — enables file-specific tasks (e.g., "open this DOCX in LibreOffice")

**Snippets live at** `~/.config/zed/snippets/` with `snippets.json` (global) or `{language}.json` (per-language). The `markdown.json` file would serve `.claude/` document authoring and memory entry creation.

**.memory/ vault is unpopulated**: `ls /home/benjamin/.config/zed/.memory/10-Memories/` returns only `README.md`. No memories exist yet for the Zed config. The first memory creation will happen naturally as tasks complete.

---

## Confidence Level

| Finding | Confidence |
|---------|------------|
| ACP uses Zed workspace root as Claude Code working directory | High — confirmed by multiple sources |
| CLAUDE.md discovered from workspace root upward | High — standard Claude Code behavior |
| Custom .claude/commands/ work as slash commands in Zed | High — documented in Zed ACP docs |
| Multi-folder projects use first folder for ACP | High — documented in GitHub discussion #49862 |
| tasks.json schema and variable list | High — from official Zed docs |
| Snippets format and location | High — from official Zed docs |
| .memory/ vault is unpopulated | High — confirmed by filesystem check |
| Built-in AI vs. Claude Code distinction | High — confirmed by Teammate A in Round 1 |
| Exact keybinding for Claude Code panel (Ctrl+?) | Medium — varies by keymap config |
| Snippets for .claude/ commands would be used regularly | Low — user already knows commands; value is modest |
