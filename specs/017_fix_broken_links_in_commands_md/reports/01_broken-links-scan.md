# Research Report: Task #17

**Task**: 17 - Fix broken link at line 22 in docs/agent-system/commands.md and scan for similar broken links
**Started**: 2026-04-11T00:30:00Z
**Completed**: 2026-04-11T00:40:00Z
**Effort**: small
**Dependencies**: None
**Sources/Inputs**: Codebase scan of all 20 markdown files under docs/ plus root README.md
**Artifacts**: specs/017_fix_broken_links_in_commands_md/reports/01_broken-links-scan.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- 14 broken anchor links found across 2 files: `docs/agent-system/commands.md` (8) and `docs/workflows/README.md` (6)
- Zero broken file-level links -- all referenced files exist
- Root cause A: commands.md uses short anchors (`#task`) but user-guide.md uses `#task-command` format
- Root cause B: workflows/README.md uses double-dash anchors (`#convert--documents`) but actual headings with em dash produce single-dash anchors (`#convert-documents`)
- All fixes are mechanical anchor corrections with no content changes needed

## Context & Scope

Scanned all 20 markdown files under `docs/` plus the root `README.md` for:
1. Broken file-level links (relative links to files that do not exist)
2. Broken anchor links (links with `#fragment` pointing to non-existent headings)

External links (http/https) were excluded from the scan.

## Findings

### File-Level Links

All file-level internal links across the documentation resolve correctly. No broken file links were found.

### Broken Anchor Links

14 broken anchor links found in 2 files:

#### Group 1: docs/agent-system/commands.md (8 broken anchors)

These all link to `../../.claude/docs/guides/user-guide.md` with incorrect anchor fragments. The user-guide.md uses `{name}-command` format for command section headings, but commands.md uses bare command names.

| Line | Broken Link | Suggested Fix |
|------|-------------|---------------|
| 22 | `user-guide.md#task` | `user-guide.md#task-command` |
| 35 | `user-guide.md#research` | `user-guide.md#research-command` |
| 48 | `user-guide.md#plan` | `user-guide.md#plan-command` |
| 61 | `user-guide.md#implement` | `user-guide.md#implement-command` |
| 72 | `user-guide.md#revise` | `user-guide.md#revise-command` |
| 83 | `user-guide.md#todo` | `user-guide.md#todo-command` |
| 98 | `user-guide.md#review` | `user-guide.md#review-command` |
| 292 | `user-guide.md#funds` | Remove anchor (no `#funds-command` heading exists; nearest is `#task-not-found`) or link to the general user-guide without anchor |

**Root cause**: When commands.md was written (task 12), the anchor format in user-guide.md was not verified. The user-guide.md headings are formatted as `### /task Command` which produces anchors like `#task-command`, not `#task`.

**Note on line 292 (`#funds`)**: The user-guide.md does not have a `/funds` section at all (it covers core workflow commands but not the present-extension commands). The link should either be removed entirely or pointed at a different target.

#### Group 2: docs/workflows/README.md (6 broken anchors)

These all link to `convert-documents.md` with anchors containing double dashes where single dashes are correct.

| Line | Broken Link | Suggested Fix |
|------|-------------|---------------|
| 63 | `convert-documents.md#convert--documents-between-formats` | `convert-documents.md#convert--documents-between-formats` -> `convert-documents.md#convert-documents-between-formats` |
| 64 | `convert-documents.md#table--spreadsheets-to-formatted-tables` | `convert-documents.md#table-spreadsheets-to-formatted-tables` |
| 65 | `convert-documents.md#slides--research-talk-creation` | `convert-documents.md#slides-research-talk-creation` |
| 66 | `convert-documents.md#scrape--pdf-annotations-to-markdown-or-json` | `convert-documents.md#scrape-pdf-annotations-to-markdown-or-json` |
| 89 | `convert-documents.md#scrape--pdf-annotations-to-markdown-or-json` | `convert-documents.md#scrape-pdf-annotations-to-markdown-or-json` |
| 95 | `convert-documents.md#table--spreadsheets-to-formatted-tables` | `convert-documents.md#table-spreadsheets-to-formatted-tables` |

**Root cause**: The headings in convert-documents.md use an em dash (`---`), e.g., `## /convert --- documents between formats`. When GitHub/renderers generate anchor IDs, the em dash is stripped entirely, producing `#convert-documents-between-formats` (single dash). The links in README.md assumed the em dash would become a double dash, but it does not.

## Methodology

1. Collected all 20 `.md` files under `docs/` plus root `README.md`
2. Parsed all markdown links using regex `\[([^\]]*)\]\(([^)]+)\)`
3. Filtered out external URLs (http/https)
4. For file-level links: resolved relative paths and checked file existence
5. For anchor links: extracted headings from target files, converted to GitHub-style anchors, and compared
6. Used `difflib.get_close_matches()` to suggest correct anchors

## Recommendations

### Fix Group 1 (commands.md): Update 7 anchors, remove 1

For lines 22, 35, 48, 61, 72, 83, 98: change `#command-name` to `#command-name-command` to match user-guide.md heading format.

For line 292 (`#funds`): either remove the `[user guide]` link entirely (since user-guide.md has no `/funds` section), or link without an anchor: `[user guide](../../.claude/docs/guides/user-guide.md)`.

### Fix Group 2 (workflows/README.md): Replace double dashes with single dashes

For all 6 occurrences: change `#name--rest` to `#name-rest` (single dash).

### Total changes

- **2 files** modified
- **14 links** corrected
- **0 content changes** (only anchor fragments updated)
- Estimated effort: 10 minutes

## Risks & Mitigations

- **Risk**: user-guide.md headings could change in future, re-breaking links
  - **Mitigation**: Add a periodic link-check script or integrate into `/review`
- **Risk**: The `/funds` link on line 292 has no valid anchor target
  - **Mitigation**: Remove the anchor or the entire user-guide link for that entry

## Appendix

### Search methodology

- Python script using `os.walk`, `re.finditer`, and `os.path.normpath` for file link resolution
- Heading-to-anchor conversion: lowercase, strip special characters, spaces to dashes
- Close-match suggestions via `difflib.get_close_matches`

### Files scanned (20 docs/ files + 1 root)

```
README.md
docs/README.md
docs/agent-system/README.md
docs/agent-system/architecture.md
docs/agent-system/commands.md
docs/agent-system/context-and-memory.md
docs/agent-system/zed-agent-panel.md
docs/general/README.md
docs/general/installation.md
docs/general/keybindings.md
docs/general/settings.md
docs/workflows/README.md
docs/workflows/agent-lifecycle.md
docs/workflows/convert-documents.md
docs/workflows/edit-spreadsheets.md
docs/workflows/edit-word-documents.md
docs/workflows/epidemiology-analysis.md
docs/workflows/grant-development.md
docs/workflows/maintenance-and-meta.md
docs/workflows/memory-and-learning.md
docs/workflows/tips-and-troubleshooting.md
```
