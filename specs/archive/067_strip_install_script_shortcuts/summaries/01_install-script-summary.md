# Implementation Summary: Strip Install Script Shortcuts

- **Task**: 67 - strip_install_script_shortcuts
- **Status**: [COMPLETED]
- **Started**: 2026-04-15T00:00:00Z
- **Completed**: 2026-04-15T00:30:00Z
- **Effort**: 30 minutes
- **Dependencies**: None
- **Artifacts**:
  - `specs/067_strip_install_script_shortcuts/reports/01_install-script-audit.md`
  - `specs/067_strip_install_script_shortcuts/plans/01_install-script-plan.md`
- **Standards**: status-markers.md, artifact-management.md, tasks.md, summary.md

## Overview

Removed the `--yes`/`-y`, `--only`, and `--preset` flags from the install system (lib.sh, install.sh, and 6 child scripts) while retaining `--dry-run`, `--check`, and `--help`. Updated 8 documentation files to remove all references to the stripped flags, and revised README.md line 18 from a hidden HTML comment listing all shortcuts to visible text describing what `--dry-run` and `--check` do.

## What Changed

- Removed `ASSUME_YES`, `ONLY_GROUPS`, `PRESET` variable initializations from `lib.sh`
- Removed `--yes|-y`, `--only`, `--preset` flag parsing cases from `parse_common_flags` in `lib.sh`
- Removed `ASSUME_YES` guard branches from `prompt_yn` and `prompt_accept_skip_cancel` in `lib.sh`
- Removed the `preset_groups` function and its help text lines from `lib.sh`
- Simplified `resolve_groups` in `install.sh` to always return `$ALL_GROUPS`
- Removed `--yes` pass-through from `build_child_args` in `install.sh`
- Removed the non-interactive dispatch path (preset/only conditional) in `install.sh`
- Removed `--yes` flag comments from all 6 child install scripts
- Removed `ASSUME_YES` guards from `install-base.sh` (Xcode CLT wait) and `install-mcp-servers.sh` (obsidian pointer)
- Revised README.md line 18 to visible text describing `--dry-run` and `--check`
- Reduced installation.md "Non-interactive shortcuts" section from 7 bullets to 2
- Removed `--yes` from toolchain/README.md blockquote and 5 per-group doc quick-install examples

## Decisions

- Kept `--help`/`-h` as it is informational, not a "non-interactive shortcut"
- Made README.md line 18 visible (was an HTML comment) since it provides useful information about the retained flags
- Simplified `resolve_groups` to a one-liner rather than inlining it, preserving the function boundary for clarity

## Impacts

- The install wizard is now always interactive (accept/skip/cancel per group); there is no non-interactive batch mode
- `--dry-run` and `--check` remain as the only non-interactive shortcuts (both have their own early-exit paths)
- Any external scripts or CI that used `--yes`, `--preset`, or `--only` will see "unknown flag" warnings

## Follow-ups

- None required; changes are purely subtractive

## References

- `specs/067_strip_install_script_shortcuts/reports/01_install-script-audit.md`
- `specs/067_strip_install_script_shortcuts/plans/01_install-script-plan.md`
