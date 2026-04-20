# Implementation Plan: Task #63 (Revised v3)

- **Task**: 63 - Create zed-specific .claude/ customizations and .syncprotect file
- **Status**: [COMPLETED]
- **Effort**: 5.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/063_zed_specific_claude_customizations_and_syncprotect/reports/01_zed-customizations-audit.md, specs/063_zed_specific_claude_customizations_and_syncprotect/reports/02_docs-update-audit.md
- **Artifacts**: plans/03_zed-customizations-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This v3 revision preserves the 7-phase structure from v2 but adds a cross-cutting requirement to every phase: all files touched must be scrubbed of NeoVim-specific, NixOS-specific, and `<leader>ac`-specific references. The zed repo is loaded by users on various systems and editors; content must be generic to the Claude Code agent system. The revision reason is that Zed does not have a `<leader>ac` picker -- that is a NeoVim keybinding irrelevant to this repository.

### Cross-Cutting Requirement: Strip Editor/OS-Specific References

Every phase that modifies files MUST scan for and remove or replace the following terms:

| Term | Replacement |
|------|-------------|
| `<leader>ac` | "loading extensions" or "the extension loader" (generic) |
| `neovim`, `nvim`, `Neovim` | Remove, or "editor" if generic context requires it |
| `NixOS`, `nix-shell`, `home-manager`, `nix` (as OS) | Remove, or use OS-neutral language |
| `lazy.nvim`, `treesitter`, `lspconfig`, `mason.nvim` | Remove entirely (nvim plugin references) |
| `lua/neotex/` paths | Remove (nvim internal paths) |
| `VimTeX`, `:VimtexCompile`, `<leader>lc`, etc. | Remove (nvim plugin references) |
| `nvim/lua/`, `nvim/` paths in examples | Replace with generic paths or zed-appropriate paths |
| `neovim-research-agent`, `neovim-implementation-agent` | Remove (these agents do not exist in zed) |
| `skill-neovim-research`, `skill-neovim-implementation` | Remove (these skills do not exist in zed) |
| `neovim-lua.md` rule references | Remove |

**Exception**: References inside `<!-- SECTION: extension_* -->` comment blocks in CLAUDE.md are managed by the extension loader and must NOT be edited manually.

**Exception**: The `.claude/CLAUDE.md.backup` and `.claude/settings.local.json.backup` files are backups and should not be modified.

### Research Integration

- **01_zed-customizations-audit.md** (integrated in plan v1): Complete audit of zed .claude/ files identifying project-overview.md as entirely wrong, CLAUDE.md needing leader-ac updates, git-workflow.md as byte-identical to nvim, agents/README.md deleted, and .syncprotect scope.
- **02_docs-update-audit.md** (integrated in plan v2): Audit of .claude/ changes since task 56 baseline identifying 4 docs files and README.md needing updates for slide-critic system addition, Co-Authored-By removal, updated counts, and slides routing change.
- **Revision reason** (integrated in plan v3): User directive to strip all NeoVim/NixOS/`<leader>ac` references from every file touched, producing content generic to the agent system.

### Prior Plan Reference

plans/01_zed-customizations-plan.md (v1, 5 phases, 2.5 hours)
plans/02_zed-customizations-plan.md (v2, 7 phases, 4 hours)

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Replace project-overview.md with accurate Zed editor configuration documentation (no nvim content)
- Update CLAUDE.md core section to remove all `<leader>ac`, nvim, and NixOS references
- Recreate agents/README.md with accurate listing of agents (excluding nvim-only agents)
- Create .syncprotect to protect zed-customized files from sync overwrite
- Update docs/ files to reflect .claude/ changes AND strip nvim/nix references
- Update README.md to be fully generic (no nvim/nix references)
- Strip nvim/nix/leader-ac references from .claude/README.md
- Strip nvim-specific examples from .claude/commands/fix-it.md
- Ensure all modified content is editor-agnostic and OS-neutral

**Non-Goals**:
- Editing extension-managed sections of CLAUDE.md (inside `<!-- SECTION: extension_* -->` blocks)
- Fixing the nvim path reference in .claude/settings.json line 87 (separate task)
- Modifying .claude/CLAUDE.md.backup or .claude/settings.local.json.backup (backup files)
- Modifying .claude/context/index.schema.json (schema file with nvim examples -- cosmetic, low risk)
- Replacing hardcoded counts in architecture.md with approximate language (just update the numbers)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Editing inside extension comment markers in CLAUDE.md | H | L | Only edit core section (lines 1-345); verify changes are outside `<!-- SECTION -->` blocks |
| Over-stripping removes valid references (e.g., "neovim" as a task_type value) | H | M | Task type values like `neovim` in routing tables should be kept if they describe extension capabilities; remove only where they describe THIS repo's setup |
| .syncprotect format not recognized by sync script | M | L | Verify sync script reads .syncprotect before creating; use simple one-file-per-line format |
| Docs updates introduce incorrect cross-references | M | L | Verify all internal links after editing; check referenced files exist |
| Stripping nvim references breaks fix-it.md examples | M | M | Replace nvim-specific examples with generic ones (e.g., `src/` paths instead of `nvim/lua/` paths) |
| Skill/agent counts drift again after future syncs | L | H | Update to current counts; accept they may need future updates |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4 | -- |
| 2 | 5, 6, 7 | 2 (phase 5 needs CLAUDE.md done first; phases 6-7 reference current state of .claude/) |

Phases within the same wave can execute in parallel.

### Phase 1: Generate project-overview.md [COMPLETED]

**Goal**: Replace the incorrect Neovim-focused project-overview.md with accurate Zed editor configuration documentation containing zero nvim/nix references.

**Tasks**:
- [ ] Read current `.claude/context/repo/project-overview.md` to understand existing structure
- [ ] Write new project-overview.md covering: Zed editor config repo purpose, directory structure (settings.json, keymap.json, tasks.json, docs/, examples/, talks/, scripts/, .zed/, .memory/, specs/, .claude/), technology stack (Zed editor, One Dark theme, Fira Code, R/Python/Markdown languages, Claude Code ACP integration), installed extensions, platform support
- [ ] **STRIP CHECK**: Verify the new file contains zero occurrences of: neovim, nvim, NixOS, nix-shell, home-manager, lazy.nvim, treesitter, lspconfig, mason.nvim, lua/neotex, VimTeX, `<leader>ac`
- [ ] Verify the new content matches the actual repo structure from the research audit

**Timing**: 0.75 hours

**Depends on**: none

**Files to modify**:
- `.claude/context/repo/project-overview.md` - Complete rewrite with zed-specific content

**Verification**:
- File describes Zed editor, not Neovim
- All major directories documented
- Technology stack accurate (Zed, ACP, pyright, ruff, r-language-server)
- `grep -ciE 'neovim|nvim|nix.?shell|home.manager|lazy\.nvim|treesitter|lspconfig|VimTeX|leader.ac' .claude/context/repo/project-overview.md` returns 0

---

### Phase 2: Update CLAUDE.md core section [COMPLETED]

**Goal**: Remove all `<leader>ac`, nvim-specific, and NixOS-specific references from the CLAUDE.md core section (lines 1-345), making it generic to the Claude Code agent system.

**Tasks**:
- [ ] Locate the 3 `<leader>ac` references (lines 73, 198, 291 in core section):
  - Line 73: "available when extensions are loaded via `<leader>ac`" -> "available when extensions are loaded via the extension loader"
  - Line 291: "Available when extensions are loaded via `<leader>ac`" -> "Available when extensions are loaded. Query `index.json` for extension-specific context files."
  - Note: Line 198 mentions `skill-neovim-research -> neovim-research-agent` as an example -- replace with a generic example like `skill-latex-research -> latex-research-agent`
- [ ] Line 75: Remove "neovim" from the task type list example, or replace with types actually available in zed (latex, typst, python, epi, present, etc.)
- [ ] Line 120: The `"task_type": "neovim"` example in state.json schema -- replace with `"task_type": "meta"` or another type that exists in zed
- [ ] Line 220: Remove "neovim-lua.md for Lua development" example -- replace with a generic example like "latex-standards.md for LaTeX development"
- [ ] Verify all replacements are outside `<!-- SECTION: extension_* -->` comment blocks
- [ ] **STRIP CHECK**: Run grep to confirm zero remaining occurrences of neovim/nvim/`<leader>ac` in core section (lines 1-345)
- [ ] Verify no NixOS/nix-shell/home-manager references exist in core section

**Timing**: 0.75 hours

**Depends on**: none

**Files to modify**:
- `.claude/CLAUDE.md` - Update core section (lines 1-345 only)

**Verification**:
- No `<leader>ac` references remain in core section
- No `neovim`/`nvim` references remain in core section (excluding extension-managed sections)
- Extension-managed sections untouched
- CLAUDE.md still parses correctly as markdown

---

### Phase 3: Accept nvim canonical git-workflow.md [COMPLETED]

**Goal**: Confirm git-workflow.md requires no changes and document the decision.

**Tasks**:
- [ ] Verify git-workflow.md is byte-identical to nvim canonical (already confirmed by research)
- [ ] **STRIP CHECK**: Verify git-workflow.md contains no nvim-specific content beyond the portable NixOS comment on line 105 (which says "works on NixOS, macOS, Linux" -- this is a platform compatibility note and is acceptable to keep as it describes broad compatibility, not a NixOS dependency)
- [ ] No file modifications needed -- this phase is a verification-only checkpoint

**Timing**: 0.1 hours

**Depends on**: none

**Files to modify**:
- (none -- accept upstream as-is)

**Verification**:
- git-workflow.md contains no Co-Authored-By references
- git-workflow.md contains no nvim-specific content

---

### Phase 4: Recreate agents/README.md [COMPLETED]

**Goal**: Create agents/README.md with an accurate listing of all agents organized by source (core vs extension), without nvim-specific agent references.

**Tasks**:
- [ ] List all .md files in `.claude/agents/` directory
- [ ] Categorize each agent by source: core (7 agents), epidemiology extension (2), filetypes extension (5+1 router), latex extension (2), present extension (8), python extension (2), typst extension (2)
- [ ] Write README.md with: header, purpose description, agent table organized by source with columns for agent name, purpose, and model
- [ ] **STRIP CHECK**: Do NOT include any nvim-specific agents (neovim-research-agent, neovim-implementation-agent) -- these do not exist in the zed agents/ directory. Only list agents that actually exist as files.
- [ ] Verify agent count matches what is actually in the directory

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `.claude/agents/README.md` - New file (recreate deleted README)

**Verification**:
- README lists all agents present in the directory
- Agents correctly categorized by source
- No nvim-specific agents listed
- No agents missing or duplicated

---

### Phase 5: Create .syncprotect file [COMPLETED]

**Goal**: Create .syncprotect file to prevent sync from overwriting zed-customized files. Include additional files that were customized in this task.

**Tasks**:
- [ ] Create `.claude/.syncprotect` with protected files list:
  - `CLAUDE.md` (core section customized to remove leader-ac/nvim references)
  - `context/repo/project-overview.md` (complete rewrite for zed)
  - `README.md` (.claude/README.md if customized)
  - `commands/fix-it.md` (if examples are replaced)
- [ ] Add a comment header explaining the file's purpose
- [ ] Verify the sync mechanism recognizes the .syncprotect format

**Timing**: 0.2 hours

**Depends on**: 2

**Files to modify**:
- `.claude/.syncprotect` - New file

**Verification**:
- File exists at `.claude/.syncprotect`
- Contains all zed-customized file paths
- Format is one file path per line with optional comment lines starting with `#`

---

### Phase 6: Update docs/ files and strip nvim/nix references [COMPLETED]

**Goal**: Update documentation files in docs/ to reflect .claude/ changes (slide-critic, Co-Authored-By removal, updated counts) AND strip all nvim/nix/leader-ac references found in docs/.

**Tasks**:
- [ ] **docs/agent-system/README.md** (HIGH priority):
  - Remove or update line 70 "No Co-Authored-By trailer" from "Zed adaptations" section
  - Add `skill-slide-critic` / `slide-critic-agent` to the extensions list
  - Add `/slides N --critic` command mention
- [ ] **docs/agent-system/commands.md** (MEDIUM priority):
  - Update `/plan` routing note: change `present:slides` to `present` with `slides` subtype
  - Add `--critic` flag documentation to the `/slides` section
- [ ] **docs/agent-system/architecture.md** (LOW priority):
  - Update skill router count (was "32", now at least 33 with skill-slide-critic)
  - Update agent specification count
  - Remove or rewrite the Co-Authored-By trailer omission sentence at line 83
- [ ] **docs/workflows/grant-development.md** (MEDIUM priority):
  - Add a note about `/slides N --critic` critique step in the slides workflow lifecycle section
- [ ] **docs/toolchain/README.md** -- STRIP nvim/nix references:
  - Line 13: NixOS installation wizard note -- rewrite to be OS-neutral or remove
  - Lines 99-105: Remove the "author's Neovim config repository" section and `~/.config/nvim/scripts/claude-ready-signal.sh` reference. Replace with a generic note that some hooks reference external scripts not included in this repo.
- [ ] **docs/toolchain/mcp-servers.md** -- STRIP nvim reference:
  - Line 175: Remove "Lean is a theorem-prover toolchain used in the author's Neovim config repo" -- rewrite to simply state Lean is not used in this repository
- [ ] **docs/toolchain/extensions.md** -- STRIP VimTeX reference:
  - Line 36: Replace "VimTeX-equivalent" with "equivalent" or "comparable"
- [ ] **docs/toolchain/typesetting.md** -- STRIP VimTeX references:
  - Line 28: Remove "VimTeX-equivalent workflows" language
  - Line 62: Remove "VimTeX workflows expect" language -- rewrite for generic LaTeX workflow
- [ ] **docs/general/installation.md** -- STRIP NixOS reference:
  - Line 7: Remove or generalize the NixOS detection note
- [ ] **STRIP CHECK**: After all edits, run grep across docs/ for: neovim, nvim, NixOS, nix-shell, home-manager, VimTeX, `<leader>ac`. Confirm zero matches (or only acceptable ones like "nix" in a generic package manager context).

**Timing**: 1.75 hours

**Depends on**: 2 (needs CLAUDE.md current state as reference for accuracy)

**Files to modify**:
- `docs/agent-system/README.md`
- `docs/agent-system/commands.md`
- `docs/agent-system/architecture.md`
- `docs/workflows/grant-development.md`
- `docs/toolchain/README.md`
- `docs/toolchain/mcp-servers.md`
- `docs/toolchain/extensions.md`
- `docs/toolchain/typesetting.md`
- `docs/general/installation.md`

**Verification**:
- No references to "No Co-Authored-By" remain as a zed deviation
- Skill/agent counts are accurate
- `/slides --critic` is documented in commands.md
- All internal links in modified files still resolve
- `grep -rciE 'neovim|nvim|VimTeX|<leader>ac' docs/` returns 0 (or only acceptable generic references)
- NixOS references removed or generalized

---

### Phase 7: Update root README.md and .claude/README.md [COMPLETED]

**Goal**: Update README.md to mention --critic flag and strip nvim/nix references. Update .claude/README.md to strip nvim-specific references.

**Tasks**:
- [ ] **README.md** (root):
  - Read current README.md to locate the /slides command description
  - Update the /slides description to mention the `--critic` flag
  - **STRIP CHECK**: Verify README.md contains no nvim/nix/leader-ac references
- [ ] **.claude/README.md**:
  - Line 113: Replace "`<leader>ac` keybinding" with "the extension loader" or "loading the extension system"
  - Line 119: Remove the `nvim | Neovim/Lua | neovim-research-agent, neovim-implementation-agent` row from the extensions table (these do not exist in zed)
  - Line 188: Remove or update "Neovim Integration" guide reference (check if the referenced file exists)
  - **STRIP CHECK**: Verify .claude/README.md contains no remaining nvim/nix/leader-ac references
- [ ] **.claude/commands/fix-it.md**:
  - Replace nvim-specific path examples (`nvim/lua/Layer1/Modal.lua`, `nvim/lua/config/lsp.lua`, etc.) with generic examples (`src/module/handler.py`, `lib/config.ts`, etc.)
  - Replace "neovim" task type references in examples with "general" or "meta"
  - Line 109: Replace `nvim/lua/, docs/` scan paths with generic paths
  - **STRIP CHECK**: Verify fix-it.md contains no remaining nvim-specific paths or references
- [ ] **.claude/skills/skill-orchestrator/SKILL.md**:
  - Remove the `neovim` row from the routing table (line 44)
  - Replace `"task_type": "neovim"` example (line 69) with a type that exists in zed
- [ ] **.claude/rules/plan-format-enforcement.md**:
  - Line 19: Replace `neovim` in the task_type example with types that exist in zed (e.g., "meta, general, latex, etc.")

**Timing**: 1.0 hours

**Depends on**: 2 (needs CLAUDE.md current state as reference)

**Files to modify**:
- `README.md` - Update /slides command description
- `.claude/README.md` - Strip nvim/leader-ac references
- `.claude/commands/fix-it.md` - Replace nvim-specific examples
- `.claude/skills/skill-orchestrator/SKILL.md` - Remove neovim routing
- `.claude/rules/plan-format-enforcement.md` - Update task_type example

**Verification**:
- /slides entry mentions --critic flag in README.md
- No nvim/nix/leader-ac references in .claude/README.md
- fix-it.md examples use generic paths
- skill-orchestrator routing table has no neovim row
- `grep -rciE 'neovim|nvim|<leader>ac' .claude/README.md .claude/commands/fix-it.md .claude/skills/skill-orchestrator/SKILL.md .claude/rules/plan-format-enforcement.md` returns 0

## Testing & Validation

- [ ] project-overview.md describes Zed editor configuration, not Neovim
- [ ] CLAUDE.md has no `<leader>ac` references in core section (lines 1-345)
- [ ] CLAUDE.md has no `neovim`/`nvim` references in core section
- [ ] CLAUDE.md extension sections unchanged (diff only shows core section changes)
- [ ] git-workflow.md unchanged
- [ ] agents/README.md exists and lists all agents in `.claude/agents/` (no nvim-only agents)
- [ ] `.claude/.syncprotect` exists and contains all customized file paths
- [ ] docs/agent-system/README.md "Zed adaptations" no longer lists Co-Authored-By as a deviation
- [ ] docs/agent-system/commands.md includes --critic flag for /slides
- [ ] docs/agent-system/architecture.md has updated skill/agent counts
- [ ] docs/workflows/grant-development.md mentions /slides --critic in slides workflow
- [ ] docs/toolchain/ files contain no nvim/VimTeX/NixOS references
- [ ] docs/general/installation.md contains no NixOS-specific language
- [ ] README.md /slides entry mentions --critic
- [ ] .claude/README.md contains no nvim/leader-ac references
- [ ] .claude/commands/fix-it.md uses generic examples (no nvim/ paths)
- [ ] .claude/skills/skill-orchestrator/SKILL.md has no neovim routing row
- [ ] All modified files are valid markdown
- [ ] All internal documentation links resolve
- [ ] **GLOBAL STRIP CHECK**: `grep -rciE 'neovim|<leader>ac' .claude/CLAUDE.md .claude/README.md .claude/commands/ .claude/skills/skill-orchestrator/ .claude/rules/plan-format-enforcement.md docs/ README.md .claude/context/repo/project-overview.md` returns 0 for all files (excluding extension-managed CLAUDE.md sections and backup files)

## Artifacts & Outputs

- `.claude/context/repo/project-overview.md` - Rewritten for Zed (no nvim content)
- `.claude/CLAUDE.md` - Updated core section (leader-ac, nvim, nix references removed)
- `.claude/agents/README.md` - Recreated agent listing (no nvim agents)
- `.claude/.syncprotect` - New sync protection file
- `.claude/README.md` - Stripped nvim/leader-ac references
- `.claude/commands/fix-it.md` - Generic examples replacing nvim-specific ones
- `.claude/skills/skill-orchestrator/SKILL.md` - Removed neovim routing
- `.claude/rules/plan-format-enforcement.md` - Updated task_type example
- `docs/agent-system/README.md` - Updated Zed adaptations and slide-critic
- `docs/agent-system/commands.md` - Added --critic flag, updated slides routing
- `docs/agent-system/architecture.md` - Updated counts, removed Co-Authored-By reference
- `docs/workflows/grant-development.md` - Added slide critique step
- `docs/toolchain/README.md` - Stripped nvim/nix references
- `docs/toolchain/mcp-servers.md` - Stripped nvim reference
- `docs/toolchain/extensions.md` - Stripped VimTeX reference
- `docs/toolchain/typesetting.md` - Stripped VimTeX references
- `docs/general/installation.md` - Stripped NixOS reference
- `README.md` - Updated /slides description
- `specs/063_zed_specific_claude_customizations_and_syncprotect/plans/03_zed-customizations-plan.md` - This plan

## Rollback/Contingency

All changes are to tracked files in git. If implementation fails:
- `git checkout -- .claude/context/repo/project-overview.md` to restore original
- `git checkout -- .claude/CLAUDE.md .claude/README.md` to restore originals
- `git checkout -- .claude/commands/fix-it.md .claude/skills/skill-orchestrator/SKILL.md .claude/rules/plan-format-enforcement.md` to restore originals
- `git rm .claude/agents/README.md` and `git rm .claude/.syncprotect` to remove new files
- `git checkout -- docs/` to restore all docs
- `git checkout -- README.md` to restore root README
- Phase 3 requires no rollback (no changes made)
