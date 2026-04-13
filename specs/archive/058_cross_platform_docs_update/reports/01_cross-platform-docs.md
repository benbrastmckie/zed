# Research Report: Task #58

**Task**: 58 - cross_platform_docs_update
**Started**: 2026-04-13T10:00:00Z
**Completed**: 2026-04-13T10:45:00Z
**Effort**: medium
**Dependencies**: Task 57 (cross-platform install wizard)
**Sources/Inputs**:
- Codebase: all 9 documentation files listed in task description
- Codebase: `scripts/install/lib.sh` (package name mapping, platform detection, interactive_step)
- Codebase: `scripts/install/install-*.sh` (all 5 group scripts for cross-platform install logic)
**Artifacts**: specs/058_cross_platform_docs_update/reports/01_cross-platform-docs.md
**Standards**: report-format.md, artifact-management.md

## Executive Summary

- All 9 documentation files contain macOS-only language that must be updated to reflect the cross-platform wizard completed in task 57.
- The README.md and docs/toolchain/README.md contain explicit "macOS only" declarations that directly contradict the wizard's cross-platform support.
- The manual installation sections in installation.md, python.md, r.md, shell-tools.md, and typesetting.md show only `brew install` commands; cross-platform alternatives from lib.sh's package map need to be added.
- extensions.md and mcp-servers.md require lighter changes (mainly removing macOS-only framing and adding platform notes where install methods differ).
- lib.sh provides a complete package name mapping table (canonical -> brew/apt/pacman) that should be the source of truth for all documentation updates.

## Context & Scope

Task 57 added cross-platform support (macOS, Debian/Ubuntu, Arch/Manjaro) to all install scripts with OS detection, package manager abstraction, interactive_step pattern, PPM binary repos for R on Linux, and NixOS detect-and-skip. The documentation was not updated as part of that task. This research inventories every change needed across all 9 files.

### Conventions Used in This Report

- **[REMOVE]** = text to delete
- **[REPLACE]** = text to replace with cross-platform equivalent
- **[ADD]** = new text to insert
- Line numbers reference the current file state as read during research

## Findings

### File 1: README.md

**Current macOS-only references:**

| Line(s) | Issue | Change Needed |
|---------|-------|---------------|
| 1 | "A Zed editor configuration for macOS" | [REPLACE] with "A Zed editor configuration for macOS, Debian/Ubuntu, and Arch/Manjaro" |
| 3 | "**Platform**: macOS 11 (Big Sur) or newer." | [REPLACE] with multi-platform statement: macOS 11+, Debian/Ubuntu, Arch/Manjaro |
| 9 | "On a fresh Mac, the fastest path" | [REPLACE] "On a fresh Mac" with "On a fresh system" |
| 21 | "Install [Homebrew](https://brew.sh), then `brew install --cask zed`" | [ADD] Linux alternatives (download from zed.dev, or package manager) |
| 194 | Description: "Installation, keybindings, settings, and R/Python setup for this Zed configuration on macOS" | [REPLACE] "on macOS" with "on macOS, Debian/Ubuntu, and Arch/Manjaro" |
| 229-236 | Platform Notes section -- entirely macOS-focused | [REPLACE] with multi-platform section covering macOS, Debian/Ubuntu, and Arch |
| 231 | "macOS: Install via Homebrew" | [ADD] Linux install alternatives |
| 232 | "macOS keybindings" reference | Keep but add note about Linux key equivalents (Ctrl vs Cmd) |
| 233 | "Config location: `~/.config/zed/` -- standard for Zed on macOS" | [REPLACE] "on macOS" with "on all platforms" |
| 235 | "Install Python and R via Homebrew" | [ADD] cross-platform alternatives |

### File 2: docs/general/installation.md

**Current macOS-only references:**

| Line(s) | Issue | Change Needed |
|---------|-------|---------------|
| 8-9 | "Supported platforms" section already mentions cross-platform | OK -- already updated. Keep as-is. |
| 66-67 | "The target platform is macOS 11 (Big Sur) or newer" in manual section | [ADD] note that manual section covers macOS; wizard handles all platforms |
| 70-77 | Quick-reference command block: all `brew install` | [ADD] a parallel block or note for Linux manual install |
| 86-89 | "Before you begin" is macOS-Terminal-specific (Cmd+Space, Spotlight) | [ADD] Linux terminal instructions alongside macOS |
| 94 | "Prerequisites" lists only "macOS 11 (Big Sur) or newer" | [REPLACE] with multi-platform prereqs |
| 102-126 | "Install Xcode Command Line Tools" section | [ADD] Linux equivalent (`sudo apt install build-essential git` / `sudo pacman -S base-devel git`) |
| 129-159 | "Install Homebrew" section | This is macOS-specific by design; [ADD] note that on Linux, apt/pacman are used instead |
| 162-187 | "Install Node.js" section -- `brew install node` only | [ADD] cross-platform: apt (`nodejs npm`), pacman (`nodejs npm`) |
| 189-215 | "Install Zed" section -- `brew install --cask zed` only | [ADD] Linux install: download from zed.dev or package manager |
| 231-235 | "Install Claude Code CLI" -- `brew install --cask claude-code` | [ADD] npm/direct install for Linux |

**Note**: The "Installation wizard (recommended)" section (lines 1-61) is already well-updated with cross-platform support notes. The main gap is the "Manual installation (advanced)" section which remains entirely macOS/Homebrew.

### File 3: docs/toolchain/README.md

**Current macOS-only references:**

| Line(s) | Issue | Change Needed |
|---------|-------|---------------|
| 10-13 | **CRITICAL**: "This documentation is **macOS / Homebrew only**. Linux install paths (apt, nix, pacman, dnf) are explicitly out of scope per the task-21 'macOS Zed IDE' reframing." | [REMOVE] entirely -- this statement is now false. The wizard supports Linux. [REPLACE] with a statement that all tools are documented with cross-platform install commands. |
| 7 | References "Homebrew" as the single package manager | [REPLACE] with "the platform's package manager (Homebrew on macOS, apt on Debian/Ubuntu, pacman on Arch)" |
| 13 | "Homebrew itself is a prerequisite for every install step below" | [REPLACE] with cross-platform prerequisite statement |

### File 4: docs/toolchain/python.md

**Current macOS-only references:**

| Line(s) | Issue | Change Needed |
|---------|-------|---------------|
| 15 | "This guide walks through installing Python...on macOS for use with Zed" | [REPLACE] "on macOS" with cross-platform statement |
| 19-20 | "You need Homebrew and Xcode Command Line Tools installed" | [REPLACE] with platform-appropriate prereqs |
| 38 | `brew install python` -- macOS only | [ADD] cross-platform alternatives from lib.sh: apt=`python3`, pacman=`python` |
| 66 | `brew install uv` -- macOS only | [ADD] Linux: `curl -LsSf https://astral.sh/uv/install.sh \| sh` (from install-python.sh line 72) |
| 90 | `brew install ruff` -- macOS only | [ADD] Linux: `uv tool install ruff` or `pipx install ruff` (from install-python.sh line 93-98) |
| 335 | "r.md -- R language setup for macOS" | [REPLACE] "for macOS" |
| 339 | "Main README" reference OK | No change |

**Package name mapping from lib.sh:**
- canonical `python3`: brew=`python`, apt=`python3`, pacman=`python`
- `uv` and `ruff`: not in lib.sh pkg_map; macOS=brew, Linux=curl installer / uv tool

### File 5: docs/toolchain/r.md

**Current macOS-only references:**

| Line(s) | Issue | Change Needed |
|---------|-------|---------------|
| 14 | "This guide walks through installing R...on macOS for use with Zed" | [REPLACE] "on macOS" with cross-platform |
| 21-25 | "You need two tools...Xcode Command Line Tools...Homebrew" | [REPLACE] with platform-appropriate prereqs |
| 42 | `brew install r` -- macOS only | [ADD] cross-platform: apt=`r-base` + `r-base-dev`, pacman=`r` |
| 239 | `brew install --cask quarto` -- macOS only | [ADD] cross-platform: Debian=download .deb, Arch=AUR `quarto-cli-bin` (from install-r.sh lines 208-233) |
| 266 | "Stan / C++ toolchain: packages that use Stan...require the Xcode Command Line Tools C++ compiler" | [ADD] Linux equivalent: `build-essential` (Debian) / `base-devel` (Arch) |
| 270 | "docs/general/installation.md -- Prerequisites (Homebrew, Xcode CLT)" | [REPLACE] with cross-platform prereqs |

**Package name mapping from lib.sh:**
- canonical `r`: brew=`r`, apt=`r-base`, pacman=`r`
- canonical `r-dev`: brew="" (not needed), apt=`r-base-dev`, pacman="" (not needed)

**PPM binary repos**: The install script configures Posit Package Manager (PPM) on Linux to provide pre-compiled R package binaries. This should be documented in r.md as a Linux-specific optimization that avoids lengthy source compilation.

### File 6: docs/toolchain/shell-tools.md

**Current macOS-only references:**

| Line(s) | Issue | Change Needed |
|---------|-------|---------------|
| 16-17 | "a small set of shell utilities...Homebrew developer environment" | [REPLACE] "Homebrew" with "standard" |
| 20 | "Homebrew is required" | [REPLACE] with platform-appropriate statement |
| 36 | git: `xcode-select --install` macOS-only | [ADD] Linux: `sudo apt install git` / `sudo pacman -S git` |
| 44 | `brew install git` | [ADD] cross-platform alternatives |
| 66 | `brew install jq` | [ADD] apt=`jq`, pacman=`jq` (same name on all platforms per lib.sh) |
| 90 | `brew install gh` | [ADD] Debian: GitHub CLI apt repo setup (from install-shell-tools.sh lines 49-58), Arch: pacman=`github-cli` |
| 113-114 | make: "On macOS, `make` is provided by Xcode Command Line Tools" | [ADD] Linux: `make` or `build-essential`/`base-devel` |
| 127 | `brew install make` | [ADD] cross-platform |
| 130 | "Homebrew's GNU make is installed as `gmake`" -- macOS-specific note | Mark as macOS-specific |
| 150 | `brew install fontconfig` | [ADD] apt=`fontconfig`, pacman=`fontconfig` (same name per lib.sh) |
| 162-163 | "`od` and `date`...part of base macOS" | [REPLACE] "base macOS" with "all supported platforms" |

**Package name mapping from lib.sh:**
- `jq`: same on all platforms
- `gh`: brew=`gh`, apt=`gh`, pacman=`github-cli`
- `fontconfig`: same on all platforms
- `make`: brew=`make`, apt=`make`, pacman=`make`

### File 7: docs/toolchain/typesetting.md

**Current macOS-only references:**

| Line(s) | Issue | Change Needed |
|---------|-------|---------------|
| 10 | "Prompts for LaTeX (BasicTeX by default, MacTeX on opt-in)" | [ADD] Linux variants: texlive-base/texlive-full (Debian), texlive-basic/texlive-most (Arch) |
| 16 | "installs the typesetting tools...on macOS" | [REPLACE] with cross-platform statement |
| 22 | "Homebrew is required for every install command below" | [REPLACE] with platform-appropriate statement |
| 30-33 | "macOS has two Homebrew-friendly LaTeX distributions" | [REPLACE] with cross-platform LaTeX section |
| 48-49 | `brew install --cask basictex` | [ADD] Debian: `sudo apt install texlive-base texlive-latex-extra latexmk biber`, Arch: `sudo pacman -S texlive-basic texlive-latexextra texlive-binextra biber` |
| 54-56 | `sudo tlmgr install...` -- BasicTeX post-install | Mark as macOS-only (Linux texlive packages include these) |
| 69-70 | `brew install --cask mactex` | [ADD] Debian: `sudo apt install texlive-full`, Arch: `sudo pacman -S texlive-most` |
| 98-99 | `brew install typst` | [ADD] Debian: `cargo install typst-cli` or `snap install typst`, Arch: `sudo pacman -S typst` |
| 133 | `brew install pandoc` | [ADD] apt=`pandoc`, pacman=`pandoc` |
| 201-208 | Fonts: `brew install --cask font-*` macOS casks | [ADD] Debian: `sudo apt install fonts-lmodern fonts-cmu fonts-noto fonts-noto-cjk`, Arch: `sudo pacman -S otf-latin-modern noto-fonts noto-fonts-cjk` |

**Package name mapping from lib.sh:**
- `texlive-basic`: brew="" (uses cask), apt=`texlive-base texlive-latex-extra latexmk biber`, pacman=`texlive-basic texlive-latexextra texlive-binextra biber`
- `texlive-full`: brew="" (uses cask), apt=`texlive-full`, pacman=`texlive-most`
- `typst`: brew=`typst`, apt="" (not in repos), pacman=`typst`
- `pandoc`: same on all platforms
- `fonts-lm`: brew="" (uses cask), apt=`fonts-lmodern fonts-cmu`, pacman=`otf-latin-modern noto-fonts`
- `fonts-noto`: brew="" (uses cask), apt=`fonts-noto fonts-noto-cjk`, pacman=`noto-fonts noto-fonts-cjk`

### File 8: docs/toolchain/extensions.md

**Current macOS-only references:**

| Line(s) | Issue | Change Needed |
|---------|-------|---------------|
| No explicit "macOS only" declarations | Lighter changes needed |
| General | All cross-link descriptions that say "for macOS" should be updated | Update in See also sections |
| 84 | "C++ toolchain (Xcode Command Line Tools)" | [ADD] Linux: build-essential / base-devel |

This file is mostly a router (cross-links to other docs), so most changes propagate from the other files being updated. The Check commands and cross-references are platform-agnostic.

### File 9: docs/toolchain/mcp-servers.md

**Current macOS-only references:**

| Line(s) | Issue | Change Needed |
|---------|-------|---------------|
| No explicit "macOS only" declarations | Minimal changes needed |
| General | MCP servers are installed via `claude mcp add` and `uvx`/`npx` which are cross-platform | No platform-specific install commands |

This file requires no substantive changes. MCP server installation is already platform-agnostic (uses `claude mcp add`, `uvx`, `npx`). The only change would be removing any implicit macOS-only framing in cross-references.

### Cross-Platform Package Reference Table (from lib.sh)

This table should be included or referenced in toolchain/README.md as the canonical mapping:

| Canonical | Homebrew (macOS) | apt (Debian/Ubuntu) | pacman (Arch/Manjaro) |
|-----------|-----------------|--------------------|-----------------------|
| jq | jq | jq | jq |
| gh | gh | gh | github-cli |
| fontconfig | fontconfig | fontconfig | fontconfig |
| make | make | make | make |
| nodejs | node | nodejs | nodejs |
| npm | node | npm | npm |
| python3 | python | python3 | python |
| r | r | r-base | r |
| r-dev | (not needed) | r-base-dev | (not needed) |
| pandoc | pandoc | pandoc | pandoc |
| typst | typst | (not in repos) | typst |
| build-essential | (Xcode CLT) | build-essential | base-devel |
| curl | curl | curl | curl |
| git | git | git | git |
| texlive-basic | basictex (cask) | texlive-base texlive-latex-extra latexmk biber | texlive-basic texlive-latexextra texlive-binextra biber |
| texlive-full | mactex (cask) | texlive-full | texlive-most |
| fonts-lm | font-latin-modern + font-latin-modern-math (cask) | fonts-lmodern fonts-cmu | otf-latin-modern noto-fonts |
| fonts-noto | font-noto-sans + font-noto-serif + font-noto-sans-mono (cask) | fonts-noto fonts-noto-cjk | noto-fonts noto-fonts-cjk |

### Additional Cross-Platform Features to Document

1. **PPM (Posit Package Manager)**: The R install script configures PPM binary repos on Linux to avoid source compilation. This should be documented in r.md as a Linux note.

2. **NixOS detect-and-skip**: lib.sh detects NixOS and exits with guidance to use `configuration.nix` / `home.nix`. Already mentioned in installation.md line 8 but should be noted in toolchain/README.md.

3. **interactive_step pattern**: Used for sudo-requiring installs on Linux. Not user-facing documentation, but the deferred-hints behavior should be mentioned (wizard prints manual commands if no tty available).

4. **uv on Linux**: Installed via curl installer, not brew. This differs from macOS and must be documented in python.md.

5. **ruff on Linux**: Installed via `uv tool install ruff` or `pipx install ruff`, not brew.

6. **Typst on Debian**: Not in apt repos. Install via `cargo install typst-cli` or `snap install typst`.

## Decisions

1. The manual installation sections should remain macOS-primary but add cross-platform callout blocks for each tool, rather than tripling the length with fully parallel walkthroughs.
2. The "Platform scope" section in toolchain/README.md must be removed or completely rewritten -- it is the most flagrantly incorrect statement.
3. mcp-servers.md needs no substantive changes (already platform-agnostic).
4. extensions.md needs minimal changes (mostly inherits from other file updates).

## Recommendations

1. **Priority 1 -- Remove contradictory "macOS only" declarations** (README.md lines 1,3; toolchain/README.md lines 10-13). These are the most visible blockers.

2. **Priority 2 -- Update manual install commands with cross-platform alternatives** (installation.md, python.md, r.md, shell-tools.md, typesetting.md). Use a consistent format: show macOS command first, then a "Linux" callout block with Debian and Arch alternatives.

3. **Priority 3 -- Add the package name mapping table** to toolchain/README.md as a canonical reference, sourced from lib.sh.

4. **Priority 4 -- Document Linux-specific features** (PPM for R, uv curl installer, Typst via cargo/snap).

5. **Priority 5 -- Update See also / cross-reference descriptions** that say "for macOS" throughout all files.

## Risks & Mitigations

- **Risk**: Cross-platform install docs become verbose and harder to follow. **Mitigation**: Use consistent callout block format (e.g., blockquote or details/summary for Linux alternatives) to keep the primary flow readable.
- **Risk**: Package names in docs drift from lib.sh over time. **Mitigation**: Add a comment in lib.sh's package map pointing to the docs, and vice versa.

## Appendix

### Files Read
- `/home/benjamin/.config/zed/README.md`
- `/home/benjamin/.config/zed/docs/general/installation.md`
- `/home/benjamin/.config/zed/docs/toolchain/README.md`
- `/home/benjamin/.config/zed/docs/toolchain/python.md`
- `/home/benjamin/.config/zed/docs/toolchain/r.md`
- `/home/benjamin/.config/zed/docs/toolchain/shell-tools.md`
- `/home/benjamin/.config/zed/docs/toolchain/typesetting.md`
- `/home/benjamin/.config/zed/docs/toolchain/extensions.md`
- `/home/benjamin/.config/zed/docs/toolchain/mcp-servers.md`
- `/home/benjamin/.config/zed/scripts/install/lib.sh`
- `/home/benjamin/.config/zed/scripts/install/install-python.sh`
- `/home/benjamin/.config/zed/scripts/install/install-r.sh`
- `/home/benjamin/.config/zed/scripts/install/install-shell-tools.sh`
- `/home/benjamin/.config/zed/scripts/install/install-typesetting.sh`

### Change Volume Estimate
- README.md: ~10 changes
- installation.md: ~8 changes (manual section only; wizard section already done)
- toolchain/README.md: ~3 changes (critical: remove macOS-only declaration)
- python.md: ~5 changes
- r.md: ~6 changes
- shell-tools.md: ~8 changes
- typesetting.md: ~8 changes
- extensions.md: ~2 changes
- mcp-servers.md: ~0 changes
- **Total**: ~50 individual edits across 8 files
