# Implementation Plan: Task #63

- **Task**: 63 - Create zed-specific .claude/ customizations and .syncprotect file
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/063_zed_specific_claude_customizations_and_syncprotect/reports/01_zed-customizations-audit.md
- **Artifacts**: plans/01_zed-customizations-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan addresses five areas of zed-specific customization identified by the research audit. The current project-overview.md incorrectly describes Neovim/Lua instead of Zed, CLAUDE.md contains three `<leader>ac` references that are nvim-specific, agents/README.md was deleted and needs recreation, and a .syncprotect file is needed to prevent sync from overwriting zed-customized files. git-workflow.md is byte-identical to nvim and requires no changes.

### Research Integration

The research report (01_zed-customizations-audit.md) provided a complete audit of the zed repo structure, identified that only project-overview.md and CLAUDE.md need substantive changes, confirmed git-workflow.md is identical to nvim canonical, catalogued all 30 agents in the directory, and recommended protecting only CLAUDE.md in .syncprotect.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Replace project-overview.md with accurate Zed editor configuration documentation
- Update CLAUDE.md `<leader>ac` references to describe zed's extension loading mechanism
- Recreate agents/README.md with accurate listing of all 30 agents organized by source
- Create .syncprotect to protect zed-customized files from sync overwrite

**Non-Goals**:
- Editing extension-managed sections of CLAUDE.md (inside `<!-- SECTION: extension_* -->` blocks)
- Fixing the nvim path reference in .claude/settings.json line 87 (separate task)
- Modifying git-workflow.md (already byte-identical to nvim canonical)
- Adding VimTeX replacement content (extension-managed, out of scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Editing inside extension comment markers in CLAUDE.md | H | L | Only edit core section (lines 1-345); verify changes are outside `<!-- SECTION -->` blocks |
| .syncprotect format not recognized by sync script | M | L | Verify sync script reads .syncprotect before creating; use simple one-file-per-line format |
| project-overview.md missing details about repo structure | M | L | Use research report's detailed directory audit as source of truth |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4 | -- |
| 2 | 5 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Generate project-overview.md [NOT STARTED]

**Goal**: Replace the incorrect Neovim-focused project-overview.md with accurate Zed editor configuration documentation.

**Tasks**:
- [ ] Read current `.claude/context/repo/project-overview.md` to understand existing structure
- [ ] Write new project-overview.md covering: Zed editor config repo purpose, directory structure (settings.json, keymap.json, tasks.json, docs/, examples/, talks/, scripts/, .zed/, .memory/, specs/, .claude/), technology stack (Zed editor, One Dark theme, Fira Code, R/Python/Markdown/Nix languages, Claude Code ACP integration), installed extensions, platform support
- [ ] Verify the new content matches the actual repo structure from the research audit

**Timing**: 0.75 hours

**Depends on**: none

**Files to modify**:
- `.claude/context/repo/project-overview.md` - Complete rewrite with zed-specific content

**Verification**:
- File describes Zed editor, not Neovim
- All major directories documented
- Technology stack accurate (Zed, ACP, pyright, ruff, r-language-server)

---

### Phase 2: Update CLAUDE.md with zed-specific content [NOT STARTED]

**Goal**: Replace the three `<leader>ac` references in the core section with zed-appropriate descriptions of extension loading.

**Tasks**:
- [ ] Locate the 3 `<leader>ac` references (research identified lines 73, 198, 291 in core section)
- [ ] Replace each with text describing zed's mechanism: extensions are loaded from the nvim extension source via the extension loader (no local `<leader>ac` keybinding in zed)
- [ ] Verify all replacements are outside `<!-- SECTION: extension_* -->` comment blocks
- [ ] Verify no other nvim-specific references remain in the core section

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `.claude/CLAUDE.md` - Update 3 `<leader>ac` references in core section (lines 1-345)

**Verification**:
- No `<leader>ac` references remain in core section
- Extension-managed sections untouched
- CLAUDE.md still parses correctly as markdown

---

### Phase 3: Accept nvim canonical git-workflow.md [NOT STARTED]

**Goal**: Confirm git-workflow.md requires no changes and document the decision.

**Tasks**:
- [ ] Verify git-workflow.md is byte-identical to nvim canonical (already confirmed by research)
- [ ] No file modifications needed -- this phase is a verification-only checkpoint

**Timing**: 0.1 hours

**Depends on**: none

**Files to modify**:
- (none -- accept upstream as-is)

**Verification**:
- git-workflow.md contains no Co-Authored-By references
- git-workflow.md contains no nvim-specific content

---

### Phase 4: Recreate agents/README.md [NOT STARTED]

**Goal**: Create agents/README.md with an accurate listing of all 30 agents organized by source (core vs extension).

**Tasks**:
- [ ] List all .md files in `.claude/agents/` directory
- [ ] Categorize each agent by source: core (7 agents), epidemiology extension (2), filetypes extension (5), latex extension (2), present extension (8), python extension (2), typst extension (2), memory extension (0 agents, skill only), slide-planner (1), slide-critic (1)
- [ ] Write README.md with: header, purpose description, agent table organized by source with columns for agent name, purpose, and model
- [ ] Verify agent count matches the 30 identified in research

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `.claude/agents/README.md` - New file (recreate deleted README)

**Verification**:
- README lists all agents present in the directory
- Agents correctly categorized by source
- No agents missing or duplicated

---

### Phase 5: Create .syncprotect file [NOT STARTED]

**Goal**: Create .syncprotect file to prevent sync from overwriting zed-customized files.

**Tasks**:
- [ ] Create `.claude/.syncprotect` with CLAUDE.md as the protected file
- [ ] Add a comment header explaining the file's purpose
- [ ] Verify the sync mechanism recognizes the .syncprotect format (check nvim sync scripts if accessible)

**Timing**: 0.15 hours

**Depends on**: 2

**Files to modify**:
- `.claude/.syncprotect` - New file

**Verification**:
- File exists at `.claude/.syncprotect`
- Contains `CLAUDE.md` entry
- Format is one file path per line with optional comment lines starting with `#`

## Testing & Validation

- [ ] project-overview.md describes Zed editor configuration, not Neovim
- [ ] CLAUDE.md has no `<leader>ac` references in core section (lines 1-345)
- [ ] CLAUDE.md extension sections unchanged (diff only shows core section changes)
- [ ] git-workflow.md unchanged
- [ ] agents/README.md exists and lists all agents in `.claude/agents/`
- [ ] `.claude/.syncprotect` exists and contains CLAUDE.md
- [ ] All modified files are valid markdown

## Artifacts & Outputs

- `.claude/context/repo/project-overview.md` - Rewritten for Zed
- `.claude/CLAUDE.md` - Updated core section (3 line replacements)
- `.claude/agents/README.md` - Recreated agent listing
- `.claude/.syncprotect` - New sync protection file
- `specs/063_zed_specific_claude_customizations_and_syncprotect/plans/01_zed-customizations-plan.md` - This plan

## Rollback/Contingency

All changes are to `.claude/` files tracked in git. If implementation fails:
- `git checkout -- .claude/context/repo/project-overview.md` to restore original
- `git checkout -- .claude/CLAUDE.md` to restore original
- `git rm .claude/agents/README.md` and `git rm .claude/.syncprotect` to remove new files
- Phase 3 requires no rollback (no changes made)
