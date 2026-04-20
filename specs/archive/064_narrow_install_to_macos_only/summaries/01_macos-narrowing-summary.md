# Implementation Summary: Task #64

- **Task**: 64 - narrow_install_to_macos_only
- **Status**: [COMPLETED]
- **Started**: 2026-04-14
- **Completed**: 2026-04-14
- **Effort**: ~2 hours
- **Dependencies**: None
- **Artifacts**: plans/01_macos-narrowing-plan.md, summaries/01_macos-narrowing-summary.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md

## Overview

Stripped all Linux platform support (Debian/Ubuntu, Arch/Manjaro, NixOS) from the installation wizard scripts, documentation, and .claude/ context files, narrowing the entire install system to macOS/Homebrew only. This was a purely subtractive task -- no new features were added, and all macOS code paths were preserved unchanged.

## What Changed

- Rewrote `lib.sh` platform detection to a simple `uname -s == Darwin` check, removing ~200 lines of cross-platform dispatch, package name mapping (`PKG_MAP_*`, `_pkg_map_add`, `resolve_pkg_name`), and multi-distro package install infrastructure
- Simplified `assert_supported_os()`, `require_pkg_manager()`, `pkg_install()`, `check_pkg_installed()`, `sudo_install()`, and `assert_git_or_hint()` to macOS-only implementations
- Deleted systemd timer script and unit files (`.claude/scripts/install-systemd-timer.sh`, `.claude/systemd/` directory, `.claude_OLD/scripts/install-systemd-timer.sh`)
- Removed Linux branches from all 6 group install scripts (`install-base.sh`, `install-r.sh`, `install-typesetting.sh`, `install.sh`, `install-shell-tools.sh`, `install-python.sh`, `install-mcp-servers.sh`)
- Deleted PPM (Posit Package Manager) configuration from `install-r.sh`
- Updated 11 documentation files to remove Linux prerequisites, callout blocks, and platform descriptions
- Cleaned Linux platform mentions from .claude/ context files (filetypes dependency guide, tool detection, convert command, user installation guide)

## Decisions

- Kept `pkg_install()` and `check_pkg_installed()` as thin wrappers around `brew_install_formula` / `check_brew_formula` for backward compatibility
- Kept `sudo_install()` as a thin wrapper (falls through to `brew_install_formula`) rather than deleting it, since callers may still reference it
- Left incidental NixOS references in troubleshooting/compatibility notes (Playwright, session ID generation, TTS/STT) since these describe tool behavior, not platform support
- Left `.claude_OLD/` files untouched (old backups, not actively used)

## Impacts

- Installation wizard now only runs on macOS; non-macOS platforms get a clear error at `assert_supported_os()`
- `lib.sh` reduced from ~806 lines to ~535 lines
- All `--check` and `--dry-run` modes continue to function correctly on macOS
- No behavioral changes for macOS users

## Follow-ups

- None identified -- the narrowing is complete

## References

- `specs/064_narrow_install_to_macos_only/reports/01_macos-narrowing-audit.md` -- research audit
- `specs/064_narrow_install_to_macos_only/plans/01_macos-narrowing-plan.md` -- implementation plan
