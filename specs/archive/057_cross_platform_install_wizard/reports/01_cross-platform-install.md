# Research Report: Task #57

**Task**: 57 - cross_platform_install_wizard
**Started**: 2026-04-13T10:00:00Z
**Completed**: 2026-04-13T10:45:00Z
**Effort**: 2-3 hours research
**Dependencies**: Task 31 (toolchain_installation_scripts) - COMPLETED (archived)
**Sources/Inputs**:
- Codebase: `scripts/install/*.sh` (8 files)
- Codebase: `specs/archive/031_toolchain_installation_scripts/` (plan, summary, reports)
- Codebase: `lib.sh` deferred-hints pattern analysis
**Artifacts**: specs/057_cross_platform_install_wizard/reports/01_cross-platform-install.md
**Standards**: report-format.md, artifact-formats.md

## Executive Summary

- The current install wizard (8 scripts, ~750 lines) is entirely macOS-specific: every script calls `assert_macos`, all package installation routes through Homebrew, and several steps depend on macOS-only concepts (Xcode CLT, .app bundles, `/Library/TeX/texbin`).
- Cross-platform support requires (a) replacing `assert_macos` with OS detection, (b) abstracting package installation behind a `pkg_install` dispatcher that selects brew/apt/pacman, (c) handling platform-specific bootstrapping (Xcode CLT on macOS, build-essential on Debian, base-devel on Arch), and (d) mapping ~30 packages across three package managers.
- The existing `brew_install_pkg_cask` / `DEFERRED_HINTS` pattern in lib.sh is a solid foundation for the "wait-and-verify" interactive pattern needed for all sudo/tty-requiring steps across platforms.
- R package compilation timeouts are a real concern for headless execution: the epi bundle (~30 packages) can take 30+ minutes; the solution is background compilation with periodic progress checks rather than relying on bash's `read` timeout.
- NixOS support is architecturally different (declarative, not imperative) and should be a separate `--nix` path or companion script rather than shoehorned into the imperative wizard.

## Context & Scope

Task 57 asks to make the existing macOS-only install wizard cross-platform (macOS, Debian, Arch) while also improving headless/tty-aware execution. The developer works on NixOS, making this task personally relevant. The wizard must preserve all existing functionality (flags, presets, idempotency, subprocess isolation, Lean MCP resurrection guard) while adding platform detection and graceful degradation for non-interactive environments.

### Constraints
- Bash 3.2 compatibility (macOS default) must be preserved for the macOS path
- The "scripts never read markdown" hard invariant from task 31 must be maintained
- Every action must remain idempotent with presence checks
- The `--dry-run`, `--check`, `--yes`, `--preset`, `--only` flags must continue to work

## Findings

### 1. Current Architecture

**File inventory** (8 files, ~750 total lines):

| File | Lines | Purpose | macOS-specific? |
|------|-------|---------|-----------------|
| `lib.sh` | 397 | Shared helpers: logging, prompts, presence checks, flag parsing, exit trap | Yes (assert_macos, brew helpers, HOMEBREW_* env vars) |
| `install.sh` | 253 | Master wizard: topological dispatch, presets, interactive prompts | Yes (assert_macos, help text says "macOS") |
| `install-base.sh` | 172 | Xcode CLT, Homebrew, Node, Zed, Claude CLI, MCP servers | Heavily macOS (Xcode, Homebrew bootstrap, .app bundles) |
| `install-shell-tools.sh` | 79 | jq, gh, make, fontconfig | Yes (all via brew) |
| `install-python.sh` | 129 | Python, uv, ruff + optional tools/packages | Yes (all via brew) |
| `install-r.sh` | 164 | R, languageserver/lintr/styler + Quarto + epi bundle | Yes (R via brew, Quarto via brew cask) |
| `install-typesetting.sh` | 179 | LaTeX, Typst, Pandoc, markitdown, fonts | Yes (brew casks, /Library/TeX paths) |
| `install-mcp-servers.sh` | 155 | rmcp, markitdown-mcp, mcp-pandoc | Partially (assert_macos, but MCP registration is platform-neutral) |

**Architecture patterns**:
- Every script sources `lib.sh` for shared helpers
- Master wizard dispatches per-group scripts as subprocesses (`bash "$script" $CHILD_ARGS`)
- Each script has uniform structure: `parse_common_flags` -> `assert_macos` -> `print_section` -> check/install functions -> `main()`
- Presence checks use `command -v`, `brew list`, `r_package_installed`, `uv_tool_installed`, `claude_mcp_has`
- `run_or_dry` wrapper handles `--dry-run` mode
- Exit trap prints summary of OK/SKIPPED/FAILED groups

**Topological order**: base -> shell-tools -> python -> r -> typesetting -> mcp-servers (justified: markitdown needs uv; rmcp needs uv+R; claude mcp add needs claude CLI from base).

### 2. Platform-Specific Operations Inventory

#### macOS-only operations that need cross-platform equivalents:

**A. Bootstrap / Foundation (install-base.sh)**

| Operation | macOS | Debian Equivalent | Arch Equivalent |
|-----------|-------|-------------------|-----------------|
| Xcode CLT install | `xcode-select --install` (GUI dialog) | `sudo apt install build-essential` | `sudo pacman -S base-devel` |
| Homebrew bootstrap | curl Homebrew installer | N/A (use apt directly) | N/A (use pacman directly) |
| Post-install PATH fixup | `/opt/homebrew/bin/brew` shellenv | N/A | N/A |
| Zed install | `brew install --cask zed` | Download .deb from zed.dev or flatpak | AUR `zed-editor` or flatpak |
| Claude Code CLI | `brew install --cask claude-code` | `npm install -g @anthropic-ai/claude-code` | `npm install -g @anthropic-ai/claude-code` |
| `.app` bundle check | `check_app_bundle "Zed.app"` | `command -v zed` or `dpkg -l zed` | `command -v zed` or `pacman -Qi zed` |

**B. Package installation dispatch**

| lib.sh function | macOS impl | Debian equiv | Arch equiv |
|----------------|-----------|--------------|------------|
| `brew_install_formula` | `brew install X` | `sudo apt install X` | `sudo pacman -S X` |
| `brew_install_cask` | `brew install --cask X` | N/A (use native pkg or flatpak) | N/A (use AUR or flatpak) |
| `brew_install_pkg_cask` | brew cask + sudo detection | `sudo apt install X` (simpler) | `sudo pacman -S X` (simpler) |
| `check_brew_formula` | `brew list --formula X` | `dpkg -l X` or `command -v X` | `pacman -Qi X` |
| `check_brew_cask` | `brew list --cask X` | `dpkg -l X` or flatpak check | `pacman -Qi X` or AUR check |

**C. Platform-specific paths and behaviors**

| Item | macOS | Debian | Arch |
|------|-------|--------|------|
| TeX path | `/Library/TeX/texbin` | `/usr/bin` (via texlive) | `/usr/bin` (via texlive) |
| Font install | brew cask fonts | `sudo apt install fonts-X` | `sudo pacman -S ttf-X` or AUR |
| Font config | `fc-list` (via brew fontconfig) | `fc-list` (via `apt install fontconfig`) | `fc-list` (via `pacman -S fontconfig`) |
| Obsidian | `open file.md` | `xdg-open file.md` | `xdg-open file.md` |

### 3. TTY/Headless Issues Inventory

Every point where the scripts require interactive input:

| Location | Interaction Type | Can Automate? | Headless Strategy |
|----------|-----------------|---------------|-------------------|
| `install_xcode_clt()` in install-base.sh:53 | GUI dialog (`xcode-select --install`) + "Press Enter" wait | No (macOS GUI required) | Defer with instructions |
| `install_homebrew()` in install-base.sh:74 | Homebrew bootstrap (may prompt for sudo) | Partially (NONINTERACTIVE=1 env var) | Defer with instructions |
| `prompt_yn()` in lib.sh:101 | Y/N prompts throughout all scripts | Yes (`--yes` flag) | `--yes` auto-accepts defaults |
| `prompt_accept_skip_cancel()` in lib.sh:139 | Accept/skip/cancel per group | Yes (`--yes` auto-accepts) | `--yes` or `--preset` |
| `brew_install_pkg_cask()` in lib.sh:247 | sudo for .pkg installers | Already handled | DEFERRED_HINTS pattern |
| `sudo tlmgr update/install` in install-typesetting.sh:64-65 | sudo for TeX Live manager | No (needs sudo) | Defer with instructions |
| `do_epi_bundle()` in install-r.sh:117-127 | R package compilation (long-running) | Yes, but timeout risk | Background + progress check |
| `do_obsidian_pointer()` in install-mcp-servers.sh:108 | `open` command for setup guide | No (optional, already skip-safe) | Log instructions only |

**Categorization**:
- **Fully automatable**: All `prompt_yn` and `prompt_accept_skip_cancel` calls (via `--yes`)
- **Requires sudo**: Homebrew bootstrap, .pkg cask installs, `sudo tlmgr`, `sudo apt install`, `sudo pacman -S`
- **Requires GUI**: Xcode CLT dialog (macOS only)
- **Long-running risk**: R epi bundle compilation (30+ minutes possible)

### 4. The brew_install_pkg_cask / DEFERRED_HINTS Pattern

**Current implementation** (lib.sh lines 247-293):

```
brew_install_pkg_cask(cask, manual_cmd, description):
  1. Check if already installed -> return early
  2. If dry-run -> log and return
  3. Check: can we run sudo non-interactively (`sudo -n true`) OR is there a tty?
     - Neither available: append to DEFERRED_HINTS, log warning, return 0
     - One available: proceed with `brew install --cask`
  4. At script end: print_deferred_hints() shows manual commands

print_deferred_hints():
  - Iterates DEFERRED_HINTS (TAB-separated "command\tdescription" pairs)
  - Prints "Manual steps required" section with commands and explanations
```

**Extension opportunities for the cross-platform wizard**:

The DEFERRED_HINTS pattern should be generalized to a `defer_interactive_step()` function that:
1. Records the command, description, verification command, and reason (which workflows depend on it)
2. In interactive mode: pauses, tells user to run it in another terminal, waits for Enter, then verifies
3. In headless mode: appends to deferred hints for end-of-run display
4. After user says "done": runs the verification command; if it fails, offers retry or skip

**Proposed generalized signature**:
```bash
interactive_step "description" "manual_command" "verify_command" "why_needed"
```

This subsumes `brew_install_pkg_cask` and handles all sudo/GUI/tty-requiring steps uniformly.

### 5. R Package Compilation Timeouts

**The problem**: Claude Code's bash tool has a default 120-second (2 minute) timeout. R package compilation, especially for the epi bundle (~30 packages including Stan-dependent `brms` and `rstanarm`), can take 30-60 minutes.

**Specific high-compilation-time packages**:
- `brms` / `rstanarm`: Stan C++ compilation, 10-20 minutes each
- `survival`, `data.table`: C compilation, 2-5 minutes each
- `tidybayes`, `posterior`: Template-heavy C++, 3-5 minutes each

**Mitigation strategies**:

1. **Background compilation with progress polling**: Run `Rscript -e "install.packages(...)"` in background, check `ps` periodically, report progress by monitoring the R library directory for new package directories appearing.

2. **Batch with explicit timeout**: Use `timeout` command (coreutils) with a generous limit (e.g., 45 minutes), but this kills the whole batch on timeout.

3. **Per-package installation with individual timeouts**: Install each package individually with its own timeout, so a single slow package does not block the rest. Failed packages are logged and reported.

4. **Pre-compiled binaries**: On macOS, CRAN provides pre-compiled binaries for most packages. On Linux, use Posit Package Manager (PPM) binary repository (`options(repos = c(PPM = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"))`). This reduces compile times from minutes to seconds.

5. **Detect headless and warn**: If no tty is detected and the epi bundle is requested, warn that compilation may take 30+ minutes and suggest running manually.

**Recommendation**: Combine strategies 3 and 4. Use PPM binaries on Linux to mostly avoid compilation. For remaining source-compiles, install per-package with generous timeouts (10 min each). Log progress so the user can see which package is being compiled.

### 6. Cross-Platform Package Mapping

**Complete mapping of every tool installed by the wizard**:

| Tool | macOS (brew) | Debian (apt) | Arch (pacman/AUR) | Notes |
|------|-------------|-------------|-------------------|-------|
| **Base group** | | | | |
| Build tools | `xcode-select --install` | `build-essential` | `base-devel` | Compilers, make, git |
| Git | (via Xcode CLT) | `git` | `git` | Usually already present |
| Node.js | `node` (formula) | `nodejs npm` | `nodejs npm` | |
| Zed | `zed` (cask) | zed.dev .deb / flatpak | AUR `zed-editor` / flatpak | GUI app |
| Claude Code CLI | `claude-code` (cask) | `npm i -g @anthropic-ai/claude-code` | `npm i -g @anthropic-ai/claude-code` | Or via brew on Linux |
| **Shell tools group** | | | | |
| jq | `jq` (formula) | `jq` | `jq` | Same name everywhere |
| gh | `gh` (formula) | `gh` (via GitHub apt repo) | `github-cli` | Different name on Arch |
| GNU make | `make` (formula, as gmake) | `make` (via build-essential) | `make` (via base-devel) | Already present from build tools |
| fontconfig | `fontconfig` (formula) | `fontconfig` | `fontconfig` | Same name everywhere |
| **Python group** | | | | |
| Python 3 | `python` (formula) | `python3 python3-pip python3-venv` | `python python-pip` | Need pip and venv on Debian |
| uv | `uv` (formula) | curl installer or pipx | `uv` (AUR) or curl installer | Not in standard repos |
| ruff | `ruff` (formula) | `pipx install ruff` or cargo | `ruff` (AUR) or pipx | Not in standard repos |
| **R group** | | | | |
| R | `r` (formula) | `r-base r-base-dev` | `r` | Need r-base-dev on Debian for compilation |
| Quarto | `quarto` (cask, .pkg) | .deb from quarto.org | AUR `quarto-cli-bin` | Not in standard repos |
| **Typesetting group** | | | | |
| LaTeX (basic) | `basictex` (cask, .pkg) | `texlive-base texlive-latex-extra` | `texlive-basic texlive-latexextra` | Different package granularity |
| LaTeX (full) | `mactex` (cask, .pkg) | `texlive-full` | `texlive-most` | ~5 GB |
| latexmk | (via tlmgr) | `latexmk` | `texlive-binextra` | Separate package on Debian |
| biber | (via tlmgr) | `biber` | `biber` | |
| Typst | `typst` (formula) | cargo or snap | `typst` (AUR) | Not in standard Debian repos |
| Pandoc | `pandoc` (formula) | `pandoc` | `pandoc` | Same name |
| markitdown | `uv tool install` | `uv tool install` | `uv tool install` | Platform-neutral via uv |
| **Fonts** | | | | |
| Latin Modern | `font-latin-modern` (cask) | `fonts-lmodern` | `otf-latin-modern` | |
| Latin Modern Math | `font-latin-modern-math` (cask) | `fonts-lmodern` (included) | `otf-latinmodern-math` (AUR) | |
| Computer Modern | `font-computer-modern` (cask) | `cm-super` or `fonts-cmu` | `otf-cm-unicode` (AUR) | |
| Noto Sans | `font-noto-sans` (cask) | `fonts-noto` | `noto-fonts` | |
| Noto Serif | `font-noto-serif` (cask) | `fonts-noto` (included) | `noto-fonts` (included) | |
| Noto Sans Mono | `font-noto-sans-mono` (cask) | `fonts-noto` (included) | `noto-fonts` (included) | |
| **MCP servers** | | | | |
| superdoc | `claude mcp add` + npx | same | same | Platform-neutral |
| openpyxl | `claude mcp add` + npx | same | same | Platform-neutral |
| rmcp | `claude mcp add` + uvx | same | same | Platform-neutral |
| markitdown-mcp | `claude mcp add` + uvx | same | same | Platform-neutral |
| mcp-pandoc | `claude mcp add` + uvx | same | same | Platform-neutral |

### 7. Task 31 Design Decisions to Preserve

From the task 31 plan and summary, these design decisions are foundational and must be preserved:

1. **No markdown scraping**: Scripts never read .md files at runtime (Lean MCP resurrection guard).
2. **Topological order**: base -> shell-tools -> python -> r -> typesetting -> mcp-servers.
3. **Subprocess isolation**: Each group runs as a child bash process; failure does not abort wizard.
4. **Uniform flag interface**: Every script supports `--dry-run`, `--check`, `--yes`, `--help`.
5. **Idempotency**: Every install action guarded by presence check.
6. **CRAN mirror pinning**: `repos="https://cloud.r-project.org"` to skip mirror selection.
7. **Logging to stderr**: Never pollutes stdout for command substitution callers.
8. **Presets**: minimal, epi-demo, writing, everything.
9. **`--check` contract**: Co-designed with future `/doctor` command. Uniform exit codes.
10. **Lean MCP intentionally absent**: Comment header in install-mcp-servers.sh.
11. **obsidian-memory**: Print-and-skip with offer to open setup guide.
12. **Ctrl-C safety**: `trap on_exit EXIT INT TERM` prints partial summary.
13. **Bash 3.2 compatibility**: No mapfile, no nameref, no associative arrays, no `${var,,}`.

### 8. Interactive Wait-and-Verify Pattern

**Best practices for "pause, instruct, verify" in shell scripts**:

The pattern is:
```
1. Detect that an operation requires manual intervention
2. Print clear instructions: WHAT to run, WHY it's needed, WHERE to run it
3. Wait for user acknowledgment (Enter key)
4. Verify the operation actually succeeded
5. If verification fails: report failure, offer retry or skip
```

**Recommended implementation**:

```bash
interactive_step() {
  local description="$1"    # Human-readable description
  local manual_cmd="$2"     # Command for user to run
  local verify_cmd="$3"     # Command to verify success (exit 0 = success)
  local why_needed="$4"     # Which workflows depend on this

  # Already satisfied?
  if eval "$verify_cmd" >/dev/null 2>&1; then
    log_ok "$description (already done)"
    return 0
  fi

  # Headless mode: defer
  if ! tty -s 2>/dev/null; then
    defer_hint "$manual_cmd" "$description" "$why_needed"
    return 0
  fi

  # Interactive mode: instruct, wait, verify
  log_warn "$description requires manual action."
  log_info "WHY: $why_needed"
  log_info "Run this in another terminal tab:"
  log_info "  $manual_cmd"

  local max_attempts=3
  local attempt=0
  while [ "$attempt" -lt "$max_attempts" ]; do
    printf 'Press Enter when done (or "s" to skip)... ' >&2
    read -r reply </dev/tty 2>/dev/null || read -r reply
    if [ "$reply" = "s" ] || [ "$reply" = "skip" ]; then
      log_info "skipped: $description"
      return 0
    fi
    if eval "$verify_cmd" >/dev/null 2>&1; then
      log_ok "$description verified successfully"
      return 0
    fi
    attempt=$((attempt + 1))
    log_warn "Verification failed ($attempt/$max_attempts). The command may not have completed."
    if [ "$attempt" -lt "$max_attempts" ]; then
      log_info "Try again, or press 's' to skip."
    fi
  done
  log_error "$description: verification failed after $max_attempts attempts"
  log_error "Continuing, but dependent workflows may not work: $why_needed"
  return 0  # Don't abort the wizard
}
```

**Key design choices**:
- Never abort the wizard on verification failure (matches existing subprocess isolation philosophy)
- Limit retry attempts (3) to prevent infinite loops
- Allow explicit skip
- In headless mode, fall through to deferred hints (existing pattern)
- Verify command is a shell expression evaluated with `eval` for flexibility

### 9. NixOS Considerations

The developer works on NixOS. Key observations:

**Why NixOS is architecturally different**:
- NixOS is declarative: packages are specified in `configuration.nix` or `home.nix`, not installed imperatively
- `nix-env -iA` exists for imperative installs but is discouraged
- Home Manager (`home-manager switch`) is the idiomatic way to manage user packages
- Nix flakes provide reproducible environments without system-level changes

**Options for NixOS support**:

1. **Companion `flake.nix`**: A Nix flake that provides a `devShell` with all tools. Users run `nix develop` instead of the bash wizard. This is the most idiomatic approach.

2. **`--nix` flag in the wizard**: Detect NixOS (`/etc/os-release` or presence of `/nix/store`) and generate a `home.nix` fragment or `flake.nix` instead of running install commands.

3. **Separate `install-nix.sh`**: A script that generates the appropriate Nix configuration file (home-manager or flake) listing all packages.

4. **Skip entirely with guidance**: Detect NixOS, print a message saying "NixOS detected; use the companion flake.nix or add packages to your home.nix", and exit.

**Recommendation**: Option 4 for v1 (detect and print guidance). Option 1 (companion flake.nix) as a follow-up task. The imperative wizard pattern fundamentally conflicts with NixOS's declarative model, so trying to make the same script work on NixOS would be awkward.

**Detection**:
```bash
is_nixos() {
  [ -f /etc/NIXOS ] || ([ -f /etc/os-release ] && grep -qi nixos /etc/os-release 2>/dev/null)
}
```

## Decisions

1. **OS detection should replace assert_macos**: Use `uname -s` + `/etc/os-release` parsing to detect Darwin/Debian/Arch/NixOS. Store in a global `DETECTED_OS` variable set early in lib.sh.

2. **Package manager abstraction**: Create `pkg_install <canonical-name>` that dispatches to brew/apt/pacman based on DETECTED_OS, with a mapping table for name differences.

3. **The interactive_step pattern should generalize DEFERRED_HINTS**: A single function handles all sudo/GUI/tty requirements across all platforms, with verify-after-wait in interactive mode.

4. **R binary packages via PPM on Linux**: Use Posit Package Manager for pre-compiled R packages on Linux to avoid compilation timeouts.

5. **NixOS gets detect-and-skip for v1**: Print guidance, exit cleanly. Follow-up task for flake.nix.

6. **Bash 3.2 compat stays for macOS path**: Linux paths can use bash 4+ features since all target distros ship bash 5.x, but the shared lib.sh must remain 3.2-compatible.

7. **Preserve all existing flags and behaviors**: No breaking changes to the macOS path.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Package name mapping becomes stale | M | M | Document canonical names in lib.sh with version-pinning comments; `--check` mode catches drift |
| Debian vs Ubuntu differences (PPA availability) | L | M | Target "Debian-family" and document Ubuntu-specific PPAs as optional |
| AUR packages require `yay`/`paru` helper | M | H | Detect AUR helper presence; fall back to instructions for manual AUR install |
| R compilation timeouts in headless mode | H | H | PPM binaries on Linux; per-package install with generous timeouts; detect headless and warn |
| Zed not in standard repos (Debian/Arch) | M | H | Support multiple install methods: .deb download, flatpak, AUR; let user choose |
| `uv` and `ruff` not in standard repos | M | H | Use curl installer for uv; pipx or cargo for ruff; or use brew-on-linux |
| Bash 3.2 compat limits cross-platform patterns | L | L | Only shared lib.sh code needs 3.2; platform-specific code can use bash 4+ |
| sudo password prompts in headless/CI | H | M | interactive_step pattern with defer-and-verify; never call sudo without checking first |
| Claude Code bash timeout (120s default) kills long installs | H | H | Document that epi bundle must be run interactively or with extended timeout; detect headless mode |

## Appendix

### A. Files Examined

- `scripts/install/lib.sh` (397 lines)
- `scripts/install/install.sh` (253 lines)
- `scripts/install/install-base.sh` (172 lines)
- `scripts/install/install-shell-tools.sh` (79 lines)
- `scripts/install/install-python.sh` (129 lines)
- `scripts/install/install-r.sh` (164 lines)
- `scripts/install/install-typesetting.sh` (179 lines)
- `scripts/install/install-mcp-servers.sh` (155 lines)
- `specs/archive/031_toolchain_installation_scripts/plans/01_install-wizard-scripts.md`
- `specs/archive/031_toolchain_installation_scripts/summaries/01_install-wizard-summary.md`

### B. Proposed lib.sh OS Detection Skeleton

```bash
# OS detection - call once at lib.sh source time
detect_os() {
  local uname_s
  uname_s="$(uname -s)"
  case "$uname_s" in
    Darwin) DETECTED_OS="macos" ;;
    Linux)
      if [ -f /etc/NIXOS ]; then
        DETECTED_OS="nixos"
      elif [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        case "${ID:-}" in
          debian|ubuntu|linuxmint|pop) DETECTED_OS="debian" ;;
          arch|manjaro|endeavouros)     DETECTED_OS="arch" ;;
          nixos)                        DETECTED_OS="nixos" ;;
          *)                            DETECTED_OS="linux-unknown" ;;
        esac
      else
        DETECTED_OS="linux-unknown"
      fi
      ;;
    *) DETECTED_OS="unsupported" ;;
  esac
}

# Package manager dispatcher
pkg_install() {
  local canonical="$1"
  local pkg_name
  pkg_name="$(resolve_pkg_name "$canonical")"
  case "$DETECTED_OS" in
    macos)   brew_install_formula "$pkg_name" ;;
    debian)  run_or_dry sudo apt-get install -y "$pkg_name" ;;
    arch)    run_or_dry sudo pacman -S --noconfirm "$pkg_name" ;;
    nixos)   log_warn "NixOS: add '$pkg_name' to your configuration.nix or home.nix" ;;
    *)       log_error "unsupported OS for package install: $DETECTED_OS" ;;
  esac
}
```

### C. Proposed Implementation Phases (for planning reference)

1. **lib.sh refactoring**: OS detection, package manager abstraction, interactive_step pattern
2. **install-base.sh cross-platform**: Platform-specific bootstrapping (build tools, Node, Zed, Claude CLI)
3. **install-shell-tools.sh cross-platform**: Package name mapping for jq, gh, make, fontconfig
4. **install-python.sh cross-platform**: uv/ruff install methods per platform
5. **install-r.sh cross-platform**: R install + PPM binary repo + epi bundle timeout handling
6. **install-typesetting.sh cross-platform**: TeX Live, Typst, fonts per platform
7. **install-mcp-servers.sh + install.sh**: Help text updates, NixOS detection, final integration
8. **Testing and verification**: `--dry-run` and `--check` on all platforms
