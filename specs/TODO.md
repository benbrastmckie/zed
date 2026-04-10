---
next_project_number: 13
---

# Task List

## Tasks

### 12. Expand docs/agent-system/commands.md to include brief examples and explanations for each command
- **Effort**: small
- **Status**: [IMPLEMENTING]
- **Task Type**: meta
- **Research**: [01_team-research.md](012_expand_commands_docs_examples/reports/01_team-research.md)
- **Plan**: [01_expand-commands-docs.md](012_expand_commands_docs_examples/plans/01_expand-commands-docs.md)

**Description**: Expand docs/agent-system/commands.md to include brief examples and explanations for each command.

### 11. Fix Zed ACP subagent invocation to match Neovim Claude Code plugin behavior

- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Completed**: 2026-04-10
- **Research**: [01_team-research.md](011_fix_zed_acp_subagent_invocation/reports/01_team-research.md)
- **Plan**: [01_zed-cli-parity.md](011_fix_zed_acp_subagent_invocation/plans/01_zed-cli-parity.md)
- **Summary**: [01_zed-cli-parity-summary.md](011_fix_zed_acp_subagent_invocation/summaries/01_zed-cli-parity-summary.md)
- **Summary**: Configured Zed for Claude Code CLI parity: created .zed/tasks.json terminal task for full feature parity (subagents, --team, skills), and added CLAUDE_CODE_EXECUTABLE env var to agent_servers config for improved ACP panel behavior.

**Description**: Running `/implement 9` in the Zed agent sidebar via Agent ACP produced /home/benjamin/.config/zed/output/test.md, showing the command did not invoke subagents as expected. The same command run via the Claude Code plugin in Neovim correctly delegates to subagents. Investigate the discrepancy between Zed ACP and Neovim Claude Code plugin environments, and determine how to configure Zed so that all Claude Code commands, skills, and agents behave identically to their Neovim counterparts.

### 10. Update docs/ based on .claude/ diff

- **Effort**: small
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Completed**: 2026-04-10
- **Research**: [01_team-research.md](010_update_docs_from_claude_diff/reports/01_team-research.md)
- **Plan**: [01_update-docs-from-claude-diff.md](010_update_docs_from_claude_diff/plans/01_update-docs-from-claude-diff.md)
- **Summary**: [01_update-docs-from-claude-diff-summary.md](010_update_docs_from_claude_diff/summaries/01_update-docs-from-claude-diff-summary.md)

**Description**: Review the diff for .claude/ to see what has changed in order to update the documentation in /home/benjamin/.config/zed/docs/ appropriately.

### 9. Populate docs/workflows/ with command workflow guides

- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: markdown
- **Research**: [01_team-research.md](009_workflow_docs_for_commands/reports/01_team-research.md)
- **Plan**: [01_workflow-docs-plan.md](009_workflow_docs_for_commands/plans/01_workflow-docs-plan.md)
- **Summary**: [01_workflow-docs-summary.md](009_workflow_docs_for_commands/summaries/01_workflow-docs-summary.md)
- **Completed**: 2026-04-10

**Description**: Populate docs/workflows/ with workflows covering all commands in .claude/commands/, grouping related commands together as appropriate.

### 8. Split office-workflows.md into workflows/ directory

- **Effort**: small
- **Status**: [COMPLETED]
- **Task Type**: markdown
- **Research**: [01_team-research.md](008_split_workflows_into_directory/reports/01_team-research.md)
- **Plan**: [01_split-workflows-directory.md](008_split_workflows_into_directory/plans/01_split-workflows-directory.md)
- **Summary**: [01_split-workflows-directory-summary.md](008_split_workflows_into_directory/summaries/01_split-workflows-directory-summary.md)

**Description**: Turn docs/office-workflows.md into a docs/workflows/ directory with separate documents for each type of workflow, moving docs/agent-system/workflow.md into this folder for agent workflows. Documents in workflows/ should be non-redundant but divided into distinct workflows where possible or natural, with appropriate cross-linking. Include a workflows/README.md with a table of contents linking to all files with brief descriptions.

### 7. Revise installation.md for macOS (drop NixOS)

- **Effort**: small
- **Status**: [COMPLETED]
- **Task Type**: markdown
- **Research**: [01_installation-macos-research.md](007_revise_installation_md_macos/reports/01_installation-macos-research.md)
- **Plan**: [01_revise-installation-macos.md](007_revise_installation_md_macos/plans/01_revise-installation-macos.md)
- **Summary**: [01_revise-installation-macos-summary.md](007_revise_installation_md_macos/summaries/01_revise-installation-macos-summary.md)

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
