# Implementation Summary: Expand agent-system.md into docs/ directory

- **Task**: 6 - Expand agent-system.md into docs/ directory
- **Status**: [COMPLETED]
- **Started**: 2026-04-10
- **Completed**: 2026-04-10
- **Effort**: ~1 hour (vs 7.5 hour estimate)
- **Dependencies**: None
- **Artifacts**:
  - Plan: specs/006_expand_agent_system_docs/plans/01_expand-docs-directory.md
  - Research: specs/006_expand_agent_system_docs/reports/01_team-research.md
  - This summary: specs/006_expand_agent_system_docs/summaries/01_expand-docs-directory-summary.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, summary-format.md

## Overview

Split the 378-line monolithic `docs/agent-system.md` into a focused `docs/agent-system/` subdirectory of six progressive-disclosure files plus a new top-level `docs/installation.md` that covers the claude-acp bridge (previously undocumented). Repaired all nine inbound links across `README.md`, `docs/README.md`, `docs/settings.md`, and `docs/office-workflows.md`, added a new `agent_servers` reference section to `docs/settings.md`, then deleted the old file.

## What Changed

- Created `docs/installation.md` with Homebrew install flow, `claude auth login`, registry-style `claude-acp` config (recommended), in-panel `/login`, MCP tool installation (SuperDoc + openpyxl), verification checklist, and NixOS Platform Notes quoting `settings.json` lines 138–145 verbatim.
- Created `docs/agent-system/README.md` as the orientation entry point with a comparison table, navigation list, and first-task quick start.
- Created `docs/agent-system/zed-agent-panel.md` documenting the Agent Panel, built-in vs Claude Code threads, the `@zed-industries/claude-agent-acp` ACP bridge mechanism, authentication, keybindings, inline assist, edit predictions, and troubleshooting (`dev: open acp logs`).
- Created `docs/agent-system/workflow.md` with the task lifecycle state machine, seven main-workflow commands, multi-task syntax, team mode, and exception states (ported from old lines 51–103).
- Created `docs/agent-system/commands.md` as a thin-wrapper catalog of all 24 commands grouped into Lifecycle, Maintenance, Memory, Documents, Research & Grants. Each entry is a one-sentence summary + example + flag list + links into `.claude/commands/` and the user guide.
- Created `docs/agent-system/context-and-memory.md` documenting the two memory layers (`.memory/` vault vs auto-memory), `/learn` modes, `/research --remember`, the five context layers, and a decision flowchart.
- Created `docs/agent-system/architecture.md` with the three-layer pipeline, checkpoint execution, session IDs, state files, configuration tree, extensions clarification (not applicable in Zed), and task routing.
- Repaired 5 references in `README.md` (install-context -> `docs/installation.md`; overview contexts -> `docs/agent-system/README.md`; panel context -> `docs/agent-system/zed-agent-panel.md`; directory-layout comment updated; office-editing reference uses fragment `#install-mcp-tools`).
- Repaired `docs/README.md` to add an `installation.md` entry and point Agent System to `agent-system/README.md`.
- Repaired `docs/settings.md`: added a new `### agent_servers` section documenting registry and custom config variants with a cross-link to `installation.md`, and repaired the related link; total 2 changes.
- Repaired both `docs/office-workflows.md` references: troubleshooting fragment now targets `installation.md#install-mcp-tools`; Related Documentation adds Installation entry and points Agent system at `agent-system/README.md`.
- Deleted `docs/agent-system.md` (378 lines) in Phase 8 after all inbound links were repaired and validated.
- Final sweep: zero references to `agent-system.md` remain anywhere in the repo outside `specs/` and `.claude/`.

## Decisions

- Used the registry-style `"type": "registry"` config as the recommended default in `installation.md`, and documented the current NixOS custom config (`command = /home/benjamin/.nix-profile/bin/npx`) only in a clearly labeled Platform Notes section — matching the research synthesis.
- Enforced the thin-wrapper policy strictly in `commands.md`: each command entry is a 1-sentence summary + minimal example + flag list + link into `.claude/`; no duplicated prose from `.claude/docs/guides/user-guide.md`.
- Ported Task 5's Main Workflow content (old lines 51–103) and Command Catalog content (old lines 104–165) largely verbatim, with only the structural reorganization needed to split across two files.
- Removed the link to `.claude/commands/tag.md` from the `/tag` entry in `commands.md` because the command file does not exist in `.claude/commands/` (only declared in the routing table in `.claude/CLAUDE.md`); redirected reader to `.claude/CLAUDE.md`.
- Ordered phases so all new files existed before inbound links were repaired (Phase 6) and the old file was deleted only in Phase 8, avoiding any transient broken-link state.

## Impacts

- `docs/` now has a clear split between setup (`installation.md`) and usage/mechanism (`agent-system/` subdirectory), matching the progressive-disclosure pattern.
- `claude-acp` (previously absent from user-facing docs) now has first-class coverage: setup in `installation.md#configure-claude-acp`, runtime explanation in `zed-agent-panel.md`, and reference config in `settings.md#agent_servers`.
- `docs/settings.md` now has a full `agent_servers` reference section that explains both registry and custom configurations including the NixOS case.
- Fragment link from `office-workflows.md` correctly resolves to the new anchor.
- Collaborator onboarding flow is clearer: README -> `docs/installation.md` -> `docs/agent-system/README.md` -> task workflow.

## Verification

- Build: N/A (markdown documentation)
- Tests: N/A
- All 7 new files exist and are non-empty.
- `grep -rn "agent-system\.md" .` (excluding `specs/` and `.claude/`) returns zero matches.
- Link validation: extracted every markdown link from all 7 new files and confirmed each target path exists (zero missing after removing the stale `tag.md` link).
- `docs/installation.md` has a heading whose GitHub slug is `install-mcp-tools`.
- `docs/installation.md` contains both the registry config block and the NixOS custom block.
- `docs/agent-system/zed-agent-panel.md` explicitly names `@zed-industries/claude-agent-acp`.
- `docs/agent-system/commands.md` covers all 5 command groups with all 24 commands linked.
- `docs/settings.md` has an `### agent_servers` heading.
- `docs/keybindings.md` is unchanged.
- Each phase was committed individually with session ID `sess_1775849200_b921b2` in the trailer.

## Follow-ups

Recorded in the plan but intentionally not executed in this task:

- Link-check script for `docs/**/*.md`
- Back-reference from `.claude/CLAUDE.md` to `docs/README.md`
- `docs/quick-start.md` for collaborator onboarding
- Platform sibling files `installation/macos.md`, `installation/linux.md`

## References

- specs/006_expand_agent_system_docs/plans/01_expand-docs-directory.md — full 8-phase plan
- specs/006_expand_agent_system_docs/reports/01_team-research.md — synthesized research
- docs/installation.md — new installation guide
- docs/agent-system/ — new subdirectory (6 files)
- docs/README.md, README.md, docs/settings.md, docs/office-workflows.md — inbound link repairs
