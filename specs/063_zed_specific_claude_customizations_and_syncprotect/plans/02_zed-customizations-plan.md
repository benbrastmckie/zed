# Implementation Plan: Task #63 (Revised v2)

- **Task**: 63 - Create zed-specific .claude/ customizations and .syncprotect file
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/063_zed_specific_claude_customizations_and_syncprotect/reports/01_zed-customizations-audit.md, specs/063_zed_specific_claude_customizations_and_syncprotect/reports/02_docs-update-audit.md
- **Artifacts**: plans/02_zed-customizations-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This revised plan addresses seven areas of zed-specific customization. The original five phases from v1 are preserved: project-overview.md rewrite, CLAUDE.md leader-ac fixes, git-workflow.md verification, agents/README.md recreation, and .syncprotect creation. Round-2 research (02_docs-update-audit.md) identified that 61 files changed in .claude/ since the last stable baseline, affecting user-facing documentation in docs/ and README.md. Two new phases are added: updating docs/ files (4 files with substantive changes) and updating root README.md.

### Research Integration

- **01_zed-customizations-audit.md** (integrated in plan v1): Complete audit of zed .claude/ files identifying project-overview.md as entirely wrong, CLAUDE.md needing leader-ac updates, git-workflow.md as byte-identical to nvim, agents/README.md deleted, and .syncprotect scope.
- **02_docs-update-audit.md** (integrated in plan v2): Audit of .claude/ changes since task 56 baseline identifying 4 docs files and README.md needing updates for slide-critic system addition, Co-Authored-By removal, artifact-linking pattern change, and pymupdf tool priority.

### Prior Plan Reference

plans/01_zed-customizations-plan.md (v1, 5 phases, 2.5 hours)

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Replace project-overview.md with accurate Zed editor configuration documentation
- Update CLAUDE.md `<leader>ac` references to describe zed's extension loading mechanism
- Recreate agents/README.md with accurate listing of all 30 agents organized by source
- Create .syncprotect to protect zed-customized files from sync overwrite
- Update docs/agent-system/README.md to remove stale Co-Authored-By deviation and add slide-critic
- Update docs/agent-system/commands.md to add --critic flag and fix slides routing description
- Update docs/agent-system/architecture.md to fix skill/agent counts and remove Co-Authored-By reference
- Update docs/workflows/grant-development.md to add slide critique step
- Update README.md to mention --critic flag for /slides

**Non-Goals**:
- Editing extension-managed sections of CLAUDE.md (inside `<!-- SECTION: extension_* -->` blocks)
- Fixing the nvim path reference in .claude/settings.json line 87 (separate task)
- Modifying git-workflow.md (already byte-identical to nvim canonical)
- Adding VimTeX replacement content (extension-managed, out of scope)
- Updating docs/workflows/convert-documents.md for pymupdf (no user-facing tool references exist there)
- Replacing hardcoded counts in architecture.md with approximate language (out of scope -- just update the numbers)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Editing inside extension comment markers in CLAUDE.md | H | L | Only edit core section (lines 1-345); verify changes are outside `<!-- SECTION -->` blocks |
| .syncprotect format not recognized by sync script | M | L | Verify sync script reads .syncprotect before creating; use simple one-file-per-line format |
| project-overview.md missing details about repo structure | M | L | Use research report's detailed directory audit as source of truth |
| Docs updates introduce incorrect cross-references | M | L | Verify all internal links after editing; check referenced files exist |
| Skill/agent counts drift again after future syncs | L | H | Update to current counts; accept they may need future updates |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4 | -- |
| 2 | 5, 6, 7 | 2 (phase 5 needs CLAUDE.md done first; phases 6-7 reference current state of .claude/) |

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
- [ ] Categorize each agent by source: core (7 agents), epidemiology extension (2), filetypes extension (5+1 router), latex extension (2), present extension (8), python extension (2), typst extension (2)
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

---

### Phase 6: Update docs/ files for .claude/ changes [NOT STARTED]

**Goal**: Update 4 documentation files in docs/ to reflect .claude/ changes identified in the round-2 research audit (slide-critic addition, Co-Authored-By removal, updated counts, slides routing change).

**Tasks**:
- [ ] **docs/agent-system/README.md** (HIGH priority):
  - Remove or update line 70 "No Co-Authored-By trailer" from "Zed adaptations" section (deviation is now moot -- upstream removed it too)
  - Add `skill-slide-critic` / `slide-critic-agent` to the extensions list alongside existing slide-planning entry
  - Add `/slides N --critic` command mention
- [ ] **docs/agent-system/commands.md** (MEDIUM priority):
  - Update `/plan` routing note: change `present:slides` to `present` with `slides` subtype
  - Add `--critic` flag documentation to the `/slides` section, describing three input modes (task+rubric, task+prompt, standalone file)
- [ ] **docs/agent-system/architecture.md** (LOW priority):
  - Update skill router count (was "32", now at least 33 with skill-slide-critic)
  - Update agent specification count (slide-critic-agent added, agents/README.md deleted -- verify exact count)
  - Remove or rewrite the Co-Authored-By trailer omission sentence at line 83
- [ ] **docs/workflows/grant-development.md** (MEDIUM priority):
  - Add a note about `/slides N --critic` critique step in the slides workflow lifecycle section (after implementation, before finalization)

**Timing**: 1.25 hours

**Depends on**: 2 (needs CLAUDE.md current state as reference for accuracy)

**Files to modify**:
- `docs/agent-system/README.md`
- `docs/agent-system/commands.md`
- `docs/agent-system/architecture.md`
- `docs/workflows/grant-development.md`

**Verification**:
- No references to "No Co-Authored-By" remain as a zed deviation
- Skill/agent counts are accurate (verify with `ls .claude/skills/ | wc -l` and `ls .claude/agents/*.md | wc -l`)
- `/slides --critic` is documented in commands.md
- All internal links in modified files still resolve

---

### Phase 7: Update root README.md [NOT STARTED]

**Goal**: Update the root README.md to mention the --critic flag for /slides command.

**Tasks**:
- [ ] Read current README.md to locate the /slides command description (research identified line 129)
- [ ] Update the /slides description to mention the `--critic` flag for interactive slide critique
- [ ] Verify no other stale references exist in README.md

**Timing**: 0.25 hours

**Depends on**: 2 (needs CLAUDE.md current state as reference)

**Files to modify**:
- `README.md` - Update /slides command description

**Verification**:
- /slides entry mentions --critic flag
- No broken links or stale references in README.md

## Testing & Validation

- [ ] project-overview.md describes Zed editor configuration, not Neovim
- [ ] CLAUDE.md has no `<leader>ac` references in core section (lines 1-345)
- [ ] CLAUDE.md extension sections unchanged (diff only shows core section changes)
- [ ] git-workflow.md unchanged
- [ ] agents/README.md exists and lists all agents in `.claude/agents/`
- [ ] `.claude/.syncprotect` exists and contains CLAUDE.md
- [ ] docs/agent-system/README.md "Zed adaptations" no longer lists Co-Authored-By as a deviation
- [ ] docs/agent-system/commands.md includes --critic flag for /slides
- [ ] docs/agent-system/architecture.md has updated skill/agent counts
- [ ] docs/workflows/grant-development.md mentions /slides --critic in slides workflow
- [ ] README.md /slides entry mentions --critic
- [ ] All modified files are valid markdown
- [ ] All internal documentation links resolve

## Artifacts & Outputs

- `.claude/context/repo/project-overview.md` - Rewritten for Zed
- `.claude/CLAUDE.md` - Updated core section (3 line replacements)
- `.claude/agents/README.md` - Recreated agent listing
- `.claude/.syncprotect` - New sync protection file
- `docs/agent-system/README.md` - Updated Zed adaptations and slide-critic
- `docs/agent-system/commands.md` - Added --critic flag, updated slides routing
- `docs/agent-system/architecture.md` - Updated counts, removed Co-Authored-By reference
- `docs/workflows/grant-development.md` - Added slide critique step
- `README.md` - Updated /slides description
- `specs/063_zed_specific_claude_customizations_and_syncprotect/plans/02_zed-customizations-plan.md` - This plan

## Rollback/Contingency

All changes are to tracked files in git. If implementation fails:
- `git checkout -- .claude/context/repo/project-overview.md` to restore original
- `git checkout -- .claude/CLAUDE.md` to restore original
- `git rm .claude/agents/README.md` and `git rm .claude/.syncprotect` to remove new files
- `git checkout -- docs/agent-system/README.md docs/agent-system/commands.md docs/agent-system/architecture.md docs/workflows/grant-development.md README.md` to restore docs
- Phase 3 requires no rollback (no changes made)
