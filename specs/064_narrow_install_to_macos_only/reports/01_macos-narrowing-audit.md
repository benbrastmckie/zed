# Research Report: Task #64

**Task**: 64 - narrow_install_to_macos_only
**Started**: 2026-04-14T12:00:00Z
**Completed**: 2026-04-14T12:30:00Z
**Effort**: Medium-Large (7 scripts, 4 doc files, ~40 context/doc files with minor mentions)
**Dependencies**: None
**Sources/Inputs**:
- Codebase audit of all `scripts/install/*.sh` files
- Documentation audit of `docs/`, `README.md`, `.claude/context/repo/project-overview.md`
- Cross-reference search for Linux-specific patterns across entire repository
**Artifacts**:
- `specs/064_narrow_install_to_macos_only/reports/01_macos-narrowing-audit.md`
**Standards**: report-format.md, artifact-management.md

## Executive Summary

- **7 installation scripts** need modification: `lib.sh` requires the heaviest rewrite (remove detect_os Linux branches, package name mapping, all Linux dispatchers); the 6 group scripts each have 3-8 Linux case branches to remove.
- **1 script to delete entirely**: `.claude/scripts/install-systemd-timer.sh` (Linux-only systemd timer). Also delete `.claude/systemd/` directory (2 files). No cross-references exist.
- **4 documentation files** have substantive Linux content requiring rewrite: `docs/general/installation.md`, `docs/toolchain/README.md`, `README.md`, `.claude/context/repo/project-overview.md`.
- **7 additional toolchain docs** have "> Linux alternatives" callout blocks to remove: `python.md`, `r.md`, `shell-tools.md`, `typesetting.md`, `extensions.md`, plus `docs/agent-system/architecture.md` and `docs/agent-system/README.md`.
- **~40 .claude/ context and doc files** contain incidental "Debian/Ubuntu, Arch/Manjaro" mentions in boilerplate platform lists. These are low-priority cosmetic fixes.
- Core architecture is well-preserved: idempotency, interactive_step, --dry-run, --check, presets all remain. The `lib.sh` abstraction layer can be significantly simplified since only Homebrew is needed.

## Context & Scope

The task is to strip all Linux platform support from the installation wizard and documentation, narrowing to macOS-only. The repository's install system was expanded to cross-platform in tasks 57-58 but the user wants to reverse that decision. The scope covers:

1. All scripts in `scripts/install/` (7 files)
2. The systemd timer script and associated files (3 files to delete)
3. All documentation referencing Linux platforms
4. Preservation of the clean architectural patterns (idempotency, interactive_step, presets, etc.)

## Findings

### File-by-File Audit: Installation Scripts

---

#### 1. `scripts/install/lib.sh` (806 lines) -- HEAVIEST REWRITE

This is the shared library sourced by all group scripts. It contains the platform detection, package name mapping, and cross-platform dispatch infrastructure.

**Sections to DELETE entirely:**

| Lines | Content | Action |
|-------|---------|--------|
| 55-101 | `detect_os()` Linux branches: /etc/os-release parsing, nixos/debian/arch/linux-unknown detection | Replace with simple Darwin check; set DETECTED_OS="macos" or "unsupported" |
| 277-303 | `assert_supported_os()` -- nixos, debian, arch, linux-unknown cases | Simplify to: if not macos, error and exit |
| 308-337 | `require_pkg_manager()` -- debian apt-get check, arch pacman check | Simplify to just `require_brew` |
| 339-419 | Entire package name mapping system: `PKG_MAP_CANONICAL`, `PKG_MAP_BREW`, `PKG_MAP_APT`, `PKG_MAP_PACMAN`, `_pkg_map_add`, `resolve_pkg_name()` | DELETE entirely. With only brew, scripts can call `brew_install_formula` directly. |
| 421-459 | `pkg_install()` -- debian apt-get dispatch, arch pacman dispatch | Replace with brew-only: just call `brew_install_formula` for each resolved name |
| 461-495 | `check_pkg_installed()` -- debian dpkg check, arch pacman -Qi check | Replace with brew-only: just call `check_brew_formula` |
| 573-605 | `sudo_install()` -- debian/arch branches | DELETE or simplify to just macOS (which already falls through to pkg_install) |
| 767-791 | `assert_git_or_hint()` -- debian/arch hints | Simplify to macOS-only hint |

**Sections to KEEP (unchanged or minor cleanup):**

| Lines | Content | Notes |
|-------|---------|-------|
| 1-49 | Header, guards, HOMEBREW env vars | Keep; update header comment |
| 106-132 | `is_headless()`, flag state, summary accumulators | Keep as-is |
| 134-228 | Logging helpers, prompt_yn, prompt_accept_skip_cancel | Keep as-is |
| 232-272 | `check_command`, `check_brew_formula`, `check_brew_cask`, `check_app_bundle`, `r_package_installed`, `uv_tool_installed`, `claude_mcp_has` | Keep as-is |
| 497-558 | `interactive_step()` | Keep as-is |
| 560-571 | `defer_hint()` | Keep as-is |
| 607-692 | `run_or_dry`, `brew_install_formula`, `brew_install_cask`, `brew_install_pkg_cask`, `print_deferred_hints` | Keep as-is |
| 694-733 | `print_common_help_footer`, `parse_common_flags` | Keep; update help text |
| 735-806 | `preset_groups`, `on_exit`, `assert_macos` (deprecated), `require_brew` | Keep |

**Architecture decision**: The `pkg_install()` / `resolve_pkg_name()` / package mapping system (~120 lines) can be replaced by a simple `brew_install` wrapper or direct `brew_install_formula` calls in each script. The abstraction was only needed for cross-platform dispatch. With brew-only, scripts become simpler and more direct.

**Estimated net change**: ~200 lines deleted, ~20 lines rewritten. lib.sh goes from ~806 lines to ~550 lines.

---

#### 2. `scripts/install/install.sh` (275 lines) -- MODERATE

**Sections to DELETE/SIMPLIFY:**

| Lines | Content | Action |
|-------|---------|--------|
| 2 | Comment "cross-platform" | Update to "macOS" |
| 7-8 | "Supported platforms: macOS, Debian/Ubuntu, Arch/Manjaro. NixOS..." | Update to macOS-only |
| 40-41 | Help text "Supported platforms: macOS, Debian/Ubuntu, Arch/Manjaro" and NixOS line | Simplify |
| 222-228 | NixOS early exit block (DETECTED_OS == "nixos") | DELETE |
| 230-234 | linux-unknown warning block | DELETE |

**Keep**: All wizard logic (resolve_groups, dispatch_group, interactive_wizard, presets). These are platform-agnostic.

**Estimated net change**: ~15 lines deleted, ~5 lines updated.

---

#### 3. `scripts/install/install-base.sh` (300 lines) -- MODERATE

**Sections to DELETE/SIMPLIFY:**

| Lines | Content | Action |
|-------|---------|--------|
| 2 | Comment "cross-platform" | Update |
| 3-10 | Multi-platform header listing Debian/Arch entries | Simplify to macOS only |
| 27-34 | Help text with Debian/Arch references | Simplify |
| 93-116 | `install_build_tools()` -- debian/arch branches | Keep only macOS (install_xcode_clt) |
| 118-128 | `install_pkg_manager()` -- Linux "already present" branch | Keep only macOS (install_homebrew) |
| 130-151 | `install_node()` -- debian/arch pkg_install branches | Keep only macOS brew_install_formula |
| 153-204 | `install_zed()` -- debian interactive_step, arch AUR helper detection | Keep only macOS brew_install_cask |
| 206-232 | `install_claude_cli()` -- Linux npm install branch | Keep only macOS brew_install_cask |
| 258-268 | `run_check_mode()` -- build-tools check for non-macOS | Keep only macOS xcode-clt check |

**Estimated net change**: ~80 lines deleted, ~10 lines updated.

---

#### 4. `scripts/install/install-shell-tools.sh` (128 lines) -- LIGHT

**Sections to DELETE/SIMPLIFY:**

| Lines | Content | Action |
|-------|---------|--------|
| 35-68 | `do_gh()` -- debian apt+repository setup, arch pkg_install | Keep only macOS brew_install_formula |
| 70-93 | `do_make()` -- Linux "comes with build tools" branch | Keep only macOS prompt |

**Note**: `do_jq()` and `do_fontconfig()` use `pkg_install` which routes through `lib.sh`. After lib.sh is simplified, these either call brew directly or use a simplified `pkg_install`.

**Estimated net change**: ~30 lines deleted, ~5 lines updated.

---

#### 5. `scripts/install/install-python.sh` (183 lines) -- LIGHT

**Sections to DELETE/SIMPLIFY:**

| Lines | Content | Action |
|-------|---------|--------|
| 38-59 | `do_core()` Python install -- debian apt + pip3/venv, arch branch | Keep only macOS brew |
| 63-83 | uv install -- Linux curl installer branch | Keep only macOS brew |
| 87-104 | ruff install -- Linux uv tool/pipx branch | Keep only macOS brew |

**Estimated net change**: ~35 lines deleted, ~5 lines updated.

---

#### 6. `scripts/install/install-r.sh` (311 lines) -- MODERATE-HEAVY

**Sections to DELETE entirely:**

| Lines | Content | Action |
|-------|---------|--------|
| 9-10 | Header about PPM on Linux | DELETE |
| 26-28 | PPM variable declaration | DELETE |
| 43-46 | Help text about PPM on Linux | DELETE |
| 49-107 | `configure_ppm()` entire function (Posit Package Manager for Linux binary R packages) | DELETE entirely |
| 120-130 | `r_install_pkg()` Linux timeout wrapper branch | Simplify to just Rscript call |
| 149-169 | `do_core()` R install -- debian r-base + r-base-dev, arch branch | Keep only macOS brew |
| 176 | `configure_ppm` call | DELETE |
| 193-233 | `do_quarto()` -- debian interactive_step + .deb download, arch AUR helper | Keep only macOS brew_install_pkg_cask |
| 246-253 | `do_epi_bundle()` Linux/PPM headless warning | DELETE |

**Estimated net change**: ~100 lines deleted, ~10 lines updated.

---

#### 7. `scripts/install/install-typesetting.sh` (247 lines) -- MODERATE

**Sections to DELETE/SIMPLIFY:**

| Lines | Content | Action |
|-------|---------|--------|
| 3-4 | Header mentioning Debian/Arch | Update |
| 25 | Help text mentioning Linux | Update |
| 72-101 | `do_latex()` -- debian and arch branches for texlive | Keep only macOS BasicTeX/MacTeX |
| 104-137 | `do_typst()` -- arch pacman, debian cargo/snap | Keep only macOS brew |
| 175-205 | `do_fonts()` -- debian and arch sudo_install branches | Keep only macOS cask installs |

**Estimated net change**: ~60 lines deleted, ~5 lines updated.

---

#### 8. `scripts/install/install-mcp-servers.sh` (164 lines) -- MINIMAL

**Sections requiring change:**

| Lines | Content | Action |
|-------|---------|--------|
| 109-119 | `do_obsidian_pointer()` -- xdg-open fallback for Linux | Remove the Linux `xdg-open` branch, keep macOS `open` |

This script is almost entirely platform-agnostic (uses `claude mcp add` and `uvx`). Only the obsidian pointer has a Linux branch.

**Estimated net change**: ~5 lines deleted.

---

### Files to DELETE Entirely

| File | Reason |
|------|--------|
| `.claude/scripts/install-systemd-timer.sh` | 100% Linux-only (systemd). 187 lines. |
| `.claude/systemd/claude-refresh.service` | systemd service unit file |
| `.claude/systemd/claude-refresh.timer` | systemd timer unit file |
| `.claude_OLD/scripts/install-systemd-timer.sh` | Old copy of the same (if cleaning up) |

**Cross-reference check**: No markdown, JSON, or script file references `install-systemd-timer` by name. The TODO.md mentions task 64 which describes it, but no code imports or sources it. Safe to delete.

---

### Documentation Audit

#### `docs/general/installation.md` (386 lines) -- MODERATE

**Sections to modify:**

| Lines | Content | Action |
|-------|---------|--------|
| 7 | "Supported platforms: macOS, Debian/Ubuntu, Arch/Manjaro" | macOS only |
| 33-49 | "Step by step (Linux)" entire section | DELETE |
| 49 | apt/pacman mention in wizard description | Simplify |
| 86-88 | "Before you begin" terminal mention for Linux | Simplify to macOS |
| 94-98 | Prerequisites listing Debian/Ubuntu and Arch/Manjaro | macOS only |
| 120-126 | "Install build tools" Linux alternatives callout | DELETE |
| 137 | Homebrew section "skip if on Linux" | Remove Linux note |
| 185-187 | Node.js Linux alternatives | DELETE |
| 217 | Zed Linux alternatives | DELETE |
| 244-245 | Claude Code Linux alternatives | DELETE |

**Estimated net change**: ~30 lines deleted, ~10 lines updated.

#### `docs/toolchain/README.md` (116 lines) -- MODERATE

**Sections to modify:**

| Lines | Content | Action |
|-------|---------|--------|
| 10-11 | "Platform scope" paragraph mentioning cross-platform | Simplify to macOS |
| 13-14 | Note about declarative package management | DELETE |
| 17-37 | Cross-platform package reference table (apt/pacman columns) | DELETE or reduce to brew-only column |
| 39 | Package manager prerequisite paragraph | Simplify |

**Estimated net change**: ~20 lines deleted/rewritten.

#### `README.md` (242 lines) -- MODERATE

**Sections to modify:**

| Lines | Content | Action |
|-------|---------|--------|
| 3 | "macOS, Debian/Ubuntu, and Arch/Manjaro" in description | macOS only |
| 5 | "Platforms: macOS 11+, Debian/Ubuntu, Arch/Manjaro" | macOS 11+ only |
| 21 | Quick start Linux Zed install alternative | DELETE |
| 229-234 | Platform Notes section -- Debian/Ubuntu and Arch/Manjaro bullets | DELETE |
| 236 | Language tooling mention of apt/pacman | Simplify |

**Estimated net change**: ~10 lines deleted, ~5 lines updated.

#### `.claude/context/repo/project-overview.md` (128 lines) -- LIGHT

**Sections to modify:**

| Lines | Content | Action |
|-------|---------|--------|
| 5 | "macOS, Debian/Ubuntu, and Arch/Manjaro" | macOS only |
| 16 | "Platform: macOS 11+, Debian/Ubuntu, Arch/Manjaro" | macOS 11+ only |

**Estimated net change**: 2 lines updated.

---

### Additional Toolchain Docs (7 files)

Each has "Linux alternatives" callout blocks that follow a consistent pattern (`> **Linux alternatives**: ...`). These are straightforward deletions:

| File | Linux References | Action |
|------|-----------------|--------|
| `docs/toolchain/python.md` | 3 callout blocks (lines 40-42, 72, 100) + 2 header mentions | Delete callouts, simplify headers |
| `docs/toolchain/r.md` | 3 callout blocks (lines 42-46, 245-247, 273) + 2 header mentions | Delete callouts, simplify headers |
| `docs/toolchain/shell-tools.md` | 6 callout blocks + 2 header mentions (13 total references) | Delete callouts, simplify headers |
| `docs/toolchain/typesetting.md` | 5 callout blocks (lines 75-79, 110-112, 148-150, 228-230) + 2 header mentions | Delete callouts, simplify headers |
| `docs/toolchain/extensions.md` | 1 mention | Minor update |
| `docs/agent-system/architecture.md` | 3 mentions | Minor updates |
| `docs/agent-system/README.md` | 1 mention | Minor update |

---

### .claude/ Context and System Files (~40 files)

The grep found ~49 files in `.claude/` containing "Debian/Ubuntu/Arch/Manjaro" references. Most are incidental mentions in boilerplate like "supports macOS, Debian/Ubuntu, Arch/Manjaro" in generated context files, agent definitions, and system documentation.

**High-priority .claude/ files** (contain substantive platform references):

| File | References | Action |
|------|-----------|--------|
| `.claude/CLAUDE.md` | 4 mentions in platform descriptions | Update |
| `.claude/README.md` | 4 mentions | Update |
| `.claude/context/repo/project-overview.md` | 4 mentions | Update (covered above) |

**Low-priority .claude/ files** (incidental mentions, can be done in a cleanup pass):

Most of the ~40 remaining files have 1-2 mentions in boilerplate strings like "macOS, Debian/Ubuntu, Arch/Manjaro" that are part of generated context summaries. These are cosmetic and can be batch-updated with a simple find-and-replace pattern.

---

### Architecture Patterns to Preserve

The following patterns are core to the install system and should be retained unchanged:

1. **Idempotency**: Every install action guarded by presence check (check_command, check_brew_formula, etc.)
2. **interactive_step()**: Manual step pattern with verify/retry/defer
3. **--dry-run support**: `run_or_dry` wrapper, `log_dry` messages
4. **--check mode**: Health report with `[ok]` / `[missing]` output
5. **--yes mode**: `prompt_yn` with ASSUME_YES
6. **Presets**: minimal, epi-demo, writing, everything
7. **Group dispatch**: Topological ordering, subprocess isolation, summary
8. **Deferred hints**: headless-friendly hint collection
9. **Bash 3.2 compatibility**: No mapfile, no nameref, no associative arrays

### Simplifications Enabled by macOS-Only

1. **Package name mapping eliminated**: No need for canonical -> brew/apt/pacman resolution. Scripts can call `brew_install_formula "jq"` directly instead of `pkg_install jq`.
2. **No `sudo_install`**: macOS rarely needs sudo for package installs (brew handles it). The `sudo_install` function and its `interactive_step` wrapper become unnecessary.
3. **No `check_pkg_installed`**: Simplifies to `check_brew_formula` directly.
4. **No `require_pkg_manager` dispatch**: Becomes just `require_brew`.
5. **No `configure_ppm`**: Posit Package Manager is Linux-only; CRAN binaries are standard on macOS.
6. **No `r_install_pkg` timeout**: The Linux timeout wrapper for source compilation is unnecessary; macOS R packages are pre-compiled binaries from CRAN.
7. **detect_os() becomes trivial**: Check `uname -s == Darwin`, done.

### Whether lib.sh Abstraction Is Still Useful

**Yes, but reduced**. Even with brew-only, lib.sh provides:
- Logging helpers (log_info, log_warn, log_error, log_ok, log_dry)
- Flag parsing (parse_common_flags)
- Prompt helpers (prompt_yn, prompt_accept_skip_cancel)
- Presence checks (check_command, check_brew_formula, check_brew_cask, check_app_bundle)
- Brew wrappers (brew_install_formula, brew_install_cask, brew_install_pkg_cask)
- interactive_step (still useful for Xcode CLT, tlmgr)
- run_or_dry
- Presets and exit trap

What becomes unnecessary:
- detect_os() complexity (trivial now)
- Package name mapping system (~80 lines)
- pkg_install / check_pkg_installed / sudo_install dispatch (~80 lines)
- assert_supported_os multi-platform logic (~25 lines)

**Recommendation**: Keep lib.sh as the shared library but remove the cross-platform abstraction layer. This cuts ~200 lines while preserving all the useful infrastructure.

## Decisions

1. **Delete systemd timer and related files**: `.claude/scripts/install-systemd-timer.sh`, `.claude/systemd/` directory. No cross-references exist.
2. **Simplify lib.sh, don't split it**: The library is still valuable for shared infrastructure; just remove the platform dispatch layer.
3. **Remove package name mapping entirely**: With brew-only, the canonical name abstraction adds complexity without value.
4. **Keep interactive_step**: Still needed for Xcode CLT install, tlmgr setup, and any future manual steps.
5. **Batch-update .claude/ context files**: Low-priority cosmetic pass to update ~40 files with "macOS, Debian/Ubuntu, Arch/Manjaro" boilerplate.

## Recommendations

**Phase 1 (Core scripts)**: Rewrite `lib.sh` first (heaviest change), then update all 6 group scripts. This is the critical path -- all scripts source lib.sh so it must be correct first.

**Phase 2 (Documentation)**: Update the 4 primary docs (`installation.md`, `toolchain/README.md`, `README.md`, `project-overview.md`) and 7 toolchain docs.

**Phase 3 (Cleanup)**: Delete systemd files. Batch-update .claude/ context files.

**Effort estimate**:
- Phase 1: ~3 hours (lib.sh is the most delicate rewrite)
- Phase 2: ~1.5 hours (mostly deletions and simplifications)
- Phase 3: ~0.5 hours (deletions and find-replace)
- **Total: ~5 hours**

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Breaking lib.sh sourcing for group scripts | Test with `--check` and `--dry-run` after rewrite |
| Missing a Linux branch in a script | Grep for `debian`, `arch`, `pacman`, `apt`, `DETECTED_OS` after completion |
| Bash 3.2 compatibility regression | Preserve existing compat patterns; test on macOS default bash |
| Orphaned functions in lib.sh | After rewrite, grep for all function definitions and verify each is called |

## Appendix

### Search Queries Used

1. `Glob **/*systemd*` -- found timer script and .claude/systemd/ directory
2. `Grep install-systemd-timer *.{md,json}` -- confirmed no cross-references
3. `Grep Debian|Ubuntu|Arch|Manjaro|pacman|apt-get|apt install *.{md,json,sh}` -- found 50 files
4. `Grep Posit Package Manager|PPM|os-release|linux-unknown|nixos` -- found 20 files
5. `Grep xdg-open|linux-unknown` in scripts/install/ -- found mcp-servers.sh and install.sh references

### Complete File Impact Summary

| Category | Files | Action | Estimated Lines Changed |
|----------|-------|--------|------------------------|
| Heavy rewrite | 1 (lib.sh) | Remove ~200 lines, rewrite ~20 | ~220 |
| Moderate rewrite | 5 (install.sh, install-base.sh, install-r.sh, install-typesetting.sh, install-shell-tools.sh) | Remove Linux branches | ~220 |
| Light rewrite | 2 (install-python.sh, install-mcp-servers.sh) | Remove Linux branches | ~40 |
| Delete entirely | 4 (systemd timer + 2 unit files + .claude_OLD copy) | Delete | ~190 |
| Primary docs | 4 (installation.md, toolchain/README.md, README.md, project-overview.md) | Remove Linux sections | ~70 |
| Toolchain docs | 7 (python.md, r.md, shell-tools.md, typesetting.md, extensions.md, 2 agent-system) | Remove callouts | ~60 |
| .claude/ cosmetic | ~40 files | Find-replace platform strings | ~50 |
| **Total** | **~63 files** | | **~850 lines** |
