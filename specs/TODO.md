---
next_project_number: 60
---

# Task List

## Tasks

### 59. Revise keybindings documentation after task 56
- **Effort**: small
- **Status**: [PLANNED]
- **Research**: [01_keybindings-docs-review.md](059_revise_keybindings_docs_post_task_56/reports/01_keybindings-docs-review.md)
- **Plan**: [01_keybindings-docs-review.md](059_revise_keybindings_docs_post_task_56/plans/01_keybindings-docs-review.md)
- **Task Type**: markdown

**Description**: Revise `docs/general/keybindings.md` and `docs/general/keybindings-cheat-sheet.typ` to reflect changes completed in task 56.

### 58. Update documentation for cross-platform install wizard
- **Effort**: medium
- **Status**: [PLANNED]
- **Research**: [01_cross-platform-docs.md](058_cross_platform_docs_update/reports/01_cross-platform-docs.md)
- **Plan**: [01_cross-platform-docs.md](058_cross_platform_docs_update/plans/01_cross-platform-docs.md)
- **Task Type**: markdown

**Description**: Update all documentation to reflect the cross-platform install wizard completed in task 57. The wizard now supports macOS, Debian/Ubuntu, and Arch/Manjaro with OS detection, package manager abstraction, interactive_step pattern, PPM binary repos for R on Linux, and NixOS detect-and-skip. The following files still reference "macOS only" or contain Homebrew-only install instructions that need cross-platform alternatives added:

- `README.md` — Platform line says "macOS 11 (Big Sur) or newer", Quick Start says "On a fresh Mac"
- `docs/general/installation.md` — Manual installation section says "target platform is macOS 11", Prerequisites list only macOS, all manual install steps are Homebrew-only. The wizard section was already updated by task 57.
- `docs/toolchain/README.md` — Platform scope section explicitly says "macOS / Homebrew only" and "Linux install paths are explicitly out of scope per the task-21 reframing"
- `docs/toolchain/python.md` — All install commands are brew-only (brew install python, brew install uv, brew install ruff). Needs Linux alternatives (apt/pacman for python3, curl installer for uv, uv tool install for ruff)
- `docs/toolchain/r.md` — Install command is "brew install r" only. Needs apt/pacman alternatives, mention of PPM binary repos for Linux, note about compilation timeouts on Linux without PPM
- `docs/toolchain/shell-tools.md` — Install commands are brew/xcode-select only. Needs apt/pacman alternatives for jq, gh, make, fontconfig, git
- `docs/toolchain/typesetting.md` — All install commands are brew-only (BasicTeX/MacTeX casks, brew install typst, brew install pandoc, brew font casks). Needs apt/pacman alternatives for texlive, typst, pandoc, and system font packages
- `docs/toolchain/extensions.md` — Check commands reference brew-specific paths; epidemiology section mentions "Xcode Command Line Tools C++ compiler" without Linux equivalent (build-essential/base-devel)
- `docs/toolchain/mcp-servers.md` — Mostly platform-neutral (uvx/npx), minimal changes needed

Reference: The cross-platform install logic is in `scripts/install/lib.sh` (detect_os, resolve_pkg_name, pkg_install, interactive_step, etc.) — consult for correct package names and install methods per platform.

### 57. Cross-platform install wizard with headless-aware interactive fallbacks
- **Effort**: large
- **Status**: [COMPLETED]
- **Research**: [01_cross-platform-install.md](057_cross_platform_install_wizard/reports/01_cross-platform-install.md)
- **Plan**: [01_cross-platform-install.md](057_cross_platform_install_wizard/plans/01_cross-platform-install.md)
- **Summary**: [01_cross-platform-install-summary.md](057_cross_platform_install_wizard/summaries/01_cross-platform-install-summary.md)
- **Task Type**: meta

**Description**: Optimize scripts/install/ wizard for cross-platform support (macOS, Debian, Arch) and headless/tty-aware execution. Make the script platform-agnostic by detecting the OS and using appropriate package managers (brew on macOS, apt on Debian, pacman on Arch). For steps that require a tty (Xcode CLT GUI dialog, Homebrew bootstrap, sudo-requiring .pkg cask installs, sudo tlmgr), detect headless mode automatically and present the user with clear instructions including: what command to run, why it's needed (which workflows depend on it), and why it must be run manually. Tell the user to run it in another terminal tab, then press Enter to continue. After the user says they've completed the manual step, verify the installation actually worked before proceeding — if it didn't, report the failure and offer to retry or skip. Extend the existing DEFERRED_HINTS and brew_install_pkg_cask pattern from lib.sh to all interactive/sudo/GUI steps consistently. Ensure R package compilations handle Claude Code's bash timeout gracefully. Preserve all existing functionality: --dry-run, --check, --yes, --preset, --only, idempotency, subprocess isolation, the Lean MCP resurrection guard. The script should work identically in an interactive terminal (human user) and when run by Claude Code (headless), with graceful degradation in the latter case.

### 56. Refactor keymap.json to use platform-adaptive keybindings
- **Effort**: medium
- **Status**: [COMPLETED]
- **Research**: [01_platform-adaptive-keybindings.md](056_refactor_keymap_platform_adaptive/reports/01_platform-adaptive-keybindings.md)
- **Plan**: [01_platform-adaptive-keybindings.md](056_refactor_keymap_platform_adaptive/plans/01_platform-adaptive-keybindings.md)
- **Summary**: [01_platform-adaptive-keybindings-summary.md](056_refactor_keymap_platform_adaptive/summaries/01_platform-adaptive-keybindings-summary.md)
- **Task Type**: general

**Description**: Refactor keymap.json to use Zed's `secondary-` modifier for platform-adaptive keybindings (Ctrl on Linux, Cmd on macOS). Audit all 17 custom bindings against Zed's macOS defaults to identify collisions, resolve conflicts, and update keymap.json comments, docs/general/keybindings.md, and docs/general/keybindings-cheat-sheet.typ to reflect the new cross-platform scheme.

### 55. Update all documentation in .claude/, README.md, and docs/ to reflect recent .claude/ changes
- **Effort**: medium
- **Status**: [COMPLETED]
- **Research**: [01_team-research.md](055_update_claude_and_project_docs/reports/01_team-research.md)
- **Plan**: [01_update-docs.md](055_update_claude_and_project_docs/plans/01_update-docs.md)
- **Summary**: [01_update-docs-summary.md](055_update_claude_and_project_docs/summaries/01_update-docs-summary.md)
- **Task Type**: meta

**Description**: Run git diff on .claude/ to see what has changed in order to systematically update all documentation in .claude/ as well as /home/benjamin/.config/zed/README.md and in /home/benjamin/.config/zed/docs/ as appropriate, cutting no corners

## Recommended Order

1. **58** -> research (independent)
2. **59** -> research (independent)
