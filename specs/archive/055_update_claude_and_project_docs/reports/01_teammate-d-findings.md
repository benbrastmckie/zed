# Teammate D Findings: Documentation Alignment Analysis

**Task**: 55 — Update CLAUDE.md and Project Docs
**Date**: 2026-04-13
**Scope**: Cross-reference existing documentation against current .claude/ directory state; identify gaps, mismatches, and strategic improvements.

---

## Key Findings

The documentation is **largely accurate but has specific, bounded gaps** caused by the recent addition of three new capabilities: `slide-planner-agent`, `skill-slide-planning`, and the `validate-plan-write.sh` hook. These are integrated into `extensions.json`, `settings.json`, and the skills/agents directories but are **not documented anywhere in `.claude/CLAUDE.md`, the agents README, or any user-facing docs**.

The existing documentation (`.claude/CLAUDE.md`, root `README.md`, `docs/`) is internally consistent, well-organized, and accurate for everything it does cover. The doc debt is narrow, not broad.

---

## CLAUDE.md Sections Requiring Updates

### 1. Skill-to-Agent Mapping Table (lines 166–183)
**Issue**: `slide-planner-agent` and `skill-slide-planning` are absent.

**Current**: The table lists `skill-planner -> planner-agent` as the sole planning skill.

**Required addition**:
```
| skill-slide-planning | slide-planner-agent | opus | Interactive 5-stage slide planning for present:slides tasks |
```

The note about extension skills (line 200) should be updated to list `skill-slide-planning -> slide-planner-agent` as an example of a present extension skill (currently uses `skill-neovim-research` as the example, which is irrelevant to this repo's extensions).

### 2. Agents Table (lines 184–194)
**Issue**: `slide-planner-agent` is absent from the agents table.

**Required addition**:
```
| slide-planner-agent | Slide-by-slide plan generation from design feedback and research |
```

### 3. Agents README (.claude/agents/README.md)
**Issue**: The README lists 7 agents (core only) but `slide-planner-agent` is now installed as the 8th entry in the directory. The table needs a new row for `slide-planner-agent.md`.

### 4. Present Extension Section (lines 489–552)
**Issue**: The `skill-slide-planning` skill is documented in `.claude/skills/` but the Present Extension section in CLAUDE.md only mentions `skill-slides` for plan routing. The routing for `present:slides -> /plan` actually dispatches to `skill-slide-planning`, but this is invisible in the documentation.

The Present Extension's "Language Routing" table shows:
```
| present | slides | skill-slides | skill-slides | ...
```
But the implementation skill column is incorrect — `/plan` on a `present:slides` task routes to `skill-slide-planning`, not `skill-slides`. This is a **functional inaccuracy**, not just a missing entry.

### 5. Rules References Section (lines 214–222)
**Issue**: The `validate-plan-write.sh` hook is not mentioned anywhere in CLAUDE.md. Since this is a `PostToolUse` hook that enforces artifact format compliance, it represents a behavioral constraint agents must be aware of. It should be documented, either in the Rules References section or in a new "Hooks" section.

**Context**: The hook is registered in `settings.json` and validates writes to `specs/*/plans/*.md`, `specs/*/reports/*.md`, and `specs/*/summaries/*.md`. It calls `scripts/validate-artifact.sh` and returns `additionalContext` on validation failure. This is part of the enforceable system contract.

---

## README.md Updates Needed

The root `README.md` (at `/home/benjamin/.config/zed/README.md`) is accurate but **does not mention slide planning as a distinct interactive workflow**. The `/slides` command is listed under Grant Development, but the interactive planning behavior (5-stage Q&A before plan generation) is unique and noteworthy.

The README currently treats `/slides` as equivalent to other domain commands. A brief note distinguishing "research talk creation (interactive planning)" from other grant commands would help users understand what to expect when running `/plan` on a slides task.

**Specific change needed**: In the Claude Code Commands section, the `/slides` row description could note: "Create research talks; `/plan` triggers interactive 5-stage slide design review."

No other README changes are required.

---

## docs/ Directory Updates Needed

### docs/agent-system/commands.md
The commands.md catalog has a `/slides` entry but it needs to clarify that `/plan` on a slides task triggers the interactive slide-planner workflow (not the generic planner). Currently there is no hint that `/plan 55` (where task 55 is type `present:slides`) behaves differently from `/plan 10` (a generic task).

### docs/agent-system/README.md
The Extensions section (lines 56–64) describes the Present extension with:
> "research talks (`/slides`)"

This is accurate but incomplete: the present extension now includes a distinct planning agent (`slide-planner-agent`) invoked via `skill-slide-planning`. The Extensions section could add a sentence: "Slide planning uses an interactive 5-stage design review (`/plan` on slides tasks)."

No other docs/ files appear stale or inaccurate.

---

## New Capabilities to Document

### 1. `skill-slide-planning` + `slide-planner-agent`

These are the most significant undocumented capabilities. They represent a new **interactive planning workflow** specific to `present:slides` tasks:
- 5-stage Q&A (theme, narrative arc, include/exclude slides, per-slide refinement)
- Delegation to `slide-planner-agent` for slide-by-slide plan production
- Skill-internal postflight pattern (skill handles status update + commit, not the orchestrator)

**Documents that need updates**:
- `.claude/CLAUDE.md`: Skill-to-Agent table, Agents table, Present Extension routing table
- `.claude/agents/README.md`: Agents table
- `docs/agent-system/commands.md`: `/plan` and `/slides` entries
- `docs/agent-system/README.md`: Extensions section

### 2. `validate-plan-write.sh` Hook

A new `PostToolUse` hook that validates artifact writes against format standards. Intercepts all writes to `specs/*/plans/`, `specs/*/reports/`, and `specs/*/summaries/`, and returns corrective `additionalContext` if the artifact fails validation.

**Documents that need updates**:
- `.claude/CLAUDE.md`: New "Hooks" subsection (or addition to Rules References section)
- `docs/agent-system/architecture.md` (if it covers the hook system)

---

## Strategic Documentation Recommendations

### 1. Fix the functional inaccuracy in Present Extension routing (high priority)
The Language Routing table in the Present Extension section shows `skill-slides` as the implementation skill for `present:slides`, but `/plan` actually routes to `skill-slide-planning`. This is misleading and could cause agent routing errors. Fix this first.

### 2. Add a Hooks section to CLAUDE.md (medium priority)
The hooks system has grown to include 8+ hooks (log-session, post-command, subagent-postflight, tts-notify, validate-plan-write, validate-state-sync, wezterm-*). None are documented in CLAUDE.md. A brief Hooks section listing behaviorally significant hooks (those that affect agent output, not just UI notifications) would improve system transparency. At minimum, `validate-plan-write.sh` and `validate-state-sync.sh` should be documented as they have correctness implications.

### 3. Keep agents/README.md synchronized automatically (low priority)
The agents README currently lists only the 7 core agents and has drifted from the actual 30+ agents in the directory (all extension agents are in the flat directory but only core ones are in the README). This is a known pattern — the README covers core agents; extensions are documented in CLAUDE.md. This is acceptable as a design choice, but should be made explicit: add a note to `agents/README.md` stating that extension-specific agents are documented in `.claude/CLAUDE.md` extension sections.

### 4. Add `/plan` behavior note for slides to grant-development workflow doc (low priority)
`docs/workflows/grant-development.md` likely covers `/slides` as a workflow. If it shows the standard `/research` -> `/plan` -> `/implement` lifecycle, it should clarify that `/plan` triggers interactive design review rather than the standard planning flow. This prevents user confusion when the command behaves unexpectedly.

---

## Confidence Level: **high**

The analysis is based on direct file inspection of:
- `.claude/CLAUDE.md` (full read)
- `.claude/agents/` directory listing + README
- `.claude/skills/skill-slide-planning/SKILL.md` (full read)
- `.claude/agents/slide-planner-agent.md` (partial read)
- `.claude/hooks/validate-plan-write.sh` (full read)
- `.claude/settings.json` (hooks section)
- `.claude/extensions.json` (references to new capabilities)
- `README.md` (full read)
- `docs/README.md`, `docs/agent-system/README.md`, `docs/agent-system/commands.md` (partial reads)
- `docs/workflows/README.md` (full read)

The three undocumented capabilities (slide-planner-agent, skill-slide-planning, validate-plan-write hook) were confirmed to exist in files but absent from all documentation files checked.
