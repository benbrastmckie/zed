# Implementation Summary: Cross-Platform Install Wizard

- **Task**: 57 - cross_platform_install_wizard
- **Status**: [COMPLETED]
- **Started**: 2026-04-13T00:00:00Z
- **Completed**: 2026-04-13T01:00:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: Task 31 (toolchain_installation_scripts) - COMPLETED (archived)
- **Artifacts**: plans/01_cross-platform-install.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md

## Overview

Made the 8-script install wizard cross-platform, supporting macOS, Debian/Ubuntu, and Arch Linux. Added OS detection, package manager abstraction, cross-platform package name mapping, interactive_step pattern for sudo-requiring operations, PPM binary repository configuration for R on Linux, and NixOS detect-and-skip behavior. All existing macOS functionality preserved through the same code paths.

## What Changed

- `scripts/install/lib.sh`: Added ~300 lines of platform abstraction: `detect_os()` (auto-runs at source time), `assert_supported_os()`, `require_pkg_manager()`, `pkg_install()` dispatcher with parallel-array package name mapping table (~18 canonical packages), `check_pkg_installed()` cross-platform presence checker, `interactive_step()` pattern (verify-first, instruct-wait-verify with retry, headless defer), `defer_hint()` standalone helper, `sudo_install()` wrapper, `is_headless()` detection. Updated `assert_git_or_hint()` with platform-specific hints. Made `assert_macos()` a deprecated wrapper for `assert_supported_os()`.
- `scripts/install/install-base.sh`: Replaced macOS-only bootstrap with platform-dispatched `install_build_tools()` (Xcode CLT / build-essential / base-devel), `install_pkg_manager()` (Homebrew on macOS, skip on Linux), cross-platform `install_node()`, `install_zed()` (cask / curl installer / AUR), `install_claude_cli()` (cask / npm).
- `scripts/install/install-shell-tools.sh`: Cross-platform `do_gh()` (brew / GitHub apt repo / pacman github-cli), platform-aware `do_make()`.
- `scripts/install/install-python.sh`: Cross-platform `do_core()` with uv curl installer on Linux, ruff via uv tool on Linux.
- `scripts/install/install-mcp-servers.sh`: Replaced `assert_macos` with `assert_supported_os`, `xdg-open` on Linux for obsidian pointer.
- `scripts/install/install-r.sh`: Cross-platform R install, `configure_ppm()` for Posit Package Manager binary repo on Linux, `r_install_pkg()` with 600s timeout on Linux, per-package progress logging (N/M) for epi bundle, headless detection with defer for epi bundle without PPM.
- `scripts/install/install-typesetting.sh`: Platform-dispatched LaTeX (BasicTeX/MacTeX cask vs texlive apt/pacman), Typst (brew / pacman / cargo/snap), cross-platform font packages.
- `scripts/install/install.sh`: Cross-platform help text, NixOS early detection, linux-unknown warning, platform-neutral group descriptions.
- `docs/general/installation.md`: Added Linux step-by-step section, platform support note.

## Decisions

- Used parallel arrays (not associative arrays) for package name mapping to maintain Bash 3.2 compatibility.
- Made `assert_macos()` a deprecated wrapper rather than removing it, for backward compatibility.
- NixOS exits with guidance at exit code 3 (prerequisite failure), not exit code 0.
- `interactive_step` retries up to 3 times in interactive mode, then defers; in headless mode, defers immediately.
- PPM configuration appends to `~/.Rprofile` rather than creating a standalone config file.
- Zed on Linux uses the official `zed.dev/install.sh` curl installer or AUR helpers if available.

## Impacts

- All 8 scripts now work on macOS, Debian/Ubuntu, and Arch Linux.
- Existing macOS behavior is preserved (same code paths, just behind DETECTED_OS checks).
- `--dry-run`, `--check`, `--yes`, `--preset`, `--only` flags all continue to work.
- NixOS users get a clear message instead of cryptic failures.

## Follow-ups

- NixOS companion flake.nix (mentioned in NixOS guidance) is a potential follow-up task.
- AUR helper auto-installation could be added if users frequently lack yay/paru.
- Manual testing on actual Debian and Arch systems recommended before production use.

## References

- `specs/057_cross_platform_install_wizard/reports/01_cross-platform-install.md`
- `specs/057_cross_platform_install_wizard/plans/01_cross-platform-install.md`
