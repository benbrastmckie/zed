# Research Report: Task #63 (Round 2) -- Documentation Update Audit

**Task**: 63 - zed_specific_claude_customizations_and_syncprotect
**Started**: 2026-04-14T16:00:00Z
**Completed**: 2026-04-14T16:30:00Z
**Effort**: Small
**Dependencies**: None
**Sources/Inputs**:
- Git diff `3283a359..8ef1cd96` (task 56 completion through HEAD) scoped to `.claude/`
- All files in `docs/` directory (14 markdown files)
- `README.md` (root)
**Artifacts**:
- `specs/063_zed_specific_claude_customizations_and_syncprotect/reports/02_docs-update-audit.md`
**Standards**: report-format.md

## Executive Summary

- 61 files changed in `.claude/` since the last stable baseline (task 56), including 4 new files, 6 deleted files, and 51 modified files
- The most significant changes are: new slide-critic system (agent + skill + rubric), Co-Authored-By removal across the system, artifact linking moved from inline Edit to shell script, document-agent updated with pymupdf as primary PDF tool, and several internal README.md files deleted
- 7 documentation files in `docs/` need updates; `README.md` needs 1 update
- The "Zed adaptations" section in `docs/agent-system/README.md` is the most impacted -- two of its three listed deviations are now incorrect

## Context & Scope

This audit identifies which files in `/home/benjamin/.config/zed/docs/` and `/home/benjamin/.config/zed/README.md` need updating to reflect `.claude/` changes that were synced from the nvim upstream. The diff baseline is commit `3283a359` (task 56 completion) through `8ef1cd96` (HEAD).

## Findings

### Category 1: New Files Added to .claude/

| File | Description |
|------|-------------|
| `.claude/agents/slide-critic-agent.md` | New agent for interactive slide critique with rubric evaluation (451 lines) |
| `.claude/skills/skill-slide-critic/SKILL.md` | New skill routing to slide-critic-agent (532 lines) |
| `.claude/context/project/present/talk/critique-rubric.md` | Rubric for slide critique evaluation (248 lines) |
| `.claude/scripts/link-artifact-todo.sh` | Shell script replacing inline Edit-based artifact linking (221 lines) |

### Category 2: Files Deleted from .claude/

| File | Was Referenced By |
|------|-------------------|
| `.claude/agents/README.md` | `docs/agent-system/architecture.md` (line 113 lists "25 agent specifications") |
| `.claude/context/README.md` | Not directly referenced in docs/ |
| `.claude/context/checkpoints/README.md` | Not directly referenced in docs/ |
| `.claude/context/reference/README.md` | Not directly referenced in docs/ |
| `.claude/docs/README.md` | `docs/agent-system/README.md` (line 77: "See also" links to `.claude/docs/guides/user-guide.md`) |
| `.claude/docs/templates/README.md` | Not directly referenced in docs/ |

### Category 3: Key Modifications

#### 3a. CLAUDE.md Changes
- **Removed**: "No Co-Authored-By" note from git commit conventions section
- **Removed**: `slide-planner-agent` from skill-to-agent mapping table and agents table
- **Removed**: Hooks section (PostToolUse hooks / `validate-plan-write.sh`)
- **Added**: `skill-slide-critic` -> `slide-critic-agent` in present extension skill table
- **Added**: `/slides N --critic` command in present extension commands table
- **Changed**: Present language routing from `present:slides` to `present` for slides

#### 3b. Co-Authored-By Removal
- Removed from `.claude/rules/git-workflow.md` (the workspace-specific "omit Co-Authored-By" note)
- Removed from `.claude/commands/slides.md` commit template
- Removed from multiple skill files (implementer, planner, researcher, reviser, team-*)

#### 3c. Document Agent Updates
- Primary PDF tool changed from `markitdown` to `pymupdf`
- Added EPUB format support
- Conversion table restructured with Fallback 1 / Fallback 2 columns
- Added OCR capability for images via pymupdf

#### 3d. Artifact Linking Pattern Change
- `.claude/context/patterns/artifact-linking-todo.md` changed from "uses Edit tool, cannot be a shell script" to "implemented by `.claude/scripts/link-artifact-todo.sh`"

#### 3e. Extensions.json Restructure
- Removed `version`, `installed_dirs` fields from extension entries
- Added `settings.mcp_servers` configuration within extension entries
- Simplified structure (removed `data_skeleton_files` as empty arrays in some entries)

### Category 4: Documentation Files Requiring Updates

#### File 1: `docs/agent-system/README.md` -- HIGH PRIORITY

**Line 59**: References `skill-slide-planning` for slide planning.
- **Update**: Add mention of `skill-slide-critic` for the new `/slides N --critic` critique workflow.

**Lines 68-71 ("Zed adaptations")**: Two of three listed deviations are now incorrect:
- Line 70: "No `Co-Authored-By` trailer" -- This deviation was **removed from .claude/** in the sync. The `Co-Authored-By` note was deleted from both `CLAUDE.md` and `rules/git-workflow.md`. This line should be removed or updated to note that the upstream no longer includes Co-Authored-By either (making the deviation moot).
- Line 71: "No `.claude/extensions/` directory" -- Still accurate (flat `extensions.json` pattern).
- **Missing**: The hooks section was removed from CLAUDE.md. If any doc references `validate-plan-write.sh`, it should be removed.

**Line 77**: Links to `.claude/docs/guides/user-guide.md` -- this file still exists, but `.claude/docs/README.md` was deleted. The link is to user-guide.md directly so it is still valid.

#### File 2: `docs/agent-system/commands.md` -- MEDIUM PRIORITY

**Line 48**: States `/plan` routes to `skill-slide-planning` for `present:slides` tasks.
- **Update**: The task type changed from `present:slides` to just `present` with `slides` subtype. The `/plan` routing description should reflect the current CLAUDE.md.

**Missing entry**: No entry for `/slides N --critic`. The `/slides` section (lines 305-316) does not mention the `--critic` flag.
- **Add**: A note about `--critic` flag and its three input modes (task+rubric, task+prompt, standalone file).

#### File 3: `docs/agent-system/architecture.md` -- LOW PRIORITY

**Line 109**: States "32 skill routers" in the configuration tree.
- **Update**: Count is now at least 33 (skill-slide-critic was added). Verify exact count.

**Line 110**: States "25 agent specifications".
- **Update**: Count changed (slide-critic-agent added, agents/README.md deleted). Verify exact count.

**Line 83**: References Co-Authored-By trailer omission: "This workspace omits the `Co-Authored-By` trailer per user preference; see [Zed adaptations](README.md#zed-adaptations)."
- **Update**: Remove or rewrite this sentence since the Co-Authored-By note was removed from the upstream config.

#### File 4: `docs/workflows/grant-development.md` -- MEDIUM PRIORITY

**Lines 80-84**: Describe the slides workflow lifecycle including `/plan` routing to `skill-slide-planning`.
- **Update**: This is still accurate for planning. But the section is missing the new `/slides N --critic` critique step that can happen after implementation.
- **Add**: A brief note about using `/slides N --critic` to review generated slides.

#### File 5: `docs/workflows/convert-documents.md` -- LOW PRIORITY

No direct references to changed components. However, the document-agent's tool priority changed (pymupdf is now primary for PDF). The docs describe `/convert` at a user level and don't mention specific tools, so **no update strictly needed** -- but if the user wants to document pymupdf as a new dependency, this is where it would go.

#### File 6: `docs/workflows/agent-lifecycle.md` -- NO UPDATE NEEDED

This file describes the generic lifecycle and doesn't reference slide-planning specifics or Co-Authored-By. No changes needed.

#### File 7: `README.md` (root) -- LOW PRIORITY

**Line 129**: `/slides` description says "(`/plan` triggers interactive slide design)".
- **Update**: Could add mention of `--critic` flag, but the current description is not wrong -- just incomplete.

No other changes needed in README.md. The command tables, directory layout, and platform notes are all still accurate.

### Category 5: Files That Do NOT Need Updates

The following docs files were checked and found to have no references to changed components:

- `docs/general/installation.md` -- No references to changed agents/skills
- `docs/general/keybindings.md` -- No agent references
- `docs/general/settings.md` -- No agent references
- `docs/general/README.md` -- No agent references
- `docs/toolchain/*` -- No agent references
- `docs/agent-system/zed-agent-panel.md` -- No references to changed components
- `docs/agent-system/context-and-memory.md` -- No references to changed components
- `docs/workflows/maintenance-and-meta.md` -- No references to changed components
- `docs/workflows/memory-and-learning.md` -- No references to changed components
- `docs/workflows/tips-and-troubleshooting.md` -- No references to changed components
- `docs/workflows/edit-word-documents.md` -- No references to changed components
- `docs/workflows/edit-spreadsheets.md` -- No references to changed components
- `docs/workflows/epidemiology-analysis.md` -- No references to changed components
- `docs/workflows/README.md` -- No references to changed components

## Decisions

- The Co-Authored-By deviation in "Zed adaptations" should be **removed** since the upstream itself no longer includes Co-Authored-By trailers, making the deviation a no-op.
- The hooks removal (validate-plan-write.sh) does not need documentation changes because no docs/ file referenced hooks.
- The artifact-linking pattern change (Edit -> shell script) is internal and does not surface in user-facing docs.
- The extensions.json restructure is internal and does not surface in user-facing docs.

## Recommendations

Ordered by priority:

1. **`docs/agent-system/README.md`** -- Remove or update the Co-Authored-By line in "Zed adaptations"; add slide-critic to the extensions list.
2. **`docs/agent-system/commands.md`** -- Add `--critic` flag to `/slides` entry; update `/plan` routing note for slides tasks.
3. **`docs/agent-system/architecture.md`** -- Update skill/agent counts; remove Co-Authored-By reference.
4. **`docs/workflows/grant-development.md`** -- Add `/slides N --critic` to the slides workflow.
5. **`README.md`** -- Minor: update `/slides` description to mention `--critic`.

## Risks & Mitigations

- **Risk**: The deleted `.claude/docs/README.md` was an internal navigation hub. If any doc links to it, those links are now broken.
  - **Mitigation**: Checked all docs/ files -- none link to `.claude/docs/README.md` directly. The `CLAUDE.md` (root) does reference it, but that is the `.claude/` layer, not user docs.

- **Risk**: Skill/agent counts in architecture.md are hardcoded numbers that will drift again.
  - **Mitigation**: Consider replacing hardcoded counts with approximate language ("~30 skill routers") or removing them.

## Appendix

### Git Diff Command
```bash
git diff 3283a359..8ef1cd96 --stat -- .claude/
```

### Files Changed Summary
- 4 new files added
- 6 files deleted (5 README.md files + 1 templates/README.md)
- 51 files modified
- Net: +727 lines added, -5207 lines removed (much of this is extensions.json restructure)

### Key New Components
- `slide-critic-agent` + `skill-slide-critic` + `critique-rubric.md` = complete critique system
- `link-artifact-todo.sh` = artifact linking automation (was previously inline Edit)
- `pymupdf` = new primary PDF conversion tool (replaces markitdown for PDF)
