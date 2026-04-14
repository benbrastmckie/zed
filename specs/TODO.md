---
next_project_number: 63
---

# Task List

## Tasks

### 62. Triage and selectively apply working tree changes synced from nvim config
- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: meta

**Description**: The `<leader>ac` extension loader has synced .claude/ files from the nvim config, producing working tree changes that are a mix of genuine improvements and regressions. This is the same pattern that caused task 60 (which was reverted by task 61). Changes must be triaged into two groups:

**DISCARD (regressions from nvim sync not knowing about zed-specific additions):**
- CLAUDE.md: Removal of slide-planner-agent/skill-slide-planning from 3 tables (skill-agent mapping, agents table, present extension skill mapping)
- CLAUDE.md: Removal of Hooks section (validate-plan-write.sh)
- CLAUDE.md: Changing `present:slides` task type to `present`/`slides` (zed uses compound routing)
- agents/README.md: Removal of slide-planner-agent row and extension note
- git-workflow.md: Removal of "omit Co-Authored-By" user preference note (zed repo preference differs from nvim)
- index.json / extensions.json: Key reordering only (cosmetic churn, no semantic value)

**KEEP (genuine improvements to selectively commit):**
- document-agent.md: pymupdf as primary PDF/EPUB/Image conversion tool (valid improvement, was collateral damage in task 60 revert)
- 3 filetypes context files (conversion-tables.md, dependency-guide.md, tool-detection.md): pymupdf additions to fallback chains and dependency tables
- 7 skills (researcher, planner, implementer, reviser, team-research, team-plan, team-implement): Replace inline Edit-based artifact linking with link-artifact-todo.sh script call
- artifact-linking-todo.md: Updated note about script automation
- update-task-status.sh: Tolerant status regex for space-indented TODO entries
- New untracked file: .claude/scripts/link-artifact-todo.sh (the script referenced by the skill changes)

**Approach**: `git checkout` the regression files to discard those changes, then stage and commit only the genuine improvements

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
