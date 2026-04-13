# Improvements to Port Back to nvim/.claude/

All changes below were identified by comparing the freshly reloaded `.claude/` (from the nvim preset) against `.claude_NEW_NEW/` (the previous zed working copy). The `.claude_NEW_NEW/` version contains improvements made during actual use that haven't been ported upstream yet.

Target: `/home/benjamin/.config/nvim/.claude/`

---

## 1. Remove Phase Checkpoint Protocol (3 agents)

**Files**:
- `agents/epi-implement-agent.md`
- `agents/pptx-assembly-agent.md`
- `agents/slidev-assembly-agent.md`

**What to remove**: Each agent has a "Phase Checkpoint Protocol" section (~28-60 lines) documenting per-phase `[IN PROGRESS]`/`[COMPLETED]` status tracking in plan headings, per-phase git commits, and phase-to-stage mapping tables. Additionally, inline references to the protocol (preamble notes, per-phase commit notes, numbered rules at the end).

**Why**: Simplifies to single-commit model. The per-phase tracking was overhead without clear benefit — assembly agents don't need checkpoint granularity.

**Specific removals per file**:

### epi-implement-agent.md
- Lines ~141-159: "Before each phase" / "After each phase" status update instructions + git commit template
- Lines ~489-516: Full "Phase Checkpoint Protocol" section (read plan, update status, execute, commit, proceed)

### pptx-assembly-agent.md
- Lines ~100-147: Full "Phase Checkpoint Protocol" section with phase-to-stage mapping table (A1-A6)
- Lines ~150-151: Preamble reference ("Before processing slides, read the plan file...")
- Lines ~265-266: Per-phase git commit note
- Lines ~371-373: Rules 8-10 (follow protocol, update headings, create per-phase commits)

### slidev-assembly-agent.md
- Lines ~118-165: Full "Phase Checkpoint Protocol" section with phase-to-stage mapping table (S1-S7)
- Lines ~168-169: Preamble reference
- Lines ~313-314: Per-phase git commit note
- Lines ~403-405: Rules 10-12 (follow protocol, update headings, create per-phase commits)

---

## 2. Remove Stage 5.5 from Meta System

**Files**:
- `agents/meta-builder-agent.md`
- `skills/skill-meta/SKILL.md`
- `docs/reference/standards/multi-task-creation-standard.md`

**What**: `/meta` tasks should start at `[NOT STARTED]` instead of `[RESEARCHED]`. Remove auto-generated research artifacts.

### agents/meta-builder-agent.md

**Remove** (~100 lines at Stage 5.5):
- The entire "Interview Stage 5.5: GenerateResearchArtifacts" section (steps 5.5.1 through 5.5.4)
- Includes: directory creation, research report template, artifact tracking, proceed-to-Stage-6 instructions

**Change** the Stage 5 confirmation action:
```
# OLD
**If user selects "Yes"**: Proceed to Stage 5.5 (Research Artifact Generation).

# NEW
**If user selects "Yes"**: Proceed to Stage 6 (CreateTasks).
```

**Change** Stage 6 state.json entry:
```json
// OLD
"status": "researched",
"artifacts": [
  {
    "type": "research",
    "path": "specs/036_task_slug/reports/01_meta-research.md",
    "summary": "Auto-generated research from /meta interview"
  }
]

// NEW
"status": "not_started",
"artifacts": []
```

**Remove** the note about RESEARCHED status:
```
// REMOVE
**Note**: Tasks created via /meta start in `"researched"` status because Stage 5.5 generates research artifacts from interview context. This enables immediate `/plan N` without requiring separate `/research N`.
```

**Change** TODO.md entry format:
```markdown
<!-- OLD -->
- **Status**: [RESEARCHED]
...
- **Research**: [01_meta-research.md]({NNN}_{slug}/reports/01_meta-research.md)

<!-- NEW -->
- **Status**: [NOT STARTED]
<!-- (no Research line) -->
```

**Change** next_steps messaging:
```
# OLD
"next_steps": "Run /plan 430 to create implementation plan (research already complete)"

# NEW
"next_steps": "Run /research 430 to begin research on first task"
```

### skills/skill-meta/SKILL.md

**Change** expected return example:
```
# OLD
"summary": "Created 2 tasks for command creation workflow. Tasks start in RESEARCHED status.",
"tasks_status": "researched"
"next_steps": "Run /plan 430 to create implementation plan (research already complete)"

# NEW
"summary": "Created 2 tasks for command creation workflow. Tasks start in NOT STARTED status.",
"tasks_status": "not_started"
"next_steps": "Run /research 430 to begin research on first task"
```

**Remove** artifact entries from example state.json output (the `"type": "research"` entries).

**Change** closing note:
```
# OLD
**Note**: Tasks created via `/meta` start in RESEARCHED status because the interview process generates research artifacts from the captured context. This enables immediate `/plan N` execution without requiring separate `/research N` calls.

# NEW
**Note**: Tasks created via `/meta` start in NOT STARTED status. Run `/research N` to begin the standard research -> plan -> implement lifecycle.
```

### docs/reference/standards/multi-task-creation-standard.md

**Remove** from the compliance table the "Research Gen" column:
```
// OLD
| Command | Required | Grouping | Dependencies | Ordering | Visualization | Research Gen |
|---------|----------|----------|--------------|----------|---------------|--------------|
| `/meta` | Yes | **Automatic** | Full DAG | Kahn's | Linear/Layered | **Yes** |
...

// NEW
| Command | Required | Grouping | Dependencies | Ordering | Visualization |
|---------|----------|----------|--------------|----------|---------------|
| `/meta` | Yes | **Automatic** | Full DAG | Kahn's | Linear/Layered |
...
```

**Remove** the "Enhanced Stages" entries:
```
// REMOVE
- **Research Generation** row from component table
- **Stage 5.5 (GenerateResearchArtifacts)**: Creates `01_meta-research.md` from interview context for each task
- **RESEARCHED Status**: Tasks start in `researched` status, enabling immediate `/plan N` without separate `/research N`
```

**Change** state updates description:
```
# OLD
| State Updates | Interview Stage 6 (batch insertion with RESEARCHED status) |

# NEW
| State Updates | Interview Stage 6 (batch insertion with NOT STARTED status) |
```

---

## 3. Update Extension Trigger Wording (5 skills)

Single-line change in each file.

| File | Old | New |
|------|-----|-----|
| `skills/skill-epi-implement/SKILL.md:34` | `Extension is loaded via \`<leader>ac\`` | `Epidemiology extension is available` |
| `skills/skill-epi-research/SKILL.md:33` | `Extension is loaded via \`<leader>ac\`` | `Epidemiology extension is available` |
| `skills/skill-funds/SKILL.md:36` | `Extension is loaded via \`<leader>ac\`` | `Present extension is available` |
| `skills/skill-grant/SKILL.md:34` | `Extension is loaded via \`<leader>ac\`` | `Present extension is available` |
| `skills/skill-timeline/SKILL.md:35` | `Extension is loaded via \`<leader>ac\`` | `Present extension is available` |

---

## 4. Restore .npmrc in Slidev Template

**File**: `context/project/present/talk/templates/slidev-project/.npmrc`

This file was deleted and never re-added. Create it with:

```
shamefully-hoist=true
```

Required for Slidev dependencies to resolve correctly with pnpm.

---

## 5. Port Slides Skill Improvements

**File**: `skills/skill-slides/SKILL.md`

### 5a. Header/metadata clarification

```yaml
# OLD
# Subagent dispatch (resolved at Stage 4):

# NEW
# Subagents (dispatched by workflow_type + output_format):
```

Add after subagent list:
```yaml
# Context is loaded by each subagent independently.
# Tools (used by subagents):
#   - Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, Bash
```

### 5b. Subagent description rewrite

```markdown
# OLD
Thin wrapper that routes slides tasks to one of three specialized subagents:
- **slides-research-agent** -- material synthesis into slide-mapped reports
- **planner-agent** -- design-aware implementation planning (with D1-D3 design questions)
- **pptx-assembly-agent** / **slidev-assembly-agent** -- presentation assembly by output format

# NEW
Thin wrapper that delegates slides work to the appropriate subagent based on workflow type and output format:
- **slides-research-agent**: Material synthesis into slide-mapped research reports
- **pptx-assembly-agent**: PowerPoint generation from research reports
- **slidev-assembly-agent**: Slidev project generation from research reports
```

### 5c. Stage 3.5 (Design Questions) rewrite

The entire Stage 3.5 section is restructured from inline bash (case statements, variable assignments) to a clearer step-by-step format with pseudocode:

- **Step 1**: Check for existing design_decisions (simplified from nested if/case)
- **Step 2**: Read research report (standalone step, not embedded in conditionals)
- **Step 3**: Design questions D1-D3 (presented as AskUserQuestion prompts with "Store response as..." instructions instead of bash variable assignments)
- **Step 4**: Store design decisions (jq update, same logic but separate step)

The theme fallback chain documentation moves from a standalone note to inline in the subagent description.

### 5d. Stage 4 dispatch simplification

```bash
# OLD
if [ "$output_format" = "pptx" ]; then
  target_agent="pptx-assembly-agent"
else
  target_agent="slidev-assembly-agent"
fi

# NEW
case "$output_format" in
  pptx) target_agent="pptx-assembly-agent" ;;
  *)    target_agent="slidev-assembly-agent" ;;
esac
```

Routing table moved from Stage 4 to after Stage 4's dispatch block. `"plan"` removed from `workflow_type` field in delegation context (plan is handled separately). Delegation context no longer passes `design_decisions` explicitly (subagent reads from state.json).

### 5e. Remove Plan Success output template

Remove the "Plan Success" return template (planner-agent handles its own output).

---

## 6. Port Slides Command Improvements

**File**: `commands/slides.md`

### 6a. Output format prompt wording

```markdown
# OLD
What output format for this presentation?
- SLIDEV (default): Browser-based slides with Slidev markdown
- PPTX: PowerPoint file via python-pptx

# NEW
What output format do you want for the presentation?
- SLIDEV (default): Slidev markdown-based slides
- PPTX: PowerPoint presentation file
```

Add explicit default behavior:
```
# OLD
Store response as `forcing_data.output_format`. Default: `"slidev"`.

# NEW
Store response as `forcing_data.output_format`. If the user does not specify or is ambiguous, default to `"slidev"`.
```

### 6b. Step reference fix

```
# OLD
Run Stage 0 forcing questions (Steps 0.0-0.3)

# NEW
Run Stage 0 forcing questions (Steps 0.1-0.3)
```

### 6c. Step 2.5 (Enrich Description) rewrite

Replace the compact inline version with an expanded 3-step process:

1. **Start with base description** (distinguish `input_type="description"` vs `input_type="file_path"`)
2. **Append structured details** (talk type, output format, source materials with relative paths, audience context summary)
3. **Replace `$desc`** for both state.json and TODO.md

Add path relativization with git repo root detection:
```bash
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
# ... loop over source_materials, strip repo_root prefix, fall back to basename
```

Add audience summary truncation (~20 words / 120 chars).

Remove the standalone duration lookup table (inline the concept instead).

---

## 7. Python -> Rust in Documentation Examples

**Files** (7):
- `docs/guides/creating-skills.md`
- `docs/guides/creating-agents.md`
- `docs/guides/component-selection.md`
- `docs/architecture/system-overview.md`
- `docs/guides/adding-domains.md`
- `docs/guides/creating-extensions.md`
- `context/architecture/component-checklist.md`

**What**: All documentation examples use "Python" as the example language for adding new language support. Change to "Rust" throughout.

Key substitutions:
| Old | New |
|-----|-----|
| `skill-python-research` | `skill-rust-research` |
| `python-research-agent` | `rust-research-agent` |
| `"language": "python"` | `"language": "rust"` |
| `asyncio best practices` | `tokio best practices` |
| `project/python/tools.md` | `project/rust/tools.md` |
| `Python, Rust` (in lists) | `Rust, Go` |
| `latex, lean, python, react` | `latex, lean, rust, react` |
| `Python, React, Rust` | `Rust, React, Go` |
| `Python packages or APIs` | `Rust crates or APIs` |

**Note**: The actual Python extension files (agents, skills, context) remain in the preset — this change only affects documentation examples. If Python support should remain as a shipped extension, keep it. The doc examples are just about which language is used as the "how to add a new language" tutorial.

---

## 8. Normalize context/index.json Field Ordering

**File**: `context/index.json`

**What**: JSON keys are inconsistently ordered across entries. Normalize to:
```json
{
  "load_when": { "always": true, "agents": [], "commands": [], "task_types": [] },
  "summary": "...",
  "domain": "...",
  "keywords": [],
  "subdomain": "...",
  "line_count": 0,
  "topics": []
}
```

Within `load_when`, order: `always` -> `agents` -> `commands` -> `task_types`.

No semantic changes — purely structural consistency for maintainability.

---

## Summary

| # | Change | Files | Effort | Priority |
|---|--------|-------|--------|----------|
| 1 | Remove phase checkpoint protocol | 3 agents | Small | High |
| 2 | Remove Stage 5.5 from meta system | 3 files | Medium | High |
| 3 | Update extension trigger wording | 5 skills | Trivial | High |
| 4 | Restore .npmrc | 1 file | Trivial | High |
| 5 | Slides skill improvements | 1 skill | Medium | Medium |
| 6 | Slides command improvements | 1 command | Small | Medium |
| 7 | Python -> Rust doc examples | 7 docs | Small | Low |
| 8 | Normalize index.json ordering | 1 file | Trivial | Low |
