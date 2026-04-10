---
next_project_number: 8
---

# Task List

## Tasks

### 7. Revise installation.md for macOS (drop NixOS)

- **Effort**: small
- **Status**: [NOT STARTED]
- **Task Type**: markdown

**Description**: Revise docs/installation.md to target macOS users only (remove NixOS references; building from a NixOS machine is incidental). Include installation steps for Homebrew, Node, Claude Code, and any other dependencies, assuming only WezTerm (or the default macOS Terminal as backup) is present. Order sections so dependencies come earlier, and each section should check whether the dependency is already installed so users can skip to the next step.

### 6. Expand agent-system.md into docs/ directory

- **Effort**: medium
- **Status**: [COMPLETED]
- **Completed**: 2026-04-10
- **Task Type**: meta
- **Research**: [01_team-research.md](006_expand_agent_system_docs/reports/01_team-research.md)
- **Plan**: [01_expand-docs-directory.md](006_expand_agent_system_docs/plans/01_expand-docs-directory.md)
- **Summary**: [01_expand-docs-directory-summary.md](006_expand_agent_system_docs/summaries/01_expand-docs-directory-summary.md)

**Description**: Expand docs/agent-system.md into a docs/ directory with multiple clear, educational documents (one file per natural grouping) and extract installation content into an independent docs/installation.md focused on macOS Homebrew + claude-acp setup. The new docs must cover claude-acp (currently absent), use progressive disclosure (brief explanation -> example -> advanced details), explain relationships between commands/skills/agents/context/.memory/, and link rather than duplicate .claude/ internal docs.

### 4. Integrate config-report.md into docs/ and delete

- **Effort**: small
- **Status**: [PLANNED]
- **Task Type**: general
- **Research**: [01_integrate-config-report.md](004_integrate_config_report_into_docs/reports/01_integrate-config-report.md)
- **Plan**: [01_integrate-config-report.md](004_integrate_config_report_into_docs/plans/01_integrate-config-report.md)

**Description**: Extract unique content from config-report.md into docs/: (1) external Zed documentation URLs table (https://zed.dev/docs/*) into docs/README.md as a "Reference" section; (2) runtime data paths (~/.local/share/zed/extensions, logs, db) into docs/settings.md; (3) optionally the Neovim comparison table. Then delete config-report.md. The stale "Current State" snapshot table and already-covered setup steps should NOT be copied.

### 3. Integrate zed-claude-office-guide.md into docs/ directory

- **Effort**: small
- **Status**: [COMPLETED]
- **Completed**: 2026-04-10
- **Task Type**: general
- **Research**: [01_integrate-guide-docs.md](003_integrate_guide_into_docs/reports/01_integrate-guide-docs.md)
- **Plan**: [01_integrate-guide-docs.md](003_integrate_guide_into_docs/plans/01_integrate-guide-docs.md)
- **Summary**: [01_integrate-guide-docs-summary.md](003_integrate_guide_into_docs/summaries/01_integrate-guide-docs-summary.md)

**Description**: Integrate zed-claude-office-guide.md into docs/ so that there is no overlap between files. If all information in zed-claude-office-guide.md is already covered by what is in docs/ then the guide file can be deleted. Otherwise, carefully organize all information in docs/ for clarity and completeness.

### 2. Add Claude ACP keybindings to Zed documentation

- **Effort**: small
- **Status**: [COMPLETED]
- **Completed**: 2026-04-10
- **Task Type**: general
- **Research**: [01_claude-acp-keybindings.md](002_add_claude_acp_keybindings_docs/reports/01_claude-acp-keybindings.md)
- **Plan**: [01_add-keybindings-docs.md](002_add_claude_acp_keybindings_docs/plans/01_add-keybindings-docs.md)
- **Summary**: [01_add-keybindings-docs-summary.md](002_add_claude_acp_keybindings_docs/summaries/01_add-keybindings-docs-summary.md)

**Description**: Add all relevant keybindings for using Claude ACP in the agent sidebar in Zed to the zed/docs/ guides wherever most relevant. For example, ctrl+n opens a new session is an important detail to include.

### 1. Configure Zed with Claude agent system documentation

- **Effort**: medium
- **Status**: [COMPLETED]
- **Completed**: 2026-04-10
- **Language**: general
- **Summary**: [03_execution-summary.md](001_configure_zed_with_claude_agent_docs/summaries/03_execution-summary.md)
- **Plan**:
  - [02_implementation-plan.md](001_configure_zed_with_claude_agent_docs/plans/02_implementation-plan.md)
  - [03_implementation-plan.md](001_configure_zed_with_claude_agent_docs/plans/03_implementation-plan.md)

**Description**: Configure Zed following zed-claude-office-guide.md and config-report.md, creating appropriate documentation in zed/docs/ as well as zed/README.md in addition to configuration, following best practices. Configure Zed to support the .claude/ agent system which uses the .memory/ system. All documentation needs to be clear, accessible to a beginner, to the point, concise, and well organized and cross-linked.
