# Implementation Plan: Configure Zed with Claude Agent Documentation

- **Task**: 1 - configure_zed_with_claude_agent_docs
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/001_configure_zed_with_claude_agent_docs/reports/02_team-research.md
- **Artifacts**: plans/02_implementation-plan.md
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
- **Type**: general
- **Lean Intent**: false

## Overview

Configure Zed editor with verified settings, keybindings, and tasks from two rounds of team research, then create beginner-friendly documentation in `docs/`. The project-overview.md must be rewritten from Neovim to Zed. All configuration artifacts (settings.json, keymap.json, tasks.json) are ready from research; documentation requires original writing with cross-linking. Definition of done: Zed opens with correct theme/vim/agent config, docs are navigable from README.md, and project-overview.md accurately describes this repository.

## Goals & Non-Goals

**Goals**:
- Write settings.json, keymap.json, tasks.json with verified content from research
- Create README.md as a navigation hub with quick start
- Create docs/settings.md documenting all configuration choices
- Create docs/agent-system.md as a thin bridge to .claude/README.md and .memory/README.md
- Create docs/office-workflows.md for Linux-native Office file workflows
- Rewrite .claude/context/repo/project-overview.md for Zed (currently describes Neovim)

**Non-Goals**:
- Creating .zed/settings.json (user-level config covers everything)
- Duplicating .claude/README.md or .memory/README.md content
- Installing or configuring Priority 2 extensions (Context7, MarkItDown, Brave Search)
- Resolving unverified keybinding conflicts (tab/shift-tab, space i shift-r) -- noted for live testing

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Tab/Shift-Tab conflicts with vim Tab motion | M | M | Note in docs as needing live testing; provide fallback binding |
| One Dark theme not built-in | L | L | Research says likely built-in; fall back to "One Dark Pro" extension if needed |
| MCP servers (SuperDoc, openpyxl) not activating | M | L | Document as "requires npx"; note testing needed in docs |
| Documentation too verbose for beginner audience | M | M | Target word counts per file; use headers for scanability |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Configuration Files [NOT STARTED]

**Goal**: Create all three Zed configuration files with verified content from research.

**Tasks**:
- [ ] Create `settings.json` with theme, vim, agent, languages, context_servers, auto_install_extensions
- [ ] Create `keymap.json` with space-leader bindings, pane navigation, editor shortcuts
- [ ] Create `tasks.json` with LibreOffice open, Export Agent System, Git Status tasks
- [ ] Add inline comments where JSON allows (or add a NOTE at top of docs/settings.md) for non-obvious choices

**Timing**: 30 minutes

**Depends on**: --

**Files to create**:
- `settings.json` -- full Zed settings from research finding #1
- `keymap.json` -- keybindings from research finding #2
- `tasks.json` -- task runners from research finding #7

**Verification**:
- All three files parse as valid JSON (`python3 -m json.tool <file>`)
- settings.json contains `agent` block (not `assistant`)
- context_servers entries have no `"source": "custom"` field

---

### Phase 2: Project Overview Rewrite [NOT STARTED]

**Goal**: Replace the Neovim-focused project-overview.md with an accurate Zed description.

**Tasks**:
- [ ] Rewrite `.claude/context/repo/project-overview.md` to describe this Zed configuration repository
- [ ] Include: project purpose, technology stack (Zed, JSON config, NixOS), directory structure
- [ ] Include: development workflow (standard and AI-assisted), common tasks, verification commands
- [ ] Reference docs/ directory and .claude/ system
- [ ] Keep parallel structure to original for consistency with other repos using same agent system

**Timing**: 30 minutes

**Depends on**: --

**Files to modify**:
- `.claude/context/repo/project-overview.md` -- full rewrite

**Verification**:
- No references to Neovim, Lua, lazy.nvim, or nvim remain
- Directory structure matches actual repository layout
- Verification commands use `zeditor` (NixOS binary name)

---

### Phase 3: Settings and Keybinding Documentation [NOT STARTED]

**Goal**: Create docs/settings.md explaining every configuration choice so a beginner understands the setup.

**Tasks**:
- [ ] Create `docs/` directory
- [ ] Write `docs/settings.md` covering settings.json structure section by section
- [ ] Document each keymap.json context block with rationale for bindings
- [ ] Include table of Zed agent panel shortcuts (Ctrl+?, Ctrl+N, etc.) from research finding #4
- [ ] Document tasks.json entries and how to run them (Ctrl+Shift+P > task:)
- [ ] Note items needing live testing (tab/shift-tab conflict, space i shift-r chord)
- [ ] Cross-link to README.md and docs/agent-system.md

**Timing**: 45 minutes

**Depends on**: Phase 1 (references actual config file content)

**Files to create**:
- `docs/settings.md` -- configuration reference (~200-250 lines)

**Verification**:
- Every settings.json top-level key is documented
- Every keymap.json binding is listed with its action
- Cross-links resolve to actual file paths

---

### Phase 4: Agent System Bridge Documentation [NOT STARTED]

**Goal**: Create docs/agent-system.md as a thin bridge explaining the two AI systems and linking to .claude/ and .memory/ documentation.

**Tasks**:
- [ ] Write section: The Two AI Systems in Zed (built-in agent vs Claude Code via ACP)
- [ ] Write section: Starting Claude Code (Ctrl+?, first-use ACP install)
- [ ] Write section: Project Discovery (workspace root = working directory, single-folder requirement)
- [ ] Write section: Key Commands (3-4 examples with link to .claude/README.md for full list)
- [ ] Write section: The Memory Vault (what /learn does, link to .memory/README.md)
- [ ] Write section: Known Limitations (ACP vs terminal, multi-folder restriction, no markdown preview)
- [ ] Keep to ~100-150 lines; do not duplicate .claude/README.md content

**Timing**: 30 minutes

**Depends on**: Phase 2 (project-overview provides structural context)

**Files to create**:
- `docs/agent-system.md` -- agent system bridge (~100-150 lines)

**Verification**:
- Links to .claude/README.md and .memory/README.md are present
- No command reference duplication (only 3-4 examples)
- Built-in vs Claude Code distinction is clear

---

### Phase 5: Office Workflows and README Hub [NOT STARTED]

**Goal**: Create docs/office-workflows.md for Linux-native file handling, and README.md as the navigation hub tying everything together.

**Tasks**:
- [ ] Write `docs/office-workflows.md` covering:
  - LibreOffice integration via tasks.json
  - MCP servers for Office files (SuperDoc for DOCX, openpyxl for XLSX)
  - PDF handling (no native preview; use external tools)
  - /convert, /table, /slides, /scrape commands from filetypes extension
- [ ] Write `README.md` as navigation hub:
  - Quick start section (open project, install extensions, key shortcuts)
  - Directory layout overview
  - Links to each docs/ file with one-line descriptions
  - Links to .claude/CLAUDE.md and .memory/ README
  - Platform note (NixOS, binary is `zeditor`)
- [ ] Verify all cross-links between docs are bidirectional

**Timing**: 45 minutes

**Depends on**: Phase 3 (settings docs), Phase 4 (agent system docs)

**Files to create**:
- `docs/office-workflows.md` -- Linux Office workflows (~100-150 lines)
- `README.md` -- navigation hub (~150-200 lines)

**Verification**:
- README.md links to all 3 docs/ files and they exist
- docs/office-workflows.md references tasks.json entries
- All internal links use relative paths and resolve correctly
- README quick start is actionable (open, configure, verify)

## Testing & Validation

- [ ] All JSON files parse without errors (`python3 -m json.tool`)
- [ ] No Neovim/nvim references remain in project-overview.md
- [ ] All cross-links between README.md, docs/*, and .claude/ files resolve
- [ ] Documentation uses present tense, active voice consistently
- [ ] Word counts stay within targets (settings ~250, agent-system ~150, office ~150, README ~200)
- [ ] No duplication of .claude/README.md command reference
- [ ] Platform references use NixOS conventions (zeditor, Ctrl not Cmd)

## Artifacts & Outputs

- `settings.json` -- Zed editor settings
- `keymap.json` -- Custom keybindings
- `tasks.json` -- Task runner definitions
- `.claude/context/repo/project-overview.md` -- Rewritten for Zed
- `docs/settings.md` -- Configuration reference
- `docs/agent-system.md` -- Agent system bridge
- `docs/office-workflows.md` -- Linux Office workflows
- `README.md` -- Navigation hub

## Rollback/Contingency

All files are new creations except project-overview.md. If implementation fails:
- Delete created files (settings.json, keymap.json, tasks.json, docs/, README.md)
- Restore project-overview.md from git (`git checkout -- .claude/context/repo/project-overview.md`)
- Task returns to [PLANNED] status for retry
