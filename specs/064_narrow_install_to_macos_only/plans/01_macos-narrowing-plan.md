# Implementation Plan: Task #64

- **Task**: 64 - narrow_install_to_macos_only
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/064_narrow_install_to_macos_only/reports/01_macos-narrowing-audit.md
- **Artifacts**: plans/01_macos-narrowing-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Strip all Linux platform support (Debian/Ubuntu, Arch/Manjaro, NixOS) from the installation wizard scripts, documentation, and .claude/ context files, narrowing to macOS/Homebrew only. The core task is deletion and simplification: removing ~200 lines of cross-platform dispatch from lib.sh, removing Linux branches from 6 group scripts, deleting the systemd timer and unit files, and updating ~15 documentation files. The clean architectural patterns (idempotency, interactive_step, --dry-run, --check, presets) are preserved unchanged.

### Research Integration

The file-by-file audit (report 01) identified 63 affected files totaling ~850 lines of changes. Key findings: lib.sh requires the heaviest rewrite (~200 lines deleted) because it contains the platform detection, package name mapping, and cross-platform dispatch infrastructure that all other scripts depend on. The package mapping system (_pkg_map_add, resolve_pkg_name, PKG_MAP_APT, PKG_MAP_PACMAN) can be eliminated entirely since only Homebrew remains. The report confirmed no cross-references exist to the systemd timer, making deletion safe.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Remove all Linux platform detection, package dispatch, and distro-specific branches from lib.sh and all install-*.sh scripts
- Delete the systemd timer script and .claude/systemd/ directory
- Simplify lib.sh by eliminating the package name mapping abstraction (PKG_MAP_*, _pkg_map_add, resolve_pkg_name, pkg_install)
- Update all documentation to reference only macOS/Homebrew
- Clean up incidental "Debian/Ubuntu, Arch/Manjaro" mentions in .claude/ context files

**Non-Goals**:
- Refactoring the overall script architecture (interactive_step, presets, group dispatch remain as-is)
- Adding new macOS-specific features
- Changing the Bash 3.2 compatibility requirements
- Modifying any behavior for the macOS code paths (this is purely subtractive)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking lib.sh sourcing contract for group scripts | H | M | Test every script with `--check` and `--dry-run` after lib.sh rewrite |
| Missing a Linux branch in a script | M | L | Post-implementation grep for `debian`, `arch`, `pacman`, `apt`, `DETECTED_OS`, `linux`, `nixos` |
| Removing a function still called by scripts | H | L | After lib.sh rewrite, grep for all removed function names to confirm no callers remain |
| Bash 3.2 compatibility regression | M | L | Do not introduce new syntax; preserve existing compat patterns |
| Documentation referencing removed script features | L | M | Cross-check docs against final script state in Phase 5 |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4 | 1 |
| 3 | 5 | 3, 4 |
| 4 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Simplify lib.sh Platform Infrastructure [COMPLETED]

**Goal**: Remove all cross-platform dispatch from lib.sh, leaving a macOS/Homebrew-only shared library. This is the foundation that all other scripts depend on.

**Tasks**:
- [ ] Rewrite `detect_os()` (lines 55-101): replace Linux branches with simple `uname -s == Darwin` check; set DETECTED_OS="macos" or error
- [ ] Simplify `assert_supported_os()` (lines 277-303): reduce to "if not macos, error and exit"
- [ ] Replace `require_pkg_manager()` (lines 308-337): reduce to just calling `require_brew`
- [ ] Delete entire package name mapping system (lines 339-419): `PKG_MAP_CANONICAL`, `PKG_MAP_BREW`, `PKG_MAP_APT`, `PKG_MAP_PACMAN`, `_pkg_map_add`, `resolve_pkg_name()`
- [ ] Replace `pkg_install()` (lines 421-459): make it a thin wrapper around `brew_install_formula` (or delete and update callers)
- [ ] Replace `check_pkg_installed()` (lines 461-495): make it a thin wrapper around `check_brew_formula` (or delete and update callers)
- [ ] Delete or simplify `sudo_install()` (lines 573-605): remove debian/arch branches; macOS does not need this
- [ ] Simplify `assert_git_or_hint()` (lines 767-791): remove debian/arch hint text
- [ ] Update header comments to say "macOS" instead of "cross-platform"
- [ ] Update `print_common_help_footer` / help text to remove Linux platform references

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `scripts/install/lib.sh` - Remove ~200 lines of cross-platform infrastructure, rewrite ~20 lines

**Verification**:
- `bash -n scripts/install/lib.sh` passes (syntax check)
- Grep for `debian`, `arch`, `pacman`, `apt`, `nixos`, `linux-unknown` in lib.sh returns zero matches
- All exported functions still defined (check_command, check_brew_formula, check_brew_cask, check_app_bundle, interactive_step, run_or_dry, brew_install_formula, etc.)

---

### Phase 2: Delete Systemd Timer and Unit Files [COMPLETED]

**Goal**: Remove the Linux-only systemd timer script and associated unit files.

**Tasks**:
- [ ] Delete `.claude/scripts/install-systemd-timer.sh`
- [ ] Delete `.claude/systemd/claude-refresh.service`
- [ ] Delete `.claude/systemd/claude-refresh.timer`
- [ ] Delete `.claude/systemd/` directory
- [ ] If `.claude_OLD/scripts/install-systemd-timer.sh` exists, delete it too
- [ ] Verify no remaining references to `install-systemd-timer` or `claude-refresh.service` in any file

**Timing**: 0.25 hours

**Depends on**: none

**Files to modify**:
- `.claude/scripts/install-systemd-timer.sh` - DELETE
- `.claude/systemd/claude-refresh.service` - DELETE
- `.claude/systemd/claude-refresh.timer` - DELETE

**Verification**:
- `find . -name "*systemd*" -o -name "install-systemd-timer*"` returns nothing
- Grep for `systemd`, `install-systemd-timer`, `claude-refresh.service` across the repo returns no orphaned references

---

### Phase 3: Simplify Group Install Scripts (Part 1: Heavy) [NOT STARTED]

**Goal**: Remove Linux branches from the three scripts requiring the most changes: install-base.sh, install-r.sh, install-typesetting.sh.

**Tasks**:
- [ ] **install-base.sh** (~300 lines): Remove debian/arch branches from `install_build_tools()`, `install_pkg_manager()`, `install_node()`, `install_zed()`, `install_claude_cli()`, `run_check_mode()`; update header and help text
- [ ] **install-r.sh** (~311 lines): Delete `configure_ppm()` entirely; simplify `r_install_pkg()` (remove Linux timeout wrapper); remove debian/arch branches from `do_core()`, `do_quarto()`; delete PPM variable and call; remove Linux headless warning from `do_epi_bundle()`
- [ ] **install-typesetting.sh** (~247 lines): Remove debian/arch branches from `do_latex()`, `do_typst()`, `do_fonts()`; update header and help text
- [ ] Replace any `pkg_install` calls with direct `brew_install_formula` calls (if pkg_install was deleted in Phase 1) or verify they work with the simplified wrapper

**Timing**: 1.25 hours

**Depends on**: 1

**Files to modify**:
- `scripts/install/install-base.sh` - Remove ~80 lines of Linux branches
- `scripts/install/install-r.sh` - Remove ~100 lines (PPM, Linux branches)
- `scripts/install/install-typesetting.sh` - Remove ~60 lines of Linux branches

**Verification**:
- `bash -n` passes for each script
- Each script runs successfully with `--check` flag
- Each script runs successfully with `--dry-run` flag
- Grep for `debian`, `arch`, `pacman`, `apt`, `PPM`, `configure_ppm`, `sudo_install` returns zero matches in these files

---

### Phase 4: Simplify Group Install Scripts (Part 2: Light) [NOT STARTED]

**Goal**: Remove Linux branches from the three scripts requiring lighter changes: install.sh, install-shell-tools.sh, install-python.sh, install-mcp-servers.sh.

**Tasks**:
- [ ] **install.sh** (~275 lines): Update "cross-platform" comment and supported platforms help text; delete NixOS early exit block; delete linux-unknown warning block
- [ ] **install-shell-tools.sh** (~128 lines): Remove debian/arch branches from `do_gh()` and `do_make()`; update any `pkg_install` calls
- [ ] **install-python.sh** (~183 lines): Remove debian/arch branches from `do_core()`, uv install, ruff install
- [ ] **install-mcp-servers.sh** (~164 lines): Remove Linux `xdg-open` fallback from `do_obsidian_pointer()`

**Timing**: 0.75 hours

**Depends on**: 1

**Files to modify**:
- `scripts/install/install.sh` - Remove ~15 lines, update ~5 lines
- `scripts/install/install-shell-tools.sh` - Remove ~30 lines
- `scripts/install/install-python.sh` - Remove ~35 lines
- `scripts/install/install-mcp-servers.sh` - Remove ~5 lines

**Verification**:
- `bash -n` passes for each script
- Each script runs successfully with `--check` flag
- Each script runs successfully with `--dry-run` flag
- Grep for `debian`, `arch`, `pacman`, `apt`, `nixos`, `linux-unknown`, `xdg-open` returns zero matches in these files

---

### Phase 5: Update Primary Documentation [NOT STARTED]

**Goal**: Rewrite the 4 primary documentation files and 7 toolchain docs to remove all Linux platform references.

**Tasks**:
- [ ] **docs/general/installation.md**: Delete "Step by step (Linux)" section; remove all Linux prerequisites and alternatives callouts; simplify platform description to macOS-only
- [ ] **docs/toolchain/README.md**: Delete cross-platform package reference table (apt/pacman columns); simplify to brew-only; remove declarative package management note
- [ ] **README.md**: Update platform descriptions from "macOS, Debian/Ubuntu, Arch/Manjaro" to "macOS"; delete Platform Notes Linux bullets; remove quick start Linux alternative
- [ ] **.claude/context/repo/project-overview.md**: Update 2 platform description lines
- [ ] **docs/toolchain/python.md**: Delete 3 "Linux alternatives" callout blocks and simplify headers
- [ ] **docs/toolchain/r.md**: Delete 3 "Linux alternatives" callout blocks and simplify headers
- [ ] **docs/toolchain/shell-tools.md**: Delete 6 "Linux alternatives" callout blocks and simplify headers
- [ ] **docs/toolchain/typesetting.md**: Delete 5 "Linux alternatives" callout blocks and simplify headers
- [ ] **docs/toolchain/extensions.md**: Update 1 Linux mention
- [ ] **docs/agent-system/architecture.md**: Update 3 Linux mentions
- [ ] **docs/agent-system/README.md**: Update 1 Linux mention

**Timing**: 1.0 hour

**Depends on**: 3, 4

**Files to modify**:
- `docs/general/installation.md` - Delete ~30 lines, update ~10 lines
- `docs/toolchain/README.md` - Delete ~20 lines, rewrite table
- `README.md` - Delete ~10 lines, update ~5 lines
- `.claude/context/repo/project-overview.md` - Update 2 lines
- `docs/toolchain/python.md` - Delete callout blocks
- `docs/toolchain/r.md` - Delete callout blocks
- `docs/toolchain/shell-tools.md` - Delete callout blocks
- `docs/toolchain/typesetting.md` - Delete callout blocks
- `docs/toolchain/extensions.md` - Minor update
- `docs/agent-system/architecture.md` - Minor updates
- `docs/agent-system/README.md` - Minor update

**Verification**:
- Grep for `Debian`, `Ubuntu`, `Arch`, `Manjaro`, `pacman`, `apt-get`, `apt install`, `NixOS` across docs/ returns zero matches
- Documentation accurately describes the macOS-only scripts (no references to removed features like PPM, systemd timer, etc.)

---

### Phase 6: Clean Up .claude/ Context Files [NOT STARTED]

**Goal**: Remove incidental "Debian/Ubuntu, Arch/Manjaro" mentions from ~40 .claude/ context and system files.

**Tasks**:
- [ ] Update `.claude/CLAUDE.md` (4 platform mentions)
- [ ] Update `.claude/README.md` (4 platform mentions)
- [ ] Batch find-and-replace across remaining .claude/ files: replace "macOS, Debian/Ubuntu, and Arch/Manjaro" with "macOS"; replace "macOS, Debian/Ubuntu, Arch/Manjaro" with "macOS"
- [ ] Review each replacement for context correctness (some may need more nuanced rewording)
- [ ] Final sweep: grep for `Debian`, `Ubuntu`, `Arch`, `Manjaro`, `pacman`, `apt` across entire repository to catch any stragglers

**Timing**: 0.25 hours

**Depends on**: 5

**Files to modify**:
- `.claude/CLAUDE.md` - Update platform references
- `.claude/README.md` - Update platform references
- ~40 additional .claude/ context files - Cosmetic platform string updates

**Verification**:
- Grep for `Debian`, `Ubuntu`, `Arch/Manjaro`, `pacman`, `apt-get` across entire repository returns zero matches (excluding git history, specs/ reports, and this plan)
- No broken references or orphaned content

## Testing & Validation

- [ ] `bash -n` syntax check passes for all 7 scripts in scripts/install/
- [ ] `scripts/install/install.sh --check` runs without errors
- [ ] `scripts/install/install.sh --dry-run` runs without errors
- [ ] Each group script (`install-base.sh`, `install-r.sh`, etc.) passes `--check` and `--dry-run`
- [ ] Repository-wide grep for Linux platform terms returns zero matches (outside specs/ artifacts and git history)
- [ ] No orphaned function references (functions removed from lib.sh are not called anywhere)
- [ ] Systemd files are fully deleted with no remaining references

## Artifacts & Outputs

- Modified: `scripts/install/lib.sh` (simplified to ~550 lines)
- Modified: 6 group install scripts (Linux branches removed)
- Modified: 11 documentation files (Linux references removed)
- Modified: ~40 .claude/ context files (cosmetic platform string updates)
- Deleted: `.claude/scripts/install-systemd-timer.sh`
- Deleted: `.claude/systemd/` directory (2 files)
- Deleted: `.claude_OLD/scripts/install-systemd-timer.sh` (if exists)

## Rollback/Contingency

All changes are tracked in git. If the simplification causes issues:
1. `git revert` the phase commits to restore cross-platform support
2. Individual phases are independently revertible since each modifies distinct files (except Phase 1 which must be reverted together with Phases 3-4 since scripts depend on lib.sh)
3. The research report preserves the exact line numbers and content of what was removed, enabling surgical restoration if needed
