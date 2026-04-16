# Implementation Plan: Self-Learning Memory System

- **Task**: 68 - Self-learning memory system
- **Status**: [COMPLETED]
- **Effort**: 9 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/068_self_learning_memory_system/reports/01_team-research.md
  - specs/068_self_learning_memory_system/reports/02_memory-index-design.md
- **Artifacts**: plans/02_memory-system-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
  - .claude/context/workflows/task-breakdown.md
- **Type**: meta

## Overview

The current memory system is entirely user-driven: `/learn` for capture, `--remember` on `/research` for retrieval. This plan implements automatic retrieval (making `--remember` the default) and friction-reduced capture (agents emit memory candidates in return metadata, `/todo` presents batch review with pre-classification). Round 2 research on memory index design revealed that the original plan's grep-based frontmatter matching is insufficient for relevance scoring and token budgeting. The revised approach adds a foundational Phase 0 to create a JSON manifest (`memory-index.json`) modeled on the proven `context/index.json` pattern, enabling two-phase retrieval: cheap index scan for candidate scoring, then selective file reads for top-K matches. The system is done when memories are automatically injected into research/plan/implement operations via index-based scoring, and when `/todo` presents pre-classified memory candidates from completed tasks for one-click batch approval.

### Research Integration

**Round 1** (team research, 4 teammates): Established architectural constraints (postflight prohibition, interactive requirement), recommended `/todo` as batch capture checkpoint, confirmed auto-retrieval as lower-risk starting point, identified AUDN deduplication and verification-at-retrieval patterns.

**Round 2** (memory index design): Designed JSON manifest schema for two-phase retrieval, defined keyword overlap scoring algorithm, compared four approaches (JSON manifest, hierarchical markdown, embeddings, hybrid), recommended regenerate-on-write + validate-on-read synchronization, projected token costs (400-13K depending on vault size).

Reports integrated:
- `reports/01_team-research.md` (v1)
- `reports/02_memory-index-design.md` (v2)

### Prior Plan Reference

Revises `plans/01_memory-system-plan.md`. Changes: added Phase 0 (memory index generation), restructured Phase 1 to use two-phase retrieval via JSON manifest instead of grep-based frontmatter matching, increased token budget from 1500 to 3000, merged frontmatter enhancement into Phase 0, updated dependency graph.

### Roadmap Alignment

No ROADMAP.md items found (roadmap is empty placeholder).

## Goals & Non-Goals

**Goals**:
- Create a machine-queryable memory index (`memory-index.json`) with per-entry metadata for scoring
- Make memory retrieval automatic for all `/research`, `/plan`, and `/implement` operations via two-phase retrieval (index scan + selective file read)
- Enable agents to emit structured memory candidates in return metadata
- Upgrade `/todo` HarvestMemories to present pre-classified batch review with one AskUserQuestion
- Track retrieval statistics (retrieval_count, last_retrieved) in both index and memory frontmatter for natural decay
- Add passive Stop hook nudge for memory capture awareness

**Non-Goals**:
- Fully autonomous memory writes (violates mandatory interactive requirement)
- Embedding-based semantic search (vault is small enough for keyword/JSON matching)
- Memory expiration or automatic deletion (premature for current vault size)
- Modifying postflight-tool-restrictions standard
- Time-based decay scoring (verification-at-retrieval is preferred for code repos)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Memory bloat from low-quality candidates | H | M | Three-tier classification gates Tier 1 items as pre-selected, Tier 3 as hidden; user confirms all |
| Stale memories injecting false context | H | L | Retrieval stats in index enable natural decay; low-retrieval memories flagged during `/todo` |
| Auto-retrieval increasing token cost | M | M | Two-phase retrieval limits injection to top-5 memories, capped at 3000 tokens; `--no-remember` opt-out |
| Keyword matching misses relevant memories | M | M | Keywords + topic + summary fields provide 80% of embedding quality; grep fallback available as future enhancement |
| Index drift from manual file edits | M | L | Validate-on-read detects mismatch and triggers regeneration before scoring |
| Circular learning (mistakes becoming patterns) | H | L | All captures require user confirmation; no autonomous writes |
| Skill-memory interactive requirement conflict | H | M | New `autonomous-capture` code path in skill-todo, separate from skill-memory's interactive path |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5, 6 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Memory Index Infrastructure [COMPLETED]

**Goal**: Create the `memory-index.json` manifest and integrate its generation into the existing `/learn` index regeneration workflow. Simultaneously enhance memory frontmatter with retrieval tracking fields and keywords.

**Tasks**:
- [ ] Define `memory-index.json` schema in `.memory/memory-index.json` with fields: version, generated_at, entry_count, total_tokens, entries array
- [ ] Per-entry schema: id, path, title, summary (one-line), topic, category, keywords (array), token_count, created, modified, last_retrieved, retrieval_count
- [ ] Write index generation logic in `skill-memory/SKILL.md` as part of the existing "Index Regeneration Pattern": scan `.memory/10-Memories/MEM-*.md`, extract frontmatter fields, compute token count (word count * 1.3), extract keywords from body (top 8 by frequency excluding stop words), build JSON entries, write `memory-index.json`
- [ ] Update `.memory/30-Templates/memory-template.md` to include `retrieval_count: 0`, `last_retrieved: null`, `keywords: []`, and `summary: ""` frontmatter fields
- [ ] Backfill existing memory files in `.memory/10-Memories/` with new frontmatter fields (retrieval_count: 0, last_retrieved: null, keywords from tags, summary from first content sentence)
- [ ] Update skill-memory CREATE operation template to include the new frontmatter fields
- [ ] Add validate-on-read logic: before using the index, check all listed files exist and no unlisted MEM-*.md files are present; if mismatch, regenerate
- [ ] Generate the initial `memory-index.json` from current vault state
- [ ] Update `.memory/20-Indices/index.md` to document the new JSON index and retrieval tracking fields

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `.memory/memory-index.json` (new file) - Machine-queryable memory index
- `.claude/skills/skill-memory/SKILL.md` - Add JSON index generation to regeneration step
- `.memory/30-Templates/memory-template.md` - Add retrieval_count, last_retrieved, keywords, summary
- `.memory/10-Memories/MEM-*.md` (all existing files) - Backfill new frontmatter fields
- `.memory/20-Indices/index.md` - Document new index and fields

**Verification**:
- `memory-index.json` exists and is valid JSON with all required per-entry fields
- All existing memory files have new frontmatter fields
- Running `/learn` regenerates `memory-index.json` alongside `index.md`
- Validate-on-read detects when a memory file is added/removed without index update

---

### Phase 2: Two-Phase Auto-Retrieval [COMPLETED]

**Goal**: Memory retrieval becomes automatic for all research, planning, and implementation operations using two-phase retrieval: score the JSON index to select top-K candidates, then read only selected memory files into context.

**Tasks**:
- [ ] Implement two-phase retrieval pattern in `skill-researcher/SKILL.md` Stage 4 (Prepare Delegation Context):
  - Phase 1 (Score): Read `memory-index.json`, extract keywords from task description, score each entry using: `0.5 * keyword_overlap + 0.3 * topic_match + 0.2 * recency_bonus`, select top-K where score > 0.2 (K = min(5, entries above threshold)), budget check: sum(selected.token_count) < 3000 tokens
  - Phase 2 (Retrieve): Read each selected memory file, inject into delegation context as `<memory-context>` block
  - Update: increment `retrieval_count` and set `last_retrieved` to current date in `memory-index.json` for retrieved entries
- [ ] Add `--no-remember` flag handling to skill-researcher: when present, skip memory retrieval entirely
- [ ] Remove `--remember` flag logic from skill-researcher (retrieval is now always-on)
- [ ] Add same two-phase retrieval pattern to `skill-planner/SKILL.md` Stage 1 (Parse Delegation Context)
- [ ] Add same two-phase retrieval pattern to `skill-implementer/SKILL.md` delegation context preparation
- [ ] Update memory file frontmatter on retrieval: when a memory is injected, also update that file's YAML frontmatter `retrieval_count` and `last_retrieved` fields to stay in sync with the index
- [ ] Update CLAUDE.md Memory Extension section: document that `--remember` is now default, add `--no-remember` documentation, document the two-phase retrieval mechanism

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `.claude/skills/skill-researcher/SKILL.md` - Two-phase retrieval in Stage 4, remove --remember conditional
- `.claude/skills/skill-planner/SKILL.md` - Two-phase retrieval in delegation context
- `.claude/skills/skill-implementer/SKILL.md` - Two-phase retrieval in delegation context
- `.memory/memory-index.json` - Updated at retrieval time (retrieval stats)
- `.claude/CLAUDE.md` - Update Memory Extension documentation

**Verification**:
- Running `/research N` without `--remember` flag injects relevant memories via index scoring
- Running `/research N --no-remember` skips memory retrieval
- Memory injection is bounded (max 5 files, max 3000 tokens)
- After retrieval, `memory-index.json` shows updated retrieval_count and last_retrieved for injected memories
- Memory file frontmatter stays in sync with index retrieval stats

---

### Phase 3: Memory Candidate Schema in Return Metadata [COMPLETED]

**Goal**: Extend the return metadata schema so agents can emit structured memory candidates alongside their normal output. No memory writes occur -- candidates are stored as data in `.return-meta.json` for later processing by `/todo`.

**Tasks**:
- [ ] Add `memory_candidates` array schema to `return-metadata-file.md` with fields: `content` (string, max 300 tokens), `category` (enum: TECHNIQUE|PATTERN|CONFIG|WORKFLOW|INSIGHT), `source_artifact` (path string), `confidence` (float 0-1), `suggested_keywords` (array of strings for index entry)
- [ ] Update `general-research-agent.md` to emit 0-3 memory candidates in return metadata when novel findings are discovered (key research findings, not task-specific details)
- [ ] Update `general-implementation-agent.md` to emit 0-3 memory candidates for reusable patterns, configuration discoveries, or workflow insights found during implementation
- [ ] Update `planner-agent.md` to emit 0-1 memory candidates when planning reveals architectural patterns or dependency insights worth preserving
- [ ] Add memory_candidates to the completion_data schema in state.json (agents write to .return-meta.json; skills propagate to state.json during postflight)
- [ ] Update skill-researcher postflight (Stage 7) to propagate `memory_candidates` from `.return-meta.json` to state.json task entry
- [ ] Update skill-implementer postflight to propagate `memory_candidates` from `.return-meta.json` to state.json task entry

**Timing**: 2 hours

**Depends on**: 2

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
- Each candidate has all required fields (content, category, source_artifact, confidence, suggested_keywords)

---

### Phase 4: Enhanced /todo HarvestMemories with Pre-Classification [COMPLETED]

**Goal**: Upgrade `/todo` Stage 7 (HarvestMemories) to collect memory candidates from completed task metadata, apply three-tier pre-classification, and present a single batch AskUserQuestion for user approval. Approved memories are created using a new autonomous code path with proper index regeneration.

**Tasks**:
- [ ] Modify `skill-todo/SKILL.md` Stage 7 to collect `memory_candidates` from state.json for each completed task being archived
- [ ] Implement three-tier pre-classification logic in Stage 7:
  - Tier 1 (pre-selected): PATTERN or CONFIG category with confidence >= 0.8
  - Tier 2 (presented, not pre-selected): WORKFLOW or TECHNIQUE with confidence >= 0.5
  - Tier 3 (hidden by default): INSIGHT or confidence < 0.5
- [ ] Add deduplication step: for each candidate, query `memory-index.json` keywords for overlap; if keyword overlap > 60%, mark as potential UPDATE instead of CREATE; if overlap > 90%, mark as NOOP and exclude
- [ ] Modify Stage 9 (InteractivePrompts) memory harvest section: present pre-classified candidates in a single AskUserQuestion with Tier 1 pre-selected, Tier 2 as options, Tier 3 hidden (shown only if user requests)
- [ ] Modify Stage 14 (CreateMemories): implement autonomous memory creation for approved candidates -- write MEM-{slug}.md files directly (bypassing skill-memory's per-segment interactive flow) with proper frontmatter including retrieval_count: 0, last_retrieved: null, keywords from suggested_keywords, and summary
- [ ] Ensure Stage 14 regenerates `memory-index.json` after creating memories (reuse the index regeneration pattern from Phase 1)

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `.claude/skills/skill-todo/SKILL.md` - Stages 7, 9, and 14 modifications

**Verification**:
- `/todo` with completed tasks shows pre-classified memory candidates
- Tier 1 items appear pre-selected in the AskUserQuestion
- Approved memories are created in `.memory/10-Memories/` with correct frontmatter including keywords and summary
- `memory-index.json` is regenerated after memory creation
- No duplicate memories created for candidates with >90% keyword overlap in index

---

### Phase 5: Passive Stop Hook Nudge [COMPLETED]

**Goal**: Add a lightweight Stop hook that detects completed lifecycle operations and prints a one-line reminder about memory capture, increasing user awareness without any writes or state changes.

**Tasks**:
- [ ] Create `.claude/hooks/memory-nudge.sh` script that:
  - Checks if the just-completed response involved `/research`, `/implement`, or `/plan` completion
  - If yes, prints: `Memory: artifacts available for /learn --task N`
  - Uses only echo (no file writes, no MCP calls, no state changes)
  - Is idempotent and non-blocking
- [ ] Add Stop hook entry to `.claude/settings.json` hooks array referencing the new script
- [ ] Test that the hook fires after lifecycle command completion and does not fire for non-lifecycle operations

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- `.claude/hooks/memory-nudge.sh` (new file) - Passive nudge script
- `.claude/settings.json` - Add Stop hook entry

**Verification**:
- After `/research N` completes, a one-line memory nudge appears
- After a normal conversation (no lifecycle command), no nudge appears
- The hook makes no file writes and no MCP calls
- The hook does not block or slow down normal operations

---

### Phase 6: Documentation and Integration Testing [COMPLETED]

**Goal**: Ensure all components work together end-to-end and documentation reflects the complete system.

**Tasks**:
- [ ] Update `.claude/CLAUDE.md` Memory Extension section with complete documentation: memory-index.json schema, two-phase retrieval, auto-retrieval default, --no-remember opt-out, memory candidate emission, /todo harvest workflow
- [ ] Add `/memory --reindex` documentation: force-regenerate `memory-index.json` from filesystem state for manual recovery
- [ ] Run end-to-end validation: `/research N` -> verify index-based memory injection -> `/implement N` -> verify memory candidates emitted -> `/todo` -> verify harvest with pre-classification
- [ ] Verify retrieval statistics accumulate correctly across multiple operations
- [ ] Verify vault stays under 50 files after typical usage cycle

**Timing**: 1 hour

**Depends on**: 4, 5

**Files to modify**:
- `.claude/CLAUDE.md` - Complete Memory Extension documentation update

**Verification**:
- All documentation sections are accurate and complete
- End-to-end workflow produces expected results at each stage
- Retrieval_count increments correctly across multiple /research runs
- Memory-index.json regenerates correctly after /learn operations

---

## Testing & Validation

- [ ] Run `/research N` on a test task and verify memories are automatically injected via index-based two-phase retrieval (no `--remember` flag)
- [ ] Run `/research N --no-remember` and verify no memories are injected
- [ ] Verify `memory-index.json` is valid JSON with all required fields after initial generation
- [ ] Verify validate-on-read detects stale index (add a memory file without running /learn, then trigger retrieval)
- [ ] Complete a research and implementation cycle, then run `/todo` and verify memory candidates appear with pre-classification
- [ ] Approve memory candidates in `/todo` and verify MEM-*.md files are created with correct frontmatter (including retrieval_count, last_retrieved, keywords, summary)
- [ ] Verify that after retrieval, both `memory-index.json` and memory file frontmatter show updated retrieval stats
- [ ] Check that the Stop hook fires only after lifecycle command completion
- [ ] Verify vault remains under 50 files after typical usage (no bloat from auto-capture)
- [ ] Verify token budget enforcement: injected memories never exceed 3000 tokens total

## Artifacts & Outputs

- `specs/068_self_learning_memory_system/plans/02_memory-system-plan.md` (this file)
- `.memory/memory-index.json` (new file) - Machine-queryable memory index
- `.claude/hooks/memory-nudge.sh` (new file) - Passive Stop hook nudge script
- Modified skills: skill-researcher, skill-planner, skill-implementer, skill-todo, skill-memory
- Modified agents: general-research-agent, general-implementation-agent, planner-agent
- Modified formats: return-metadata-file.md
- Modified config: `.claude/settings.json`, `.claude/CLAUDE.md`
- Updated templates: `.memory/30-Templates/memory-template.md`
- Updated indices: `.memory/20-Indices/index.md`

## Rollback/Contingency

All changes are to `.claude/` configuration files and `.memory/` templates. Rollback via `git revert` of the implementation commit(s). The system degrades gracefully:
- If two-phase retrieval causes issues, fall back to no auto-retrieval (revert Phase 2, keep index for future use)
- If index generation is unreliable, remove validate-on-read and rely on manual `/memory --reindex`
- If auto-retrieval causes token bloat, add `--no-remember` flag and revert to opt-in
- If memory candidates produce noise, remove `memory_candidates` emission from agent definitions
- If the Stop hook is annoying, remove its entry from `settings.json`
- Memory frontmatter backfill is additive (extra fields) and does not break existing functionality
- `memory-index.json` is entirely derived from memory files and can always be regenerated from scratch
