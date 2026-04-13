---
next_project_number: 57
---

# Task List

## Tasks

### 56. Refactor keymap.json to use platform-adaptive keybindings
- **Effort**: medium
- **Status**: [NOT STARTED]
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
