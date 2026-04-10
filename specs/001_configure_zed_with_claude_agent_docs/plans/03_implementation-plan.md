# Implementation Plan: Configure Zed with Claude Agent Documentation (v3)

- **Task**: 1 - configure_zed_with_claude_agent_docs
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/001_configure_zed_with_claude_agent_docs/reports/03_team-research.md
- **Artifacts**: plans/03_implementation-plan.md (this file)
- **Standards**: .claude/rules/artifact-formats.md, .claude/rules/state-management.md, .claude/rules/plan-format-enforcement.md
- **Type**: general
- **Lean Intent**: false

## Overview

Configure Zed editor with Scheme A (minimal) keybindings, no vim mode, and collaborator-friendly documentation. This is a v3 plan replacing v2 which assumed vim mode. The keymap.json serves dual purpose: functional config AND default keybinding reference via comments. A new keybindings guide targets a non-coder collaborator. Definition of done: Zed opens with correct theme/agent config, keymap.json documents both custom and default bindings, and a keybindings guide explains everyday usage for a non-technical collaborator.

### Research Integration

Round 3 research confirmed: (1) markdown preview EXISTS in Zed (Ctrl+K V), correcting prior rounds; (2) only 6 custom bindings needed for Scheme A (4 pane nav + 2 line move); (3) Zed defaults already cover file finder, project search, explorer, terminal, agent panel, and all LSP actions; (4) Ctrl+K as pane-up may conflict with Zed chord prefix -- needs live testing.

## Goals & Non-Goals

**Goals**:
- Write settings.json without vim_mode, with theme, agent, languages, context_servers, auto_install_extensions
- Write keymap.json with Scheme A (6 bindings) plus inline comment sections showing important Zed defaults
- Write tasks.json with LibreOffice, Export, Git Status tasks
- Create docs/guides/keybindings.md for non-coder collaborator (file nav, Claude Code, basic editing)
- Rewrite .claude/context/repo/project-overview.md for Zed (currently describes Neovim)
- Update docs/settings.md documenting configuration choices (no vim references)
- Create docs/agent-system.md as thin bridge to .claude/ and .memory/
- Create docs/office-workflows.md for Linux-native Office file workflows
- Create README.md as navigation hub

**Non-Goals**:
- Vim mode, vim keybindings, or space-leader patterns
- Coding-focused documentation (LSP, debugging, refactoring)
- Scheme B or Scheme C bindings (start minimal, add later)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Ctrl+K intercepted as chord prefix (blocks pane-up) | M | M | Note in docs; fallback to Ctrl+Alt+Up if confirmed |
| Ctrl+H conflicts with find-replace in Editor context | L | L | Context scoping resolves: Workspace=pane nav, Editor=find-replace |
| JSONC comments not supported in Zed config | M | L | Use separate comment blocks or // if supported; fall back to docs-only reference |
| Keybindings guide too technical for collaborator | M | M | Review language for jargon; use task-oriented headings ("How to open a file") |
| MCP servers (SuperDoc, openpyxl) not activating | M | L | Document as "requires npx"; test after settings.json creation; note in docs |
| One Dark theme not built-in in this Zed version | L | L | Verify at launch; fall back to "One Dark Pro" extension if needed |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4 | 1 |
| 3 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Configuration Files [NOT STARTED]

**Goal**: Create settings.json, keymap.json (with default reference comments), and tasks.json.

**Tasks**:
- [ ] Create `settings.json` with: theme (One Dark), font settings, agent block (not assistant), languages block, context_servers (SuperDoc, openpyxl), auto_install_extensions (including Claude Code-relevant extensions), no vim_mode
- [ ] Include in auto_install_extensions: markdown-oxide, markdownlint, codebook, csv, context7-mcp (live library docs for Claude Code), markitdown-mcp (Office-to-Markdown for Claude Code)
- [ ] Create `keymap.json` with Scheme A bindings (6 custom) in proper context blocks
- [ ] Add comment sections in keymap.json showing important Zed default keybindings organized by category (File Ops, Navigation, Panels, Search, Agent/AI, Editing, Git, Markdown)
- [ ] Create `tasks.json` with LibreOffice open, Export Agent System, Git Status tasks
- [ ] Validate all JSON files parse correctly

**Timing**: 45 minutes

**Depends on**: none

**Files to create**:
- `settings.json` -- Zed editor settings (no vim)
- `keymap.json` -- Scheme A custom bindings + default reference
- `tasks.json` -- task runner definitions

**Verification**:
- All three files parse as valid JSON/JSONC
- settings.json contains no vim_mode: true, no vim block, no relative_line_numbers
- auto_install_extensions includes context7-mcp and markitdown-mcp alongside markdown/editing extensions
- Verify One Dark theme loads (check Zed appearance after launch)
- keymap.json has exactly 2 context blocks (Workspace with 4 bindings, Editor with 2 bindings)
- keymap.json contains reference comments for defaults

---

### Phase 2: Project Overview Rewrite [NOT STARTED]

**Goal**: Replace the Neovim-focused project-overview.md with an accurate Zed description.

**Tasks**:
- [ ] Read current `.claude/context/repo/project-overview.md`
- [ ] Rewrite to describe Zed configuration repository: purpose, technology stack (Zed, JSON config, NixOS), directory structure
- [ ] Include development workflow (standard and AI-assisted), common tasks, verification commands
- [ ] Reference docs/ directory and .claude/ system
- [ ] Ensure no references to Neovim, Lua, lazy.nvim, or nvim remain

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/context/repo/project-overview.md` -- full rewrite

**Verification**:
- Zero references to Neovim, Lua, lazy.nvim, nvim
- Directory structure matches actual repository layout
- Verification commands use `zeditor` (NixOS binary name)

---

### Phase 3: Keybindings Guide for Collaborator [NOT STARTED]

**Goal**: Create a task-oriented keybindings guide targeting a non-coder who uses Zed for file navigation and heavy Claude Code usage.

**Tasks**:
- [ ] Create `docs/guides/` directory
- [ ] Write `docs/guides/keybindings.md` with task-oriented sections:
  - Opening and saving files (Ctrl+P, Ctrl+S, Ctrl+Alt+S)
  - Navigating tabs and panes (Ctrl+Tab, Ctrl+W, Ctrl+H/J/K/L custom)
  - Using the file explorer (Ctrl+Shift+E, Ctrl+B)
  - Using Claude Code agent panel (Ctrl+?, Ctrl+N, Ctrl+Enter, Ctrl+;)
  - Basic text editing (Ctrl+Z/Y, Ctrl+C/X/V, Ctrl+F, Alt+J/K custom)
  - Search across files (Ctrl+Shift+F)
  - Using the terminal (Ctrl+`)
  - Markdown preview (Ctrl+K V)
- [ ] Use plain language, no jargon; organize by "How do I..." tasks
- [ ] Include a quick reference table at the top with the 15 most-used shortcuts
- [ ] Note which bindings are custom (marked with asterisk) vs Zed defaults

**Timing**: 30 minutes

**Depends on**: Phase 1 (needs final keymap.json to reference accurately)

**Files to create**:
- `docs/guides/keybindings.md` -- collaborator keybinding guide (~150-200 lines)

**Verification**:
- No coding-specific shortcuts (LSP, debugging, refactoring)
- All referenced shortcuts match keymap.json or Zed defaults
- Language is accessible to non-technical user
- Custom bindings clearly distinguished from defaults

---

### Phase 4: Settings and Agent Documentation [NOT STARTED]

**Goal**: Create docs/settings.md (configuration reference), docs/agent-system.md (bridge to .claude/), and docs/office-workflows.md (Linux Office workflows).

**Tasks**:
- [ ] Write `docs/settings.md` covering settings.json structure section by section (no vim references)
- [ ] Document the Scheme A keybinding rationale and how to add more bindings later
- [ ] Include reference to docs/guides/keybindings.md for the full shortcut guide
- [ ] Write `docs/agent-system.md` covering: Two AI Systems (built-in agent vs Claude Code via ACP), Starting Claude Code, Project Discovery, Key Commands (3-4 examples), Memory Vault, Known Limitations
- [ ] Write `docs/office-workflows.md` covering: LibreOffice integration via tasks.json, MCP servers for Office files, PDF handling, /convert /table /slides /scrape commands
- [ ] Cross-link all docs files to each other and to README.md

**Timing**: 45 minutes

**Depends on**: Phase 1 (references config file content)

**Files to create**:
- `docs/settings.md` -- configuration reference (~150-200 lines)
- `docs/agent-system.md` -- agent system bridge (~100-150 lines)
- `docs/office-workflows.md` -- Linux Office workflows (~100-150 lines)

**Verification**:
- No vim references in settings.md
- docs/agent-system.md links to .claude/README.md and .memory/README.md without duplicating content
- docs/office-workflows.md references tasks.json entries
- All cross-links resolve

---

### Phase 5: README Hub and Final Cross-Linking [NOT STARTED]

**Goal**: Create README.md as the navigation hub and verify all cross-links between documents.

**Tasks**:
- [ ] Write `README.md` with:
  - Quick start section (open project, auto-install extensions, key shortcuts for collaborator)
  - Directory layout overview
  - Links to each docs/ file with one-line descriptions
  - Links to docs/guides/keybindings.md prominently
  - Links to .claude/CLAUDE.md and .memory/ README
  - Platform note (NixOS, binary is `zeditor`)
  - "Adding More Keybindings" section pointing to keymap.json comments
- [ ] Verify all cross-links between docs are bidirectional
- [ ] Verify all internal links use relative paths and resolve correctly

**Timing**: 30 minutes

**Depends on**: Phase 2 (project-overview), Phase 3 (keybindings guide), Phase 4 (docs files)

**Files to create**:
- `README.md` -- navigation hub (~150-200 lines)

**Verification**:
- README.md links to all docs/ files and they exist
- All internal links use relative paths
- Quick start is actionable for non-technical collaborator
- No vim references

## Testing & Validation

- [ ] All JSON files parse without errors (`python3 -m json.tool`)
- [ ] No Neovim/nvim/vim references in any created file (except project-overview history context if needed)
- [ ] All cross-links between README.md, docs/*, and .claude/ files resolve
- [ ] Documentation uses present tense, active voice, plain language
- [ ] Keybindings guide is accessible to non-coder audience
- [ ] keymap.json contains both functional bindings and default reference
- [ ] settings.json contains no vim_mode: true, no vim block
- [ ] Platform references use NixOS conventions (zeditor, Ctrl not Cmd)

## Artifacts & Outputs

- `settings.json` -- Zed editor settings (no vim)
- `keymap.json` -- Scheme A custom bindings + default keybinding reference
- `tasks.json` -- Task runner definitions
- `.claude/context/repo/project-overview.md` -- Rewritten for Zed
- `docs/guides/keybindings.md` -- Collaborator keybinding guide
- `docs/settings.md` -- Configuration reference
- `docs/agent-system.md` -- Agent system bridge
- `docs/office-workflows.md` -- Linux Office workflows
- `README.md` -- Navigation hub

## Rollback/Contingency

All files are new creations except project-overview.md. If implementation fails:
- Delete created files (settings.json, keymap.json, tasks.json, docs/guides/, README.md)
- Restore project-overview.md from git (`git checkout -- .claude/context/repo/project-overview.md`)
- Task returns to [PLANNED] status for retry
