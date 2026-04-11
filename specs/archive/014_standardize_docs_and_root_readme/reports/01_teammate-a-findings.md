# Teammate A Findings: Documentation Current State Inventory

**Task**: 14 -- Standardize and cross-link all docs/ README.md files; improve root README.md
**Role**: Teammate A -- Primary Angle (Current State of All Documentation)
**Date**: 2026-04-10

---

## Key Findings

### 1. Platform Mismatch (High Priority)

The root `README.md` and all `docs/` README files describe this as a **macOS** configuration. The actual platform is **NixOS Linux** (`zeditor` binary, as noted in `settings.json` line 3). This is a pervasive inconsistency across six files:

- `README.md` lines 3, 5, 65, 84-86: "Zed editor configuration for macOS", "Platform: macOS 11 (Big Sur) or newer", Homebrew install instructions, `Cmd` key references
- `docs/README.md` line 3, 7-9: "Zed configuration on macOS" (twice)
- `docs/general/README.md` lines 3, 9: "Zed configuration on macOS", "Step-by-step macOS setup: Xcode Command Line Tools, Homebrew..."
- `docs/workflows/README.md` lines 3, 41, 103: "working with this Zed configuration on macOS", OneDrive/macOS permissions

The root README in particular says `brew install --cask zed` and references `Cmd` keys throughout, which will not work on Linux/NixOS.

### 2. Root README Does Not Reflect Epidemiology/Medical Research Focus (High Priority)

The repository hosts the `epidemiology` and `present` (grant/research) extensions, yet the root `README.md` contains zero mentions of epidemiology, medical research, or clinical workflows. The AI Integration section mentions `/grant`, `/budget`, `/funds`, `/timeline` only in passing in a single run-on sentence (line 80). There is no framing of the repo as a research-oriented configuration.

### 3. .claude/README.md Has One Broken Link (Medium Priority)

The `.claude/README.md` references `[extensions/README.md](extensions/README.md)` (line 202). There is no `.claude/extensions/` directory in this repo -- extensions are tracked via the flat `.claude/extensions.json` file. This link is broken.

### 4. .claude/docs/README.md Has Stale Neovim Branding (Medium Priority)

`.claude/docs/README.md` was copied from the upstream Neovim configuration and retains four Neovim-specific references:
- Line 3 and 100: breadcrumb `[Neovim Configuration](../../README.md)` -- the link itself resolves to the correct repo root README, but the label says "Neovim Configuration"
- Line 5: "structured task management, research workflows, and implementation automation for **Neovim configuration development**"
- Line 96: "**Neovim Configuration README**: Main project documentation"
- Line 18: lists `neovim-integration.md` as a guide (which covers Neovim-specific hook-based signaling, irrelevant to this Zed repo)

### 5. Root README Missing Links to .memory/README.md and .claude/README.md (Medium Priority)

The root `README.md` only links to `.claude/CLAUDE.md` (not `.claude/README.md`) and does not link to `.memory/README.md` at all. The task requirement specifically calls for accurate links to `docs/`, `.memory/README.md`, and `.claude/README.md`.

Current "Related" section (lines 92-93):
```
- [Claude Code System](.claude/CLAUDE.md) -- Full agent system documentation
- [Task List](specs/TODO.md) -- Current project tasks
```

Missing: `.claude/README.md` (architecture navigation hub) and `.memory/README.md` (memory vault reference).

### 6. Inconsistent Separator Style in docs/ README Files (Low Priority)

The `docs/` README files use inconsistent list separators:
- `docs/README.md`: Uses ` -- ` (double dash with spaces)
- `docs/general/README.md`: Uses ` — ` (em dash) and ` -- ` inconsistently
- `docs/agent-system/README.md`: Uses ` — ` (em dash) throughout
- `docs/workflows/README.md`: Uses `|` table format for content listing

The root `README.md` uses ` -- ` in its Related section (line 92) but table format with `|` for its Documentation section (lines 49-54).

### 7. docs/README.md Is Very Sparse (Low Priority)

`docs/README.md` is only 9 lines -- a title, one sentence, and a 3-item list. It serves as a pass-through index but provides no orientation, no "when to use" guidance, and no cross-links to `.claude/README.md` or `.memory/README.md`. Other README files (especially `docs/workflows/README.md`) do significantly more work.

### 8. Epidemiology Section in docs/agent-system/README.md Is Absent (Low Priority)

`docs/agent-system/README.md` documents two AI systems (Zed Agent Panel and Claude Code) and lists grant & research workflows in the comparison table (line 10), but does not mention the `epidemiology` extension or the `/epi` command. The workflows directory has `epidemiology-analysis.md` but there is no navigation pointer to it from `docs/agent-system/README.md`.

---

## Complete Documentation Inventory

### docs/ README Files

| Path | Lines | What It Covers | Key Links |
|------|-------|----------------|-----------|
| `/home/benjamin/.config/zed/docs/README.md` | 9 | Top-level index; lists 3 subdirs | `general/README.md`, `agent-system/README.md`, `workflows/README.md`, `../README.md` |
| `/home/benjamin/.config/zed/docs/general/README.md` | 27 | Covers installation, keybindings, settings; reading order | Links to 3 sub-files, `../README.md`, `../agent-system/README.md`, `../workflows/README.md`, `../../README.md` |
| `/home/benjamin/.config/zed/docs/agent-system/README.md` | 67 | Two AI systems comparison, navigation to 5 sub-files, Zed adaptations, quick start | Links to local sub-files, `../../.claude/CLAUDE.md`, `../../.claude/README.md`, `../../.claude/docs/guides/user-guide.md` |
| `/home/benjamin/.config/zed/docs/workflows/README.md` | 110 | Narrative index for all workflow guides; decision guide; common scenarios | Links to all 9 workflow files; `../agent-system/README.md`, `../general/settings.md`, `../general/installation.md` |

### System README Files

| Path | Lines | What It Covers | Key Links |
|------|-------|----------------|-----------|
| `/home/benjamin/.config/zed/README.md` | 94 | Root repo README; quick start, directory layout, documentation table, custom keybindings, AI integration, platform notes | Links to `docs/general/README.md`, `docs/agent-system/README.md`, `docs/workflows/README.md`, `.claude/CLAUDE.md`, `specs/TODO.md`, `docs/general/installation.md`, `docs/general/keybindings.md`, `docs/general/settings.md`, `docs/agent-system/zed-agent-panel.md` |
| `/home/benjamin/.config/zed/.memory/README.md` | 101 | Memory vault: multi-system usage, structure, adding memories, git workflow, MCP setup, naming conventions, template format, best practices | No links to external README files; references `memory-setup.md` in context dir (informal) |
| `/home/benjamin/.config/zed/.claude/README.md` | 260 | Agent system architecture hub: quick reference commands, architecture diagram, core components, extensions, state management, context organization, error handling, related files, version history | Internal links to `.claude/docs/` sub-files (all valid EXCEPT `extensions/README.md` which is BROKEN) |
| `/home/benjamin/.config/zed/.claude/docs/README.md` | 101 | Claude Code docs hub: documentation map, guides index, examples, templates, related docs | Breadcrumb says "Neovim Configuration" (stale); links to `../../README.md` (valid path, stale label) |

---

## Link Validity Assessment

### Broken Links

| File | Link Text | Target | Status |
|------|-----------|--------|--------|
| `.claude/README.md` line 202 | `extensions/README.md` | `.claude/extensions/README.md` | BROKEN -- no extensions/ directory |

### Stale Labels (Links Resolve But Labels Are Wrong)

| File | Link Label | Actual Target | Issue |
|------|-----------|---------------|-------|
| `.claude/docs/README.md` lines 3, 100 | "Neovim Configuration" | `../../README.md` (= repo root) | Wrong label -- this is Zed, not Neovim |
| `.claude/docs/README.md` line 96 | "Neovim Configuration README" | `../../README.md` | Wrong label |

### Missing Links (Cross-References That Should Exist But Don't)

| File | Should Link To | Why |
|------|----------------|-----|
| `README.md` | `.claude/README.md` | Architecture hub not linked from root |
| `README.md` | `.memory/README.md` | Memory vault not referenced from root |
| `docs/README.md` | `.claude/README.md` | No cross-link to agent system architecture |
| `docs/README.md` | `.memory/README.md` | No cross-link to memory vault |
| `docs/agent-system/README.md` | `docs/workflows/epidemiology-analysis.md` | Epi extension not mentioned |
| `.memory/README.md` | `.claude/README.md` | No cross-reference to agent system |

### All Other Links Verified Valid

All links in `docs/general/README.md`, `docs/workflows/README.md`, and `docs/agent-system/README.md` were verified to resolve to existing files.

---

## Structural Analysis by File

### `README.md` (root)

**Sections**: Quick Start | Directory Layout | Documentation table | Custom Keybindings | AI Integration | Platform Notes | Related

**Issues**:
1. Platform says macOS; actual platform is NixOS Linux
2. Quick start uses `brew install --cask zed` -- wrong for Linux
3. Shortcuts table uses `Cmd` -- Linux users use `Ctrl` (though the current user likely knows this)
4. No epidemiology or research identity -- this reads as a generic developer tool config, not a research-focused config
5. "Related" section links only to `.claude/CLAUDE.md` not `.claude/README.md`
6. No link to `.memory/README.md`
7. `Cmd+Shift+?` shortcut listed for agent panel -- actual Zed binding is `Cmd+?` per `docs/agent-system/README.md` line 9 (potential conflict)

### `docs/README.md`

**Sections**: Title | One sentence | 3-item list

**Issues**:
1. Extremely sparse -- just a pass-through
2. No cross-links to `.claude/README.md` or `.memory/README.md`
3. Platform description "on macOS" repeated from parent

### `docs/general/README.md`

**Sections**: Title | Navigation (3 files) | Quick start (3-step order) | See also (4 links)

**Issues**:
1. "on macOS" in opening sentence and installation.md description
2. Otherwise well-structured and complete

### `docs/agent-system/README.md`

**Sections**: Title | Two AI systems table | Navigation (5 files + 3 companion links) | Zed adaptations | Quick start | See also

**Issues**:
1. No mention of epidemiology extension or /epi command despite this being a primary use case
2. `grant & research workflows` mentioned in comparison table but no deeper navigation to those workflow docs
3. "Zed adaptations" section correctly documents differences from Neovim config -- this is good

### `docs/workflows/README.md`

**Sections**: Title + note | Contents (grouped by topic) | Decision guide | Common scenarios | See also

**Issues**:
1. "on macOS" in opening sentence and throughout
2. OneDrive/macOS permissions scenarios irrelevant on NixOS Linux
3. Well-organized otherwise; decision guide and common scenarios are excellent

### `.memory/README.md`

**Sections**: Title | Multi-System Usage | MCP Server Considerations | Directory Structure | Adding Memories | Git Workflow | MCP Server Setup | Naming Conventions | Template Format | Best Practices

**Issues**:
1. No cross-links to `.claude/README.md` or `docs/` documentation
2. References `memory-setup.md` informally ("See the memory-setup.md in your system's context directory") without a link
3. The vault is described as shared between "Claude Code and OpenCode" -- accurate but could note this is the Zed repo's vault
4. Otherwise complete and well-documented

### `.claude/README.md`

**Sections**: Title (version + date) | Quick Reference table | Architecture diagram | Core Principles | Core Components (Commands, Skills, Agents) | Extensions | State Management | Context Organization | Documentation Hub | Session Maintenance | Error Handling | Related Files | Version History

**Issues**:
1. One broken link: `extensions/README.md` (no extensions/ directory)
2. "Neovim Integration" listed under Documentation Hub / Getting Started (line 188) -- irrelevant to Zed
3. Extensions table still includes `nvim` extension (line 119) -- may or may not exist in this repo
4. Version history says "2.0 | 2025-12-26 | Clean-break refactor" and earlier -- these predate the Zed adaptation

### `.claude/docs/README.md`

**Sections**: Breadcrumb nav | Title | Intro | Documentation Map (tree) | System Architecture | Guides (Getting Started, Component Development, Domain Extensions, Advanced Topics) | Examples | Templates | Related Documentation | Breadcrumb nav

**Issues**:
1. Breadcrumb labels say "Neovim Configuration" (×2) instead of "Zed Configuration"
2. Body text says "for Neovim configuration development"
3. "Neovim Configuration README" in Related Documentation section
4. Lists `neovim-integration.md` as a getting-started guide (misleading for this repo)
5. This file is entirely agent-system-internal; users navigating from docs/ will not encounter it

---

## Recommended Approach

Based on the current state analysis, the following changes are needed in priority order:

### Priority 1: Root README.md improvements
1. Reframe intro as "Zed configuration for epidemiology and medical research" on NixOS Linux (or at minimum platform-agnostic)
2. Add prominent section on epidemiology/research capabilities (`/epi`, `/grant`, `/budget`, `/funds`, `/timeline`, `/slides`)
3. Add links to `.claude/README.md` and `.memory/README.md`
4. Fix platform claims (macOS vs NixOS Linux)
5. Verify `Cmd+Shift+?` vs `Cmd+?` for agent panel shortcut

### Priority 2: Cross-link missing connections
1. `docs/README.md`: Add "See also" with `.claude/README.md` and `.memory/README.md`
2. `docs/agent-system/README.md`: Add mention of epidemiology extension + link to `docs/workflows/epidemiology-analysis.md`

### Priority 3: Fix broken link
1. `.claude/README.md` line 202: Replace `[extensions/README.md](extensions/README.md)` with reference to `extensions.json` or remove

### Priority 4: Fix stale Neovim branding
1. `.claude/docs/README.md`: Replace all "Neovim Configuration" labels with "Zed Configuration"
2. Update description from "Neovim configuration development" to "Zed editor configuration"

### Priority 5: Formatting consistency
1. Standardize separator style across docs/ README files (choose `--` or em dash, apply consistently)
2. Decide whether macOS-specific content (OneDrive, Homebrew, Cmd keys) should be updated to reflect NixOS Linux reality or kept as-is for documentation value

---

## Confidence Level

**High** -- All findings are based on direct file reads and explicit link verification via filesystem checks. The broken link, stale labels, and missing cross-links are confirmed facts. The platform mismatch is confirmed by `settings.json` and `uname -a`. The epidemiology/research identity gap is confirmed by absence of those terms in `README.md`.

The only area of uncertainty is whether the macOS-centric documentation is **intentional** (documenting the original target platform) or **stale** (should be updated to NixOS Linux). The `settings.json` comment "Platform: NixOS Linux" and the auto-memory note "No vim mode in Zed -- Zed shared with collaborator" suggest the actual running platform is NixOS, but the documentation may be written for a collaborator who uses macOS. This should be clarified before updating platform-specific content.
