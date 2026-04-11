# Implementation Plan: Improve Documentation for Core System and Extensions

- **Task**: 33 - Improve documentation to present core agent system and extension architecture
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/033_improve_docs_core_system_extensions/reports/01_team-research.md
- **Artifacts**: plans/01_improve-docs-extensions.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The documentation tells the wrong story. The root README frames the project as "a Zed editor configuration for R and Python" when the distinctive product is the `.claude/` agent system with its task lifecycle and extension ecosystem. Machine-facing files (`.claude/CLAUDE.md`, `.claude/README.md`, `project-overview.md`) contain stale Neovim references that mislead agents every session. This plan fixes correctness issues first, then restructures user-facing documentation to center the task lifecycle and present extensions as first-class capabilities. Done when: all stale references are removed, README.md tells the agent-system story, and extensions are presented as platform capabilities rather than afterthoughts.

### Research Integration

Team research (4 teammates) identified three priority tiers: correctness fixes for stale references (Priority 1), README restructure around task lifecycle (Priority 2), and supporting doc improvements (Priority 3). Key findings: `project-overview.md` describes a Neovim/Lua project; `.claude/CLAUDE.md` references `<leader>ac`, VimTeX, and `extensions/*/manifest.json`; `.claude/README.md` lists an `nvim` extension row; README.md buries extensions under "Also available"; the task lifecycle is never explained.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No active roadmap items. This task establishes foundational documentation quality.

## Goals & Non-Goals

**Goals**:
- Remove all stale Neovim/vim references from machine-facing files
- Rewrite `project-overview.md` to accurately describe the Zed workspace
- Restructure README.md to center the agent system and task lifecycle
- Present extensions as first-class platform capabilities, not afterthoughts
- Surface the task lifecycle example and decision guide in README.md
- Fix incorrect "Python" extension listing in `docs/agent-system/README.md`

**Non-Goals**:
- Creating new documentation pages (e.g., `docs/agent-system/extensions.md`)
- Adding Mermaid diagrams or visual command maps
- Restructuring the entire `docs/` directory hierarchy
- Changing any agent system functionality or configuration

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stale reference removal breaks agent context loading | H | L | Each reference is in prose/comments, not functional paths; verify with grep after edits |
| README restructure loses useful content | M | M | Restructure existing content; do not delete sections, reframe them |
| Scope creep into supporting docs overhaul | M | H | Strict phase boundaries; Phase 3 is optional and time-boxed |
| CLAUDE.md changes affect all agent sessions | H | L | Changes are removing incorrect references, not adding new routing; test with context-discovery query |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Fix Stale References and Rewrite project-overview.md [NOT STARTED]

**Goal**: Eliminate all incorrect Neovim/vim references from machine-facing files and replace the factually wrong project-overview.md with accurate Zed workspace content.

**Tasks**:
- [ ] In `.claude/CLAUDE.md`: Replace `<leader>ac` references (lines ~73, ~293) with accurate description (extensions are pre-merged, no manual loading)
- [ ] In `.claude/CLAUDE.md`: Remove VimTeX Integration section (lines ~443-448) under LaTeX Extension
- [ ] In `.claude/CLAUDE.md`: Replace `extensions/*/manifest.json` path reference (line ~75) with `.claude/extensions.json`
- [ ] In `.claude/CLAUDE.md`: Remove `neovim` from the extension task type support list (line ~75)
- [ ] In `.claude/CLAUDE.md`: Update example references that use `neovim` task type (lines ~120, ~200, ~222) to use a valid type like `general` or `latex`
- [ ] In `.claude/README.md`: Remove `nvim` extension row from the extensions table (line ~119)
- [ ] In `.claude/README.md`: Replace `<leader>ac` loading description (line ~113) with accurate statement about pre-merged extensions
- [ ] Rewrite `.claude/context/repo/project-overview.md` entirely: describe Zed IDE configuration with R/Python language support, Claude Code agent system, extension ecosystem, and the actual directory structure
- [ ] Grep the full `.claude/` tree for any remaining `nvim`, `neovim`, `<leader>`, `VimTeX`, `lazy.nvim` references and fix them

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `.claude/CLAUDE.md` - Remove stale Neovim references
- `.claude/README.md` - Remove nvim extension, fix extension loading description
- `.claude/context/repo/project-overview.md` - Complete rewrite for Zed workspace

**Verification**:
- `grep -ri 'neovim\|nvim\|<leader>\|vimtex\|lazy.nvim' .claude/CLAUDE.md .claude/README.md .claude/context/repo/project-overview.md` returns no matches
- `project-overview.md` mentions Zed, R, Python, Claude Code, and the actual directory structure

---

### Phase 2: Restructure README.md Around Task Lifecycle [NOT STARTED]

**Goal**: Transform README.md from an "editor config for R and Python" pitch into a "structured AI development system" pitch, centering the task lifecycle and presenting extensions as platform capabilities.

**Tasks**:
- [ ] Rewrite the opening paragraph: lead with the agent system and task lifecycle as the core value, with R/Python as the development languages and Zed as the editor
- [ ] Add a 3-5 sentence "How It Works" section after Quick Start explaining the task lifecycle: `/task` creates tracked work, `/research` investigates, `/plan` creates phased plans, `/implement` executes with git commits, `/todo` archives
- [ ] Add a concrete walkthrough example showing a task flowing through the full lifecycle (adapted from `docs/agent-system/README.md` Quick Start)
- [ ] Restructure "Claude Code Commands" section into three groups: (1) Task Lifecycle (task, research, plan, implement, revise, todo), (2) Domain Extensions with purpose statements (epi, grant, budget, funds, timeline, slides, convert, edit, learn), (3) Housekeeping (review, errors, fix-it, refresh, meta, merge)
- [ ] Replace "Also available -- domain extensions" framing with "Domain Extensions" as a peer-level heading with one-sentence purpose for each extension domain (Epidemiology, Grant Development, Document Tools, Memory)
- [ ] Surface 2-3 common scenarios from `docs/workflows/README.md` decision guide (e.g., "Starting a new epi study", "Writing a grant", "Converting a document")
- [ ] Update the "AI Integration" section to mention the task lifecycle and extension system, not just the commands

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `README.md` - Major restructure of opening, commands, and AI sections

**Verification**:
- README.md opening paragraph mentions "agent system" or "task lifecycle"
- No "Also available" framing for extensions
- Three command groups are visible (lifecycle, domain, housekeeping)
- A concrete lifecycle example is present

---

### Phase 3: Fix Supporting Documentation [NOT STARTED]

**Goal**: Update secondary documentation files to align with the restructured narrative and fix known inaccuracies.

**Tasks**:
- [ ] In `docs/agent-system/README.md`: Remove "Python" from the extensions list (line ~34)
- [ ] In `docs/agent-system/README.md`: Move "Quick start: your first task" section earlier (before or immediately after "Two AI systems")
- [ ] In `docs/README.md`: Add one framing sentence to the opening paragraph about the core agent system and its extension model
- [ ] In `docs/README.md`: Update the Agent System section description to mention extensions as first-class rather than supplementary

**Timing**: 0.5 hours

**Depends on**: 1

**Files to modify**:
- `docs/agent-system/README.md` - Remove Python extension, reorder sections
- `docs/README.md` - Add framing sentence about core + extensions

**Verification**:
- `grep -i 'python' docs/agent-system/README.md` shows no "Python extension" reference
- Quick Start appears before the Navigation section in `docs/agent-system/README.md`
- `docs/README.md` opening mentions extensions or the agent system's extensibility

---

### Phase 4: Cross-File Consistency Verification [NOT STARTED]

**Goal**: Verify all modified files are internally consistent and cross-reference each other correctly.

**Tasks**:
- [ ] Verify all internal links in README.md resolve to existing files
- [ ] Verify all internal links in `.claude/README.md` resolve to existing files
- [ ] Verify `.claude/CLAUDE.md` extension descriptions match `docs/agent-system/README.md` extension list
- [ ] Grep for any remaining stale references across all modified files: `nvim`, `neovim`, `<leader>`, `VimTeX`, `lazy.nvim`, `manifest.json`, "Python" extension
- [ ] Verify `project-overview.md` directory tree matches actual repository structure
- [ ] Read through each modified file start to finish for narrative coherence

**Timing**: 0.5 hours

**Depends on**: 2, 3

**Files to modify**:
- Any files found to have remaining issues during verification

**Verification**:
- All link targets exist
- No stale Neovim references in any modified file
- Extension lists are consistent across README.md, `.claude/README.md`, and `docs/agent-system/README.md`

## Testing & Validation

- [ ] `grep -ri 'neovim\|<leader>\|vimtex\|lazy.nvim' .claude/CLAUDE.md .claude/README.md .claude/context/repo/project-overview.md` returns no matches
- [ ] `grep -i 'Also available' README.md` returns no matches
- [ ] README.md contains a task lifecycle explanation with concrete example
- [ ] README.md command section has three distinct groups (lifecycle, domain, housekeeping)
- [ ] `docs/agent-system/README.md` does not list Python as an extension
- [ ] All markdown links in modified files resolve to existing targets
- [ ] `project-overview.md` accurately describes the Zed workspace

## Artifacts & Outputs

- `specs/033_improve_docs_core_system_extensions/plans/01_improve-docs-extensions.md` (this plan)
- Modified: `.claude/CLAUDE.md` (stale reference removal)
- Modified: `.claude/README.md` (nvim extension removal, extension loading fix)
- Modified: `.claude/context/repo/project-overview.md` (complete rewrite)
- Modified: `README.md` (major restructure)
- Modified: `docs/agent-system/README.md` (Python removal, Quick Start reorder)
- Modified: `docs/README.md` (framing sentence)

## Rollback/Contingency

All changes are to documentation files tracked in git. If any change causes issues:
1. `git diff` to identify problematic changes
2. `git checkout -- <file>` to revert individual files
3. All original content preserved in git history
4. No functional code is modified, so rollback risk is minimal
