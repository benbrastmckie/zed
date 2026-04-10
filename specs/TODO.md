---
next_project_number: 7
---

# Task List

## Tasks

### 6. Expand docs/agent-system.md into a docs/ directory and extract installation guide

- **Effort**: medium
- **Status**: [NOT STARTED]
- **Task Type**: meta

**Description**: `docs/agent-system.md` currently contains installation information that should be moved to an independent `docs/installation.md` focused on installing Zed via Homebrew on macOS. The file also does not cover `claude-acp`, which is what the user actually runs in Zed and which successfully loads all agent system commands, skills, and context. The existing agent-system.md file is long and densely compressed; it should be expanded into a directory containing multiple clear, educational documents — one file per natural grouping of components in the `.claude/` agent system. Each command should be presented with a brief explanation of what it does, a clear and concise usage example, and then more advanced details (flags, task workflow integration, etc.) afterward. The documentation should be accessible to new users and cover all commands as well as the relationships between commands, skills, agents, context files, and the `.memory/` system.

### 5. Update docs/agent-system.md to accurately represent the .claude/ agent system

- **Effort**: medium
- **Status**: [COMPLETED]
- **Completed**: 2026-04-10
- **Task Type**: meta
- **Research**: [01_agent-system-docs.md](005_update_agent_system_docs/reports/01_agent-system-docs.md)
- **Plan**: [01_implementation-plan.md](005_update_agent_system_docs/plans/01_implementation-plan.md)
- **Summary**: Rewrote docs/agent-system.md (185 -> 378 lines) with Main Workflow section, topic-grouped Command Catalog, dedicated Memory System section, and 22 verified cross-references into .claude/ docs.

**Description**: Update `/home/benjamin/.config/zed/docs/agent-system.md` to accurately represent the `/home/benjamin/.config/zed/.claude/` agent system. Clarify the main workflow commands `/task`, `/research`, `/plan`, `/revise`, and `/implement` that help the user progress through tasks, along with clean-up commands `/todo` and `/review`. Explain all other commands in topic-based groups. Devote a dedicated section to the `.memory/` system. Make any other necessary improvements, including adding appropriate links to relevant content in `/home/benjamin/.config/zed/.claude/docs/` or `/home/benjamin/.config/zed/.claude/README.md` as appropriate.

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
