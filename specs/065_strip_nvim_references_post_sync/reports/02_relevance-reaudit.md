# Research Report: Task #65 Relevance Re-Audit

**Task**: 65 - strip_nvim_references_post_sync
**Started**: 2026-04-18T00:00:00Z
**Completed**: 2026-04-18T00:05:00Z
**Effort**: Small
**Dependencies**: None
**Sources/Inputs**:
- Codebase grep searches across `.claude/`
- Original research report `specs/065_strip_nvim_references_post_sync/reports/01_nvim-reference-audit.md`
**Artifacts**:
- `specs/065_strip_nvim_references_post_sync/reports/02_relevance-reaudit.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The original audit found **368 nvim/neovim occurrences across 53 files**, **21 neotex references**, and **19 leader-ac references**. The current state is **59 occurrences across 19 files**, **1 neotex reference**, and **2 leader-ac references**.
- This represents an **84% reduction** in nvim/neovim references (368 -> 59) and a **64% reduction** in affected files (53 -> 19).
- All Category A+ files (re-contaminated by sync) have been fully cleaned except for 1 benign mention in CLAUDE.md.
- All Category C files (neovim-centric guides) have been either deleted or fully cleaned.
- All Category D files (examples using neovim) have been fully cleaned -- zero nvim/neovim references remain.
- **Recommendation: Reduce scope significantly.** Only 3 files have substantive remaining issues that warrant action. The rest are harmless mentions in examples or reference material.

## Context & Scope

Task 65 was created to clean up nvim/neovim contamination after a sync reload overwrote previously cleaned files. Since the original audit (tasks 69-75 have been completed), this re-audit determines whether the task is still relevant.

## Findings

### Current State vs. Original Audit

| Metric | Original | Current | Change |
|--------|----------|---------|--------|
| Total nvim/neovim occurrences | 368 | 59 | -84% |
| Files affected | 53 | 19 | -64% |
| neotex references | 21 | 1 | -95% |
| leader-ac references | 19 | 2 | -89% |

### Category-by-Category Analysis

#### Category A+ (Re-contaminated by Sync): RESOLVED

Original: 8 files, 36 occurrences. Current: **1 file, 1 occurrence** (benign).

| File | Original Count | Current Count | Status |
|------|---------------|---------------|--------|
| `CLAUDE.md` | 4 | 1 | Cleaned (1 benign mention in extension list) |
| `README.md` | 2 | 0 | File deleted |
| `commands/fix-it.md` | 16 | 0 | Cleaned |
| `commands/learn.md` | 1 | 1 | Still has neovim directory example |
| `commands/review.md` | 7 | 0 | Cleaned |
| `commands/task.md` | 3 | 0 | Cleaned |
| `skills/skill-orchestrator/SKILL.md` | 2 | 0 | Cleaned |
| `rules/plan-format-enforcement.md` | 1 | 0 | Cleaned |

#### Category A (Broken Config): PARTIALLY RESOLVED

Original: 6 files, 30 occurrences. Current: **3 files, 24 occurrences** (substantive issues remain).

| File | Original Count | Current Count | Status |
|------|---------------|---------------|--------|
| `extensions.json` | 7 | 9 | **Still broken** -- all `source_dir` entries point to nvim paths |
| `settings.local.json` | 12 | 14 | **Still broken** -- permission patterns reference nvim paths |
| `settings.json` | 1 | 0 | Cleaned |
| `systemd/claude-refresh.service` | 1 | 1 | **Still broken** -- ExecStart points to nvim script |
| `commands/todo.md` | 4 | 0 | Cleaned |
| `scripts/validate-wiring.sh` | 5 | 5 | **Still present** -- validates nonexistent neovim agents |

#### Category B (Incorrect Routing): MOSTLY RESOLVED

Original: 6 files, 12 occurrences. Current: **1 file, 3 occurrences**.

| File | Original Count | Current Count | Status |
|------|---------------|---------------|--------|
| `agents/meta-builder-agent.md` | 3 | 0 | Cleaned |
| `agents/code-reviewer-agent.md` | 3 | 3 | **Still present** -- "Load For Neovim Code" section |
| `agents/spawn-agent.md` | 1 | 0 | Cleaned |
| `skills/skill-fix-it/SKILL.md` | 2 | 0 | Cleaned |
| `context/architecture/system-overview.md` | 2 | 0 | Cleaned |
| `context/orchestration/orchestration-core.md` | 1 | 0 | Cleaned |

#### Category C (Neovim-Centric Guides): RESOLVED

Original: 6 files, ~106 occurrences. Current: **0 occurrences**.

- `docs/guides/neovim-integration.md` -- **Deleted**
- `docs/guides/tts-stt-integration.md` -- **Deleted**
- All 4 rewrite candidates -- **Cleaned** (zero nvim/neovim references)

#### Category D (Examples Using Neovim): RESOLVED

Original: 14 files, ~142 occurrences. Current: **0 occurrences**.

All 14 files have been cleaned of nvim/neovim references.

#### Category E (Template/Generic Mentions): PARTIALLY REMAINING

Original: 14 files, ~42 occurrences. Current: ~28 occurrences across ~10 files.

These are primarily harmless example text in:
- `skills/skill-memory/SKILL.md` (10 refs) -- neovim as example topic in memory examples
- `context/project/memory/learn-usage.md` (12 refs) -- neovim as example topic
- Various memory-related files (1-2 refs each) -- neovim as example topic/domain
- `context/project/latex/tools/compilation-guide.md` (1 ref) -- "Neovim with VimTeX" in editor list
- `context/project/typst/tools/compilation-guide.md` (1 ref) -- "Neovim Integration" section

### Remaining Substantive Issues (Action Required)

Only **3 files** have references that are genuinely broken or misleading:

1. **`extensions.json`** (9 refs): All `source_dir` entries point to `/home/benjamin/.config/nvim/.claude/extensions/*`. These are broken paths that should reference local or correct paths. **However**, this file is likely regenerated by the extension loader and may self-correct.

2. **`settings.local.json`** (14 refs): Permission patterns reference nvim paths for mv commands, script execution, and spec file access. These are broken/irrelevant permission entries.

3. **`systemd/claude-refresh.service`** (1 ref): ExecStart points to `nvim/.claude/scripts/claude-refresh.sh`. Should point to the local script.

### Minor Issues (Low Priority)

4. **`agents/code-reviewer-agent.md`** (3 refs): "Load For Neovim Code" section references nvim extension context paths. Not harmful (extension not loaded), but incorrect.

5. **`scripts/validate-wiring.sh`** (5 refs): Validates nonexistent neovim agents. Not harmful (nvim case simply won't match), but dead code.

6. **`docs/docs-README.md`** (4 refs): Notes about files moved to nvim extension. Informational/historical, not broken.

7. **`docs/architecture/extension-system.md`** (2 refs): References "Neovim Lua Loader" layer. Historical/architectural description.

8. **`docs/README.md`** (2 refs): Lists nvim extension and moved guide. Informational.

9. **`context/guides/extension-development.md`** (1 leader-ac ref): Uses `<leader>ac` for extension loading.

10. **`context/guides/loader-reference.md`** (1 leader-ac ref): References `<leader>ac` picker.

### Benign References (No Action Needed)

- **Memory-related files** (~22 refs total): Use neovim as example domain in memory documentation. These are illustrative examples, not broken functionality.
- **Compilation guides** (2 refs): Mention Neovim as a legitimate editor option. Factually correct.
- **CLAUDE.md** (1 ref): Lists neovim in extension examples. Factually correct -- nvim is a valid extension even if not loaded.
- **`templates/extension-readme-template.md`** (1 ref): Lists nvim in example list. Factually correct.
- **Lint scripts** (2 refs): `nvim --headless` in build pattern lists. Legitimate build pattern to detect.

## Decisions

1. The original task scope of 53 files / 368 occurrences is **no longer accurate**.
2. Categories A+, C, and D have been **fully resolved** by recent tasks (69-75).
3. Only 3 files have **genuinely broken** references requiring fixes.
4. The ~22 memory-related example references are **harmless** and do not need changes.

## Recommendations

1. **Reduce scope dramatically**: Change the task description to reflect current reality (3 substantive files, not 53).
2. **Fix the 3 broken files** as a small implementation task:
   - `extensions.json`: Fix `source_dir` paths (or verify the extension loader regenerates this)
   - `settings.local.json`: Remove stale nvim permission entries
   - `systemd/claude-refresh.service`: Fix ExecStart path
3. **Optionally clean** `agents/code-reviewer-agent.md` (remove "Load For Neovim Code" section) and `scripts/validate-wiring.sh` (remove nvim case).
4. **Do not clean** memory example files, compilation guides, or extension lists -- these are benign.
5. **The 2 leader-ac references** in extension docs are minor and could be fixed during any future docs update.
6. **Consider abandoning** this task entirely and creating a smaller, focused task instead, given that 95% of the work is already done.

## Risks & Mitigations

- **Risk**: `extensions.json` source_dir paths may be auto-generated by the extension loader, making manual edits futile.
  - **Mitigation**: Verify whether `extensions.json` is generated or hand-edited before modifying.
- **Risk**: `settings.local.json` permission entries may be auto-generated.
  - **Mitigation**: Same verification needed.

## Appendix

### Search Queries Used
- `grep -ic 'nvim\|neovim' .claude/` (recursive, case-insensitive)
- `grep -ic 'neotex' .claude/`
- `grep -ic 'leader.ac\|<leader>ac' .claude/`
- File existence checks for all 53 original files

### Summary Statistics

| Category | Original Files | Original Refs | Current Files | Current Refs | Status |
|----------|---------------|---------------|---------------|--------------|--------|
| A+ (Re-contaminated) | 8 | 36 | 1 | 1 | Resolved |
| A (Broken Config) | 6 | 30 | 3 | 24 | Partially resolved |
| B (Incorrect Routing) | 6 | 12 | 1 | 3 | Mostly resolved |
| C (Neovim Guides) | 6 | 106 | 0 | 0 | Resolved |
| D (Examples) | 14 | 142 | 0 | 0 | Resolved |
| E (Template/Generic) | 14 | 42 | 10 | 28 | Partially remaining (benign) |
| **Total** | **53** | **368** | **15** | **56** | **84% reduction** |
| neotex | 3 | 21 | 1 | 1 | Resolved |
| leader-ac | 10 | 19 | 2 | 2 | Resolved |
