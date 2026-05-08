# Implementation Plan: Task #81

- **Task**: 81 - Set up .opencode/ directory with xlsx skill mirroring
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: 79 (completed)
- **Research Inputs**: specs/081_setup_opencode_xlsx_system/reports/01_opencode-xlsx-setup.md
- **Artifacts**: plans/01_opencode-xlsx-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Task 79 created the xlsx-agent, skill-xlsx, and /xlsx command in the zed project's `.claude/` directory, and updated the nvim source `manifest.json` to reference them. However, the actual source files were not copied into the nvim extension source directory (`~/.config/nvim/.claude/extensions/filetypes/`), and the `.opencode/` side was not updated at all. This plan covers: (1) copying source files into the nvim `.claude/` extension source, (2) creating `.opencode/`-adjusted variants, (3) updating `opencode-agents.json` for agent discovery, (4) updating the `.opencode/` EXTENSION.md, manifest, and index entries, and (5) running the extension loader to propagate changes.

### Research Integration

Key findings from the research report (01_opencode-xlsx-setup.md):
- The zed project has no `.opencode/` directory; OpenCode support lives in `~/.config/nvim/.opencode/`
- `.opencode/` uses `agent/subagents/` (not `agents/`), `AGENTS.md` (not `CLAUDE.md`), and `extension_oc_` section prefix
- The `.opencode/` extensions directory maintains separate skill copies with `.opencode/` path references (not auto-adjusted by the loader)
- `opencode-agents.json` needs an `xlsx` entry for agent discovery
- The `.opencode/` EXTENSION.md and manifest.json are both missing xlsx entries

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No active roadmap items. ROADMAP.md has no items defined.

## Goals & Non-Goals

**Goals**:
- Copy xlsx-agent.md, skill-xlsx/SKILL.md, and xlsx.md command to the nvim `.claude/` extension source directory
- Create `.opencode/`-adjusted variants of skill and agent files in the nvim `.opencode/` extension directory
- Update `opencode-agents.json` with the xlsx-agent entry
- Update `.opencode/` EXTENSION.md with xlsx skill-agent mapping and /xlsx command
- Update `.opencode/` manifest.json to include xlsx entries in agents, skills, commands, and routing
- Verify consistency between `.claude/` and `.opencode/` extension configurations

**Non-Goals**:
- Creating a `.opencode/` directory in the zed project (only nvim has OpenCode support)
- Modifying the extension loader (config.lua) itself
- Running the extension loader (this is a manual step the user performs after file changes)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Path references in SKILL.md not fully adjusted for `.opencode/` | M | M | Compare against existing `.opencode/` skill files (e.g., skill-filetypes) for the established path pattern |
| `opencode-agents.json` entry uses wrong tool permissions | L | L | Match the existing agent entries' tool patterns (read, write, edit, glob, grep, bash) |
| `.opencode/` manifest routing entries inconsistent with `.claude/` | M | L | Derive `.opencode/` routing from the `.claude/` manifest, keeping same skill names |
| Index entries not updated for `.opencode/` | M | M | Check `index-entries.json` in both source directories for consistency |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Copy source files to nvim `.claude/` extension [NOT STARTED]

**Goal**: Populate the nvim `.claude/` extension source directory with the xlsx files that Task 79 created only in the zed project.

**Tasks**:
- [ ] Copy `~/.config/zed/.claude/agents/xlsx-agent.md` to `~/.config/nvim/.claude/extensions/filetypes/agents/xlsx-agent.md`
- [ ] Create directory `~/.config/nvim/.claude/extensions/filetypes/skills/skill-xlsx/`
- [ ] Copy `~/.config/zed/.claude/skills/skill-xlsx/SKILL.md` to `~/.config/nvim/.claude/extensions/filetypes/skills/skill-xlsx/SKILL.md`
- [ ] Copy `~/.config/zed/.claude/commands/xlsx.md` to `~/.config/nvim/.claude/extensions/filetypes/commands/xlsx.md`
- [ ] Verify all three files exist in the nvim source extension

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `~/.config/nvim/.claude/extensions/filetypes/agents/xlsx-agent.md` - new file (copy from zed)
- `~/.config/nvim/.claude/extensions/filetypes/skills/skill-xlsx/SKILL.md` - new file (copy from zed)
- `~/.config/nvim/.claude/extensions/filetypes/commands/xlsx.md` - new file (copy from zed)

**Verification**:
- All three files exist in the nvim source extension directory
- File contents match the zed originals

---

### Phase 2: Create `.opencode/` variants [NOT STARTED]

**Goal**: Create `.opencode/`-adjusted copies of the xlsx skill, agent, and command in the nvim `.opencode/` extension directory, following the established pattern of separate copies with `.opencode/` path references.

**Tasks**:
- [ ] Create `~/.config/nvim/.opencode/extensions/filetypes/agents/xlsx-agent.md` by adapting the `.claude/` version: replace `.claude/context/` references with `.opencode/context/core/`, replace `.claude/agents/` with `.opencode/agent/subagents/`, and adjust any other `.claude/`-specific paths
- [ ] Create `~/.config/nvim/.opencode/extensions/filetypes/skills/skill-xlsx/SKILL.md` by adapting the `.claude/` version: replace `.claude/context/formats/subagent-return.md` with `.opencode/context/core/formats/subagent-return.md` (matching the pattern from skill-filetypes/SKILL.md in `.opencode/`)
- [ ] Create `~/.config/nvim/.opencode/extensions/filetypes/commands/xlsx.md` by adapting the `.claude/` version: update any `.claude/`-specific path references to `.opencode/` equivalents
- [ ] Verify path references by comparing with existing `.opencode/` skill files (e.g., skill-filetypes/SKILL.md) for pattern consistency

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `~/.config/nvim/.opencode/extensions/filetypes/agents/xlsx-agent.md` - new file (adapted from `.claude/` version)
- `~/.config/nvim/.opencode/extensions/filetypes/skills/skill-xlsx/SKILL.md` - new file (adapted from `.claude/` version)
- `~/.config/nvim/.opencode/extensions/filetypes/commands/xlsx.md` - new file (adapted from `.claude/` version)

**Verification**:
- All three files exist in the `.opencode/` extension directory
- Path references use `.opencode/` prefix (not `.claude/`)
- Pattern matches existing `.opencode/` skill/agent files

---

### Phase 3: Update `opencode-agents.json` and `.opencode/` EXTENSION.md [NOT STARTED]

**Goal**: Register the xlsx-agent in `opencode-agents.json` for OpenCode agent discovery and update the `.opencode/` EXTENSION.md with xlsx entries.

**Tasks**:
- [ ] Add `xlsx` entry to `~/.config/nvim/.claude/extensions/filetypes/opencode-agents.json` under the `agent` key, with description "XLSX creation, editing, and analysis using openpyxl and pandas", mode "subagent", prompt `{file:.opencode/agent/subagents/xlsx-agent.md}`, and tools matching existing entries (read, write, edit, glob, grep, bash)
- [ ] Add `xlsx` entry to `~/.config/nvim/.opencode/extensions/filetypes/opencode-agents.json` with the same structure (if this is a separate file; verify whether it mirrors the source or is the same file)
- [ ] Update `~/.config/nvim/.opencode/extensions/filetypes/EXTENSION.md`: add `skill-xlsx | xlsx-agent | XLSX creation, editing, and analysis (openpyxl)` to the Skill-Agent Mapping table
- [ ] Update `~/.config/nvim/.opencode/extensions/filetypes/EXTENSION.md`: add `/xlsx` command to the Commands table (if a commands table exists; otherwise add a commands section)

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `~/.config/nvim/.claude/extensions/filetypes/opencode-agents.json` - add xlsx agent entry
- `~/.config/nvim/.opencode/extensions/filetypes/opencode-agents.json` - add xlsx agent entry (if separate)
- `~/.config/nvim/.opencode/extensions/filetypes/EXTENSION.md` - add xlsx skill-agent and command entries

**Verification**:
- `opencode-agents.json` contains an `xlsx` key under `agent`
- EXTENSION.md skill-agent table includes xlsx-agent row
- JSON is valid (parse with python or jq)

---

### Phase 4: Update `.opencode/` manifest and index entries [NOT STARTED]

**Goal**: Update the `.opencode/` manifest.json to include xlsx in agents, skills, commands, and routing arrays, and verify index-entries.json consistency.

**Tasks**:
- [ ] Update `~/.config/nvim/.opencode/extensions/filetypes/manifest.json`: add `"xlsx-agent.md"` to `provides.agents` array
- [ ] Update `~/.config/nvim/.opencode/extensions/filetypes/manifest.json`: add `"skill-xlsx"` to `provides.skills` array
- [ ] Update `~/.config/nvim/.opencode/extensions/filetypes/manifest.json`: add `"xlsx.md"` to `provides.commands` array
- [ ] Update `~/.config/nvim/.opencode/extensions/filetypes/manifest.json`: add `"filetypes:xlsx": "skill-xlsx"` to `routing.research`, `routing.plan` (as `"skill-planner"`), and `routing.implement` sections
- [ ] Bump the manifest version from `2.0.0` to `2.2.0` to match the `.claude/` source version
- [ ] Compare `~/.config/nvim/.opencode/extensions/filetypes/index-entries.json` with `~/.config/nvim/.claude/extensions/filetypes/index-entries.json` and add any missing xlsx-related entries
- [ ] Validate all modified JSON files parse correctly

**Timing**: 30 minutes

**Depends on**: 2, 3

**Files to modify**:
- `~/.config/nvim/.opencode/extensions/filetypes/manifest.json` - add xlsx to provides and routing
- `~/.config/nvim/.opencode/extensions/filetypes/index-entries.json` - add xlsx entries if missing

**Verification**:
- `manifest.json` lists xlsx-agent.md, skill-xlsx, xlsx.md in provides
- Routing entries exist for `filetypes:xlsx` in research, plan, and implement
- Manifest version matches `.claude/` version (2.2.0)
- All JSON files parse without errors
- `index-entries.json` has parity with `.claude/` version for xlsx entries

## Testing & Validation

- [ ] All source files exist in `~/.config/nvim/.claude/extensions/filetypes/` (agents, skills, commands)
- [ ] All `.opencode/` variants exist in `~/.config/nvim/.opencode/extensions/filetypes/` (agents, skills, commands)
- [ ] `opencode-agents.json` includes xlsx-agent entry and parses as valid JSON
- [ ] `.opencode/` EXTENSION.md includes xlsx skill-agent mapping and /xlsx command
- [ ] `.opencode/` manifest.json includes xlsx in all provides arrays and routing sections
- [ ] Path references in `.opencode/` files use `.opencode/` prefix (not `.claude/`)
- [ ] No dangling references -- all paths in SKILL.md and agent files point to files that exist or will exist after loader propagation

## Artifacts & Outputs

- `specs/081_setup_opencode_xlsx_system/plans/01_opencode-xlsx-plan.md` (this file)
- `specs/081_setup_opencode_xlsx_system/summaries/01_opencode-xlsx-summary.md` (post-implementation)

## Rollback/Contingency

To revert all changes:
1. Remove added files from `~/.config/nvim/.claude/extensions/filetypes/` (agents/xlsx-agent.md, skills/skill-xlsx/, commands/xlsx.md)
2. Remove added files from `~/.config/nvim/.opencode/extensions/filetypes/` (same set)
3. Restore `opencode-agents.json` to pre-change state (remove xlsx entry from both locations)
4. Restore `manifest.json` and `EXTENSION.md` in `.opencode/` to pre-change state via git
5. Re-run extension loader to propagate the reverted state
