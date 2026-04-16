# Implementation Plan: Self-Learning Memory System

- **Task**: 68 - Self-learning memory system
- **Status**: [NOT STARTED]
- **Effort**: 7 hours
- **Dependencies**: None
- **Research Inputs**: specs/068_self_learning_memory_system/reports/01_team-research.md
- **Artifacts**: plans/01_memory-system-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
  - .claude/context/workflows/task-breakdown.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The current memory system is entirely user-driven: `/learn` for capture, `--remember` on `/research` for retrieval. This plan implements automatic retrieval (making `--remember` the default) and friction-reduced capture (agents emit memory candidates in return metadata, `/todo` presents batch review with pre-classification). Two hard architectural constraints shape the design: postflight restrictions prohibit memory writes during GATE OUT, and skill-memory's mandatory interactive requirement prevents fully autonomous writes. The system is done when memories are automatically injected into research/plan/implement operations and when `/todo` presents pre-classified memory candidates from completed tasks for one-click batch approval.

### Research Integration

Team research (4 teammates) confirmed:
- Postflight is the wrong location for memory capture (prohibited operations)
- `/todo` HarvestMemories (Stage 7) is the natural batch capture checkpoint
- Auto-retrieval is technically simpler and lower risk than auto-capture
- AUDN deduplication pattern (ADD/UPDATE/DELETE/NOOP) should govern writes
- Verification-at-retrieval preferred over time-based decay
- Target vault size: 50-200 curated memories
- Prior art (Generative Agents, Reflexion, Mem0, GitHub Copilot) converges on checkpoint-based capture with composite scoring

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items found (roadmap is empty placeholder).

## Goals & Non-Goals

**Goals**:
- Make memory retrieval automatic for all `/research`, `/plan`, and `/implement` operations (no `--remember` flag needed)
- Enable agents to emit structured memory candidates in return metadata
- Upgrade `/todo` HarvestMemories to present pre-classified batch review with one AskUserQuestion
- Add `retrieval_count` and `last_retrieved` fields to memory frontmatter for natural decay tracking
- Add passive Stop hook nudge for memory capture awareness

**Non-Goals**:
- Fully autonomous memory writes (violates mandatory interactive requirement)
- Embedding-based semantic search (vault is small enough for keyword/grep matching)
- Memory expiration or automatic deletion (premature for current vault size)
- Modifying postflight-tool-restrictions standard
- Time-based decay scoring (verification-at-retrieval is preferred for code repos)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Memory bloat from low-quality candidates | H | M | Three-tier classification gates Tier 1 items as pre-selected, Tier 3 as hidden; user confirms all |
| Stale memories injecting false context | H | L | Add `retrieval_count`/`last_retrieved` frontmatter; low-retrieval memories flagged during `/todo` |
| Auto-retrieval increasing token cost | M | M | Budget injection to top-3 memories, cap at 2000 tokens; `--no-remember` opt-out |
| Circular learning (mistakes becoming patterns) | H | L | All captures require user confirmation; no autonomous writes |
| Skill-memory interactive requirement conflict | H | M | New `autonomous-capture` code path in skill-todo, separate from skill-memory's interactive path |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4, 5 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Auto-Retrieval -- Make --remember Default [NOT STARTED]

**Goal**: Memory retrieval becomes automatic for all research, planning, and implementation operations without requiring the `--remember` flag.

**Tasks**:
- [ ] Modify `skill-researcher/SKILL.md` Stage 4 (Prepare Delegation Context): add memory retrieval step that greps `.memory/10-Memories/*.md` frontmatter `topic:` and `tags:` fields against task description keywords, injecting top-3 matching memory file paths into delegation context
- [ ] Add `--no-remember` flag handling to skill-researcher: when present, skip memory injection
- [ ] Update skill-researcher Stage 5 prompt template to include a `<memory-context>` block with injected memory content (read each matched file, truncate to 500 tokens each, cap total at 1500 tokens)
- [ ] Add same memory retrieval step to `skill-planner/SKILL.md` Stage 1 (Parse Delegation Context): grep memory vault for task-relevant memories, inject into planner-agent prompt
- [ ] Add same memory retrieval step to `skill-implementer/SKILL.md` delegation context preparation
- [ ] Update CLAUDE.md Memory Extension section: document that `--remember` is now default, add `--no-remember` documentation
- [ ] Remove `--remember` flag logic from skill-researcher (it is now always-on)

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md` - Add memory injection to Stage 4, remove --remember conditional
- `.claude/skills/skill-planner/SKILL.md` - Add memory injection to delegation context
- `.claude/skills/skill-implementer/SKILL.md` - Add memory injection to delegation context
- `.claude/CLAUDE.md` - Update Memory Extension documentation

**Verification**:
- Running `/research N` without `--remember` flag still injects relevant memories
- Running `/research N --no-remember` skips memory injection
- Memory injection is bounded (max 3 files, max 1500 tokens)

---

### Phase 2: Memory Candidate Schema in Return Metadata [NOT STARTED]

**Goal**: Extend the return metadata schema so agents can emit structured memory candidates alongside their normal output. No memory writes occur -- candidates are stored as data in `.return-meta.json` for later processing.

**Tasks**:
- [ ] Add `memory_candidates` array schema to `return-metadata-file.md` with fields: `content` (string, max 300 tokens), `category` (enum: TECHNIQUE|PATTERN|CONFIG|WORKFLOW|INSIGHT), `source_artifact` (path string), `confidence` (float 0-1)
- [ ] Update `general-research-agent.md` to emit 0-3 memory candidates in return metadata when novel findings are discovered (key research findings, not task-specific details)
- [ ] Update `general-implementation-agent.md` to emit 0-3 memory candidates for reusable patterns, configuration discoveries, or workflow insights found during implementation
- [ ] Update `planner-agent.md` to emit 0-1 memory candidates when planning reveals architectural patterns or dependency insights worth preserving
- [ ] Add memory_candidates to the completion_data schema in state.json (agents write to .return-meta.json; skills propagate to state.json during postflight)
- [ ] Update skill-researcher postflight (Stage 7) to propagate `memory_candidates` from `.return-meta.json` to state.json task entry
- [ ] Update skill-implementer postflight to propagate `memory_candidates` from `.return-meta.json` to state.json task entry

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `.claude/context/formats/return-metadata-file.md` - Add memory_candidates schema
- `.claude/agents/general-research-agent.md` - Add memory candidate emission instructions
- `.claude/agents/general-implementation-agent.md` - Add memory candidate emission instructions
- `.claude/agents/planner-agent.md` - Add memory candidate emission instructions
- `.claude/skills/skill-researcher/SKILL.md` - Propagate memory_candidates in postflight
- `.claude/skills/skill-implementer/SKILL.md` - Propagate memory_candidates in postflight

**Verification**:
- After `/research N`, `.return-meta.json` contains `memory_candidates` array (may be empty)
- After `/implement N`, state.json task entry has `memory_candidates` field propagated from metadata
- Each candidate has all required fields (content, category, source_artifact, confidence)

---

### Phase 3: Memory Frontmatter Enhancement [NOT STARTED]

**Goal**: Add retrieval tracking fields to memory files and update the memory template so new memories include these fields. This enables natural decay tracking (frequently retrieved memories are reinforced; unused ones become archival candidates).

**Tasks**:
- [ ] Update `.memory/30-Templates/memory-template.md` to include `retrieval_count: 0` and `last_retrieved: null` frontmatter fields
- [ ] Add `retrieval_count` and `last_retrieved` fields to existing memory files in `.memory/10-Memories/` (backfill with `retrieval_count: 0` and `last_retrieved: null`)
- [ ] Update skill-memory CREATE operation template to include the new frontmatter fields
- [ ] Update the memory retrieval code added in Phase 1: when a memory file is injected into agent context, increment `retrieval_count` and set `last_retrieved` to current date in that file's frontmatter
- [ ] Update `.memory/20-Indices/index.md` to note retrieval tracking fields in the schema documentation

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `.memory/30-Templates/memory-template.md` - Add retrieval_count, last_retrieved fields
- `.memory/10-Memories/MEM-*.md` (all existing files) - Backfill new frontmatter fields
- `.claude/skills/skill-memory/SKILL.md` - Update CREATE template
- `.claude/skills/skill-researcher/SKILL.md` - Add retrieval count increment after injection
- `.memory/20-Indices/index.md` - Document new fields

**Verification**:
- All existing memory files have `retrieval_count` and `last_retrieved` in frontmatter
- After a `/research` run that injects memories, the injected memory files have incremented `retrieval_count` and updated `last_retrieved`
- New memories created via `/learn` include the fields with initial values

---

### Phase 4: Enhanced /todo HarvestMemories with Pre-Classification [NOT STARTED]

**Goal**: Upgrade `/todo` Stage 7 (HarvestMemories) to collect memory candidates from completed task metadata, apply three-tier pre-classification, and present a single batch AskUserQuestion for user approval. Approved memories are created using a new autonomous code path (not skill-memory's interactive path).

**Tasks**:
- [ ] Modify `skill-todo/SKILL.md` Stage 7 to collect `memory_candidates` from state.json for each completed task being archived
- [ ] Implement three-tier pre-classification logic in Stage 7:
  - Tier 1 (pre-selected): PATTERN or CONFIG category with confidence >= 0.8
  - Tier 2 (presented, not pre-selected): WORKFLOW or TECHNIQUE with confidence >= 0.5
  - Tier 3 (hidden by default): INSIGHT or confidence < 0.5
- [ ] Add deduplication step: for each candidate, grep `.memory/10-Memories/*.md` for key terms; if overlap > 60%, mark as potential UPDATE instead of CREATE; if overlap > 90%, mark as NOOP and exclude
- [ ] Modify Stage 9 (InteractivePrompts) memory harvest section: present pre-classified candidates in a single AskUserQuestion with Tier 1 pre-selected, Tier 2 as options, Tier 3 hidden (shown only if user requests)
- [ ] Modify Stage 14 (CreateMemories): implement autonomous memory creation for approved candidates -- write MEM-{slug}.md files directly (bypassing skill-memory's per-segment interactive flow) with proper frontmatter including `retrieval_count: 0` and `last_retrieved: null`
- [ ] Ensure Stage 14 runs index regeneration after creating memories (reuse the idempotent index regeneration pattern from skill-memory)

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `.claude/skills/skill-todo/SKILL.md` - Stages 7, 9, and 14 modifications

**Verification**:
- `/todo` with completed tasks shows pre-classified memory candidates
- Tier 1 items appear pre-selected in the AskUserQuestion
- Approved memories are created in `.memory/10-Memories/` with correct frontmatter
- Index is regenerated after memory creation
- No duplicate memories created for candidates with >90% overlap

---

### Phase 5: Passive Stop Hook Nudge [NOT STARTED]

**Goal**: Add a lightweight Stop hook that detects completed lifecycle operations and prints a one-line reminder about memory capture, increasing user awareness without any writes or state changes.

**Tasks**:
- [ ] Create `.claude/hooks/memory-nudge.sh` script that:
  - Checks if the just-completed response involved `/research`, `/implement`, or `/plan` completion
  - If yes, prints: `Memory: artifacts available for /learn --task N`
  - Uses only echo (no file writes, no MCP calls, no state changes)
  - Is idempotent and non-blocking
- [ ] Add Stop hook entry to `.claude/settings.json` hooks array referencing the new script
- [ ] Test that the hook fires after lifecycle command completion and does not fire for non-lifecycle operations

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `.claude/hooks/memory-nudge.sh` (new file) - Passive nudge script
- `.claude/settings.json` - Add Stop hook entry

**Verification**:
- After `/research N` completes, a one-line memory nudge appears
- After a normal conversation (no lifecycle command), no nudge appears
- The hook makes no file writes and no MCP calls
- The hook does not block or slow down normal operations

---

## Testing & Validation

- [ ] Run `/research N` on a test task and verify memories are automatically injected into the agent context (no `--remember` flag)
- [ ] Run `/research N --no-remember` and verify no memories are injected
- [ ] Complete a research and implementation cycle, then run `/todo` and verify memory candidates appear with pre-classification
- [ ] Approve memory candidates in `/todo` and verify MEM-*.md files are created with correct frontmatter (including retrieval_count, last_retrieved)
- [ ] Verify that after retrieval, memory files have incremented retrieval_count
- [ ] Check that the Stop hook fires only after lifecycle command completion
- [ ] Verify vault remains under 50 files after typical usage (no bloat from auto-capture)

## Artifacts & Outputs

- `specs/068_self_learning_memory_system/plans/01_memory-system-plan.md` (this file)
- Modified skills: skill-researcher, skill-planner, skill-implementer, skill-todo, skill-memory
- Modified agents: general-research-agent, general-implementation-agent, planner-agent
- Modified formats: return-metadata-file.md
- New file: `.claude/hooks/memory-nudge.sh`
- Modified config: `.claude/settings.json`
- Updated documentation: `.claude/CLAUDE.md`

## Rollback/Contingency

All changes are to `.claude/` configuration files and `.memory/` templates. Rollback via `git revert` of the implementation commit(s). The system degrades gracefully:
- If auto-retrieval causes token bloat, add `--no-remember` flag and revert to opt-in
- If memory candidates produce noise, remove `memory_candidates` emission from agent definitions
- If the Stop hook is annoying, remove its entry from `settings.json`
- Memory frontmatter backfill is additive (extra fields) and does not break existing functionality
