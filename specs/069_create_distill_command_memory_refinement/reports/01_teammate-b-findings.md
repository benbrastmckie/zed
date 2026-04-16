---
title: "Teammate B Findings: Alternative Patterns and Prior Art for /distill"
artifact_number: 01
teammate: B
focus: Alternative Approaches and Prior Art
task: 69
created: 2026-04-16
---

# Teammate B Findings: Alternative Patterns and Prior Art for /distill

## Executive Summary

Research into AI memory management systems, knowledge base maintenance tools, cache eviction theory, and CLI UX patterns reveals several approaches that differ significantly from a naive "read all memories, summarize them" implementation. The strongest recommendation is a **scoring-led triage architecture** that applies different operations (consolidate, compress, purge, or pass) based on per-memory scores derived from retrieval history, token count, keyword overlap, and age — rather than processing all memories uniformly. For the `/todo` integration, conditional suggestions based on vault state thresholds are the right pattern.

---

## Key Findings

### 1. Prior Art: How Production AI Memory Systems Handle Consolidation

**Mem0's two-phase pipeline** (Extraction + Update) is the current production standard for AI agent memory management. It is instructive because it separates concerns cleanly:

- *Extraction phase*: Ingests the latest exchange, a rolling summary, and recent messages; uses an LLM to produce candidate facts.
- *Update phase*: Compares each candidate against the top-N similar existing entries. An "arbiter LLM" decides whether each is: a duplicate (merge/drop), a refinement (extend), or a contradiction/pivot (compress old + add new temporal summary).

Key insight: Mem0 does not uniformly summarize — it routes each candidate through a conflict-resolution decision tree. A memory that is simply old but consistent gets extended; a memory that contradicts newer facts gets compressed into a "temporal reflection summary" (e.g., "User preferred React until Nov 2025, then switched to Vue"). This distinction between *staleness* and *contradiction* is absent from naive approaches.

**Source**: arxiv.org/abs/2504.19413; mem0.ai/blog/memory-in-agents-what-why-and-how

**MCP Memory Service (doobidoo)** implements autonomous consolidation with decay-based compression. Old memories automatically decay in relevance; the service compresses historical information without manual triggers. Crucially, it treats consolidation as a background process, not a user-initiated command — which is the opposite of the `/distill` model but useful as a contrast.

**Source**: github.com/doobidoo/mcp-memory-service

**Claude Code's own compaction** (the `compact-2026-01-12` Anthropic API feature) triggers at 70% context utilization, using anchored iterative summarization: it identifies only newly-evicted message spans, summarizes those segments alone, then merges results into a persistent anchor state structured around intent, changes made, decisions, and next steps. This 70% threshold is empirically validated — performance degrades non-linearly beyond 30,000 tokens even in large-window models.

**Source**: zylos.ai/research/2026-02-28-ai-agent-context-compression-strategies

---

### 2. Alternative Architectural Approaches

#### A. Batch vs. Incremental: Strong Recommendation for Incremental

Research shows that batch-mode summarization (reprocessing all memories at once) consistently underperforms incremental approaches:

- Factory.ai's anchored iterative summarization scored 4.04 vs. competitors' 3.74–3.43 on technical detail preservation, precisely because it avoids regenerating summaries from scratch.
- Rolling LLM summarization (full reconstruction on each pass) suffers from "detail drift" — each compression cycle loses more information.
- The practice overflow article on compaction found that "summaries masked failure signals, so agents kept pushing down unproductive paths" — a risk of aggressive uniform summarization.

**Recommendation**: `/distill` should process memories in small groups (by topic or keyword cluster), not as a single batch. This preserves intra-cluster context and avoids cross-contamination between unrelated domains.

#### B. Threshold-Triggered vs. On-Demand

Two viable models:

1. **On-demand** (user-initiated `/distill`): Consistent with the existing command system. The user decides when to run it. Appropriate given the current vault size (8 memories).

2. **Threshold-triggered** (automatic suggestion): The 70% context utilization threshold from Anthropic's compaction research translates to a memory count threshold for this system. A vault of 8 memories uses ~3,751 tokens. If the memory retrieval budget is capped at 3,000 tokens (per the existing CLAUDE.md spec), the vault is already over budget by raw token count alone. A threshold of **20–25 memories OR >5,000 tokens** would be a reasonable trigger for suggesting distillation.

The `/todo` integration should implement the threshold check and suggest `/distill` conditionally when the threshold is exceeded — not unconditionally on every run.

#### C. Diff-Based Drift Detection

GitOps drift detection (comparing rendered manifests against live state) maps cleanly onto the `.memory/` system:

- The `memory-index.json` stores `modified` dates. A `git log --follow` on `.memory/10-Memories/` reveals which memories have changed across commits.
- Memories whose source files (the project files they were learned from) have since been updated in git could be flagged as "drifted" — the memory may no longer reflect current reality.
- This is a **different problem from consolidation** — it is correctness drift rather than redundancy drift.

**Recommendation**: `/distill` should include a drift-detection pass: compare `memory.modified` dates against `git log` timestamps for the source files referenced in memory frontmatter. Flag memories as potentially stale if their source has been updated since the memory was created.

---

### 3. Purge Strategies from Other Systems

#### LRU (Least Recently Used)
In the memory index, `last_retrieved` is null for all 8 current memories (never retrieved). LRU would flag these for review — but pure LRU is problematic for a knowledge vault because a CONFIG memory about Zed keybindings is still valid even if never retrieved during task operations. LRU works well for caches where retrieval implies value; it works poorly for reference knowledge.

**Adaptation**: Use LRU as a secondary signal, not a primary eviction criterion. A memory that is never retrieved AND has high keyword overlap with another memory is a candidate for merge-or-purge. A memory that is never retrieved but covers a unique topic should be retained.

#### LFU (Least Frequently Used)
Current data: all memories have `retrieval_count: 0`. LFU is useless until the system has accumulated retrieval history. This argues against implementing aggressive purging in the initial `/distill` — the vault is too young.

**Recommendation**: Purge should be conservative at low vault ages (< 50 memories). Focus initial `/distill` runs on consolidation and compression rather than deletion.

#### TTL (Time-To-Live) Expiry
Applied to the domain: a CONFIG memory (like Zed editor settings) may become stale after a major version update. A WORKFLOW memory may be valid indefinitely. A TECHNIQUE memory may be superseded by new tooling.

**TTL mapping by category:**
- `CONFIG`: 6 months (settings change frequently)
- `WORKFLOW`: 12 months (processes change slowly)
- `PATTERN`: 18 months (architectural patterns are durable)
- `TECHNIQUE`: 9 months (techniques evolve with tooling)
- `INSIGHT`: No TTL (insights are timeless or self-evidently outdated)

These should be advisory (flagged for review), not automatic deletions.

#### Tombstone Pattern (Soft Delete)
From Cassandra/ScyllaDB: instead of hard-deleting memories, mark them with a `deleted: true` field and a `deleted_at` timestamp. Run actual removal in a separate "garbage collection" pass after a grace period (Cassandra defaults to 10 days).

**Application**: `/distill` should implement a two-phase delete:
1. Mark memory as `status: tombstoned` in its frontmatter and in the index.
2. A separate `/distill --gc` flag (or automatic cleanup after N days) performs hard deletion.

This prevents accidental loss of memories that were incorrectly flagged and gives users a recovery window.

---

### 4. Compression Techniques for Text Knowledge Bases

The consolidation/summarization/distillation tripartite taxonomy (from Lavigne, Medium) maps directly onto the `/distill` operation types:

| Operation | Info Retention | Compression | Best For |
|-----------|---------------|-------------|----------|
| Consolidation | 80–95% | 20–50% | Redundant memories on same topic |
| Summarization | 50–80% | 60–90% | Long CONFIG/WORKFLOW memories |
| Distillation | 30–60% | 80–95% | Old INSIGHT/TECHNIQUE memories |

**Concrete recommendation**: Route each memory group through the appropriate operation based on its category and age:
- PATTERN/CONFIG memories: consolidation (preserve detail, remove redundancy)
- WORKFLOW/TECHNIQUE memories > 9 months: summarization
- INSIGHT memories > 18 months with zero retrieval: distillation or tombstone

#### FSRS-Inspired Staleness Scoring

The FSRS algorithm's three parameters (Stability, Retrievability, Difficulty) can be adapted for memory scoring:

```
stability    = days_since_created (older = less stable in dynamic domains)
retrievability = retrieval_count / max(days_since_created, 1)  (access rate)
difficulty   = token_count / 500  (proxy for complexity; dense memories are harder to use)

staleness_score = (1 - retrievability) * (1 / max(stability, 1)) * difficulty
```

Memories with high staleness scores are candidates for compression or review. This produces a ranked list rather than a binary keep/purge decision.

**Key insight from FSRS**: The relationship between retrievability and stability growth is non-linear — a memory successfully retrieved when its retrievability was low gets a larger stability boost than one retrieved when it was already fresh. Translated: a memory that IS retrieved despite being old is more valuable than its age suggests, and should NOT be purged.

---

### 5. The /todo Integration

#### Conditional Suggestion Pattern

Research from CLI UX best practices (clig.dev, Evil Martians, Atlassian) confirms that the best CLIs suggest next steps contextually, not unconditionally. The pattern is:

```
if [condition that makes the suggestion relevant]:
    print "Tip: Run /distill to compress and consolidate your memory vault."
```

For `/todo`, the relevant condition is one or more of:
- `entry_count >= 20` in memory-index.json
- `total_tokens >= 5000` in memory-index.json
- Any memory has `retrieval_count == 0` AND `created` > 90 days ago
- Any memory has `last_retrieved` > 180 days ago

#### Exact /todo Modification

The suggestion block belongs at the end of Step 7 (Output), after the existing "Next Steps" block. The current `/todo` output ends with:

```
Next Steps:
1. Review archive at specs/archive/
2. Run /review for codebase analysis
```

The modified version should conditionally append:

```bash
# Check memory vault state
entry_count=$(jq '.entry_count' .memory/memory-index.json 2>/dev/null || echo "0")
total_tokens=$(jq '.total_tokens' .memory/memory-index.json 2>/dev/null || echo "0")
stale_count=$(jq '[.entries[] | select(.retrieval_count == 0)] | length' .memory/memory-index.json 2>/dev/null || echo "0")

distill_suggested=false
if [ "$entry_count" -ge 20 ] || [ "$total_tokens" -ge 5000 ] || [ "$stale_count" -ge 10 ]; then
  distill_suggested=true
fi
```

Output when `distill_suggested=true`:
```
3. Run /distill to consolidate memory vault ({entry_count} memories, {stale_count} never retrieved)
```

Output when `distill_suggested=false` and vault has any memories:
```
3. Run /distill to review memory vault health
```

Output when vault is empty or missing: omit entirely.

This follows the principle of "identifying common patterns of use" to suggest the next best step — the suggestion is most valuable when the vault is large enough to benefit from distillation.

---

## Recommended Approach

A `/distill` command built on these principles should differ from the naive implementation in five concrete ways:

### 1. Score-Led Triage, Not Uniform Processing

Instead of processing all memories the same way, compute a staleness score for each memory and route it to the appropriate operation:

```
score 0.0–0.3: healthy, skip
score 0.3–0.6: candidate for consolidation with similar memories
score 0.6–0.8: candidate for summarization/compression
score 0.8–1.0: candidate for tombstone (soft delete)
```

### 2. Topic-Cluster Grouping Before Any LLM Calls

Group memories by `topic` field (e.g., `agent-system/*`, `zed/*`) before invoking any consolidation. Process clusters independently. This prevents cross-domain contamination and reduces token cost.

The current 8 memories form two natural clusters:
- `agent-system/*` (3 memories: architecture, commands, context-layers)
- `zed/*` (5 memories: install, toolchain, agent-panel-modes, editor-settings, keybindings)

Within-cluster consolidation is the highest-value operation; cross-cluster consolidation is almost never appropriate.

### 3. Tombstone Pattern for Deletions

Never hard-delete during a `/distill` run. Mark candidates with `status: tombstoned` + `tombstoned_at` timestamp. Offer `--gc` flag to perform hard deletion of tombstones older than 7 days.

### 4. Diff-Based Drift Detection as a Dedicated Pass

Add a `--drift` flag (or include as a standard check) that compares memory creation/modification dates against `git log` timestamps for the memory vault. Flag memories whose source domain has had significant commits since they were created.

### 5. Incremental Mode as Default, Batch as Opt-In

Default `/distill` processes memories in clusters (incremental). An explicit `--all` or `--batch` flag processes the entire vault in one pass (faster but higher risk of detail loss).

---

## Evidence and Examples

### Observation Masking vs. Summarization
From the compaction research: "observation masking was cheaper, faster, and slightly more effective at completing tasks because summarization sometimes loses important details in the compression." Applied to memory distillation: for CONFIG memories (Zed settings, keybindings), consolidation (masking redundant fields) is better than summarization; for WORKFLOW/PATTERN memories, summarization is appropriate.

### Mem0 Arbiter Agent Pattern
Mem0's use of a specialized "arbiter LLM" to resolve conflicts is evidence for the value of a dedicated distillation agent rather than executing distillation inline in the command. This maps to the existing agent architecture: `/distill` command -> `skill-distill` -> `distill-agent`.

### TTL in Cassandra vs. Our Domain
Cassandra's default `gc_grace_seconds` is 10 days — long enough to ensure distributed replication before hard deletion. For a local memory vault, 7 days is appropriate for the tombstone grace period (one week of daily use to notice a missing memory).

### CLI "Next Steps" Pattern
The CLIG.dev guidelines and Evil Martians CLI best practices both confirm that post-operation suggestions should be contextual, not boilerplate. The suggestion should include the relevant metric so the user understands why it's being surfaced.

---

## Confidence Levels

| Finding | Confidence | Basis |
|---------|-----------|-------|
| Score-led triage is better than uniform processing | High | Multiple production systems (Mem0, Factory.ai ACON) |
| Tombstone pattern for safe deletion | High | Well-established database pattern (Cassandra, Scylla) |
| Topic-cluster grouping before LLM calls | High | First-principles reasoning + Mem0 architecture |
| Incremental > batch for consolidation | High | Factory.ai empirical results (4.04 vs 3.74 score) |
| FSRS-inspired staleness scoring | Medium | Requires empirical tuning; algorithm is sound but parameters are guessed |
| Diff-based drift detection | Medium | Conceptually valid; requires consistent source metadata in memory frontmatter |
| TTL values by category | Low | No empirical basis for the specific durations; reasonable heuristics only |
| Token threshold of 5,000 for /todo suggestion | Low | Extrapolated from the 70% context budget threshold; not validated for this vault size |

---

## What Teammate A Should NOT Duplicate

This report focuses on:
- Prior art survey (Mem0, Factory.ai, MCP Memory Service, FSRS/Anki, Cassandra tombstones)
- Alternative architecture options (batch vs. incremental, threshold-triggered vs. on-demand, diff-based)
- The tombstone pattern as a purge safety mechanism
- Concrete `/todo` modification with conditional logic

Teammate A's primary implementation focus should cover:
- The command file structure (`/distill` argument parsing)
- The skill/agent architecture
- The memory-index.json schema changes needed
- The interactive user flow (which memories to process, confirmation dialogs)
- The index regeneration logic after operations complete
