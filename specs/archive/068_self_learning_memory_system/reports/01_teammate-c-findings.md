# Teammate C Findings: Critical Analysis of Self-Learning Memory System

**Task**: 68 - Design self-learning memory system with automatic capture and retrieval
**Role**: Critic (Teammate C) - Gaps, Risks, and Blind Spots
**Date**: 2026-04-15

---

## Key Findings

### Finding 1: Postflight Phase is Architecturally Prohibited for Memory Operations

This is the most fundamental constraint the design must address. The postflight-tool-restrictions standard (`standards/postflight-tool-restrictions.md`) is explicit:

- Postflight is LIMITED TO: state.json updates, TODO.md edits, git commits, artifact cleanup
- Prohibited: Any MCP tool calls ("Domain tools are agent work"), `grep` on source files ("Analysis is agent work"), Write to `.claude/` directories, and any source modification

Auto-capture at lifecycle checkpoints (GATE OUT / postflight) would require memory search (MCP), content analysis, and writing to `.memory/` -- all of which are prohibited in postflight. The proposed design cannot simply "add a learning step to GATE OUT phases" without violating the foundational architecture standard.

**The correct location for memory capture is inside the agent itself (during delegation), not postflight.** This means redesigning all target agents (general-research-agent, general-implementation-agent, planner-agent) to emit memory candidates in their return metadata, which is a much larger change than "add a postflight step."

### Finding 2: The Mandatory Interactive Requirement is Irreconcilable with Automation

The skill-memory SKILL.md contains a non-negotiable constraint:

> **MANDATORY INTERACTIVE REQUIREMENT -- DO NOT SKIP**: STOP at Step 4 and call AskUserQuestion to show files. Write NOTHING to disk until user responds. These are not optional. Running autonomously without user input is a critical failure.

Every memory write requires explicit user confirmation per segment. Auto-capture -- by definition -- bypasses this requirement. A design that removes or circumvents the AskUserQuestion gates would be rewriting the memory skill's core contract, not extending it. Any auto-capture design must either:
- Accept that it cannot use the existing `skill-memory` as-is (needs a new "autonomous memory" code path with weaker guarantees), or
- Accept that "automatic capture" actually means "suggest memories to the user at the end of a lifecycle event" -- which is not truly automatic

### Finding 3: Memory Bloat is Likely and Difficult to Mitigate Without Human Judgment

The current vault has 8 memories, all curated by a human using `/learn`. With 67 completed tasks and only 8 memories, the human selection rate is approximately 12% of tasks yielding any memory. Auto-capture at every implementation completion would produce a vastly different ratio.

**Concrete problem**: What constitutes a "genuinely useful" memory cannot be determined automatically with confidence. Consider:
- Task 67 (strip install script shortcuts) - Would auto-capture memorize "always remove shortcuts from install scripts"? That's task-specific, not generalizable.
- Task 65 (strip nvim references post-sync) - Auto-capture might create a memory about nvim-stripping procedures that becomes misleading after the codebase evolves.

Quality filtering without human judgment requires predicting which insights are durable vs. ephemeral, which is a hard AI judgment problem. The classification taxonomy in skill-memory (`[TECHNIQUE]`, `[PATTERN]`, `[CONFIG]`, `[WORKFLOW]`, `[INSIGHT]`, `[SKIP]`) exists precisely because this judgment is hard and currently requires user review.

### Finding 4: Auto-Retrieval Token Cost Impact is Not Negligible

The current memory vault has 8 entries. If auto-retrieval injects memories into every research/plan/implement operation, the token cost scales with vault size. A vault of 200+ memories (plausible after a year of auto-capture) would require:
1. A search query against the vault (MCP call or grep + scoring)
2. Injection of potentially 3-5 memory files into the context window
3. Each memory file is 200-500 tokens = 600-2500 tokens per operation

At hundreds of operations per year, this represents a meaningful and compounding token cost. Worse: as the vault grows, search precision drops, so retrieval fetches more false positives, increasing injection noise. The token cost and signal-to-noise ratio trend in opposite directions as the system scales.

### Finding 5: Stale Memory Risk is Structurally Unaddressed

Memories are written at a point in time. The current architecture has no expiration, validation, or staleness detection mechanism. Consider:
- A memory written about `install.sh` structure after task 67 would be incorrect after any significant refactor
- A memory about Zed keybindings (currently MEM-zed-keybindings-scheme.md) would drift as the config evolves
- A memory about "how to strip nvim references" (task 65) is operationally worthless once the stripping is complete

Auto-captured memories would have no mechanism to detect when the underlying reality has changed. An agent following a stale memory pattern could make incorrect decisions -- and with no human in the confirmation loop, there's no catch point.

### Finding 6: Circular Learning -- Mistakes Becoming Patterns

If an implementation agent makes a suboptimal decision (e.g., choosing a flawed workaround for a bug), auto-capture could encode that mistake as a "pattern" memory. Future agents would retrieve this memory and repeat the mistake. With human-mediated `/learn`, the user can recognize bad patterns and skip them. Auto-capture has no such filter.

This risk compounds with the stale memory risk: a bad pattern memory that was accurate at creation time but is now wrong is worse than a clearly outdated memory, because it appears authoritative.

### Finding 7: Deduplication Requires Reading Existing Memories -- Prohibited in Postflight

The memory skill's deduplication requires:
1. A search against existing memories (MCP or grep)
2. Overlap scoring against existing memory content
3. Classification as UPDATE/EXTEND/CREATE

Steps 1 and 2 involve reading and analyzing existing `.memory/` files and calling MCP tools -- both classified as "agent work" under the postflight restrictions standard. If auto-capture runs in postflight, deduplication is impossible, and the vault will accumulate duplicate memories rapidly.

Without deduplication, the vault degrades: multiple memories covering the same topic with different (possibly contradictory) content, making search results unreliable.

### Finding 8: No Signal That Most Tasks Produce Generalizable Knowledge

Examining the 8 current memories and the 67 completed tasks:

**The 8 memories are all configuration/architecture knowledge** -- things that persist across the lifetime of the repository (Zed settings, command catalog, context layers, toolchain). These are high-durability knowledge.

**Most implementation tasks are non-generalizable**: stripping references (task 65), fixing install script (task 67), reverting a bad change (task 61). These are point-in-time corrections. Capturing them as memories produces low-value entries with short shelf lives.

The signal-to-noise ratio of auto-captured memories would be structurally lower than human-selected memories because human selection already filters for durability.

---

## Recommended Approach

Based on the constraints identified, the viable design space is narrower than the task description suggests. The recommended approach is a **human-confirmed, checkpoint-triggered suggestion system** rather than fully automatic capture:

**What can realistically work:**
1. **Agents emit memory candidates in return metadata** -- Agents (research, implement) can identify potentially useful patterns they discovered and include them as `memory_candidates` in `.return-meta.json`. The skill postflight can display these as suggestions without writing them automatically.

2. **End-of-lifecycle prompts, not auto-writes** -- Instead of auto-capturing, lifecycle commands can prompt the user: "3 memory candidates identified. Run `/learn --task 68` to review?" This preserves the mandatory interactive requirement.

3. **`/todo` memory harvest as a batch checkpoint** -- The existing skill-todo already surfaces memory suggestions. Strengthen this: at archive time, present curated candidates from completed tasks in a single interactive session. This batches the user confirmation burden rather than eliminating it.

4. **Scoped auto-retrieval with explicit opt-in** -- The `--remember` flag on `/research` is already the correct design. Auto-injection without opt-in risks context pollution. Consider making `--remember` the default for specific task types (e.g., `meta` tasks where system architecture knowledge is most relevant) while leaving it opt-in for others.

**What cannot work within current architecture:**
- Postflight auto-writes to `.memory/` (violates postflight restrictions)
- Bypassing AskUserQuestion gates in skill-memory (violates mandatory interactive requirement)
- Fully automated capture without human confirmation loop

---

## Evidence and Examples

### Evidence: Postflight Restriction Scope

From `postflight-tool-restrictions.md`:
- Prohibited: "Any MCP tool" (reason: "Domain tools are agent work")
- Prohibited: `grep` on source files (reason: "Analysis is agent work")
- Write restrictions: "Write to `.claude/` (except specs/)" prohibited

Memory operations require all three prohibited categories.

### Evidence: Interactive Requirement is Enforced by Design

From `skill-memory/SKILL.md`:
- "These are not optional. Running autonomously without user input is a critical failure."
- AskUserQuestion gates appear at Step 4 (file display), Memory Search result presentation, and per-segment confirmation

This is not a soft guideline -- it is marked as critical failure to bypass.

### Evidence: Current Vault Demonstrates Human Curation Value

Current vault: 8 memories from 67 tasks = 12% task-to-memory ratio, all high-durability configuration/architecture knowledge. The human filter is doing meaningful work.

### Evidence: Stale Memory Risk is Real

MEM-zed-keybindings-scheme.md and MEM-zed-editor-settings.md describe current configuration. Both would become stale after any configuration change. Without invalidation mechanisms, stale memories persist indefinitely.

### Evidence: Token Cost Calculation

At vault size V and operation count O per year:
- Each retrieval: 1 search + 3-5 memory files injected
- Memory file size: ~300 tokens average
- Per-operation cost: ~1200-1500 tokens injected
- At 200 operations/year with 200 vault entries: ~250,000 additional tokens annually, with declining relevance

---

## Confidence Level

| Risk Assessment | Confidence |
|-----------------|-----------|
| Postflight restriction violation | High (direct text evidence in standard) |
| Mandatory interactive requirement conflict | High (direct text evidence in SKILL.md) |
| Memory bloat and low signal-to-noise | High (supported by vault statistics) |
| Stale memory risk | High (no invalidation mechanism exists) |
| Circular learning risk | Medium (depends on implementation quality of candidate filtering) |
| Token cost impact | Medium (estimate based on current vault size; highly variable) |
| Deduplication failure in postflight | High (requires MCP/grep, both prohibited) |

**Overall assessment**: The proposed "automatic capture at lifecycle checkpoints" design has fundamental conflicts with two non-negotiable architectural constraints (postflight restrictions and mandatory interactive requirement). The design space for genuine automation is narrow. A suggestion-based approach that preserves human confirmation while reducing friction is the architecturally sound direction.
