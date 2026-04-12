# Research Report: Slides Format Selection

- **Task**: 37 - slides_format_selection
- **Started**: 2026-04-12T12:00:00Z
- **Completed**: 2026-04-12T12:30:00Z
- **Effort**: 30 minutes
- **Dependencies**: None
- **Sources/Inputs**:
  - `.claude/commands/slides.md` -- Full `/slides` command definition
  - `.claude/skills/skill-slides/SKILL.md` -- Skill wrapper for slides agent
  - `.claude/agents/slides-agent.md` -- Slides research/assembly agent
  - `.claude/commands/budget.md` -- Pattern reference for forcing questions
  - `.claude/commands/funds.md` -- Pattern reference for forcing questions
  - Codebase-wide grep for "Slidev", "pptx", "output_format", "forcing_data"
- **Artifacts**: `specs/037_slides_format_selection/reports/01_format-selection.md`
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Executive Summary

- The `/slides` command has a well-structured Stage 0 with forcing questions (Steps 0.1-0.3) that store data in `forcing_data`. A new Step 0.0 can be inserted before Step 0.1 following the same AskUserQuestion pattern.
- `forcing_data` is stored in state.json under the task's `active_projects` entry and passed through the skill to the agent via delegation context. Adding `output_format` requires no schema changes.
- "Slidev" is referenced in 7 distinct locations across 4 files that need format-aware updates: the command file (slides.md), the CLAUDE.md files, the agent file, and talk library context files.
- Other commands (budget, funds, grant, timeline, epi) all use the same Step 0.N forcing question pattern with AskUserQuestion, confirming the approach is consistent.

## Context & Scope

The task requires inserting a new Step 0.0 in the `/slides` Stage 0 forcing questions that asks the user to choose between Slidev or PowerPoint (PPTX) output format. The choice must be stored as `forcing_data.output_format` and propagated through the skill/agent pipeline. Output messages mentioning Slidev must become format-aware.

## Findings

### 1. Current `/slides` Stage 0 Structure

The command file (`commands/slides.md`) defines Stage 0 with three forcing question steps:

| Step | Question | Stored As |
|------|----------|-----------|
| 0.1 | Talk type (CONFERENCE, SEMINAR, etc.) | `forcing_data.talk_type` |
| 0.2 | Source materials | `forcing_data.source_materials` |
| 0.3 | Audience context | `forcing_data.audience_context` |
| 0.4 | (Store forcing data -- not a question) | JSON assembly |

A new Step 0.0 fits naturally before Step 0.1. The existing steps would be renumbered to 0.1 through 0.4, with the store step becoming 0.5. Alternatively, the new step can be inserted as 0.0 without renumbering (the task description specifies "Step 0.0").

### 2. `forcing_data` Schema and Flow

The forcing_data object is assembled in Step 0.4 (slides.md line 101-109):
```json
{
  "talk_type": "{selected_type}",
  "source_materials": ["{material_1}", "{material_2}"],
  "audience_context": "{audience description}",
  "gathered_at": "{ISO timestamp}"
}
```

This flows through:
1. **Command** (slides.md) -- assembles forcing_data, stores in state.json via jq
2. **Skill** (skill-slides/SKILL.md) -- reads forcing_data from state.json, passes to agent via delegation context (Stage 4, line 175: `"forcing_data": "{from state.json task metadata}"`)
3. **Agent** (slides-agent.md) -- receives forcing_data in delegation context (Stage 1, line 96-110), uses it to select talk pattern and load materials

Adding `output_format` to the forcing_data object requires changes in:
- **slides.md**: Step 0.0 question + Step 0.4 JSON assembly
- **No skill changes needed**: skill-slides passes the entire forcing_data object through
- **slides-agent.md**: Would need to read `forcing_data.output_format` when assembling output (but agent changes are implementation, not research scope)

### 3. Slidev References Requiring Format-Aware Updates

**File: `.claude/commands/slides.md`** (PRIMARY -- all changes here)

| Line | Current Text | Context |
|------|-------------|---------|
| 14 | "synthesis into Slidev-based research talks" | Overview paragraph |
| 246 | "3. /implement {N} - Generate Slidev presentation to talks/{N}_{slug}/" | Stage 1 Step 6 output |
| 431 | "Generate Slidev presentation" | Core Command Integration table |
| 464 | "3. /implement {N} - Generate Slidev presentation" | Output Formats section |

**File: `.claude/CLAUDE.md`** (SECONDARY -- documentation)

| Line | Current Text | Context |
|------|-------------|---------|
| 485 | "Typst and Slidev formats" | Present Extension description |
| 539 | "Slidev-compatible markdown templates" | Talk Library description |

**File: `.claude/agents/slides-agent.md`** (TERTIARY -- agent internals)

The agent references "Slidev" only indirectly through content template descriptions. These templates are inherently Slidev-specific and would need parallel PPTX templates, but that is implementation scope.

**File: `.claude/context/project/present/talk/index.json`** (REFERENCE)
- Line 3: `"description": "Research presentation library for Slidev-based academic talks"`

### 4. Pattern Reference: How Other Commands Handle Format/Mode Selection

All present-extension commands use the same pattern for their first forcing question:

**`/budget` Step 0.1** (budget.md line 53-66):
```
What type of grant budget are you preparing?

A) NIH MODULAR - Under $250K/year direct costs...
B) NIH DETAILED - $250K+/year...
C) NSF - Standard NSF budget format
D) FOUNDATION - Simplified format...
E) SBIR - Small Business Innovation Research

Which format?
```

**`/funds` Step 0.1** (funds.md line 49-58):
```
What type of funding analysis do you need?

- LANDSCAPE: Map funding opportunities...
- PORTFOLIO: Analyze a specific funder...
- JUSTIFY: Verify budget justification...
- GAP: Identify unfunded areas...
```

Both use `AskUserQuestion` with lettered or bulleted options, storing the result in a `forcing_data` field. The `/slides` Step 0.0 should follow this same pattern.

### 5. Default Value Handling

The task specifies "Slidev remains the default if the user doesn't specify." This means:
- The forcing question should indicate the default clearly (e.g., "Slidev (default)")
- If the user skips or provides an ambiguous answer, default to `"slidev"`
- Existing tasks without `output_format` in their forcing_data should be treated as Slidev

### 6. Downstream Impact Assessment

| Component | Impact | Change Required |
|-----------|--------|----------------|
| `slides.md` (command) | HIGH | New Step 0.0, updated forcing_data assembly, conditional output messages |
| `skill-slides/SKILL.md` | NONE | Passes forcing_data as-is |
| `slides-agent.md` | LOW | Should read output_format but research/mapping is format-agnostic |
| CLAUDE.md | LOW | Documentation update for format options |
| Talk library templates | NONE (for now) | Slidev-specific; PPTX templates would be separate future work |
| `skill-planner` | NONE | Reads forcing_data generically |

## Decisions

- **Step 0.0 (not renumbering)**: Insert as Step 0.0 per task description rather than renumbering all existing steps. This preserves existing step references.
- **Two values only**: `slidev` and `pptx` as specified in the task description.
- **Default handling**: Explicit "(default)" marker on Slidev option, with fallback logic in the command.

## Recommendations

### Implementation Plan Outline

**Phase 1: Command File Changes** (slides.md)
1. Add Step 0.0 with AskUserQuestion for format selection
2. Update Step 0.4 (Store Forcing Data) to include `output_format`
3. Make Stage 1 Step 6 output messages conditional on output_format
4. Make Output Formats section messages conditional on output_format
5. Update Overview paragraph to mention both formats

**Phase 2: Documentation Updates** (CLAUDE.md)
1. Update Present Extension description
2. Update Talk Library description

**Phase 3: Agent Awareness** (slides-agent.md)
1. Add output_format to parsed delegation context
2. Note format in research report metadata (informational only -- research is format-agnostic)

### Suggested Step 0.0 Question Text

```
What output format for the presentation?

A) SLIDEV - Web-based slides with Markdown (default)
B) PPTX - PowerPoint presentation file

Format (or press Enter for Slidev):
```

### Conditional Output Message Pattern

```
# In Step 6 output and Output Formats section:
if output_format == "pptx":
  "3. /implement {N} - Generate PowerPoint presentation to talks/{N}_{slug}/"
else:
  "3. /implement {N} - Generate Slidev presentation to talks/{N}_{slug}/"
```

## Risks & Mitigations

- **Risk**: PPTX assembly pipeline does not exist yet. The agent and skill currently only know how to produce Slidev output.
  - **Mitigation**: This task only adds the format selection question and stores the choice. Actual PPTX generation is a separate implementation task. The research and planning phases are format-agnostic.

- **Risk**: Existing tasks in state.json lack `output_format` in their forcing_data.
  - **Mitigation**: All code that reads `output_format` should default to `"slidev"` when the field is missing.

- **Risk**: The CLAUDE.md backup file also contains Slidev references.
  - **Mitigation**: Only update CLAUDE.md (not CLAUDE.md.backup). Backup files are not live configuration.

## Appendix

### Search Queries Used
- `Glob .claude/**/*slides*` -- Found 3 files: commands/slides.md, agents/slides-agent.md, context/filetypes/patterns/presentation-slides.md
- `Grep "Slidev"` in .claude/ -- 40+ matches across commands, agents, context, templates
- `Grep "forcing_data"` in .claude/ -- 21 files using the forcing_data pattern
- `Grep "Step 0.0"` in .claude/commands/ -- No existing Step 0.0 in any command
- `Grep "output_format"` in .claude/ -- Used by filetypes/presentation agents but not slides pipeline
- `Grep "pptx|PowerPoint"` in .claude/ -- Only in filetypes/convert pipeline, not in slides pipeline

### Files to Modify (Implementation)
1. `/home/benjamin/.config/zed/.claude/commands/slides.md` -- Primary changes
2. `/home/benjamin/.config/zed/.claude/CLAUDE.md` -- Documentation updates
3. `/home/benjamin/.config/zed/.claude/agents/slides-agent.md` -- Minor awareness update
