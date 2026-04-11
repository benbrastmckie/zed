# Implementation Plan: Standardize Docs and Root README

- **Task**: 14 - Standardize and cross-link all docs/ README.md files for consistency, then improve the root README.md
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/014_standardize_docs_and_root_readme/reports/01_team-research.md
- **Artifacts**: plans/01_standardize-docs-readme.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan addresses systematic documentation problems across the repository: the root README presents a generic Zed setup with no epidemiology/medical research identity, docs/ README files lack consistent structure and cross-links, and stale Neovim references and incorrect keyboard shortcuts persist in multiple files. The work covers 10+ files across docs/, .claude/, .memory/, and the root, standardizing structure, fixing broken links, removing all Neovim references, correcting keyboard shortcuts to use `Ctrl+Shift+A` as the primary keymap, and reframing the repository as a Zed + Claude Code configuration for epidemiology and medical research aimed at a macOS collaborator.

### Research Integration

The team research report (4 teammates) identified 15 issues organized by severity, inventoried 8 README files, proposed a lightweight docs/ template structure, and confirmed 2 broken links plus 7+ files with stale `Cmd+Shift+?` shortcut references. Key findings directly shape each phase below.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Rewrite root README.md to present the repo as a Zed + Claude Code configuration for epidemiology and medical research on macOS
- Add links to `.claude/README.md` and `.memory/README.md` from root and docs/
- Expand docs/README.md from 9 lines to ~30-40 lines with section descriptions and audience guidance
- Standardize docs/ README files with consistent structure (navigation, "See also" sections, `--` separators)
- Remove all Neovim references from documentation (not specs/ historical artifacts)
- Fix all broken links and stale anchors
- Correct keyboard shortcuts: `Ctrl+Shift+A` as primary Claude Code keymap, brief mention of `Ctrl+?` for ACP sidebar
- Replace all stale `Cmd+Shift+?` references across docs/
- Update `.claude/context/repo/project-overview.md` to describe a Zed configuration project
- Mention epidemiology extension in docs/agent-system/README.md

**Non-Goals**:
- Rewriting well-structured docs that only need minor fixes (docs/general/README.md, docs/agent-system/README.md)
- Updating Office workflow docs (tips-and-troubleshooting.md, edit-word-documents.md, edit-spreadsheets.md) for platform differences
- Modifying specs/ historical artifacts (reports, plans, summaries from prior tasks)
- Modifying .claude/CLAUDE.md (auto-generated, references `<leader>ac` but is agent-facing)
- Creating Architecture Decision Records or other new documentation categories

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inconsistent shortcut fixes across many files | M | M | Grep-verify all `Cmd+Shift+?` and `Cmd+?` references after Phase 3 |
| Breaking existing cross-links while adding new ones | M | L | Verify all new links resolve before closing each phase |
| Missing Neovim references in less-obvious files | L | M | Systematic grep for neovim/nvim/leader patterns; exclude specs/ |
| Root README rewrite loses useful existing content | M | L | Preserve editor shortcuts section, directory layout, and platform notes; restructure rather than discard |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Root README.md Rewrite [COMPLETED]

**Goal**: Transform the root README from a generic Zed setup document into a clear presentation of a Zed + Claude Code configuration for epidemiology and medical research on macOS.

**Tasks**:
- [ ] Rewrite opening section with identity statement: Zed + Claude Code for epidemiology/medical research on macOS
- [ ] Add research commands quick-reference table (epi, grant, budget, funds, timeline, slides, learn, convert)
- [ ] Update editor shortcuts section: primary keymap `Ctrl+Shift+A` for Claude Code, brief mention of `Ctrl+?` for ACP agent sidebar
- [ ] Fix font reference from JetBrains Mono to Fira Code
- [ ] Fix pane navigation: remove Ctrl+J/K claims (only H/L are actually bound)
- [ ] Add documentation table entries for `.claude/README.md` and `.memory/README.md`
- [ ] Remove or replace Homebrew-specific install instructions with generic macOS guidance
- [ ] Remove any Neovim references
- [ ] Keep macOS orientation throughout (do NOT mention NixOS)

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `README.md` -- Full rewrite of root README

**Verification**:
- README opens with epidemiology/medical research identity
- Contains links to .claude/README.md and .memory/README.md
- All shortcuts use Ctrl (not Cmd), with `Ctrl+Shift+A` as primary
- No Neovim references
- No NixOS references; macOS-oriented throughout
- Font listed as Fira Code

---

### Phase 2: docs/README.md Expansion and docs/ Standardization [NOT STARTED]

**Goal**: Expand the sparse docs/README.md into a proper documentation hub and add consistent "See also" sections across all docs/ README files.

**Tasks**:
- [ ] Expand docs/README.md from 9 to ~30-40 lines: add section descriptions for general/, agent-system/, workflows/
- [ ] State docs/ vs .claude/ audience distinction (docs/ = human readers, .claude/ = agent context)
- [ ] Add "See also" section with links to .memory/README.md and .claude/README.md
- [ ] Mention epi/grant/research workflows in the workflows/ description
- [ ] Add "See also" section to docs/general/README.md (link back to docs/README.md, link to .memory/)
- [ ] Add "See also" section to docs/agent-system/README.md (link to .claude/README.md, mention epidemiology extension)
- [ ] Add "See also" section to docs/workflows/README.md if missing (link to docs/README.md)
- [ ] Normalize separator style to `--` throughout docs/ README files
- [ ] Fix broken anchor in docs/workflows/README.md: `#slides--presentations-to-source-based-slides` to `#slides--research-talk-creation`

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `docs/README.md` -- Major expansion
- `docs/general/README.md` -- Add "See also", normalize separators
- `docs/agent-system/README.md` -- Add "See also", mention epidemiology extension
- `docs/workflows/README.md` -- Fix broken anchor, add "See also" if missing, normalize separators

**Verification**:
- docs/README.md is 30-40 lines with section descriptions
- All 4 docs/ README files have "See also" sections
- Broken anchor fixed
- Separator style consistent (`--`)

---

### Phase 3: Fix Keyboard Shortcuts Across docs/ [NOT STARTED]

**Goal**: Replace all stale `Cmd+Shift+?` and incorrect `Cmd+?` references in docs/ files with the correct `Ctrl+Shift+A` (primary) or `Ctrl+?` (ACP sidebar alternative).

**Tasks**:
- [ ] Fix shortcuts in docs/general/keybindings.md
- [ ] Fix shortcuts in docs/general/installation.md
- [ ] Fix shortcuts in docs/workflows/README.md
- [ ] Fix shortcuts in docs/workflows/maintenance-and-meta.md
- [ ] Fix shortcuts in docs/workflows/tips-and-troubleshooting.md
- [ ] Fix shortcuts in docs/workflows/edit-spreadsheets.md
- [ ] Fix shortcuts in docs/workflows/edit-word-documents.md
- [ ] Fix shortcuts in docs/workflows/convert-documents.md
- [ ] Fix shortcuts in docs/agent-system/README.md
- [ ] Fix shortcuts in docs/agent-system/architecture.md
- [ ] Grep-verify: zero remaining `Cmd+Shift+?` or `Cmd+?` in docs/ (excluding specs/)

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `docs/general/keybindings.md` -- Shortcut corrections
- `docs/general/installation.md` -- Shortcut corrections
- `docs/workflows/README.md` -- Shortcut corrections
- `docs/workflows/maintenance-and-meta.md` -- Shortcut corrections
- `docs/workflows/tips-and-troubleshooting.md` -- Shortcut corrections
- `docs/workflows/edit-spreadsheets.md` -- Shortcut corrections
- `docs/workflows/edit-word-documents.md` -- Shortcut corrections
- `docs/workflows/convert-documents.md` -- Shortcut corrections
- `docs/agent-system/README.md` -- Shortcut corrections
- `docs/agent-system/architecture.md` -- Shortcut corrections

**Verification**:
- `grep -r "Cmd+Shift+?" docs/` returns zero results
- `grep -r "Cmd+?" docs/` returns zero results (outside of non-Claude contexts)
- Primary keymap consistently documented as `Ctrl+Shift+A`

---

### Phase 4: Remove Neovim References and Fix .claude/ Links [NOT STARTED]

**Goal**: Purge Neovim carry-overs from .claude/ documentation files and fix broken/stale links in .claude/README.md and .claude/docs/README.md.

**Tasks**:
- [ ] Fix .claude/docs/README.md: replace "Neovim Configuration" labels with "Zed Configuration" (2 occurrences)
- [ ] Fix .claude/README.md: remove or replace broken `extensions/README.md` link (line ~202)
- [ ] Fix .claude/README.md: update extensions section to note Zed pre-loads extensions (no `<leader>ac` loading step)
- [ ] Update .claude/context/repo/project-overview.md: rewrite to describe Zed + Claude Code configuration for epi/medical research (remove "Neovim configuration project using Lua and lazy.nvim")
- [ ] Update .memory/README.md: replace Neovim-specific naming examples with epi/research examples
- [ ] Grep-verify: no remaining neovim/nvim/`<leader>` references in docs/, .claude/docs/, .claude/README.md, .memory/README.md (excluding specs/, .claude/CLAUDE.md, and .claude/context/ internal files)

**Timing**: 45 minutes

**Depends on**: 2, 3

**Files to modify**:
- `.claude/docs/README.md` -- Replace "Neovim Configuration" labels
- `.claude/README.md` -- Fix broken link, update extensions section
- `.claude/context/repo/project-overview.md` -- Rewrite project description
- `.memory/README.md` -- Replace Neovim examples with epi/research examples

**Verification**:
- No "Neovim" or "nvim" in modified files
- No broken `extensions/README.md` link
- project-overview.md describes Zed configuration
- .memory/README.md examples are epi/research-relevant

---

### Phase 5: Final Cross-Link Audit and Verification [NOT STARTED]

**Goal**: Verify all cross-links resolve correctly and no stale references remain across the full documentation set.

**Tasks**:
- [ ] Verify root README links to docs/, .claude/README.md, .memory/README.md all resolve
- [ ] Verify docs/README.md links to sub-sections and .claude/.memory resolve
- [ ] Verify .claude/README.md internal links resolve (no broken anchors or file links)
- [ ] Run final grep for `Cmd+Shift+?`, `Cmd+?`, `Neovim`, `nvim`, `<leader>`, `JetBrains Mono` across docs/, .claude/docs/, .claude/README.md, .memory/README.md, README.md
- [ ] Verify no NixOS references in any modified file
- [ ] Spot-check that `Ctrl+Shift+A` appears as the primary Claude Code keymap in root README, installation.md, and keybindings.md

**Timing**: 15 minutes

**Depends on**: 4

**Files to modify**:
- None (verification only; fix any issues found in-place)

**Verification**:
- All cross-links resolve
- Zero grep hits for stale terms across documentation scope
- `Ctrl+Shift+A` consistently documented as primary keymap

## Testing & Validation

- [ ] `grep -r "Cmd+Shift+?" docs/ README.md` returns zero results
- [ ] `grep -r "Neovim\|nvim" docs/ .claude/docs/ .claude/README.md .memory/README.md README.md .claude/context/repo/project-overview.md` returns zero results (case-insensitive)
- [ ] `grep -r "<leader>" docs/ .claude/docs/ .claude/README.md .memory/README.md README.md` returns zero results
- [ ] `grep -r "NixOS" README.md docs/` returns zero results
- [ ] Root README contains links to `.claude/README.md` and `.memory/README.md`
- [ ] docs/README.md is 30+ lines
- [ ] docs/agent-system/README.md mentions epidemiology extension
- [ ] .claude/context/repo/project-overview.md does not mention Neovim
- [ ] All modified files use Fira Code (not JetBrains Mono) where font is referenced

## Artifacts & Outputs

- `specs/014_standardize_docs_and_root_readme/plans/01_standardize-docs-readme.md` (this plan)
- `specs/014_standardize_docs_and_root_readme/summaries/01_standardize-docs-summary.md` (post-implementation)
- Modified files: README.md, docs/README.md, docs/general/README.md, docs/general/keybindings.md, docs/general/installation.md, docs/agent-system/README.md, docs/agent-system/architecture.md, docs/workflows/README.md, docs/workflows/maintenance-and-meta.md, docs/workflows/tips-and-troubleshooting.md, docs/workflows/edit-spreadsheets.md, docs/workflows/edit-word-documents.md, docs/workflows/convert-documents.md, .claude/README.md, .claude/docs/README.md, .claude/context/repo/project-overview.md, .memory/README.md

## Rollback/Contingency

All changes are to markdown documentation files with no build or runtime dependencies. Rollback is straightforward via `git checkout HEAD -- <file>` for any individual file, or `git reset HEAD~1` to undo the entire implementation commit. No data migration or state changes are involved beyond the standard task status updates.
