# Teammate B Findings: New/Deleted Files and Broken References

## Key Findings

### 1. Renamed Agents (Deleted → New)

| Deleted | New | Change |
|---------|-----|--------|
| `epidemiology-research-agent.md` | `epi-research-agent.md` | Shortened name + comprehensive rewrite |
| `epidemiology-implementation-agent.md` | `epi-implement-agent.md` | Shortened name + comprehensive rewrite |

The old agents were minimal stubs (~20 lines, capability lists). The new agents are fully-specified execution agents with explicit stages (0-9 for research, 0-5 for implement), metadata file protocol, 5-phase R analysis workflow, and detailed error handling.

### 2. Renamed Skills (Deleted → New)

| Deleted | New |
|---------|-----|
| `.claude/skills/skill-epidemiology-research/SKILL.md` | `.claude/skills/skill-epi-research/SKILL.md` |
| `.claude/skills/skill-epidemiology-implementation/SKILL.md` | `.claude/skills/skill-epi-implement/SKILL.md` |

### 3. New Command Added

`.claude/commands/epi.md` — A new `/epi` command with a 10-question forcing flow for study design scoping. No equivalent existed in the old system. This is comparable to `/grant` in the present extension.

### 4. New Context Files Added

**Domain files** (all new, in `.claude/context/project/epidemiology/domain/`):
- `causal-inference.md`
- `data-management.md`
- `missing-data.md`
- `reporting-standards.md`
- `r-workflow.md`
- `study-designs.md`

**Pattern files** (new additions):
- `patterns/analysis-phases.md`
- `patterns/observational-methods.md`
- `patterns/strobe-checklist.md`

**Templates** (all new, in `.claude/context/project/epidemiology/templates/`):
- `analysis-plan.md`
- `findings-report.md`

The old system had only `patterns/statistical-modeling.md` and `tools/` files.

### 5. Stale Reference in `.claude/context/routing.md`

Line 15 of `/home/benjamin/.config/zed/.claude/context/routing.md` still uses old skill names:
```
| epidemiology | skill-epidemiology-research | skill-epidemiology-implementation |
```
Should be:
```
| epi, epi:study, epidemiology | skill-epi-research | skill-epi-implement |
```

### 6. Stale Reference in `.claude/agents/README.md`

The agents README lists only 7 core agents in its table and makes no mention of epi-research-agent or epi-implement-agent (or any extension agents). After this reload, 24 agent files exist, but the README table only documents 7. The README needs either:
- An extension agents section listing epi-research-agent and epi-implement-agent
- Or a note that extension agents are tracked elsewhere

### 7. Docs Missing `/epi` Command Entry

`docs/agent-system/commands.md` opens with "catalog of all **24** slash commands." After adding `epi.md`, there are still 24 commands total (the count was already correct before the reload because the command was untracked). However, `/epi` has no entry in the catalog. The "Research & Grants" section covers `/grant`, `/budget`, `/timeline`, `/funds`, `/slides` but has no epidemiology section.

### 8. Docs Missing Epidemiology Workflow

`docs/workflows/README.md` has sections for: Agent system, Grant development, Memory, Office documents. There is no epidemiology workflow section. The `grant-development.md` workflow file exists as a model; an equivalent `epidemiology-analysis.md` workflow file would complete the coverage.

### 9. Agent Count in `docs/agent-system/architecture.md` Is Accurate

Line 110 says `agents/ # 25 agent specifications`. Current count is 24 agent files + README.md = 25 entries total in the directory. If "25 agent specifications" means 25 non-README agent files, the count is off by 1 (24 actual agents). If it means 25 total directory entries, it is correct. This is ambiguous and low priority.

## Recommended Approach

### Must Fix (Broken Functionality)

1. **`routing.md` stale skill names** — The routing table in `.claude/context/routing.md` still maps `epidemiology` to the deleted `skill-epidemiology-research` and `skill-epidemiology-implementation`. Any task with `task_type: epidemiology` would fail to route. Update to `skill-epi-research` and `skill-epi-implement`, and add `epi` and `epi:study` rows.

### Should Fix (Documentation Gaps)

2. **`docs/agent-system/commands.md`** — Add `/epi` entry in a new "Epidemiology" section (or within "Research & Grants"). Update the opening count from "24" to "25" if `/epi` was not previously documented, or verify count first.

3. **`docs/workflows/README.md`** — Add an "Epidemiology analysis" row to the contents table, pointing to a new `epidemiology-analysis.md` workflow file.

4. **Create `docs/workflows/epidemiology-analysis.md`** — Parallel to `grant-development.md`. Should cover: `/epi` command flow, study design types, the 5-phase R analysis, `/research` → `/plan` → `/implement` routing for epi tasks.

### Nice to Have

5. **`.claude/agents/README.md`** — Add an "Extension Agents" section that lists `epi-research-agent.md` and `epi-implement-agent.md` alongside the other extension agents (budget-agent, grant-agent, etc., which are also missing from the table).

## Evidence/Examples

### Old → New Name Mappings

| Component | Old Name | New Name |
|-----------|----------|----------|
| Research agent | `epidemiology-research-agent` | `epi-research-agent` |
| Implement agent | `epidemiology-implementation-agent` | `epi-implement-agent` |
| Research skill | `skill-epidemiology-research` | `skill-epi-research` |
| Implement skill | `skill-epidemiology-implementation` | `skill-epi-implement` |
| Research invocation | `skills: skill-epidemiology-research` | `skill-epi-research` (via Task tool) |
| Command | (none) | `/epi` |

### Broken routing.md entry (line 15)

Current (broken):
```
| epidemiology | skill-epidemiology-research | skill-epidemiology-implementation |
```

Fixed:
```
| epi | skill-epi-research | skill-epi-implement |
| epi:study | skill-epi-research | skill-epi-implement |
| epidemiology | skill-epi-research | skill-epi-implement |
```

### New task type keys (from CLAUDE.md Epidemiology Extension section)

The CLAUDE.md routing table now supports three task type keys: `epi`, `epi:study`, `epidemiology`. The old system supported only `epidemiology` and `r`.

### New context structure (6 domain files, 3 new patterns, 2 templates)

The old epidemiology extension had ~4 context files. The new extension has 14 context files across domain/, patterns/, templates/, and tools/ directories, representing a substantial expansion in coverage.

## Confidence Level

**High** for:
- Renamed agents and skills (confirmed via git show on deleted files and ls on new files)
- routing.md stale entry (confirmed by reading the file)
- /epi command missing from docs/agent-system/commands.md (searched and found no entry)
- New context files (confirmed by ls of domain/ and templates/ directories)

**Medium** for:
- Agent count accuracy in architecture.md (depends on interpretation of "25 specifications")
- agents/README.md coverage gap (the README explicitly covers only core agents; extension agents may be intentionally excluded)

**Low** for:
- Whether a new epidemiology-analysis.md workflow doc is needed vs updating an existing file (depends on scope decisions by the planner)
