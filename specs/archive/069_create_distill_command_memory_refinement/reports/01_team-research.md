# Research Report: Task #69

**Task**: Create /distill command for memory system refinement
**Date**: 2026-04-16
**Mode**: Team Research (4 teammates)

## Summary

Team research synthesized findings from four angles on designing a `/distill` command for the `.memory/` vault system. The command should complement `/learn` (which creates memories) by providing vault maintenance: health reporting, pruning stale entries, merging duplicates, compressing verbose memories, and refining metadata. Claude Code's leaked "Auto Dream" system prompt provides the strongest design reference -- a four-phase consolidation model (Orient, Gather Signal, Consolidate, Prune & Index) with a conservative philosophy of keeping ambiguously-useful content. The `/todo` suggestion for `/distill` and `/review` should be conditional based on vault health metrics, not always-on boilerplate.

## Key Findings

### Primary Approach (from Teammate A)

**Claude Code Auto Dream (direct inspiration)**: Claude Code has a leaked memory consolidation feature that runs a four-phase cycle: Orient (inventory memories), Gather Signal (targeted grep for contradictions/duplicates), Consolidate (normalize dates, delete contradicted facts, merge duplicates), Prune & Index (keep index under 200 lines/~25KB). It triggers on dual conditions (24hr + 5 sessions) and uses conservative philosophy: "prefer keeping ambiguously-useful content over removing something potentially important."

**Four core distillation operations mapped to existing data model**:
1. **PURGE**: `retrieval_count == 0 AND days_since_created > 30` -- present as multiSelect, opt-in
2. **COMBINE**: keyword overlap > 60% between pairs -- present pairs for user confirmation
3. **COMPRESS**: `token_count > 600` -- user confirms before rewriting to key points + History section
4. **REFINE**: keyword quality fixes (< 4 keywords, duplicates) automatic; topic reclassification interactive

**Scoring model**: Composite of staleness (days since retrieval/creation, 90-day window), zero-retrieval penalty, size penalty (>600 tokens), and duplicate score (keyword overlap). Yields ranked priority list.

**Architecture**: Extend `skill-memory` with `mode=distill` rather than creating a new skill. Reuse existing keyword overlap scoring (>60% HIGH, 30-60% MEDIUM, <30% LOW).

**Command flags**: `/distill` (full), `--analyze` (dry run), `--purge-only/--combine-only/--compress-only`, `--auto` (bookkeeping only).

### Alternative Approaches (from Teammate B)

**Mem0's arbiter-agent pattern**: Production AI memory systems route each memory through a conflict-resolution decision tree (duplicate/refinement/contradiction), not uniform summarization. Contradicting facts get compressed into "temporal reflection summaries." Key insight: distinguish staleness from contradiction.

**Factory.ai anchored iterative summarization**: Scored 4.04 vs competitors' 3.74 on detail preservation because it avoids full reconstruction. Strong evidence for incremental (cluster-by-cluster) over batch (all-at-once) processing.

**FSRS-inspired staleness scoring**: Adapted from spaced repetition (stability x retrievability x difficulty). Memories retrieved when old are MORE valuable than age suggests -- a non-obvious insight that prevents incorrect purging.

**Tombstone pattern**: Never hard-delete during distillation. Mark with `status: tombstoned` + timestamp. Offer `--gc` flag for cleanup after 7-day grace period. Prevents accidental loss with a recovery window.

**Topic-cluster grouping**: Process memories by topic cluster (`agent-system/*`, `zed/*`) independently. Prevents cross-domain contamination and reduces token cost.

**TTL by category**: CONFIG 6mo, WORKFLOW 12mo, PATTERN 18mo, TECHNIQUE 9mo, INSIGHT no TTL. Advisory only (flagged for review), not automatic.

### Gaps and Shortcomings (from Critic)

**1. Premature optimization**: With 8 memories and 0 retrievals, there is no usage signal to guide distillation. Any algorithm is guessing. Meaningful threshold: ~50 memories. But building the infrastructure now (health reporting) is valid preparation.

**2. Silent information loss**: Merge errors lose keywords. Summary compression loses detail exponentially. History sections can be destroyed. Category downgrades change retrieval behavior invisibly. **Prerequisite**: A distillation log (`.memory/distill-log.json`) recording what was changed and why.

**3. Retrieval degradation from keyword changes**: The retrieval system uses ONLY keyword overlap. Merging two memories risks dropping keywords from either source. Retrieval failures are silent -- no error when a relevant memory is missed. **Mitigation**: Merged memories MUST have keywords as superset of union of all source memories' keywords.

**4. Functional overlap with /learn**: Three of four operations (compress, combine, refine) already exist in `/learn` as UPDATE/EXTEND. The genuine gap is PURGE (deletion) and batch cross-memory redundancy detection. Risk: if `/distill` reimplements with different semantics, the systems diverge.

**5. Auto-Dream architecture mismatch**: Auto-Dream's Phase 2 reads session transcript JSONL files. This vault has no transcripts. Signal sources must be redefined: git commit messages, task completion summaries, retrieval_count/last_retrieved fields.

**6. Missing success metrics**: No way to evaluate if distillation improved or degraded the vault. Minimum: pre/post token count, entry count, list of affected memories.

**7. ## Connections stale links**: If Memory A is merged into B, all memories referencing A via `[[MEM-A]]` have stale links. No link-update mechanism exists.

**8. The /todo suggestion is trivially simple**: ~15 minutes of work, should be decoupled from the hard design work.

### Strategic Horizons (from Teammate D)

**Lifecycle position**: `/distill` fits after `/todo` harvest as distinct maintenance: `/learn -> auto-retrieval -> /todo harvest -> /distill (maintain quality)`. Not merged into `/todo`.

**Three operational regimes**:
| Vault Size | Problem | Strategy |
|------------|---------|----------|
| 0-30 | None | Report quality score only |
| 30-150 | Keyword drift, duplicates | Active: merge, prune |
| 150-500+ | Retrieval precision degrades | Cluster compression, meta-memories |

Design target should be the 30-150 regime, with structural features deferred.

**memory_health in state.json**: Parallel to existing `repository_health`. Fields: `last_distilled`, `distill_count`, `total_memories`, `never_retrieved`, `health_score`, `status`. `/distill` updates it; `/todo` reads it for conditional suggestions.

**Meta-memories**: At 5+ related memories in a cluster, generate a summary "meta-memory" (marked `is_meta: true`). Enables two-tier retrieval: meta-memories for broad context, constituent memories for detail. Defer until 50+ memories.

**/todo as "next steps advisor"**: Conditional suggestions based on actual system state, not boilerplate. Show `/distill` when: `never_retrieved/total > 50%` OR `total_memories > 30` OR `last_distilled` older than 30 days. Suppress when vault < 5 memories.

**Core command, not extension**: Memory maintenance is a system responsibility. But should be domain-aware (cluster by topic, don't merge across domains).

## Synthesis

### Conflicts Resolved

**1. Skill architecture (A: extend skill-memory vs D: new skill-distill)**
Resolution: **Extend skill-memory with `mode=distill`** (A's approach). The operations reuse the same infrastructure (overlap scoring, index regeneration, memory file I/O). Creating a separate skill duplicates too much code. However, the distill mode may optionally spawn a `distill-agent` (opus) for agent-assisted compression, similar to how `/review` can invoke `code-reviewer-agent`.

**2. Threshold for /todo suggestion (A: 5+, B: 20+, C: 50+, D: 30+)**
Resolution: **Two-tier conditional logic**. Always suggest `/distill --report` (read-only health check) when vault has 10+ memories. Suggest `/distill` (full interactive) when: `total_memories >= 30` OR `never_retrieved/total > 0.5` OR `last_distilled` older than 30 days. This respects the critic's concern about premature optimization while still surfacing the command early for awareness.

**3. Scope: single command vs decomposition (A: single + flags, C: decompose)**
Resolution: **Single command with subcommand-style flags** (A's approach, informed by C's safety concerns). `/distill` bare = health report (safe default). `--purge`, `--merge`, `--compress` for scoped operations. This satisfies C's decomposition concern without fragmenting into multiple commands.

**4. Auto-Dream applicability (A: direct inspiration, C: architecture mismatch)**
Resolution: **Adopt Phases 1, 3, 4; redefine Phase 2 signal sources**. The consolidation and pruning phases translate well. The "gather signal" phase must use this system's native signals: `retrieval_count`, `last_retrieved`, `keywords` overlap, `token_count`, and git log of `.memory/` changes -- not session transcripts.

### Gaps Identified

1. **No distillation log mechanism**: Must be designed as prerequisite. Format: `.memory/distill-log.json` recording timestamp, operations performed, memories affected, pre/post metrics.

2. **No keyword preservation guarantee**: The implementation plan must enforce keyword superset rule for merges.

3. **No `## Connections` link update mechanism**: When memories are merged or deleted, wiki-links in other memories become stale. Needs a link-scan step.

4. **No rollback beyond git**: A distillation log enables targeted rollback. Git provides full rollback but requires manual identification of affected files.

5. **No retrieval quality baseline**: Before distilling, the system should establish baseline retrieval metrics (even if all zeros currently) to measure impact.

### Recommendations

**Phase 1 (Immediate, low-risk)**:
1. Update `/todo` output to conditionally suggest `/distill` and `/review` based on vault health
2. Add `memory_health` field to `state.json` schema
3. Implement `/distill --report` (read-only health analysis)

**Phase 2 (After vault reaches 30+ memories)**:
4. Implement PURGE with tombstone pattern and interactive confirmation
5. Implement COMBINE with keyword superset guarantee
6. Add `distill-log.json` tracking

**Phase 3 (After vault reaches 100+ memories)**:
7. Implement COMPRESS with agent-assisted summarization
8. Implement meta-memories for large clusters
9. Consider scheduled background distillation (`/schedule weekly /distill --auto`)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach: Auto-Dream inspiration, scoring model, command structure | completed | high |
| B | Alternatives: Mem0 arbiter, FSRS scoring, tombstone pattern, prior art | completed | high |
| C | Critic: Premature optimization, keyword loss, scope creep, missing metrics | completed | high |
| D | Horizons: Lifecycle position, memory_health, meta-memories, scaling regimes | completed | medium |

## References

- Claude Code Auto-Dream system prompt (Piebald-AI/claude-code-system-prompts)
- Mem0 memory pipeline (arxiv.org/abs/2504.19413)
- Factory.ai anchored iterative summarization (zylos.ai research)
- FSRS spaced repetition algorithm (adapted for memory staleness)
- Structured Distillation for Agent Memory (arxiv 2603.13017)
- MCP Memory Service autonomous consolidation (doobidoo/mcp-memory-service)
- CLI UX best practices (clig.dev, Evil Martians)
