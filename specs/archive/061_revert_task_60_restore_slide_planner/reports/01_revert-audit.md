# Research Report: Task #61

**Task**: 61 - Revert task 60 implementation and restore slide-planner-agent references
**Started**: 2026-04-13T23:25:00Z
**Completed**: 2026-04-13T23:35:00Z
**Effort**: medium
**Dependencies**: None
**Sources/Inputs**:
- Git history (commits 198c9270..41023fd4, commit 191655c3)
- Current file state of .claude/CLAUDE.md, index.json, docs/, rules/
**Artifacts**: - specs/061_revert_task_60_restore_slide_planner/reports/01_revert-audit.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Task 60 made 4 commits (198c9270..41023fd4) that removed slide-planner-agent/skill-slide-planning references from 14 files, treating them as "stale" -- but they are active components
- The root cause was commit 191655c3 (extension loader sync) which overwrote CLAUDE.md with a version from nvim config that lacked zed-specific present extension additions (slide-planner-agent was added in task 55, commit b42705d0)
- Reverting all 4 commits cleanly restores 12 of the 14 affected files; TODO.md and state.json need manual handling since task 61 entries were added after task 60
- Additionally, the 4 CLAUDE.md table entries for slide-planner-agent must be re-added since they were removed by commit 191655c3 (not by task 60 itself)
- The Co-Authored-By note in git-workflow.md will be restored by the revert
- The agent file (.claude/agents/slide-planner-agent.md) and skill file (.claude/skills/skill-slide-planning/SKILL.md) still exist -- only references to them were removed

## Context & Scope

Task 60 was created to "update documentation to reflect .claude/ directory changes." It identified slide-planner-agent and skill-slide-planning as removed/stale and proceeded to clean references from docs, index.json, CLAUDE.md tables, command files, and git-workflow.md. However, these components are active -- the apparent absence from CLAUDE.md was caused by commit 191655c3 syncing an nvim-origin CLAUDE.md that didn't include zed-specific additions.

### Timeline of Events

1. **Task 55** (commit b42705d0): Added slide-planner-agent to 4 CLAUDE.md tables
2. **Commit 191655c3** (extension loader sync): Overwrote CLAUDE.md from nvim config, removing slide-planner-agent entries along with many other changes
3. **Task 60 research** (198c9270): Saw slide-planner-agent absent from CLAUDE.md, concluded it was "removed"
4. **Task 60 implementation** (258361ee, 41023fd4): Removed references from docs/, index.json, skill-slides/SKILL.md, agents/README.md, git-workflow.md

## Findings

### Commits to Revert (4 commits, newest first)

| Hash | Subject | Files Changed |
|------|---------|---------------|
| 41023fd4 | task 60: complete implementation | 10 files (docs, index.json, commands, extensions.json) |
| 258361ee | task 60: complete implementation | 6 files (CLAUDE.md, git-workflow.md, agents/README.md, etc.) |
| 23ffeecd | task 60: create implementation plan | 2 files (plan artifact, TODO.md) |
| 198c9270 | task 60: complete research | 3 files (report artifact, TODO.md, state.json) |

### Files Modified by Task 60

**Core config files** (revert restores pre-task-60 state):
1. `.claude/CLAUDE.md` -- Removed Hooks section, slide-planner from present extension table (but NOT the 4 main tables -- those were already missing from 191655c3)
2. `.claude/context/index.json` -- Removed slide-planner-agent from 5 agent arrays + restructured key ordering
3. `.claude/context/index.json.backup` -- Same as above
4. `.claude/extensions.json` -- Restructured format
5. `.claude/rules/git-workflow.md` -- Removed Co-Authored-By note
6. `.claude/skills/skill-slides/SKILL.md` -- Changed routing note
7. `.claude/agents/README.md` -- Removed slide-planner-agent row and extension note
8. `.claude/agents/document-agent.md` -- Rewrote conversion table and tool detection

**Documentation files** (revert restores pre-task-60 state):
9. `docs/agent-system/README.md` -- Changed skill-slide-planning to skill-slides
10. `docs/agent-system/commands.md` -- Changed skill-slide-planning to skill-slides
11. `docs/workflows/grant-development.md` -- Changed skill-slide-planning to skill-slides (2 places)

**Command files** (revert restores pre-task-60 state):
12. `.claude/commands/implement.md` -- Changed "PostToolUse hook" to "validation hook"
13. `.claude/commands/plan.md` -- Same
14. `.claude/commands/research.md` -- Same

**Filetypes extension context** (revert restores pre-task-60 state):
15. `.claude/context/project/filetypes/domain/conversion-tables.md`
16. `.claude/context/project/filetypes/tools/dependency-guide.md`
17. `.claude/context/project/filetypes/tools/tool-detection.md`

**Task artifacts** (created by task 60, will be removed by revert):
18. `specs/060_update_docs_for_claude_changes/plans/01_doc-update-plan.md`
19. `specs/060_update_docs_for_claude_changes/reports/01_doc-update-audit.md`
20. `specs/060_update_docs_for_claude_changes/summaries/01_doc-update-summary.md`

**State files** (need manual handling, NOT simple revert):
21. `specs/TODO.md` -- Task 60 status changes + task 61 added after
22. `specs/state.json` -- Task 60 completion data + task 61 added after

### CLAUDE.md Tables Needing slide-planner-agent Restoration

These 4 entries were removed by commit 191655c3 (NOT by task 60), so reverting task 60 alone does NOT restore them. They must be re-added separately:

**Table 1: Skill-to-Agent Mapping** (after skill-orchestrator row):
```
| skill-slide-planning | slide-planner-agent | opus | Interactive slide design planning |
```

**Table 2: Agents** (after spawn-agent row):
```
| slide-planner-agent | Interactive slide design and per-slide planning |
```

**Table 3: Present Extension Skill-Agent Mapping** (after slidev-assembly-agent row):
```
| skill-slide-planning | slide-planner-agent | opus | Interactive slide design planning |
```

**Table 4: Present Extension Language Routing** (replace slides row):
```
| `present:slides` | `slides` | `skill-slide-planning` | `skill-slides` | WebSearch, WebFetch, Read, Write, Edit |
```
(Note: task type key changes from `present` back to `present:slides`, and Research Skill changes from `skill-slides` to `skill-slide-planning`)

### Co-Authored-By State

Before task 60, `.claude/rules/git-workflow.md` contained:
```
**Note**: Per user preference, omit `Co-Authored-By` trailers from all commits in this workspace.
```
Task 60 removed this line. The revert will restore it.

### Hooks Section

Before task 60, `.claude/CLAUDE.md` contained a `### Hooks` subsection under Rules References documenting the PostToolUse validate-plan-write.sh hook. Task 60 removed it. The revert will restore it.

However, note that this Hooks section was added between commits 191655c3 and task 60. The revert of the task 60 commit that removed it (258361ee) will restore it since that commit's parent had it.

## Decisions

1. **Revert strategy**: Revert all 4 task 60 commits in reverse chronological order using `git revert --no-commit` to stage all changes, then commit once
2. **TODO.md/state.json**: Handle manually -- revert task 60's status to indicate it should be abandoned/reverted, keep task 61 entries
3. **CLAUDE.md tables**: Re-add 4 slide-planner-agent entries as a separate step after the revert, since they were removed by 191655c3 not task 60
4. **Task 60 artifacts**: The revert will delete the plan/report/summary files from specs/060_*; the directory itself should be kept for the reverted task entry

## Recommendations

### Implementation Plan

**Phase 1: Revert task 60 commits** (single compound revert)
```bash
git revert --no-commit 41023fd4
git revert --no-commit 258361ee
git revert --no-commit 23ffeecd
git revert --no-commit 198c9270
```
Then manually handle TODO.md and state.json conflicts (keep task 61 entries, mark task 60 as abandoned/reverted).

**Phase 2: Re-add slide-planner-agent to CLAUDE.md tables**
Add the 4 entries listed in Findings above. These were removed by commit 191655c3, not task 60, so the revert doesn't restore them.

**Phase 3: Verify cross-references**
- Confirm slide-planner-agent appears in: CLAUDE.md (4 tables), index.json (5 entries), agents/README.md, skill-slides/SKILL.md
- Confirm skill-slide-planning appears in: CLAUDE.md (3 tables), docs/agent-system/commands.md, docs/workflows/grant-development.md
- Confirm Co-Authored-By note is back in git-workflow.md
- Confirm Hooks section is back in CLAUDE.md

### Conflict Expectations

- **TODO.md**: Will conflict because task 61 was added after task 60. Resolution: keep task 61 entry, set task 60 status to [ABANDONED] with revert note
- **state.json**: Same situation. Resolution: revert task 60 completion data, keep task 61 entry, mark task 60 as abandoned
- **All other files**: Clean revert expected (no intervening changes)

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| index.json key reordering causes semantic issues | Low | The revert restores the pre-task-60 key order; functionally equivalent |
| extensions.json format revert causes loader issues | Low | The pre-task-60 format was working; restore is safe |
| document-agent.md revert loses pymupdf improvements | Medium | Task 60 rewrote the conversion table to add pymupdf; revert removes this. If pymupdf support is desired, create a new task |
| filetypes context files revert loses improvements | Medium | Same as above -- task 60 updated conversion tables and tool detection. A new task can re-apply valid improvements separately from the incorrect removals |

## Appendix

### Key Commits Reference

| Commit | Description |
|--------|-------------|
| b42705d0 | Task 55: Added slide-planner-agent to CLAUDE.md tables |
| 191655c3 | Extension loader sync: Overwrote CLAUDE.md (regression) |
| 5d369c2b | Task 60 creation commit |
| 198c9270 | Task 60: research |
| 23ffeecd | Task 60: plan |
| 258361ee | Task 60: implementation phase 1 |
| 41023fd4 | Task 60: implementation phase 2 |
| 90eeab2b | Task 61 creation commit |

### Files Still Containing slide-planner-agent (not modified by task 60)

- `.claude/agents/slide-planner-agent.md` -- Agent definition (intact)
- `.claude/skills/skill-slide-planning/SKILL.md` -- Skill definition (intact)
- `.claude/hooks/validate-plan-write.sh` -- Hook script (intact)
