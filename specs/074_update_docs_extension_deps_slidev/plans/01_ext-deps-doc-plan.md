# Implementation Plan: Task #74

- **Task**: 74 - Update documentation for extension dependency system and slidev resource-only extension
- **Status**: [IMPLEMENTING]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/074_update_docs_extension_deps_slidev/reports/01_ext-deps-doc-audit.md
- **Artifacts**: plans/01_ext-deps-doc-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: true

## Overview

All documentation changes for the extension dependency system and slidev resource-only extension already exist in the working tree as unstaged modifications. The research audit confirmed all 10 change areas are present and substantively correct, with one bug: duplicate step numbers in `extension-system.md` load and unload flows. Implementation consists of fixing the step numbering bug, verifying all changes for consistency, and staging/committing as a single unit.

### Research Integration

The research report audited all 11 changed files and 15 new files. Key findings:
- All 10 change areas from the task description are present and correct
- One bug: `extension-system.md` has duplicate step "3" in both load and unload flows (off-by-one from inserting step 2 without renumbering)
- Cross-reference analysis confirmed no additional files need updates (user-guide.md, component-selection.md, extension-slim-standard.md, user-installation.md are fine as-is)
- The index.json diff is large (3574 lines) but cosmetic key reordering plus 15 new entries

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items to advance (roadmap is empty).

## Goals & Non-Goals

**Goals**:
- Fix the step numbering bug in extension-system.md
- Verify all 10 change areas are consistent and complete
- Stage and commit all documentation changes as a single coherent unit

**Non-Goals**:
- Adding extension-slim-standard.md coverage of resource-only extensions (future work)
- Modifying any non-documentation files
- Restructuring the changes into multiple commits

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Large index.json diff masks issues | M | L | Research already audited -- only key reordering + 15 new entries |
| Step renumbering cascades incorrectly | L | L | Verify final numbering matches expected sequence |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Fix Bug and Verify Changes [COMPLETED]

**Goal**: Fix the step numbering bug in extension-system.md and verify all 10 change areas are correct.

**Tasks**:
- [ ] Fix load flow step numbering in `.claude/docs/architecture/extension-system.md`: renumber steps after the new "Resolve dependencies" step 2 so they go 1, 2, 3, 4, 5, ... (no duplicate "3")
- [ ] Fix unload flow step numbering in `.claude/docs/architecture/extension-system.md`: renumber steps after the new "Check reverse dependencies" step 2 so they go 1, 2, 3, 4, 5, 6 (no duplicate "3")
- [ ] Spot-check CLAUDE.md dependency paragraph references extension-development.md
- [ ] Spot-check extension-development.md Dependencies section covers all 6 subsections
- [ ] Spot-check creating-extensions.md Resource-Only Extensions section
- [ ] Verify talk/index.json paths reference slidev extension correctly
- [ ] Verify index.json has 15 new slidev entries matching the new files

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/docs/architecture/extension-system.md` - Fix duplicate step numbers in load and unload flows

**Verification**:
- No duplicate step numbers in extension-system.md
- All step sequences are contiguous (no gaps)

---

### Phase 2: Stage and Commit [IN PROGRESS]

**Goal**: Stage all documentation changes and commit as a single unit.

**Tasks**:
- [ ] Stage all modified files (11 changed files)
- [ ] Stage all new files in `.claude/context/project/slidev/` (15 new files)
- [ ] Create commit with message: `task 74: complete implementation`

**Timing**: 15 minutes

**Depends on**: 1

**Files to modify**:
- No additional modifications; staging existing changes

**Verification**:
- `git status` shows clean working tree after commit
- Commit includes all 26 files (11 modified + 15 new)

## Testing & Validation

- [ ] `extension-system.md` load flow steps numbered 1 through N with no duplicates
- [ ] `extension-system.md` unload flow steps numbered 1 through N with no duplicates
- [ ] `git diff --stat` after staging matches expected 11 modified files + 15 new files
- [ ] No unintended file changes included in the commit

## Artifacts & Outputs

- Fixed `.claude/docs/architecture/extension-system.md` with corrected step numbering
- Single git commit containing all 26 files of documentation updates

## Rollback/Contingency

Since changes are already in the working tree and not yet committed, rollback is straightforward: `git checkout -- .claude/` would revert all changes. The new slidev directory can be removed with `git clean -fd .claude/context/project/slidev/`.
