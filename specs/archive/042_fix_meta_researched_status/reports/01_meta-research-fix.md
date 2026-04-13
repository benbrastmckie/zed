# Research Report: Task #42

**Task**: 42 - Fix /meta creating tasks at RESEARCHED status without research artifacts
**Generated**: 2026-04-12T00:00:00Z
**Effort**: 2 hours
**Dependencies**: None
**Sources/Inputs**: Codebase analysis of .claude/ agent system files
**Artifacts**: specs/042_fix_meta_researched_status/reports/01_meta-research-fix.md
**Standards**: report-format.md

---

## Executive Summary

- The meta-builder-agent defines a Stage 5.5 (GenerateResearchArtifacts) that creates `01_meta-research.md` files, but the LLM agent skips this step at runtime, leaving tasks at RESEARCHED with no actual reports.
- Five files need changes: meta-builder-agent.md, skill-meta SKILL.md, multi-task-creation-standard.md, and two sections within meta-builder-agent.md (Interview Stage 6 and outer Stage 6).
- The fix aligns /meta with the /slides pattern: create tasks at NOT STARTED, let users run the normal `/research -> /plan -> /implement` lifecycle.

## Context and Scope

The `/meta` command runs an interactive interview to gather requirements, then creates tasks. The current design attempts to generate "lightweight research reports" from interview context (Stage 5.5) so tasks can skip the `/research` step. In practice, the LLM agent consistently skips Stage 5.5, jumping from user confirmation (Stage 5) directly to task creation (Stage 6). No enforcement mechanism catches the missing files.

The `/slides` command faces a similar situation -- it gathers forcing_data via pre-task questions -- but correctly creates tasks at `[NOT STARTED]` status with `"status": "not_started"` in state.json. The forcing_data is stored as task metadata, not as a fake research artifact.

## Findings

### File 1: `.claude/agents/meta-builder-agent.md`

**Current state**: Contains six sections that need changes.

#### Change 1: Remove Stage 5.5 entirely (lines 592-691)

Line 592 dispatches to Stage 5.5:
```
**If user selects "Yes"**: Proceed to Stage 5.5 (Research Artifact Generation).
```

Lines 594-691 define the entire `### Interview Stage 5.5: GenerateResearchArtifacts` section including the report template, artifact tracking, and "Proceed to Stage 6" instructions.

**Action**: Delete lines 594-691 (the entire Stage 5.5 section). Change line 592 to proceed directly to Stage 6:
```
**If user selects "Yes"**: Proceed to Stage 6 (CreateTasks).
```

#### Change 2: Interview Stage 6 state.json entry (lines 774-790)

Current state.json template:
```json
{
  "project_number": 36,
  "project_name": "task_slug",
  "status": "researched",
  "task_type": "meta",
  "dependencies": [35, 34],
  "artifacts": [
    {
      "type": "research",
      "path": "specs/036_task_slug/reports/01_meta-research.md",
      "summary": "Auto-generated research from /meta interview"
    }
  ]
}
```

**Action**: Change `"status": "researched"` to `"status": "not_started"`. Remove the entire `"artifacts"` array. Remove the note on line 792 about RESEARCHED status.

#### Change 3: Interview Stage 6 TODO.md entry format (lines 794-840)

Current template uses `[RESEARCHED]` and includes a `- **Research**: [01_meta-research.md](...)` line.

**Action**: Change `[RESEARCHED]` to `[NOT STARTED]`. Remove the `- **Research**:` line. Update the Python code block (lines 827-842) to remove `research_path` variable and `- **Research**:` line from the format string. Remove "with RESEARCHED status and research link" comment on line 827.

#### Change 4: Outer Stage 5 return JSON (lines 1373-1396)

The interactive mode return shows:
```json
"next_steps": "Run /research 430 to begin research on first task"
```

This is already correct for NOT STARTED status. No change needed here.

#### Change 5: Outer Stage 6 (lines 1447-1459)

Line 1453 says:
```
Format each task entry using the TODO.md Entry Format (see Stage 6 CreateTasks)
```

This references the Stage 6 CreateTasks format, which will be updated by Changes 2-3. No additional change needed here -- it inherits the fix.

#### Change 6: Line 689 reference to status (within Stage 5.5, removed by Change 1)

This line (`status = "researched"` for all tasks) is removed as part of the Stage 5.5 deletion.

### File 2: `.claude/skills/skill-meta/SKILL.md`

**Current state** (lines 126-167): The "Expected Return: Interactive Mode" example shows:

1. `"summary"` mentions "Tasks start in RESEARCHED status" (line 132)
2. `"artifacts"` array includes research report entries (lines 137-151)
3. `"tasks_status": "researched"` in metadata (line 160)
4. `"next_steps"` says "research already complete" (line 163)
5. A note block on line 166 explains RESEARCHED status rationale

**Action**: Update all five items:
1. Change summary to mention NOT STARTED status
2. Remove research artifact entries from artifacts array (keep only task directory entries)
3. Change `"tasks_status": "researched"` to `"tasks_status": "not_started"`
4. Change next_steps to `"Run /research 430 to begin research on first task"`
5. Replace the note block with one explaining tasks start at NOT STARTED for normal lifecycle

### File 3: `.claude/docs/reference/standards/multi-task-creation-standard.md`

**Current state**: Three sections reference Stage 5.5 / GenerateResearchArtifacts.

#### Change A: Reference Implementation table (lines 359-379)

Line 373:
```
| **Research Generation** | **Interview Stage 5.5 (GenerateResearchArtifacts)** |
```

Line 374 (State Updates row):
```
| State Updates | Interview Stage 6 (batch insertion with RESEARCHED status) |
```

**Action**: Remove the Research Generation row entirely. Change State Updates description to "Interview Stage 6 (batch insertion with NOT STARTED status)".

#### Change B: Enhanced Stages description (lines 376-378)

```
- **Stage 5.5 (GenerateResearchArtifacts)**: Creates `01_meta-research.md` from interview context for each task
```

**Action**: Remove this bullet entirely.

#### Change C: Current Compliance Status table (lines 384-391)

The table has a "Research Gen" column with "Yes" for /meta. Also lines 394-397 have "Enhanced /meta Features" that reference Stage 5.5.

**Action**: Remove the "Research Gen" column from the table. Remove the three enhanced feature bullets (lines 394-397) or replace them with just the Topic Clustering bullet.

## Decisions

1. **Remove Stage 5.5 entirely** rather than fixing it -- the interview context is pre-task metadata, not research. Attempting to make it work would add complexity for minimal benefit since the interview does not perform actual codebase exploration or web research.

2. **Use NOT STARTED status** for /meta-created tasks, consistent with /slides. The normal `/research -> /plan -> /implement` lifecycle is the proper path.

3. **Do not store interview context as forcing_data** (unlike /slides) -- the task description already captures the interview output. This keeps the change minimal.

## Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Users accustomed to running `/plan N` directly after `/meta` will get a status error | Medium | The next_steps output already says "Run /research N". Clear messaging in the return. |
| Existing tasks in state.json with `"status": "researched"` but no artifacts | Low | These are already broken. Running `/research N` on them will work regardless of current status. |
| Interview context is lost when Stage 5.5 is removed | Low | Interview context is already captured in the task description field. Users can pass focus prompts to `/research N "focus"` for targeted investigation. |
| meta-builder-agent.md is large and changes span multiple sections | Medium | Each change is isolated and can be verified independently. The Stage 5.5 removal is a clean block deletion. |

## Appendix

### Files to Change (Summary)

| File | Lines | Change |
|------|-------|--------|
| `.claude/agents/meta-builder-agent.md` | 592 | "Yes" -> Stage 6 (not 5.5) |
| `.claude/agents/meta-builder-agent.md` | 594-691 | Delete entire Stage 5.5 |
| `.claude/agents/meta-builder-agent.md` | 779 | `"researched"` -> `"not_started"` |
| `.claude/agents/meta-builder-agent.md` | 782-789 | Remove `"artifacts"` array |
| `.claude/agents/meta-builder-agent.md` | 792 | Remove RESEARCHED status note |
| `.claude/agents/meta-builder-agent.md` | 798 | `[RESEARCHED]` -> `[NOT STARTED]` |
| `.claude/agents/meta-builder-agent.md` | 801 | Remove `- **Research**:` line |
| `.claude/agents/meta-builder-agent.md` | 827-836 | Update Python template (remove research_path, change status) |
| `.claude/skills/skill-meta/SKILL.md` | 132 | Update summary text |
| `.claude/skills/skill-meta/SKILL.md` | 137-151 | Remove research artifact entries |
| `.claude/skills/skill-meta/SKILL.md` | 160 | `"researched"` -> `"not_started"` |
| `.claude/skills/skill-meta/SKILL.md` | 163 | Update next_steps |
| `.claude/skills/skill-meta/SKILL.md` | 166-167 | Replace RESEARCHED note |
| `.claude/docs/reference/standards/multi-task-creation-standard.md` | 373 | Remove Research Generation row |
| `.claude/docs/reference/standards/multi-task-creation-standard.md` | 374 | Update State Updates description |
| `.claude/docs/reference/standards/multi-task-creation-standard.md` | 378 | Remove Stage 5.5 bullet |
| `.claude/docs/reference/standards/multi-task-creation-standard.md` | 384-397 | Remove Research Gen column and enhanced features |

### Comparison: /slides vs /meta Task Creation

| Aspect | /slides (current, correct) | /meta (current, broken) | /meta (proposed) |
|--------|---------------------------|------------------------|------------------|
| Pre-task data | forcing_data in state.json | Interview context in description | Interview context in description |
| Initial status | `not_started` | `researched` | `not_started` |
| Research artifacts | None at creation | Specified but not created | None at creation |
| Next step | `/slides N` (runs research) | `/plan N` (skips research) | `/research N` |
| TODO.md status | `[NOT STARTED]` | `[RESEARCHED]` | `[NOT STARTED]` |
