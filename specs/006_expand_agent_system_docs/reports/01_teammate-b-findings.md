# Teammate B: Alternative Patterns & Prior Art

**Task**: Expand `docs/agent-system.md` into a `docs/` directory with multiple clear, educational
documents. Also extract installation info into `docs/installation.md` focused on Homebrew and
`claude-acp`.

**Research Angle**: Prior art in `.claude/` system, alternative doc organization frameworks,
claude-acp integration details, installation.md structure alternatives.

**Date**: 2026-04-10

---

## Key Findings

### 1. The `.claude/` System Already Has Rich Documentation — Link, Don't Duplicate

The internal `.claude/` documentation is comprehensive and well-organized. User-facing docs in
`docs/` should act as a **portal** into this system, not a mirror.

**Files that should be LINKED (not duplicated) in user-facing docs:**

| Existing file | What it covers | Link from |
|---|---|---|
| `.claude/README.md` | Architecture diagram, component table, full nav hub | `docs/index.md` or `docs/reference/` |
| `.claude/CLAUDE.md` | Complete command list with usage and flags | `docs/commands.md` or inline tables |
| `.claude/docs/README.md` | Internal docs index (guides, examples, standards) | Any "advanced" section |
| `.claude/docs/guides/user-guide.md` | Full command workflows with examples | Link from `docs/commands.md` |
| `.claude/docs/guides/user-installation.md` | Claude Code CLI install steps | Link from `docs/installation.md` |
| `.claude/docs/architecture/system-overview.md` | Three-layer architecture walkthrough | Link from architecture section |
| `.claude/rules/state-management.md` | Task state machine and sync protocol | Link from advanced reference |
| `.claude/rules/git-workflow.md` | Commit conventions | Link from advanced reference |
| `.claude/rules/artifact-formats.md` | Report/plan naming conventions | Link from advanced reference |

**Key pattern in `.claude/README.md`**: It uses a hub-and-spoke structure — short summaries with
explicit links. The user-facing `docs/` should adopt the same pattern. The README leads with a
quick-reference table, then an ASCII architecture diagram, then component-by-component links.

**Style conventions observed in `.claude/` docs:**
- All headings use `##` or `###` (no `#` after the title)
- Tables are used for command/skill/agent catalogs
- Code blocks use triple backtick with language hint
- Navigation breadcrumbs at top/bottom of each file
- "See also" links at end of each major section

### 2. The Existing `docs/agent-system.md` Is Already Comprehensive

The current `docs/agent-system.md` (379 lines) covers:
- Installation (Homebrew, MCP tools)
- Both AI systems (Zed panel vs. Claude Code)
- Full command catalog with descriptions
- Memory system (two-layer: `.memory/` vault + auto-memory)
- Architecture (three-layer pipeline, state files, config layout)
- MCP tool setup (SuperDoc, openpyxl)
- Zed Agent Panel keybindings
- Known limitations
- Related documentation index

The **primary risk** in expansion is duplication. The document already links extensively to
`.claude/` internals. The expansion task should **split by audience and topic**, not add new
content wholesale.

### 3. Recommended Documentation Framework: Diátaxis (Adapted)

The [Diátaxis framework](https://diataxis.fr/) defines four document types by what the reader
needs:

| Type | Reader need | Tone | Zed workspace example |
|---|---|---|---|
| **Tutorial** | Learning by doing | Instructional, hand-holding | "Your first task with Claude Code" |
| **How-to guide** | Accomplishing a specific goal | Task-oriented, assumes competence | "How to convert a PDF to Markdown" |
| **Reference** | Accurate facts to do things correctly | Terse, complete, no narrative | Command catalog, settings schema |
| **Explanation** | Understanding why | Conceptual, analytic | "How the three-layer pipeline works" |

**Fit for this workspace**: The user request — "brief explanation → example → advanced details" —
maps cleanly to a **tutorial-first** variant of Diátaxis:

```
docs/
├── README.md           # Index (hub)
├── installation.md     # Tutorial: get running from zero (Homebrew, claude-acp, MCP)
├── quick-start.md      # Tutorial: first task end-to-end
├── commands.md         # Reference: full command catalog
├── zed-panel.md        # How-to: Zed Agent Panel usage and keybindings
├── memory.md           # Explanation: two-layer memory model
└── settings.md         # Reference: settings.json and keymap.json (already exists)
```

This avoids creating a deep nested hierarchy (which would fragment a small doc set) while giving
each document a clear, non-overlapping purpose.

**Alternative flat structure** (minimal, good for a small team):
```
docs/
├── README.md           # Hub with short summaries of each file
├── installation.md     # Zero-to-running (Homebrew + claude-acp + MCP)
├── agent-system/       # Directory replacing agent-system.md
│   ├── README.md       # Orientation: two systems overview
│   ├── commands.md     # Command catalog
│   ├── memory.md       # Memory system
│   └── architecture.md # Pipeline explanation (links to .claude/)
├── keybindings.md      # Already exists
├── settings.md         # Already exists
└── office-workflows.md # Already exists
```

**Recommendation**: Use the **flat structure with `agent-system/` subdirectory**. It keeps the
existing files in place, avoids breaking existing links in `docs/README.md`, and satisfies the
task's explicit goal of extracting `installation.md`.

### 4. claude-acp Integration — Complete Picture

**What `claude-acp` is:**

The user's `settings.json` (line 137–144) contains:
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

This configures a **custom** (manually managed) ACP server using npx to run the
`@zed-industries/claude-agent-acp` npm package. The `type: "custom"` means Zed does NOT
auto-install or auto-update it — the user manages the npm package. (The alternative `type:
"registry"` would have Zed manage installation automatically.)

**Official Zed docs** (from `https://zed.dev/docs/ai/external-agents`) confirm:

- Registry-type: `{ "type": "registry", "env": {} }` — Zed installs `@zed-industries/claude-acp`
  automatically on first thread creation and updates it automatically.
- Custom-type: User supplies `command` and `args` pointing to a local binary/npx invocation.

**Authentication**: Within a Claude Code thread, run `/login` to authenticate. This is separate
from both Zed's own API key and the Claude Code CLI auth (`claude auth login`).

**Opening claude-acp in Zed:**

- macOS: `Cmd+?` → click `+` → select "Claude Code"
- Windows/Linux: `Ctrl+?` → click `+` → select "Claude Code"
- Via keybinding (from prior research report): `ctrl-alt-c` bound to
  `agent::NewExternalAgentThread` with `{ "agent": { "custom": { "name": "claude-acp" } } }`

**Important distinction**: The `claude-code-extension` in `auto_install_extensions` (line 119 of
`settings.json`) is a Zed UI extension that adds the claude-acp entry to the agent menu. The
actual ACP server is `@zed-industries/claude-agent-acp` (or `@zed-industries/claude-acp`
registry name). Both are needed: the extension for the menu entry, the ACP server for execution.

**Existing docs coverage of ACP**: The current `docs/settings.md` mentions ACP only in passing
("claude-code-extension: Integrates Claude Code with Zed via ACP"). The `docs/agent-system.md`
does not mention `claude-acp` or `agent_servers` at all. This is a gap.

### 5. What a Homebrew-Focused `installation.md` Should Cover

Based on analysis of `docs/agent-system.md` (existing steps) and official Zed/Claude docs:

**Complete install sequence for macOS:**

1. **Homebrew** — prerequisite package manager
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   brew --version
   ```

2. **Zed** — the editor itself
   ```bash
   brew install --cask zed        # Stable release
   # OR: brew install --cask zed@preview   # Preview (newer features, less stable)
   ```
   Note: Zed auto-installs the `claude-code-extension` and other extensions listed in
   `auto_install_extensions` on first launch.

3. **Claude Code CLI** — the terminal-based agent (separate from Zed's ACP integration)
   ```bash
   brew install anthropics/claude/claude-code
   claude --version
   claude auth login              # Browser-based auth
   ```
   Note: `claude-acp` (the Zed panel integration) authenticates separately via `/login` inside
   a Zed agent thread — it does NOT share auth with the CLI.

4. **claude-acp in Zed** — two paths:
   - **Registry (recommended for macOS)**: Add to `settings.json`:
     ```json
     "agent_servers": {
       "claude-acp": { "type": "registry", "env": {} }
     }
     ```
     Zed installs and updates `@zed-industries/claude-acp` automatically.
   - **Custom (NixOS/nix-profile path — what this user has)**: Uses explicit npx path:
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
   After config, open Zed → `Cmd+?` → `+` → "Claude Code" → `/login`

5. **MCP tools** — optional, for Office document editing
   ```bash
   claude mcp add --scope user superdoc -- npx @superdoc-dev/mcp
   claude mcp add --scope user openpyxl -- npx @jonemo/openpyxl-mcp
   claude mcp list                # Verify
   ```
   Note: These MCP tools serve the **terminal Claude Code**, not Zed's ACP panel.

6. **Copy this config** — clone the `.config/zed/` repo and symlink or copy to `~/.config/zed/`

**Zed Stable vs Preview:**
- `brew install --cask zed` → stable channel
- `brew install --cask zed@preview` → preview channel (earlier access to ACP features)
- Cannot have both installed simultaneously via Homebrew casks

### 6. Patterns to Reuse from `.claude/` System

**Hub-and-spoke navigation pattern** (from `.claude/README.md`):
```markdown
## Documentation Hub

### Getting Started
- [Installation](docs/installation.md) - Zero to running
- [Quick Start](docs/quick-start.md) - First workflow

### Reference
- [Commands](docs/commands.md) - Full command catalog
```

**Breadcrumb navigation** (from `.claude/docs/*.md` files):
```markdown
[Back to Docs](../README.md) | [Agent System](.claude/README.md) | [CLAUDE.md](.claude/CLAUDE.md)
```

**ASCII architecture diagrams** (from `.claude/README.md`):
The three-layer pipeline diagram in `.claude/README.md` can be directly quoted or linked in
`docs/agent-system/architecture.md` rather than recreated.

**Command table format** (from `.claude/CLAUDE.md`):
The existing command tables with `| Command | Usage | Description |` format are the canonical
reference. User-facing docs can use shorter summaries and link to the full table.

---

## Recommended Approach (Alternative to Primary)

### Option B: Flat `docs/` Expansion with `agent-system/` Subdirectory

Replace `docs/agent-system.md` with `docs/agent-system/` directory containing focused files.
Keep existing `docs/keybindings.md`, `docs/settings.md`, `docs/office-workflows.md` in place.

**Target structure:**
```
docs/
├── README.md                     # Update: add installation.md and agent-system/ links
├── installation.md               # NEW: Homebrew + Zed + claude-acp + MCP (macOS-focused)
├── agent-system/
│   ├── README.md                 # Orientation: two AI systems, when to use each
│   ├── commands.md               # Command catalog (the 24 commands, grouped)
│   ├── memory.md                 # Two-layer memory model
│   └── architecture.md           # Three-layer pipeline + links to .claude/ docs
├── keybindings.md                # Existing (no change)
├── settings.md                   # Existing (add agent_servers / claude-acp section)
└── office-workflows.md           # Existing (no change)
```

**What moves where from `agent-system.md`:**

| Current section | Target file |
|---|---|
| Installation (Steps 1-3) | `docs/installation.md` |
| Two AI Systems overview | `docs/agent-system/README.md` |
| Claude Code: Main Workflow | `docs/agent-system/commands.md` |
| Command Catalog by Topic | `docs/agent-system/commands.md` |
| Memory System | `docs/agent-system/memory.md` |
| Architecture & Configuration | `docs/agent-system/architecture.md` |
| MCP Tool Setup | `docs/installation.md` (as step 5) |
| Zed Agent Panel keybindings | `docs/keybindings.md` (merge) |
| Known Limitations | `docs/agent-system/README.md` (bottom) |
| Related Documentation | All files get their own "See also" sections |

**Why this approach:**
- Preserves existing docs structure; only `agent-system.md` is broken up
- `docs/README.md` links remain valid after redirecting to subdirectory
- Each new file has a single clear purpose (Diátaxis-aligned)
- `installation.md` becomes standalone and reusable
- `settings.md` gains the missing `agent_servers` section

**What NOT to do:**
- Do not duplicate `.claude/CLAUDE.md`'s command table — link to it
- Do not copy `.claude/docs/guides/user-guide.md` — link to it
- Do not recreate the architecture diagram — link to `.claude/README.md`

---

## Evidence / Examples

### claude-acp config in current `settings.json`

```json
// Lines 136-144 of /home/benjamin/.config/zed/settings.json
"agent_servers": {
  "claude-acp": {
    "type": "custom",
    "command": "/home/benjamin/.nix-profile/bin/npx",
    "args": ["@zed-industries/claude-agent-acp", "--serve"],
    "env": {}
  }
}
```

This uses `type: "custom"` because this machine uses NixOS with nix-profile for npm. On a
standard macOS Homebrew install, `type: "registry"` is simpler. The `installation.md` should
document both, recommending registry for Homebrew users.

### Existing gap in `docs/settings.md`

`docs/settings.md` documents `auto_install_extensions.claude-code-extension` as "Integrates
Claude Code with Zed via ACP" but has no `agent_servers` section. The ACP server configuration
is entirely absent. This should be added as a new section.

### Official Zed ACP docs URL

https://zed.dev/docs/ai/external-agents — confirms `type: "registry"` with env customization.

### Diátaxis framework

https://diataxis.fr/ — the four-type framework (tutorial / how-to / reference / explanation).
The user-facing docs map naturally: installation.md = tutorial, commands.md = reference,
memory.md = explanation, keybindings.md = how-to.

---

## Confidence Level: high

- ACP config in `settings.json` was directly read from the file (lines 136-144) — certain.
- Official Zed docs for external agents were fetched and confirmed `type: "registry"` behavior.
- The `claude-code-extension` vs `claude-acp` distinction is confirmed by prior research in
  `specs/001_configure_zed_with_claude_agent_docs/reports/01_teammate-a-findings.md` (lines
  11-21) and the official blog post at `https://zed.dev/blog/claude-code-via-acp`.
- Homebrew install commands (`brew install --cask zed`) are confirmed by `docs/settings.md` line
  200 and `docs/agent-system.md` line 29.
- Zed Stable vs Preview distinction (two cask names) is from official Homebrew cask repository
  pattern; verified as a consistent Zed release channel practice.
- MCP tools serving terminal Claude Code (not Zed ACP panel) is confirmed by task 001 summary
  and the `claude mcp add --scope user` commands in `docs/agent-system.md`.
- The `@zed-industries/claude-agent-acp` npm package name in `settings.json` differs slightly
  from the registry name `@zed-industries/claude-acp`. Both refer to the same underlying
  package; the registry shortname is the canonical reference in Zed docs.
