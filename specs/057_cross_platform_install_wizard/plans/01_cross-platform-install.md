# Implementation Plan: Task #57

- **Task**: 57 - cross_platform_install_wizard
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: Task 31 (toolchain_installation_scripts) - COMPLETED (archived)
- **Research Inputs**: specs/057_cross_platform_install_wizard/reports/01_cross-platform-install.md
- **Artifacts**: plans/01_cross-platform-install.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The current install wizard (8 scripts, ~750 lines) is entirely macOS-specific: every script calls `assert_macos`, all package installation routes through Homebrew, and several steps depend on macOS-only concepts (Xcode CLT, .app bundles, `/Library/TeX/texbin`). This task makes the wizard platform-agnostic across macOS, Debian-family, and Arch Linux by introducing OS detection, a package manager abstraction layer, and a generalized `interactive_step` pattern that handles sudo/GUI/tty-requiring operations uniformly. The definition of done is: `bash scripts/install/install.sh --dry-run` completes cleanly on all three platform families, all 13 task 31 invariants are preserved, headless execution gracefully defers interactive steps, and the existing macOS path behaves identically to before.

### Research Integration

The research report identified: (1) every macOS-specific operation across all 8 scripts with cross-platform equivalents, (2) a complete package name mapping for ~30 tools across brew/apt/pacman, (3) the `interactive_step` pattern that generalizes the existing `brew_install_pkg_cask`/`DEFERRED_HINTS` mechanism to all sudo/GUI/tty steps with wait-and-verify, (4) R compilation timeout mitigation via Posit Package Manager (PPM) binaries on Linux plus per-package installation, (5) NixOS should be detect-and-skip for v1 with guidance to use a companion flake.nix, and (6) Bash 3.2 compatibility must be maintained in shared lib.sh code while Linux-specific paths can use bash 4+ features.

### Prior Plan Reference

No prior plan. Task 31's completed plan provided effort calibration (12 hours for 8 scripts from scratch; this refactoring effort is estimated at 10 hours since the architecture is already established). The task 31 plan also established the 13 invariants and design decisions that must be preserved.

### Roadmap Alignment

No ROADMAP.md items to advance (roadmap is empty). This task extends the reproducibility/onboarding story started by tasks 20, 27, 28, 30, 31.

## Goals & Non-Goals

**Goals**:
- Add OS detection (`detect_os`) to lib.sh, replacing `assert_macos` with `assert_supported_os`
- Create `pkg_install` dispatcher that routes to brew/apt/pacman based on detected OS
- Create cross-platform package name mapping table in lib.sh
- Create cross-platform presence check functions (`check_pkg_installed`) alongside existing brew-specific ones
- Implement `interactive_step` pattern: instruct, wait, verify (interactive) or defer (headless)
- Update all 6 per-group scripts to use platform-dispatched install functions
- Add PPM binary repository configuration for R on Linux to avoid compilation timeouts
- Add per-package R installation with generous timeouts for the epi bundle
- Detect NixOS and print guidance (exit cleanly, no imperative installs)
- Update `install.sh` help text to reflect cross-platform support
- Preserve all existing flags: `--dry-run`, `--check`, `--yes`, `--preset`, `--only`
- Preserve all 13 task 31 invariants (see research report section 7)
- Maintain Bash 3.2 compatibility in lib.sh (macOS constraint)

**Non-Goals**:
- NixOS imperative installation support (detect-and-skip only; companion flake.nix is a follow-up)
- AUR helper installation (detect yay/paru; fall back to instructions if absent)
- Flatpak as a primary install method (instructions only, not automated)
- Automated CI testing on Debian/Arch VMs (manual testing on author's machines)
- Brewfile generation or Nix flake generation
- Changes to `.claude/settings.json` or any runtime config
- Ubuntu PPA-specific paths (target "Debian-family" generically)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Package name mapping becomes stale across distros | M | M | Document canonical names with comments in lib.sh; `--check` mode catches drift |
| AUR packages require yay/paru helper not installed | M | H | Detect AUR helper; fall back to manual instructions with deferred hints |
| R compilation timeouts in headless mode (epi bundle) | H | H | PPM binaries on Linux; per-package install; detect headless and warn |
| Zed not in standard Linux repos | M | H | Support multiple methods: .deb download URL, AUR, flatpak; defer if headless |
| uv and ruff not in standard Linux repos | M | H | Use curl installer for uv; install ruff via uv/pipx; document alternatives |
| Bash 3.2 compat constrains cross-platform patterns in lib.sh | L | L | Only shared code needs 3.2; platform-specific branches can use bash 4+ |
| sudo password prompts in headless/CI | H | M | interactive_step pattern with defer-and-verify; never call sudo blindly |
| Regression in existing macOS path | H | M | Phase 6 dedicated verification; --dry-run comparison before/after |
| Debian vs Ubuntu package availability differences | L | M | Target Debian-family generically; document Ubuntu-specific PPAs as optional |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 2 |
| 5 | 6 | 3, 4, 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: lib.sh Platform Abstraction Layer [COMPLETED]

**Goal**: Add OS detection, package manager abstraction, cross-platform presence checks, the `interactive_step` pattern, and headless detection to lib.sh without breaking any existing macOS functionality.

**Tasks**:
- [ ] Add `detect_os()` function using `uname -s` + `/etc/os-release` parsing; sets global `DETECTED_OS` to one of: `macos`, `debian`, `arch`, `nixos`, `linux-unknown`, `unsupported`
- [ ] Add `DETECTED_OS=""` to the global state section; call `detect_os` at source time (after the double-source guard)
- [ ] Replace `assert_macos` with `assert_supported_os` that accepts macos/debian/arch and rejects nixos (with guidance) and unsupported
- [ ] Keep `assert_macos` as a deprecated wrapper calling `assert_supported_os` for any scripts that still reference it during transition
- [ ] Add `is_headless()` function: returns 0 if no tty detected (`! tty -s 2>/dev/null`) and no `FORCE_INTERACTIVE` env var
- [ ] Add `pkg_install()` dispatcher: takes a canonical package name, resolves to platform-specific name via `resolve_pkg_name`, dispatches to brew/apt/pacman
- [ ] Add `resolve_pkg_name()` with the complete package mapping table from research (using parallel arrays for Bash 3.2 compat, not associative arrays)
- [ ] Add `check_pkg_installed()` dispatcher: checks via brew list / dpkg -l / pacman -Qi based on DETECTED_OS
- [ ] Add `require_pkg_manager()` to replace `require_brew`: on macOS requires brew, on Debian checks apt, on Arch checks pacman
- [ ] Implement `interactive_step()` function with signature: `interactive_step "description" "manual_command" "verify_command" "why_needed"` -- idempotent (verify first), interactive (instruct + wait + verify + retry up to 3), headless (defer to DEFERRED_HINTS)
- [ ] Refactor `defer_hint()` as a standalone helper extracted from `brew_install_pkg_cask` for reuse by `interactive_step`
- [ ] Update `print_deferred_hints()` to include the "why needed" field
- [ ] Add `sudo_install()` helper: wraps `sudo apt-get install -y` / `sudo pacman -S --noconfirm` with `interactive_step` for sudo authentication
- [ ] Keep all existing brew-specific helpers (`brew_install_formula`, `brew_install_cask`, `brew_install_pkg_cask`) unchanged for backward compat
- [ ] Update `assert_git_or_hint()` to give platform-appropriate hints (not just "xcode-select --install")
- [ ] Maintain Bash 3.2 compatibility: no associative arrays, no nameref, no mapfile, no `${var,,}`
- [ ] Run `shellcheck scripts/install/lib.sh`

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `scripts/install/lib.sh` - add ~150 lines of platform abstraction (OS detection, pkg_install, interactive_step, presence checks)

**Verification**:
- `bash -n scripts/install/lib.sh` parses cleanly
- `shellcheck scripts/install/lib.sh` reports no errors
- Sourcing lib.sh on macOS sets `DETECTED_OS=macos`; on Debian sets `DETECTED_OS=debian`; on Arch sets `DETECTED_OS=arch`
- `interactive_step` with an already-satisfied verify_cmd returns immediately
- All existing brew helpers still work unchanged
- No Bash 3.2 incompatible constructs (grep for mapfile, nameref, `${var,,}`, `declare -A`)

---

### Phase 2: install-base.sh Cross-Platform [COMPLETED]

**Goal**: Make install-base.sh work on macOS, Debian, and Arch by replacing macOS-only bootstrap steps with platform-dispatched equivalents.

**Tasks**:
- [ ] Replace `assert_macos` with `assert_supported_os`
- [ ] Refactor `install_xcode_clt()` to be macOS-only (wrap in `if [ "$DETECTED_OS" = "macos" ]`); on Linux, install build-essential (Debian) or base-devel (Arch) via `interactive_step` for sudo
- [ ] Refactor `install_homebrew()` to be macOS-only; on Linux, skip (package manager is already present)
- [ ] Refactor `install_node()`: macOS uses `brew_install_formula node`; Debian uses `pkg_install nodejs` + `pkg_install npm`; Arch uses `pkg_install nodejs` + `pkg_install npm`
- [ ] Refactor `install_zed()`: macOS uses cask; Debian uses `interactive_step` with instructions to download .deb from zed.dev or use flatpak; Arch uses AUR `zed-editor` or flatpak
- [ ] Refactor `install_claude_cli()`: macOS uses cask; Linux uses `npm install -g @anthropic-ai/claude-code` (check node first)
- [ ] Keep MCP server registration (`install_mcp_superdoc`, `install_mcp_openpyxl`) unchanged (already platform-neutral)
- [ ] Update `run_check_mode()` to use platform-appropriate presence checks (e.g., `check_pkg_installed` instead of `check_brew_cask`)
- [ ] Update `print_section` banner and help text to say "base developer environment" instead of "macOS base developer environment"
- [ ] Run `shellcheck scripts/install/install-base.sh`

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `scripts/install/install-base.sh` - refactor all install functions for cross-platform dispatch

**Verification**:
- `shellcheck` clean
- `--dry-run` on macOS shows identical output to current behavior
- `--dry-run` on Debian shows apt-based install commands
- `--dry-run` on Arch shows pacman-based install commands
- `--check` works on all platforms

---

### Phase 3: Per-Group Scripts Cross-Platform (shell-tools, python, mcp-servers) [COMPLETED]

**Goal**: Make install-shell-tools.sh, install-python.sh, and install-mcp-servers.sh cross-platform. These three are the simplest to convert because their packages have direct equivalents or are already platform-neutral.

**Tasks**:
- [ ] **install-shell-tools.sh**: Replace `assert_macos` with `assert_supported_os`; replace `require_brew` with `require_pkg_manager`; replace `brew_install_formula jq` with `pkg_install jq`; replace `brew_install_formula gh` with platform-dispatched install (gh requires GitHub apt repo on Debian, `github-cli` on Arch); replace `brew_install_formula fontconfig` with `pkg_install fontconfig`; update `do_make()` for Linux (make comes with build tools); update check mode
- [ ] **install-python.sh**: Replace `assert_macos` with `assert_supported_os`; replace `require_brew` with `require_pkg_manager`; replace brew-based python/uv/ruff installs with platform dispatch; on Debian `pkg_install python3 python3-pip python3-venv`; uv via curl installer on Linux (`curl -LsSf https://astral.sh/uv/install.sh | sh`); ruff via `uv tool install ruff` or `pipx install ruff` on Linux; keep uv tools and filetypes packages sections unchanged (platform-neutral via uv/pip3); update check mode
- [ ] **install-mcp-servers.sh**: Replace `assert_macos` with `assert_supported_os`; remove `require_brew` (not needed -- all MCP servers use uvx/npx which are platform-neutral); update `do_obsidian_pointer()` to use `xdg-open` instead of `open` on Linux; update help text and banners
- [ ] Update all three scripts' help text to remove "macOS" references
- [ ] Run `shellcheck` on all three scripts

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `scripts/install/install-shell-tools.sh` - cross-platform package dispatch
- `scripts/install/install-python.sh` - cross-platform python/uv/ruff install methods
- `scripts/install/install-mcp-servers.sh` - remove macOS gate, update open command

**Verification**:
- `shellcheck` clean on all three
- `--dry-run` on each platform shows appropriate commands
- `--check` works on all platforms
- MCP server registration remains platform-neutral

---

### Phase 4: install-r.sh Cross-Platform with Timeout Handling [COMPLETED]

**Goal**: Make install-r.sh work on Debian and Arch, configure PPM binary repository on Linux for fast R package installation, and add per-package installation with timeout handling for the epi bundle.

**Tasks**:
- [ ] Replace `assert_macos` with `assert_supported_os`; replace `require_brew` with `require_pkg_manager`
- [ ] Refactor R installation: macOS uses `brew_install_formula r`; Debian uses `pkg_install r-base` + `pkg_install r-base-dev`; Arch uses `pkg_install r`
- [ ] Add `configure_ppm()` function: on Linux, configure Posit Package Manager binary repo via `Rscript -e "options(repos = c(PPM = 'https://packagemanager.posit.co/cran/__linux__/<distro>/latest', CRAN = '$CRAN_REPO'))"` -- write to `~/.Rprofile` or pass inline. Detect distro codename from `/etc/os-release` (VERSION_CODENAME).
- [ ] Refactor `do_quarto()`: macOS uses `brew_install_pkg_cask quarto`; Debian uses `interactive_step` with instructions to download .deb from quarto.org; Arch uses AUR `quarto-cli-bin` or download
- [ ] Add timeout handling to `r_install_pkg()`: on Linux, use `timeout 600` (10 min per package) for source-compiled packages; log which package is being installed
- [ ] Add headless detection to `do_epi_bundle()`: if headless and no PPM configured, warn that compilation may take 30+ minutes and defer with instructions
- [ ] Add progress logging to epi bundle: print package name before each install, print count (e.g., "Installing 5/30: brms")
- [ ] Update `run_check_mode()` with platform-appropriate checks
- [ ] Update help text and banners
- [ ] Run `shellcheck scripts/install/install-r.sh`

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `scripts/install/install-r.sh` - cross-platform R install, PPM config, timeout handling

**Verification**:
- `shellcheck` clean
- `--dry-run` on macOS shows identical behavior to current
- `--dry-run` on Debian shows apt + PPM configuration
- `--check` works on all platforms
- Epi bundle shows progress logging (package N/M)
- Headless mode defers epi bundle with clear instructions

---

### Phase 5: install-typesetting.sh Cross-Platform [COMPLETED]

**Goal**: Make install-typesetting.sh work on Debian and Arch with platform-appropriate TeX Live, Typst, and font installation.

**Tasks**:
- [ ] Replace `assert_macos` with `assert_supported_os`; replace `require_brew` with `require_pkg_manager`
- [ ] Refactor `do_latex()`: macOS keeps current BasicTeX/MacTeX cask flow; Debian uses `interactive_step` for `sudo apt install texlive-base texlive-latex-extra latexmk biber` (basic) or `sudo apt install texlive-full` (full); Arch uses `sudo pacman -S texlive-basic texlive-latexextra texlive-binextra biber` (basic) or `texlive-most` (full)
- [ ] Remove macOS-specific TeX path handling (`/Library/TeX/texbin`); on Linux, TeX binaries are in standard PATH
- [ ] Refactor `sudo tlmgr` calls: only needed on macOS (BasicTeX path); on Linux, packages come from apt/pacman directly. Use `interactive_step` for the sudo tlmgr calls on macOS.
- [ ] Refactor `do_typst()`: macOS uses `brew_install_formula typst`; Arch has `typst` in community repo; Debian uses `cargo install typst-cli` or snap -- use `interactive_step` with instructions if neither cargo nor snap available
- [ ] Refactor `do_fonts()`: macOS uses brew font casks; Debian uses `pkg_install fonts-lmodern fonts-cmu fonts-noto`; Arch uses `pkg_install otf-latin-modern noto-fonts` + AUR for others
- [ ] Keep `do_pandoc()` and `do_markitdown()` largely unchanged (pandoc is same name everywhere; markitdown is via uv tool, platform-neutral)
- [ ] Update `run_check_mode()` with platform-appropriate checks (no brew cask checks on Linux)
- [ ] Update help text and banners
- [ ] Run `shellcheck scripts/install/install-typesetting.sh`

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `scripts/install/install-typesetting.sh` - cross-platform TeX, Typst, font installation

**Verification**:
- `shellcheck` clean
- `--dry-run` on macOS shows identical behavior to current
- `--dry-run` on Debian shows apt-based TeX and font installs
- `--dry-run` on Arch shows pacman-based installs
- `--check` works on all platforms
- sudo tlmgr steps use `interactive_step` on macOS

---

### Phase 6: Master Wizard Update and Integration Testing [NOT STARTED]

**Goal**: Update install.sh for cross-platform support, add NixOS detection, update all help text, and run comprehensive verification across all platforms and modes.

**Tasks**:
- [ ] Replace `assert_macos` with `assert_supported_os` in install.sh
- [ ] Add NixOS detection early in `main()`: if `DETECTED_OS=nixos`, print guidance ("NixOS detected; this imperative wizard is not designed for NixOS. Add packages to your configuration.nix or home.nix, or use the companion flake.nix when available.") and exit 0
- [ ] Add `linux-unknown` handling: print warning with detected distro info, offer to continue at user's risk
- [ ] Update `print_help()`: remove "macOS" from title, document supported platforms (macOS, Debian/Ubuntu, Arch/Manjaro), document NixOS behavior
- [ ] Update `describe_group()` descriptions to be platform-neutral (e.g., "Build tools, package manager, Node.js, Zed, Claude Code CLI" instead of "Xcode Command Line Tools, Homebrew, ...")
- [ ] Update `build_child_args()` to pass through any new platform-related flags if needed
- [ ] Update banner text in `print_section` calls throughout
- [ ] Run `shellcheck scripts/install/*.sh` on all 8 files
- [ ] Test `--dry-run` on macOS: verify output is identical to pre-change behavior
- [ ] Test `--dry-run` on Debian (or Ubuntu): verify appropriate apt commands
- [ ] Test `--dry-run` on Arch: verify appropriate pacman commands
- [ ] Test `--check` mode on all platforms
- [ ] Test `--preset epi-demo --dry-run` on all platforms
- [ ] Test headless detection: run with stdin redirected from /dev/null, verify interactive steps are deferred
- [ ] Test `interactive_step` manually: verify wait-and-verify loop works
- [ ] Verify no script reads any .md file at runtime (Lean MCP resurrection guard)
- [ ] Verify Ctrl-C mid-wizard still prints partial summary
- [ ] Verify all 13 task 31 invariants still hold (see research report section 7)
- [ ] Update docs: change `docs/general/installation.md` wizard section to mention Linux support; update `scripts/install/` README or help text if any

**Timing**: 1.5 hours

**Depends on**: 2, 3, 4, 5

**Files to modify**:
- `scripts/install/install.sh` - cross-platform support, NixOS detection, updated help/descriptions
- `docs/general/installation.md` - mention Linux support in wizard section (minimal update)

**Verification**:
- `shellcheck` clean on all 8 scripts
- `--dry-run` on macOS produces identical output to pre-change
- `--dry-run` on Debian/Arch produces platform-appropriate commands
- `--check` works on all platforms
- `--preset epi-demo --dry-run` works on all platforms
- Headless mode defers all interactive steps
- All 13 task 31 invariants preserved
- NixOS detected and handled gracefully
- No script reads .md files at runtime

## Testing & Validation

- [ ] `shellcheck` reports no errors on all 8 scripts in `scripts/install/`
- [ ] `bash scripts/install/install.sh --help` reflects cross-platform support
- [ ] `bash scripts/install/install.sh --dry-run` works on macOS, Debian, Arch
- [ ] `bash scripts/install/install.sh --check` produces correct health report per platform
- [ ] `bash scripts/install/install.sh --preset epi-demo --dry-run` works on all platforms
- [ ] `bash scripts/install/install.sh --only r --dry-run` works on all platforms
- [ ] Headless execution (no tty) defers interactive steps to DEFERRED_HINTS
- [ ] `interactive_step` verifies after user acknowledgment; retries on failure; allows skip
- [ ] R epi bundle on Linux uses PPM binaries when available
- [ ] R epi bundle shows per-package progress logging
- [ ] NixOS detection prints guidance and exits cleanly
- [ ] Ctrl-C mid-wizard prints partial summary
- [ ] No script reads any .md file at runtime (Lean MCP resurrection guard)
- [ ] All existing flags (`--dry-run`, `--check`, `--yes`, `--preset`, `--only`) continue to work
- [ ] Bash 3.2 compatibility maintained in lib.sh (no mapfile, nameref, associative arrays, `${var,,}`)

## Artifacts & Outputs

- `scripts/install/lib.sh` - modified (platform abstraction layer added)
- `scripts/install/install.sh` - modified (cross-platform support, NixOS detection)
- `scripts/install/install-base.sh` - modified (cross-platform bootstrap)
- `scripts/install/install-shell-tools.sh` - modified (cross-platform package dispatch)
- `scripts/install/install-python.sh` - modified (cross-platform python/uv/ruff)
- `scripts/install/install-r.sh` - modified (cross-platform R, PPM, timeout handling)
- `scripts/install/install-typesetting.sh` - modified (cross-platform TeX, Typst, fonts)
- `scripts/install/install-mcp-servers.sh` - modified (remove macOS gate, update open)
- `docs/general/installation.md` - minor update (mention Linux support)

## Rollback/Contingency

- All changes modify existing files. Full rollback is `git checkout -- scripts/install/ docs/general/installation.md`.
- If a specific platform proves too complex during implementation, that platform's branches can be stubbed with `interactive_step` deferrals that print manual instructions, keeping the wizard functional on other platforms.
- If the package name mapping table grows unwieldy, it can be extracted to a separate `scripts/install/pkg-map.sh` file sourced by lib.sh.
- If R PPM binary configuration proves unreliable, fall back to source compilation with generous timeouts and a headless warning.
- The existing macOS path can be preserved as-is by gating new code behind `DETECTED_OS` checks, ensuring zero regression risk for the primary platform.
