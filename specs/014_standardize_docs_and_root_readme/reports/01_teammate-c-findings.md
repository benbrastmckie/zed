# Teammate C: Critic Findings
## Task 14 — Standardize docs/ README files and improve root README

**Role**: Critic — identify gaps, broken links, stale content, inconsistencies
**Date**: 2026-04-10
**Scope**: All README.md files in `/home/benjamin/.config/zed/docs/` and subdirectories; `/home/benjamin/.config/zed/README.md`; `.memory/README.md`; `.claude/README.md`

---

## Key Findings Summary

| Severity | Count | Category |
|----------|-------|----------|
| Critical | 3 | Platform mismatch (macOS vs NixOS Linux) |
| High | 5 | Stale/incorrect shortcut keys |
| High | 2 | Broken links |
| High | 1 | Root README missing core purpose (epi/medical research) |
| Medium | 4 | Neovim carry-over content in wrong context |
| Medium | 2 | Navigation section mislabeled |
| Medium | 1 | Anchor link mismatch |
| Low | 3 | Minor inconsistencies and stale examples |

---

## Finding 1 (Critical): Platform Claimed as macOS — Actual System is NixOS Linux

**Files affected**:
- `/home/benjamin/.config/zed/README.md` — lines 3, 5, 9–10, 65, 84–86
- `/home/benjamin/.config/zed/docs/general/README.md` — lines 1, 7, 24, 26
- `/home/benjamin/.config/zed/docs/general/installation.md` — line 3, throughout
- `/home/benjamin/.config/zed/docs/general/keybindings.md` — line 3
- Multiple workflow docs via "macOS permissions" and "Word/Excel" references

**Evidence**:
- `settings.json` comment on line 2: `// Platform: NixOS Linux (binary: zeditor)`
- System: `Linux hamsa 6.19.10 #1-NixOS SMP`
- `settings.json` uses `/home/benjamin/.nix-profile/bin/npx` and `/home/benjamin/.nix-profile/bin/claude`
- `tasks.json` has "Open in LibreOffice" — Linux office suite, not Word
- `zed` binary is named `zeditor` on this system

**Problems**:
1. Root README line 3: "Zed editor configuration for macOS"
2. Root README line 5: "**Platform**: macOS 11 (Big Sur) or newer"
3. Root README line 9: "Install via Homebrew" (Homebrew is macOS/Linux but not standard on NixOS)
4. `installation.md` is entirely written for macOS (Xcode, Homebrew, `brew install --cask`)
5. All "Cmd+" shortcut references throughout docs — macOS uses Cmd, Linux uses Ctrl

**Recommended fix**: Either update all docs to reflect NixOS Linux accurately, or explicitly note this is a macOS-oriented guide written on a Linux development machine (if the config is intended to be shared for macOS users). The `settings.json` platform comment suggests Linux is the true platform.

---

## Finding 2 (Critical): Shortcut Key "Cmd" vs "Ctrl" — Pervasive Inconsistency

**Files affected**:
- `/home/benjamin/.config/zed/README.md` — lines 20–26, 69, 78, 80
- `/home/benjamin/.config/zed/docs/general/keybindings.md` — throughout
- `/home/benjamin/.config/zed/docs/general/installation.md` — lines 18, 143, 195, 208, 214, 218, 291
- `/home/benjamin/.config/zed/docs/workflows/README.md` — line 91
- `/home/benjamin/.config/zed/docs/workflows/maintenance-and-meta.md` — line 3
- `/home/benjamin/.config/zed/docs/workflows/tips-and-troubleshooting.md` — line 7
- `/home/benjamin/.config/zed/docs/workflows/edit-spreadsheets.md` — line 10
- `/home/benjamin/.config/zed/docs/workflows/edit-word-documents.md` — line 5

**Evidence**: `keymap.json` uses `ctrl-h`, `ctrl-l`, `ctrl-?`, `ctrl-shift-a`, `alt-j`, `alt-k` — all Ctrl-based. The only file that correctly uses Ctrl is `docs/agent-system/zed-agent-panel.md` (lines 8, 37, 153).

**Three-way inconsistency for the agent panel shortcut**:
- `zed-agent-panel.md` (correct): **Ctrl+?**
- `agent-system/README.md` (partially fixed in task 13): **Cmd+?**
- `installation.md`, `workflows/`, root `README.md`: **Cmd+Shift+?** (wrong and redundant — `?` already requires Shift)

**Note**: Task 13 summary explicitly listed 7 remaining files still using `Cmd+Shift+?` as a follow-up item, confirming this is a known, unresolved issue.

---

## Finding 3 (Critical): Root README Has Zero Mentions of Epidemiology or Medical Research

**File**: `/home/benjamin/.config/zed/README.md`

**Evidence**: `grep -c "epi" README.md` returns 0. The task description for task 14 explicitly states the goal is to "clearly present the repo as a Zed + Claude Code configuration for epidemiology and medical research."

**Current framing**: The root README presents this as a generic Zed editor setup for macOS. It mentions "grant/research commands" in the AI Integration section (line 80) as a parenthetical list, but never mentions the primary use case.

**What's missing**:
- No mention of epidemiology, R-based analysis, or clinical/medical research
- The `/epi` command is not in the root README at all
- The `docs/workflows/epidemiology-analysis.md` and `docs/workflows/grant-development.md` exist but are not surfaced at the root level
- The description of `docs/workflows/` in the root README (line 53) says "Office file workflows on macOS" — completely omitting the epi/grant workflows

**Impact**: A new user reading only the root README would have no idea this is a research-focused configuration. They would have to dive into `docs/workflows/README.md` to discover the core functionality.

---

## Finding 4 (High): Ctrl+H/J/K/L Claimed — Only H and L Are Actually Bound

**File**: `/home/benjamin/.config/zed/README.md` — line 62

**Evidence**: `keymap.json` binds `ctrl-h` and `ctrl-l` for left/right pane navigation but has no `ctrl-j` or `ctrl-k` bindings. The keymap comment explicitly notes "Ctrl+K is also Zed's chord prefix. If Ctrl+K as pane-up causes issues, remap to Ctrl+Alt+Up."

**Quote from README** (line 62): `| Ctrl+H/J/K/L | Move focus between split panes |`

**Actual keybindings**:
- `ctrl-h` → `workspace::ActivatePaneLeft` ✓
- `ctrl-l` → `workspace::ActivatePaneRight` ✓
- `ctrl-j` → not bound (no up/down pane navigation)
- `ctrl-k` → not bound (Zed chord prefix conflict)

This is a documentation lie — users will press Ctrl+J/K expecting pane navigation and get nothing.

---

## Finding 5 (High): Broken Link — `extensions/README.md` in `.claude/README.md`

**File**: `/home/benjamin/.config/zed/.claude/README.md` — line 248

**Link**: `[extensions/README.md](extensions/README.md)`

**Problem**: The `.claude/extensions/` directory does not exist. Extensions are stored as a flat `.claude/extensions.json` file. The link resolves to a non-existent file at `.claude/extensions/README.md`.

**Evidence**: `ls /home/benjamin/.config/zed/.claude/extensions*` shows only `extensions.json`. No `extensions/` directory.

---

## Finding 6 (High): `.claude/docs/README.md` — Neovim Label on Links Pointing to Zed Repo

**File**: `/home/benjamin/.config/zed/.claude/docs/README.md` — lines 3, 5, 96, 100

**Problems**:
1. Line 3: `[Neovim Configuration](../../README.md)` — the link path is technically correct (resolves to `zed/README.md`) but the label "Neovim Configuration" is wrong for this Zed config repo.
2. Line 5: "The system provides structured task management, research workflows, and implementation automation for **Neovim configuration development**." — this description is wrong for a Zed config repo.
3. Line 96: `[Neovim Configuration README](../../README.md)` — same issue.
4. Line 100: Same breadcrumb as line 3.

**Root cause**: `.claude/docs/README.md` was copied from the neovim configuration project and not updated to reflect the Zed context.

---

## Finding 7 (High): `.claude/README.md` — Extension System Description References Non-Existent Directory

**File**: `/home/benjamin/.config/zed/.claude/README.md` — lines 113–135

**Problem**: The "Extensions" section says "Extensions are loaded via `<leader>ac` keybinding" and "Available Extensions (`.claude/extensions/`)" — but:
1. `<leader>ac` is a Neovim keybinding, not a Zed keybinding
2. `.claude/extensions/` directory does not exist (only `extensions.json`)

**Note**: `docs/agent-system/README.md` correctly describes this deviation (lines 34–36): "The neovim config uses `<leader>ac` to load extensions on demand. In Zed, all extensions are pre-merged into the active configuration; there is no equivalent keybinding." But `.claude/README.md` hasn't been updated to match.

---

## Finding 8 (High): Anchor Link Mismatch in `docs/workflows/README.md`

**File**: `/home/benjamin/.config/zed/docs/workflows/README.md` — line 65

**Link**: `[convert-documents.md](convert-documents.md#slides--presentations-to-source-based-slides)`

**Actual heading** in `docs/workflows/convert-documents.md` (line 35): `## /slides — research talk creation`

**Generated anchor** from actual heading: `#slides--research-talk-creation`

**The link anchor `#slides--presentations-to-source-based-slides` does not match the actual section heading.** The `/slides` section was renamed (from a previous "presentations-to-source-based-slides" description) but the anchor in `workflows/README.md` was not updated.

Other convert-documents anchors appear correct:
- `#convert--documents-between-formats` matches `## /convert — documents between formats` ✓
- `#table--spreadsheets-to-formatted-tables` matches `## /table — spreadsheets to formatted tables` ✓
- `#scrape--pdf-annotations-to-markdown-or-json` matches `## /scrape — PDF annotations to Markdown or JSON` ✓

---

## Finding 9 (Medium): `docs/agent-system/README.md` — Navigation Section Misleadingly Lists Cross-Directory File

**File**: `/home/benjamin/.config/zed/docs/agent-system/README.md` — lines 16–22

**Problem**: The section header says "Files in this directory (`docs/agent-system/`)" but then lists `agent-lifecycle.md` with a link to `../workflows/agent-lifecycle.md`. The file is in `docs/workflows/`, not `docs/agent-system/`. This is misleading.

**Quote** (line 19):
```
- **[agent-lifecycle.md](../workflows/agent-lifecycle.md)** — Task lifecycle state machine...
```

The link itself is correct, but listing it under "Files in this directory" falsely implies it lives in `docs/agent-system/`.

---

## Finding 10 (Medium): `docs/README.md` — Workflows Description Omits Epidemiology and Grant Docs

**File**: `/home/benjamin/.config/zed/docs/README.md` — line 9

**Quote**: "Workflows — Agent task lifecycle plus Word, Excel, PowerPoint, and PDF workflows on macOS: tracked-changes editing, batch edits, spreadsheet updates, conversions, OneDrive tips, and troubleshooting"

**Problem**: The `docs/workflows/` directory now contains:
- `epidemiology-analysis.md` (added in task 13)
- `grant-development.md`
- `memory-and-learning.md`

The description in `docs/README.md` mentions none of these. A reader using `docs/README.md` as an index would not know the epidemiology and grant workflows exist.

---

## Finding 11 (Medium): `.claude/context/repo/project-overview.md` — Wrong Project Description

**File**: `/home/benjamin/.config/zed/.claude/context/repo/project-overview.md` — lines 1–3

**Quote**: "# Neovim Configuration Project ... This is a Neovim configuration project using Lua and lazy.nvim for plugin management."

**Problem**: This is the agent context file that is loaded "always" (per context index). Agents operating on this Zed config will be told they are working on a Neovim/Lua project. This is factually wrong and could lead to incorrect agent behavior.

**Impact**: High for agent operations — this file is described in `CLAUDE.md` as core context loaded every session.

---

## Finding 12 (Medium): `.memory/README.md` — Neovim-Specific Naming Examples

**File**: `/home/benjamin/.config/zed/.memory/README.md` — lines 74, 85–86

**Problems**:
1. Line 74 naming convention example: `MEM-telescope-custom-pickers.md`, `MEM-neovim-lsp-best-practices.md` — these are Neovim plugin examples, not relevant to Zed/epi research
2. YAML template (lines 85–86) shows `tags: neovim, lsp, configuration` and `topic: "neovim/lsp"` — Neovim-specific examples in what should be a generic template

**Severity**: Low-medium — purely cosmetic/confusing, not functionally broken. However, in an epi/medical research context, examples like `MEM-cohort-study-design.md` or `tags: epidemiology, R, survival-analysis` would be more relevant.

---

## Finding 13 (Low): Root README — Font Listed as JetBrains Mono, Actual Config Uses Fira Code

**File**: `/home/benjamin/.config/zed/README.md` — line 12

**Quote**: "Theme is One Dark; font is JetBrains Mono"

**Evidence**: `settings.json` line 11: `"buffer_font_family": "Fira Code"`

The theme (One Dark) is correct. The font is wrong.

---

## Finding 14 (Low): `.claude/README.md` — Documentation Hub Lists Neovim-Specific Guide

**File**: `/home/benjamin/.config/zed/.claude/README.md` — line 188

**Quote**: `[Neovim Integration](docs/guides/neovim-integration.md) - Hooks, TTS/STT`

**Problem**: This links to a Neovim-specific integration guide from within the Zed repo's agent system documentation hub. The guide exists and isn't broken, but listing it as a first-class item in the Documentation Hub section implies it's relevant for this Zed configuration. It's only relevant if someone is working on the neovim config from within this Zed repo.

---

## Finding 15 (Low): `docs/workflows/README.md` — "Reviewing a PDF paper" Scenario Uses Cmd+Shift+?

**File**: `/home/benjamin/.config/zed/docs/workflows/README.md` — line 91

**Quote**: `4. Use the Agent Panel (**Cmd+Shift+?**) to discuss the paper with Claude`

This is one of the 7 stale `Cmd+Shift+?` references identified (but not fixed) in the task 13 summary. The correct shortcut is `Ctrl+?` per `keymap.json` and `zed-agent-panel.md`.

---

## Important Aspects of the Repo NOT Covered by Documentation

1. **No explanation of who this configuration is for**: The repo contains a full epidemiology research stack (R-based analysis, grant writing, memory vault) but the root README presents it as a generic Zed config. There is no "about this configuration" section that explains the target audience (researchers, academics, clinicians).

2. **No mention of LibreOffice vs Word**: The tasks.json has "Open in LibreOffice" and the settings use nix paths, but all docs talk about Word/Excel. The Office workflow docs (edit-word-documents.md, edit-spreadsheets.md) describe macOS automation that won't work on Linux.

3. **The `/epi` command is completely absent from the root README**: It is the most domain-specific command in the entire system and the most important differentiator from a generic Zed config.

4. **No cross-link from root README to `.memory/README.md`**: The task description specifically asks for "accurate links to docs/, .memory/README.md, and .claude/README.md" — but the current root README only links to `docs/` sections. `.memory/README.md` and `.claude/README.md` are not linked.

5. **The extension system architecture is undocumented for the Zed context**: `.claude/README.md` has a whole "Extensions" section that describes the neovim extension loader (`<leader>ac`, `.claude/extensions/` directory). The Zed-specific deviation (extensions are pre-merged into `extensions.json`, no loader keybinding) is described in `docs/agent-system/README.md` but not in `.claude/README.md` itself.

---

## Recommended Approach

### Priority 1 — Fix the root README (critical, user-facing)

The root README needs three major changes:
1. Add an "About this configuration" or updated opening paragraph that presents it as a Zed + Claude Code setup for epidemiology/medical research
2. Add the `/epi` command and the epi/grant workflows to the Documentation and AI Integration sections
3. Add links to `.memory/README.md` and `.claude/README.md`
4. Fix font (JetBrains Mono → Fira Code)
5. Fix shortcut keys (Cmd → Ctrl throughout, Ctrl+H/L not H/J/K/L)
6. Fix platform statement (or clarify macOS/Linux dual use)

### Priority 2 — Fix the 7 remaining `Cmd+Shift+?` instances (high, accuracy)

Files: `docs/general/keybindings.md`, `docs/general/installation.md` (×4), `docs/workflows/README.md`, `docs/workflows/maintenance-and-meta.md`, `docs/workflows/tips-and-troubleshooting.md`, `docs/workflows/edit-spreadsheets.md`, `docs/workflows/edit-word-documents.md`

Correct value: **Ctrl+?** (matching `keymap.json` and `zed-agent-panel.md`)

### Priority 3 — Fix broken/stale links

- `.claude/README.md` line 248: Remove or replace `[extensions/README.md](extensions/README.md)` (directory doesn't exist)
- `docs/workflows/README.md` line 65: Fix anchor `#slides--presentations-to-source-based-slides` → `#slides--research-talk-creation`

### Priority 4 — Update docs/README.md description of workflows (medium)

Add epidemiology, grant development, and memory workflow descriptions to the Workflows entry.

### Priority 5 — Correct `.claude/docs/README.md` and `project-overview.md` (medium)

- Replace "Neovim Configuration" labels with "Zed Configuration"
- Replace "Neovim configuration development" description with accurate Zed/research description
- Update `project-overview.md` to describe the actual Zed repository structure

### Priority 6 — Fix `.claude/README.md` extension system description (medium)

Add a note (similar to `docs/agent-system/README.md` lines 32–36) clarifying that in this Zed repo, extensions are pre-merged and `<leader>ac` does not apply.

### Priority 7 — Update docs/agent-system/README.md navigation section (low)

Clarify that `agent-lifecycle.md` lives in `docs/workflows/` not in `docs/agent-system/`.

---

## Evidence Summary — Broken Links

| File | Line | Link | Status |
|------|------|------|--------|
| `.claude/README.md` | 248 | `extensions/README.md` | File does not exist |
| `docs/workflows/README.md` | 65 | `convert-documents.md#slides--presentations-to-source-based-slides` | Anchor mismatch — actual heading generates `#slides--research-talk-creation` |

All other links checked across root README, docs/README.md, docs/general/README.md, docs/agent-system/README.md, docs/workflows/README.md, .claude/README.md, .claude/docs/README.md, and .memory/README.md are valid (files exist).

---

## Confidence Level

**High confidence** on all findings above. Each was verified against actual file contents:
- Platform findings: verified against `settings.json` platform comment, nix paths, `uname -a` output, `tasks.json` LibreOffice entry
- Shortcut inconsistencies: verified against `keymap.json` which is the ground truth
- Missing root README content: verified by `grep -c "epi" README.md` returning 0
- Broken links: verified by `ls` confirming file/directory absence
- Anchor mismatch: verified by comparing linked anchor text against actual heading text and computing generated anchor
- Neovim carry-overs: verified by reading file content
