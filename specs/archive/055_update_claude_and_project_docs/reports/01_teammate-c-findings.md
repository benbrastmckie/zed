# Teammate C: Documentation Gaps and Risk Analysis

**Task**: 55 - Update CLAUDE.md and project docs
**Role**: Critic
**Date**: 2026-04-13

---

## Key Findings

The documentation update scope covers 48 files changed in `.claude/` across agents, commands, skills, context patterns, extensions, and settings. The main `.claude/CLAUDE.md` file was NOT updated (zero diff) despite multiple new components being added. Three entirely new components (one agent, one skill directory, one hook) have no documentation coverage anywhere in the project.

---

## Undocumented New Files

### 1. `slide-planner-agent.md` (new agent)
- Present in `.claude/agents/` but absent from `.claude/agents/README.md`
- Agents README only lists 7 core agents; actual directory has 29 agents (the README has always been stale, but slide-planner-agent is the newest unmentioned)
- Not listed in `.claude/CLAUDE.md`'s Agents table (which correctly says extension agents are added when loaded, but does NOT say /plan on present:slides routes to this agent)
- The Present Extension section in CLAUDE.md lists `skill-slides -> slides-research-agent / pptx-assembly-agent / slidev-assembly-agent` but omits `skill-slide-planning -> slide-planner-agent`

### 2. `skill-slide-planning/` (new skill directory)
- Present in `.claude/skills/` and correctly registered in `extensions.json`
- NOT mentioned in `.claude/CLAUDE.md`'s Present Extension Skill-Agent Mapping table
- The CLAUDE.md Present Extension section still shows `skill-slides` for both research AND implementation of slides tasks (line ~532), but the actual routing now is: `/research` -> `skill-slides`, `/plan` -> `skill-slide-planning`
- The user-facing `docs/agent-system/commands.md` mentions `/slides` and `/plan` but has no description of the interactive 5-stage Q&A that now runs on `/plan` for slide tasks
- No workflow doc exists for the slides `/plan` interactive flow

### 3. `.claude/hooks/validate-plan-write.sh` (new hook)
- New PostToolUse hook registered in `settings.json` (confirmed by git diff)
- No documentation anywhere: not in CLAUDE.md, not in docs/, not in any hooks README
- The hook fires on every Write|Edit tool call and validates artifact paths against format standards -- a significant behavioral change agents need to know about
- No mention of what validation it performs or how agents should interpret its `additionalContext` output

### 4. `.claude/context/patterns/artifact-linking-todo.md` (new context pattern)
- IS indexed in `context/index.json` with `"always": true` -- this is correct
- IS referenced by `skill-slide-planning/SKILL.md` -- correct
- NOT mentioned in CLAUDE.md or any agent documentation
- Skills that already have inline four-case artifact linking logic (researcher, planner, implementer, etc.) may not know to defer to this canonical pattern; the CLAUDE.md has no pointer to it

---

## Broken or Stale Cross-References

### 1. slides.md output inconsistency: "Task Type: present" vs "present:slides"
In `.claude/commands/slides.md`, the Task Creation Success output format still says:
```
Task Type: present
```
...even though the task_type was changed to `present:slides` everywhere else in the file. This is a stale remnant from the diff that didn't get cleaned up (visible in the diff: lines showing both old and new).

### 2. CLAUDE.md Present Extension routing table is stale
The CLAUDE.md language routing table (Present Extension section) shows:
```
present | slides | skill-slides | skill-slides | ...
```
But `/plan` for `present:slides` tasks now routes to `skill-slide-planning`, not `skill-slides`. The Implementation Skill column for `slides` rows is incorrect.

### 3. Agents README is severely outdated
`.claude/agents/README.md` lists only 7 agents. The directory contains 29. The README explicitly lists only "core" agents, but it doesn't acknowledge that 22 additional extension agents exist, which creates a false impression of the system's scope.

### 4. git-workflow.md contains stale Co-Authored-By trailer
`.claude/rules/git-workflow.md` still says:
```
Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```
But CLAUDE.md itself says per user preference this trailer should be omitted entirely. The rules file contradicts the CLAUDE.md note about user preference.

---

## Missing Documentation

### 1. No documentation for the interactive /plan flow for slides
The new `skill-slide-planning` introduces a 5-stage interactive Q&A when `/plan` is run on a `present:slides` task:
- Stage 1: Theme selection (5 options + custom)
- Stage 2: Narrative arc review
- Stage 3: Slide picker (include/exclude)
- Stage 4: Per-slide feedback

This is a significant UX change that users will encounter. It is not described anywhere in:
- `docs/agent-system/commands.md` (only `/plan` basics)
- `docs/workflows/grant-development.md` (says `/plan 42  # design slide structure` with no further context)
- `README.md` (no mention of interactive planning for slides)

### 2. No hook documentation
There is no hooks README or hooks section in CLAUDE.md. Currently `.claude/hooks/` contains 10 shell scripts. The `validate-plan-write.sh` hook is new but undocumented. What happens when it returns a non-empty `additionalContext`? How does this affect agent behavior? This is not documented.

### 3. settings.json changes not reflected in docs
The `settings.json` diff adds a new PostToolUse hook for Write|Edit calls. This is a system-wide behavior change. No docs reference this.

### 4. Phase Checkpoint Protocol removal not documented
Multiple agents had their Phase Checkpoint Protocol sections removed (python-implementation-agent confirmed; PORT.md indicates epi-implement-agent, pptx-assembly-agent, slidev-assembly-agent also affected). This simplifies the commit model but the change is nowhere documented -- agents/README.md doesn't describe commit model at all.

---

## Blind Spots in Update Scope

### 1. The update doesn't touch CLAUDE.md at all
The git diff shows zero changes to `.claude/CLAUDE.md`. Yet at least 4 things changed that CLAUDE.md should reflect:
- `skill-slide-planning` + `slide-planner-agent` added to Present Extension section
- `validate-plan-write.sh` hook added
- `artifact-linking-todo.md` pattern added (should be referenced)
- `present:slides` routing now splits between research and plan skills

### 2. No validation that extensions.json is consistent with actual files
The diff to `extensions.json` is large (763 lines changed). Extensions.json references file paths. Nobody has verified these paths still exist post-change. Example: `extensions.json` references `python-implementation-agent.md` at line 462 -- this file still exists but had content removed. But untracked files like `.claude_OLD/` suggest a major reload happened; stale paths could exist.

### 3. Untracked `.claude_OLD/` directory could cause confusion
A `.claude_OLD/` directory exists (untracked). Its presence alongside `.claude/` will confuse future readers of git history. It's also not clear if it should be deleted or kept for reference. The task description doesn't address this.

### 4. `context/index.json.backup` is tracked but shouldn't be
`context/index.json.backup` is a tracked file with modifications. Backup files in version control are a maintenance liability -- they will continually show up in diffs without providing value.

### 5. Assumption: docs/ is out of scope for this update
No changes were made to `docs/`. The research team may have assumed docs/ doesn't need updating because it covers user-facing workflows. But the new interactive slide-planning flow IS a user-facing change that `docs/workflows/grant-development.md` currently misrepresents (says `/plan 42 # design slide structure` as if it's the generic planner).

---

## Confidence Level

**High** on items 1-3 under Undocumented New Files (confirmed by direct grep/diff inspection).

**High** on CLAUDE.md not being updated (confirmed by zero diff).

**High** on the slides.md "Task Type: present" stale output format (confirmed by diff content).

**Medium** on extensions.json path validation (would require enumerating all referenced paths).

**Medium** on the Phase Checkpoint Protocol removal scope (PORT.md mentions 3 agents; only python-implementation-agent was confirmed directly).

**Low** on whether the absence of docs/ updates is intentional or an oversight (team may have scoped docs separately).
