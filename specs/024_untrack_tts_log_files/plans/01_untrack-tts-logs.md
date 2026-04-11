# Implementation Plan: Task #24

- **Task**: 24 - Untrack Claude Code TTS log files from git
- **Status**: [COMPLETED]
- **Effort**: 0.25 hours
- **Dependencies**: None
- **Research Inputs**: None (review-generated task)
- **Artifacts**: plans/01_untrack-tts-logs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: true

## Overview

Stop git from tracking the two Claude Code TTS notification hook scratch files (`specs/tmp/claude-tts-last-notify` and `specs/tmp/claude-tts-notify.log`) that the hook rewrites on every invocation, producing perpetual dirty working tree entries. Untrack them with `git rm --cached` and add a `.gitignore` entry so they stay out of future commits.

### Research Integration

No research report was created for this task -- the fix is mechanical and well-understood.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation required for this maintenance task.

## Goals & Non-Goals

**Goals**:
- Remove `specs/tmp/claude-tts-last-notify` and `specs/tmp/claude-tts-notify.log` from git's index without deleting the files on disk
- Add a `.gitignore` entry that covers both files (and, defensively, the `specs/tmp/` scratch directory) so future hook invocations do not dirty the working tree
- Leave a clean `git status` after the commit

**Non-Goals**:
- Modifying the Claude Code TTS hook itself
- Relocating the scratch files to a different directory
- Removing other entries from `specs/tmp/` that may represent useful state

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Over-broad gitignore pattern hides files that should be tracked | L | L | Scope the ignore pattern narrowly to the two known files, or ignore `specs/tmp/` only after verifying nothing else there is tracked |
| `git rm --cached` accidentally deletes the working copy | L | L | Use `--cached` explicitly; verify files still exist on disk after the command |
| Existing `.gitignore` (if any appears) gets clobbered | L | L | Append to `.gitignore` rather than overwriting; check for existing file first |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

### Phase 1: Untrack TTS scratch files and update .gitignore [COMPLETED]

**Goal**: Remove the two TTS hook scratch files from git's index and add a `.gitignore` entry so they stay ignored going forward.

**Tasks**:
- [ ] Verify both files still exist on disk at `specs/tmp/claude-tts-last-notify` and `specs/tmp/claude-tts-notify.log`
- [ ] Check whether a root `.gitignore` exists; if not, create one
- [ ] Run `git rm --cached specs/tmp/claude-tts-last-notify specs/tmp/claude-tts-notify.log`
- [ ] Append ignore entries to `.gitignore` (at minimum the two explicit paths; consider ignoring `specs/tmp/` after confirming nothing else there is tracked)
- [ ] Stage `.gitignore`
- [ ] Confirm `git status` no longer shows the two files as modified

**Timing**: 0.25 hours

**Depends on**: none

**Files to modify**:
- `.gitignore` - Create (or append) to ignore the two TTS scratch files
- Git index - Untrack `specs/tmp/claude-tts-last-notify` and `specs/tmp/claude-tts-notify.log`

**Verification**:
- `git ls-files specs/tmp/claude-tts-last-notify specs/tmp/claude-tts-notify.log` returns empty
- Both files still exist on disk (`ls specs/tmp/claude-tts-*`)
- `git status` no longer lists the two files as modified
- `git check-ignore specs/tmp/claude-tts-last-notify specs/tmp/claude-tts-notify.log` lists both paths

---

## Testing & Validation

- [ ] Both files are absent from `git ls-files`
- [ ] Both files still exist on disk (TTS hook continues to function)
- [ ] `git status` is clean with respect to the two scratch files after a subsequent hook invocation
- [ ] `.gitignore` is staged and contains the new entries

## Artifacts & Outputs

- Updated (or newly created) `.gitignore` at repo root
- Git index with the two TTS scratch files removed
- Clean working tree for the affected paths

## Rollback/Contingency

If the fix causes problems (e.g., the gitignore pattern is too broad and hides wanted files):
- Revert `.gitignore` changes: `git checkout -- .gitignore` (or delete if newly created)
- Re-add the scratch files to tracking: `git add -f specs/tmp/claude-tts-last-notify specs/tmp/claude-tts-notify.log`
- Commit the revert
