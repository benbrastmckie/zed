---
title: "Teammate C findings: Gaps, shortcomings, and blind spots for /distill command"
task: 69
artifact_number: 01
teammate: C (Critic)
role: Identify risks, failure modes, and what is missing
created: 2026-04-16
---

# Teammate C: Critic Findings for /distill Command

## Executive Summary

The `/distill` command proposal has merit but is being designed before the memory system is large enough to require it, and the task description conflates several distinct concerns that deserve separate treatment. The biggest risks are: (1) silent information loss during automated consolidation, (2) retrieval degradation caused by keyword changes post-distill, and (3) scope creep from bundling too many operations into one command. The `/todo` suggestion addition is trivial and should be decoupled from the hard design work.

---

## Key Findings

### Finding 1: Premature Optimization (High Risk)

**Status of the vault today**: 8 memories, 3,751 total tokens (~15KB of content).

With 8 memories averaging 469 tokens each, the vault is tiny. The two-phase retrieval system injects up to 5 memories into each agent context (capped at 3,000 tokens), meaning the vault is small enough that nearly the entire vault could be injected on every operation. There is no retrieval quality problem to fix yet.

**Evidence of premature optimization**:
- At 8 memories, keyword overlap scoring will find correct matches trivially -- there is no needle-in-a-haystack problem.
- The current 90% keyword overlap threshold for deduplication in `/learn` means near-duplicates are already blocked at creation time.
- No memory has ever been retrieved (`retrieval_count: 0` for all 8 entries as of 2026-04-15), which means there is no usage signal to guide pruning decisions.

**Why this is a problem**: Without usage signal, any distillation algorithm is guessing. It cannot distinguish a memory that is "never retrieved because it's rarely relevant" from one that is "never retrieved because the system is new." Distilling based on zero retrieval data risks deleting the most important foundational memories.

**Threshold recommendation**: Distillation provides meaningful value at approximately 50-100 memories, where retrieval quality begins degrading and keyword scoring begins producing false positives. The system should note this threshold explicitly rather than building the feature for the current 8-memory state.

---

### Finding 2: Silent Information Loss During Consolidation (Critical Risk)

The Claude Code Auto-Dream feature (which this task uses as inspiration) was documented in March 2026 as "good but not perfect" and explicitly requires user review to catch errors. Even Anthropic's implementation has blind spots.

**Specific information loss mechanisms in the proposed system**:

1. **Merge errors**: When two memories are merged, the merged memory's keywords become a union or intersection of the originals. If intersection is used (to avoid keyword bloat), unique-but-important keywords from either source are silently lost. If union is used, keyword signal is diluted.

2. **Summary compression**: The `summary` field is a single line. Summarizing a summarization loses detail exponentially. After two rounds of distillation, a nuanced technique may become an empty platitude.

3. **The `## History` mechanism in UPDATE operations**: The existing `/learn` skill preserves history in a `## History` section when updating memories. If `/distill` merges or compresses memories without preserving these history sections, the chronological record of how the knowledge evolved is lost permanently.

4. **Category downgrade**: A memory classified as `CONFIG` (high retrieval priority in the three-tier harvest system) might be merged into an `INSIGHT` (low priority, often hidden). This changes retrieval behavior invisibly.

**Why git history is insufficient as a rollback mechanism**: Git preserves the file state before distillation, but recovering from a bad distillation requires:
- Knowing *which* memories were affected (requires a distillation log)
- Understanding *what* was lost (requires pre/post comparison)
- Manually restoring specific entries (no automated rollback)

This is non-trivial. A distillation log (recording what was merged, compressed, or deleted and why) is a prerequisite for safe operation, not an optional feature.

---

### Finding 3: Retrieval Degradation from Keyword Changes (High Risk)

The auto-retrieval system scores memories by keyword overlap with task descriptions. The keyword set in `memory-index.json` is the *only* signal used for retrieval. This creates a fragile dependency:

**The problem chain**:
1. Memory `MEM-zed-keybindings-scheme` has keywords: `["keybindings", "shortcuts", "keymap", "modifiers", "bindings", "scheme", "zed"]`
2. `/distill` merges this with `MEM-zed-editor-settings` into a single `MEM-zed-configuration` memory
3. The merged memory's keywords are: `["settings", "theme", "fonts", "lsp", "extensions", "editor", "keybindings", "configuration"]`
4. A future task about "zed shortcuts" now fails to retrieve this memory because "shortcuts" was dropped
5. The agent works without the relevant configuration context and produces a suboptimal result

**Why this is worse than it sounds**: Retrieval failures are silent. The agent does not know a relevant memory was missed. There is no error log. The only observable symptom is slightly lower quality agent output, which is difficult to attribute to a distillation that ran weeks earlier.

**The compress-discoverability tension**: Any compression of content necessarily reduces the keyword surface area. Shorter, denser memories are harder to retrieve via keyword overlap. The very goal of compression conflicts with the mechanism used for retrieval. This is a fundamental design tension that the task description does not acknowledge.

**Mitigation requirement**: Before merging any two memories, distillation must verify that the merged memory's keywords are a superset of the union of both source memories' keywords -- not just the "important" ones from the primary memory.

---

### Finding 4: Functional Overlap with /learn (Medium Risk)

The `/learn` skill already implements:
- **Deduplication**: >90% keyword overlap blocks creation
- **UPDATE**: Replace memory content (for high-overlap, >60% threshold)
- **EXTEND**: Append new section (for medium-overlap, 30-60%)

The proposed `/distill` operations of "compress, combine, purge, and refine" overlap significantly:
- **Compress** ≈ UPDATE with a shorter version of the same content
- **Combine** ≈ UPDATE one memory with content from another, then DELETE the source
- **Purge** ≈ DELETE memories below a threshold (no equivalent in /learn)
- **Refine** ≈ EXTEND or UPDATE with corrected content

**The real gap**: `/distill` is needed primarily for *purge* (deleting obsolete or low-value memories) and *batch cross-memory operations* (identifying redundancy across the full vault, not just against new input). `/learn` can only see new content against existing memories; it cannot see two existing memories against each other.

**Risk of duplication**: If `/distill` reimplements UPDATE and EXTEND with slightly different semantics, the two systems will diverge and conflict. A memory updated by `/distill` may not follow the `## History` convention that `/learn` expects to find.

---

### Finding 5: The "Claude Code Dreaming" Inspiration Is Architecturally Different (Medium Risk)

Claude Code's Auto-Dream (as documented in the leaked system prompt at Piebald-AI/claude-code-system-prompts) operates on a different memory architecture:

| Dimension | Claude Code Auto-Dream | This Custom Vault |
|-----------|----------------------|------------------|
| Source material | Session transcripts (JSONL files), daily logs | Manual `/learn` entries + agent-emitted candidates |
| Memory format | Free-form topic files | Structured frontmatter (keywords, retrieval_count, etc.) |
| Index constraint | Under 200 lines, ~25KB | JSON with per-entry metadata |
| Trigger | Automatic (24hr Stop hook) | Manual (proposed `/distill` command) |
| Deduplication | Heuristic (avoid near-duplicates) | Threshold-based (90% keyword overlap) |
| Signal used | Recent session transcripts | `retrieval_count` + keyword scoring |

**The key difference**: Auto-Dream's Phase 2 "Gather Signal" reads session transcripts to find recent corrections and decisions. This system has no such transcript log -- the signal source for distillation decisions simply does not exist in the same form.

Applying the Auto-Dream four-phase model directly to this vault means Phase 2 would have no data to work with, making the process essentially Phase 1 (orient) + Phase 3 (consolidate based on keyword overlap alone) + Phase 4 (prune index). That is a reduced-capability version of the inspiration, and the limitations should be documented explicitly.

**Is the analogy appropriate?** Partially. The consolidation and pruning phases (Phases 3 and 4) translate reasonably well. The signal-gathering phase (Phase 2) does not -- this system would need to define what "recent signal" means in the absence of session transcripts. Candidate sources: git commit messages, task completion summaries, and the `last_retrieved`/`retrieval_count` fields.

---

### Finding 6: Scope Creep and Command Decomposition (Medium Risk)

The task description bundles four distinct operations:
1. **Compress**: Reduce token count of individual memories
2. **Combine**: Merge two or more memories into one
3. **Purge**: Delete memories that are obsolete, redundant, or low-value
4. **Refine**: Update memories with corrections or better formulations

Each of these has different risk profiles:

| Operation | Risk | Reversibility | When Needed |
|-----------|------|---------------|-------------|
| Compress | High (information loss) | Git only | 200+ tokens per memory, 50+ memories |
| Combine | High (keyword loss, category change) | Git only | Obvious duplicates, 30+ memories |
| Purge | Medium (can delete wrong memory) | Git only | Low-retrieval entries, 50+ memories |
| Refine | Low (same as /learn UPDATE) | /learn already does this | Always |

**Alternative decomposition**: Rather than one `/distill` command that does everything, consider:
- `/distill --purge`: Only deletes memories below a configurable threshold (safe default: `retrieval_count == 0` AND `age > 90 days`)
- `/distill --merge MEM-A MEM-B`: Explicitly merge two named memories (user-directed, not algorithmic)
- `/distill --compress MEM-X`: Reduce a specific memory (user-directed)
- `/distill` (bare): Show a health report without modifying anything

This decomposition aligns with the system's existing principle of mandatory user interaction (the `/learn` skill has explicit `MANDATORY STOP` requirements for every operation).

---

### Finding 7: Missing Success Metrics (High Risk)

How do you know if distillation improved or degraded the memory system?

**Current observability**:
- `retrieval_count` tracks usage but only goes up
- `last_retrieved` tracks recency but is not compared against task outcomes
- There is no metric connecting "this memory was retrieved" to "this task succeeded"

**What is needed but not proposed**:
1. **Pre/post token count**: Did distillation reduce total_tokens in memory-index.json?
2. **Pre/post entry count**: How many memories were merged or deleted?
3. **Retrieval coverage**: What fraction of recent tasks retrieved at least one memory?
4. **False positive rate**: How often are retrieved memories irrelevant to the task?

Without these metrics, there is no way to answer "was the last distillation run good or bad?" The `/distill` command will be a black box that modifies the vault in ways that cannot be evaluated.

**Minimum viable measurement**: Log a distillation summary to `.memory/distill-log.json` with pre/post counts, list of affected memories, and timestamp. This enables retrospective evaluation even without real-time quality metrics.

---

### Finding 8: The /todo Suggestion Addition Is Trivially Simple (Low Risk, but Scope Issue)

The second half of this task -- updating `/todo` to suggest running `/distill` and `/review` when it finishes -- is a one-line addition to the "Next Steps" section of the `/todo` output template:

```
Next Steps:
1. Review archive at specs/archive/
2. Run /review for codebase analysis
3. Run /distill to consolidate memory vault (if vault has grown)
```

This is approximately 15 minutes of work and should not be bundled with designing `/distill` itself. The implementation risk is near-zero; the design risk of `/distill` is substantial. Bundling them in the same task creates pressure to implement `/distill` quickly (to "complete" the task) rather than carefully.

**Recommendation**: Separate the `/todo` update into its own sub-task or implement it immediately as a near-zero-risk change, independently of the `/distill` design work.

---

## What Questions Aren't Being Asked

1. **When should distillation NOT run?** The task focuses on when/how to distill but not on guards. Examples: Do not distill during an active multi-phase implementation. Do not distill if fewer than N memories exist. Do not distill if `memory-index.json` was modified in the last 24 hours.

2. **Who owns the distillation decision?** The current system requires human confirmation for every memory operation in `/learn`. Should `/distill` be fully automated (like Auto-Dream), fully interactive (like `/learn`), or a hybrid? The task description implies automation, which conflicts with the system's existing interactive-first philosophy.

3. **What happens to memory candidates in state.json during distillation?** The `/todo` command harvests memory candidates from `state.json`. If `/distill` runs before `/todo`, it may merge or delete memories that are about to be created as candidates. This ordering dependency is not addressed.

4. **How does `/distill` handle the `## Connections` section?** Each memory file has a `## Connections` section for `[[wiki-link]]` references. If Memory A is merged into Memory B, all memories that referenced A via `[[MEM-A]]` now have stale links. There is no link-update mechanism in the current system.

5. **Should distillation respect `.syncprotect`?** The `.syncprotect` file protects files from sync overwrite. Should certain memories be marked as distillation-exempt? A protected memory should never be merged or deleted by automated distillation.

---

## Recommended Approach

### Immediate (Before Implementing /distill)

1. **Implement the `/todo` suggestion** now -- it is independent and trivial.
2. **Define the minimum vault size threshold** at which `/distill` becomes useful (recommendation: 50 memories, ~25,000 tokens).
3. **Add a distillation-log mechanism** to `.memory/distill-log.json` before any distillation operations are run.

### Design Constraints for /distill

1. **Never fully automate**: Require user confirmation for any destructive operation (merge, delete). Show a preview of what will be changed before executing.
2. **Keyword superset guarantee**: Merged memories must have keywords that are a superset of all source memories' keywords.
3. **Preserve `## History` sections**: Merged memories must include history sections from all source memories.
4. **Default to read-only**: Running `/distill` without flags should show a health report (candidate operations, token totals, retrieval statistics) without modifying anything.
5. **No cascade deletes**: Deleting a memory should prompt a check for `[[MEM-X]]` references in other memories and warn the user about stale links.

### Safe Starting Point

Build `/distill --health` first: a read-only command that analyzes the vault and reports:
- Total memories, total tokens
- Memories never retrieved (candidates for purge)
- Memories with overlapping keyword sets (candidates for merge)
- Memories older than N days with zero retrieval (candidates for deletion)
- Index stale detection (same as validate-on-read pattern)

Only after the health report is proven useful should the destructive operations be added.

---

## Evidence/Examples

### The Keyword Loss Problem (Concrete Example)

Current state of two memories:
- `MEM-zed-editor-settings`: keywords `["settings", "theme", "fonts", "lsp", "extensions", "editor", "configuration", "zed"]`
- `MEM-zed-keybindings-scheme`: keywords `["keybindings", "shortcuts", "keymap", "modifiers", "bindings", "scheme", "zed"]`

A naive merge into `MEM-zed-configuration` might take the top-8 keywords by frequency, yielding:
`["zed", "settings", "configuration", "editor", "extensions", "keybindings", "fonts", "lsp"]`

Lost keywords: `shortcuts`, `keymap`, `modifiers`, `bindings`, `scheme`, `theme`

A future task "change zed shortcut for terminal" would now fail to retrieve this memory because "shortcut" is not in the merged keyword set.

### The Auto-Dream Architecture Mismatch (Concrete Example)

Auto-Dream Phase 2 "Gather Signal" requires session transcripts (JSONL files). The system prompt excerpt (from Piebald-AI/claude-code-system-prompts) specifies: "Check for subdirectories like `logs/` or `sessions/`. Use targeted grep on JSONL files."

This vault has no `logs/` directory, no JSONL session files, no transcript log. The analog for "recent signal" in this system is:
- Git log of `.memory/` changes
- `specs/state.json` completion_summaries
- `retrieval_count` and `last_retrieved` in `memory-index.json`

Using these as signal sources is valid but is architecturally different from Auto-Dream's approach. The `/distill` design must explicitly define its signal sources rather than assuming the Auto-Dream model applies directly.

---

## Confidence Level

| Finding | Confidence | Basis |
|---------|------------|-------|
| Premature optimization at 8 memories | High | Empirical (8 entries, 0 retrievals) |
| Keyword loss risk during merge | High | Deductive from retrieval algorithm |
| Retrieval degradation is silent | High | System architecture (no error path for missed memories) |
| Auto-Dream architecture mismatch | High | Official system prompt (Piebald-AI repo) vs vault structure |
| /todo suggestion is trivial | High | Direct inspection of todo.md template |
| Success metrics are missing | High | No metric definition found in task description or codebase |
| Scope should be decomposed | Medium | Judgment call; single-command approach could work with strong guards |
| /learn overlap risk | Medium | The operations overlap but the use cases differ |
