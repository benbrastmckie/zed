# Research Report: Task #71

**Task**: Fix documentation regressions from agent system update
**Date**: 2026-04-16
**Started**: 2026-04-16
**Completed**: 2026-04-16
**Standards**: report-format.md, artifact-formats.md

## Sources/Inputs

- `git diff` of 33 unstaged files (+4830/-3449 lines)
- `.claude/context/formats/return-metadata-file.md`
- `.claude/context/formats/plan-format.md`
- `.claude/skills/skill-memory/SKILL.md`
- `.claude/agents/general-research-agent.md`
- `.claude/agents/general-implementation-agent.md`
- `.claude/agents/planner-agent.md`
- `.claude/CLAUDE.md`

## Executive Summary

The agent system update introduced three categories of documentation regressions: (1) removed JSON examples that agents depend on for output consistency, (2) over-compressed schema documentation that lost structural detail, and (3) a frontmatter template change that broke retrieval tracking field consistency. Six specific fixes are recommended across four files.

## Findings

### Finding 1: return-metadata-file.md lost 5 of 6 concrete JSON examples

**Severity**: Medium
**Files**: `.claude/context/formats/return-metadata-file.md`

The update removed all JSON examples except "Implementation Success (non-meta)":
- Implementation Success (meta task with .claude/ changes) -- removed
- Implementation Success (meta task without .claude/ changes) -- removed
- Implementation Partial -- removed
- Planning Success -- removed
- In Progress (research) -- removed
- In Progress (implementation phase-level) -- removed

These were replaced by a single sentence: "For other scenarios (meta tasks, partial, blocked, planning), combine the schema fields above."

**Impact**: Agents reference this file when writing `.return-meta.json`. Without examples, agents must infer correct field combinations from schema tables alone. The planning example is most critical because the planner agent writes unique fields (`phase_count`, `estimated_hours`, `dependency_waves`) not used by other agents. The partial/error example is second most important because error recovery metadata has conditional fields (`errors` array, `recoverable`, `recommendation`).

**Recommendation**: Restore two examples:
1. **Planning Success** -- covers planner-agent-specific fields
2. **Implementation Partial** -- covers error recovery path with `errors` array

The meta task variants and in-progress variants are genuinely redundant and can stay removed.

### Finding 2: plan-format.md lost dependency_waves structural detail

**Severity**: Medium
**Files**: `.claude/context/formats/plan-format.md`

The `plan_metadata` schema was compressed from a full JSON block + 8 field descriptions to a single paragraph. The compressed version says `dependency_waves` is "array of phase-number arrays for parallel execution groups" -- but the nested array-of-arrays shape (`[[1], [2, 3], [4, 5]]`) is not self-evident from this description.

**Impact**: `dependency_waves` is consumed programmatically by `skill-team-implement` to determine parallel execution groups. An agent might produce `[1, [2, 3]]` or `{"wave_1": [1]}` without seeing the concrete shape. The `reports_integrated` inner object schema is adequately described in the compressed version.

**Recommendation**: Add back just the JSON example block (no field descriptions needed):

```json
{
  "phases": 5,
  "total_effort_hours": 8,
  "complexity": "medium",
  "research_integrated": true,
  "plan_version": 1,
  "dependency_waves": [[1], [2, 3], [4, 5]],
  "reports_integrated": [
    {
      "path": "reports/01_{short-slug}.md",
      "integrated_in_plan_version": 1,
      "integrated_date": "2026-01-05"
    }
  ]
}
```

The one-liner text description can stay as-is alongside it (it provides good terse field-type reference).

### Finding 3: Memory frontmatter template dropped retrieval tracking fields

**Severity**: High
**Files**: `.claude/skills/skill-memory/SKILL.md`

Four fields were removed from the memory frontmatter template in the "Create Memory Files" section:
- `retrieval_count: 0`
- `last_retrieved: null`
- `keywords: {segment.key_terms}`
- `summary: "{one-line summary of content}"`

However, the "JSON Index Maintenance" section in the same file still extracts these fields from frontmatter:

```bash
retrieval_count=$(grep -m1 "^retrieval_count:" "$mem" ...)
last_retrieved=$(grep -m1 "^last_retrieved:" "$mem" ...)
keywords=$(grep -m1 "^keywords:" "$mem" ...)
summary=$(grep -m1 "^summary:" "$mem" ...)
```

**Impact**: New memories created without these fields will have empty values in `memory-index.json`, breaking retrieval scoring (which uses `retrieval_count` and `keywords` for ranking) and display (which uses `summary`).

**Recommendation**: Restore all four fields to the frontmatter template:

```yaml
retrieval_count: 0
last_retrieved: null
keywords: {segment.key_terms}
summary: "{one-line summary of content}"
```

### Finding 4: Dependency Analysis format description over-compressed

**Severity**: Low
**Files**: `.claude/context/formats/plan-format.md`

The bullet list explaining the Dependency Analysis table columns was removed:
- Wave: execution order group
- Phases: phase numbers in this wave (can run in parallel)
- Blocked by: phase numbers that must complete before this wave starts
- Generate the table from per-phase `Depends on` fields
- For fully sequential plans, each wave contains one phase

The replacement sentence is adequate but omits the note about fully sequential plans still being valid, which prevented agents from skipping the wave table when plans have no parallelism.

**Recommendation**: Add one sentence to the compressed description: "For fully sequential plans, each wave contains one phase (still valid and required)."

### Finding 5: memory_health removed from core state.json schema but referenced in extension section

**Severity**: Low (cosmetic inconsistency)
**Files**: `.claude/CLAUDE.md`

The `memory_health` field was correctly removed from the core `state.json` example (since memory is an extension), but the Memory Extension section added below still says "The `memory_health` field in `state.json` tracks vault health metrics." This is architecturally correct (extension adds the field when loaded), but the two sections could confuse agents about whether the field exists.

**Recommendation**: No code change needed. The current structure is correct -- extensions add fields to state.json when loaded. The extension section documents the field it adds. This is informational only.

### Finding 6: plan-format.md Dependency Analysis removed sequential plan note

**Severity**: Low
**Files**: `.claude/context/formats/plan-format.md`

Covered under Finding 4 above. Merged for implementation.

## Recommendations

### Priority 1 (High) -- Restore retrieval tracking fields in memory template
- **File**: `.claude/skills/skill-memory/SKILL.md`
- **Action**: Add `retrieval_count`, `last_retrieved`, `keywords`, `summary` back to frontmatter template
- **Rationale**: Without these, new memories break JSON index generation and retrieval scoring

### Priority 2 (Medium) -- Restore planning and partial examples in return-metadata-file
- **File**: `.claude/context/formats/return-metadata-file.md`
- **Action**: Restore the "Planning Success" and "Implementation Partial" JSON examples
- **Rationale**: Agents need concrete examples for non-obvious field combinations

### Priority 3 (Medium) -- Restore plan_metadata JSON example
- **File**: `.claude/context/formats/plan-format.md`
- **Action**: Add the JSON block back after the compressed description paragraph
- **Rationale**: `dependency_waves` nested array shape is not self-evident from text alone

### Priority 4 (Low) -- Add sequential plan note to Dependency Analysis
- **File**: `.claude/context/formats/plan-format.md`
- **Action**: Append sentence about fully sequential plans still requiring wave tables
- **Rationale**: Prevents agents from skipping wave tables for non-parallel plans

## Appendix: Files Requiring Changes

| File | Change Type | Lines Changed (est.) |
|------|-------------|---------------------|
| `.claude/skills/skill-memory/SKILL.md` | Restore 4 frontmatter fields | +4 |
| `.claude/context/formats/return-metadata-file.md` | Restore 2 JSON examples | +60 |
| `.claude/context/formats/plan-format.md` | Restore JSON block + sequential note | +15 |
