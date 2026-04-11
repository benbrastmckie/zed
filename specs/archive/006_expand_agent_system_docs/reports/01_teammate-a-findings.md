# Teammate A: Primary Approach

**Task**: 6 - Expand agent-system.md into a docs/ directory
**Angle**: Implementation structure and file layout
**Date**: 2026-04-10

---

## Key Findings

### 1. Current State of docs/

The `docs/` directory at `/home/benjamin/.config/zed/docs/` contains four files:

| File | Lines | Purpose |
|------|-------|---------|
| `README.md` | 11 | Short contents page linking the other three |
| `agent-system.md` | 378 | Everything about Claude Code + Zed AI; dense and long |
| `keybindings.md` | unknown | Keyboard shortcuts (Zed-specific, Linux) |
| `office-workflows.md` | unknown | Word/Excel/PDF workflows |
| `settings.md` | unknown | Settings.json reference |

There is no `installation.md`. Installation content is currently inside `agent-system.md` (lines 7-37: Homebrew + Zed install steps, Step 3 redirects to an MCP section buried lower in the file).

### 2. What agent-system.md Actually Contains

After reading the full 378-line file, I can map its logical sections:

| Lines | Section | Should become |
|-------|---------|---------------|
| 1-37 | Installation (Homebrew, Zed, MCP step stub) | `installation.md` |
| 38-50 | Two AI Systems overview | `agent-system/README.md` intro |
| 51-103 | Claude Code Main Workflow (state machine, lifecycle) | `agent-system/workflow.md` |
| 104-165 | Command Catalog by Topic (17 commands in tables) | `agent-system/commands.md` |
| 166-213 | Memory System (vault, auto-memory, context layers) | `agent-system/context-and-memory.md` |
| 214-265 | Architecture & Configuration (pipeline, state files, layout) | `agent-system/architecture.md` |
| 266-295 | MCP Tool Setup (SuperDoc, openpyxl) | `installation.md` (MCP section) |
| 296-328 | Zed Agent Panel (how to open, keybindings table) | `agent-system/zed-agent-panel.md` |
| 329-378 | Related Documentation (22 cross-reference links) | Distributed into each file |

### 3. What claude-acp Is (and How It Works Here)

`claude-acp` is the `@zed-industries/claude-agent-acp` npm package. It implements Zed's **Agent Client Protocol (ACP)** — a WebSocket-based protocol that lets Zed talk to an external agent process. The actual config is in `settings.json`:

```json
"agent_servers": {
  "claude-acp": {
    "type": "custom",
    "command": "/home/benjamin/.nix-profile/bin/npx",
    "args": ["@zed-industries/claude-agent-acp", "--serve"],
    "env": {}
  }
}
```

Key facts discovered:
- **Not auto-installed**: In this NixOS/Linux setup `npx` is specified explicitly via the Nix profile path.
- **Not a Claude Code extension**: `claude-acp` is Zed's bridge to Claude Code. It spawns a local process and opens a WebSocket. Zed's Agent Panel communicates over this socket.
- **Loads .claude/ indirectly**: When you open a Claude ACP thread in Zed, it is connecting to the same Claude Code binary that reads `.claude/CLAUDE.md` and loads commands. The slash commands work the same way as in the terminal.
- **Authentication**: Done inside the Zed agent panel with `/login`, not via API key.
- **Custom keybinding**: There is no default shortcut for opening a claude-acp thread. It must be bound manually:

```json
{
  "bindings": {
    "ctrl-alt-c": [
      "agent::NewExternalAgentThread",
      { "agent": { "custom": { "name": "claude-acp" } } }
    ]
  }
}
```

Source: prior research in `specs/001_.../reports/01_teammate-a-findings.md` (high confidence) and `specs/002_.../reports/01_claude-acp-keybindings.md` (high confidence, web-verified).

### 4. The Existing .claude/docs/ Has Rich Internal References

The `.claude/docs/` tree at `/home/benjamin/.config/zed/.claude/docs/` contains:

```
.claude/docs/
├── README.md
├── architecture/
│   ├── system-overview.md
│   └── extension-system.md
├── guides/
│   ├── user-guide.md              # comprehensive command reference
│   ├── user-installation.md       # quick-start (neovim-focused, less relevant here)
│   ├── component-selection.md     # command vs skill vs agent decision tree
│   ├── creating-agents.md
│   ├── creating-commands.md
│   ├── creating-extensions.md
│   ├── creating-skills.md
│   ├── neovim-integration.md      # NOT relevant to this Zed repo
│   ├── tts-stt-integration.md     # NOT relevant to this Zed repo
│   └── development/
│       └── context-index-migration.md
├── reference/
│   └── standards/
│       ├── agent-frontmatter-standard.md
│       ├── extension-slim-standard.md
│       └── multi-task-creation-standard.md
└── examples/
    ├── research-flow-example.md
    └── fix-it-flow-example.md
```

The user-facing `docs/agent-system.md` already links to 22 of these. The new split files should inherit those links but link only from the relevant file (not all files linking to everything).

### 5. Agent/Skill/Extension Inventory

**Commands** (24 total in `.claude/commands/`):
- Lifecycle: task, research, plan, implement, revise
- Cleanup: review, todo, errors, fix-it, refresh, spawn, merge
- Memory: learn
- Document: convert, table, slides, scrape, edit
- Grants/Research: grant, budget, timeline, funds, talk

**Skills** (32 in `.claude/skills/`): Including team variants (skill-team-research, skill-team-plan, skill-team-implement), domain skills (latex, typst, epidemiology), and orchestration skills.

**Agents** (25 in `.claude/agents/`): See `.claude/README.md` for full mapping table.

**Extensions** (active, per `extensions.json`): latex, typst, epidemiology, memory, present, filetypes — all installed and active. The `<leader>ac` extension loader mentioned in `.claude/CLAUDE.md` is a neovim-only pattern; in this Zed workspace all commands are always available.

### 6. What the Current File Gets Wrong or Omits

1. **No claude-acp coverage**: The file describes Claude Code in general but never explains how claude-acp connects Zed's Agent Panel to Claude Code, or what the `agent_servers` block in settings.json does.
2. **Installation section is buried and split**: Homebrew/Zed install at the top, MCP setup 230 lines later. No logical flow.
3. **"Two AI Systems" section is underdeveloped**: It names Zed Agent Panel and Claude Code but doesn't explain that they are different authentication contexts (claude-acp vs built-in Zed AI) or when to use each.
4. **No coverage of the Zed `agent` settings block**: The `agent.default_model` and `agent.inline_alternatives` keys in settings.json are undocumented.
5. **Extension loading disclaimer is confusing**: The file says "no extension loading step" but `.claude/CLAUDE.md` references `<leader>ac` throughout, creating confusion.

---

## Recommended Approach

### Proposed Directory Structure

```
docs/
├── README.md                         # Update: expand table of contents
├── installation.md                   # NEW: full install guide
├── agent-system/
│   ├── README.md                     # NEW: overview + navigation
│   ├── zed-agent-panel.md            # NEW: built-in AI + claude-acp
│   ├── workflow.md                   # NEW: task lifecycle deep-dive
│   ├── commands.md                   # NEW: full command reference
│   ├── context-and-memory.md         # NEW: memory vault + context layers
│   └── architecture.md              # NEW: pipeline + state files (advanced)
├── keybindings.md                    # KEEP (already focused)
├── office-workflows.md               # KEEP (already focused)
└── settings.md                       # KEEP (already focused)
```

**What happens to agent-system.md**: It is replaced by the `agent-system/` subdirectory. The existing `docs/README.md` link to `agent-system.md` is updated to point to `agent-system/README.md`.

---

### File-by-File Specification

#### `docs/installation.md` (NEW)

- **Audience**: New user setting up for the first time
- **Source content**: Lines 7-37 and 266-295 of current `agent-system.md`, plus claude-acp setup not currently documented anywhere
- **Sections**:
  1. Prerequisites (macOS or Linux, terminal, 20 min)
  2. Install Homebrew (with verification step)
  3. Install Zed via Homebrew (`brew install --cask zed`)
  4. Install Claude Code CLI (`brew install anthropics/claude/claude-code` or npm)
  5. Set up claude-acp in Zed (the `agent_servers` block in settings.json — this is the missing piece)
  6. Authenticate (`/login` in the Zed Agent Panel, NOT an API key)
  7. Install MCP Tools (SuperDoc, openpyxl — moved from agent-system.md)
  8. Verify everything works (checklist)
- **Cross-references**: Links to `settings.md` for full settings.json reference, `agent-system/zed-agent-panel.md` for how to use the panel
- **Example content pattern**:
  ```
  ## Set up claude-acp (Zed ↔ Claude Code bridge)

  Zed communicates with Claude Code through an adapter called `claude-acp`.
  Add this to your `settings.json` inside the top-level `{}`:

  ```json
  "agent_servers": {
    "claude-acp": {
      "type": "custom",
      "command": "npx",
      "args": ["@zed-industries/claude-agent-acp", "--serve"],
      "env": {}
    }
  }
  ```

  On NixOS/Linux, replace `"command": "npx"` with the full path from
  `which npx` if Zed cannot find it in PATH.

  After saving, restart Zed. You should see "Claude Code" as an option
  when you open the Agent Panel and click +.
  ```

---

#### `docs/agent-system/README.md` (NEW)

- **Audience**: New user who has already installed, wants to understand the system
- **Source content**: "Two AI Systems" section (lines 38-50) + orientation material
- **Sections**:
  1. Two AI systems in this workspace (Zed built-in vs Claude Code via claude-acp)
  2. When to use each (quick comparison table)
  3. Navigation — what each doc in this directory covers
  4. Quick-start: first task walkthrough (3-step: `/task` → `/research` → `/implement`)
- **Cross-references**: `installation.md` (for setup), `workflow.md` (for deeper lifecycle), `.claude/README.md` (for power users)
- **Example content pattern**:
  ```
  ## Two AI Systems

  This workspace gives you two distinct AI tools:

  | | Zed Agent Panel | Claude Code (claude-acp) |
  |--|--|--|
  | Opens with | Ctrl+? | Ctrl+? → click + → Claude Code |
  | Good for | Quick edits, questions | Research, planning, multi-file work |
  | Authentication | Zed account or Anthropic key | `/login` in Agent Panel |
  | Slash commands | No | Yes — 24 commands |
  | Reads .claude/ | No | Yes |
  ```

---

#### `docs/agent-system/zed-agent-panel.md` (NEW)

- **Audience**: New to intermediate user
- **Source content**: "Zed Agent Panel" section (lines 296-328 of current file) + claude-acp setup not currently in docs
- **Sections**:
  1. Opening the panel (keyboard shortcuts, toolbar icon)
  2. Starting a built-in AI thread (Zed's own AI — quick questions)
  3. Starting a Claude Code thread via claude-acp (the powerful one)
  4. Authenticating claude-acp (`/login`)
  5. Keybindings quick reference (condensed from keybindings.md)
  6. Inline Assist
  7. Edit Predictions (Tab completion)
  8. Troubleshooting (ACP connection issues, `dev: open acp logs`)
- **Cross-references**: `keybindings.md` (full shortcut list), `installation.md` (setup), `workflow.md` (slash commands)
- **Note**: This file does what the current agent-system.md Keybindings table and "Zed Agent Panel" sections attempted but with fuller claude-acp context

---

#### `docs/agent-system/workflow.md` (NEW)

- **Audience**: New user learning the task lifecycle; intermediate users for reference
- **Source content**: "Claude Code: Main Workflow" section (lines 51-103 of current file)
- **Sections**:
  1. The state machine (visual diagram: NOT STARTED → RESEARCHED → PLANNED → COMPLETED)
  2. Creating a task (`/task "description"`)
  3. Researching (`/research N [focus]`)
  4. Planning (`/plan N`)
  5. Implementing (`/implement N`)
  6. Finishing up (`/todo`)
  7. Advanced: team mode (`--team` flag), multi-task syntax, `--remember` flag
  8. Exception states: BLOCKED, PARTIAL, EXPANDED
- **Cross-references**: `commands.md` (full syntax), `.claude/docs/examples/research-flow-example.md`, `.claude/rules/workflows.md`
- **Example content pattern**:
  ```
  ## Creating a Task

  Every piece of work starts with a task:

  ```
  /task "Add dark mode support to the settings panel"
  ```

  This creates:
  - An entry in `specs/TODO.md` with status `[NOT STARTED]`
  - A directory at `specs/006_add-dark-mode/`
  - A machine-readable entry in `specs/state.json`
  - A git commit recording the creation

  The task number (6 in this example) is how you refer to it in all
  subsequent commands: `/research 6`, `/plan 6`, `/implement 6`.
  ```

---

#### `docs/agent-system/commands.md` (NEW)

- **Audience**: Intermediate user who knows the basics, wants command-by-command reference
- **Source content**: "Command Catalog by Topic" (lines 104-165 of current file), expanded with clearer syntax examples
- **Sections**:
  1. Lifecycle commands (task, research, plan, implement, revise) — with syntax tables
  2. Maintenance commands (review, todo, errors, fix-it, refresh, spawn, merge)
  3. Memory commands (learn)
  4. Document commands (convert, table, slides, scrape, edit)
  5. Research presentation & grants (grant, budget, timeline, funds, talk)
  6. Advanced flags reference (--team, --force, --dry-run, --remember)
- **Cross-references**: `workflow.md` for lifecycle context, `.claude/docs/guides/user-guide.md` for the comprehensive power-user reference
- **Example content pattern**:
  ```
  ### /task

  Create and manage tasks.

  ```
  /task "Description"          # Create new task
  /task --recover N            # Rebuild broken task from artifacts
  /task --expand N             # Split a task into subtasks
  /task --sync                 # Repair TODO.md/state.json drift
  /task --abandon N            # Mark task terminal
  ```

  **Example**:
  ```
  /task "Research whether Typst works for conference papers"
  # → Creates task 7 at specs/007_research-typst-conference-papers/
  ```

  After creation, the task is in state `[NOT STARTED]`.
  Use `/research 7` to begin work on it.
  ```

---

#### `docs/agent-system/context-and-memory.md` (NEW)

- **Audience**: Intermediate user who wants to understand how Claude keeps knowledge
- **Source content**: "Memory System" section (lines 166-213 of current file)
- **Sections**:
  1. The two memory layers (project vault vs auto-memory) — distinction matters
  2. Project memory vault (`.memory/`) — structure, write path, read path
  3. Auto-memory (harness-managed) — what it is, that you don't touch it
  4. Using `/learn` to add memories
  5. Using `--remember` flag on `/research`
  6. The five context layers (table from current file, with explanation of each)
  7. Where to store new information (decision flowchart)
- **Cross-references**: `.memory/README.md`, `.claude/context/architecture/context-layers.md`, `commands.md` for `/learn` syntax
- **Justification**: This is conceptually distinct from task workflow and architecture — memory is a standalone topic that users often want to read in isolation

---

#### `docs/agent-system/architecture.md` (NEW)

- **Audience**: Advanced user / contributor who wants to understand internals
- **Source content**: "Architecture & Configuration" section (lines 214-265 of current file)
- **Sections**:
  1. Three-layer execution pipeline (commands → skills → agents diagram)
  2. Checkpoint-based execution (GATE IN → DELEGATE → GATE OUT → COMMIT)
  3. Session IDs and traceability
  4. State files (TODO.md, state.json, errors.json)
  5. Configuration layout (full directory tree)
  6. Extensions system (what extensions are active, that <leader>ac is neovim-only)
  7. Task routing by task_type
- **Cross-references**: `.claude/README.md`, `.claude/docs/architecture/system-overview.md`, `.claude/docs/guides/component-selection.md`
- **Justification**: Only power users or contributors need this; keeping it separate avoids overwhelming new users

---

#### `docs/README.md` (UPDATE)

Current version is 11 lines with a 4-item list. Update to:
- Add `agent-system/` subdirectory entry (replacing the single `agent-system.md` line)
- Expand descriptions to one sentence each
- Add a "Start here" pointer for new users (`installation.md` → `agent-system/README.md`)

---

### Files to Keep Unchanged

- `docs/keybindings.md` — focused, purpose-built
- `docs/office-workflows.md` — focused, purpose-built
- `docs/settings.md` — focused, purpose-built

### File to Remove

- `docs/agent-system.md` — replaced by `docs/agent-system/` directory

---

## Evidence and Examples

### Evidence: claude-acp is Configured in This Workspace

From `settings.json` (confirmed by direct file read):
```json
"agent_servers": {
  "claude-acp": {
    "type": "custom",
    "command": "/home/benjamin/.nix-profile/bin/npx",
    "args": ["@zed-industries/claude-agent-acp", "--serve"],
    "env": {}
  }
}
```

This is the only place `claude-acp` appears in settings. The hardcoded `/home/benjamin/.nix-profile/bin/npx` path is NixOS-specific and should be documented with a note about how to adapt for macOS Homebrew (`command: "npx"` is sufficient when npx is on PATH).

### Evidence: Prior Research on claude-acp

`specs/001_configure_zed_with_claude_agent_docs/reports/01_teammate-a-findings.md` (prior team research, April 2026) confirms:
- "The Claude Code agent panel opens with Ctrl+? on Linux"
- "Authentication uses /login inside the agent panel"
- "Zed auto-installs the Claude Agent adapter on first use" (macOS default; NixOS needs manual npx path)

`specs/002_add_claude_acp_keybindings_docs/reports/01_claude-acp-keybindings.md` (web-verified, April 2026) confirms:
- No default keybinding for `agent::NewExternalAgentThread`
- `dev: open acp logs` action exists for troubleshooting
- The `use_modifier_to_send` setting controls whether Enter or Ctrl+Enter sends

### Evidence: Current agent-system.md Does Not Mention claude-acp

The string "claude-acp" does not appear anywhere in `docs/agent-system.md`. The `agent_servers` settings block is not mentioned. The "Installation" section (lines 7-37) only covers Homebrew + Zed, with a vague "See the MCP Tool Setup section below" redirect. MCP setup (lines 266-295) covers SuperDoc and openpyxl but not the claude-acp adapter itself.

### Evidence: Extensions Are Always-On in This Workspace

From `agent-system.md` line 49: "Claude Code in this workspace ships **24 slash commands** that are **always available** — there is no extension loading step."

The `extensions.json` file confirms latex, typst, epidemiology, memory, present, and filetypes extensions are all `"status": "active"` with their files installed. The neovim-style `<leader>ac` loader in `.claude/CLAUDE.md` is a portability mechanism that does not apply here. This distinction should be made explicit in `architecture.md` to resolve the confusion.

---

## Confidence Level: high

All findings are based on direct file reads of the actual codebase. The claude-acp finding is corroborated by two prior research reports that were web-verified. The proposed split is driven by clear logical groupings in the current file's own section headings — I am essentially formalizing what the file already implicitly contains.

The one area of medium confidence: I did not confirm whether Homebrew-installed Zed on macOS auto-discovers `claude-acp` without the `agent_servers` block (the `@zed-industries/claude-agent-acp` package may be bundled). The current settings.json uses an explicit NixOS path which suggests manual configuration was required here. The `installation.md` should note both the auto-discovery path (macOS/typical) and the manual config path (NixOS/custom npx location).
