---
next_project_number: 5
---

# Task List

## Tasks

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
