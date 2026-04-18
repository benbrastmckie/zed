# Research Report: Task #65 Post-Reload Diff Review

**Task**: 65 - strip_nvim_references_post_sync
**Started**: 2026-04-18T22:10:00Z
**Completed**: 2026-04-18T22:25:00Z
**Effort**: Small
**Dependencies**: None
**Sources/Inputs**:
- `git diff HEAD` of working tree changes (7629 lines across .claude/)
- Previous reports: 01, 02, 03 in this task directory
- `grep` scan of current .claude/ directory for remaining references
**Artifacts**:
- `specs/065_strip_nvim_references_post_sync/reports/04_post-reload-diff-review.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The latest reload applied **6 substantive nvim/neovim/neotex fixes** in the working tree: neotex header removed from CLAUDE.md, "neovim" dropped from extension list, `<leader>ac` replaced in 2 files, "Neovim Lua Loader" genericized in docs, extension-development.md genericized.
- **60 nvim/neovim/neotex/leader references remain across 18 files**. However, the majority (40+) are in illustrative examples within memory/learn documentation and are not actionable cleanup targets.
- **9 references in extensions.json** are `source_dir` paths pointing to `/home/benjamin/.config/nvim/.claude/extensions/*` -- these are factual filesystem paths and cannot be changed without breaking the extension loader.
- **4 VimTeX/leader references in CLAUDE.md** (lines 450-455) come from the latex extension's `EXTENSION.md` upstream source and will reappear on every reload unless the upstream is fixed.
- The **highest-priority remaining fixes** are in 6 files totaling ~17 references that refer to nvim-specific agents, extensions, or paths that do not exist in the zed deployment.

## Context & Scope

This audit reviews the `git diff HEAD` after a fresh `.claude/` reload to determine what the reload fixed versus what regressed or remains. The reload regenerates files from upstream sources in `/home/benjamin/.config/nvim/.claude/extensions/`.

## Findings

### Fixes Applied by This Reload (in working tree diff)

| File | Fix | Refs Removed |
|------|-----|-------------|
| `CLAUDE.md` | `neotex extension loader` -> `extension loader` | 1 neotex |
| `CLAUDE.md` | `neovim, lean4, latex...` -> `lean4, latex...` | 1 neovim |
| `context/architecture/system-overview.md` | Example list now uses "nix, lean4, latex, typst" | 1 neovim |
| `context/guides/extension-development.md` | `<leader>ac` -> "extension picker"; loader description genericized | 2 (leader + Neovim) |
| `context/guides/loader-reference.md` | `<leader>ac` -> "extension picker" | 1 leader |
| `docs/architecture/system-overview.md` | "Neovim Lua Loader" -> "Extension Loader"; "Extension picker UI in Neovim" genericized | 2 Neovim |
| `context/repo/project-overview.md` | Now uses generic "Editor loader" / "Agent system" language | 2 nvim |

**Net result**: ~10 nvim/neovim/neotex/leader references removed by this reload.

### Remaining References by Category

#### Category A: Must Fix (actionable, incorrect for zed deployment) -- 17 refs in 6 files

| File | Line(s) | Reference | Action Needed |
|------|---------|-----------|---------------|
| `CLAUDE.md` | 450-455 | VimTeX Integration section with 4 `<leader>` bindings | Remove section (comes from latex EXTENSION.md upstream) |
| `agents/code-reviewer-agent.md` | 36-38 | "Load For Neovim Code" with nvim extension paths (3 refs) | Remove or replace with generic guidance |
| `docs/README.md` | 120 | `nvim` task type row with neovim agents | Remove row |
| `docs/README.md` | 191 | "Moved to nvim extension" note | Remove or reword |
| `docs/docs-README.md` | 18-19, 56-57 | 4 refs to "moved to nvim extension" | Remove or reword |
| `systemd/claude-refresh.service` | 9 | `ExecStart=%h/.config/nvim/.claude/scripts/...` | Fix path to zed-local script |

#### Category B: Legitimate Examples in Documentation -- 33 refs in 6 files

These use "neovim" as an illustrative example topic in memory/learn documentation. They are self-contained examples showing how the memory system works, not references to actual nvim infrastructure.

| File | Count | Nature |
|------|-------|--------|
| `skills/skill-memory/SKILL.md` | 10 | Example memory topics like `neovim/plugins/telescope` |
| `context/project/memory/learn-usage.md` | 12 | Example `/learn` usage with neovim paths |
| `context/project/memory/knowledge-capture-usage.md` | 1 | Example memory deduplication |
| `context/project/memory/memory-setup.md` | 1 | Example memory path |
| `context/project/memory/domain/memory-reference.md` | 1 | Example topic field |
| `commands/learn.md` | 1 | Example: `/learn ~/notes/neovim/` |

**Recommendation**: These could be changed to use a more generic example topic (e.g., "python/libraries/pandas") but this is low priority and cosmetic. Changing them risks breaking the documentation's internal consistency.

#### Category C: Legitimate Tool References -- 4 refs in 3 files

| File | Count | Nature |
|------|-------|--------|
| `context/project/latex/tools/compilation-guide.md` | 1 | Mentions "Neovim with VimTeX" as a LaTeX editor |
| `context/project/typst/tools/compilation-guide.md` | 1 | "Neovim Integration" section header |
| `context/standards/postflight-tool-restrictions.md` | 1 | `nvim --headless` as a build command example |

**Recommendation**: The latex and typst compilation guides could be genericized, but these are factual tool references. The postflight restriction is a legitimate build command pattern.

#### Category D: Build/Test Infrastructure -- 7 refs in 3 files

| File | Count | Nature |
|------|-------|--------|
| `extensions.json` | 9 | `source_dir` paths to `/home/benjamin/.config/nvim/.claude/extensions/*` |
| `scripts/validate-wiring.sh` | 5 | `nvim)` case with neovim agent validation |
| `scripts/lint/lint-postflight-boundary.sh` | 2 | `nvim --headless` in build pattern list |

**Recommendation**: `extensions.json` paths are functional -- they record where extensions were loaded from. Cannot change without breaking state tracking. `validate-wiring.sh` nvim case could be removed since nvim extension is not available in zed. `lint-postflight-boundary.sh` uses nvim as a legitimate build tool pattern.

#### Category E: Template -- 1 ref in 1 file

| File | Count | Nature |
|------|-------|--------|
| `templates/extension-readme-template.md` | 1 | Lists "nvim" as example of complex extension |

**Recommendation**: Replace with another example (e.g., "present").

### Comparison with Previous Reports

| Metric | Report 01 | Report 02 | Report 03 | This Report (04) |
|--------|-----------|-----------|-----------|-------------------|
| Total occurrences | 368 | 56 | 76 | 60 |
| Files affected | 53 | 15 | 23 | 18 |
| neotex refs | 21 | 1 | 2 | 0 |
| leader-ac refs | 19 | 2 | 0 | 0 |
| VimTeX/leader refs | -- | -- | 4 | 4 |

The reload successfully eliminated all neotex and leader-ac references. VimTeX references persist because they originate from the latex extension upstream.

## Decisions

- **Extensions.json source_dir paths**: These are functional records and should NOT be modified. They correctly record where files were loaded from.
- **Memory documentation examples**: Low priority. Examples using "neovim" as a topic are self-contained illustrations and do not imply nvim is available in the zed deployment.
- **VimTeX section**: This is an upstream issue in `/home/benjamin/.config/nvim/.claude/extensions/latex/EXTENSION.md`. Fixing it there would fix all downstream deployments on next reload.

## Recommendations

**Priority 1 (must fix, 6 files, ~17 refs)**:
1. `CLAUDE.md` lines 450-455: Remove VimTeX Integration subsection entirely
2. `agents/code-reviewer-agent.md` lines 36-38: Remove "Load For Neovim Code" block
3. `docs/README.md` line 120: Remove nvim routing row
4. `docs/README.md` line 191: Remove "moved to nvim extension" note
5. `docs/docs-README.md` lines 18-19, 56-57: Remove "moved to nvim extension" entries
6. `systemd/claude-refresh.service` line 9: Update ExecStart path

**Priority 2 (should fix, 2 files, ~6 refs)**:
1. `scripts/validate-wiring.sh` lines 240-244: Remove nvim case block
2. `templates/extension-readme-template.md` line 26: Replace "nvim" with "present"

**Priority 3 (cosmetic, optional)**:
1. Memory documentation examples: Could replace "neovim" topic examples with "python" examples across 6 files (~33 refs)

**Upstream fix needed** (prevents recontamination):
- Edit `/home/benjamin/.config/nvim/.claude/extensions/latex/EXTENSION.md` to remove or conditionalize the VimTeX Integration section

## Risks & Mitigations

- **Risk**: Future reloads will reintroduce VimTeX section in CLAUDE.md unless upstream EXTENSION.md is fixed or CLAUDE.md is added to .syncprotect (it already is).
- **Mitigation**: CLAUDE.md is already in .syncprotect, so future syncs should skip it. However, a full reload may still regenerate it. The safest fix is to edit the upstream latex EXTENSION.md.
- **Risk**: Editing extensions.json source_dir paths would break extension state tracking.
- **Mitigation**: Leave extensions.json paths as-is; they are functional metadata.

## Appendix

### Search Commands Used
```bash
git diff HEAD -- .claude/                    # Full working tree diff
grep -riE 'nvim|neovim|neotex|<leader>' .claude/  # Remaining reference scan
```

### .syncprotect Status
The `.syncprotect` file lists 9 files as protected: `context/repo/project-overview.md`, `CLAUDE.md`, `README.md`, `commands/fix-it.md`, `commands/learn.md`, `commands/review.md`, `commands/task.md`, `skills/skill-orchestrator/SKILL.md`, `rules/plan-format-enforcement.md`. This should prevent future sync operations from overwriting these cleaned files.
