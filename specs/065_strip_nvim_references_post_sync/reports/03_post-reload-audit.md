# Research Report: Task #65 Post-Reload Audit

**Task**: 65 - strip_nvim_references_post_sync
**Started**: 2026-04-18T21:15:00Z
**Completed**: 2026-04-18T21:25:00Z
**Effort**: Small
**Dependencies**: None
**Sources/Inputs**:
- `git diff` of unstaged changes (14 files, 2828 insertions, 2822 deletions)
- Previous re-audit: `specs/065_strip_nvim_references_post_sync/reports/02_relevance-reaudit.md`
- Codebase grep searches across `.claude/`
**Artifacts**:
- `specs/065_strip_nvim_references_post_sync/reports/03_post-reload-audit.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The agent system reload touched 14 files but **re-introduced nvim/neovim references in 3 files** that had previously been cleaned, and **introduced 1 new neotex reference**.
- Current totals: **76 nvim/neovim occurrences across 23 files** (up from 56 across 15 in report 02, due to re-contamination plus settings.local.json which report 02 counted separately).
- The reload **improved** `project-overview.md` by making it more generic (removing nvim-specific language), but **regressed** `system-overview.md` (2 files), `extension-development.md`, and `claudemd-header.md` by re-introducing nvim/neovim/neotex terms.
- The `<leader>ac` references (2 in report 02) were **correctly cleaned** by the reload -- now 0 occurrences.
- The **neotex** count went from 1 (report 02) to **2** (reload re-introduced one in `claudemd-header.md`).
- The 3 substantive broken files identified in report 02 (`extensions.json`, `settings.local.json`, `systemd/claude-refresh.service`) remain **unchanged** by the reload.

## Context & Scope

This audit assesses the impact of an agent system reload on the nvim/neovim cleanup work tracked by task 65. The reload regenerates files from source templates in the nvim config directory, potentially overwriting previous cleanup work.

## Findings

### Reload Impact Summary

The reload modified 14 files. Of these, the nvim-relevant changes are:

#### Re-Introduced References (Regressions)

| File | What Changed | Impact |
|------|-------------|--------|
| `context/architecture/system-overview.md` | Example list changed from "lean4, latex, typst, python" to "neovim, lean4, latex, typst" | +1 neovim ref |
| `docs/architecture/system-overview.md` | Example list changed from "lean4, latex, typst, python, etc." to "neovim, latex, typst, python, etc." | +1 neovim ref |
| `context/guides/extension-development.md` | "extension loader" reverted to "Neovim Lua loader" | +1 Neovim ref |
| `templates/claudemd-header.md` | "extension loader" reverted to "neotex extension loader" | +1 neotex ref |

#### Improvements (Nvim References Removed)

| File | What Changed | Impact |
|------|-------------|--------|
| `context/repo/project-overview.md` | Made generic: "Extension loader" -> "Editor loader", removed nvim-specific examples | -2 nvim refs improved to generic |
| `context/guides/extension-development.md` | `<leader>ac` removed (replaced with "extension picker") | -1 leader-ac ref |
| `context/guides/loader-reference.md` | `<leader>ac` removed (replaced with "extension picker") | -1 leader-ac ref |

#### Unrelated Changes (No Nvim Impact)

| File | Change Summary |
|------|---------------|
| `CLAUDE.md` | Template notice text updated (no nvim change) |
| `context/meta/meta-guide.md` | Documentation path changed (introduced a bug: duplicate `.claude/README.md`) |
| `docs/guides/creating-commands.md` | Documentation path changed |
| `extensions.json` | Key ordering changed, timestamps updated, structural reformatting (~622 lines changed) |
| `context/index.json` | Entry ordering changed (~4988 lines churned but content equivalent) |
| `.memory/memory-index.json` | Retrieval count incremented |

### Net Change from Reload

| Metric | Report 02 | After Reload | Delta | Direction |
|--------|-----------|-------------|-------|-----------|
| nvim/neovim (actionable files) | 59 | 62 | +3 | Regression |
| nvim/neovim (total w/ settings) | 56+14=70* | 76 | +6** | Mixed |
| neotex | 1 | 2 | +1 | Regression |
| leader-ac | 2 | 0 | -2 | Improvement |
| Files affected | 19 (excl settings) | 23 | +4 | Regression |

*Report 02 counted settings.local.json separately; normalizing here.
**The 3 re-introduced refs plus reclassification differences account for the delta.

### Current Full Inventory

**Substantive / Broken (Action Required)**:

| File | Count | Issue | Changed by Reload? |
|------|-------|-------|-------------------|
| `settings.local.json` | 14 | Broken permission paths reference nvim | No |
| `extensions.json` | 9 | All source_dir entries point to nvim | No (only reordered) |
| `systemd/claude-refresh.service` | 1 | ExecStart points to nvim script | No |
| **Subtotal** | **24** | | |

**Re-Introduced by Reload (New Regressions)**:

| File | Count | Issue |
|------|-------|-------|
| `context/architecture/system-overview.md` | 1 | "neovim" in extension example list |
| `docs/architecture/system-overview.md` | 1 | "neovim" in extension example list |
| `context/guides/extension-development.md` | 1 | "Neovim Lua loader" description |
| `templates/claudemd-header.md` | 1 (neotex) | "neotex extension loader" comment |
| **Subtotal** | **4** | |

**Minor / Could Clean (Low Priority)**:

| File | Count | Issue | Changed by Reload? |
|------|-------|-------|-------------------|
| `agents/code-reviewer-agent.md` | 3 | "Load For Neovim Code" section | No |
| `scripts/validate-wiring.sh` | 5 | Validates nonexistent neovim agents | No |
| `docs/docs-README.md` | 4 | Historical notes about nvim extension | No |
| `docs/README.md` | 2 | Lists nvim extension | No |
| `docs/architecture/extension-system.md` | 2 | "Neovim Lua Loader" architectural ref | No |
| `context/standards/postflight-tool-restrictions.md` | 1 | nvim mention | No |
| `scripts/lint/lint-postflight-boundary.sh` | 2 | nvim in build pattern list | No |
| **Subtotal** | **19** | | |

**Benign / No Action Needed**:

| File | Count | Reason |
|------|-------|--------|
| `skills/skill-memory/SKILL.md` | 10 | Neovim as example topic |
| `context/project/memory/learn-usage.md` | 12 | Neovim as example topic |
| `context/project/memory/memory-setup.md` | 1 | Neovim as example |
| `context/project/memory/knowledge-capture-usage.md` | 1 | Neovim as example |
| `context/project/memory/domain/memory-reference.md` | 1 | Neovim as example |
| `commands/learn.md` | 1 | Neovim directory in example |
| `templates/extension-readme-template.md` | 1 | nvim in example list |
| `context/project/latex/tools/compilation-guide.md` | 1 | Neovim as editor option |
| `context/project/typst/tools/compilation-guide.md` | 1 | Neovim as editor option |
| `CLAUDE.md` | 1 | neotex in generated comment |
| **Subtotal** | **30** | |

**Grand Total**: 77 occurrences across 23 files (24 substantive + 4 reload regressions + 19 minor + 30 benign)

### Collateral Issue: meta-guide.md Bug

The reload introduced a bug in `context/meta/meta-guide.md` unrelated to nvim cleanup:
```
- **Documentation**: `.claude/docs/README.md`
+ **Documentation**: `.claude/README.md`, `.claude/README.md`
```
This is a duplicate path and likely incorrect (should be `.claude/docs/README.md`).

## Decisions

1. The reload **partially regressed** cleanup work -- 3 files had nvim/neovim re-introduced, 1 file had neotex re-introduced.
2. The reload also **helped** by removing the 2 `<leader>ac` references and improving `project-overview.md`.
3. The 3 substantive broken files (`extensions.json`, `settings.local.json`, `systemd/claude-refresh.service`) were **not touched** by the reload and remain the primary cleanup targets.
4. The root cause of re-introduction is that the source templates in `/home/benjamin/.config/nvim/.claude/extensions/` still contain nvim-specific language.

## Recommendations

1. **Fix the 4 reload regressions** (trivial, 4 lines total):
   - `context/architecture/system-overview.md`: Change "neovim, lean4, latex, typst" to "lean4, latex, typst, python"
   - `docs/architecture/system-overview.md`: Change "neovim, latex, typst, python" to "lean4, latex, typst, python"
   - `context/guides/extension-development.md`: Change "Neovim Lua loader" to "extension loader"
   - `templates/claudemd-header.md`: Change "neotex extension loader" to "extension loader"

2. **Fix the 3 substantive broken files** (same as report 02):
   - `extensions.json`: Fix `source_dir` paths (or accept they are auto-generated)
   - `settings.local.json`: Remove stale nvim permission entries
   - `systemd/claude-refresh.service`: Fix ExecStart path

3. **Fix the meta-guide.md bug** (collateral from reload):
   - Change duplicate `.claude/README.md` back to `.claude/docs/README.md`

4. **Protect cleaned files from future reloads**: Add the 4 regressed files to `.syncprotect` to prevent re-contamination.

5. **Address root cause**: The source templates in the nvim config need updating to use generic language. Without this, every reload will re-introduce references.

## Risks & Mitigations

- **Risk**: Future reloads will continue re-introducing nvim references as long as source templates contain them.
  - **Mitigation**: Add cleaned files to `.syncprotect`, or fix source templates in `/home/benjamin/.config/nvim/.claude/extensions/`.
- **Risk**: `extensions.json` and `settings.local.json` may be auto-generated, making manual fixes futile.
  - **Mitigation**: Verify generation mechanism before editing.

## Appendix

### Search Queries Used
- `git diff --stat` (14 files changed)
- `git diff` on all changed files for nvim/neovim/neotex/leader-ac content
- `grep -ric 'nvim\|neovim' .claude/` (76 occurrences across 23 files)
- `grep -ric 'neotex' .claude/` (2 occurrences across 2 files)
- `grep -ric 'leader.ac' .claude/` (0 occurrences)

### Comparison: Report 02 vs Post-Reload

| Category | Report 02 | Post-Reload | Notes |
|----------|-----------|-------------|-------|
| A+ (Re-contaminated) | 1 file, 1 ref | 1 file, 1 ref | Unchanged |
| A (Broken Config) | 3 files, 24 refs | 3 files, 24 refs | Unchanged (not touched by reload) |
| B (Incorrect Routing) | 1 file, 3 refs | 1 file, 3 refs | Unchanged |
| Reload regressions | N/A | 4 files, 4 refs | New category |
| Minor | ~6 files, ~15 refs | 7 files, 19 refs | Slight increase |
| Benign | ~10 files, ~28 refs | 10 files, 30 refs | Slight increase |
| leader-ac | 2 refs | 0 refs | Improved by reload |
| neotex | 1 ref | 2 refs | Regressed by reload |
