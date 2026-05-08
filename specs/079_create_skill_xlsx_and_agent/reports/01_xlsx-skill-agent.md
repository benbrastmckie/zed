# Research Report: Task #79

**Task**: 79 - Create skill-xlsx and xlsx-agent
**Started**: 2026-05-08T12:00:00Z
**Completed**: 2026-05-08T12:15:00Z
**Effort**: Small (2 files to create following established patterns)
**Dependencies**: None (filetypes extension already loaded)
**Sources/Inputs**:
- Codebase: existing filetypes skills (skill-scrape, skill-docx-edit, skill-filetypes-spreadsheet, skill-presentation, skill-filetypes)
- Codebase: existing filetypes agents (scrape-agent, docx-edit-agent, filetypes-spreadsheet-agent, document-agent, filetypes-router-agent)
- Codebase: budget-agent (xlsx generation patterns with openpyxl)
- Codebase: extension manifest, EXTENSION.md, index-entries.json
- Codebase: context files (tool-detection.md, dependency-guide.md, subagent-return.md)
- Codebase: /edit command (existing xlsx stub)
**Artifacts**:
- `specs/079_create_skill_xlsx_and_agent/reports/01_xlsx-skill-agent.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The filetypes extension uses a consistent thin-wrapper skill + agent delegation pattern across all five existing skill/agent pairs
- Skill SKILL.md files follow a rigid structure: frontmatter (name, description, allowed-tools: Task), context pointers, trigger conditions, execution (validate -> context prep -> invoke agent via Task tool -> return validation -> propagation), error handling
- Agent .md files follow a rigid structure: frontmatter (name, description), overview, metadata, allowed-tools list, context references, execution flow (parse -> validate -> detect tools -> execute -> validate output -> return JSON), error handling, critical requirements
- The budget-agent contains the authoritative xlsx creation workflow using openpyxl (formulas, formatting, color coding, recalc patterns) that should be adapted for the general xlsx-agent
- The /edit command already has an explicit stub for .xlsx routing that returns "skill-xlsx-edit has not been implemented" -- this needs to be updated to route to the new skill-xlsx
- Registration requires updates to: manifest.json, EXTENSION.md, index-entries.json, and the /edit command

## Context & Scope

This research examines the existing filetypes extension patterns to document exactly how `skill-xlsx` and `xlsx-agent` should be created. The goal is to understand:
1. The exact thin-wrapper skill SKILL.md structure
2. The exact agent .md structure
3. The xlsx-specific workflow content from budget-agent
4. All registration/integration points that need updating

## Findings

### 1. Thin-Wrapper Skill Pattern (SKILL.md)

All filetypes skills share an identical structure. Here is the canonical pattern derived from the five existing skills:

**Frontmatter** (3 fields, always the same pattern):
```yaml
---
name: skill-{name}
description: {one-line description}
allowed-tools: Task
---
```

**Sections in order**:
1. **Title** - `# {Name} Skill` with one-line summary: "Thin wrapper that routes ... to the `{agent-name}`"
2. **Context Pointers** - Always references `subagent-return.md` with "do not load eagerly" note
3. **Trigger Conditions** - Three subsections:
   - Direct Invocation (command name and conversational triggers)
   - Implicit Invocation (plan step language patterns, file extension detection, task description keywords)
   - When NOT to Trigger (exclusions)
4. **Execution** - Five numbered steps:
   - 1. Input Validation (bash code)
   - 2. Context Preparation (JSON delegation context)
   - 3. Invoke Agent (CRITICAL: use Task tool, NOT Skill tool)
   - 4. Return Validation (status values, summary length, artifacts, metadata)
   - 5. Return Propagation
5. **Return Format** - Expected JSON with status/summary/artifacts/metadata/next_steps
6. **Error Handling** - Input validation, unsupported format, agent errors, tool not available
7. **MUST NOT** section (optional, present in scrape and docx-edit)

**Key files examined**:
- `/home/benjamin/.config/zed/.claude/skills/skill-scrape/SKILL.md` (189 lines)
- `/home/benjamin/.config/zed/.claude/skills/skill-docx-edit/SKILL.md` (211 lines)
- `/home/benjamin/.config/zed/.claude/skills/skill-presentation/SKILL.md` (188 lines)
- `/home/benjamin/.config/zed/.claude/skills/skill-filetypes-spreadsheet/SKILL.md` (186 lines)
- `/home/benjamin/.config/zed/.claude/skills/skill-filetypes/SKILL.md` (189 lines)

### 2. Agent Pattern (.md)

All filetypes agents share an identical structure. Here is the canonical pattern:

**Frontmatter** (2 fields):
```yaml
---
name: {agent-name}
description: {one-line description}
---
```

Note: filetypes agents do NOT include `model:` or `mcp-servers:` frontmatter (unlike budget-agent which has `model: opus` and `mcp-servers: []`). The xlsx-agent should follow the simpler filetypes agent pattern.

**Sections in order**:
1. **Title** - `# {Agent Name}`
2. **Overview** - Multi-sentence description of what the agent does
3. **Agent Metadata** - Bullet list: Name, Purpose, Invoked By, Return Format
4. **Allowed Tools** - Grouped into File Operations and Execution Tools
5. **Context References** - `@`-references with Always Load and conditional Load When sections
6. **Supported Operations** - Table of capabilities (conversions, extraction types, etc.)
7. **Execution Flow** - Staged pipeline:
   - Stage 1: Parse Delegation Context (JSON input schema)
   - Stage 2: Validate Inputs (bash checks)
   - Stage 3: Detect Available Tools (referencing tool-detection.md)
   - Stage 4: Execute (the actual work with code examples)
   - Stage 5: Validate Output (verify files exist and are non-empty)
   - Stage 6: Return Structured JSON
8. **Error Handling** - Missing dependencies, validation failures, etc.
9. **Critical Requirements** - MUST DO and MUST NOT lists

**Key agent files examined**:
- `/home/benjamin/.config/zed/.claude/agents/filetypes-spreadsheet-agent.md` (289 lines)
- `/home/benjamin/.config/zed/.claude/agents/scrape-agent.md` (14,139 bytes)
- `/home/benjamin/.config/zed/.claude/agents/document-agent.md` (12,783 bytes)
- `/home/benjamin/.config/zed/.claude/agents/docx-edit-agent.md` (14,713 bytes)
- `/home/benjamin/.config/zed/.claude/agents/filetypes-router-agent.md` (239 lines)

**Allowed Tools** pattern for filetypes agents (common subset):
- File Operations: Read, Write, Edit, Glob, Grep (some agents omit Edit/Grep)
- Execution Tools: Bash
- The filetypes-router-agent additionally has Task (for sub-delegation)

### 3. Budget Agent XLSX Patterns (to adapt for xlsx-agent)

The budget-agent at `/home/benjamin/.config/zed/.claude/agents/budget-agent.md` (21,829 bytes) contains the authoritative xlsx creation workflow. Key patterns to extract for the general xlsx-agent:

**Python/openpyxl workflow**:
```python
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side, numbers
from openpyxl.utils import get_column_letter
```

**Color coding standards**:
- `INPUT_FILL = PatternFill(start_color='DCE6F1', ...)` -- blue background for user-editable cells
- `INPUT_FONT = Font(color='0000FF')` -- blue font for input values
- `FORMULA_FONT = Font(color='000000')` -- black font for computed values
- `HEADER_FILL = PatternFill(start_color='0A2540', ...)` -- dark header with white text
- `SUBTOTAL_FILL = PatternFill(start_color='E8EEF5', ...)` -- light fill for subtotal rows
- `CATEGORY_FONT = Font(bold=True, size=11)` -- bold for category headers

**Formula patterns**:
- Salary with NIH cap: `=MIN(D{row}, 221900) * C{row} * (1.03)^{year-1}`
- Category subtotal: `=SUM({col}{start}:{col}{end})`
- Row total: `=SUM(E{row}:I{row})`
- Percentage: `={cell1}*{cell2}`

**Key principles for xlsx generation**:
1. Always generate XLSX with formulas, not hardcoded computed values
2. Use color conventions to distinguish input cells from formula cells
3. Include proper number formatting (`$#,##0`, `0%`, etc.)
4. Create multi-sheet workbooks when appropriate (Detail + Summary)
5. Use `wb.save(output_path)` to write the file

**Formula error prevention** (from budget-agent critical requirements):
- Always use formulas instead of computed values
- Verify formulas reference correct cells
- Test with escalation rates

**Note**: The task description mentions "recalc.py for formula verification" but no recalc.py file was found in the codebase. This appears to be aspirational content from the Anthropic xlsx skill reference rather than existing infrastructure.

### 4. Extension Manifest and Registration

The filetypes extension manifest at `/home/benjamin/.config/nvim/.claude/extensions/filetypes/manifest.json` shows the registration structure:

**provides.agents** array: List of agent .md filenames
**provides.skills** array: List of skill directory names
**provides.commands** array: List of command .md filenames
**routing** object: Maps task_type keys to skills for research/plan/implement phases

For xlsx-agent registration:
- Add `"xlsx-agent.md"` to `provides.agents`
- Add `"skill-xlsx"` to `provides.skills`
- Add routing entries (e.g., `"filetypes:xlsx": "skill-xlsx"` in research and implement)

**EXTENSION.md** needs a new row in the Skill-Agent Mapping table:
```
| skill-xlsx | xlsx-agent | XLSX creation, editing, and analysis (openpyxl) |
```

**index-entries.json** needs xlsx-agent added to the agents arrays in tool-detection.md and dependency-guide.md entries.

### 5. Context Files Referenced

All referenced context files exist and were examined:

- **`subagent-return.md`** at `/home/benjamin/.config/zed/.claude/context/formats/subagent-return.md` -- Return format schema. Agents reference this for JSON return structure. Status values: researched, planned, implemented, synced, linked, committed, tasks_created, partial, failed, blocked. For xlsx operations, appropriate status values would be: `created`, `edited`, `analyzed`, `partial`, `failed`.
- **`tool-detection.md`** at `/home/benjamin/.config/zed/.claude/context/project/filetypes/tools/tool-detection.md` -- Shared tool detection patterns. Already includes openpyxl and pandas detection. The xlsx-agent should reference this.
- **`dependency-guide.md`** at `/home/benjamin/.config/zed/.claude/context/project/filetypes/tools/dependency-guide.md` -- Installation instructions. Already covers openpyxl and pandas.
- **`return-metadata-file.md`** at `/home/benjamin/.config/zed/.claude/context/formats/return-metadata-file.md` -- File-based metadata exchange schema.

### 6. Command Patterns and /edit Integration

The `/edit` command at `/home/benjamin/.config/zed/.claude/commands/edit.md` already has an xlsx stub:

```bash
xlsx)
  echo "Error: XLSX editing is not yet available."
  echo "The openpyxl MCP server is declared but skill-xlsx-edit has not been implemented."
  echo "You can use the openpyxl MCP tools directly in conversation for spreadsheet editing."
  exit 1
  ;;
```

This needs to be updated to route to `skill-xlsx` instead of erroring. The variable `target_skill` should be set to `"skill-xlsx"` for .xlsx files.

Additionally, the task description mentions a standalone `/xlsx` command. Looking at how other commands work (e.g., `/table`, `/scrape`), a new `/xlsx` command file would be created at `.claude/commands/xlsx.md` following the same CHECKPOINT pattern.

### 7. Trigger Conditions for skill-xlsx

Based on the task description and existing patterns, the triggers should be:

**Direct invocation**: `/xlsx` command

**Implicit invocation patterns**:
- "create spreadsheet" / "create xlsx"
- "edit xlsx" / "edit spreadsheet"
- "add formulas" / "add formatting"
- File extensions: `.xlsx`, `.xlsm`, `.csv`, `.tsv`

**When NOT to trigger**:
- Spreadsheet-to-table conversion (use skill-filetypes-spreadsheet)
- Simple CSV reading (use Read tool directly)
- Grant budget creation (use skill-budget)
- PDF/DOCX operations (use other filetypes skills)

### 8. xlsx-agent Scope

Based on the task description and budget-agent patterns, the xlsx-agent should support:

**Creation**: Build new XLSX files from scratch with:
- Headers, data rows, formulas
- Color coding (input vs formula cells)
- Number formatting
- Multi-sheet workbooks

**Editing**: Modify existing XLSX files:
- Read existing workbook with openpyxl
- Modify cell values, formulas, formatting
- Add/remove sheets
- Preserve existing formulas and styles

**Analysis**: Read and analyze XLSX data:
- Use pandas for data analysis
- Summarize contents, identify patterns
- Extract specific sheets/ranges

**Allowed Tools** (from task description):
- Read, Write, Edit, Bash, Glob, Grep

**Context References**:
- `@context/project/filetypes/tools/tool-detection.md`
- `@context/project/filetypes/tools/dependency-guide.md`
- `@.claude/context/formats/subagent-return.md`

## Decisions

- The skill should be named `skill-xlsx` (not `skill-xlsx-edit`) to cover creation, editing, and analysis
- The agent should be named `xlsx-agent` (not `xlsx-edit-agent`) for the same reason
- The agent should NOT include `model:` or `mcp-servers:` frontmatter, following the simpler filetypes agent pattern
- Status values for the return should be: `created` (new file), `edited` (modified file), `analyzed` (read-only), `partial`, `failed`
- The agent should use openpyxl as the primary tool for creation/editing and pandas for analysis
- The `/edit` command xlsx stub should be updated to route to `skill-xlsx`
- A new `/xlsx` command should also be created for direct invocation

## Recommendations

### Implementation Approach

1. **Create `skill-xlsx/SKILL.md`** following the thin-wrapper pattern from skill-docx-edit (closest analog -- same create/edit/analyze scope). Key adaptations:
   - Trigger on `/xlsx` command and xlsx-related language patterns
   - File extensions: `.xlsx`, `.xlsm`, `.csv`, `.tsv`
   - Delegate to `xlsx-agent` via Task tool

2. **Create `xlsx-agent.md`** following the filetypes agent pattern from filetypes-spreadsheet-agent (closest analog -- same file format). Key adaptations:
   - Include full openpyxl workflow from budget-agent (color coding, formula patterns, formatting)
   - Include pandas analysis workflow
   - Support three modes: create, edit, analyze
   - Include formula verification step (generate then read back to verify)

3. **Update `/edit` command** to route `.xlsx` to `skill-xlsx` instead of erroring

4. **Update extension registration** (manifest.json, EXTENSION.md, index-entries.json)

5. **Create `/xlsx` command** following the table.md command pattern

### Files to Create
- `.claude/skills/skill-xlsx/SKILL.md` (~200 lines)
- `.claude/agents/xlsx-agent.md` (~400 lines, due to openpyxl workflow content)

### Files to Modify
- `.claude/commands/edit.md` (update xlsx stub)
- Extension registration files in nvim upstream (manifest.json, EXTENSION.md, index-entries.json)

## Risks & Mitigations

- **Risk**: The openpyxl MCP server is declared in the manifest but may not be needed if direct Python/openpyxl via Bash is used instead. **Mitigation**: The xlsx-agent should use Bash + Python/openpyxl directly (like budget-agent does), not the MCP server. The MCP server can remain declared for potential future use.
- **Risk**: Scope creep -- the xlsx-agent could become as large as budget-agent (700+ lines). **Mitigation**: Keep the agent focused on general xlsx operations. Domain-specific logic (grant budgets, funding landscapes) stays in their respective agents.
- **Risk**: The recalc.py mentioned in the task description does not exist. **Mitigation**: Include a formula verification pattern within the agent itself (write file, read back with openpyxl, verify formula cells are present) rather than relying on an external script.

## Appendix

### Search Queries Used
- `find .claude/skills -name "SKILL.md"` -- discover all skill files
- `find .claude/agents -name "*.md"` -- discover all agent files
- `find .claude/extensions -name "manifest.json"` -- locate extension manifests
- `grep -r "xlsx" .claude/commands/` -- find xlsx references in commands
- `find .claude/context -name "tool-detection.md" -o -name "dependency-guide.md"` -- locate referenced context files

### Key File Paths
- Skills: `/home/benjamin/.config/zed/.claude/skills/skill-*/SKILL.md`
- Agents: `/home/benjamin/.config/zed/.claude/agents/*.md`
- Commands: `/home/benjamin/.config/zed/.claude/commands/*.md`
- Extension manifest: `/home/benjamin/.config/nvim/.claude/extensions/filetypes/manifest.json`
- Context files: `/home/benjamin/.config/zed/.claude/context/project/filetypes/tools/`
