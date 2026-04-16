---
next_project_number: 69
---

# Task List

## Tasks

### 68. Design self-learning memory system with automatic capture and retrieval
- **Effort**: large
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**:
  - [01_team-research.md](specs/068_self_learning_memory_system/reports/01_team-research.md)
  - [068_self_learning_memory_system/reports/02_memory-index-design.md]
- **Plan**:
  - [068_self_learning_memory_system/plans/01_memory-system-plan.md]
  - [068_self_learning_memory_system/plans/02_memory-system-plan.md]
- **Summary**: [068_self_learning_memory_system/summaries/02_memory-system-summary.md]

**Description**: Design a self-learning memory system that automatically captures useful knowledge at lifecycle checkpoints (implementation completion, /todo archival, /review runs, /research completion) and automatically retrieves relevant memories during agent operations without requiring the --remember flag. Research best practices for AI memory systems, study the current .memory/ vault and skill-memory architecture, and design an optimization that: (1) integrates learning steps into lifecycle commands (GATE OUT phases), (2) filters for genuinely useful repository knowledge vs noisy details, (3) enables automatic memory retrieval during research, planning, and implementation, and (4) ensures memories naturally guide agent behavior. The design should balance comprehensiveness with signal-to-noise ratio.

### 67. Remove non-interactive shortcuts from installation script except --dry-run and --check
- **Effort**: small
- **Status**: [COMPLETED]
- **Task Type**: general
- **Research**: [01_install-script-audit.md](specs/067_strip_install_script_shortcuts/reports/01_install-script-audit.md)
- **Plan**: [067_strip_install_script_shortcuts/plans/01_install-script-plan.md]
- **Summary**: [067_strip_install_script_shortcuts/summaries/01_install-script-summary.md]

**Description**: Remove all non-interactive shortcuts from the installation script except `--dry-run` and `--check`, updating the documentation accordingly and revising `README.md` line 18 to briefly state what each of these two retained flags does.

### 66. Update docs/ and README.md to reflect .claude/ refactoring
- **Effort**: medium
- **Effort**: medium
- **Status**: [RESEARCHED]
- **Task Type**: meta
- **Research**: [01_refactoring-diff-audit.md](specs/066_update_docs_readme_post_refactor/reports/01_refactoring-diff-audit.md)

**Description**: Update all relevant documentation in `docs/` and `README.md` to reflect the .claude/ directory refactoring: remove neovim-specific references, replace `<leader>ac` with "extension picker", genericize examples (nvim/lua/ paths to src/ paths, neovim task types to general), and fix any stale cross-references from deleted files (neovim-integration.md, tts-stt-integration.md).

### 65. Strip nvim/neovim references from 53 .claude/ files after sync reload
- **Effort**: large
- **Status**: [RESEARCHED]
- **Task Type**: meta
- **Research**: [01_nvim-reference-audit.md](specs/065_strip_nvim_references_post_sync/reports/01_nvim-reference-audit.md)

**Description**: 368 nvim/neovim occurrences across 53 `.claude/` files, plus 21 neotex and 19 `<leader>ac` references. The sync reload overwrote 8 of 9 `.syncprotect`-listed files (only `project-overview.md` survived via `CONTEXT_EXCLUDE_PATTERNS`, not `.syncprotect`). Root `CLAUDE.md` created by task 63 no longer exists. Full per-file audit in research report.

**Prerequisite -- Fix sync protection**: `.syncprotect` is not honored by the sync mechanism. Options: fix the loader, add a post-sync fixup script, or use git stash/restore around syncs. Without this, cleanup will be undone on next reload.

**Category A+ -- Re-contaminated (Critical, 8 files, 36 refs):** Syncprotected files the reload overwrote: `CLAUDE.md`, `README.md`, `commands/fix-it.md`, `commands/learn.md`, `commands/review.md`, `commands/task.md`, `skills/skill-orchestrator/SKILL.md`, `rules/plan-format-enforcement.md`.

**Category A -- Broken Config (Critical, 6 files, 30 refs):** Paths to nonexistent nvim directories. `extensions.json` (7 source_dir), `settings.local.json` (12 nvim path permissions), `settings.json` (SessionStart hook), `systemd/claude-refresh.service`, `commands/todo.md` (health metrics), `scripts/validate-wiring.sh`.

**Category B -- Incorrect Routing (High, 6 files, 12 refs):** Routes to nonexistent neovim agents/skills. `agents/meta-builder-agent.md`, `agents/code-reviewer-agent.md`, `agents/spawn-agent.md`, `skills/skill-fix-it/SKILL.md`, `context/architecture/system-overview.md`, `context/orchestration/orchestration-core.md`.

**Category C -- Neovim-Centric Guides (Medium, 6 files, ~106 refs):** Delete `neovim-integration.md` and `tts-stt-integration.md`. Rewrite `user-installation.md`, `copy-claude-directory.md`, `user-guide.md`, `adding-domains.md`.

**Category D -- Examples Using Neovim (Medium, 14 files, ~142 refs):** Replace `nvim/lua/` paths and neovim task types with Zed-appropriate examples across docs, standards, and context guides.

**Category E -- Template/Generic (Low, 14 files, ~42 refs):** Neovim in editor lists or generic templates. Replace where easy, defer rest.

**Also needed:** Recreate root `~/.config/zed/CLAUDE.md` (gone after reload). Replace 19 `<leader>ac` references with generic "extension loader" language across 10 files.

### 64. Narrow installation scripts and documentation to macOS-only, removing all Linux support
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: general
- **Research**: [01_macos-narrowing-audit.md](specs/064_narrow_install_to_macos_only/reports/01_macos-narrowing-audit.md)
- **Plan**: [01_macos-narrowing-plan.md](specs/064_narrow_install_to_macos_only/plans/01_macos-narrowing-plan.md)
- **Summary**: [01_macos-narrowing-summary.md](specs/064_narrow_install_to_macos_only/summaries/01_macos-narrowing-summary.md)

**Description**: Remove all Linux platform support (Debian/Ubuntu, Arch/Manjaro, NixOS detection, linux-unknown) from the installation wizard scripts (install.sh, lib.sh, install-base.sh, install-shell-tools.sh, install-python.sh, install-r.sh, install-typesetting.sh) and all associated documentation (docs/general/installation.md, docs/toolchain/README.md, README.md, project-overview.md). Simplify lib.sh platform detection to macOS-only, remove the cross-platform package name mapping (apt/pacman columns), remove Linux-specific features (Posit Package Manager configuration, systemd timer, AUR helper detection, /etc/os-release parsing), and update all docs to reference only macOS/Homebrew. Delete the systemd timer installer script. Retain the clean idempotent/interactive-step architecture but strip all multi-platform branching.

### 63. Create zed-specific .claude/ customizations and .syncprotect file
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**:
  - [01_zed-customizations-audit.md](specs/063_zed_specific_claude_customizations_and_syncprotect/reports/01_zed-customizations-audit.md)
  - [02_docs-update-audit.md](specs/063_zed_specific_claude_customizations_and_syncprotect/reports/02_docs-update-audit.md)
- **Plan**: [03_zed-customizations-plan.md](specs/063_zed_specific_claude_customizations_and_syncprotect/plans/03_zed-customizations-plan.md)
- **Summary**: [03_zed-customizations-summary.md](063_zed_specific_claude_customizations_and_syncprotect/summaries/03_zed-customizations-summary.md)
**Description**: Make the zed config repo's .claude/ files accurate and repo-specific, then protect them from future sync overwrites.

**Phase 1: Generate project-overview.md for zed repo**

The current `context/repo/project-overview.md` is a copy of the nvim template describing Lua, lazy.nvim, treesitter, etc. Replace it with an accurate overview of the zed config repo: settings.json, keymap.json, themes/, talks/, scripts/, docs/, examples/, prompts/, tasks.json, specs/. This file is already excluded from sync by CONTEXT_EXCLUDE_PATTERNS so no protection needed, but it's actively misleading agents.

**Phase 2: Update CLAUDE.md with zed-specific content**

Review the current CLAUDE.md against the nvim version (which is now canonical post-task 427). Decide what zed-specific additions are needed:
- The slide-critic entries (tasks 424-426) are already in the nvim version — accept those
- The slide-planner-agent rows were in the old zed version but removed from nvim — check if slide-planner-agent.md exists in this repo's agents/ and if so, re-add the table rows
- The Hooks section — check if `.claude/hooks/validate-plan-write.sh` exists in this repo; if so, document it; if not, omit the section
- Remove any stale Co-Authored-By references (task 427 cleaned these from nvim)

**Phase 3: Update rules/git-workflow.md**

Accept the nvim canonical version (Co-Authored-By notes removed by task 427). If the user wants a no-trailer policy for this repo, that belongs in Claude's auto-memory, not in a synced file.

**Phase 4: Recreate agents/README.md**

Generate a zed-specific agents/README.md listing the agents actually available in this repo's .claude/agents/ directory. README.md files are already skipped by sync, so this is inherently protected.

**Phase 5: Create .syncprotect file**

Create `.claude/.syncprotect` listing files that have zed-specific customizations. Only CLAUDE.md needs protection — git-workflow.md should accept upstream, README.md is already skip-protected, and project-overview.md is already excluded by CONTEXT_EXCLUDE_PATTERNS.

### 61. Revert task 60 implementation and restore slide-planner-agent references
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**: [01_revert-audit.md](specs/061_revert_task_60_restore_slide_planner/reports/01_revert-audit.md)
- **Plan**: [01_revert-plan.md](specs/061_revert_task_60_restore_slide_planner/plans/01_revert-plan.md)
- **Summary**: [01_revert-summary.md](specs/061_revert_task_60_restore_slide_planner/summaries/01_revert-summary.md)

**Description**: Revert task 60 implementation and restore slide-planner-agent references. Task 60 (commits 198c9270 through 41023fd4) incorrectly removed slide-planner-agent and skill-slide-planning references from docs/ and .claude/ files, treating them as stale. In reality, the removal from CLAUDE.md was a regression caused by the `<leader>ac` extension loader syncing a version of .claude/CLAUDE.md from the nvim config that didn't know about zed-specific present extension additions. Required actions: (1) Revert all commits from task 60 (198c9270..41023fd4 inclusive) -- 4 commits: research, plan, and 2 implementation commits; (2) Re-add slide-planner-agent and skill-slide-planning to the 4 CLAUDE.md documentation tables where commit 191655c3 removed them during the `<leader>ac` sync; (3) Verify the Co-Authored-By conflict resolution from task 60 phase 3 is also reverted; (4) Verify index.json, skill-slides/SKILL.md, and command files are restored to pre-task-60 state; (5) Run cross-reference verification to ensure CLAUDE.md tables, index.json agent arrays, and docs/ all consistently reference slide-planner-agent and skill-slide-planning

## Recommended Order

1. **65** [RESEARCHED] -> plan (independent)
