# Research Report: Task 1 — Teammate C Findings (Critic)

**Task**: 1 - Configure Zed with Claude agent system documentation
**Role**: Critic — gaps, shortcomings, blind spots
**Date**: 2026-04-09
**Focus**: What's wrong, missing, or contradictory in the proposed approach

---

## Key Findings

### 1. Platform Mismatch: The Office Guide Is Entirely Wrong for This System

The `zed-claude-office-guide.md` is written for macOS. This is not a minor formatting issue — the
guide's core assumptions are wrong for NixOS Linux:

| Guide Assumption | Reality on This System |
|-----------------|----------------------|
| Install via Homebrew | Installed via NixOS `configuration.nix`; binary is `zeditor` |
| Open with Cmd+Space (Spotlight) | No Spotlight; launch from terminal with `zeditor` |
| Cmd+Shift+? opens Agent Panel | Ctrl+Shift+? on Linux (config-report correctly notes this) |
| Cmd+P, Cmd+S, Cmd+, for Zed shortcuts | All are Ctrl+P, Ctrl+S, Ctrl+, |
| Microsoft Word stays open, AppleScript reloads it | No Microsoft Word; LibreOffice 25.8.5.2 is installed |
| OneDrive menu bar icon | No menu bar on Linux; OneDrive may run as a daemon or not at all |
| "macOS 11 (Big Sur) or newer" requirement | This is NixOS Linux |

**Critical**: The Word AppleScript automation described (save-edit-reload cycle) is macOS-only.
The `superdoc` MCP (`@superdoc-dev/mcp`) is designed for Microsoft Word's COM/AppleScript bridge.
On Linux, it would attempt to use python-docx or LibreOffice headlessly — behavior differs and
the "automatic reload in Word" workflow simply does not exist.

**Evidence**: `libreoffice --version` shows LibreOffice 25.8.5.2. `which libreoffice` confirms
it is at `/run/current-system/sw/bin/libreoffice`. No Microsoft Office binaries present.

**What the guide CAN document for Linux**:
- DOCX editing via SuperDoc's python-docx backend (headless, no live reload)
- XLSX editing via openpyxl MCP (unchanged from macOS)
- LibreOffice can open edited files: `libreoffice file.docx` after edits complete
- Conversion workflows (DOCX -> PDF, etc.) work the same

### 2. The "Beginner Audience" Claim Is Self-Contradictory

The task description says docs must be "accessible to a beginner." This conflicts with the
actual environment:

- **NixOS is not beginner territory.** NixOS requires comfort with declarative configuration,
  the Nix expression language, and `nixos-rebuild switch`. No beginner installs NixOS.
- **vim_mode is enabled** in the recommended settings.json. Vim modal editing (Normal, Insert,
  Visual modes) has a steep learning curve. Enabling it by default in a "beginner" guide is wrong.
- **The user has lean-lsp MCP configured**, epidemiology extensions, LaTeX, Typst agents — this
  is clearly an advanced research workflow.

**What "beginner" likely means**: Not a beginner to computing — a beginner to *this specific Zed
setup* who already knows how to use a computer but may not know vim keybindings or the
agent system structure. Possibly a collaborator or colleague.

**Recommendation**: Assume the reader is comfortable with a terminal and file paths but new to
Zed and Claude Code. The docs should not explain what a terminal is, but should explain what
vim_mode does and how to turn it off if unwanted.

### 3. vim_mode Decision Needs to Be Explicit

The config-report recommends `"vim_mode": true`. This should be flagged for the final
documentation as a deliberate choice, not a default:

- vim_mode changes how *all* editing works (cursor, modes, navigation)
- A user unfamiliar with Vim will be unable to type text (stuck in Normal mode)
- The docs need to either (a) explain vim_mode with escape hatch instructions, or
  (b) default to `false` and document how to enable it

**This is the single biggest usability gap** if docs are meant for anyone other than the primary user.

### 4. "One Dark" Theme Status Is Ambiguous

The config-report recommends `"theme": "One Dark"`. Investigation reveals:

- The themes directory at `/home/benjamin/.config/zed/themes/` is empty
- No custom theme JSON is installed there
- "One Dark" may be a built-in Zed theme or may need to be installed as an extension

The nix store search found `one.json` in home-manager test fixtures, not in the actual
Zed installation. Zed ships with built-in themes (One Dark was added to Zed's bundled themes
around 2023), but this should be verified. If it requires extension installation, the docs
need to say so.

**Risk**: If a user sets `"theme": "One Dark"` and it is not available, Zed falls back to
default silently — but this creates confusion if the documented appearance doesn't match.

### 5. RobotoMono Nerd Font: Available, Exact Name Matters

The font IS installed — confirmed via `fc-list | grep -i roboto`. However:

- The installed font is named **"RobotoMono Nerd Font"** (not "RobotoMono Nerd Font Mono" or
  "RobotoMono Nerd Font Propo")
- Zed uses the exact font family name from fc-list
- The config-report's recommended name `"RobotoMono Nerd Font"` appears correct
- Nerd Font glyphs will display in the terminal panel; Zed itself does not require them for
  the editor (no glyph-dependent UI)

**No action needed** — font is available under the correct name.

### 6. Claude Code Extension vs. Built-In AI

The config-report says "Claude Code extension — Not installed" as a required step. This needs
clarification:

- In Zed 0.230.1, the AI assistant functionality is **built-in**, not an extension
- There is a separate "Claude Code" extension that embeds the full Claude Code CLI in an
  Agent Panel — this is different from Zed's native assistant
- The config-report's `settings.json` includes `"assistant": {"default_model": {"provider": "anthropic"}}` which configures the **built-in** assistant
- The `zed-claude-office-guide.md` references `Ctrl+Shift+?` to open the "Agent Panel" — this
  is the Claude Code extension's panel, not the built-in assistant

**Critical ambiguity**: The docs must clearly distinguish between:
  1. Zed's built-in AI assistant (Ctrl+I or Ctrl+Shift+A depending on version)
  2. The Claude Code extension (embeds Claude Code CLI, shows ACP tools, runs .claude/ commands)

Only the Claude Code extension can run `/research`, `/plan`, etc. from the `.claude/` system.

### 7. The project-overview.md Is Wrong for This Directory

`/home/benjamin/.config/zed/.claude/context/repo/project-overview.md` describes a **Neovim
configuration project** — it mentions `init.lua`, `lazy.nvim`, `nvim-lspconfig`, and
`lua/plugins/`. This file was copied verbatim from the nvim `.claude/` directory.

This is a serious content error. The project-overview.md is loaded by agents to understand the
repository context. Having wrong context will cause agents to make incorrect assumptions.

**The Zed config is not a Neovim project.** The project-overview.md needs to be updated to
describe the Zed configuration repository:
- JSON-based configuration (settings.json, keymap.json)
- .claude/ agent system (same as nvim but without neovim extension)
- .memory/ knowledge vault
- Primary use cases: Office file workflows, document editing, agent task management
- No Lua files, no lazy.nvim, no treesitter

### 8. MCP Servers: superdoc and openpyxl Are Not Configured

The config-report lists `superdoc` and `openpyxl` as not configured. The current `claude mcp list`
shows only:
- gmail, Google Drive, Google Calendar (need auth)
- lean-lsp (connected)

Neither superdoc nor openpyxl is installed. The config steps in the guide (`claude mcp add
--scope user superdoc -- npx @superdoc-dev/mcp`) will work since Node.js v24.14.0 is available,
but:

- `superdoc` on Linux edits DOCX files but cannot do the macOS Word reload trick
- `openpyxl` should work identically on Linux
- Claude CLI is available at `/home/benjamin/.npm/_npx/.../claude` — this is via npx, not a
  permanent install, which may cause issues with `--scope user` persistence

**Risk**: Running `claude` via `npx` means MCP configuration is stored in the npx instance's
context, not a global install. If the npx cache is cleared, `claude` may change version.

### 9. Scope Confusion: Documentation Audience and Purpose

The task says "create appropriate documentation in zed/docs/ as well as zed/README.md." But there
are actually two different audiences who need different information:

**Audience A — Primary user (Benjamin)**: Already understands the system. Needs:
- Settings reference (what's configured and why)
- Agent system quick-reference (commands, keybindings)
- Differences from the nvim agent setup

**Audience B — Collaborator/beginner**: May not understand vim_mode, agent system, or terminal.
Needs:
- What Zed is and how to open it
- What Claude can do (plain English)
- How to type a request (Agent Panel basics)
- What the .claude/ system is without needing to understand it

The `zed-claude-office-guide.md` was written for Audience B but targets macOS. The task docs
need to decide: are they for Audience A, B, or both? Trying to serve both in one README produces
a document that's too long and serves neither well.

**Recommendation**: README.md targets Audience A (the system owner). docs/getting-started.md
targets Audience B (a collaborator encountering this for the first time). Cross-link between them.

### 10. Missing: How Zed Discovers the .claude/ System

The docs do not explain the mechanism by which Zed's Claude Code extension finds `.claude/`:
- Claude Code reads `CLAUDE.md` files up the directory tree from the open workspace
- Opening `~/.config/zed/` as a workspace in Zed means `CLAUDE.md` at `~/.config/zed/.claude/CLAUDE.md` is loaded
- The `.claude/` commands, agents, and skills are activated through this mechanism

This is non-obvious for a new user and should be documented explicitly. A user who opens a
different folder in Zed will not have the `.claude/` system available (or will get different
context from a different project's `.claude/`).

---

## Recommended Approach

### Priority 1: Fix the Platform Mismatch Before Writing Any Guide

The `zed-claude-office-guide.md` cannot be adapted by changing Cmd to Ctrl. The Office workflow
section is fundamentally different on Linux:
- No Microsoft Word = no AppleScript automation = no live reload in Word
- LibreOffice is available, and can open DOCX files after editing
- Batch DOCX editing still works via python-docx (superdoc's backend)
- Excel equivalent = LibreOffice Calc, but openpyxl MCP edits the raw .xlsx fine

**Write a Linux-native version** of the Office workflows section, not an adaptation.

### Priority 2: Clarify vim_mode in the Documentation

Either:
- Remove vim_mode from the recommended settings.json (set to false) and note it as optional
- Or keep it and add a "Vim Mode" section to README.md explaining Normal/Insert mode toggle (Escape/i)

A collaborator hitting Normal mode without explanation will think Zed is broken.

### Priority 3: Fix project-overview.md

Update `/home/benjamin/.config/zed/.claude/context/repo/project-overview.md` to describe the
Zed config, not the Neovim config. This affects all agent operations in this directory.

### Priority 4: Separate Beginner and Power-User Documentation

Structure:
```
README.md              -- System overview (power user, cross-links both audiences)
docs/
  quick-start.md       -- Audience B: "Open Zed, press Ctrl+Shift+?, type a question"
  agent-system.md      -- Audience A: Commands, skills, agents reference
  office-workflows.md  -- Linux-native Office file workflows (replaces the macOS guide)
  configuration.md     -- settings.json and keymap.json reference
```

### Priority 5: Distinguish Built-in AI from Claude Code Extension

Document which Zed integration provides what:
- Built-in assistant: Quick questions, inline completions
- Claude Code extension: Full `/command` system, .claude/ agent system, MCP tools

---

## Evidence / Examples

**Platform mismatch confirmed**:
```
$ which libreoffice
/run/current-system/sw/bin/libreoffice
$ libreoffice --version
LibreOffice 25.8.5.2
# No Microsoft Office binary found
```

**Wrong project-overview**:
```
$ head -3 ~/.config/zed/.claude/context/repo/project-overview.md
# Neovim Configuration Project
## Project Overview
This is a Neovim configuration project using Lua and lazy.nvim for plugin management.
```

**Claude via npx (not global install)**:
```
$ which claude
/home/benjamin/.npm/_npx/f333a4178fc46f03/node_modules/.bin/claude
$ claude --version
2.1.87 (Claude Code)
```

**Only html extension installed in Zed**:
```
$ cat ~/.local/share/zed/extensions/index.json | python3 -c "..."
['html']
# Claude Code extension not installed
```

**Font available under correct name**:
```
$ fc-list | grep "RobotoMono Nerd Font:"
# Returns: RobotoMono Nerd Font:style=Regular (and variants)
# Exact name matches config-report recommendation
```

---

## Confidence Level

| Finding | Confidence |
|---------|-----------|
| Platform mismatch (macOS vs Linux) | High — verified by system inspection |
| LibreOffice instead of Microsoft Word | High — binary confirmed, no MS Office found |
| vim_mode beginner concern | High — fundamental UX issue |
| project-overview.md wrong content | High — file content confirmed |
| One Dark theme ambiguity | Medium — built-in themes not enumerated from binary |
| Claude Code extension vs built-in AI | Medium — Zed 0.230.1 ships Claude Code extension by default or may need install |
| npx-based claude persistence risk | Medium — claude mcp list works, but permanence unclear |
| Audience ambiguity | High — both the task description and the source guide are ambiguous |
