# Implementation Plan: Task #60

- **Task**: 60 - Update documentation to reflect .claude/ changes
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/060_update_docs_for_claude_changes/reports/01_doc-update-audit.md
- **Artifacts**: plans/01_doc-update-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: true

## Overview

This plan addresses 13 documentation inconsistencies identified by the research audit after a batch of direct .claude/ changes. The changes span three themes: removing stale `slide-planner-agent`/`skill-slide-planning` references, softening PostToolUse hook references in command files, and resolving a Co-Authored-By conflict between `git-workflow.md` and the documented user preference. All changes are documentation-only edits with no code or configuration impact.

### Research Integration

Key findings from `reports/01_doc-update-audit.md`:
- 3 `docs/` files reference the removed `skill-slide-planning` skill
- 5 `index.json` entries still list `slide-planner-agent` in `load_when.agents` arrays
- `skill-slides/SKILL.md` still references `skill-slide-planning` on line 22
- 3 command files reference PostToolUse hooks (hook still exists in settings.json, just undocumented in CLAUDE.md)
- `git-workflow.md` re-added Co-Authored-By trailers, conflicting with user preference in CLAUDE.md line 162

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No active roadmap items. ROADMAP.md is empty (placeholder only).

## Goals & Non-Goals

**Goals**:
- Remove all references to `slide-planner-agent` and `skill-slide-planning` from docs/ and .claude/ files that were not already updated in the original batch
- Resolve the Co-Authored-By conflict in `git-workflow.md` by reverting to match the documented user preference (omit trailers)
- Soften PostToolUse hook references in command files to match the CLAUDE.md change
- Ensure cross-references between CLAUDE.md, docs/, and .claude/ internal files are consistent

**Non-Goals**:
- Deleting the `slide-planner-agent.md` or `skill-slide-planning/SKILL.md` files from disk (file deletion is a separate decision; this plan only fixes documentation references)
- Modifying `settings.json` or the actual hook script `validate-plan-write.sh`
- Restructuring `index.json` beyond removing stale agent references

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing `slide-planner-agent` from index.json while file exists causes routing confusion | M | L | The CLAUDE.md routing tables already omit it; index.json cleanup aligns with that |
| Co-Authored-By revert conflicts with upstream sync intent | M | L | CLAUDE.md user preference note was NOT changed in the batch, confirming the git-workflow change was unintentional |
| Missed references in files not covered by research grep | L | L | Research used comprehensive grep patterns; verify with post-implementation grep |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Remove slide-planner references from docs/ [COMPLETED]

**Goal**: Clean all `skill-slide-planning` and `slide-planner-agent` references from user-facing documentation files.

**Tasks**:
- [ ] Edit `docs/agent-system/commands.md` line ~48: remove or rewrite the Note about `skill-slide-planning` routing for `/plan` on slides tasks; replace with note that `/plan` on slides tasks routes to `skill-slides`
- [ ] Edit `docs/agent-system/README.md` line ~59: remove "via `skill-slide-planning`" clause from Present extension description
- [ ] Edit `docs/workflows/grant-development.md` lines ~80, ~84: remove `skill-slide-planning` references, update to reflect `skill-slides` handles plan routing

**Timing**: 20 minutes

**Depends on**: none

**Files to modify**:
- `docs/agent-system/commands.md` - Update slides routing note
- `docs/agent-system/README.md` - Remove skill-slide-planning reference
- `docs/workflows/grant-development.md` - Update slides routing references

**Verification**:
- `grep -r "skill-slide-planning" docs/` returns no matches
- `grep -r "slide-planner-agent" docs/` returns no matches

---

### Phase 2: Clean .claude/ internal references [COMPLETED]

**Goal**: Remove stale `slide-planner-agent` entries from `index.json` and update `skill-slides/SKILL.md`.

**Tasks**:
- [ ] Edit `.claude/context/index.json`: remove `slide-planner-agent` from 5 `load_when.agents` arrays (lines ~4067, ~4104, ~4139, ~4201, ~4379)
- [ ] Edit `.claude/context/index.json.backup`: same 5 removals to keep backup consistent
- [ ] Edit `.claude/skills/skill-slides/SKILL.md` line ~22: remove or update the note that says "Plan workflow (`/plan present:slides`) is handled by `skill-slide-planning`, not this skill" -- replace with note that `skill-slides` now handles both research and plan routing for slides tasks
- [ ] Edit `.claude/commands/research.md` line ~43: soften PostToolUse reference (change from "A PostToolUse hook monitors..." to "A validation hook monitors..." or remove the specific PostToolUse naming)
- [ ] Edit `.claude/commands/plan.md` line ~38: same PostToolUse softening
- [ ] Edit `.claude/commands/implement.md` line ~37: same PostToolUse softening

**Timing**: 40 minutes

**Depends on**: none

**Files to modify**:
- `.claude/context/index.json` - Remove slide-planner-agent from 5 agent arrays
- `.claude/context/index.json.backup` - Same removals
- `.claude/skills/skill-slides/SKILL.md` - Update routing note
- `.claude/commands/research.md` - Soften PostToolUse reference
- `.claude/commands/plan.md` - Soften PostToolUse reference
- `.claude/commands/implement.md` - Soften PostToolUse reference

**Verification**:
- `grep "slide-planner-agent" .claude/context/index.json` returns no matches
- `grep "skill-slide-planning" .claude/skills/skill-slides/SKILL.md` returns no matches
- `grep "PostToolUse" .claude/commands/*.md` returns no matches

---

### Phase 3: Resolve Co-Authored-By conflict in git-workflow.md [COMPLETED]

**Goal**: Revert the Co-Authored-By additions in `git-workflow.md` to match the documented user preference (omit trailers).

**Tasks**:
- [ ] Edit `.claude/rules/git-workflow.md`: remove `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>` from the commit format template (~line 95)
- [ ] Edit `.claude/rules/git-workflow.md`: remove Co-Authored-By lines from the 3 example commit blocks (~lines 124, 132, 140)
- [ ] Verify that `docs/agent-system/README.md` (~line 70) and `docs/agent-system/architecture.md` (~line 83) still correctly state "omit Co-Authored-By" (no changes needed if they already say this)

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `.claude/rules/git-workflow.md` - Remove Co-Authored-By from template and examples

**Verification**:
- `grep "Co-Authored-By" .claude/rules/git-workflow.md` returns no matches
- The user preference note in `.claude/CLAUDE.md` line 162 remains consistent

---

### Phase 4: Cross-reference verification [COMPLETED]

**Goal**: Run comprehensive grep verification to confirm all inconsistencies are resolved.

**Tasks**:
- [ ] Run `grep -r "slide-planner-agent" --include="*.md" --include="*.json"` excluding archived specs -- confirm only the agent file itself and extensions.json `installed_files` entry remain
- [ ] Run `grep -r "skill-slide-planning" --include="*.md" --include="*.json"` excluding archived specs -- confirm only the SKILL.md file itself remains (if file is kept)
- [ ] Run `grep -r "PostToolUse" --include="*.md"` excluding archived specs -- confirm no command files reference it
- [ ] Run `grep "Co-Authored-By" .claude/rules/git-workflow.md` -- confirm zero matches
- [ ] Verify JSON validity of `index.json` with `jq empty .claude/context/index.json`

**Timing**: 15 minutes

**Depends on**: 1, 2, 3

**Files to modify**: None (verification only)

**Verification**:
- All grep checks pass with expected results
- `index.json` parses as valid JSON

## Testing & Validation

- [ ] `grep -r "skill-slide-planning" docs/` returns zero matches
- [ ] `grep -r "slide-planner-agent" .claude/context/index.json` returns zero matches
- [ ] `grep "PostToolUse" .claude/commands/*.md` returns zero matches
- [ ] `grep "Co-Authored-By" .claude/rules/git-workflow.md` returns zero matches
- [ ] `jq empty .claude/context/index.json` exits 0 (valid JSON)
- [ ] `.claude/CLAUDE.md` user preference note at line 162 still says "omit Co-Authored-By"

## Artifacts & Outputs

- `specs/060_update_docs_for_claude_changes/plans/01_doc-update-plan.md` (this file)
- `specs/060_update_docs_for_claude_changes/summaries/01_doc-update-summary.md` (after implementation)

## Rollback/Contingency

All changes are documentation edits tracked by git. Rollback is straightforward:
- `git diff` to review all changes before committing
- `git checkout -- <file>` for any individual file revert
- No build, config, or runtime impact from any of these changes
