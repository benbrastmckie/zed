# Implementation Summary: Task #17

**Completed**: 2026-04-10
**Duration**: 10 minutes

## Changes Made

Fixed 8 broken anchor links in `docs/agent-system/commands.md` that pointed to `user-guide.md` with incorrect fragment identifiers. The user-guide.md headings use the format `### /task Command` (producing anchor `#task-command`), but commands.md used bare names like `#task`.

Verified that 6 links in `docs/workflows/README.md` with double-dash anchors (e.g., `#convert--documents-between-formats`) are actually correct. The em-dash character in headings like `## /convert — documents` gets stripped during anchor generation, leaving two adjacent spaces that each become hyphens. The research report incorrectly identified these as broken.

## Files Modified

- `docs/agent-system/commands.md` - Fixed 7 anchors from `#name` to `#name-command` format (lines 22, 35, 48, 61, 72, 83, 98); removed invalid `#funds` anchor from line 292 (no corresponding heading in user-guide.md)

## Verification

- Build: N/A
- Tests: N/A
- Grep for bare `user-guide.md#task`, `#research`, `#plan`, `#implement`, `#revise`, `#todo`, `#review`, `#funds`: zero matches (all corrected)
- All 7 corrected anchors match headings in user-guide.md: confirmed
- Files verified: Yes

## Notes

- Phase 2 (workflows/README.md double-dash anchors) required no changes. Analysis of the em-dash byte sequence (UTF-8: `e2 80 94`) confirmed the anchors are generated correctly with double dashes. The research report's anchor generation algorithm differed from GitHub's actual behavior.
- The `/funds` command has no section in user-guide.md (it covers only core workflow commands, not present-extension commands). The broken link text was removed rather than linking to user-guide.md without an anchor, to avoid a misleading "see user guide" reference that leads nowhere useful.
