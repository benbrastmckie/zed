# Post-Reload Diff Report: .claude/ (preset) vs .claude_NEW_NEW/ (previous zed)

Direction: `.claude/` (freshly reloaded from nvim preset) vs `.claude_NEW_NEW/` (previous zed-specific version).
Goal: Identify changes worth porting back to the nvim preset at `/home/benjamin/.config/nvim/.claude/`.

Previous versions: `.claude_OLD/` (oldest) -> `.claude_NEW/` (middle, had `extensions/` dir) -> `.claude_NEW_NEW/` (just replaced).

---

## Changes to Port Back to nvim Preset

### 1. Phase Checkpoint Protocol Removed (3 agents)

Agents:
- `agents/epi-implement-agent.md` (~28 lines removed)
- `agents/pptx-assembly-agent.md` (~60 lines removed)
- `agents/slidev-assembly-agent.md` (~48 lines removed)

**What**: Per-phase status tracking (`[IN PROGRESS]`, `[COMPLETED]`), per-phase git commits, phase-to-stage mapping tables all removed. Simplifies to single-commit model.

**Action**: Remove phase checkpoint protocol sections from these agents in nvim preset.

### 2. Meta System: Remove Stage 5.5 (Research Artifact Generation)

Files:
- `agents/meta-builder-agent.md`: Stage 5.5 (GenerateResearchArtifacts) deleted (~100 lines)
- `skills/skill-meta/SKILL.md`: Expected return updated for NOT STARTED status
- `docs/reference/standards/multi-task-creation-standard.md`: Removed Stage 5.5 row and references

**What**: `/meta` tasks now start at `[NOT STARTED]` instead of `[RESEARCHED]`. No auto-generated `01_meta-research.md` files. Tasks follow normal `/research -> /plan -> /implement` flow. Stage 6 (CreateTasks) no longer generates artifact links or `artifacts` arrays in state.json. Next steps say "Run /research" instead of "Run /plan (research already complete)".

**Action**: Remove Stage 5.5 from meta-builder-agent, update skill-meta and multi-task-creation-standard.

### 3. Extension Trigger Wording Update (5 skills)

Skills:
- `skills/skill-epi-implement/SKILL.md`
- `skills/skill-epi-research/SKILL.md`
- `skills/skill-funds/SKILL.md`
- `skills/skill-grant/SKILL.md`
- `skills/skill-timeline/SKILL.md`

**What**: "Extension is loaded via `<leader>ac`" -> "[Domain] extension is available". Simpler, not tied to nvim-specific loading mechanism.

**Action**: Update trigger wording in nvim preset.

### 4. Slides Skill Improvements

File: `skills/skill-slides/SKILL.md`

**What**: Clarified subagent dispatch pattern, removed planner-agent reference from design workflow, expanded Stage 3.5 design question workflow with more detail.

**Action**: Port updated skill-slides.

### 5. Slides Command Path Relativization

File: `commands/slides.md`

**What**: Step 2.5 expanded with a proper 3-step process including git repo root detection, bash-based path relativization, and clearer formatting. Output format prompt wording also refined.

**Action**: Port updated slides command.

### 6. Talk Structure Pattern Refinement

File: `context/project/present/patterns/talk-structure.md`

**What**: Slidev/PowerPoint pattern descriptions expanded (more specific about what each pattern doc covers — footer positioning, Mermaid rendering, PDF export verification, theme application, speaker notes).

**Action**: Port updated talk-structure.md. Already in nvim preset since this is the source.

### 7. Documentation Examples: Python -> Rust

Files:
- `docs/guides/creating-skills.md`
- `docs/guides/creating-agents.md`
- `docs/guides/component-selection.md`
- `docs/architecture/system-overview.md`
- `docs/guides/adding-domains.md`
- `docs/guides/creating-extensions.md`
- `context/architecture/component-checklist.md`

**What**: Python examples replaced with Rust throughout docs. "Python, Rust" -> "Rust, Go" in extension lists.

**Action**: Port if Python extension is no longer bundled as a default example.

### 8. Restore .npmrc in Slidev Template

File: `context/project/present/talk/templates/slidev-project/.npmrc`

**What**: Contains `shamefully-hoist=true`. Present in `.claude_NEW/` but missing from both `.claude_NEW_NEW/` and current `.claude/`. Git status shows it as deleted.

**Action**: Re-add to nvim preset's present extension template.

### 9. Context index.json Field Reordering

File: `context/index.json`

**What**: JSON keys normalized — `summary` moved up after `load_when`, `agents` moved before `commands` in `load_when`. No semantic changes, just consistent field ordering.

**Action**: Port for consistency if desired. Low priority.

---

## Zed-Specific Changes (Do NOT Port)

### 1. project-overview.md
Zed configuration description. Repo-specific.

### 2. Python Extension Files
Current `.claude/` includes python agents, skills, and context from the nvim preset. These are correct for the preset but may not be needed in every target repo. Not a gap.

### 3. PPTX Template Binary
`context/project/present/talk/templates/pptx-project/UCSF_ZSFG_Template_16x9.pptx` — binary, repo-specific.

### 4. Python Routing Entry
`context/routing.md` gained a python row in `.claude_NEW_NEW/` that the preset already has. Expected.

### 5. extensions.json, settings.local.json, logs/
Runtime artifacts and local config. Not portable.

### 6. Extension Manifest Approach
`.claude_NEW/` had `extensions/present/manifest.json` with explicit routing, provides, and mcp_servers fields. This was removed in `.claude_NEW_NEW/` — extensions are now pre-merged into the main agent system rather than loaded from manifest files. The manifest approach may be worth revisiting as a cleaner architecture but is not a regression.

---

## Changes Already Captured (Verified Present in All Versions)

- Three-agent split (slides-research-agent, pptx-assembly-agent, slidev-assembly-agent)
- `--design` flag removal from `/slides` command
- Output format selection (Slidev/PPTX) at task creation
- Design questions moved into `skill-slides` plan workflow
- UCSF institutional theme added
- pptx-generation.md and slidev-pitfalls.md patterns
- Talk library index.json updates
- Footer styling in theme JSON files
- Enriched description construction in slides.md
- All template files (playwright-verify.mjs, pptx-project/, slidev-project/)

---

## Summary of Gaps (Priority Order)

| # | Change | Scope | Effort |
|---|--------|-------|--------|
| 1 | Remove phase checkpoint protocol from 3 agents | agents/ | Small |
| 2 | Remove Stage 5.5 from meta system | agents/, skills/, docs/ | Medium |
| 3 | Update extension trigger wording in 5 skills | skills/ | Trivial |
| 4 | Restore .npmrc in slidev template | templates/ | Trivial |
| 5 | Port slides skill + command improvements | skills/, commands/ | Small |
| 6 | Python -> Rust doc examples | docs/ | Small |
| 7 | context/index.json field ordering | context/ | Trivial |

## Potential Further Improvements for nvim Preset

### A. Extension Manifest Architecture
`.claude_NEW/` experimented with `extensions/present/manifest.json` containing explicit routing tables, dependency declarations, and MCP server configs. This was abandoned in `.claude_NEW_NEW/` but the concept of declarative extension manifests with routing is cleaner than pre-merging everything. Worth considering as a future architecture improvement.

### B. Auto-Memory Migration
Previous DIFF.md noted auto-memory being disabled in favor of `.memory/` via `/learn`. If this is the intended direction, the nvim preset's CLAUDE.md context layers table should be updated to reflect this.

### C. Extension Loading Model Documentation
CLAUDE.md still references `<leader>ac` for extension loading in some places while the actual mechanism has shifted to pre-merged extensions. Documentation should be consistent with the actual loading model used.
