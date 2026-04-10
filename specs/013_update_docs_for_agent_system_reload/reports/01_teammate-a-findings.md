# Teammate A Findings: .claude/ Agent System Changes and Documentation Impact

**Task**: 13 — Update docs/ documentation to reflect reloaded .claude/ agent system changes
**Researcher**: Teammate A (Primary Angle)
**Date**: 2026-04-10

---

## Key Findings

### Summary of .claude/ Changes

The reload replaced the old `epidemiology` extension (v1.0.0) with a substantially rebuilt v2.0.0. This is **the only extension that changed**; latex, filetypes, present, memory, and typst are unchanged in content (only JSON key ordering changed in extensions.json, which is a no-op functionally). The changes fall into three categories:

#### 1. Agent/Skill Renaming (epidemiology extension)

**Deleted agents**:
- `.claude/agents/epidemiology-research-agent.md`
- `.claude/agents/epidemiology-implementation-agent.md`

**New agents**:
- `.claude/agents/epi-research-agent.md`
- `.claude/agents/epi-implement-agent.md`

**Deleted skills**:
- `.claude/skills/skill-epidemiology-research/SKILL.md`
- `.claude/skills/skill-epidemiology-implementation/SKILL.md`

**New skills** (already on disk in new names):
- `.claude/skills/skill-epi-research/`
- `.claude/skills/skill-epi-implement/`

#### 2. Task Type Routing Changes

**Old routing** (in `.claude/CLAUDE.md` and `commands/task.md`):
```
task_type: "epidemiology" or "r"
skills: skill-epidemiology-research / skill-epidemiology-implementation
agents: epidemiology-research-agent / epidemiology-implementation-agent
```

**New routing**:
```
task_type: "epi", "epi:study", or "epidemiology" (all map to same agents)
skills: skill-epi-research / skill-epi-implement
agents: epi-research-agent / epi-implement-agent
```

**Keyword change in `commands/task.md`** (auto-detection):
```diff
- "epidemiology", "epimodel", "stan", "infectious" → epidemiology
+ "epidemiology", "epi", "cohort", "case-control", "strobe" → epi:study
```

#### 3. New Command: /epi

A new dedicated `commands/epi.md` was added. This is a Stage-0 forcing-question command that:
- Asks 10 scoping questions before task creation
- Stores responses as `forcing_data` in state.json
- Routes to `epi:study` task type
- Supports three input modes: description string, task number, or file path

The old epidemiology extension had no dedicated command.

#### 4. Expanded Context Library

**Old context** (4 files):
- `project/epidemiology/README.md`
- `project/epidemiology/tools/r-packages.md`
- `project/epidemiology/patterns/statistical-modeling.md`
- `project/epidemiology/tools/mcp-guide.md`

**New context** (15+ files):
- `domain/study-designs.md`, `domain/causal-inference.md`, `domain/missing-data.md`
- `domain/data-management.md`, `domain/reporting-standards.md`, `domain/r-workflow.md`
- `patterns/observational-methods.md`, `patterns/analysis-phases.md`, `patterns/strobe-checklist.md`
- `templates/analysis-plan.md`, `templates/findings-report.md`
- (plus existing: `patterns/statistical-modeling.md`, `tools/r-packages.md`, `tools/mcp-guide.md`)

#### 5. check-extension-docs.sh Enhancement

A new `check_routing_block()` function was added to validate that extension manifests with skills also declare a routing block. This is an internal tool change with no direct documentation impact.

#### 6. context/index.json Restructuring

The `index.json` was reformatted (key ordering changed: `subdomain` and `path` moved before `topics`, etc.). The content itself is unchanged. No documentation impact.

---

## Docs Files Affected

### Docs that NEED updates

| File | What needs changing | Priority |
|------|---------------------|----------|
| `docs/agent-system/commands.md` | Missing `/epi` command entirely | HIGH |
| `docs/agent-system/architecture.md` | References "epidemiology" as task_type; old skill/agent names implied | MEDIUM |
| `docs/workflows/README.md` | No entry for epidemiology workflows | MEDIUM |
| `docs/agent-system/README.md` | Epidemiology extension description in Zed adaptations section | LOW |

### Docs that do NOT need updates

| File | Reason |
|------|--------|
| `docs/agent-system/context-and-memory.md` | No epi-specific content; generic context architecture is unchanged |
| `docs/workflows/agent-lifecycle.md` | Generic lifecycle; epi routing is out of scope for this doc |
| `docs/workflows/maintenance-and-meta.md` | No epi content |
| `docs/workflows/grant-development.md` | Present extension unchanged |
| `docs/workflows/memory-and-learning.md` | Memory extension unchanged |
| `docs/workflows/convert-documents.md` | Filetypes extension unchanged |
| `docs/workflows/edit-word-documents.md` | Unchanged |
| `docs/workflows/edit-spreadsheets.md` | Unchanged |
| `docs/general/` (all files) | Installation, keybindings, settings: no epi-specific content |

---

## Recommended Approach

Listed in priority order:

### Priority 1 — Add /epi to command catalog (HIGH)

**File**: `docs/agent-system/commands.md`

The command catalog lists 24 commands. `/epi` is now present in `.claude/commands/epi.md` and is a first-class command but is missing from `commands.md` entirely.

Suggested placement: Add a new "Epidemiology" section (or add to "Research & Grants" group, since it follows the same forcing-question pattern as `/grant`, `/budget`, `/slides`, etc.).

Required content:
- 2-sentence description: Stage-0 interactive command with 10 forcing questions
- Example: `/epi "Cohort study of vaccine effectiveness"` and `/epi 5`
- Three input modes: description, task number, file path
- Link to `.claude/commands/epi.md`

### Priority 2 — Add epidemiology workflow page (MEDIUM)

**New file**: `docs/workflows/epidemiology-workflow.md` (or section in existing file)

No workflow narrative exists for the epi extension. The grant extension has `docs/workflows/grant-development.md` as its narrative guide. The epi extension now has comparable complexity (10-question forcing flow, 5-phase R analysis, study-design-specific routing) and deserves similar treatment.

At minimum, should cover:
- When to use `/epi` vs. `/task`
- The 10 forcing questions and why they matter
- What the research agent produces (study design report with data inventory)
- What the implement agent produces (5 R scripts + findings report)
- The `/epi N` shortcut to resume research on existing task

If a full new page is out of scope, add a brief entry to `docs/workflows/README.md` pointing to the command catalog and `commands/epi.md`.

### Priority 3 — Update architecture.md routing table (MEDIUM)

**File**: `docs/agent-system/architecture.md`

The routing table at line 127-133 only shows core task types. It mentions "epidemiology, etc." as examples of specialty routing. This text should be updated to reflect the new task type keys (`epi`, `epi:study`, `epidemiology`) and the new skill/agent names.

The "extensions" section at lines 119-121 says: "every extension entry... (epidemiology, filetypes, latex, memory, present, typst) is pre-merged." This is still accurate but could note that `epi` and `epi:study` are the current task type keys for the epidemiology extension.

The skill/agent count in the configuration tree (line 109-110) says "32 skill routers" and "25 agent specifications". These numbers should be verified against current filesystem state (two old agents deleted, two new agents added; two old skills deleted, two new skills added — net change is zero, so counts may still be correct).

**Check**: Current agents directory has 25 agents (counted above). Current skills directory has 32 skills (counted above). Numbers in architecture.md appear accurate.

### Priority 4 — Update workflows/README.md decision guide (LOW)

**File**: `docs/workflows/README.md`

The decision guide at line 38 has no entry for "Design a cohort or epi study." Consider adding:

```
| Design a cohort, case-control, or other epi study | [See /epi command](../agent-system/commands.md#epi) |
```

### Priority 5 — Update agent-system/README.md Zed adaptations (LOW)

**File**: `docs/agent-system/README.md`

Line 36: "Every extension entry in `.claude/CLAUDE.md` (epidemiology, filetypes, latex, memory, present, typst) is pre-merged..." — This is still accurate. No change strictly required, but could note the `/epi` command as the entry point.

---

## Evidence/Examples

### Specific diff → doc mapping

**diff: `.claude/CLAUDE.md` Epidemiology section rewrite**

Old CLAUDE.md:
```
### Language Routing
| Language | Research Tools | Implementation Tools |
| `epidemiology` | skill-epidemiology-research | skill-epidemiology-implementation |
| `r` | rmcp, WebSearch | Rscript, Read, Write |
```

New CLAUDE.md:
```
### Task Type Routing
| Task Type Key | Research | Plan | Implement |
| `epi` | skill-epi-research | skill-planner | skill-epi-implement |
| `epi:study` | skill-epi-research | skill-planner | skill-epi-implement |
| `epidemiology` | skill-epi-research | skill-planner | skill-epi-implement |

### Command
`/epi` -- Stage 0 interactive routing.
```

**Impact**: `docs/agent-system/commands.md` lacks `/epi`. The routing table change in CLAUDE.md is already authoritative — docs/agent-system/architecture.md references it correctly via link.

**diff: `.claude/commands/task.md` keyword routing**

```diff
- "epidemiology", "epimodel", "stan", "infectious" → epidemiology
+ "epidemiology", "epi", "cohort", "case-control", "strobe" → epi:study
```

**Impact**: `docs/agent-system/architecture.md` line 126 mentions task_type routing but correctly defers to `.claude/CLAUDE.md` for the full table. No update needed; however, the architecture doc could add "epi" and "epi:study" to the specialty types mention at line 133.

**diff: `.claude/extensions.json` epidemiology entry**

Old: 8 installed files, version 1.0.0, skills `skill-epidemiology-*`, agents `epidemiology-*-agent`
New: 20 installed files, version 2.0.0, skills `skill-epi-*`, agents `epi-*-agent`, new `commands/epi.md`

**Impact**: This directly confirms `/epi` is now a first-class installed command in the epidemiology extension. The docs need to reflect this.

**diff: agents deleted and new agents on disk**

New agents read during this research:
- `epi-research-agent.md`: Elaborate 9-stage workflow, data inventory, STROBE/CONSORT selection
- `epi-implement-agent.md`: 5-phase R analysis (data cleaning, EDA, primary, sensitivity, reporting)

These are substantially more capable than the old agents. The new workflow document (Priority 2 above) should explain this to users.

---

## Confidence Level

**High** — The git diff clearly shows which files changed. The docs/ content was read in full. The mapping from diff to docs is unambiguous.

The only uncertainty is whether a standalone `docs/workflows/epidemiology-workflow.md` is in scope for this task or whether a minimal `commands.md` addition plus `README.md` cross-reference is sufficient. The plan phase should resolve this scope question.

---

## Appendix: File Inventory Cross-check

**Current agents/** (25 files, consistent with architecture.md):
budget, code-reviewer, document, docx-edit, epi-implement, epi-research, filetypes-router, funds, general-implementation, general-research, grant, latex-implementation, latex-research, meta-builder, planner, presentation, reviser, scrape, spawn, spreadsheet, talk, timeline, typst-implementation, typst-research, (README = 25 non-README entries)

**Current skills/** (32 directories, consistent with architecture.md):
skill-budget, skill-docx-edit, skill-epi-implement, skill-epi-research, skill-filetypes, skill-fix-it, skill-funds, skill-git-workflow, skill-grant, skill-implementer, skill-latex-implementation, skill-latex-research, skill-memory, skill-meta, skill-orchestrator, skill-planner, skill-presentation, skill-refresh, skill-researcher, skill-reviser, skill-scrape, skill-spawn, skill-spreadsheet, skill-status-sync, skill-talk, skill-team-implement, skill-team-plan, skill-team-research, skill-timeline, skill-todo, skill-typst-implementation, skill-typst-research (32 total)

Agent/skill counts in `docs/agent-system/architecture.md` are accurate — no update needed for those numbers.
