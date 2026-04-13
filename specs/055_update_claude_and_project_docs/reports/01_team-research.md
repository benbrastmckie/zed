# Research Report: Task #55

**Task**: Update all documentation in .claude/, README.md, and docs/ to reflect recent .claude/ changes
**Date**: 2026-04-13
**Mode**: Team Research (4 teammates)

## Summary

48 files were modified and 4 new files added in `.claude/`. The changes fall into 6 cross-cutting themes. Despite the breadth of code changes, the documentation debt is **narrow and bounded** — concentrated around 3 undocumented new capabilities and 1 functional inaccuracy in an existing routing table. The main `.claude/CLAUDE.md` has zero changes despite needing at least 5 updates.

---

## Key Findings

### Theme 1: `language` Field Removed — `task_type` Is Now Canonical

All `.task_type // .language // "general"` fallbacks removed across agents, commands, skills, and context files. Every file now uses `.task_type // "general"`. The backward-compatibility shim in `state-management-schema.md` was also removed.

**Documentation impact**:
- `.claude/CLAUDE.md` context discovery section still uses `languages[]?` in jq examples — must become `task_types[]?`
- `context-discovery.md` already updated (3 locations)
- `orchestrator.md` already updated
- `state-management-schema.md` shim removed

### Theme 2: `present:slides` Compound Task Type

The broken duplicate-key JSON pattern (`"task_type": "present", "task_type": "slides"`) replaced with single `"task_type": "present:slides"` across all agents, commands, and skills touching slides.

**Documentation impact**:
- CLAUDE.md Present Extension routing table still shows separate `present` | `slides` rows — needs `present:slides` compound value
- `commands/slides.md` output format still says `Task Type: present` instead of `present:slides` (stale remnant)

### Theme 3: Self-Execution Fallback (Stage 5b) Added to All Skills

Every delegating skill now includes a Stage 5b/4b/6b that writes `.return-meta.json` even when the agent bypasses the Task tool. Paired with `## Postflight (ALWAYS EXECUTE)` headers.

**Documentation impact**:
- New pattern documented in `postflight-control.md` and `thin-wrapper-skill.md`
- Not mentioned in CLAUDE.md (acceptable — this is an internal pattern, not user-facing)

### Theme 4: Artifact Linking Centralized

Inline 4-case Edit logic for TODO.md artifact linking removed from ~12 skills, replaced with references to new canonical file `artifact-linking-todo.md` with parameterized `field_name`/`next_field`.

**Documentation impact**:
- New file `artifact-linking-todo.md` is indexed in `context/index.json` with `always: true` — correct
- `planning-workflow.md` and `research-workflow.md` already updated to reference it
- No CLAUDE.md mention needed (internal pattern)

### Theme 5: New Slide Planning Capability (Undocumented)

`skill-slide-planning` + `slide-planner-agent` extracted from `skill-slides`. Implements 5-stage interactive design Q&A before delegating to a specialized slide-by-slide planning agent.

**Documentation impact** (HIGH PRIORITY):
- `.claude/CLAUDE.md` Skill-to-Agent table: missing `skill-slide-planning -> slide-planner-agent | opus`
- `.claude/CLAUDE.md` Agents table: missing `slide-planner-agent`
- `.claude/CLAUDE.md` Present Extension routing: shows `skill-slides` for plan, but actual routing is `skill-slide-planning` — **functional inaccuracy**
- `.claude/agents/README.md`: missing `slide-planner-agent` row
- `docs/agent-system/commands.md`: `/plan` on slides tasks triggers interactive Q&A, not generic planning
- `docs/agent-system/README.md`: Present extension description incomplete

### Theme 6: New PostToolUse Hook (Undocumented)

`validate-plan-write.sh` registered in `settings.json` as a Write|Edit PostToolUse hook. Validates artifact writes to `specs/*/plans/`, `specs/*/reports/`, `specs/*/summaries/`. Returns corrective `additionalContext` on failure.

**Documentation impact**:
- Not mentioned anywhere in CLAUDE.md, docs/, or any README
- Delegates to `validate-artifact.sh` which does not yet exist (graceful fallback)
- Anti-Bypass Constraint sections in `/research`, `/plan`, `/implement` commands reference this hook

### Phase Checkpoint Protocol Removal

Removed from 4 agents (grant, latex-implementation, python-implementation, typst-implementation). Phase tracking now centralized in plan format enforcement rules, not per-agent.

**Documentation impact**: Low — no central docs referenced this protocol by name.

---

## Synthesis

### Conflicts Resolved

1. **Teammate A vs C on docs/ scope**: Teammate A focused on `.claude/` internal docs; Teammate C flagged `docs/workflows/grant-development.md` as misrepresenting `/plan` for slides. **Resolution**: Both are correct — docs/ IS in scope per the task description, and the grant-development workflow doc needs updating.

2. **Teammate B vs C on `validate-artifact.sh`**: Teammate B noted it doesn't exist but hook handles gracefully. Teammate C flagged it as a blind spot. **Resolution**: The missing script is a known gap but non-blocking — the hook falls back silently. Document the hook's existence; note the script is pending.

3. **Teammate D vs A on agents/README.md**: Teammate D suggested adding `slide-planner-agent` to the README; Teammate C noted the README only covers 7 of 29 agents. **Resolution**: Add `slide-planner-agent` and a note that extension agents are documented in CLAUDE.md extension sections.

### Gaps Identified

1. **`.claude_OLD/` directory** — Untracked, unaddressed. Not a documentation issue but a cleanup item.
2. **`context/index.json.backup`** — Tracked backup file that shouldn't be in version control. Maintenance liability.
3. **Extensions.json path integrity** — Not validated. Medium risk of stale paths after large reload.
4. **git-workflow.md Co-Authored-By** — Still shows `Claude Opus 4.5` trailer despite user preference to omit entirely.

### Recommendations

#### Must-Do (functional correctness)

| # | File | Change |
|---|------|--------|
| 1 | `.claude/CLAUDE.md` | Add `skill-slide-planning -> slide-planner-agent \| opus` to Skill-to-Agent table |
| 2 | `.claude/CLAUDE.md` | Add `slide-planner-agent` to Agents table |
| 3 | `.claude/CLAUDE.md` | Fix Present Extension routing: `/plan` for `present:slides` → `skill-slide-planning` (not `skill-slides`) |
| 4 | `.claude/CLAUDE.md` | Update context discovery jq examples: `languages[]?` → `task_types[]?` |
| 5 | `.claude/CLAUDE.md` | Add `validate-plan-write.sh` hook to Rules References or new Hooks section |
| 6 | `.claude/agents/README.md` | Add `slide-planner-agent` row + note about extension agents in CLAUDE.md |

#### Should-Do (documentation completeness)

| # | File | Change |
|---|------|--------|
| 7 | `docs/agent-system/commands.md` | Note that `/plan` on slides tasks triggers interactive 5-stage design review |
| 8 | `docs/agent-system/README.md` | Add sentence about slide planning in Present extension description |
| 9 | `README.md` | Optionally note `/slides` + `/plan` interactive behavior in domain commands table |
| 10 | `.claude/CLAUDE.md` | Update Present Extension Skill-Agent Mapping table to include `skill-slide-planning` |
| 11 | `.claude/CLAUDE.md` | Present Extension Language Routing table: use `present:slides` compound value |

#### Could-Do (housekeeping)

| # | File | Change |
|---|------|--------|
| 12 | `.claude/rules/git-workflow.md` | Remove or update stale Co-Authored-By example (conflicts with user preference) |
| 13 | `.claude/agents/README.md` | Add note: extension agents documented in CLAUDE.md extension sections |
| 14 | `docs/workflows/grant-development.md` | Update `/plan` description for slides tasks |

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Agent/command/skill changes | completed | high |
| B | Context/extensions/settings | completed | high |
| C | Critic — gaps and risks | completed | high |
| D | Strategic doc alignment | completed | high |

## References

- All findings derived from `git diff .claude/` and `git status .claude/`
- Cross-referenced against `.claude/CLAUDE.md`, `README.md`, `docs/` directory
- Teammate findings preserved at `specs/055_update_claude_and_project_docs/reports/01_teammate-{a,b,c,d}-findings.md`
