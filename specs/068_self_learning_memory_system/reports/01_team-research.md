---
title: "Self-Learning Memory System: Team Research Synthesis"
task: 68
artifact_type: research
mode: team
teammates: 4 (A: Primary, B: Alternatives/Web Research, C: Critic, D: Horizons)
created: 2026-04-15
---

# Research Report: Task #68

**Task**: Design self-learning memory system with automatic capture and retrieval
**Date**: 2026-04-15
**Mode**: Team Research (4 teammates)

## Summary

The current memory system is entirely user-driven: `/learn` for capture, `--remember` on `/research` for retrieval. Both require explicit invocation. The design goal -- automatic capture at lifecycle checkpoints and automatic retrieval during agent operations -- faces two hard architectural constraints:

1. **Postflight restrictions** prohibit memory writes, MCP calls, and content analysis after agent delegation completes
2. **Mandatory interactive requirement** in skill-memory labels autonomous writes a "critical failure"

These constraints narrow the viable design space from "fully automatic" to "friction-reduced interactive." The recommended approach centers on three mechanisms: (1) agents emit memory candidates in return metadata, (2) `/todo` archival upgrades its existing HarvestMemories stage into an interactive review with pre-classification, and (3) auto-retrieval becomes the default for all research operations by making `--remember` behavior implicit.

## Key Findings

### 1. Current Architecture Has No Autonomous Write Path

The memory vault at `.memory/` uses MEM-{slug}.md files with YAML frontmatter. The only write path is `/learn` -> `skill-memory`, which enforces mandatory AskUserQuestion gates at every step. There are currently 8 manually curated memories from 67 completed tasks (12% task-to-memory ratio), all high-durability configuration/architecture knowledge. This low ratio reflects intentional human curation, not a failure of the system.

### 2. Postflight Is the Wrong Location for Memory Capture

All three teammates confirmed: the postflight-tool-restrictions standard explicitly prohibits the operations memory capture requires (MCP calls, content analysis, `.memory/` writes). The postflight phase exists solely for state management (state.json, TODO.md, git commit). Injecting memory operations here would either violate the standard or require restructuring it -- creating maintenance burden across all skills.

**Resolution**: Memory capture must happen either (a) inside the agent delegation phase (agents emit candidates in metadata), or (b) at a separate lifecycle checkpoint that isn't bound by postflight restrictions.

### 3. `/todo` Archival Is the Natural Capture Checkpoint

The `/todo` command's skill-todo already has a HarvestMemories stage (Stage 7) that scans completed task artifacts, classifies content into TECHNIQUE/PATTERN/CONFIG/WORKFLOW/INSIGHT categories, and presents suggestions. This is the highest-quality capture point because:
- Tasks are fully complete (no risk of capturing abandoned work)
- All artifacts exist (reports, plans, summaries)
- The completion_summary field provides a concise, human-validated extract
- The classification taxonomy already exists

Currently this is a passive suggestion. Upgrading it to a pre-classified interactive review with one-click confirmation would dramatically reduce friction while preserving quality.

### 4. Auto-Retrieval Is More Viable Than Auto-Capture

Making relevant memories available to agents is technically simpler and less risky than automatic capture. The current `--remember` flag uses MCP/grep search against the vault and injects matches into research context. Three approaches for making this automatic:

**Approach A: Default --remember for all research** -- Make memory search the default behavior of `/research`, with `--no-remember` to opt out. Cheap to implement, no schema changes.

**Approach B: Keyword-based injection at delegation** -- In skill-researcher Stage 4 (prepare delegation context), grep task description keywords against `.memory/10-Memories/*.md` frontmatter topics and inject top-3 matches. No MCP dependency, works offline.

**Approach C: Extend index.json load_when** -- Add a `memory_topics` field to the context discovery schema that links agents/task_types to memory topic paths. More elegant but requires schema change.

### 5. Quality Without Human Judgment Is Structurally Hard

The Critic teammate identified a fundamental tension: what makes a memory "useful" cannot be reliably determined automatically. Most implementation tasks produce task-specific knowledge (e.g., "how I stripped nvim references") that has short shelf life and low reuse value. Only ~12% of tasks yielded memories worth keeping under human curation.

Risks of automatic capture without quality filtering:
- **Memory bloat**: Vault fills with low-value entries, degrading search precision
- **Stale memories**: No expiration/invalidation mechanism exists; outdated memories mislead agents
- **Circular learning**: Agent mistakes encoded as patterns get reinforced in future tasks
- **Deduplication impossible in postflight**: Overlap scoring requires MCP/grep (prohibited)

### 6. The Hook Infrastructure Enables Passive Nudging

The `.claude/settings.json` already has active hooks at SessionStart, UserPromptSubmit, Stop, and SubagentStop. A lightweight Stop hook could detect completed `/research` or `/implement` operations and append a one-line nudge: "Artifacts available for `/learn --task N`". This is:
- Non-blocking (echo only, no writes)
- Idempotent (same message regardless of repetition)
- Zero-risk (no vault writes, no MCP, no state changes)

### 7. Strategic Alignment: Curated Library, Not Knowledge Log

The project is a personal power tool (macOS Zed config for one user). The right memory model is a curated reference library of 50-200 high-durability memories, not a comprehensive log. Target domains: agent-system/, zed/, epi/, grant/, python/, r/, typst/. Each domain should have 10-20 core patterns. The vault is shared with OpenCode, adding write-safety constraints.

## Synthesis

### Conflicts Resolved

**Conflict 1: Auto-capture tier system vs. mandatory interactive requirement**

Teammate A proposed a three-tier system where Tier 1 (PATTERN/CONFIG with <30% overlap) captures automatically without confirmation. Teammate C identified this as irreconcilable with the mandatory interactive requirement. **Resolution**: Adopt the three-tier classification logic for **pre-classification** (auto-sorting candidates into tiers), but preserve a single aggregate confirmation step. Tier 1 items are pre-selected, Tier 2 items are presented, Tier 3 items are hidden by default. One AskUserQuestion call covers all candidates, reducing friction from per-segment confirmation to one batch decision.

**Conflict 2: Where to inject capture -- postflight vs. agent vs. archival**

Teammate A identified three candidate points; Teammate C ruled out postflight on architectural grounds. **Resolution**: Use a two-phase approach:
- **Phase 1 (agent-side)**: Agents emit `memory_candidates` in return metadata during delegation. No postflight violation because the capture happens inside the agent's work phase.
- **Phase 2 (archival)**: `/todo` collects candidates from completed task metadata and presents batch review. This is the existing HarvestMemories stage, upgraded with pre-classification.

**Conflict 3: Fully automatic retrieval vs. opt-in --remember flag**

Teammate D recommended making `--remember` default for `meta` tasks only. Teammate A proposed making it default for all research. **Resolution**: Make retrieval default for all research operations (it's cheap and the vault is small). Add `--no-remember` flag for opt-out. For planning and implementation, use topic-based filtering (Approach B) to inject only highly relevant memories without full vault search.

### Prior Art Integration (from Teammate B -- late completion)

Teammate B's web research surfaced seven major systems with converging evidence:

**Retrieval scoring**: The Generative Agents paper (Stanford/Google, UIST 2023) established the gold-standard formula: `score = α·recency + β·importance + γ·relevance`. Key insight: recency measures time since last *retrieval*, not creation -- implementing natural spaced repetition. Frequently-accessed memories strengthen; unused ones decay.

**Reflexion pattern** (NeurIPS 2023): Post-task verbal reflection stored as episodic memory dramatically improves coding agent performance (SOTA on HumanEval, MBPP). Maps directly to GATE OUT capture. The most effective reflections are task-outcome-conditional, failure-focused, and prescriptive.

**AUDN cycle** (Mem0, production 2024-2025): Industry-standard deduplication: ADD/UPDATE/DELETE/NOOP. LLM-driven decision after semantic search of top-10 similar memories. Achieves 26% improvement over OpenAI memory, 91% token reduction vs full context. Most candidates result in NOOP (system already knows the fact).

**Verification-at-retrieval** (GitHub Copilot, production): Rather than time-based decay, verify whether memory citations are still valid at retrieval time. Better for code repos because changes are event-driven, not time-driven. Measured impact: 7% increase in PR merge rates with memory-enabled agents.

**Design implications for task 68**:
- Use composite scoring for retrieval (not just keyword matching)
- Add `retrieval_count` and `last_retrieved` fields to memory frontmatter for natural decay
- Adopt AUDN for deduplication (the existing UPDATE/EXTEND/CREATE in skill-memory is already close)
- Prefer verification-at-retrieval over time-based expiration for staleness
- Budget retrieval to 5-10 memories, <2000 tokens per injection

### Gaps Identified

1. **Memory invalidation**: No mechanism exists to detect or mark stale memories. Verification-at-retrieval (GitHub Copilot pattern) is the recommended approach over time-based decay.
2. **Memory pruning**: Add `retrieval_count` field; memories never retrieved after N task cycles become archive candidates.
3. **Cross-session deduplication**: AUDN cycle (Mem0 pattern) should govern all writes. Most candidates will be NOOP.
4. **Embedding infrastructure**: Current system uses grep/keyword matching. Composite scoring with relevance requires either embedding support or enhanced keyword overlap scoring.

### Recommendations

#### Tier 1: Automatic Retrieval (low risk, high value, implement first)

1. Make `--remember` the default behavior for `/research` (grep-based, no MCP dependency)
2. Add lightweight memory injection to `/plan` and `/implement` delegation contexts using task description keyword matching against memory topics
3. Add `--no-remember` flag for opt-out

#### Tier 2: Agent-Side Capture Candidates (medium risk, medium value)

4. Extend return metadata schema with `memory_candidates[]` array
5. Agents emit 0-3 candidates per operation (key findings, novel patterns, configuration discoveries)
6. Candidates stored in `.return-meta.json` -- no memory writes during delegation, just structured suggestions

#### Tier 3: Enhanced /todo Harvest (low risk, high value)

7. Upgrade `/todo` HarvestMemories to use three-tier pre-classification
8. Batch all candidates from completed tasks into one AskUserQuestion with pre-selected Tier 1 items
9. Single confirmation creates all approved memories

#### Tier 4: Passive Nudging (zero risk, low-medium value)

10. Add Stop hook that detects completed lifecycle operations and prints `/learn --task N` reminder
11. No writes, no state changes, just awareness

#### Tier 5: Memory Health (future, needed as vault grows)

12. `/memory --audit` command to scan for stale memories (files modified since memory creation)
13. Memory expiration dates or review-by dates in frontmatter
14. Periodic vault pruning recommendations during `/todo`

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary architecture + implementation | completed | medium-high |
| B | Prior art + web research (7 systems analyzed) | completed (late) | high |
| C | Critic: risks and constraints | completed | high |
| D | Strategic alignment + creative approaches | completed | high |

## References

- `.claude/context/standards/postflight-tool-restrictions.md` -- Postflight boundary standard
- `.claude/skills/skill-memory/SKILL.md` -- Memory skill with mandatory interactive requirement
- `.claude/skills/skill-todo/SKILL.md` -- HarvestMemories stage (Stage 7)
- `.claude/context/patterns/context-discovery.md` -- Context loading system
- `docs/agent-system/context-and-memory.md` -- Five context layers, two memory layers
- `.claude/context/formats/return-metadata-file.md` -- Agent return metadata schema
