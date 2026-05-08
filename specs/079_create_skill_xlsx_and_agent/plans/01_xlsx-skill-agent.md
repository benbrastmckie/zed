# Implementation Plan: Task #79

- **Task**: 79 - Create skill-xlsx and xlsx-agent
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None (filetypes extension already loaded)
- **Research Inputs**: specs/079_create_skill_xlsx_and_agent/reports/01_xlsx-skill-agent.md
- **Artifacts**: plans/01_xlsx-skill-agent.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create the `skill-xlsx` thin-wrapper skill and `xlsx-agent` implementation agent following the established filetypes extension pattern. The skill delegates to the agent via the Task tool for xlsx creation, editing, and analysis using openpyxl and pandas. The `/edit` command xlsx stub must be updated to route to the new skill, a new `/xlsx` command must be created, and the extension registration files (manifest.json, EXTENSION.md, index-entries.json) must be updated to include the new skill/agent pair.

### Research Integration

Key findings from the research report:
- All five existing filetypes skills share an identical thin-wrapper structure (frontmatter with `allowed-tools: Task`, trigger conditions, 5-step execution, return format, error handling)
- All filetypes agents share an identical structure (frontmatter without `model:` or `mcp-servers:`, 6-stage execution flow, JSON return)
- The budget-agent contains the authoritative openpyxl workflow (color coding standards, formula patterns, number formatting) to adapt for general use
- The `/edit` command already has an xlsx stub that returns an error -- this must be updated to route to `skill-xlsx`
- Extension registration requires updates to manifest.json, EXTENSION.md, and index-entries.json (all in the nvim upstream filetypes extension)
- The recalc.py mentioned in the task description does not exist; formula verification should be built into the agent workflow
- Closest skill analog: skill-docx-edit (same create/edit/analyze scope)
- Closest agent analog: filetypes-spreadsheet-agent (same file format domain)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No actionable roadmap items found. ROADMAP.md contains placeholder entries only.

## Goals & Non-Goals

**Goals**:
- Create `skill-xlsx/SKILL.md` following the thin-wrapper delegation pattern
- Create `xlsx-agent.md` with full openpyxl creation/editing/analysis workflow
- Update `/edit` command to route `.xlsx` files to `skill-xlsx`
- Create `/xlsx` command for direct invocation
- Update extension registration (manifest.json, EXTENSION.md, index-entries.json)

**Non-Goals**:
- Creating domain-specific xlsx logic (grant budgets stay in budget-agent)
- Implementing recalc.py as a standalone script
- Adding MCP server integration (agent uses Bash + Python/openpyxl directly)
- Modifying existing agents (budget-agent, filetypes-spreadsheet-agent)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Scope creep in xlsx-agent (becoming as large as budget-agent) | M | M | Keep agent focused on general xlsx ops; domain-specific logic stays in respective agents |
| openpyxl not installed on target system | L | L | Agent uses tool-detection.md patterns and provides clear installation instructions on failure |
| Inconsistent registration across nvim/zed extensions | M | L | Update the upstream nvim extension files; zed picks up changes via sync |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 1, 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Create skill-xlsx SKILL.md [COMPLETED]

**Goal**: Create the thin-wrapper skill file that delegates xlsx operations to xlsx-agent via the Task tool

**Tasks**:
- [ ] Create `.claude/skills/skill-xlsx/SKILL.md` following the skill-docx-edit pattern
- [ ] Set frontmatter: `name: skill-xlsx`, `description: XLSX creation, editing, and analysis routing to xlsx-agent`, `allowed-tools: Task`
- [ ] Add context pointer to `subagent-return.md` (do not load eagerly)
- [ ] Define trigger conditions:
  - Direct: `/xlsx` command and `/edit` with .xlsx file
  - Implicit: "create spreadsheet", "create xlsx", "edit xlsx", "edit spreadsheet", "add formulas", "add formatting", plus `.xlsx`/`.xlsm`/`.csv`/`.tsv` extensions
  - When NOT to trigger: spreadsheet-to-table conversion (skill-filetypes-spreadsheet), simple CSV reading (Read tool), grant budget creation (skill-budget), PDF/DOCX operations
- [ ] Define 5-step execution: input validation (file path, instruction, mode), context preparation (JSON delegation context), invoke xlsx-agent via Task tool (NOT Skill tool), return validation (status values: created/edited/analyzed/partial/failed), return propagation
- [ ] Add return format section with example JSON
- [ ] Add error handling section (input validation, agent errors, tool not available)
- [ ] Add MUST NOT section (no postflight, no context loading, no Skill tool for agent invocation)

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/skills/skill-xlsx/SKILL.md` - Create new file (~200 lines)

**Verification**:
- File exists at `.claude/skills/skill-xlsx/SKILL.md`
- Frontmatter contains `allowed-tools: Task`
- Trigger conditions cover all specified patterns
- Execution section delegates via Task tool (not Skill tool)

---

### Phase 2: Create xlsx-agent.md [COMPLETED]

**Goal**: Create the implementation agent with full openpyxl workflow for xlsx creation, editing, and analysis

**Tasks**:
- [ ] Create `.claude/agents/xlsx-agent.md` following filetypes-spreadsheet-agent pattern
- [ ] Set frontmatter: `name: xlsx-agent`, `description: XLSX creation, editing, and analysis using openpyxl and pandas` (no `model:` or `mcp-servers:` fields)
- [ ] Add overview section describing three modes: create, edit, analyze
- [ ] Add agent metadata: Name, Purpose, Invoked By (skill-xlsx via Task tool), Return Format
- [ ] Define allowed tools: Read, Write, Edit, Bash, Glob, Grep
- [ ] Add context references: `@context/project/filetypes/tools/tool-detection.md` (always), `@context/project/filetypes/tools/dependency-guide.md` (when installing)
- [ ] Add supported operations table (create xlsx, edit xlsx, analyze xlsx, CSV/TSV operations)
- [ ] Implement 6-stage execution flow:
  - Stage 1: Parse delegation context (source_path, output_path, instruction, mode)
  - Stage 2: Validate inputs (file exists for edit/analyze, extension check)
  - Stage 3: Detect available tools (openpyxl, pandas) via tool-detection.md
  - Stage 4: Execute operation with full openpyxl workflow:
    - Creation: Workbook setup, headers, data, formulas, color coding (INPUT_FILL blue, FORMULA_FONT black, HEADER_FILL dark, SUBTOTAL_FILL light), number formatting (`$#,##0`, `0%`), multi-sheet
    - Editing: Load existing workbook preserving formulas/styles, modify cells/sheets
    - Analysis: pandas DataFrame loading, summarization, pattern detection
  - Stage 5: Validate output (file exists, non-empty, formula verification via read-back)
  - Stage 6: Return structured JSON
- [ ] Add formula error prevention section (always use formulas not computed values, verify cell references, test with read-back)
- [ ] Add error handling section (missing dependencies, validation failures, write errors)
- [ ] Add critical requirements (MUST DO / MUST NOT lists)

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `.claude/agents/xlsx-agent.md` - Create new file (~350 lines)

**Verification**:
- File exists at `.claude/agents/xlsx-agent.md`
- Frontmatter has no `model:` or `mcp-servers:` fields
- All three modes (create, edit, analyze) are documented
- Color coding standards match budget-agent patterns
- Formula verification workflow is included

---

### Phase 3: Create /xlsx command and update /edit command [COMPLETED]

**Goal**: Create a standalone `/xlsx` command and update the `/edit` command xlsx stub to route to skill-xlsx

**Tasks**:
- [ ] Create `.claude/commands/xlsx.md` following the table.md command pattern:
  - Frontmatter with `allowed-tools: Skill, Bash(...)` and argument-hint
  - Usage examples for create, edit, and analyze modes
  - CHECKPOINT 1: GATE IN with session ID generation, argument parsing, file validation
  - STAGE 2: Delegate to skill-xlsx via Skill tool
  - CHECKPOINT 2: GATE OUT with status check and git commit
- [ ] Update `.claude/commands/edit.md` xlsx case:
  - Replace error block with `target_skill="skill-xlsx"` assignment
  - Update supported operations table to mark XLSX as "Available"
  - Update the unsupported type fallback message

**Timing**: 20 minutes

**Depends on**: 1

**Files to modify**:
- `.claude/commands/xlsx.md` - Create new file (~120 lines)
- `.claude/commands/edit.md` - Update xlsx stub (3 locations: case block, operations table, usage comment)

**Verification**:
- `/xlsx` command file exists with proper frontmatter
- `/edit` command routes `.xlsx` to `skill-xlsx` instead of erroring
- Operations table shows XLSX as "Available"

---

### Phase 4: Update extension registration [COMPLETED]

**Goal**: Register xlsx-agent and skill-xlsx in the filetypes extension manifest, documentation, and context index

**Tasks**:
- [ ] Update `/home/benjamin/.config/nvim/.claude/extensions/filetypes/manifest.json`:
  - Add `"xlsx-agent.md"` to `provides.agents` array
  - Add `"skill-xlsx"` to `provides.skills` array
  - Add `"xlsx.md"` to `provides.commands` array
  - Add `"filetypes:xlsx": "skill-xlsx"` to `routing.research` and `routing.implement`
  - Add `"filetypes:xlsx": "skill-planner"` to `routing.plan`
- [ ] Update `/home/benjamin/.config/nvim/.claude/extensions/filetypes/EXTENSION.md`:
  - Add `| skill-xlsx | xlsx-agent | XLSX creation, editing, and analysis (openpyxl) |` to Skill-Agent Mapping table
  - Add `/xlsx` to Commands table
  - Update `/edit` description to include xlsx
- [ ] Update `/home/benjamin/.config/nvim/.claude/extensions/filetypes/index-entries.json`:
  - Add `"xlsx-agent"` to agents arrays in tool-detection.md and dependency-guide.md entries
  - Add `"/xlsx"` to commands arrays in tool-detection.md and dependency-guide.md entries

**Timing**: 25 minutes

**Depends on**: 1, 2

**Files to modify**:
- `/home/benjamin/.config/nvim/.claude/extensions/filetypes/manifest.json` - Add agent, skill, command, routing entries
- `/home/benjamin/.config/nvim/.claude/extensions/filetypes/EXTENSION.md` - Add skill-agent row and command row
- `/home/benjamin/.config/nvim/.claude/extensions/filetypes/index-entries.json` - Add xlsx-agent to agent arrays and /xlsx to command arrays

**Verification**:
- `jq '.provides.agents' manifest.json` includes `xlsx-agent.md`
- `jq '.provides.skills' manifest.json` includes `skill-xlsx`
- `jq '.routing.research["filetypes:xlsx"]' manifest.json` returns `skill-xlsx`
- EXTENSION.md contains skill-xlsx row
- index-entries.json references xlsx-agent in tool-detection.md and dependency-guide.md entries

## Testing & Validation

- [ ] Verify skill file structure matches skill-docx-edit pattern (frontmatter, sections, Task tool delegation)
- [ ] Verify agent file structure matches filetypes-spreadsheet-agent pattern (frontmatter, 6-stage flow, JSON return)
- [ ] Verify `/edit` command routes `.xlsx` to `skill-xlsx` (no longer errors)
- [ ] Verify `/xlsx` command exists and delegates to `skill-xlsx`
- [ ] Verify manifest.json is valid JSON after edits
- [ ] Verify index-entries.json is valid JSON after edits
- [ ] Verify EXTENSION.md table formatting is consistent
- [ ] Verify no references to nonexistent recalc.py remain

## Artifacts & Outputs

- `.claude/skills/skill-xlsx/SKILL.md` - Thin-wrapper skill for xlsx routing
- `.claude/agents/xlsx-agent.md` - Implementation agent with openpyxl workflow
- `.claude/commands/xlsx.md` - Standalone /xlsx command
- `.claude/commands/edit.md` - Updated xlsx routing (modified)
- Extension registration files (modified): manifest.json, EXTENSION.md, index-entries.json

## Rollback/Contingency

- Delete `.claude/skills/skill-xlsx/` directory
- Delete `.claude/agents/xlsx-agent.md`
- Delete `.claude/commands/xlsx.md`
- Revert `.claude/commands/edit.md` xlsx case to error stub
- Revert manifest.json, EXTENSION.md, index-entries.json to pre-change state
- All changes are additive; existing functionality is unaffected by rollback
