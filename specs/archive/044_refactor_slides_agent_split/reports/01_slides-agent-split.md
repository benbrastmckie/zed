# Research Report: Task #44

**Task**: 44 - Refactor slides system: split slides-agent into three focused agents
**Started**: 2026-04-12T00:00:00Z
**Completed**: 2026-04-12T00:30:00Z
**Effort**: Medium (10-15 files to modify, 1 file to split into 3)
**Dependencies**: None
**Sources/Inputs**:
- `.claude/agents/slides-agent.md` (554 lines) -- current monolithic agent
- `.claude/skills/skill-slides/SKILL.md` (337 lines) -- routing skill
- `.claude/commands/slides.md` (497 lines) -- /slides command
- `.claude/extensions.json` -- present extension manifest
- `.claude/context/index.json` -- context routing entries
- `.claude/context/project/present/talk/index.json` -- talk library index
- Content templates, PPTX patterns, and Slidev project templates
- Reference agents: general-research-agent.md, latex-implementation-agent.md
**Artifacts**:
- `specs/044_refactor_slides_agent_split/reports/01_slides-agent-split.md`
**Standards**: report-format.md, artifact-management.md

## Executive Summary

- The current `slides-agent.md` (554 lines) combines two distinct workflows: format-agnostic content research (Stages 0-8) and PPTX-specific assembly (Stages A1-A8), with Slidev assembly marked as "not yet implemented"
- Context loading is wasteful: research workflow loads PPTX context references it never uses; assembly workflow loads research context it already consumed
- Splitting into three agents (slides-research-agent, pptx-assembly-agent, slidev-assembly-agent) reduces per-invocation context by ~40-60% and enables independent evolution
- The skill layer (`skill-slides`) already branches on `workflow_type` and `output_format`, making the routing change straightforward
- 10 files need modification; 1 file is deleted and replaced by 3 new agent files
- Content templates are currently Slidev-only (markdown format); the PPTX assembly agent uses pptx-generation.md helpers instead

## Context & Scope

The task description asks to split `slides-agent.md` into three focused agents to reduce context window usage and improve consistency. The current agent handles:

1. **Research workflow** (`slides_research`): Reads source materials, loads talk patterns, maps content to slide structure, identifies gaps, writes a slide-mapped research report. Format-agnostic -- the report is the same regardless of output format.

2. **PPTX assembly workflow** (`assemble` + `output_format=pptx`): Reads the slide-mapped research report, maps slide types to python-pptx components, generates a Python assembly script, executes it, verifies output.

3. **Slidev assembly workflow** (`assemble` + `output_format=slidev`): Currently returns "not yet implemented" error. The Slidev output path exists but uses the planner/implementer flow via `/plan` and `/implement` rather than the slides-agent.

## Findings

### 1. Current Slides-Agent Structure

**File**: `.claude/agents/slides-agent.md` (554 lines)

Stage mapping:

| Stage | Lines | Purpose | Workflow |
|-------|-------|---------|----------|
| 0 | 73-99 | Early metadata init | Shared |
| 1 | 101-122 | Parse delegation context | Shared |
| 1b | 124-127 | Resolve output format | Shared |
| 1c | 129-138 | Workflow branching | Shared (router) |
| 2 | 148-157 | Load talk pattern | Research only |
| 3 | 159-173 | Load source materials | Research only |
| 4 | 175-196 | Map content to slides | Research only |
| 5 | 198-214 | Identify content gaps | Research only |
| 6 | 216-254 | Create slide-mapped report | Research only |
| 7 | 256-279 | Write final metadata | Research only |
| 8 | 281-293 | Return text summary | Research only |
| A1 | 303-320 | Read research report | PPTX assembly only |
| A2 | 322-330 | Resolve design decisions | PPTX assembly only |
| A3 | 332-365 | Map slides to PPTX components | PPTX assembly only |
| A4 | 367-405 | Generate Python script | PPTX assembly only |
| A5 | 407-416 | Execute assembly script | PPTX assembly only |
| A6 | 418-430 | Verify output | PPTX assembly only |
| A7 | 432-457 | Write final metadata | PPTX assembly only |
| A8 | 459-473 | Return text summary | PPTX assembly only |

**Key observation**: Stages 0-1c are shared boilerplate (66 lines). The research workflow is ~150 lines of unique content. The PPTX assembly workflow is ~170 lines of unique content. Error handling and critical requirements sections (~80 lines) are partially shared.

### 2. Context References by Workflow

**Research workflow needs**:
- `return-metadata-file.md` (always)
- `talk/index.json` (talk library)
- `talk-structure.md` (talk structure guide)
- `presentation-types.md` (presentation types)
- `talk/patterns/{mode}.json` (by talk mode: conference, seminar, defense, journal-club)
- `talk/contents/{type}/` (by content need: title, methods, results, etc.)

**PPTX assembly workflow needs**:
- `return-metadata-file.md` (always)
- `talk/patterns/pptx-generation.md` (828 lines -- python-pptx API patterns)
- `talk/templates/pptx-project/theme_mappings.json` (theme constants)
- `talk/templates/pptx-project/generate_deck.py` (reference skeleton)

**Slidev assembly workflow would need**:
- `return-metadata-file.md` (always)
- `talk/patterns/slidev-pitfalls.md` (Slidev gotchas)
- `talk/templates/slidev-project/README.md` (project scaffold)
- `talk/templates/slidev-project/*` (package.json, vite.config.ts, etc.)
- `talk/contents/{type}/` (Slidev markdown templates)
- `talk/components/*.vue` (Vue components)
- `talk/themes/*.json` (theme definitions)

**Overlap**: Only `return-metadata-file.md` is shared. Research and assembly workflows have zero context overlap beyond the agent boilerplate and metadata format.

### 3. Skill-Slides Routing

**File**: `.claude/skills/skill-slides/SKILL.md` (337 lines)

Current routing (Stage 1c of skill):

| workflow_type | Action |
|---------------|--------|
| `slides_research` | Invoke slides-agent with `workflow_type=slides_research` |
| `assemble` | Invoke slides-agent with `workflow_type=assemble` |

The skill already branches on workflow_type. The change is to dispatch to different agent names:

| workflow_type | output_format | New Agent |
|---------------|---------------|-----------|
| `slides_research` | any | slides-research-agent |
| `assemble` | `pptx` | pptx-assembly-agent |
| `assemble` | `slidev` | slidev-assembly-agent |

The skill's Stages 2-3 (preflight status update, postflight marker) are workflow-type-aware but agent-agnostic, so they need only the subagent name updated in Stage 5.

### 4. Context Index Entries

Current entries in `.claude/context/index.json` that reference `slides-agent`:

| Path | Current agents |
|------|---------------|
| `project/present/domain/presentation-types.md` | `["slides-agent"]` |
| `project/present/patterns/talk-structure.md` | `["slides-agent"]` |
| `project/present/talk/patterns/slidev-pitfalls.md` | `["slides-agent", "planner-agent", "general-implementation-agent"]` |
| `project/present/talk/templates/slidev-project/README.md` | `["slides-agent", "general-implementation-agent"]` |

**Not in index** (referenced by @-ref in agent only):
- `talk/patterns/pptx-generation.md`
- `talk/templates/pptx-project/theme_mappings.json`
- `talk/templates/pptx-project/generate_deck.py`
- `talk/index.json`
- All `talk/contents/` templates
- All `talk/patterns/{mode}.json` files
- All `talk/themes/*.json` files

### 5. Extensions.json References

The `present` extension's `installed_files` array includes:
- `.claude/agents/slides-agent.md` -- must become 3 entries

### 6. CLAUDE.md Documentation

The Present Extension section in CLAUDE.md references:
- `skill-slides | slides-agent | opus | Research talk material synthesis and presentation assembly`

This needs updating to show the three new agents.

### 7. Content Template Format Mismatch

Content templates (`talk/contents/`) are **Slidev-specific**: they contain markdown with Slidev layout frontmatter and Vue component references. The PPTX assembly workflow does NOT use these templates -- it has its own mapping table (Stage A3) that converts slide types to python-pptx function calls.

This confirms the clean separation: research agent uses content templates for slot mapping (format-agnostic content extraction), PPTX assembly agent uses pptx-generation.md helpers, and Slidev assembly agent would use the content templates for actual markdown output.

### 8. Existing Agent Patterns (Reference)

Looking at other agents for structural patterns:

- **general-research-agent.md**: Clean single-purpose agent with context references section, execution flow stages, error handling, and critical requirements. ~200 lines.
- **latex-implementation-agent.md**: Implementation-only agent, loads only implementation context.
- **grant-agent.md**: Another present extension agent, single-purpose.

Pattern: agents declare `model:` in frontmatter, list context references with `@`-prefix, define stages sequentially, include error handling and critical requirements sections.

## Decisions

1. **Three-agent split is clean**: Research workflow (Stages 0-8) maps to `slides-research-agent`, PPTX assembly (Stages A1-A8) maps to `pptx-assembly-agent`, Slidev assembly is new (`slidev-assembly-agent`).

2. **Shared boilerplate**: Stages 0-1 (metadata init, delegation parsing) are agent-system boilerplate that every agent repeats. Each new agent gets its own copy tailored to its workflow.

3. **Skill routing update**: `skill-slides` changes from single-agent dispatch to three-way dispatch based on `workflow_type` + `output_format`.

4. **Context index updates**: Replace `slides-agent` references with appropriate new agent names. Add missing PPTX-specific entries for `pptx-assembly-agent`.

5. **Slidev assembly agent**: This is NEW functionality. The current slides-agent returns "not yet implemented" for Slidev assembly. The new agent should implement this using the Slidev templates and components already in the talk library.

## Recommendations

### Proposed Agent-to-Stage Mapping

**slides-research-agent** (~200 lines):
- Stage 0: Early metadata (adapted)
- Stage 1: Parse delegation context (research-specific fields only)
- Stage 2: Load talk pattern
- Stage 3: Load source materials
- Stage 4: Map content to slide structure
- Stage 5: Identify content gaps
- Stage 6: Create slide-mapped report
- Stage 7: Write final metadata (status: "researched")
- Stage 8: Return text summary
- Context: presentation-types.md, talk-structure.md, talk/index.json, talk/patterns/{mode}.json, talk/contents/

**pptx-assembly-agent** (~250 lines):
- Stage 0: Early metadata (adapted)
- Stage 1: Parse delegation context (assembly-specific fields)
- Stage A1: Read slide-mapped research report
- Stage A2: Resolve design decisions
- Stage A3: Map slides to PPTX components
- Stage A4: Generate Python assembly script
- Stage A5: Execute assembly script
- Stage A6: Verify output
- Stage A7: Write final metadata (status: "assembled")
- Stage A8: Return text summary
- Context: pptx-generation.md, pptx-project/theme_mappings.json, pptx-project/generate_deck.py

**slidev-assembly-agent** (~250 lines, NEW):
- Stage 0: Early metadata (adapted)
- Stage 1: Parse delegation context (assembly-specific fields)
- Stage S1: Read slide-mapped research report
- Stage S2: Resolve design decisions (theme selection)
- Stage S3: Scaffold Slidev project (copy template files)
- Stage S4: Generate slides.md from research report + content templates
- Stage S5: Apply theme styles
- Stage S6: Run verification (playwright-verify.mjs)
- Stage S7: Write final metadata (status: "assembled")
- Stage S8: Return text summary
- Context: slidev-pitfalls.md, slidev-project/README.md, talk/contents/, talk/components/, talk/themes/

### Files Requiring Modification

| # | File | Action | Details |
|---|------|--------|---------|
| 1 | `.claude/agents/slides-agent.md` | DELETE | Replaced by 3 new agents |
| 2 | `.claude/agents/slides-research-agent.md` | CREATE | Research workflow (Stages 0-8) |
| 3 | `.claude/agents/pptx-assembly-agent.md` | CREATE | PPTX assembly (Stages A1-A8) |
| 4 | `.claude/agents/slidev-assembly-agent.md` | CREATE | Slidev assembly (NEW) |
| 5 | `.claude/skills/skill-slides/SKILL.md` | MODIFY | Three-way agent dispatch |
| 6 | `.claude/extensions.json` | MODIFY | Update installed_files list |
| 7 | `.claude/context/index.json` | MODIFY | Update agent references, add PPTX entries |
| 8 | `.claude/CLAUDE.md` | MODIFY | Update skill-to-agent table |
| 9 | `.claude/context/project/present/talk/templates/pptx-project/README.md` | MODIFY | Update agent name references |
| 10 | `.claude/context/project/present/talk/patterns/pptx-generation.md` | MODIFY | Update agent name reference (line 3) |

**Optional (low priority)**:
| # | File | Action | Details |
|---|------|--------|---------|
| 11 | `.claude/context/project/present/talk/templates/pptx-project/generate_deck.py` | MODIFY | Update comment reference |
| 12 | `.claude/commands/slides.md` | VERIFY | References skill-slides not agent directly; likely no change needed |

### Context Index Entry Updates

Current -> New mapping:

| Entry Path | Current Agent | New Agent(s) |
|------------|---------------|--------------|
| `presentation-types.md` | `slides-agent` | `slides-research-agent` |
| `talk-structure.md` | `slides-agent` | `slides-research-agent` |
| `slidev-pitfalls.md` | `slides-agent, planner-agent, general-implementation-agent` | `slidev-assembly-agent, planner-agent, general-implementation-agent` |
| `slidev-project/README.md` | `slides-agent, general-implementation-agent` | `slidev-assembly-agent, general-implementation-agent` |

New entries to add:

| Entry Path | Agent(s) | Reason |
|------------|----------|--------|
| `talk/patterns/pptx-generation.md` | `pptx-assembly-agent` | Core PPTX API reference |
| `talk/templates/pptx-project/theme_mappings.json` | `pptx-assembly-agent` | Theme constants |
| `talk/templates/pptx-project/generate_deck.py` | `pptx-assembly-agent` | Reference script |
| `talk/templates/pptx-project/README.md` | `pptx-assembly-agent` | PPTX project docs |
| `talk/index.json` | `slides-research-agent` | Talk library index |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Slidev assembly agent is new functionality, not just a refactor | High | Medium | Clearly separate "split existing" from "implement new" in the plan. The slidev-assembly-agent can start with a skeleton that returns "not yet implemented" and be filled in later. |
| Extension source directory sync | Medium | Low | The source extension lives in `nvim/.claude/extensions/present/`. Changes to installed files must also update the source. Check `source_dir` in extensions.json. |
| Context index backup inconsistency | Low | Low | The `.backup` files exist but are not authoritative. Update the primary files only. |
| Skill-slides routing complexity | Low | Medium | The skill already has workflow_type branching. Adding output_format branching is a small delta. |

## Appendix

### Search Queries Used
- `Glob **/*slides*` in `.claude/`
- `Grep slides-agent|slides_agent` across `.claude/`
- `Grep slides.agent` across `.claude/`
- Context index jq queries for slides-agent, pptx, slidev, and talk entries
- Read of all primary files: slides-agent.md, SKILL.md, slides.md, extensions.json, index.json, talk/index.json, content templates

### Line Counts

| File | Lines |
|------|-------|
| slides-agent.md | 554 |
| skill-slides SKILL.md | 337 |
| slides.md (command) | 497 |
| pptx-generation.md | 828 |
| context/index.json | ~4200 (full file) |
| extensions.json | 434 |

### Agent Size Estimates (Post-Split)

| New Agent | Estimated Lines | Context Budget |
|-----------|-----------------|----------------|
| slides-research-agent | ~180-220 | ~500 lines (patterns, templates) |
| pptx-assembly-agent | ~220-260 | ~900 lines (pptx-generation.md alone is 828) |
| slidev-assembly-agent | ~200-250 | ~400 lines (pitfalls, project README, templates) |
| Original slides-agent | 554 | ~1500+ lines (all context combined) |
