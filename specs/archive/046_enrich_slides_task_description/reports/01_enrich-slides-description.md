# Research Report: Task #46

**Task**: 46 - Enrich /slides task description with source material paths and forcing data
**Started**: 2026-04-13T01:00:00Z
**Completed**: 2026-04-13T01:15:00Z
**Effort**: 1 hour estimated
**Dependencies**: None
**Sources/Inputs**:
- `.claude/commands/slides.md` (primary target file)
- `specs/state.json` (task 45 and task 29 entries)
- `specs/TODO.md` (task 45 and task 29 descriptions)
- `.claude/commands/grant.md` (comparison with sibling command)
**Artifacts**:
- `specs/046_enrich_slides_task_description/reports/01_enrich-slides-description.md`
**Standards**: report-format.md, artifact-management.md

## Executive Summary

- The `/slides` command stores forcing data (output_format, talk_type, source_materials, audience_context) in `state.json` but uses only the raw user-supplied `$desc` string for the `description` field and TODO.md entry.
- Task 45 (HIV Grand Rounds) demonstrates the problem: the file paths (`HIV_Grand_Rounds.md`, `UCSF_ZSFG_Template_16x9.pptx`) appear only in `forcing_data.source_materials` but not in the description or TODO.md.
- Task 29 (epi-study walkthrough) has a richer description because the user manually provided detailed text at creation time -- not because the command enriched it.
- The fix is localized to slides.md Stage 1 Steps 2-4: after forcing questions complete, construct an enriched description string that incorporates key forcing data fields before writing to state.json and TODO.md.
- The same pattern (description = raw `$desc` only) exists in `/grant`, `/budget`, `/funds`, and `/timeline`, but the task scope is limited to `/slides`.

## Context & Scope

The `/slides` command has two input modes that create new tasks: "description" (user types a string) and "file_path" (user provides a path). Both run Stage 0 forcing questions then Stage 1 task creation. The problem is that Stage 1 uses `$desc` (the original argument) verbatim for the `description` field, ignoring the rich structured data gathered during Stage 0.

This research examines the current code flow, compares two concrete task examples (45 and 29), and identifies the specific edits needed.

## Findings

### 1. Current Description Construction (slides.md Stage 1)

**Step 2** creates a slug from the description -- straightforward, no issues.

**Step 3** (state.json update) uses `--arg desc "$description"` and stores `"description": $desc`. The `$description` variable is set at Step 2 of CHECKPOINT 1 (GATE IN):
- For `input_type="description"`: `description="$ARGUMENTS"` (the raw user string)
- For `input_type="file_path"`: not explicitly set -- the file is read as source material but no description is constructed from it

The forcing_data object is stored alongside the description but the two are never merged.

**Step 4** (TODO.md update) writes:
```markdown
**Description**: {description}
```
This uses the same raw `$desc` value.

### 2. What Information Is Available at Task Creation

After Stage 0 completes, the following structured data exists:

| Field | Source | Example (Task 45) |
|-------|--------|--------------------|
| `forcing_data.output_format` | Step 0.0 | `"pptx"` |
| `forcing_data.talk_type` | Step 0.1 | `"CONFERENCE"` |
| `forcing_data.source_materials` | Step 0.2 | `["/path/to/HIV_Grand_Rounds.md", "/path/to/UCSF_ZSFG_Template_16x9.pptx"]` |
| `forcing_data.audience_context` | Step 0.3 | Long string about audience, time, emphasis |
| `file_path` (for file input) | GATE IN Step 2 | `/path/to/HIV_Grand_Rounds.md` |
| `$description` or `$ARGUMENTS` | User input | The original argument text |

For the "file_path" input type, there is no explicit `$description` -- the user provides a path, not a description string. The description must be constructed entirely from forcing data and file content.

### 3. Task 45 Analysis (The Problem Case)

**state.json `description` field**:
```
"HIV Grand Rounds: MXM LA-ART & LA-PrEP presentation for UCSF/ZSFG (~22-23 slides, ~20-25 min).
Four patient cases with Poll Everywhere interaction, program outcome data (n=34 LA-ART, n=52
LA-PrEP), and discussion of LEN+CAB/RPV as population-level harm reduction strategy."
```

**state.json `forcing_data.source_materials`**:
```json
[
  "/home/benjamin/.config/zed/examples/test-files/HIV_Grand_Rounds.md",
  "/home/benjamin/.config/zed/examples/test-files/UCSF_ZSFG_Template_16x9.pptx"
]
```

**TODO.md description**:
```
HIV Grand Rounds presentation for UCSF/ZSFG (~22-23 slides, ~20-25 min, PPTX). Four patient
cases with Poll Everywhere interaction, program outcome data (n=34 LA-ART, n=52 LA-PrEP),
oral vs LA-ART comparison, and discussion of LEN+CAB/RPV as population-level harm reduction
strategy. Uses UCSF/ZSFG 16x9 template.
```

**What is missing from description**: The file paths to `HIV_Grand_Rounds.md` and `UCSF_ZSFG_Template_16x9.pptx` appear only in forcing_data. When a researcher or planner reads the description, they have no visibility into what source files exist unless they separately inspect `forcing_data.source_materials` in state.json.

**What the TODO.md did include (manually?)**: The TODO.md entry actually contains some enrichment (`PPTX`, `Uses UCSF/ZSFG 16x9 template`) that does not appear in the state.json description. This suggests the command or the user manually added detail to TODO.md but did not update state.json -- or the command partially enriched the TODO.md entry. Either way, the enrichment is incomplete and inconsistent.

### 4. Task 29 Analysis (The Comparison Case)

**state.json `description` field**:
```
"Conference talk walking through the zed/examples/epi-study synthetic RCT demo (KAT vs TAU,
adjusted OR 3.29) as an end-to-end showcase of the /epi Claude Code workflow for a mixed
clinical/informatics audience"
```

**state.json `forcing_data.source_materials`**:
```json
[
  "/home/benjamin/.config/zed/examples/epi-study/ (systematic review of entire directory:
  README.md, EPI_ANSWERS.md, scripts/, data/, reports/consort_report.md, reports/tables/*, logs/)"
]
```

**TODO.md description** (enriched -- likely by the command or user):
```
Conference talk (15-20 min) walking through `zed/examples/epi-study/` — the synthetic RCT demo
(ketamine-assisted therapy vs TAU for methamphetamine use disorder, N=200, adjusted OR=3.29) —
as an end-to-end showcase of the /epi Claude Code workflow for a mixed clinical/informatics
audience. Balance tooling narrative, CONSORT/methods rigor, and the headline finding; emphasize
reproducibility (deterministic seeds, base-R fallbacks).
```

Task 29's description is richer because the user provided a detailed description string up front. But even here, the source directory path (`examples/epi-study/`) appears in forcing_data but not in the state.json description field. The TODO.md description does mention it, suggesting manual enrichment occurred.

### 5. Required Edits to slides.md

The changes target **Stage 1, between Steps 2 and 3** -- after forcing data is gathered and before writing to state.json/TODO.md. A new step should construct an enriched description.

#### Edit Location: Stage 1, New Step 2.5 (Enrich Description)

After creating the slug (Step 2) but before updating state.json (Step 3), add a description enrichment step:

```
### Step 2.5: Enrich Description

Construct an enriched description that incorporates forcing data:

1. Start with the base description:
   - If input_type="description": use the user's original text
   - If input_type="file_path": synthesize a brief description from the file content and audience_context

2. Append structured details:
   - Talk type and output format: "({talk_type} talk, {output_format} format)"
   - Duration from talk type: "(15-20 min)" for CONFERENCE, etc.
   - Source materials with file paths:
     "Source materials: {path_1}, {path_2}"
   - Audience context summary (first sentence or key phrase)

3. The enriched description replaces $desc for both state.json and TODO.md.
```

#### Specific Format for the Enriched Description

The enriched description should follow this template:

```
{base_description}. {talk_type} talk ({duration}), {output_format} output.
Source: {source_material_paths}. Audience: {audience_summary}.
```

Example for task 45:
```
HIV Grand Rounds: MXM LA-ART & LA-PrEP presentation for UCSF/ZSFG (~22-23 slides, ~20-25 min).
Four patient cases with Poll Everywhere interaction, program outcome data. CONFERENCE talk
(15-20 min), pptx output. Source: examples/test-files/HIV_Grand_Rounds.md,
examples/test-files/UCSF_ZSFG_Template_16x9.pptx. Audience: ID faculty + HIV clinic community
members/staff at UCSF/ZSFG.
```

#### Edit to Step 3 (state.json)

Change `--arg desc "$description"` to `--arg desc "$enriched_description"` so the enriched version is stored.

#### Edit to Step 4 (TODO.md)

The `**Description**:` block should use the enriched description. No structural change needed -- just ensure the same enriched string is used.

#### Edit to Step 3 for file_path Input

When `input_type="file_path"`, the current command reads the file but does not set `$description`. The enrichment step should construct a description from:
- The file's title or first heading
- The audience_context response
- The talk_type and output_format

### 6. TODO.md Description Format

The current TODO.md format is:
```markdown
### {N}. {Title}
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Task Type**: present

**Description**: {description}
```

The enriched description should fit naturally within this single `**Description**:` block. No structural change to the TODO.md format is needed -- the enrichment happens at the content level, not the template level.

However, for readability, source file paths should use relative paths where possible (relative to the repository root) rather than absolute paths. The enrichment step should strip the repository root prefix from absolute paths.

## Decisions

1. **Enrichment happens at description construction time**, not at display time. The enriched string is stored in state.json and TODO.md identically.
2. **The enriched description replaces the raw description** -- there is no separate "raw" vs "enriched" field. The forcing_data still stores the structured originals.
3. **Relative paths preferred**: Strip the repository root from file paths for readability. Example: `examples/test-files/HIV_Grand_Rounds.md` instead of `/home/benjamin/.config/zed/examples/test-files/HIV_Grand_Rounds.md`.
4. **Audience context is summarized**, not included verbatim. Extract the first sentence or key descriptor (e.g., "ID faculty + HIV clinic community members/staff at UCSF/ZSFG") rather than the full multi-line response.
5. **Scope limited to /slides**: Though `/grant`, `/budget`, etc. have the same pattern, this task only modifies `/slides`.

## Recommendations

1. **Add Step 2.5 to Stage 1** in `.claude/commands/slides.md` that constructs an enriched description from base description + forcing_data fields.
2. **Update Step 3 and Step 4** to use the enriched description variable instead of raw `$desc`.
3. **Handle file_path input** by constructing a description from file content + forcing data when no user-supplied description exists.
4. **Use path relativization** -- detect and strip the git repository root from absolute paths before embedding in the description.
5. **Keep the enrichment concise** -- the description should remain a single readable paragraph, not a structured data dump. Target 2-4 sentences.

## Risks & Mitigations

- **Risk**: Enriched descriptions could become very long if audience_context is verbose.
  **Mitigation**: Summarize audience_context to first sentence or ~20 words.

- **Risk**: Path relativization could fail for paths outside the repository.
  **Mitigation**: Fall back to the basename if the path is not under the repo root.

- **Risk**: Backward incompatibility with existing tasks that have raw descriptions.
  **Mitigation**: None needed -- existing tasks are unaffected. Only new task creation is changed.

## Appendix

### Files to Modify

1. `.claude/commands/slides.md` -- Stage 1: Add Step 2.5, update Steps 3 and 4

### Key Code Locations

- **slides.md line 197-217**: Stage 1 Steps 1-4 (state.json and TODO.md update)
- **slides.md line 148-163**: GATE IN Step 2 (input type detection, where `$description` is set)
- **slides.md line 112-124**: Stage 0 Step 0.4 (forcing data object structure)

### Comparison: Task 45 vs Task 29

| Aspect | Task 45 | Task 29 |
|--------|---------|---------|
| Input type | file_path | description |
| state.json description includes file paths | No | No |
| TODO.md description includes file paths | Partially (template mention) | Yes (directory path) |
| forcing_data.source_materials | 2 files | 1 directory |
| output_format | pptx | (not set, pre-format-selection) |
| talk_type | CONFERENCE | CONFERENCE |
