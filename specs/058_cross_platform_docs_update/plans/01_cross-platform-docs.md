# Implementation Plan: Cross-Platform Documentation Update

- **Task**: 58 - cross_platform_docs_update
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: Task 57 (cross-platform install wizard)
- **Research Inputs**: specs/058_cross_platform_docs_update/reports/01_cross-platform-docs.md
- **Artifacts**: plans/01_cross-platform-docs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

All 9 documentation files contain macOS-only language that contradicts the cross-platform install wizard completed in task 57. This plan updates documentation in 4 phases: first removing the most visible "macOS only" declarations in README.md and toolchain/README.md, then updating the manual installation walkthrough, then adding cross-platform package commands to each toolchain guide, and finally sweeping cross-references and light-touch files. The definition of done is: no documentation file claims macOS-only support, and every `brew install` command is accompanied by Debian/Ubuntu and Arch/Manjaro alternatives sourced from lib.sh's package map.

### Research Integration

The research report inventoried all 9 files and identified ~50 individual edits. Key findings integrated:
- lib.sh provides the canonical package name mapping table (canonical -> brew/apt/pacman) that serves as source of truth for all docs.
- The manual installation section in installation.md is the largest gap (wizard section already updated).
- mcp-servers.md needs no substantive changes; extensions.md needs only minimal updates.
- Research recommends a consistent callout format for Linux alternatives to keep primary flow readable.
- PPM binary repos, uv curl installer, and Typst via cargo/snap are Linux-specific features requiring documentation.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No active roadmap items. The ROADMAP.md contains placeholder entries only.

## Goals & Non-Goals

**Goals**:
- Remove all "macOS only" declarations that contradict cross-platform wizard support
- Add Debian/Ubuntu (apt) and Arch/Manjaro (pacman) package install commands alongside every `brew install`
- Document Linux-specific features: PPM for R, uv/ruff curl installers, Typst via cargo/snap
- Add cross-platform package reference table to toolchain/README.md
- Update Platform Notes sections to cover macOS, Debian/Ubuntu, and Arch/Manjaro

**Non-Goals**:
- Rewriting the manual installation section as fully parallel platform walkthroughs (keep macOS-primary with Linux callouts)
- Adding support for distributions beyond Debian/Ubuntu and Arch/Manjaro
- Modifying any install scripts (those were completed in task 57)
- Updating NixOS documentation beyond the existing detect-and-skip mention

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-platform commands make docs verbose and harder to follow | M | M | Use consistent blockquote callout format for Linux alternatives; keep macOS commands as primary inline examples |
| Package names in docs drift from lib.sh over time | M | L | Add cross-reference comment in toolchain/README.md pointing to lib.sh as source of truth |
| Inconsistent callout style across files | L | M | Establish format in Phase 1, apply consistently in Phase 3 |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4 | 1 |

Phases within the same wave can execute in parallel.

---

### Phase 1: High-Visibility Declarations -- README.md and toolchain/README.md [COMPLETED]

**Goal**: Remove the most prominent "macOS only" statements and establish the cross-platform callout format that subsequent phases will follow.

**Tasks**:
- [ ] README.md line 1: Replace "A Zed editor configuration for macOS" with cross-platform statement (macOS, Debian/Ubuntu, Arch/Manjaro)
- [ ] README.md line 3: Replace "**Platform**: macOS 11 (Big Sur) or newer" with multi-platform support statement
- [ ] README.md line 9: Replace "On a fresh Mac" with "On a fresh system"
- [ ] README.md line 21: Add Linux install alternatives for Zed alongside Homebrew cask
- [ ] README.md line 194: Replace "on macOS" in description with cross-platform statement
- [ ] README.md lines 229-236: Rewrite Platform Notes section to cover all three platforms (macOS, Debian/Ubuntu, Arch), including key equivalents (Ctrl vs Cmd), config location note, and package manager alternatives
- [ ] toolchain/README.md lines 10-13: Remove "macOS / Homebrew only" declaration entirely; replace with statement that all tools support macOS, Debian/Ubuntu, and Arch/Manjaro
- [ ] toolchain/README.md line 7: Replace single "Homebrew" reference with cross-platform package manager list
- [ ] toolchain/README.md: Add cross-platform package reference table (sourced from lib.sh) as canonical mapping
- [ ] toolchain/README.md: Add note referencing lib.sh as source of truth for package names, and mention NixOS detect-and-skip

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `README.md` -- Remove macOS-only framing, update platform notes
- `docs/toolchain/README.md` -- Remove macOS-only declaration, add package reference table

**Verification**:
- No occurrence of "macOS only" or "macOS / Homebrew only" in either file
- Package reference table present in toolchain/README.md with all entries from lib.sh
- Platform Notes section covers all three supported platforms

---

### Phase 2: Manual Installation Section -- installation.md [COMPLETED]

**Goal**: Update the manual installation walkthrough in installation.md to include cross-platform prerequisites and package commands, while keeping the macOS-primary flow intact.

**Tasks**:
- [ ] Lines 66-67: Add note clarifying that manual section covers all platforms (wizard is recommended for Linux)
- [ ] Lines 86-89: Add Linux terminal opening instructions alongside macOS Spotlight instructions
- [ ] Line 94: Replace "macOS 11 (Big Sur) or newer" prerequisites with multi-platform prereqs
- [ ] Lines 102-126: Add Linux equivalent for Xcode CLT: `build-essential` (Debian) / `base-devel` (Arch)
- [ ] Lines 129-159: Add note that Homebrew section is macOS-specific; on Linux, apt/pacman are used instead
- [ ] Lines 162-187: Add cross-platform Node.js install: apt (`nodejs npm`), pacman (`nodejs npm`)
- [ ] Lines 189-215: Add Linux Zed install: download from zed.dev or package manager
- [ ] Lines 231-235: Add npm/direct install for Claude Code CLI on Linux

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `docs/general/installation.md` -- Add cross-platform alternatives throughout manual section

**Verification**:
- Every `brew install` in the manual section has a corresponding Linux alternative
- Prerequisites section lists requirements for all three platforms
- Wizard section (lines 1-61) remains unchanged (already cross-platform)

---

### Phase 3: Toolchain Guides -- python.md, r.md, shell-tools.md, typesetting.md [COMPLETED]

**Goal**: Add cross-platform package commands and Linux-specific features to each toolchain guide, using the callout format established in Phase 1.

**Tasks**:
- [ ] **python.md**: Replace "on macOS" intro (line 15) with cross-platform statement
- [ ] **python.md**: Replace Homebrew/Xcode prereqs (lines 19-20) with platform-appropriate prereqs
- [ ] **python.md**: Add cross-platform alternatives for `brew install python` (line 38): apt=`python3`, pacman=`python`
- [ ] **python.md**: Add Linux uv install via curl (line 66): `curl -LsSf https://astral.sh/uv/install.sh | sh`
- [ ] **python.md**: Add Linux ruff install via uv tool (line 90): `uv tool install ruff`
- [ ] **r.md**: Replace "on macOS" intro (line 14) with cross-platform statement
- [ ] **r.md**: Replace Homebrew/Xcode prereqs (lines 21-25) with platform-appropriate prereqs
- [ ] **r.md**: Add cross-platform R install (line 42): apt=`r-base r-base-dev`, pacman=`r`
- [ ] **r.md**: Document PPM binary repos as Linux-specific optimization (new section or note near R install)
- [ ] **r.md**: Add cross-platform Quarto install (line 239): Debian=download .deb, Arch=AUR `quarto-cli-bin`
- [ ] **r.md**: Add Linux C++ toolchain note for Stan (line 266): `build-essential` / `base-devel`
- [ ] **shell-tools.md**: Replace "Homebrew developer environment" framing (lines 16-17) with cross-platform statement
- [ ] **shell-tools.md**: Replace "Homebrew is required" prereq (line 20) with platform-appropriate statement
- [ ] **shell-tools.md**: Add cross-platform git install (lines 36, 44): apt/pacman alternatives
- [ ] **shell-tools.md**: Add cross-platform jq install (line 66): same name on all platforms
- [ ] **shell-tools.md**: Add cross-platform gh install (line 90): Debian=GitHub CLI apt repo, Arch=`github-cli`
- [ ] **shell-tools.md**: Add cross-platform make install (lines 113-130): apt/pacman + macOS gmake note
- [ ] **shell-tools.md**: Add cross-platform fontconfig (line 150): same name on all platforms
- [ ] **shell-tools.md**: Replace "base macOS" with "all supported platforms" (lines 162-163)
- [ ] **typesetting.md**: Replace "on macOS" intro (line 16) with cross-platform statement
- [ ] **typesetting.md**: Replace Homebrew prereq (line 22) with platform-appropriate statement
- [ ] **typesetting.md**: Add cross-platform LaTeX section (lines 30-70): Debian texlive packages, Arch texlive packages, mark tlmgr as macOS-only
- [ ] **typesetting.md**: Add cross-platform Typst install (lines 98-99): Debian=`cargo install typst-cli` or snap, Arch=`pacman -S typst`
- [ ] **typesetting.md**: Add cross-platform Pandoc install (line 133): same name on all platforms
- [ ] **typesetting.md**: Add cross-platform font install (lines 201-208): apt font packages, pacman font packages

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `docs/toolchain/python.md` -- Add cross-platform Python, uv, ruff commands
- `docs/toolchain/r.md` -- Add cross-platform R, Quarto, Stan commands; document PPM
- `docs/toolchain/shell-tools.md` -- Add cross-platform git, jq, gh, make, fontconfig commands
- `docs/toolchain/typesetting.md` -- Add cross-platform LaTeX, Typst, Pandoc, font commands

**Verification**:
- Every `brew install` command in all four files has a Linux alternative
- PPM binary repos documented in r.md
- uv and ruff Linux-specific install methods documented in python.md
- Typst Debian install (cargo/snap) documented in typesetting.md

---

### Phase 4: Cross-References and Light-Touch Files [COMPLETED]

**Goal**: Update extensions.md cross-references, verify mcp-servers.md needs no changes, and sweep all files for remaining "for macOS" phrases in See Also sections.

**Tasks**:
- [ ] **extensions.md** line 84: Add Linux C++ toolchain note (`build-essential` / `base-devel`) alongside Xcode CLT reference
- [ ] **extensions.md**: Update any "for macOS" cross-link descriptions to cross-platform statements
- [ ] **mcp-servers.md**: Verify no macOS-only framing remains; update cross-references if needed (expected: no changes)
- [ ] **All files**: Final sweep for remaining "for macOS" or "macOS only" phrases in See Also / cross-reference sections
- [ ] **python.md** line 335: Update "r.md -- R language setup for macOS" cross-reference
- [ ] **r.md** line 270: Update "installation.md -- Prerequisites (Homebrew, Xcode CLT)" cross-reference

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `docs/toolchain/extensions.md` -- Add Linux C++ toolchain note, update cross-references
- `docs/toolchain/mcp-servers.md` -- Verify and update cross-references if needed
- `docs/toolchain/python.md` -- Update See Also cross-references
- `docs/toolchain/r.md` -- Update See Also cross-references

**Verification**:
- `grep -ri "for macOS" docs/` returns zero results (or only appropriately scoped references like "Homebrew is for macOS")
- `grep -ri "macOS only" docs/ README.md` returns zero results
- All cross-link descriptions reflect cross-platform support

## Testing & Validation

- [ ] `grep -ri "macOS only" README.md docs/` returns no matches
- [ ] `grep -ri "macOS / Homebrew only" docs/` returns no matches
- [ ] Every `brew install` command in docs has a corresponding Linux callout within the same section
- [ ] Package names in docs match lib.sh's `_pkg_map_add` entries
- [ ] Cross-platform package reference table in toolchain/README.md matches lib.sh
- [ ] PPM binary repos documented in r.md
- [ ] uv curl installer documented in python.md
- [ ] Typst cargo/snap install documented in typesetting.md
- [ ] No broken markdown links after edits

## Artifacts & Outputs

- `specs/058_cross_platform_docs_update/plans/01_cross-platform-docs.md` (this plan)
- Updated files: `README.md`, `docs/general/installation.md`, `docs/toolchain/README.md`, `docs/toolchain/python.md`, `docs/toolchain/r.md`, `docs/toolchain/shell-tools.md`, `docs/toolchain/typesetting.md`, `docs/toolchain/extensions.md`
- No changes expected to: `docs/toolchain/mcp-servers.md`

## Rollback/Contingency

All changes are markdown text edits with no code impact. Rollback via `git checkout HEAD -- README.md docs/` to restore all documentation files to their pre-edit state. Individual files can be reverted independently since phases target non-overlapping file sets (except cross-references in Phase 4).
