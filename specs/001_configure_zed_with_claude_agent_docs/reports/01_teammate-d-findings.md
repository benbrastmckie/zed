# Research Report: Task 1 — Teammate D Findings (Horizons)

**Task**: 1 - Configure Zed with Claude agent system documentation
**Role**: Horizons Researcher — long-term alignment, strategic direction, creative approaches
**Date**: 2026-04-09
**Focus**: Why Zed, agent system portability, documentation strategy, creative opportunities

---

## Key Findings

### 1. Why Zed Alongside Neovim: Complementary, Not Competing

There is no explicit ROAD_MAP.md in the Zed config directory. However, the prior research from
nvim/specs/385_research_zed_ide_installation/ makes the strategic picture clear:

**Zed is not replacing Neovim.** Each fills a different niche:

| Use Case | Better Tool | Why |
|----------|-------------|-----|
| Complex Lua scripting, plugin authoring | Neovim | LSP, treesitter, full plugin ecosystem |
| Office file workflows (DOCX, XLSX) | Zed | Claude Code Agent Panel, SuperDoc MCP |
| Quick AI-assisted edits, non-code files | Zed | Built-in AI panel, simpler UI |
| Lean, LaTeX, Typst documents | Either | Agent system is editor-agnostic |
| Partner/collaborator use | Zed | Simpler to configure, better onboarding |

The nvim task 385 research (Teammate D findings) confirms this: "Zed just becomes a faster,
more AI-native UI layer on top of the same infrastructure." The `.claude/` agent system — all
skills, agents, commands — runs in Claude Code's process, not the editor's. Zed sees it via ACP.

**Key insight**: Zed was specifically researched (task 385) in the context of installing it on
a partner's laptop for Office file work. This clarifies that one primary use case is non-developer
(or less-developer) users doing Word/Excel work via Claude Code's Agent Panel in Zed.

### 2. Agent System Portability: Already Works, Zero Modifications Needed

The `.claude/` agent system as it exists in `/home/benjamin/.config/zed/.claude/` is already
a full-featured copy of the nvim agent system. It contains:
- All commands (research, plan, implement, task, todo, errors, etc.)
- All skills (researcher, planner, implementer, git-workflow, orchestrator, etc.)
- All agents (general-research-agent, planner-agent, budget-agent, etc.)
- Full extension context (epidemiology, typst, latex, grant, filetypes, etc.)
- Rules, hooks, and settings.json

The system was designed to be editor-agnostic. ACP (Agent Client Protocol) in Zed automatically
discovers CLAUDE.md configuration files in projects. The `.claude/` system runs in Claude Code's
process — it has nothing Zed-specific or Neovim-specific.

**Verdict**: The agent system doesn't need to be "ported" — it's already there and already works.
The documentation gap is explaining what it is and how to use it in a Zed context.

### 3. Shared vs. Separate .claude/ System

The current layout has **two separate** `.claude/` directories:
- `/home/benjamin/.config/nvim/.claude/` — nvim-specific (has neovim extension, hooks)
- `/home/benjamin/.config/zed/.claude/` — zed-specific copy

This is intentional and correct. The nvim config has Neovim-specific hooks (SessionStart readiness
signal, TTS/STT integration via nvim --remote-expr). The Zed config has generic hooks and
permissions suited for Office/document workflows.

However, the project-overview.md in the Zed `.claude/context/repo/` still describes "Neovim
Configuration Project" with a Lua/lazy.nvim stack — it was copied from the nvim config and never
updated for Zed. This needs to be replaced with Zed-appropriate content.

### 4. CLAUDE.md Hierarchy Is Sound

The existing hierarchy is correct:
- `/home/benjamin/.config/CLAUDE.md` — root index pointing to nvim and zed configs
- `/home/benjamin/.config/.claude/CLAUDE.md` — redirects to nvim/.claude/
- `/home/benjamin/.config/zed/.claude/CLAUDE.md` — full agent system reference

Claude Code discovers these in order when working in the zed config directory. No structural
changes are needed to this hierarchy.

### 5. Documentation Audience and Approach

Two distinct audiences need to be served by the docs:

**Audience A: The primary user (this user)**
- Expert in the .claude/ agent system
- Knows Neovim deeply
- Needs: Zed-specific differences, NixOS quirks, quick reference for Zed keybindings
- Documentation style: concise, assumes competence

**Audience B: A partner/collaborator (non-developer)**
- New to command-line editors
- Goal: Edit Word/Excel files via Claude Code Agent Panel
- The `zed-claude-office-guide.md` already exists and serves this audience well
- Needs: beginner-friendly setup guide adapted from macOS to NixOS/Linux

The task description says "accessible to a beginner" — this aligns with Audience B. The docs
should have a clear beginner path (5-minute getting started) separate from the expert reference.

### 6. Current Zed Config State

Per config-report.md:
- Zed 0.230.1 installed, binary is `zeditor` (not `zed` — NixOS naming)
- `settings.json` missing — needs creation
- `keymap.json` missing — needs creation
- Only `html` extension installed; Claude Code extension not installed
- MCP servers (superdoc, openpyxl) not configured
- Platform: NixOS Linux — keybindings use Ctrl, not Cmd

The project-overview.md in `.claude/context/repo/` describes the wrong project (Neovim, not Zed).

### 7. NixOS-Specific Considerations

NixOS has several Zed-specific quirks that should be documented:
- Binary is `zeditor` (nixpkgs avoids name collision with legacy `zed` text editor)
- Config managed via `xdg.configFile."zed/..."` in home.nix if using Home Manager
- No manpages for Zed — all docs online at zed.dev/docs
- Node.js available (v24.14.0) so `npx @superdoc-dev/mcp` works for MCP servers
- Keybindings: Ctrl everywhere, no Cmd (Linux)

### 8. Creative Opportunities

**tasks.json for .claude/ commands**: Zed's `tasks.json` supports custom tasks that run shell
commands. This could expose common `.claude/` workflows as Zed tasks accessible via `Ctrl+Shift+R`:
```json
[
  {"label": "Claude: New Task", "command": "claude", "args": ["-p", "/task"], ...},
  {"label": "Claude: Research Task", "command": "claude", "args": ["-p", "/research"], ...}
]
```
However, this would open Claude Code in a subprocess, not in Zed's Agent Panel. The Agent Panel
is the natural interface — tasks.json is more useful for one-off shell commands (like opening a
DOCX in LibreOffice). This is worth documenting as a "tip" rather than a primary workflow.

**5-Minute Quick Start**: The docs should have a single-page quick path: install → open Agent
Panel → type your first request. New users should not need to read anything else to get started.

**NixOS Troubleshooting Section**: A dedicated NixOS issues section would be valuable since Zed
on NixOS has specific failure modes (Vulkan driver requirements, binary naming confusion).

---

## Recommended Approach

### Documentation Structure

Create these files in `zed/docs/` (once `zed/` directory exists at project root or under config):

```
~/.config/zed/
├── settings.json           # Create: main Zed config
├── keymap.json             # Create: NixOS Ctrl-based keybindings
├── README.md               # Create: Project overview + quick start
└── docs/
    ├── README.md           # Index of all docs
    ├── getting-started.md  # 5-minute path for new users
    ├── claude-agent-system.md  # How the .claude/ system works in Zed
    ├── office-workflows.md     # Word/Excel editing guide (adapt from zed-claude-office-guide.md)
    ├── nixos-notes.md          # NixOS-specific setup and quirks
    └── key-reference.md        # Keybinding cheat sheet (Ctrl-based)
```

### project-overview.md Fix

Replace the Neovim-focused `project-overview.md` in `.claude/context/repo/` with a Zed-focused
version describing:
- Purpose: Zed editor config for AI-assisted workflows, especially Office document editing
- Key files: settings.json, keymap.json, docs/
- .claude/ system overview appropriate to Zed context
- Verification commands: `zeditor` launch, `claude mcp list`

### settings.json and keymap.json Creation

Both are missing (per config-report.md). The plan should include creating them with sensible
defaults for NixOS:
- Vim mode (user is a Neovim user)
- RobotoMono Nerd Font (matches Neovim setup)
- Ctrl-based keybindings
- Claude Code as default assistant model

### Positioning in Docs

The README.md and docs should position Zed as:
> "A fast, AI-native editor for document workflows and general editing. Complements Neovim
> rather than replacing it — Neovim for code, Zed for documents and AI collaboration."

---

## Evidence and Examples

**From nvim/specs/385_research_zed_ide_installation/reports/01_teammate-d-findings.md**:
- "The .claude/ system is portable across any ACP-compatible editor today"
- "The user's sophisticated .claude/ agent system — all skills, agents, commands — works in Zed today without modification"
- "Invest in the .claude/ system itself (which the user is already doing), not in Zed-specific integrations"

**From config-report.md**:
- Zed version 0.230.1, binary `zeditor`, NixOS platform confirmed
- settings.json and keymap.json both missing — these are blocking prerequisites
- Node.js v24.14.0 available — MCP server setup (npx) will work

**From zed-claude-office-guide.md**:
- Written for macOS with Cmd keybindings — needs Linux/NixOS adaptation
- Already beginner-friendly in tone — good template for docs/office-workflows.md
- Covers the core use case: Office file editing via Claude Code Agent Panel

**From .claude/context/repo/project-overview.md (current, incorrect)**:
- Still describes "Neovim Configuration Project" with Lua/lazy.nvim stack
- Must be replaced with Zed-appropriate content before the agent system has correct context

**From the .claude/ directory structure**:
- No `extensions/` directory exists (unlike nvim's which has neovim, lean4, latex, etc.)
- All skills and agents are present, matching the nvim config
- settings.json has comprehensive permissions and hooks already configured

---

## Confidence Level

| Finding | Confidence |
|---------|------------|
| Zed complements Neovim; is not replacing it | High |
| .claude/ agent system works in Zed without modification | High |
| project-overview.md needs replacement (wrong project description) | High |
| settings.json and keymap.json must be created | High |
| Two audiences: expert user + non-developer partner | High |
| tasks.json for .claude/ commands is useful but secondary | Medium |
| NixOS-specific docs will be valuable | High |
| Zed will remain pre-1.0 quality for 1-2 more years | Medium |

---

## Suggested Documentation Principles

Based on the task description requirement for "clear, accessible to a beginner, to the point,
concise, and well organized and cross-linked":

1. **Beginner entry point**: README.md should have a 5-step quick start a non-developer can follow
2. **Progressive depth**: Quick start -> office workflows -> agent system -> expert reference
3. **NixOS-first**: All commands use `zeditor` not `zed`; Ctrl not Cmd; Linux paths
4. **Cross-linking**: Every doc links back to README.md and forward to relevant docs
5. **Keep agent system docs thin**: The .claude/README.md and .claude/docs/ already cover the
   system comprehensively — the Zed docs should link there rather than duplicate
6. **Acknowledge Zed's pre-1.0 state**: Note that APIs and UX may change; include the Zed docs
   URL for users to check for updates
