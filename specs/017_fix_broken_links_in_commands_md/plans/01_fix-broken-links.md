# Implementation Plan: Fix broken anchor links in documentation

- **Task**: 17 - Fix broken link at line 22 in docs/agent-system/commands.md and scan for similar broken links
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/017_fix_broken_links_in_commands_md/reports/01_broken-links-scan.md
- **Artifacts**: plans/01_fix-broken-links.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: true

## Overview

Fix 14 broken anchor links across 2 documentation files. All fixes are mechanical anchor fragment corrections with no content changes. The two root causes are: (1) commands.md uses bare command names as anchors but user-guide.md uses `#name-command` format, and (2) workflows/README.md uses double-dash anchors but actual headings produce single-dash anchors.

### Research Integration

Research report identified 14 broken anchor links in 2 files with two distinct root causes. All file-level links are valid; only anchor fragments need correction. Line 292 in commands.md links to a `/funds` section that does not exist in user-guide.md and requires special handling.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Fix all 14 broken anchor links identified in the research report
- Handle the special case at line 292 where no valid anchor target exists
- Verify all corrected links resolve to valid anchors

**Non-Goals**:
- Adding a link-checking script or CI integration
- Fixing external (http/https) links
- Restructuring documentation content

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Anchor format in user-guide.md changes in future | M | L | Document the anchor convention; consider link-check in /review |
| Line numbers shifted since research | L | L | Match on link text content rather than exact line numbers |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |

Phases within the same wave can execute in parallel.

### Phase 1: Fix commands.md anchor links [NOT STARTED]

**Goal**: Correct 8 broken anchor links in docs/agent-system/commands.md

**Tasks**:
- [ ] Update line 22: change `user-guide.md#task` to `user-guide.md#task-command`
- [ ] Update line 35: change `user-guide.md#research` to `user-guide.md#research-command`
- [ ] Update line 48: change `user-guide.md#plan` to `user-guide.md#plan-command`
- [ ] Update line 61: change `user-guide.md#implement` to `user-guide.md#implement-command`
- [ ] Update line 72: change `user-guide.md#revise` to `user-guide.md#revise-command`
- [ ] Update line 83: change `user-guide.md#todo` to `user-guide.md#todo-command`
- [ ] Update line 98: change `user-guide.md#review` to `user-guide.md#review-command`
- [ ] Update line 292: remove the anchor from `user-guide.md#funds` (link to `user-guide.md` without anchor, since no `/funds` section exists in user-guide.md)

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `docs/agent-system/commands.md` - Fix 8 anchor fragments in user-guide.md links

**Verification**:
- Grep for `user-guide.md#` in commands.md and confirm all anchors match headings in user-guide.md
- Confirm no bare `#task`, `#research`, `#plan`, `#implement`, `#revise`, `#todo`, `#review`, or `#funds` anchors remain

---

### Phase 2: Fix workflows/README.md anchor links [NOT STARTED]

**Goal**: Correct 6 broken anchor links in docs/workflows/README.md by replacing double-dash anchors with single-dash anchors

**Tasks**:
- [ ] Update line 63: change `convert-documents.md#convert--documents-between-formats` to `convert-documents.md#convert-documents-between-formats`
- [ ] Update line 64: change `convert-documents.md#table--spreadsheets-to-formatted-tables` to `convert-documents.md#table-spreadsheets-to-formatted-tables`
- [ ] Update line 65: change `convert-documents.md#slides--research-talk-creation` to `convert-documents.md#slides-research-talk-creation`
- [ ] Update line 66: change `convert-documents.md#scrape--pdf-annotations-to-markdown-or-json` to `convert-documents.md#scrape-pdf-annotations-to-markdown-or-json`
- [ ] Update line 89: change `convert-documents.md#scrape--pdf-annotations-to-markdown-or-json` to `convert-documents.md#scrape-pdf-annotations-to-markdown-or-json`
- [ ] Update line 95: change `convert-documents.md#table--spreadsheets-to-formatted-tables` to `convert-documents.md#table-spreadsheets-to-formatted-tables`

**Timing**: 10 minutes

**Depends on**: none

**Files to modify**:
- `docs/workflows/README.md` - Fix 6 anchor fragments with double-dash to single-dash

**Verification**:
- Grep for `--` in anchor links within README.md and confirm none remain
- Confirm all 6 corrected anchors match headings in convert-documents.md

## Testing & Validation

- [ ] All 14 previously broken anchor links now resolve to valid headings
- [ ] No new broken links introduced
- [ ] No content changes made (only anchor fragments updated)
- [ ] Grep for double-dash anchors (`#.*--`) in docs/ returns zero results

## Artifacts & Outputs

- plans/01_fix-broken-links.md (this file)
- summaries/01_fix-broken-links-summary.md (after implementation)

## Rollback/Contingency

Revert the two modified files using `git checkout -- docs/agent-system/commands.md docs/workflows/README.md`. No other files are affected.
