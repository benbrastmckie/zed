---
next_project_number: 62
---

# Task List

## Tasks

### 61. Revert task 60 implementation and restore slide-planner-agent references
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**: [01_revert-audit.md](specs/061_revert_task_60_restore_slide_planner/reports/01_revert-audit.md)
- **Plan**: [01_revert-plan.md](specs/061_revert_task_60_restore_slide_planner/plans/01_revert-plan.md)
- **Summary**: [01_revert-summary.md](specs/061_revert_task_60_restore_slide_planner/summaries/01_revert-summary.md)

**Description**: Revert task 60 implementation and restore slide-planner-agent references. Task 60 (commits 198c9270 through 41023fd4) incorrectly removed slide-planner-agent and skill-slide-planning references from docs/ and .claude/ files, treating them as stale. In reality, the removal from CLAUDE.md was a regression caused by the `<leader>ac` extension loader syncing a version of .claude/CLAUDE.md from the nvim config that didn't know about zed-specific present extension additions. Required actions: (1) Revert all commits from task 60 (198c9270..41023fd4 inclusive) -- 4 commits: research, plan, and 2 implementation commits; (2) Re-add slide-planner-agent and skill-slide-planning to the 4 CLAUDE.md documentation tables where commit 191655c3 removed them during the `<leader>ac` sync; (3) Verify the Co-Authored-By conflict resolution from task 60 phase 3 is also reverted; (4) Verify index.json, skill-slides/SKILL.md, and command files are restored to pre-task-60 state; (5) Run cross-reference verification to ensure CLAUDE.md tables, index.json agent arrays, and docs/ all consistently reference slide-planner-agent and skill-slide-planning

### 60. Update documentation to reflect .claude/ directory changes
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: meta

**Description**: Update all relevant documentation to reflect .claude/ changes: removed slide-planner-agent and skill-slide-planning, removed PostToolUse hooks section, rewrote document-agent.md, restructured index.json and extensions.json, updated filetypes extension docs (conversion-tables.md, dependency-guide.md, tool-detection.md), and updated git-workflow rules. Ensure all cross-references, READMEs, and standards docs are consistent with these changes

## Recommended Order

1. **61** -> research (independent)
