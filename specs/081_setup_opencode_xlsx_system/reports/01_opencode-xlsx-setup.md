# Research Report: Task #81

**Task**: 81 - Set up .opencode/ directory with xlsx skill mirroring
**Started**: 2026-05-08T16:00:00Z
**Completed**: 2026-05-08T16:30:00Z
**Effort**: small
**Dependencies**: 79 (completed)
**Sources/Inputs**: Codebase exploration of .claude/, .opencode/, extension loader config, extension source files
**Artifacts**: specs/081_setup_opencode_xlsx_system/reports/01_opencode-xlsx-setup.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The zed project does NOT have a `.opencode/` directory -- it only uses `.claude/`. OpenCode support lives in the nvim project (`~/.config/nvim/.opencode/`).
- The extension loader uses a shared Lua system (`config.lua`) with presets that map `.claude/` paths to `.opencode/` equivalents: agents go to `agent/subagents/` (not `agents/`), the config file is `AGENTS.md` (not `CLAUDE.md`), and the section prefix is `extension_oc_` (not `extension_`).
- Task 79 created `skill-xlsx/SKILL.md` and `xlsx-agent.md` in the zed `.claude/` directory and updated the nvim source `manifest.json`, but the actual source files for the extension were NOT copied into the nvim source extension directory (`~/.config/nvim/.claude/extensions/filetypes/`). Additionally, the `opencode-agents.json` file was NOT updated with the xlsx-agent entry.
- Task 81 requires: (1) copying source files to the nvim extension source, (2) updating `opencode-agents.json`, (3) updating the `.opencode/` EXTENSION.md, and (4) running the extension loader to propagate changes to both `.claude/` and `.opencode/` targets in nvim.

## Context & Scope

The two-layer extension system manages files across two AI coding assistants (Claude Code and OpenCode) from a single source of truth in `~/.config/nvim/.claude/extensions/`. The loader copies files into either `.claude/` or `.opencode/` depending on which system is being configured. The zed project receives extensions loaded from the same nvim source.

### Key Question: Does `.opencode/` exist for zed?

**No.** The zed project (`~/.config/zed/`) has only `.claude/`. There is no `.opencode/` directory in the zed repository and there is no indication that OpenCode is used with zed. The `.opencode/` directories exist in:
- `~/.config/.opencode/` (an older, different system -- not relevant)
- `~/.config/nvim/.opencode/` (the target for OpenCode in the nvim project)

## Findings

### 1. Structural Differences: `.claude/` vs `.opencode/`

The extension loader's `config.lua` (`~/.config/nvim/lua/neotex/plugins/ai/shared/extensions/config.lua`) defines the mapping:

| Property | `.claude/` Preset | `.opencode/` Preset |
|----------|-------------------|---------------------|
| `base_dir` | `.claude` | `.opencode` |
| `config_file` | `CLAUDE.md` | `OPENCODE.md` (but actually `AGENTS.md` in practice) |
| `section_prefix` | `extension_` | `extension_oc_` |
| `agents_subdir` | `agents` | `agent/subagents` |
| `merge_target_key` | `claudemd` | `opencode_md` |
| `global_extensions_dir` | `~/.config/nvim/.claude/extensions` | `~/.config/nvim/.opencode/extensions` |

**Critical difference**: Agents go to `agent/subagents/` in `.opencode/` instead of `agents/` in `.claude/`.

### 2. Skill Format

Skills use the same `SKILL.md` format in both systems. The only difference is internal path references (`.claude/context/...` vs `.opencode/context/...`). The nvim `.opencode/` skills directory already contains 21 skill directories using the identical `SKILL.md` + optional `README.md` structure.

Path references within SKILL.md files are adjusted by the loader or at runtime. Example from nvim `.opencode/skills/skill-implementer/SKILL.md`:
```
- Path: `.opencode/context/formats/return-metadata-file.md`
```

### 3. Agent Format

Agents use the same `.md` format. In `.claude/`, agents live at `.claude/agents/xlsx-agent.md`. In `.opencode/`, they live at `.opencode/agent/subagents/xlsx-agent.md`. The loader handles this via the `agents_subdir` config parameter.

### 4. OpenCode-Specific: `opencode-agents.json`

OpenCode requires an additional JSON registration file (`opencode-agents.json`) in each extension source that maps agent names to their file paths and tool permissions. The current filetypes extension's `opencode-agents.json` includes filetypes-router, document, spreadsheet, and presentation agents, but NOT the xlsx-agent.

### 5. Source Extension Status

The nvim source filetypes extension (`~/.config/nvim/.claude/extensions/filetypes/`) has been partially updated by Task 79:

**Updated (by Task 79)**:
- `manifest.json` -- includes `xlsx-agent.md` in agents, `skill-xlsx` in skills, `xlsx.md` in commands, routing entries for `filetypes:xlsx`
- `EXTENSION.md` (claude version) -- includes skill-xlsx/xlsx-agent in skill-agent mapping table and `/xlsx` command

**NOT updated (needs Task 81)**:
- `agents/xlsx-agent.md` -- does NOT exist in source extension (only in zed `.claude/agents/`)
- `skills/skill-xlsx/SKILL.md` -- does NOT exist in source extension (only in zed `.claude/skills/`)
- `commands/xlsx.md` -- does NOT exist in source extension (only in zed `.claude/commands/`)
- `opencode-agents.json` -- does NOT include xlsx-agent entry

### 6. OpenCode EXTENSION.md

The `.opencode/` version of the filetypes EXTENSION.md (`~/.config/nvim/.opencode/extensions/filetypes/EXTENSION.md`) does NOT include xlsx entries. It has a different (simpler) version compared to the `.claude/` EXTENSION.md, lacking scrape-agent, docx-edit-agent, and xlsx-agent entries.

### 7. Index Entries

The extension's `index-entries.json` was reportedly updated by Task 79 to include xlsx-agent in tool-detection and dependency-guide entries. This needs verification.

## Recommendations

### Implementation Approach

The task should be divided into these steps:

**Step 1: Copy source files to extension directory**
- Copy `~/.config/zed/.claude/agents/xlsx-agent.md` to `~/.config/nvim/.claude/extensions/filetypes/agents/xlsx-agent.md`
- Copy `~/.config/zed/.claude/skills/skill-xlsx/SKILL.md` to `~/.config/nvim/.claude/extensions/filetypes/skills/skill-xlsx/SKILL.md`
- Copy `~/.config/zed/.claude/commands/xlsx.md` to `~/.config/nvim/.claude/extensions/filetypes/commands/xlsx.md`

**Step 2: Create `.opencode/` skill variant**
The skill SKILL.md needs path references adjusted from `.claude/` to `.opencode/`:
- `.claude/context/formats/subagent-return.md` -> `.opencode/context/formats/subagent-return.md`
- Context pointer paths need `.opencode/` prefix
- Create in nvim `.opencode/extensions/filetypes/skills/skill-xlsx/SKILL.md` OR rely on the loader to adjust paths automatically

**Step 3: Update `opencode-agents.json`**
Add xlsx-agent entry:
```json
{
  "xlsx": {
    "description": "XLSX creation, editing, and analysis using openpyxl and pandas",
    "mode": "subagent",
    "prompt": "{file:.opencode/agent/subagents/xlsx-agent.md}",
    "tools": {
      "read": true,
      "write": true,
      "edit": true,
      "glob": true,
      "grep": true,
      "bash": true
    }
  }
}
```

**Step 4: Update `.opencode/` EXTENSION.md**
Add xlsx entries to the skill-agent mapping table and add the `/xlsx` command to the commands table. Match the format of the `.claude/` EXTENSION.md but with `.opencode/` paths.

**Step 5: Run extension loader**
Reload the filetypes extension in both `.claude/` and `.opencode/` targets via the extension picker or programmatic reload. This propagates all changes.

### Path Reference Strategy

Two approaches for SKILL.md path references:
1. **Maintain separate versions**: One with `.claude/` paths, one with `.opencode/` paths. The loader copies from `extensions/filetypes/skills/` to the target.
2. **Loader adjusts paths**: The loader could sed-replace `.claude/` with `.opencode/` during copy. Current evidence suggests the loader does NOT do this -- the `.opencode/` extensions directory has its own skill files with `.opencode/` paths hardcoded.

The nvim `.opencode/extensions/filetypes/skills/` directory shows that separate skill copies exist for `.opencode/` with adjusted paths. This is the established pattern.

## Decisions

- Task 81's scope is primarily about the nvim source extension, NOT about creating a `.opencode/` directory in the zed project
- The `.opencode/` extensions maintain separate copies of SKILL.md files with `.opencode/` path references
- The `opencode-agents.json` must be updated for agent discovery in OpenCode
- The EXTENSION.md for `.opencode/` should match the `.claude/` version's content with appropriate path adjustments

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Extension loader reload fails | Test with `verify_extension()` after reload |
| Path reference mismatch | Compare existing `.opencode/` skill files for established path patterns |
| Broken routing | Verify `manifest.json` routing entries match both systems |
| Missing context files | The context files (tool-detection.md, dependency-guide.md) are shared; verify they exist at `.opencode/context/` paths |

## Appendix

### Files Examined
- `~/.config/zed/.claude/skills/skill-xlsx/SKILL.md` -- The skill to mirror
- `~/.config/zed/.claude/agents/xlsx-agent.md` -- The agent to mirror
- `~/.config/zed/.claude/commands/xlsx.md` -- The command to mirror
- `~/.config/nvim/lua/neotex/plugins/ai/shared/extensions/config.lua` -- Loader config presets
- `~/.config/nvim/.claude/extensions/filetypes/manifest.json` -- Source extension manifest
- `~/.config/nvim/.claude/extensions/filetypes/opencode-agents.json` -- OpenCode agent registration
- `~/.config/nvim/.opencode/extensions/filetypes/manifest.json` -- OpenCode target manifest
- `~/.config/nvim/.opencode/extensions/filetypes/EXTENSION.md` -- OpenCode target EXTENSION.md
- `~/.config/nvim/.opencode/skills/skill-implementer/SKILL.md` -- Reference for .opencode skill format
- `~/.config/nvim/.opencode/agent/subagents/` -- Reference for .opencode agent location

### Key Directory Mappings

| Component | `.claude/` Path | `.opencode/` Path |
|-----------|----------------|-------------------|
| Skill | `.claude/skills/skill-xlsx/SKILL.md` | `.opencode/skills/skill-xlsx/SKILL.md` |
| Agent | `.claude/agents/xlsx-agent.md` | `.opencode/agent/subagents/xlsx-agent.md` |
| Command | `.claude/commands/xlsx.md` | `.opencode/commands/xlsx.md` |
| Context | `.claude/context/project/filetypes/` | `.opencode/context/project/filetypes/` |
| Config | `.claude/CLAUDE.md` | `.opencode/AGENTS.md` |
| Index | `.claude/context/index.json` | `.opencode/context/index.json` |
