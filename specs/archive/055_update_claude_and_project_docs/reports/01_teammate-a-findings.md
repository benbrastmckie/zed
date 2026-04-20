---
title: Teammate A Findings - Agent, Command, and Skill Changes
task: 55
date: 2026-04-13
author: teammate-a
---

# Teammate A Findings: Agent, Command, and Skill Changes

## Key Findings

Four major cross-cutting changes affect agents, commands, and skills:

1. **`language` field removed; `task_type` is now canonical** — All references to `.language` fallback (`.task_type // .language // "general"`) have been dropped. Every file now uses `.task_type // "general"`. This is a breaking migration away from a legacy field.

2. **`present:slides` replaces the dual `task_type` keys** — The broken duplicate-key pattern (`"task_type": "present", "task_type": "slides"`) is replaced with a single compound value `"task_type": "present:slides"`. This fixes a JSON bug where only the last key was visible.

3. **Self-Execution Fallback (Stage 5b/4b/6b) added to all skills** — Every skill now includes a critical postflight safety stage that ensures `.return-meta.json` is written even when the agent bypasses the Task tool and executes inline. This is paired with an explicit `## Postflight (ALWAYS EXECUTE)` header that precedes Stage 6.

4. **TODO.md artifact linking logic centralized** — The inline multi-case Edit logic (detect existing field, insert inline, convert to multi-line, append) has been removed from all skills and replaced with a reference to `@.claude/context/patterns/artifact-linking-todo.md` with parameterized `field_name` and `next_field` values.

5. **New `skill-slide-planning` and `slide-planner-agent`** — The plan workflow for slides tasks is now a dedicated skill+agent pair, extracted from `skill-slides`. The old interactive design Q&A (D1-D3) in `skill-slides` has been removed and moved to the new skill.

6. **Anti-Bypass Constraints added to `/research`, `/plan`, `/implement`** — New `## Anti-Bypass Constraint` sections in command files explicitly prohibit commands from writing to `specs/*/reports/`, `specs/*/plans/`, or `specs/*/summaries/` directly, requiring delegation to skills.

---

## Agent Changes

### `.claude/agents/grant-agent.md`

- **Removed**: `## Phase Checkpoint Protocol` section (~33 lines) — the entire section describing how to update phase markers in plan files, commit with `task {N} phase {P}: {phase_name}`, and ensure resumability.
- **Fixed**: `### Stage 6` and `### Stage 7` headings changed to `## Stage 6` and `## Stage 7` (h2 instead of h3), which was a heading hierarchy bug.
- **Nature**: Refactor — phase checkpoint tracking is now handled elsewhere (centralized in plan format enforcement, not per-agent).

### `.claude/agents/latex-implementation-agent.md`

- **Removed**: `## Phase Checkpoint Protocol` section (~18 lines) — the condensed version of phase update/commit protocol.
- **Removed**: MUST DO item "5. Update plan file phase markers with Edit tool".
- **Nature**: Refactor — same pattern as grant-agent.

### `.claude/agents/pptx-assembly-agent.md`

- **Fixed**: Duplicate key `"task_type": "present", "task_type": "slides"` replaced with `"task_type": "present:slides"`.
- **Nature**: Bug fix — duplicate JSON keys meant only "slides" was readable.

### `.claude/agents/python-implementation-agent.md`

- **Removed**: `## Phase Checkpoint Protocol` section (~28 lines) — full version with Edit tool specifics.
- **Removed**: MUST DO item "5. Update plan file phase markers with Edit tool".
- **Nature**: Refactor — same pattern.

### `.claude/agents/slides-research-agent.md`

- **Fixed**: Duplicate `task_type` keys → `"task_type": "present:slides"`.
- **Nature**: Bug fix.

### `.claude/agents/slidev-assembly-agent.md`

- **Fixed**: Duplicate `task_type` keys → `"task_type": "present:slides"`.
- **Nature**: Bug fix.

### `.claude/agents/typst-implementation-agent.md`

- **Removed**: `## Phase Checkpoint Protocol` section (~18 lines).
- **Removed**: MUST DO item "5. Update plan file phase markers with Edit tool".
- **Removed**: MUST DO item "6. Include PDF in artifacts if compilation succeeds" → renumbered to "5."
- **Nature**: Refactor — same pattern.

---

## Command Changes

### `.claude/commands/budget.md`

- **Changed**: Task validation now checks `.task_type` instead of `.language`. Variable renamed from `task_lang` to `task_type`. Error message updated accordingly.
- **Nature**: Migration from legacy `language` field to `task_type`.

### `.claude/commands/funds.md`

- **Changed**: Same `.language` → `.task_type` migration. Also fixed a jq syntax bug: the old condition `[ "$task_lang" = "present" | not ]` (which is invalid bash/jq hybrid) is now `[ "$task_type" != "present" ]` — a proper bash comparison.
- **Nature**: Bug fix + field migration.

### `.claude/commands/implement.md`

- **Added**: `## Anti-Bypass Constraint` section prohibiting direct Write/Edit to `specs/*/summaries/*.md`. Explains that a PostToolUse hook monitors these paths.
- **Changed**: `task_type` extraction removes `.language` fallback: `.task_type // .language // "general"` → `.task_type // "general"`.
- **Nature**: New enforcement constraint + field migration.

### `.claude/commands/plan.md`

- **Added**: `## Anti-Bypass Constraint` section prohibiting direct writes to `specs/*/plans/*.md`.
- **Changed**: Same `.language` fallback removal.
- **Nature**: New enforcement constraint + field migration.

### `.claude/commands/research.md`

- **Added**: `## Anti-Bypass Constraint` section prohibiting direct writes to `specs/*/reports/*.md`.
- **Changed**: Two instances of `.language` fallback removal (once in task lookup, once in routing).
- **Nature**: New enforcement constraint + field migration.

### `.claude/commands/slides.md`

- **Changed**: Task validation now checks `task_type == "present:slides"` instead of dual language+task_type check.
- **Changed**: Description enrichment simplified — removed path relativization logic and audience summary appending. New format: `{description} ({talk_type} talk, {duration}, {output_format})`.
- **Changed**: state.json task creation uses `"task_type": "present:slides"` (single key).
- **Added**: TODO.md task entry now includes `**Sources**:` block and `**Forcing Data Gathered**:` block.
- **Changed**: Output confirmation message updated to show `Task Type: present` and forcing data block.
- **Changed**: Routing documentation updated from dual-field check to single `task_type="present:slides"`.
- **Nature**: Bug fix (duplicate key) + feature refinement (cleaner description format, richer TODO entry).

### `.claude/commands/spawn.md`

- **Changed**: `.language` fallback removal in task context extraction.
- **Nature**: Field migration.

### `.claude/commands/task.md`

- **Changed**: `.language` fallback removal in task metadata extraction.
- **Nature**: Field migration.

### `.claude/commands/todo.md`

- **Changed**: `.language` fallback removal in two places: task type classification loop and jq filter for non-meta tasks.
- **Changed**: jq filter updated from `(.task_type // .language) != "meta"` to `.task_type != "meta"` (with appropriate jq-safe syntax).
- **Nature**: Field migration.

---

## Skill Changes

### `.claude/skills/skill-budget/SKILL.md`

- **Changed**: `language=` variable → `task_type=`.
- **Added**: `### Stage 5b: Self-Execution Fallback` and `## Postflight (ALWAYS EXECUTE)` sections.
- **Changed**: TODO.md artifact linking instruction → reference to `artifact-linking-todo.md` pattern with `field_name=**Research**`, `next_field=**Plan**`.

### `.claude/skills/skill-epi-implement/SKILL.md`

- **Added**: Stage 5b self-execution fallback + Postflight header.
- **Renamed**: `### Stage 6: Parse Subagent Return (Read Metadata File)` → `### Stage 6: Read Metadata File`.
- **Added**: TODO.md artifact link instruction with `field_name=**Summary**`, `next_field=**Description**`.

### `.claude/skills/skill-epi-research/SKILL.md`

- **Added**: Stage 5b self-execution fallback + Postflight header.
- **Renamed**: Stage 6 heading.
- **Added**: TODO.md artifact link instruction with `field_name=**Research**`, `next_field=**Plan**`.

### `.claude/skills/skill-funds/SKILL.md`

- **Changed**: `language=` → `task_type=`.
- **Added**: Stage 5b self-execution fallback + Postflight header.
- **Renamed**: Stage 6 heading.
- **Changed**: TODO.md artifact link instruction → pattern reference.

### `.claude/skills/skill-grant/SKILL.md`

- **Changed**: `language=` → `task_type=`.
- **Added**: Stage 5b self-execution fallback + Postflight header.
- **Renamed**: Stage 6 heading.
- **Changed**: TODO.md artifact link with per-workflow parameterization (funder_research, proposal_draft, budget_develop, progress_track, assemble → each with explicit `field_name` and `next_field`).

### `.claude/skills/skill-implementer/SKILL.md`

- **Changed**: `.language` fallback removal.
- **Added**: Stage 5b self-execution fallback + Postflight header.
- **Changed**: TODO.md inline 4-case Edit logic (~20 lines) removed → replaced with reference to `artifact-linking-todo.md` with `field_name=**Summary**`, `next_field=**Description**`.

### `.claude/skills/skill-latex-implementation/SKILL.md`

- **Added**: Stage 4b self-execution fallback + Postflight header (numbered 4b, not 5b, due to this skill's shorter stage count).
- **Changed**: Stage 7 artifact link instruction → pattern reference with `field_name=**Summary**`, `next_field=**Description**`.

### `.claude/skills/skill-latex-research/SKILL.md`

- **Added**: Stage 4b self-execution fallback + Postflight header.
- **Changed**: Stage 7 artifact link instruction → pattern reference with `field_name=**Research**`, `next_field=**Plan**`.

### `.claude/skills/skill-planner/SKILL.md`

- **Changed**: `.language` fallback removal.
- **Added**: Stage 5b self-execution fallback + Postflight header (with explicit `status value "planned"`).
- **Changed**: TODO.md inline 4-case Edit logic (~20 lines) removed → reference with `field_name=**Plan**`, `next_field=**Description**`.

### `.claude/skills/skill-python-implementation/SKILL.md`

- **Added**: Stage 4b self-execution fallback + Postflight header.
- **Changed**: Stage 7 artifact link → pattern reference with `field_name=**Summary**`, `next_field=**Description**`.

### `.claude/skills/skill-python-research/SKILL.md`

- **Added**: Stage 4b self-execution fallback + Postflight header.
- **Changed**: Stage 7 artifact link → pattern reference with `field_name=**Research**`, `next_field=**Plan**`.

### `.claude/skills/skill-researcher/SKILL.md`

- **Changed**: `.language` fallback removal.
- **Added**: Stage 5b self-execution fallback + Postflight header (with explicit `status value "researched"`).
- **Changed**: TODO.md inline 4-case Edit logic (~20 lines) removed → reference with `field_name=**Research**`, `next_field=**Plan**`.

### `.claude/skills/skill-reviser/SKILL.md`

- **Changed**: `.language` fallback removal.
- **Added**: Stage 5b self-execution fallback + Postflight header.
- **Renamed**: Stage 6 heading.
- **Changed**: TODO.md condensed 3-case Edit description removed → reference with `field_name=**Plan**`, `next_field=**Description**`.

### `.claude/skills/skill-slides/SKILL.md`

- **Removed from header comment**: `planner-agent` dispatch reference.
- **Added note**: Plan workflow is now handled by `skill-slide-planning`.
- **Removed**: `plan` workflow from trigger conditions; updated to reference `present:slides` task type.
- **Removed**: `plan` row from workflow routing table.
- **Removed**: `### Stage 3.5: Design Questions (plan workflow only)` — entire 100+ line interactive Q&A section (D1-D3 questions, design_decisions storage, state.json update).
- **Removed**: `plan` case from agent resolution and status mapping.
- **Removed**: `plan` commit action.
- **Changed**: `language` variable removal and validation logic fixes: old broken condition (`!=` with both task_type fields) → clean compound check with legacy "slides" fallback.
- **Changed**: `task_type` context uses `present:slides` (single compound value).
- **Added**: Stage 5b self-execution fallback + Postflight header.
- **Added**: TODO.md artifact link instruction with `field_name=**Summary**`.
- **Nature**: Major refactor — plan workflow extracted to new skill.

### `.claude/skills/skill-spawn/SKILL.md`

- **Changed**: `.language` fallback removal.
- **Added**: Stage 6b self-execution fallback + Postflight header (numbered 6b for this skill's stage layout).

### `.claude/skills/skill-team-implement/SKILL.md`

- **Changed**: `.language` fallback removal.
- **Changed**: TODO.md inline 4-case Edit logic removed → reference with `field_name=**Summary**`, `next_field=**Description**`.

### `.claude/skills/skill-team-plan/SKILL.md`

- **Changed**: `.language` fallback removal.
- **Changed**: TODO.md inline 4-case Edit logic removed → reference with `field_name=**Plan**`, `next_field=**Description**`.

### `.claude/skills/skill-team-research/SKILL.md`

- **Changed**: `.language` fallback removal.
- **Changed**: TODO.md inline 4-case Edit logic removed → reference with `field_name=**Research**`, `next_field=**Plan**`.

### `.claude/skills/skill-timeline/SKILL.md`

- **Changed**: `language=` → `task_type=`.
- **Added**: Stage 5b self-execution fallback + Postflight header.
- **Renamed**: Stage 6 heading.
- **Changed**: TODO.md artifact link → pattern reference with `field_name=**Research**`, `next_field=**Plan**`.

### `.claude/skills/skill-typst-implementation/SKILL.md`

- **Added**: Stage 4b self-execution fallback + Postflight header.
- **Changed**: Stage 7 artifact link → pattern reference with `field_name=**Summary**`, `next_field=**Description**`.

### `.claude/skills/skill-typst-research/SKILL.md`

- **Added**: Stage 4b self-execution fallback + Postflight header.
- **Changed**: Stage 7 artifact link → pattern reference with `field_name=**Research**`, `next_field=**Plan**`.

---

## New Files

### `.claude/agents/slide-planner-agent.md` (NEW - untracked)

- New agent for slide-aware implementation planning.
- Model: `opus`.
- Invoked by `skill-slide-planning` via Task tool.
- Purpose: Consumes structured design decisions (from skill-slide-planning's 5-stage Q&A) and research reports to produce slide-by-slide implementation plans with template assignments and content sources.
- Distinct from `planner-agent` — generates per-slide production specs rather than generic phase plans.

### `.claude/skills/skill-slide-planning/SKILL.md` (NEW - untracked)

- New skill extracting the interactive design Q&A from `skill-slides`.
- 5-stage interactive Q&A workflow: theme preference, narrative arc feedback, slide include/exclude, per-slide refinement.
- Triggers on `/plan` for tasks with `task_type: "slides"` or `"present:slides"`.
- Delegates to `slide-planner-agent` after gathering design decisions.
- Implements skill-internal postflight pattern.
- Context: `fork` (loads independently).

---

## Documentation Impact

### High Priority

1. **`CLAUDE.md` / Agent System docs** — The `language` field is no longer used. Any documentation mentioning `.language` as a state.json field or fallback should be updated or removed. The state schema section in the main CLAUDE.md still shows no `language` field (good), but any human-readable guidance about task routing that mentions "language" needs updating.

2. **Present Extension docs** — The `task_type: "present"` + `task_type: "slides"` pattern is now `task_type: "present:slides"`. The Present Extension section in CLAUDE.md and any routing tables showing `present` + `slides` as separate fields need updating.

3. **Skill-to-Agent Mapping** — The CLAUDE.md Skill-to-Agent Mapping table does not list `skill-slide-planning` → `slide-planner-agent`. This new pair needs to be added.

4. **`artifact-linking-todo.md` pattern file** — The new pattern at `.claude/context/patterns/artifact-linking-todo.md` is referenced by ~12 skills but may be new (it appears in untracked files list). If it doesn't exist or is incomplete, this is a critical gap — all skills will fail to link artifacts correctly.

5. **Phase Checkpoint Protocol removal** — The removed protocol was documented in 4 agent files. If there's a central reference to "Phase Checkpoint Protocol" in any context or README, those references need removal or replacement.

### Medium Priority

6. **`/slides` command docs** — The simplified description format (`{description} ({talk_type} talk, {duration}, {output_format})`) and the new TODO.md entry format (with Sources and Forcing Data blocks) may warrant updated examples.

7. **Anti-Bypass Constraint hooks** — The commands reference a "PostToolUse hook" that monitors artifact paths. If this hook exists in `.claude/settings.json` or similar, it should be documented. Teammate B may have visibility on this.

8. **`validate-artifact.sh`** — Referenced in Anti-Bypass Constraints but not yet confirmed to exist. If it's a new file, it needs documentation.

### Lower Priority

9. **Command Reference table in CLAUDE.md** — Does not mention `/slides` routing changes or the new `skill-slide-planning`. Minor update may be needed.

10. **Routing table** — The extension routing table for `present:slides` may need updating to show `plan -> skill-slide-planning` explicitly.

---

## Confidence Level

**High** — All changes derived directly from `git diff` output with full line-by-line inspection. The cross-cutting nature of the four themes (language field removal, present:slides compound type, self-execution fallback, artifact-linking centralization) was consistent across all 45 changed files, lending high confidence to the pattern identification.

One area of uncertainty: whether `artifact-linking-todo.md` exists and is complete. This is the single most critical dependency of the changes — if it's missing or malformed, ~12 skills will have broken TODO.md linking instructions.
