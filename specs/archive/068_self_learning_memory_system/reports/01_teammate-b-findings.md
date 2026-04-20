# Teammate B Findings: Prior Art and Alternative Approaches
## Task 68: Self-Learning Memory System

**Role**: Teammate B — Prior Art, Best Practices, Alternative Patterns
**Date**: 2026-04-15

---

## Key Findings

### 1. The Foundational Model: Generative Agents Memory Streams (Stanford/Google, 2023)

The most cited prior art is the "Generative Agents" paper (Park et al., UIST 2023). Its memory stream architecture defines the gold standard scoring formula:

```
retrieval_score = α·recency + β·importance + γ·relevance
```

Where:
- **Recency**: Exponential decay from last access time (not creation time)
- **Importance**: LLM-assigned salience score at capture time (1-10)
- **Relevance**: Cosine similarity to current query embedding

All three are normalized to [0,1] and combined with equal weights (α=β=γ=1/3 in the original paper). The key insight is that **recency is measured from last retrieval, not creation**, which implements a natural spaced-repetition-like reinforcement.

**Applicability to task 68**: This scoring formula directly applies to the auto-retrieval side. The system can rank `.memory/` entries by this composite score at lifecycle checkpoints.

### 2. Reflexion Pattern: Self-Reflection as Memory (NeurIPS 2023)

Reflexion (Shinn et al., 2023) shows that LLM agents dramatically improve by converting task outcomes into verbal summaries stored in an episodic memory buffer. The pattern:

1. Agent completes task → receives feedback signal (success/failure/partial)
2. Self-reflection model generates a verbal critique: "I failed because X; next time I should Y"
3. Critique stored as a dated memory entry
4. On next similar task, relevant critiques are loaded into context

**Key result**: Reflexion outperforms prior SOTA on HumanEval, MBPP, and Leetcode Hard coding benchmarks. The improvement comes not from more computation but from structured post-hoc reflection stored as retrievable memory.

**Applicability to task 68**: The GATE OUT phase of `/implement`, `/research`, and `/plan` commands is the natural Reflexion checkpoint. After each command completes, an LLM-driven reflection step could generate 1-3 high-signal memories about what was learned.

### 3. Mem0's AUDN Cycle: The Industry-Standard Decision Pattern

Mem0 (production system, 2024-2025) establishes the canonical create/update/skip decision architecture:

```
New memory candidate → semantic search (top-10 similar) → LLM decides:
  ADD    - no semantically equivalent memory exists
  UPDATE - new fact augments/refines existing memory
  DELETE - new fact contradicts existing memory
  NOOP   - fact is redundant (e.g., "likes pizza" vs "loves pizza")
```

The decision is LLM-driven, not rule-based. The LLM receives both the candidate and retrieved similar memories, then uses a "tool call" interface to select the operation.

**Performance**: Mem0 achieves 26% improvement over OpenAI memory on the LOCOMO benchmark, with 91% token reduction vs full-context approaches and p95 retrieval latency of 200ms.

**Applicability to task 68**: The AUDN cycle should govern all memory writes. The existing `skill-memory` command likely has some version of this, but the system needs to apply it automatically at lifecycle checkpoints rather than requiring `/learn` invocation.

### 4. MemGPT's Virtual Context (OS-Style Memory Paging)

MemGPT (Packer et al., UC Berkeley, 2023) treats the LLM context window as RAM and external storage as disk. Agents use explicit function calls to page memories in/out:

- **Main context** (fast, limited): Current task state, active memories
- **External storage** (slow, unlimited): Archived memories, full history
- **Paging triggers**: Context approaching limit, topic shift detected, explicit retrieval query

The agent controls its own memory management rather than having it externally orchestrated.

**Applicability to task 68**: The `.memory/` vault already functions as the "disk" tier. The question is whether to give agents explicit paging tools or handle retrieval transparently in GATE IN phases.

### 5. GitHub Copilot's Agentic Memory System (Production Evidence, 2024-2025)

GitHub's production system for Copilot provides the most directly relevant prior art for coding agents:

- **Capture trigger**: Agent decides to invoke memory creation as a tool call when it discovers "something that's likely to have actionable implications for future tasks"
- **What makes a memory useful**: Specific facts tied to concrete code locations; patterns observed across multiple files; context about *why* consistency matters
- **Verification over scoring**: Rather than offline importance scoring, memories are verified at retrieval time — if citations are stale, the agent corrects and re-stores
- **Retrieval timing**: Memories loaded at session start for the target repository (not on-demand)
- **Measured impact**: 7% increase in pull request merge rates when agents access memories

**Key insight**: GitHub chose **verification-over-prediction** for noise filtering. It is easier to verify whether a memory is still accurate than to predict whether a newly captured fact will be useful. Stale memories self-heal as agents observe and correct them.

### 6. A-Mem: Zettelkasten-Style Agentic Memory (2025)

A-Mem implements a Zettelkasten (slip-box) approach:

- Each memory is a **structured note** with: content, timestamp, keywords, tags, contextual description, embedding vector
- New memories trigger a **linking pass**: find top-k similar existing memories, ask LLM to establish semantic connections
- Memories **evolve**: when new experiences integrate, they can trigger updates to related historical memories (propagating refinements through the network)
- No rigid hierarchy — connections emerge dynamically

**Applicability to task 68**: The linking pass is expensive but valuable. A lightweight version (keyword-based linking rather than embedding-based) could run at capture time to connect new memories to existing ones.

### 7. Memory Decay and Spaced Repetition Applied to AI

CortexGraph (2024) and related work apply Ebbinghaus forgetting curves to agent memory:

- Memories start with full strength (score = 1.0)
- Decay follows: `strength(t) = e^(-t/stability)` where `stability` increases with each successful retrieval
- Memories accessed frequently become harder to decay (natural spaced repetition)
- Unused memories eventually fall below a retrieval threshold and are archived or pruned

**The "is forgetting a bug or feature?" debate**: Empirically, systems with decay outperform hoarding systems because:
1. Stale memories hurt more than missing memories (they inject false context)
2. High-signal memories naturally survive (they get retrieved and reinforced)
3. Storage remains bounded

**Applicability to task 68**: A retrieval-count field in memory metadata enables lightweight decay tracking without complex time-series math. Each `/research`, `/implement`, or `/plan` that retrieves a memory increments its `retrieval_count`. Memories never retrieved after N task cycles become candidates for archival.

---

## Recommended Approach

Based on the convergent evidence across these systems, I recommend a **three-tier architecture** with **lifecycle-checkpoint capture** and **composite-score retrieval**:

### Tier Architecture

```
Tier 1 (In-context): Current task state, explicitly loaded memories (< 50 entries)
Tier 2 (Active vault): .memory/ files, searched at GATE IN by composite score
Tier 3 (Archive): .memory/archive/, low-retrieval-count memories after decay threshold
```

### Capture Pattern (at GATE OUT of lifecycle commands)

Run after `/implement` completion, `/research` completion, `/plan` creation, `/todo` archival, `/review` runs:

```
1. Gather: Collect task artifacts from current operation
2. Reflect: LLM generates 1-5 candidate memories from artifacts
3. Filter: Score each candidate (importance 1-10); discard < 6
4. Deduplicate: AUDN cycle — semantic search, LLM decides ADD/UPDATE/DELETE/NOOP
5. Store: Write accepted memories with metadata (timestamp, source_task, retrieval_count=0, importance)
6. Link: Keyword-based linking to related existing memories (lightweight, optional)
```

### Retrieval Pattern (at GATE IN of agent operations)

Run at start of `/research`, `/plan`, `/implement`:

```
1. Embed: Create embedding of current task description + context
2. Score: composite_score = 0.4·relevance + 0.3·importance + 0.3·recency
3. Rank: Sort all .memory/ files by composite score
4. Budget: Load top-K memories where K keeps token budget under 2000 tokens
5. Inject: Insert into agent context as "Relevant memory context:" block
```

### What to Capture vs. Skip

Based on GitHub Copilot and Mem0 production evidence:

**Capture** (high-signal patterns):
- Repository-specific conventions discovered during implementation (naming, structure, patterns)
- Errors encountered and their resolutions (from errors.json entries)
- Successful approaches to task types (from implementation summaries)
- External tool configurations and their quirks
- Dependencies between components discovered during research

**Skip** (low-signal noise):
- Intermediate reasoning steps within a single task
- Standard Markdown or code syntax (already in model weights)
- Task status updates (state.json handles this)
- File contents that can be read on-demand
- Generic best practices not specific to this repository

### Decision Rules for AUDN Operations

```
ADD:   No semantically similar memory exists (cosine similarity < 0.85 to all existing)
UPDATE: Similar memory exists (similarity 0.85-0.95); new fact adds precision or recency
DELETE: Similar memory exists (similarity > 0.95); new fact directly contradicts it
NOOP:  Similar memory exists (similarity > 0.95); new fact is merely paraphrase
```

---

## Evidence / Examples

### Evidence 1: Reflexion's Checkpoint Pattern Maps to GATE OUT

The Reflexion paper shows agents capturing reflections at episode boundaries (equivalent to command GATE OUT phases). The most effective reflections are:
- Task-outcome-conditional (what happened)
- Failure-focused (what went wrong and why)
- Prescriptive (what to do differently next time)

This directly maps to: after `/implement` phase completion, run a brief reflection on what worked, what was tricky, and what patterns emerged.

### Evidence 2: GitHub Copilot's 7% PR Merge Rate Improvement

This is the strongest evidence that auto-loaded coding memories provide measurable value. The key is repository-scoped loading at session start (not per-query on-demand loading), which aligns with loading memories at GATE IN of each command rather than mid-execution.

### Evidence 3: Mem0's 91% Token Reduction vs Full Context

Production data shows that selective retrieval (top-k semantically similar) dramatically outperforms either (a) loading all memories or (b) no memory. The optimal k appears to be 5-10 memories for most queries, with a hard token budget cap.

### Evidence 4: Decay Prevents Memory Rot

The "memory rot" failure mode (stale memories injecting false context) is well-documented. The CortexGraph and GitHub Copilot approaches both address this differently:
- CortexGraph: time-based exponential decay
- GitHub Copilot: verification-at-retrieval (citation checking)

For a coding agent system, **verification-at-retrieval is more appropriate** than time decay, because:
- Code changes are event-driven, not time-driven
- A convention established 6 months ago may still be valid
- A pattern observed yesterday may be immediately invalidated by a refactor

### Evidence 5: NOOP as the Default (Most Candidates Should Be Skipped)

Mem0's production data shows that the majority of extracted candidate memories result in NOOP operations — the system already knows the fact in some form. This is a feature, not a bug: aggressive extraction followed by conservative storage gives high recall with high precision.

---

## Alternative Architectures Considered

### Alternative A: Proactive Memory via Hooks (Continuous Capture)

Rather than checkpoint-based capture, monitor all file writes and tool calls, continuously extracting memories in the background.

**Pros**: Complete capture; nothing missed
**Cons**: Very noisy; extremely expensive in tokens; hard to bound storage growth

**Verdict**: Rejected. The evidence strongly favors deliberate checkpoint-based capture over continuous monitoring.

### Alternative B: User-Controlled Memory Only (Current State)

Keep the `--remember` flag and `/learn` command as opt-in; no automatic capture.

**Pros**: Zero noise; full user control; no token overhead on non-memory tasks
**Cons**: Requires remembering to use it; knowledge siloed per user habit; misses systematic patterns

**Verdict**: Rejected for the use case. The task specifically requires automatic capture to surface patterns users wouldn't think to manually record.

### Alternative C: Embedding-Only Retrieval (No Keyword Fallback)

Use vector embeddings exclusively for retrieval; no keyword/tag-based matching.

**Pros**: Semantic matching handles paraphrases and synonyms
**Cons**: Requires embedding model at retrieval time; cold-start problem for small vaults; slower than keyword lookup

**Verdict**: Hybrid approach recommended. Use keyword matching for small vaults (< 50 memories) and add embedding-based semantic search when vault grows larger. The current `.memory/` implementation uses MCP search which likely handles this.

### Alternative D: MemGPT-Style Agent-Controlled Paging

Give agents explicit memory management tools (`memory_search`, `memory_store`, `memory_page_in`).

**Pros**: Agents can make context-aware memory decisions; more flexible than static checkpoint capture
**Cons**: Increases agent complexity; agents may not invoke memory tools when they should; requires prompting discipline

**Verdict**: Partial adoption. Agents should have read access to trigger retrieval, but writes should be automated at checkpoints (not left to agent discretion), to ensure systematic capture regardless of agent focus.

---

## Confidence Level

**High confidence** (well-supported by multiple independent sources):
- Composite retrieval scoring (recency × importance × relevance) is the right approach
- AUDN cycle (ADD/UPDATE/DELETE/NOOP) for deduplication is industry standard
- Checkpoint-based capture at command boundaries is more signal-dense than continuous capture
- Token budgets on retrieval (5-10 memories, < 2000 tokens) are appropriate

**Medium confidence** (supported by evidence but implementation-specific):
- Importance threshold of 6/10 for filtering captured memories
- Cosine similarity thresholds (0.85, 0.95) for AUDN decisions — these need empirical tuning
- Verification-at-retrieval (GitHub approach) better than time-decay for code repositories
- Zettelkasten-style linking adds value for cross-task pattern discovery

**Lower confidence** (theoretical, less direct evidence for this specific use case):
- Decay archival after N task cycles without retrieval — may be premature for small vaults
- Whether embedding-based search is worth the overhead vs. keyword-based given current vault sizes

---

## Sources

- [Generative Agents: Interactive Simulacra of Human Behavior (ACM UIST 2023)](https://dl.acm.org/doi/fullHtml/10.1145/3586183.3606763)
- [Reflexion: Language Agents with Verbal Reinforcement Learning (NeurIPS 2023)](https://arxiv.org/abs/2303.11366)
- [Agentic RAG Survey (arXiv 2501.09136)](https://arxiv.org/abs/2501.09136)
- [Mem0: Building Production-Ready AI Agents with Scalable Long-Term Memory (arXiv 2504.19413)](https://arxiv.org/abs/2504.19413)
- [Building an Agentic Memory System for GitHub Copilot](https://github.blog/ai-and-ml/github-copilot/building-an-agentic-memory-system-for-github-copilot/)
- [A-Mem: Agentic Memory for LLM Agents (arXiv 2502.12110)](https://arxiv.org/html/2502.12110v1)
- [MemGPT: Towards LLMs as Operating Systems (arXiv 2310.08560)](https://arxiv.org/abs/2310.08560)
- [AI Agent Memory: Comparative Analysis of LangGraph, CrewAI, and AutoGen](https://dev.to/foxgem/ai-agent-memory-a-comparative-analysis-of-langgraph-crewai-and-autogen-31dp)
- [CortexGraph: Temporal Memory with Human-Like Forgetting Curves](https://github.com/prefrontal-systems/cortexgraph)
- [Memory in the Age of AI Agents Survey (arXiv 2512.13564)](https://arxiv.org/abs/2512.13564)
- [AWS AgentCore Long-Term Memory Deep Dive](https://aws.amazon.com/blogs/machine-learning/building-smarter-ai-agents-agentcore-long-term-memory-deep-dive/)
- [Self-Reflection in LLM Agents: Effects on Problem-Solving Performance (arXiv 2405.06682)](https://arxiv.org/abs/2405.06682)
