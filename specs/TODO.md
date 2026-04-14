---
next_project_number: 63
---

# Task List

## Tasks

### 62. Triage and selectively apply working tree changes synced from nvim config
- **Effort**: medium
- **Status**: [RESEARCHED]
- **Task Type**: meta
- **Research**: [01_sync-triage-audit.md](specs/062_triage_nvim_sync_changes/reports/01_sync-triage-audit.md)

**Description**: The `<leader>ac` extension loader has synced .claude/ files from the nvim config, producing unstaged working tree changes across 19 files in `.claude/`. These are a mix of genuine improvements from nvim and regressions caused by the nvim sync overwriting zed-specific content (the same root cause as task 60, reverted by task 61; tracked upstream as nvim task 422).

Each changed file needs to be triaged: is the diff a legitimate improvement to keep, a regression to discard, or a mix requiring selective editing? The research phase should audit every file in `git diff --stat .claude/` against what actually exists in this repo's committed state and determine the correct action per file.

**19 files with unstaged changes** (from `git diff --stat .claude/`):
- CLAUDE.md, agents/README.md, agents/document-agent.md
- context/index.json, context/index.json.backup, context/patterns/artifact-linking-todo.md
- context/project/filetypes/ (3 files: conversion-tables.md, dependency-guide.md, tool-detection.md)
- extensions.json, rules/git-workflow.md, scripts/update-task-status.sh
- 7 skill files (skill-researcher, skill-planner, skill-implementer, skill-reviser, skill-team-implement, skill-team-plan, skill-team-research)
- 1 new untracked file: .claude/scripts/link-artifact-todo.sh

**Key context**: This repo has zed-specific content that does not exist in nvim (e.g., slide-planner-agent, skill-slide-planning, Hooks section, Co-Authored-By preference, present:slides compound routing, pymupdf document-agent improvements). The sync overwrites all of these because nvim's sync.lua only protects CLAUDE.md section markers (see nvim task 420/422 for upstream fix).

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
