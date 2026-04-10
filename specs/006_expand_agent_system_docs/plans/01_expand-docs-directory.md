# Implementation Plan: Expand agent-system.md into docs/ directory

- **Task**: 6 - Expand agent-system.md into docs/ directory
- **Status**: [IMPLEMENTING]
- **Effort**: 7.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/006_expand_agent_system_docs/reports/01_team-research.md
- **Artifacts**: plans/01_expand-docs-directory.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/workflows.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Split the 378-line `docs/agent-system.md` into a `docs/agent-system/` subdirectory of six focused files plus a new top-level `docs/installation.md`, following the progressive-disclosure pattern (summary -> example -> advanced -> links). The new documentation must cover `claude-acp` (the Zed <-> Claude Code bridge) which is currently absent, apply the "thin wrapper + strong link" policy (link into `.claude/docs/` and `.claude/CLAUDE.md` rather than duplicate), and repair nine existing hard links across `README.md`, `docs/README.md`, `docs/settings.md`, and `docs/office-workflows.md` (including a fragment link). Done when all new files exist, all inbound links resolve, `docs/agent-system.md` is deleted, and a manual link-check pass confirms no broken references.

### Research Integration

The synthesized team research (4 teammates, session `sess_1775848282_0a1943`) resolved 7 conflicts and landed on a 6-file `docs/agent-system/` subdirectory plus `docs/installation.md`. Key integrated decisions: (1) use registry-style `claude-acp` config as the recommended default, with custom config in a Platform Notes section for NixOS; (2) accept Task 5's 378-line file as the starting point, do not re-research; (3) enforce thin-wrapper linking to avoid drift with `.claude/docs/guides/user-guide.md`; (4) split "setup" (installation.md) from "usage + mechanism" (zed-agent-panel.md) for claude-acp coverage. Out-of-scope follow-ups (link-check script, back-reference from `.claude/CLAUDE.md`, quick-start, platform siblings) are recorded but NOT executed in this task.

### Prior Plan Reference

No prior plan for task 6. Task 5's plan (`specs/005_update_agent_system_docs/plans/01_implementation-plan.md`) produced the current 378-line `agent-system.md` and is referenced only as the source material being split.

### Roadmap Alignment

No ROAD_MAP.md consulted for this plan (not provided or not present at planning time). This work advances documentation quality for the Zed workspace but does not encode a specific roadmap item.

## Goals & Non-Goals

**Goals**:
- Replace `docs/agent-system.md` with `docs/agent-system/{README,zed-agent-panel,workflow,commands,context-and-memory,architecture}.md`
- Create `docs/installation.md` (macOS Homebrew focus + Platform Notes for NixOS)
- Add first-class `claude-acp` coverage (setup in installation.md; usage + mechanism in zed-agent-panel.md)
- Apply progressive disclosure (summary -> example -> advanced -> links) in every new file
- Repair all 9 hard links to `docs/agent-system.md` in 4 inbound files
- Add a new `agent_servers` reference section to `docs/settings.md`
- Preserve Task 5's Main Workflow and Command Catalog content verbatim into the new files (no re-writing)
- Avoid any transient broken-link state during execution

**Non-Goals**:
- Link-check script for `docs/**/*.md` (recorded as follow-up)
- Back-reference from `.claude/CLAUDE.md` to `docs/README.md` (recorded as follow-up)
- `docs/quick-start.md` for collaborator onboarding (recorded as follow-up)
- Platform sibling files `installation/macos.md`, `installation/linux.md` (recorded as follow-up)
- Re-writing or extending the Command Catalog content produced by Task 5
- Modifying `.claude/docs/` or `.claude/CLAUDE.md`
- Modifying `docs/keybindings.md` (explicitly unchanged per research)
- Auto-generating command docs from frontmatter (research judged premature)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Transient broken links while old file is deleted before new files exist | H | M | Order phases so all new files exist BEFORE inbound links are repaired, and delete `agent-system.md` only in the final cleanup phase |
| Fragment link `agent-system.md#mcp-tool-setup` silently breaks | M | M | Dedicated task in Phase 6 to repair this specific fragment to `installation.md#install-mcp-tools`; verify anchor exists in Phase 7 |
| Content drift between `commands.md` and `.claude/docs/guides/user-guide.md` | M | M | Thin-wrapper policy: each command entry is one-sentence summary + example + link; no duplicated prose |
| macOS-only installation doc conflicts with the actual NixOS machine | M | L | Include a clearly labeled `## Platform Notes` section with the current custom `agent_servers` config as the NixOS adaptation |
| Losing verbatim content from Task 5's recent rewrite during the extraction | M | L | Phase 2 extracts content by copying line ranges from `docs/agent-system.md` (per research's line-number mapping) before any deletion |
| claude-acp registry vs custom confusion for readers | M | L | Document registry as the recommended default in the main installation flow; document custom only in Platform Notes |
| Over-linking producing brittle cross-references | L | M | Each file has a small curated "See also" section, not inline link spam |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4, 5 | 2 |
| 4 | 6 | 3, 4, 5 |
| 5 | 7 | 6 |
| 6 | 8 | 7 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Scaffold directory and stage source [COMPLETED]

**Goal**: Create the new directory structure and capture the current `docs/agent-system.md` content as a working reference so subsequent extract phases can copy from a stable source.

**Tasks**:
- [ ] Create `docs/agent-system/` directory
- [ ] Read `docs/agent-system.md` in full and record the section -> target-file mapping from the research report as a comment block at the top of this plan's working notes (not committed)
- [ ] Confirm `docs/keybindings.md`, `docs/settings.md`, `docs/office-workflows.md`, `docs/README.md`, and top-level `README.md` are present and record their line counts
- [ ] Confirm `settings.json` lines 136-144 (current `agent_servers` custom config for NixOS) so Phase 2 can quote them accurately in Platform Notes

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `docs/agent-system/` (new directory only)

**Verification**:
- `docs/agent-system/` exists and is empty
- Source file `docs/agent-system.md` is unchanged

---

### Phase 2: Write docs/installation.md [COMPLETED]

**Goal**: Produce the new macOS-focused installation guide with claude-acp registry config as the recommended default and a Platform Notes section for NixOS.

**Tasks**:
- [ ] Create `docs/installation.md` with sections: Prerequisites, Install Homebrew, Install Zed (including `zed@preview`), Install Claude Code CLI (`brew install anthropics/claude/claude-code` + `claude auth login`), Configure claude-acp (registry config block), Authenticate in Zed (`/login` distinct from CLI auth), Install MCP Tools (SuperDoc + openpyxl, extracted from current `agent-system.md` lines 266-295), Verify (checklist), Platform Notes (NixOS custom config quoting `settings.json` lines 136-144)
- [ ] Include the registry config example exactly as specified in the research:
      `"agent_servers": { "claude-acp": { "type": "registry", "env": {} } }`
- [ ] Add anchor `## Install MCP Tools` so fragment links from `office-workflows.md` can target `installation.md#install-mcp-tools`
- [ ] Add "See also" links to `docs/settings.md`, `docs/agent-system/zed-agent-panel.md`, and `.claude/docs/guides/user-installation.md`
- [ ] Follow progressive disclosure: one-paragraph summary -> minimal working example (`brew install ...`) -> detailed steps -> platform notes -> links

**Timing**: 1.25 hours

**Depends on**: 1

**Files to modify**:
- `docs/installation.md` (new)

**Verification**:
- `docs/installation.md` exists
- Contains a heading whose GitHub-style anchor is `install-mcp-tools`
- Contains both the registry config example and the NixOS custom config block
- No references to `agent-system.md` (the old file)

---

### Phase 3: Write docs/agent-system/README.md and zed-agent-panel.md [COMPLETED]

**Goal**: Produce the orientation entry point and the claude-acp usage + mechanism doc. These are the two files most directly tied to the "claude-acp coverage" requirement.

**Tasks**:
- [ ] Create `docs/agent-system/README.md` with sections: Two AI systems (comparison table), When to use each, Navigation (list of docs in this subdirectory with one-line summaries), Quick-start (first task walkthrough: `/task` -> `/research` -> `/implement`)
- [ ] Create `docs/agent-system/zed-agent-panel.md` with sections: Opening the panel, Built-in AI vs Claude Code thread, How claude-acp works under the hood (explain `@zed-industries/claude-agent-acp` as the ACP bridge Zed spawns per `agent_servers`, which in turn launches the Claude Code binary), Authenticating with `/login`, Keybindings quick reference (link to `docs/keybindings.md`), Inline Assist, Edit Predictions, Troubleshooting (`dev: open acp logs`)
- [ ] Both files: use progressive disclosure pattern
- [ ] Both files: add "See also" sections linking into `.claude/README.md`, `.claude/docs/guides/user-guide.md`, and `.claude/docs/architecture/system-overview.md` where appropriate
- [ ] Do NOT duplicate content from `.claude/docs/`; summarize and link

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `docs/agent-system/README.md` (new)
- `docs/agent-system/zed-agent-panel.md` (new)

**Verification**:
- Both files exist and are non-empty
- Both contain a "See also" section with at least one link into `.claude/`
- `zed-agent-panel.md` explicitly names `@zed-industries/claude-agent-acp`
- `README.md` has a navigation section listing all 6 files in `docs/agent-system/`

---

### Phase 4: Write docs/agent-system/workflow.md and commands.md [COMPLETED]

**Goal**: Extract and restructure the Main Workflow narrative and Command Catalog reference (Task 5 content) into two audience-distinct files.

**Tasks**:
- [ ] Create `docs/agent-system/workflow.md` with sections: State machine diagram (NOT STARTED -> RESEARCHED -> PLANNED -> COMPLETED), Creating a task, Researching, Planning, Implementing, Finishing (`/todo`), Advanced flags (`--team`, multi-task syntax, `--remember`), Exception states (BLOCKED, PARTIAL, EXPANDED)
- [ ] Port the Main Workflow content from current `docs/agent-system.md` lines 51-103 verbatim where possible
- [ ] Create `docs/agent-system/commands.md` grouped into 5 sections: Lifecycle (task, research, plan, implement, revise), Maintenance (review, todo, errors, fix-it, refresh, spawn, merge, meta, tag), Memory (learn), Documents (convert, table, slides, scrape, edit), Research & Grants (grant, budget, timeline, funds, talk)
- [ ] Per command: one-sentence summary + minimal example + one-line flag list + link to `.claude/commands/{name}.md` and `.claude/docs/guides/user-guide.md`. Do not duplicate full command specs.
- [ ] Port the Command Catalog content from current `docs/agent-system.md` lines 104-165 verbatim where possible
- [ ] Add cross-links between `workflow.md` and `commands.md`

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `docs/agent-system/workflow.md` (new)
- `docs/agent-system/commands.md` (new)

**Verification**:
- Both files exist
- `commands.md` has all 5 group headings and every command from the catalog is present with a link
- `workflow.md` covers all lifecycle states
- No inline duplication of `.claude/docs/guides/user-guide.md` content (spot-check 3 commands)

---

### Phase 5: Write docs/agent-system/context-and-memory.md and architecture.md [COMPLETED]

**Goal**: Produce the memory/context explanation and the advanced architecture reference.

**Tasks**:
- [ ] Create `docs/agent-system/context-and-memory.md` with sections: Two memory layers (project `.memory/` vs auto-memory `~/.claude/projects/`), Project vault structure + read/write paths, Auto-memory (harness-managed), `/learn` usage, `/research --remember`, Five context layers table, Decision flowchart (where should new content go?)
- [ ] Port content from current `docs/agent-system.md` lines 166-213 where applicable
- [ ] Link to `.memory/README.md` and `.claude/context/architecture/context-layers.md`
- [ ] Create `docs/agent-system/architecture.md` with sections: Three-layer pipeline (commands -> skills -> agents), Checkpoint execution (GATE IN -> DELEGATE -> GATE OUT -> COMMIT), Session IDs, State files (TODO.md, state.json, errors.json), Configuration tree, Extensions (explain that `<leader>ac` does not apply in Zed), Task routing by task_type
- [ ] Port content from current `docs/agent-system.md` lines 214-265 where applicable
- [ ] Link to `.claude/README.md`, `.claude/docs/architecture/system-overview.md`, `.claude/docs/guides/component-selection.md`
- [ ] Both files: progressive disclosure pattern

**Timing**: 1.25 hours

**Depends on**: 1

**Files to modify**:
- `docs/agent-system/context-and-memory.md` (new)
- `docs/agent-system/architecture.md` (new)

**Verification**:
- Both files exist
- `context-and-memory.md` distinguishes project vault from auto-memory
- `architecture.md` describes the three-layer pipeline and checkpoint execution
- All listed cross-references resolve to existing files

---

### Phase 6: Repair inbound links [COMPLETED]

**Goal**: Update every inbound reference to `docs/agent-system.md` so links point to the new files. This MUST happen after Phases 2-5 so that no intermediate state has dangling links.

**Tasks**:
- [ ] `/home/benjamin/.config/zed/README.md`: replace all 5 references to `docs/agent-system.md`. Context-aware replacement: install-related contexts -> `docs/installation.md`; overview/navigation contexts -> `docs/agent-system/README.md`
- [ ] `/home/benjamin/.config/zed/docs/README.md`: replace `[Agent System](agent-system.md)` -> `[Agent System](agent-system/README.md)`; add a new entry `[Installation](installation.md)`
- [ ] `/home/benjamin/.config/zed/docs/settings.md`: replace `[Agent system](agent-system.md)` -> `[Agent system](agent-system/README.md)`; add a new `## agent_servers` section documenting the claude-acp config (registry and custom variants) with a link to `docs/installation.md`
- [ ] `/home/benjamin/.config/zed/docs/office-workflows.md`: replace `[MCP Tool Setup](agent-system.md#mcp-tool-setup)` -> `[MCP Tool Setup](installation.md#install-mcp-tools)`; repair the second MCP Tool Setup reference identically
- [ ] Grep the repository for any remaining reference to `agent-system.md` (not `agent-system/`) and repair or document

**Timing**: 1.0 hours

**Depends on**: 2, 3, 4, 5

**Files to modify**:
- `README.md`
- `docs/README.md`
- `docs/settings.md`
- `docs/office-workflows.md`

**Verification**:
- `grep -rn "agent-system\\.md" .` in the repo (excluding specs/ and .claude/) returns zero matches outside `docs/agent-system.md` itself
- All replaced links point to files that exist
- `docs/settings.md` contains an `## agent_servers` heading

---

### Phase 7: Link and content validation [COMPLETED]

**Goal**: Manually validate every new file resolves its links, the fragment link from `office-workflows.md` targets a real anchor, and each file reads as a coherent standalone document.

**Tasks**:
- [ ] For each new file (`docs/installation.md`, `docs/agent-system/*.md`), extract every markdown link and verify the target path exists (relative to the file's location)
- [ ] Verify `docs/installation.md` has a section whose GitHub-slug is `install-mcp-tools` (heading text "Install MCP Tools")
- [ ] Verify the fragment link `installation.md#install-mcp-tools` from `docs/office-workflows.md` resolves correctly
- [ ] Smoke-read each new file end-to-end; confirm progressive disclosure pattern is present (summary -> example -> detail -> links)
- [ ] Confirm no new file duplicates more than a paragraph of content from `.claude/docs/guides/user-guide.md` (spot-check 3 locations)
- [ ] Confirm `docs/agent-system.md` is still present (deletion is Phase 8)

**Timing**: 0.75 hours

**Depends on**: 6

**Files to modify**:
- None (read-only validation; fix in place if issues found, looping back to the owning phase)

**Verification**:
- Zero broken internal links in `docs/**/*.md`
- Fragment link resolves
- Each new file has a "See also" or equivalent link-out section

---

### Phase 8: Delete docs/agent-system.md and final sweep [COMPLETED]

**Goal**: Remove the now-obsolete monolithic file only after all inbound links have been repaired and validated.

**Tasks**:
- [ ] Re-run `grep -rn "agent-system\\.md" .` excluding `specs/` and `.claude/`; confirm zero matches outside the file itself
- [ ] Delete `docs/agent-system.md`
- [ ] Re-run `grep -rn "agent-system\\.md" .` excluding `specs/` and `.claude/`; confirm zero matches (the file is gone, and no links reference it)
- [ ] Update `docs/README.md` table of contents if a stale mention remains
- [ ] Final read of `docs/README.md` to confirm it correctly indexes `installation.md` and `agent-system/README.md`

**Timing**: 0.75 hours

**Depends on**: 7

**Files to modify**:
- `docs/agent-system.md` (deleted)
- `docs/README.md` (possibly)

**Verification**:
- `docs/agent-system.md` does not exist
- No references to `docs/agent-system.md` remain in the repository (outside `specs/` and `.claude/`)
- `docs/README.md` lists both `installation.md` and `agent-system/README.md`

## Testing & Validation

- [ ] All 7 new files exist at the paths specified in the target structure
- [ ] `grep -rn "agent-system\\.md" .` excluding `specs/` and `.claude/` returns zero matches
- [ ] Fragment link `docs/installation.md#install-mcp-tools` resolves to a real heading
- [ ] Every markdown link in new files resolves (manual walk)
- [ ] Each new file contains a "See also" section or inline links into `.claude/` (thin-wrapper policy)
- [ ] `docs/installation.md` contains both the registry config block and the NixOS custom config in Platform Notes
- [ ] `docs/agent-system/zed-agent-panel.md` explicitly names `@zed-industries/claude-agent-acp` and explains the ACP mechanism
- [ ] `docs/agent-system/commands.md` covers all 5 command groups and every command listed in the research report
- [ ] `docs/settings.md` has an `agent_servers` section
- [ ] `docs/keybindings.md` is unchanged (verify with git status)

## Artifacts & Outputs

Expected outputs:
- `docs/installation.md` (NEW)
- `docs/agent-system/README.md` (NEW)
- `docs/agent-system/zed-agent-panel.md` (NEW)
- `docs/agent-system/workflow.md` (NEW)
- `docs/agent-system/commands.md` (NEW)
- `docs/agent-system/context-and-memory.md` (NEW)
- `docs/agent-system/architecture.md` (NEW)
- `README.md` (UPDATED: 5 link repairs)
- `docs/README.md` (UPDATED: add installation entry, repair agent-system link)
- `docs/settings.md` (UPDATED: add agent_servers section, repair link)
- `docs/office-workflows.md` (UPDATED: fragment link repair x2)
- `docs/agent-system.md` (DELETED)

Follow-ups recorded (NOT executed in this task):
- Link-check script for `docs/**/*.md`
- Back-reference from `.claude/CLAUDE.md` to `docs/README.md`
- `docs/quick-start.md` for collaborator onboarding
- Platform sibling files for `installation.md`

## Rollback/Contingency

All changes are git-tracked and isolated to `docs/`, `README.md`, and the task's `specs/` directory. To roll back:

1. `git status` to identify modified and new files
2. `git checkout -- docs/agent-system.md docs/README.md docs/settings.md docs/office-workflows.md README.md` (restore updated files)
3. `rm -rf docs/agent-system/ docs/installation.md` (remove new files)
4. Verify `docs/agent-system.md` is back with the Task 5 content
5. Verify all inbound links resolve to the restored monolithic file

Partial-failure strategy: if a phase fails mid-execution, the plan is designed so that new files can accumulate incrementally without affecting inbound links (which are only repaired in Phase 6). Re-running `/implement 6` will resume from the incomplete phase. Critically: DO NOT advance to Phase 8 (deletion) if any part of Phases 6 or 7 is incomplete.
