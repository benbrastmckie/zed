---
next_project_number: 64
---

# Task List

## Tasks

### 63. Create zed-specific .claude/ customizations and .syncprotect file
- **Effort**: medium
- **Status**: [RESEARCHED]
- **Task Type**: meta
- **Research**:
  - [01_zed-customizations-audit.md](specs/063_zed_specific_claude_customizations_and_syncprotect/reports/01_zed-customizations-audit.md)
  - [02_docs-update-audit.md](specs/063_zed_specific_claude_customizations_and_syncprotect/reports/02_docs-update-audit.md)
- **Plan**: [01_zed-customizations-plan.md](specs/063_zed_specific_claude_customizations_and_syncprotect/plans/01_zed-customizations-plan.md)
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

1. **61** -> research (independent)
2. **62** -> research (independent)
