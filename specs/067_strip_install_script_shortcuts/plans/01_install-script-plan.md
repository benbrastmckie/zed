# Implementation Plan: Strip Install Script Shortcuts

- **Task**: 67 - strip_install_script_shortcuts
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_install-script-audit.md
- **Artifacts**: plans/01_install-script-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: true

## Overview

Remove the `--yes`/`-y`, `--only`, and `--preset` flags from the install system while retaining `--dry-run`, `--check`, and `--help`. Flag parsing is centralized in `lib.sh:parse_common_flags`, with supporting logic in `install.sh` (group resolution, child arg passing, non-interactive dispatch) and flag comments scattered across 6 child scripts. Documentation across 8 files references removed flags and must be updated. README.md line 18 must be revised from an HTML comment listing all shortcuts to visible text describing what `--dry-run` and `--check` do.

### Research Integration

The research report (`reports/01_install-script-audit.md`) provides a complete flag inventory with precise line numbers, a file-by-file impact analysis, and recommended README.md line 18 replacement text. All findings are integrated into the phase tasks below.

### Roadmap Alignment

No ROADMAP.md items are relevant (roadmap is empty).

## Goals & Non-Goals

**Goals**:
- Remove `--yes`/`-y`, `--only`, and `--preset` flags from all install scripts
- Remove `ASSUME_YES`, `ONLY_GROUPS`, `PRESET` variables and all branches that reference them
- Remove the `preset_groups` function from `lib.sh`
- Simplify `resolve_groups` in `install.sh` (no longer needs preset/only branches)
- Remove the non-interactive dispatch path in `install.sh` (preset/only triggered)
- Update all documentation to reflect only `--dry-run`, `--check`, and `--help`
- Revise README.md line 18 to describe what `--dry-run` and `--check` do

**Non-Goals**:
- Changing the interactive wizard behavior
- Modifying `--dry-run`, `--check`, or `--help` functionality
- Refactoring the install system beyond what removal requires

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing ASSUME_YES breaks prompt functions | H | L | Research confirms branches are guarded; removing them makes prompts always interactive (desired) |
| Missed reference to removed flag causes runtime error | M | L | Research provides exhaustive grep-based inventory; verify with post-edit grep |
| resolve_groups simplification introduces regression | M | L | Function reduces to returning ALL_GROUPS; straightforward to verify |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Strip Flags from lib.sh [COMPLETED]

**Goal**: Remove all traces of `--yes`/`-y`, `--only`, `--preset` from the shared library, including variable initialization, flag parsing cases, help text lines, ASSUME_YES logic in prompt functions, and the `preset_groups` function.

**Tasks**:
- [ ] Remove variable initializations: `ASSUME_YES=0` (line 79), `ONLY_GROUPS=""` (line 81), `PRESET=""` (line 82)
- [ ] Remove ASSUME_YES branches in `prompt_yn` (lines 127, 135-142)
- [ ] Remove ASSUME_YES branches in `prompt_accept_skip_cancel` (lines 164, 172-173)
- [ ] Remove help text lines for `--yes, -y` (line 443), `--only <groups>` (line 445), `--preset <name>` (line 446)
- [ ] Remove flag parsing cases: `--yes|-y` (line 455), `--only` and `--only=*` (lines 457-461), `--preset` and `--preset=*` (lines 462-466)
- [ ] Remove entire `preset_groups` function (lines 480-488)
- [ ] Verify no remaining references to ASSUME_YES, ONLY_GROUPS, PRESET, preset_groups in lib.sh

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `scripts/install/lib.sh` -- remove variables, flag cases, help text, prompt guards, preset_groups function

**Verification**:
- `grep -n 'ASSUME_YES\|ONLY_GROUPS\|PRESET\|preset_groups\|--yes\|--only\|--preset' scripts/install/lib.sh` returns no matches
- `bash -n scripts/install/lib.sh` passes (no syntax errors)

---

### Phase 2: Strip Flags from install.sh and Child Scripts [COMPLETED]

**Goal**: Remove flag references from the master dispatcher and all 6 child install scripts. Simplify `resolve_groups` and `build_child_args`. Remove the non-interactive dispatch path.

**Tasks**:
- [ ] In `install.sh`: remove flag comments (lines 18, 20, 21), help examples referencing removed flags (lines 45-46), and the Presets help section (lines 48-60)
- [ ] In `install.sh`: simplify `resolve_groups` function (lines 103-119) to just return `$ALL_GROUPS`
- [ ] In `install.sh`: remove `--yes` pass-through from `build_child_args` (line 139)
- [ ] In `install.sh`: update comment about stripping master-only flags (line 135)
- [ ] In `install.sh`: remove non-interactive dispatch path where PRESET/ONLY_GROUPS triggers direct dispatch (line 240 area)
- [ ] In `install.sh`: update info message mentioning presets (line 234) and comment about ASSUME_YES (line 241)
- [ ] In `install-base.sh`: remove `--yes` from flag comment (line 8), remove ASSUME_YES guard (line 52)
- [ ] In `install-shell-tools.sh`: remove `--yes` from flag comment (line 10)
- [ ] In `install-python.sh`: remove `--yes` from flag comment (line 9)
- [ ] In `install-r.sh`: remove `--yes` from flag comment (line 12)
- [ ] In `install-typesetting.sh`: remove `--yes` from flag comment (line 9), remove `--yes` comment on MacTeX line (line 43)
- [ ] In `install-mcp-servers.sh`: remove `--yes` from flag comment (line 30), remove ASSUME_YES guard (line 107)
- [ ] Verify no remaining references to removed flags across all install scripts

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `scripts/install/install.sh` -- remove flag comments, help examples, simplify resolve_groups and build_child_args, remove non-interactive dispatch
- `scripts/install/install-base.sh` -- remove --yes comment, remove ASSUME_YES guard
- `scripts/install/install-shell-tools.sh` -- remove --yes from comment
- `scripts/install/install-python.sh` -- remove --yes from comment
- `scripts/install/install-r.sh` -- remove --yes from comment
- `scripts/install/install-typesetting.sh` -- remove --yes from comment, remove --yes MacTeX comment
- `scripts/install/install-mcp-servers.sh` -- remove --yes from comment, remove ASSUME_YES guard

**Verification**:
- `grep -rn 'ASSUME_YES\|ONLY_GROUPS\|PRESET\|preset_groups\|--yes\|--only\|--preset' scripts/install/` returns no matches
- `bash -n scripts/install/install.sh` passes
- `bash -n scripts/install/install-*.sh` all pass

---

### Phase 3: Update Documentation and README.md [NOT STARTED]

**Goal**: Update all documentation files to remove references to stripped flags and revise README.md line 18 to describe `--dry-run` and `--check`.

**Tasks**:
- [ ] Revise README.md line 18: replace HTML comment listing all shortcuts with visible text describing `--dry-run` (preview without installing) and `--check` (health report of tool presence)
- [ ] In `docs/general/installation.md`: reduce "Non-interactive shortcuts" section (lines 33-42) to only `--dry-run` and `--check` bullets; update line 43 to mention only `--dry-run`, `--check`, `--help`
- [ ] In `docs/toolchain/README.md`: remove `--yes` from blockquote (line 3)
- [ ] In `docs/toolchain/python.md`: remove `--yes` example line (lines 7-9)
- [ ] In `docs/toolchain/r.md`: remove `--yes` example line (lines 7-9)
- [ ] In `docs/toolchain/typesetting.md`: remove `--yes` example line (lines 7-9)
- [ ] In `docs/toolchain/shell-tools.md`: remove `--yes` example line (lines 7-9)
- [ ] In `docs/toolchain/mcp-servers.md`: remove `--yes` example line (lines 7-9)
- [ ] Verify no remaining documentation references to `--yes`, `--only`, or `--preset` flags

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `README.md` -- revise line 18
- `docs/general/installation.md` -- reduce shortcuts section
- `docs/toolchain/README.md` -- remove --yes from blockquote
- `docs/toolchain/python.md` -- remove --yes example
- `docs/toolchain/r.md` -- remove --yes example
- `docs/toolchain/typesetting.md` -- remove --yes example
- `docs/toolchain/shell-tools.md` -- remove --yes example
- `docs/toolchain/mcp-servers.md` -- remove --yes example

**Verification**:
- `grep -rn '\-\-yes\|\-\-only\|\-\-preset' docs/ README.md` returns no matches (except possibly in changelogs or historical references)

## Testing & Validation

- [ ] `bash -n scripts/install/lib.sh` -- no syntax errors
- [ ] `bash -n scripts/install/install.sh` -- no syntax errors
- [ ] `bash -n scripts/install/install-*.sh` -- no syntax errors in any child script
- [ ] `grep -rn 'ASSUME_YES\|ONLY_GROUPS\|PRESET\|preset_groups' scripts/install/` -- no matches
- [ ] `grep -rn '\-\-yes\|\-\-only\|\-\-preset' scripts/install/ docs/ README.md` -- no matches
- [ ] `bash scripts/install/install.sh --help` -- help text shows only `--dry-run`, `--check`, `--help`
- [ ] `bash scripts/install/install.sh --dry-run` -- still works (interactive wizard in dry-run mode)
- [ ] `bash scripts/install/install.sh --check` -- still works (health report)

## Artifacts & Outputs

- `specs/067_strip_install_script_shortcuts/plans/01_install-script-plan.md` (this plan)
- `specs/067_strip_install_script_shortcuts/summaries/01_install-script-summary.md` (after implementation)

## Rollback/Contingency

All changes are tracked by git. If the implementation introduces regressions, revert the implementation commit(s) with `git revert`. The changes are purely subtractive (removing code paths), so partial rollback is also feasible by restoring individual files from the pre-implementation commit.
