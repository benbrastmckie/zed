# Research Report: Task #40

**Task**: 40 - Update skill-slides for format-specific assembly routing
**Started**: 2026-04-12T23:00:00Z
**Completed**: 2026-04-12T23:15:00Z
**Effort**: Small
**Dependencies**: Task 39 (slides-agent PPTX assembly workflow)
**Sources/Inputs**: Codebase analysis of skill-slides, slides-agent, slides command, implement command, present extension manifest
**Artifacts**: specs/040_skill_slides_format_routing/reports/01_format-routing.md
**Standards**: report-format.md

## Executive Summary

- The `skill-slides` SKILL.md currently passes a single `workflow_type: "assemble"` to slides-agent but does not read or forward `forcing_data.output_format` to determine which assembly variant to use
- The slides-agent (updated by task 39) already has branching logic at Stage 1c that checks both `workflow_type` and `output_format`, but skill-slides does not pass `output_format` in its delegation context
- Three files need changes: `SKILL.md` (delegation context, commit messages, return summaries), and minor alignment in the implement command routing
- Backward compatibility is straightforward: default `output_format` to `"slidev"` when absent in forcing_data

## Context & Scope

Task 37 added `output_format` as a forcing question (Step 0.0) in the `/slides` command, storing it in `forcing_data.output_format` in state.json. Task 39 added the PPTX assembly workflow (Stages A1-A8) in slides-agent.md, with branching at Stage 1c based on `workflow_type` and `output_format`. This task (40) bridges the gap: skill-slides must read `output_format` from task metadata and route to the correct assembly variant.

## Findings

### 1. Current skill-slides Assembly Flow

The skill-slides SKILL.md (`.claude/skills/skill-slides/SKILL.md`) defines two workflow types:

| Workflow Type | Purpose |
|--------------|---------|
| `slides_research` | Research and material synthesis |
| `assemble` | Presentation assembly |

At **Stage 4** (Prepare Delegation Context), the skill constructs a delegation JSON that includes:
```json
{
  "workflow_type": "slides_research|assemble",
  "forcing_data": "{from state.json task metadata}"
}
```

The `forcing_data` is passed through from state.json, which means `output_format` **is already available** in the delegation context -- it just needs to be explicitly documented and the skill needs to handle routing based on it.

### 2. Where output_format Lives

The `output_format` field is stored in `state.json` at:
```
active_projects[].forcing_data.output_format
```

It is set during `/slides "description"` task creation (Step 0.0 of slides.md command). Valid values: `"slidev"` (default), `"pptx"`.

The skill-slides SKILL.md Stage 4 already passes `forcing_data` from state.json to the subagent, so the value flows through. However, the skill itself does not inspect or act on `output_format`.

### 3. slides-agent Branching (Task 39)

The slides-agent.md Stage 1c already implements format-aware branching:

| workflow_type | output_format | Action |
|---------------|---------------|--------|
| `slides_research` | any | Research workflow (Stages 2-8) |
| `assemble` | `pptx` | PPTX assembly (Stages A1-A8) |
| `assemble` | `slidev` | Write failed metadata: "Slidev assembly not yet implemented" |

So the agent-side is complete. The skill-side needs to:
1. Read `output_format` from forcing_data before delegation
2. Pass it explicitly (or confirm it flows through forcing_data)
3. Adjust commit messages and return summaries based on format

### 4. Commit Message Patterns

Current skill-slides Stage 9 (Git Commit):
```bash
case "$workflow_type" in
  slides_research)
    commit_action="complete slides research"
    ;;
  assemble)
    commit_action="assemble slides presentation"
    ;;
esac
```

This needs format-specific variants:
- `assemble` + `pptx`: `"assemble PPTX presentation"`
- `assemble` + `slidev`: `"assemble Slidev presentation"` (future)

### 5. Return Summary Patterns

Current skill-slides Stage 11 Assemble Success:
```
Talk presentation assembled for task {N}:
- Output directory: talks/{N}_{slug}/
- Files created: slides.md, style.css, README.md
- Theme: {theme_name}
```

This is Slidev-specific. For PPTX, the output structure is different:
- Files: `{slug}.pptx`, `generate_deck.py`
- No `style.css` or `README.md`

The return summary should reflect the actual output format.

### 6. How /implement Routes to skill-slides

The `/implement` command uses extension manifest routing:
```json
"implement": {
  "present:slides": "skill-slides"
}
```

It invokes skill-slides with: `task_number={N} plan_path={path} resume_phase={phase} session_id={session_id}`

It does **not** pass `workflow_type=assemble`. The skill-slides must infer this from the command context (being invoked for implementation means assemble). Currently, the SKILL.md says `workflow_type` defaults to `slides_research`, which is incorrect for the `/implement` path.

**Gap identified**: When `/implement` invokes skill-slides, the skill needs to detect that this is an assemble operation. Options:
1. The implement command passes `workflow_type=assemble` in args
2. The skill infers assemble from the task status (status=planned means assemble)
3. The implement command's routing string includes the workflow hint (like grant does: `"skill-grant:assemble"`)

Looking at the grant extension manifest routing: `"present:grant": "skill-grant:assemble"` -- it uses a colon-suffixed workflow hint. The slides routing is `"present:slides": "skill-slides"` without the `:assemble` suffix. This is another gap to address.

### 7. Grant Skill Pattern (Reference Implementation)

The skill-grant SKILL.md handles the assemble workflow similarly and can serve as a reference:
- It receives `workflow_type` from the orchestrator
- For assemble, it sets `preflight_status="implementing"`
- Commit action: `"assemble grant materials"`
- It reads forcing_data from state.json task metadata

## Decisions

1. **Routing approach**: Use the manifest routing hint pattern (`:assemble`) like grant does, updating the present extension manifest routing for slides from `"skill-slides"` to `"skill-slides:assemble"` for the implement path
2. **Format detection**: Read `output_format` from `forcing_data` in state.json at skill level, before delegating to agent
3. **Default format**: When `output_format` is absent in forcing_data, default to `"slidev"` for backward compatibility
4. **Commit message format**: Include output format in commit action string
5. **Return summary format**: Vary return summary content based on output_format

## Recommendations

### Changes Required

**File 1: `.claude/skills/skill-slides/SKILL.md`**

1. **Stage 2 (Preflight)**: Add `output_format` extraction from `forcing_data`:
   ```bash
   forcing_data=$(echo "$task_data" | jq -r '.forcing_data // "{}"')
   output_format=$(echo "$forcing_data" | jq -r '.output_format // "slidev"')
   ```

2. **Stage 4 (Delegation Context)**: Ensure `output_format` is explicitly in the delegation JSON (it already flows through forcing_data, but document it)

3. **Stage 7 (Status Update)**: Add handling for `assembled` status from the agent (already present in the table but needs the `output_format` conditional)

4. **Stage 9 (Git Commit)**: Format-specific commit actions:
   ```bash
   assemble)
     if [ "$output_format" = "pptx" ]; then
       commit_action="assemble PPTX presentation"
     else
       commit_action="assemble Slidev presentation"
     fi
     ;;
   ```

5. **Stage 11 (Return Summary)**: Format-specific return messages:
   - PPTX: Reference `.pptx` file and `generate_deck.py`
   - Slidev: Reference `slides.md`, `style.css`, `README.md`

**File 2: Present extension manifest (source: nvim)**

Update the implement routing:
```json
"implement": {
  "present:slides": "skill-slides:assemble"
}
```

This ensures `/implement` passes `workflow_type=assemble` to skill-slides.

**File 3: `.claude/commands/implement.md` (optional)**

The implement command's extension routing lookup already handles the `skill:workflow` pattern for grants. Verify it parses `skill-slides:assemble` correctly. If not, add parsing logic.

### Implementation Phases

1. **Phase 1**: Update skill-slides SKILL.md with format-aware routing, commit messages, and return summaries
2. **Phase 2**: Update present extension manifest routing for slides implement path
3. **Phase 3**: Verify implement command handles `:assemble` suffix parsing (may already work from grant implementation)

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Implement command may not parse `:assemble` suffix for slides | Check implement.md routing code; grant already uses this pattern |
| Breaking existing slidev-defaulting behavior | Default to `"slidev"` when output_format absent |
| Extension manifest is in nvim source, not zed | Update source manifest; re-run extension loader to propagate |
| slides-agent may not receive output_format | forcing_data passthrough already works; add explicit test |

## Appendix

### Files Examined
- `.claude/skills/skill-slides/SKILL.md` (318 lines) - Main skill definition
- `.claude/agents/slides-agent.md` (554 lines) - Agent with PPTX assembly workflow (task 39)
- `.claude/commands/slides.md` (497 lines) - Command with output_format forcing question (task 37)
- `.claude/commands/implement.md` - Extension routing logic
- `.claude/extensions.json` - Extension registry
- `/home/benjamin/.config/nvim/.claude/extensions/present/manifest.json` - Source manifest with routing
- `.claude/skills/skill-grant/SKILL.md` - Reference implementation for assemble pattern
