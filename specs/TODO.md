---
next_project_number: 58
---

# Task List

## Tasks

### 57. Cross-platform install wizard with headless-aware interactive fallbacks
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: meta

**Description**: Optimize scripts/install/ wizard for cross-platform support (macOS, Debian, Arch) and headless/tty-aware execution. Make the script platform-agnostic by detecting the OS and using appropriate package managers (brew on macOS, apt on Debian, pacman on Arch). For steps that require a tty (Xcode CLT GUI dialog, Homebrew bootstrap, sudo-requiring .pkg cask installs, sudo tlmgr), detect headless mode automatically and present the user with clear instructions including: what command to run, why it's needed (which workflows depend on it), and why it must be run manually. Tell the user to run it in another terminal tab, then press Enter to continue. After the user says they've completed the manual step, verify the installation actually worked before proceeding — if it didn't, report the failure and offer to retry or skip. Extend the existing DEFERRED_HINTS and brew_install_pkg_cask pattern from lib.sh to all interactive/sudo/GUI steps consistently. Ensure R package compilations handle Claude Code's bash timeout gracefully. Preserve all existing functionality: --dry-run, --check, --yes, --preset, --only, idempotency, subprocess isolation, the Lean MCP resurrection guard. The script should work identically in an interactive terminal (human user) and when run by Claude Code (headless), with graceful degradation in the latter case.

### 56. Refactor keymap.json to use platform-adaptive keybindings
- **Effort**: medium
- **Status**: [PLANNED]
- **Research**: [01_platform-adaptive-keybindings.md](056_refactor_keymap_platform_adaptive/reports/01_platform-adaptive-keybindings.md)
- **Plan**: [01_platform-adaptive-keybindings.md](056_refactor_keymap_platform_adaptive/plans/01_platform-adaptive-keybindings.md)
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
