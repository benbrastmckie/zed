# Research Report: Task #68 (Round 2)

**Task**: 68 - Self-Learning Memory System: Memory Index Design for Context-Efficient Retrieval
**Started**: 2026-04-15T12:00:00Z
**Completed**: 2026-04-15T12:45:00Z
**Effort**: medium
**Dependencies**: Round 1 team research (01_team-research.md)
**Sources/Inputs**:
- `.claude/context/index.json` -- proven selective loading schema
- `.memory/20-Indices/index.md` -- current memory index (markdown)
- `.memory/10-Memories/MEM-*.md` -- memory file frontmatter analysis
- `.claude/skills/skill-memory/SKILL.md` -- current memory operations
- `.claude/context/patterns/context-discovery.md` -- jq query patterns
- Web: Mem0 architecture (arxiv.org/abs/2504.19413)
- Web: xMemory hierarchical retrieval (arxiv.org/abs/2602.02007)
- Web: GitHub Copilot memory system (github.blog)
- Web: BM25 single-file searchable memory (eric-tramel.github.io)
**Artifacts**:
- `specs/068_self_learning_memory_system/reports/02_memory-index-design.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The current `.memory/20-Indices/index.md` is a markdown file designed for human navigation, not machine query. It cannot support relevance scoring, token budgeting, or selective retrieval.
- A JSON manifest at `.memory/memory-index.json` modeled on `.claude/context/index.json` is the recommended approach. At ~50 tokens per entry, a 200-memory vault costs ~10K tokens to scan -- well within budget for two-phase retrieval.
- Production systems (Mem0, GitHub Copilot, xMemory) converge on the same pattern: compact metadata index for candidate generation, then selective full-content retrieval for top-K matches only.
- The recommended schema includes per-entry fields for title, topic, keywords, one-line summary, token count, and retrieval statistics -- enough for relevance scoring without reading any memory file.
- Grep-based keyword matching against the JSON manifest provides 80% of the value of embedding-based search with zero infrastructure overhead. BM25 indexing could be added later as an optional enhancement.
- Auto-update on every `/learn` operation (regenerate from filesystem + frontmatter) keeps the index in sync with zero manual maintenance.

## Context & Scope

Round 1 team research established that auto-retrieval is more viable than auto-capture, and recommended making `--remember` the default behavior. This round addresses the specific question: **how do you retrieve memories without injecting the entire vault into context?**

The focus is designing a memory index schema that enables two-phase retrieval:
1. **Phase 1 (cheap)**: Scan a compact index, score entries, select top-K
2. **Phase 2 (targeted)**: Read only selected memory files into context

The constraint is that the current vault uses grep-based search with YAML frontmatter -- no MCP embedding infrastructure should be required.

## Findings

### 1. Current index.json Is the Proven Model

The `.claude/context/index.json` already solves the exact same problem for context files. Each entry contains:

```json
{
  "path": "architecture/component-checklist.md",
  "line_count": 363,
  "topics": ["system-design"],
  "domain": "core",
  "summary": "Component creation checklist for agent system",
  "subdomain": "architecture",
  "keywords": ["component", "checklist", "architecture"],
  "load_when": {
    "agents": ["meta-builder-agent"],
    "task_types": ["meta"],
    "commands": ["/meta"]
  }
}
```

This schema enables jq-based filtering: agents query by their name, task type, or command, and only matching files are loaded. The `line_count` field enables budget-aware loading. The `keywords` and `topics` fields enable content-based discovery.

Key design principle: **the index contains enough information to decide what to load without loading anything**.

### 2. Current Memory Files Have Minimal Frontmatter

Each memory file (e.g., `MEM-zed-editor-settings.md`) has YAML frontmatter:

```yaml
---
title: "Zed editor settings configuration"
created: 2026-04-15
tags: [CONFIG, zed, settings, editor]
topic: "zed/config"
source: "settings.json"
modified: 2026-04-15
---
```

This frontmatter is designed for human browsing, not machine scoring. Missing fields that would enable automated retrieval:
- **One-line summary** (for relevance matching without reading body)
- **Keywords** separate from tags (tags are categories; keywords are content terms)
- **Token count** (for budget planning)
- **Retrieval statistics** (last_retrieved, retrieval_count for decay/reinforcement)

### 3. Production Systems All Use Two-Phase Retrieval

Every production memory system reviewed uses the same pattern:

| System | Index Phase | Retrieval Phase | Token Cost |
|--------|------------|-----------------|------------|
| **Mem0** | Embedding + metadata filter, top-10 candidates | LLM scores AUDN decision on each | 91% fewer tokens vs full context |
| **GitHub Copilot** | Most recent memories for repo, citation-indexed | Agent verifies citations against current code | Not disclosed |
| **xMemory** | Hierarchical theme/semantic scan, uncertainty gating | Drill to episode/message only if uncertainty decreases | ~50% reduction (9K to 4.7K tokens) |
| **BM25 Single-File** | Precomputed sparse matrix lookup, microsecond query | Return top-K conversation turns | Zero embedding cost |

**Key convergence**: No production system injects full memory stores. All use a lightweight first pass (metadata, embeddings, or keyword index) to identify candidates, then selectively retrieve only relevant content.

### 4. Proposed Memory Index Schema

The following schema for `.memory/memory-index.json` mirrors `index.json` patterns while adding retrieval-specific fields:

```json
{
  "version": 1,
  "generated_at": "2026-04-15T12:00:00Z",
  "entry_count": 8,
  "total_tokens": 4200,
  "entries": [
    {
      "id": "MEM-zed-editor-settings",
      "path": "10-Memories/MEM-zed-editor-settings.md",
      "title": "Zed editor settings configuration",
      "summary": "Theme, fonts, LSP config, language-specific settings, and Claude Code ACP server setup for Zed editor",
      "topic": "zed/config",
      "category": "CONFIG",
      "keywords": ["zed", "settings", "theme", "lsp", "pyright", "ruff", "vim-mode", "acp"],
      "token_count": 520,
      "created": "2026-04-15",
      "modified": "2026-04-15",
      "last_retrieved": null,
      "retrieval_count": 0
    },
    {
      "id": "MEM-agent-system-architecture",
      "path": "10-Memories/MEM-agent-system-architecture.md",
      "title": "Claude Code agent system three-layer architecture",
      "summary": "Three-layer pipeline (commands/skills/agents), checkpoint execution, task lifecycle state machine, task-type routing",
      "topic": "agent-system/architecture",
      "category": "PATTERN",
      "keywords": ["agent", "pipeline", "checkpoint", "lifecycle", "routing", "delegation", "gate-in", "gate-out"],
      "token_count": 580,
      "created": "2026-04-15",
      "modified": "2026-04-15",
      "last_retrieved": null,
      "retrieval_count": 0
    }
  ]
}
```

**Per-entry token cost**: ~50 tokens (id + title + summary + topic + keywords + stats).
**200-entry vault**: ~10,000 tokens to scan the full index.
**Current vault (8 entries)**: ~400 tokens -- trivially cheap.

### 5. Two-Phase Retrieval Algorithm

```
PHASE 1: Score (read only memory-index.json)
  1. Extract keywords from task description + task_type
  2. For each index entry:
     a. keyword_overlap = |task_keywords intersect entry.keywords| / |task_keywords|
     b. topic_match = 1.0 if entry.topic starts with task_type domain, else 0.0
     c. recency_bonus = 0.1 if entry.last_retrieved within 7 days
     d. score = 0.5 * keyword_overlap + 0.3 * topic_match + 0.2 * recency_bonus
  3. Sort by score descending
  4. Select top-K where score > 0.2 (K = min(5, entries_above_threshold))
  5. Budget check: sum(selected.token_count) < 3000 tokens
     - If over budget, drop lowest-scoring entries until under

PHASE 2: Retrieve (read only selected files)
  1. Read each selected memory file
  2. Inject into delegation context as "Relevant Memories" section
  3. Update last_retrieved and retrieval_count in memory-index.json
```

**Token budget**: Phase 1 costs ~400-10K tokens (index scan). Phase 2 costs ~1500-3000 tokens (selected content). Total: ~2000-13K tokens. For the current 8-memory vault, total cost is ~2000 tokens.

### 6. Comparison of Approaches

#### Option A: JSON Manifest (Recommended)

```
memory-index.json with per-entry metadata
```

| Dimension | Assessment |
|-----------|------------|
| Token cost (scan) | ~50 tokens/entry. 200 entries = 10K tokens |
| Scoring capability | keyword overlap + topic match + recency |
| Infrastructure needed | None (jq or LLM reads JSON) |
| Maintenance | Auto-regenerated on /learn |
| Strengths | Machine-queryable, budget-aware, proven pattern (index.json) |
| Weaknesses | Keyword matching less precise than semantic search |

#### Option B: Hierarchical Topic Index (Markdown)

```
topic-index.md with ~30 lines per topic, 8 topics
```

| Dimension | Assessment |
|-----------|------------|
| Token cost (scan) | ~240 lines = ~3K tokens |
| Scoring capability | Topic matching only, no keyword scoring |
| Infrastructure needed | None |
| Maintenance | Must be manually curated or regenerated |
| Strengths | Human-readable, compact |
| Weaknesses | Cannot do keyword-level relevance scoring, loses per-entry metadata |

#### Option C: Embedding Vectors

```
Vector database (Chroma, FAISS, or MCP embedding server)
```

| Dimension | Assessment |
|-----------|------------|
| Token cost (scan) | Zero (vector similarity is non-LLM) |
| Scoring capability | Semantic similarity (best quality) |
| Infrastructure needed | Embedding model + vector store |
| Maintenance | Re-embed on every write |
| Strengths | Best retrieval quality, handles synonyms and paraphrases |
| Weaknesses | Requires infrastructure not currently present, adds dependency |

#### Option D: Hybrid JSON + Grep Verification

```
JSON manifest for scoring + grep for verification
```

| Dimension | Assessment |
|-----------|------------|
| Token cost (scan) | ~50 tokens/entry + grep is free |
| Scoring capability | keyword + topic + grep confirmation |
| Infrastructure needed | None |
| Maintenance | Auto-regenerated on /learn |
| Strengths | Best accuracy without embeddings, grep catches false negatives |
| Weaknesses | Two-step process, grep adds latency |

**Recommendation**: Start with **Option A** (JSON manifest). It provides 80% of the value with zero infrastructure cost. The `keywords` field in the index enables the same overlap scoring that skill-memory already uses. Option D (hybrid) is a natural evolution if keyword matching proves insufficient.

### 7. Index Synchronization Strategy

The memory-index.json must stay in sync with actual memory files. Three strategies:

**Strategy 1: Regenerate on /learn (Recommended)**

Every `/learn` operation already regenerates `index.md` from filesystem state (see "Index Regeneration Pattern" in skill-memory). Adding `memory-index.json` regeneration to this same step is trivial:

```bash
# After memory operations complete, regenerate index
for mem in .memory/10-Memories/MEM-*.md; do
  # Extract frontmatter fields
  title=$(grep -m1 "^title:" "$mem" | cut -d'"' -f2)
  topic=$(grep -m1 "^topic:" "$mem" | cut -d'"' -f2)
  tags=$(grep -m1 "^tags:" "$mem")
  # Extract keywords from body (top 8 by frequency)
  # Count tokens (wc -w as approximation)
  # Build JSON entry
done
# Write complete memory-index.json
```

Benefits: Idempotent, self-healing, no drift possible after /learn.

**Strategy 2: Validate on retrieval**

Before using the index for retrieval, check that all listed files exist and no unlisted MEM-*.md files are present. If mismatch, regenerate.

Benefits: Catches manual edits. Cost: adds ~50ms per retrieval.

**Strategy 3: File watcher (rejected)**

A filesystem watcher daemon would detect changes in real time. Rejected because: adds infrastructure, unreliable across sessions, overkill for a vault of <200 files.

**Recommendation**: Strategy 1 (regenerate on /learn) as primary, Strategy 2 (validate on retrieval) as safety net. The validation step is cheap and prevents stale index issues if someone manually edits memory files.

### 8. Retrieval Statistics Enable Natural Decay

Adding `last_retrieved` and `retrieval_count` fields to both the index and memory frontmatter creates a natural decay mechanism without expiration dates:

- **Frequently retrieved memories** (high retrieval_count) are reinforced -- they surface reliably
- **Never-retrieved memories** (retrieval_count = 0 after N task cycles) become pruning candidates
- **Recently retrieved memories** get a recency bonus in scoring
- **Stale memories** (last_retrieved > 90 days) can trigger a review prompt during `/todo`

This mirrors the Generative Agents paper's recency-weighted scoring and GitHub Copilot's citation verification pattern, adapted to a file-based system without embedding infrastructure.

## Decisions

1. **JSON manifest over markdown index**: Machine-queryable index is essential for automated scoring. The current `index.md` will remain for human navigation; `memory-index.json` is the machine counterpart.

2. **Two-phase retrieval**: Scan index (cheap) then read selected files (targeted). Never inject the full vault.

3. **Keyword overlap scoring**: Reuse the same overlap scoring algorithm from skill-memory's search phase. No new algorithms needed.

4. **Regenerate-on-write + validate-on-read**: Index stays in sync through regeneration after every `/learn` and validation before every retrieval.

5. **Token budget of 3000 for injected memories**: Limits the maximum context cost of auto-retrieval. Roughly 3-5 memories per operation.

6. **No embedding infrastructure required**: The JSON manifest with keyword scoring provides sufficient retrieval quality for a curated vault of <200 entries.

## Recommendations

1. **Implement `memory-index.json` generation** in skill-memory as part of the existing index regeneration step. This is the foundational piece.

2. **Add retrieval fields to memory frontmatter**: `last_retrieved` and `retrieval_count` should be added to the YAML frontmatter template. Existing memories get `null`/`0` defaults.

3. **Build the two-phase retrieval function** as a reusable pattern that can be called from skill-researcher, skill-planner, and skill-implementer delegation stages.

4. **Make retrieval default for /research**: The index scan is cheap enough (~400 tokens for 8 memories) to always run. Add `--no-remember` for opt-out.

5. **Set token budget at 3000 tokens**: This allows 3-5 full memories to be injected without significant context impact.

6. **Add `/memory --reindex` command**: Force-regenerate `memory-index.json` from filesystem state for manual recovery.

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Keyword matching misses relevant memories | Medium | Low | Grep fallback catches false negatives; vault is small enough for manual curation |
| Index drift from manual file edits | Low | Medium | Validate-on-read detects and auto-repairs |
| Token budget exceeded by large memories | Low | Medium | `token_count` in index enables pre-flight budget check |
| Index file grows too large (>200 entries) | Low | Medium | At 50 tokens/entry, 500 entries = 25K tokens -- still manageable. Beyond that, add topic-level pre-filtering |
| Retrieval adds latency to every /research | Low | Low | Index scan is ~50ms. File reads add ~100ms. Total <200ms |

## Appendix

### Search Queries Used

1. "AI memory retrieval token efficiency compact index without context bloat 2025 2026"
2. "Mem0 memory indexing architecture structured metadata retrieval without full context injection"
3. "RAG retrieval token budget management compact memory index schema JSON manifest approach"
4. "xMemory hierarchical memory retrieval theme semantic episode uncertainty gating token reduction"
5. "GitHub Copilot memory architecture how memories stored indexed retrieved coding agent 2025 2026"
6. "memory index JSON manifest per-entry metadata keywords summary token-efficient retrieval AI agent local file"

### References

- [Mem0: Building Production-Ready AI Agents with Scalable Long-Term Memory](https://arxiv.org/abs/2504.19413)
- [Beyond RAG for Agent Memory: Retrieval by Decoupling and Aggregation (xMemory)](https://arxiv.org/abs/2602.02007)
- [Building an Agentic Memory System for GitHub Copilot](https://github.blog/ai-and-ml/github-copilot/building-an-agentic-memory-system-for-github-copilot/)
- [Searchable Agent Memory in a Single File](https://eric-tramel.github.io/blog/2026-02-07-searchable-agent-memory/)
- [State of AI Agent Memory 2026](https://mem0.ai/blog/state-of-ai-agent-memory-2026)
- [How xMemory Cuts Token Costs and Context Bloat in AI Agents](https://venturebeat.com/orchestration/how-xmemory-cuts-token-costs-and-context-bloat-in-ai-agents)
- [RAG vs Memory: Addressing Token Crisis in Agentic Tasks](https://agamjn.com/technical/2025/10/11/token-crisis-in-agentic-tasks.html)

### Token Cost Projections

| Vault Size | Index Scan Cost | Top-5 Retrieval Cost | Total |
|-----------|----------------|---------------------|-------|
| 8 entries (current) | ~400 tokens | ~2,500 tokens | ~2,900 |
| 50 entries | ~2,500 tokens | ~2,500 tokens | ~5,000 |
| 100 entries | ~5,000 tokens | ~2,500 tokens | ~7,500 |
| 200 entries | ~10,000 tokens | ~3,000 tokens | ~13,000 |
| 500 entries | ~25,000 tokens | ~3,000 tokens | ~28,000 |

At 500+ entries, topic-level pre-filtering (scan only entries matching task domain) would reduce the scan cost back to ~5K tokens.
