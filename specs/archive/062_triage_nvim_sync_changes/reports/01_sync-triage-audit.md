# Research Report: Task #62

**Task**: 62 - triage_nvim_sync_changes
**Started**: 2026-04-13T00:00:00Z
**Completed**: 2026-04-13T00:30:00Z
**Effort**: medium (19 files audited)
**Dependencies**: None
**Sources/Inputs**:
- `git diff .claude/` (19 files)
- Committed state of each file (via `git show HEAD:`)
- Existing zed-specific files on disk (agents, hooks, scripts, skills)
- CLAUDE.md workspace instructions (Co-Authored-By preference)
**Artifacts**:
- `specs/062_triage_nvim_sync_changes/reports/01_sync-triage-audit.md` (this report)
**Standards**: report-format.md, artifact-formats.md

## Executive Summary

- 19 files show unstaged changes from the nvim sync; the majority are benign (key reordering, timestamp updates) or genuine improvements worth keeping.
- 3 files contain zed-specific regressions that must be discarded or selectively edited: `CLAUDE.md`, `agents/README.md`, and `rules/git-workflow.md`.
- 4 large JSON files (`index.json`, `index.json.backup`, `extensions.json`) have zero semantic content changes -- only key reordering and timestamp updates. These can be discarded to keep the diff clean.
- 11 files contain genuine improvements from nvim (pymupdf support, link-artifact-todo.sh automation, tolerant status regex) that should be kept as-is.
- 1 file (`artifact-linking-todo.md`) has a small improvement to keep.

## Context & Scope

The `<leader>ac` extension loader syncs files from the nvim config into the zed config. This produces working tree changes that may be improvements (features developed on nvim first) or regressions (nvim lacks zed-specific customizations like slide-planner-agent, hooks, and the Co-Authored-By omission preference). Task 60 attempted to commit all changes blindly and was reverted by task 61. This audit determines the correct per-file action.

## Findings

### File-by-File Triage

#### 1. `.claude/CLAUDE.md` -- MIXED (selective edit required)

**Regressions to discard:**
- Removes `skill-slide-planning | slide-planner-agent` from Skill-to-Agent table (line ~179). The file `.claude/agents/slide-planner-agent.md` and `.claude/skills/skill-slide-planning/SKILL.md` exist in zed.
- Removes `slide-planner-agent` from Agents table (line ~193). Same reason.
- Removes the entire `### Hooks` section documenting `validate-plan-write.sh`. The hook file `.claude/hooks/validate-plan-write.sh` exists in zed.
- Removes `skill-slide-planning | slide-planner-agent` from Present Extension Skill-Agent table (line ~509).
- Changes `present:slides` compound task type to bare `present` in Language Routing table (line ~537). The zed workspace uses `present:slides` for compound routing.

**No improvements in this diff.** All changes are regressions.

**Action**: `git checkout .claude/CLAUDE.md` (DISCARD all changes)

---

#### 2. `.claude/agents/README.md` -- DISCARD

**Regressions:**
- Removes `slide-planner-agent.md` row from agent table.
- Removes the "Extension-specific agents..." explanatory note.

Both are zed-specific content that should be preserved.

**Action**: `git checkout .claude/agents/README.md`

---

#### 3. `.claude/agents/document-agent.md` -- KEEP

**Improvements (all genuine):**
- Adds pymupdf as primary tool for PDF extraction with detailed per-format routing.
- Adds EPUB support, image OCR support via pymupdf.
- Restructures conversion table to show format-aware tool selection (PDF -> pymupdf, DOCX -> markitdown).
- Adds pymupdf4llm as optional high-quality PDF-to-markdown converter.
- Updates tool selection pseudocode with 6-case routing logic.
- Updates error messages and example outputs to reflect pymupdf usage.

These are substantive functional improvements. pymupdf is genuinely better for PDF extraction.

**Action**: KEEP (accept working tree version)

---

#### 4. `.claude/context/index.json` -- DISCARD

**Analysis:** Normalized JSON comparison (with `json.dumps(sort_keys=True)`) shows zero content differences. The diff is purely key reordering within JSON objects (e.g., `domain` before `subdomain` vs after). No entries added, removed, or modified.

**Action**: `git checkout .claude/context/index.json` (cosmetic noise, discard)

---

#### 5. `.claude/context/index.json.backup` -- DISCARD

**Analysis:** Same as index.json -- pure key reordering, zero semantic changes.

**Action**: `git checkout .claude/context/index.json.backup`

---

#### 6. `.claude/context/patterns/artifact-linking-todo.md` -- KEEP

**Improvement:** Changes the constraint note from "This logic uses the Edit tool... It cannot be implemented as a shell script" to "This logic is implemented by `.claude/scripts/link-artifact-todo.sh`." This accurately reflects reality since `link-artifact-todo.sh` exists at `.claude/scripts/link-artifact-todo.sh` in the zed workspace.

**Action**: KEEP

---

#### 7. `.claude/context/project/filetypes/domain/conversion-tables.md` -- KEEP

**Improvements:**
- Updates conversion table to show pymupdf as primary for PDF, EPUB, and images.
- Adds EPUB and PPTX/XLSX rows.
- Adds pymupdf and pymupdf4llm to installation instructions.
- Updates Nix package ordering to put pymupdf first.
- Updates tool reference table with pymupdf entries.

All genuine improvements consistent with the pymupdf upgrade in document-agent.md.

**Action**: KEEP

---

#### 8. `.claude/context/project/filetypes/tools/dependency-guide.md` -- KEEP

**Improvements:**
- Adds pymupdf and pymupdf4llm to cross-platform installation tables.
- Adds nix-shell commands for pymupdf.
- Adds pymupdf to home-manager persistent configuration.
- Adds detailed package documentation sections for pymupdf and pymupdf4llm.
- Adds NixOS fragility note for markitdown vs pymupdf.
- Adds pymupdf to verification script.

All consistent with the pymupdf upgrade.

**Action**: KEEP

---

#### 9. `.claude/context/project/filetypes/tools/tool-detection.md` -- KEEP

**Improvements:**
- Adds pymupdf and pymupdf4llm detection patterns to tool checking code.
- Updates fallback chain to document PDF-specific chain (pymupdf4llm -> pymupdf -> pandoc -> markitdown).
- Adds pymupdf entries to cross-reference table and JSON detection function.

Consistent with pymupdf upgrade.

**Action**: KEEP

---

#### 10. `.claude/extensions.json` -- DISCARD

**Analysis:** Normalized comparison (stripping `loaded_at` timestamps, sorting keys) shows zero content differences. The diff is entirely:
- Key reordering within extension objects (e.g., `source_dir` moved to top).
- Timestamp updates (`loaded_at` from `2026-04-13T19:21:*` to `2026-04-14T02:53:*`).

No extensions added, removed, or modified in any substantive way.

**Action**: `git checkout .claude/extensions.json` (cosmetic noise, discard)

---

#### 11. `.claude/rules/git-workflow.md` -- DISCARD

**Regressions (critical):**
- Removes the note: "Per user preference, omit `Co-Authored-By` trailers from all commits in this workspace."
- Replaces it with `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>` in the commit template and all examples.

The zed workspace explicitly omits Co-Authored-By trailers per user preference (documented in CLAUDE.md). The nvim workspace uses them. This is a clear environment-specific regression.

**Action**: `git checkout .claude/rules/git-workflow.md` (DISCARD)

---

#### 12. `.claude/scripts/update-task-status.sh` -- KEEP

**Improvement:**
- Makes the status line grep pattern more tolerant: changes `'^- \*\*Status\*\*: \['` to `'^\s*-?\s*\*\*Status\*\*: \['`.
- Adds comments explaining the tolerant pattern matches both canonical and space-indented formats.

This is a genuine bugfix -- some task entries use space-indented format without a leading dash.

**Action**: KEEP

---

#### 13. `.claude/skills/skill-implementer/SKILL.md` -- KEEP

**Improvement:** Replaces inline four-case Edit logic reference with a call to `link-artifact-todo.sh`:
```bash
bash .claude/scripts/link-artifact-todo.sh $task_number '**Summary**' '**Description**' "$artifact_path"
```
The script exists in the zed workspace. This is a DRY improvement -- centralizes artifact linking logic.

**Action**: KEEP

---

#### 14. `.claude/skills/skill-planner/SKILL.md` -- KEEP

**Improvement:** Same link-artifact-todo.sh automation as skill-implementer, with `**Plan**` / `**Description**` field names.

**Action**: KEEP

---

#### 15. `.claude/skills/skill-researcher/SKILL.md` -- KEEP

**Improvement:** Same link-artifact-todo.sh automation, with `**Research**` / `**Plan**` field names.

**Action**: KEEP

---

#### 16. `.claude/skills/skill-reviser/SKILL.md` -- KEEP

**Improvement:** Same link-artifact-todo.sh automation, with `**Plan**` / `**Description**` field names.

**Action**: KEEP

---

#### 17. `.claude/skills/skill-team-implement/SKILL.md` -- KEEP

**Improvement:** Same link-artifact-todo.sh automation, with `**Summary**` / `**Description**` field names.

**Action**: KEEP

---

#### 18. `.claude/skills/skill-team-plan/SKILL.md` -- KEEP

**Improvement:** Same link-artifact-todo.sh automation, with `**Plan**` / `**Description**` field names.

**Action**: KEEP

---

#### 19. `.claude/skills/skill-team-research/SKILL.md` -- KEEP

**Improvement:** Same link-artifact-todo.sh automation, with `**Research**` / `**Plan**` field names.

**Action**: KEEP

---

### Summary Table

| # | File | Verdict | Reason |
|---|------|---------|--------|
| 1 | `.claude/CLAUDE.md` | **DISCARD** | Removes slide-planner-agent, hooks section, present:slides routing |
| 2 | `.claude/agents/README.md` | **DISCARD** | Removes slide-planner-agent row and extension note |
| 3 | `.claude/agents/document-agent.md` | **KEEP** | pymupdf format-aware routing improvements |
| 4 | `.claude/context/index.json` | **DISCARD** | Pure key reordering, zero content changes |
| 5 | `.claude/context/index.json.backup` | **DISCARD** | Pure key reordering, zero content changes |
| 6 | `.claude/context/patterns/artifact-linking-todo.md` | **KEEP** | Correctly notes script automation exists |
| 7 | `.claude/context/project/filetypes/domain/conversion-tables.md` | **KEEP** | pymupdf additions to conversion tables |
| 8 | `.claude/context/project/filetypes/tools/dependency-guide.md` | **KEEP** | pymupdf installation/documentation |
| 9 | `.claude/context/project/filetypes/tools/tool-detection.md` | **KEEP** | pymupdf detection patterns |
| 10 | `.claude/extensions.json` | **DISCARD** | Pure key reordering + timestamp updates |
| 11 | `.claude/rules/git-workflow.md` | **DISCARD** | Replaces Co-Authored-By omission with inclusion |
| 12 | `.claude/scripts/update-task-status.sh` | **KEEP** | Tolerant status regex bugfix |
| 13 | `.claude/skills/skill-implementer/SKILL.md` | **KEEP** | link-artifact-todo.sh automation |
| 14 | `.claude/skills/skill-planner/SKILL.md` | **KEEP** | link-artifact-todo.sh automation |
| 15 | `.claude/skills/skill-researcher/SKILL.md` | **KEEP** | link-artifact-todo.sh automation |
| 16 | `.claude/skills/skill-reviser/SKILL.md` | **KEEP** | link-artifact-todo.sh automation |
| 17 | `.claude/skills/skill-team-implement/SKILL.md` | **KEEP** | link-artifact-todo.sh automation |
| 18 | `.claude/skills/skill-team-plan/SKILL.md` | **KEEP** | link-artifact-todo.sh automation |
| 19 | `.claude/skills/skill-team-research/SKILL.md` | **KEEP** | link-artifact-todo.sh automation |

**Totals**: 5 DISCARD, 14 KEEP, 0 MIXED

## Decisions

1. **CLAUDE.md reclassified from MIXED to DISCARD**: Initially appeared mixed, but every change in the diff is a regression (removing zed-specific content). No improvements from nvim in this file.
2. **JSON files classified as DISCARD**: Even though key reordering is harmless, it creates unnecessary diff noise. Cleaner to discard.
3. **pymupdf changes classified as KEEP**: pymupdf is genuinely superior for PDF extraction (structure, tables, formatting) and the changes are consistent across all filetypes context files.
4. **link-artifact-todo.sh changes classified as KEEP**: The script exists in the zed workspace and centralizing the logic is a DRY improvement over inline Edit tool instructions.

## Risks & Mitigations

- **Risk**: Discarding CLAUDE.md changes might miss future nvim improvements bundled with slide-planner removal.
  - **Mitigation**: This is a known issue tracked as nvim task 422. Future syncs should be audited the same way.

- **Risk**: Keeping pymupdf changes without verifying pymupdf is installed on this system.
  - **Mitigation**: The agent/tool code already has fallback chains. pymupdf is documented as primary but falls back gracefully.

- **Risk**: Keeping link-artifact-todo.sh skill changes without verifying the script works correctly in zed context.
  - **Mitigation**: The script already exists at `.claude/scripts/link-artifact-todo.sh` and is listed as untracked. It will need to be staged along with the skill changes.

## Appendix

### Implementation Commands

To execute the triage decisions:

```bash
# DISCARD: Checkout the 5 files that are regressions or cosmetic noise
git checkout .claude/CLAUDE.md
git checkout .claude/agents/README.md
git checkout .claude/context/index.json
git checkout .claude/context/index.json.backup
git checkout .claude/extensions.json
git checkout .claude/rules/git-workflow.md

# KEEP: Stage the 13 files with genuine improvements + 1 new script
git add .claude/agents/document-agent.md
git add .claude/context/patterns/artifact-linking-todo.md
git add .claude/context/project/filetypes/domain/conversion-tables.md
git add .claude/context/project/filetypes/tools/dependency-guide.md
git add .claude/context/project/filetypes/tools/tool-detection.md
git add .claude/scripts/update-task-status.sh
git add .claude/skills/skill-implementer/SKILL.md
git add .claude/skills/skill-planner/SKILL.md
git add .claude/skills/skill-researcher/SKILL.md
git add .claude/skills/skill-reviser/SKILL.md
git add .claude/skills/skill-team-implement/SKILL.md
git add .claude/skills/skill-team-plan/SKILL.md
git add .claude/skills/skill-team-research/SKILL.md

# NEW: Stage the untracked link-artifact-todo.sh script (referenced by skill changes)
git add .claude/scripts/link-artifact-todo.sh
```

### Verification

After checkout, verify no zed-specific content was lost:
```bash
grep -c "slide-planner-agent" .claude/CLAUDE.md    # should be >= 2
grep -c "validate-plan-write" .claude/CLAUDE.md     # should be >= 1
grep -c "present:slides" .claude/CLAUDE.md          # should be >= 1
grep "Co-Authored-By" .claude/rules/git-workflow.md # should show omission note
```
