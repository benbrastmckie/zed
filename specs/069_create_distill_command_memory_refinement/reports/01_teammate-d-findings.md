# Teammate D Findings: Strategic Direction for /distill

**Artifact**: 01
**Teammate**: D (Horizons)
**Focus**: Long-term alignment, lifecycle positioning, and creative approaches

---

## Key Findings

### 1. Lifecycle Position: /distill Belongs After /todo, Not During It

The current memory lifecycle is:

```
/learn (input) -> auto-retrieval (use) -> /todo harvest (collect candidates) -> [GAP]
```

The gap after `/todo` harvest is where distillation fits cleanly. The reasoning:
- `/todo` creates new memories from completed tasks (addition)
- `/distill` processes the accumulated vault (refinement)
- They are semantically distinct operations: one populates, one curates

**Proposed lifecycle:**
```
/learn -> auto-retrieval -> /todo harvest -> /distill (maintain quality)
                                          ^
                              /todo should suggest /distill here
```

This mirrors a natural information lifecycle: capture -> use -> harvest -> refine. Running distillation *during* `/todo` would conflate archival with curation, making `/todo` slower and harder to test/reason about.

### 2. The Vault at Scale: Three Operational Regimes

The memory vault behaves differently at different sizes, and `/distill` must evolve accordingly:

| Vault Size | Primary Problem | /distill Strategy |
|------------|-----------------|-------------------|
| 0-30 memories | None | Lightweight: report quality score only |
| 30-150 memories | Keyword drift, duplicates | Active: merge overlapping entries, prune low-value |
| 150-500 memories | Retrieval precision degrades | Aggressive: cluster-based compression, meta-memories |
| 500+ memories | Index scoring breaks down | Structural: hierarchical indexing, domain sharding |

The current vault has 8 memories, all with `retrieval_count: 0`. This is exactly the "no problem yet" regime. `/distill` should be designed for the 30-150 regime as the primary use case, but architected to scale.

**Key insight**: At 0 retrievals across all entries, the vault has never been tested in production. `/distill` should first *observe* retrieval patterns before aggressively changing the vault.

### 3. Cross-System Implications: System-Neutral Distillation

The vault is explicitly shared between Claude Code and OpenCode (README states this). Both systems:
- Write memories with the same `MEM-{slug}.md` format
- Share `memory-index.json`
- Use different MCP ports (22360 vs 27124)

**Problem**: If both systems run `/distill` concurrently, they will conflict on `memory-index.json` writes.

**Recommended approach**: Make `/distill` system-neutral in its *logic* but safe in its *execution*:

1. `/distill` should use file-level locking (or detect concurrent modification via git status) before writing
2. Memories should NOT carry system-of-origin tags - distillation should treat all memories as equivalent regardless of which system created them
3. A `distill_lock` file in `.memory/` (like npm's lockfile) prevents concurrent runs

**One exception**: The `source` frontmatter field could optionally be preserved to help identify which system contributed which knowledge. This is useful for debugging but should NOT affect distillation decisions.

### 4. Extension Architecture Alignment: Core Command, Not Extension

`/distill` should be a **core command** (always available), not part of the memory extension, for these reasons:

1. Memory maintenance is a system responsibility, not a domain responsibility - all projects need it
2. The memory extension handles *creation* (skill-memory); distillation is *maintenance*
3. Making it an extension would create an awkward dependency where the core system needs an optional component

However, `/distill` SHOULD be **domain-aware** in its *heuristics*:
- Memories tagged with `epi/` topics should be clustered separately from `python/` topics
- Domain-specific memories should not be merged across domains (a Python pattern is not an R pattern)
- The distillation agent should use topic paths as natural sharding boundaries

**Implementation**: `/distill` lives in `.claude/commands/distill.md` and delegates to a `skill-distill` (direct execution), which is part of the memory extension's skill set but callable from the core command.

### 5. Creative/Unconventional Approaches

#### 5a. Agent-Evaluated Memory Quality

The most powerful unconventional approach: use the agent system itself to evaluate memory quality. Instead of simple keyword overlap counting, the distillation agent reads each memory and asks:

> "Would this memory improve the output of a future agent working on a related task? How much?"

This turns distillation from a syntactic operation (keyword overlap) into a semantic one (value estimation). The agent can:
- Detect memories that describe superseded approaches
- Identify memories that are too abstract to be actionable
- Flag memories that contradict each other

**Concrete mechanism**: A `distill-agent` (model: opus) receives all memories in a domain cluster and outputs a structured evaluation:
```json
{
  "keep": ["MEM-foo", "MEM-bar"],
  "merge": [["MEM-a", "MEM-b"] -> "MEM-ab"],
  "archive": ["MEM-obsolete"],
  "promote": ["MEM-important" -> priority_boost]
}
```

#### 5b. Memory Health Score (Analog to repository_health)

The system already tracks `repository_health` in `state.json`. A `memory_health` field would provide parallel visibility:

```json
"memory_health": {
  "last_distilled": "2026-04-15T00:00:00Z",
  "total_memories": 8,
  "never_retrieved": 8,
  "avg_retrieval_count": 0.0,
  "stale_count": 0,
  "duplicate_risk_pairs": [],
  "health_score": 85,
  "status": "healthy"
}
```

`/distill` updates this score. `/todo` reads it and suggests `/distill` when `health_score < 70` or `never_retrieved` is too high relative to total memories.

This provides a feedback loop: `/todo` knows whether to suggest `/distill` based on objective data, not just task count.

#### 5c. Meta-Memories: Summaries of Clusters

When a cluster of 5+ related memories accumulates (e.g., 6 memories tagged `agent-system/`), `/distill` can generate a single "meta-memory" that summarizes the cluster:

```
MEM-agent-system-overview.md  # Meta-memory summarizing 6 related entries
```

Meta-memories:
- Load first during scoring (lower token cost for high-coverage context)
- Link to constituent memories via `[[filename]]` Obsidian syntax
- Are marked with `category: META` and `is_meta: true` in frontmatter

This enables a two-tier retrieval: meta-memories provide broad context, constituent memories provide deep detail when needed.

#### 5d. /todo as "Next Steps Advisor" Pattern

The requirement to have `/todo` suggest `/distill` and `/review` is an instance of a broader pattern that could be formalized:

**Advisor Pattern**: Commands that complete a lifecycle phase assess system state and suggest the next appropriate action.

Current `/todo` output ends with:
```
Next Steps:
1. Review archive at specs/archive/
2. Run /review for codebase analysis
```

Extended with `/distill` awareness:
```
Next Steps:
1. Review archive at specs/archive/
2. Run /distill (memory health: 8 memories, 0 retrievals - vault untested)
3. Run /review for codebase analysis
```

The selection logic should be *conditional*, not always-on:
- Suggest `/distill` when: `memory_health.never_retrieved > 50%` OR `total_memories > 30` OR `last_distilled` is more than 30 days ago
- Suggest `/review` when: more than 5 tasks archived since last review OR build_errors > 0

This makes `/todo`'s suggestions diagnostic (based on actual system state) rather than generic.

#### 5e. Scheduled Background Distillation

The `schedule` skill in this system enables recurring tasks. `/distill` could be scheduled to run automatically:

```
/schedule weekly /distill --auto
```

With `--auto` flag:
- No interactive prompts
- Conservative mode only (merge obvious duplicates, archive never-retrieved after 90 days)
- Commits changes and reports summary to git log
- Sends notification via next command execution

This addresses the "maintenance debt" problem: users who don't remember to run `/distill` still benefit from it.

### 6. The /todo Suggestion as a Broader Pattern

Rather than hardcoding `/distill` and `/review` suggestions in `/todo`, a more composable approach:

**Command Hooks**: Each command that affects system state can register "assessment hooks" that `/todo` calls at the end:

| Hook Source | Assessment Condition | Suggested Command |
|-------------|---------------------|-------------------|
| memory extension | memory_health.health_score < 70 | `/distill` |
| review command | last_review > 30 days ago | `/review` |
| errors command | errors.json has unfixed > 5 | `/errors` |

This is more maintainable than hardcoding suggestions in `/todo`, and extensible (new extensions can register their own hooks).

For the immediate implementation, hardcoding 2-3 suggestions is fine. But the pattern should be documented as the intended direction.

---

## Recommended Approach

### Command Design

`/distill` should be a **manual, interactive command** with an optional `--auto` flag for scheduled use.

**Core modes:**
```
/distill              # Interactive full distillation
/distill --report     # Show health report only (no changes)
/distill --auto       # Non-interactive conservative mode
/distill --domain epi # Distill only a specific topic domain
```

**Distillation operations (in order of safety):**
1. **Report**: Compute and display health metrics (always safe)
2. **Prune stale**: Archive memories never retrieved after 60+ days (with confirmation)
3. **Merge duplicates**: Combine memories with >80% keyword overlap (with preview)
4. **Compress**: Reduce verbose memories to essential content (agent-assisted, with review)
5. **Generate meta-memories**: Create cluster summaries when 5+ related memories exist

### /todo Integration

Add to `/todo` Step 7 (Output) after the existing "Next Steps" section:

```
{If memory vault exists and memory_health assessment warrants:}
Memory: {N} memories in vault, last distilled {X} days ago
  -> Consider running /distill to maintain retrieval quality
```

The conditional logic:
- Always show if `never_retrieved / total_memories > 0.5` (more than half never used)
- Always show if total_memories > 30
- Show if `last_distilled` timestamp in state.json is older than 30 days
- Suppress if vault is empty or has fewer than 5 memories

### State Tracking

Add `memory_health` to `state.json`:
```json
"memory_health": {
  "last_distilled": null,
  "distill_count": 0,
  "total_memories": 8,
  "health_score": 85
}
```

`/distill` updates this after each run. `/todo` reads it to make conditional suggestions.

---

## Evidence/Examples

### Existing System Patterns This Design Respects

1. **repository_health parallel**: The existing `repository_health` field in `state.json` (tracking `todo_count`, `fixme_count`, `build_errors`, `status`) provides a direct template for `memory_health`. The pattern is already established.

2. **Direct execution skills**: `/todo`, `/refresh`, `/fix-it` all use "direct execution" (no subagent delegation). `/distill` in conservative mode fits this pattern. The agent-assisted compression mode would use a `distill-agent`, parallel to how code review uses `code-reviewer-agent`.

3. **AskUserQuestion gate**: The `/learn` skill has a mandatory interactive requirement: "STOP and call AskUserQuestion... Write NOTHING to disk until user responds." `/distill` should use the same gate for destructive operations (prune, merge, compress).

4. **Validate-on-read**: The memory system already uses validate-on-read for the JSON index. `/distill` should use the same pattern to detect stale indices before distillation.

5. **Topic hierarchy as sharding boundary**: The existing topic paths (`zed/config`, `agent-system/architecture`) naturally define domain clusters. `/distill --domain zed` would process only memories with `zed/` topic prefix.

### The 8-Memory Current State

All 8 current memories share these properties:
- `retrieval_count: 0` - Never retrieved in production
- `created: 2026-04-15` - Created the same day, likely during a bulk `/learn` session
- Diverse topics: 5 zed-specific, 3 agent-system

This is the ideal starting state for `/distill` development: enough memories to test against, but not enough to cause pain. The `never_retrieved` signal is particularly valuable - at 8 memories with 0 retrievals, the retrieval scoring hasn't been validated yet.

A `/distill --report` run would surface: "8 memories, 0 retrievals - vault is new, no distillation needed yet."

---

## Confidence Level

**High** for:
- Lifecycle positioning (after /todo, before next cycle)
- Core command (not extension) architecture
- State tracking via memory_health in state.json
- /todo conditional suggestion logic
- AskUserQuestion gate for destructive operations

**Medium** for:
- Agent-evaluated memory quality (powerful but token-expensive; may not be worth it at small scale)
- Meta-memory generation (useful at 50+ memories, premature at 8)
- Scheduled background distillation (depends on user workflow adoption)

**Low** for:
- Specific health score thresholds (30 days, 50% never-retrieved, etc.) - these are arbitrary starting points that should be tuned based on actual usage patterns
- Hook-based advisor pattern for /todo - good long-term direction but adds complexity without immediate payoff

---

## Summary

`/distill` fits naturally after `/todo` in the memory lifecycle as a maintenance command distinct from creation. It should be a core command, system-neutral (treating all memories equally regardless of origin), and domain-aware in its clustering. The most valuable unconventional ideas are: (1) a `memory_health` score in `state.json` that drives conditional `/distill` suggestions from `/todo`; and (2) agent-evaluated quality for compression rather than pure keyword counting. The immediate implementation should be conservative (report, prune, merge) with the agent-assisted path as a future enhancement once retrieval patterns are established.
