# Teammate A Findings: Implementation Approaches and Patterns for /distill

**Task**: 69 - Create /distill command for memory system refinement
**Artifact**: 01 (Primary Angle)
**Date**: 2026-04-16

---

## Key Findings

### 1. Claude Code's "Auto Dream" Feature (Direct Inspiration)

Claude Code has an unreleased (but leaked) memory consolidation feature called **Auto Dream**. Its system prompt is publicly documented and provides the strongest design reference for `/distill`.

**Four-Phase Process** (directly applicable):

| Phase | Purpose | Operations |
|-------|---------|------------|
| Orient | Inventory current memory state | Read index, scan topic files, build mental map |
| Gather Signal | Find consolidation candidates | Targeted grep searches, identify contradictions, find duplicates |
| Consolidate | Apply changes to memory files | Convert relative dates, delete contradicted facts, merge duplicates, clean stale refs |
| Prune & Index | Maintain index health | Remove stale pointers, reorder by relevance, rebuild index under size limits |

**Trigger Model**:
- **Automatic**: Both conditions must be true: (a) 24+ hours since last consolidation, AND (b) 5+ sessions since last consolidation
- **Manual**: User says "dream", "consolidate my memory", or "distill"
- **Lock file** prevents concurrent execution

**Core Philosophy**: "Errs on the side of caution, preferring to keep information that's ambiguously useful over removing something potentially important." Selective searching ("targeted grep, not full reads") to avoid token waste.

**Key Operations** from the leaked system prompt:
- `Convert relative dates`: "yesterday we decided X" → "2026-03-15: decided X"
- `Delete contradicted facts`: Remove old entry when decision changes
- `Clean stale memories`: Eliminate notes referencing deleted files
- `Merge overlapping entries`: Multiple similar notes → single clean version
- `Index maintenance`: Keep index under 200 lines AND ~25KB
- Index entry format: `- [Title](file.md) — one-line hook` (~150 char limit per line)

### 2. AI Memory Consolidation Research Patterns

**Scoring for Consolidation** (from literature synthesis):

Three mechanisms emerge consistently:
- **Retrieval frequency** (`retrieval_count`): High-frequency memories are preserved; zero-retrieval memories are purge candidates
- **Recency** (`last_retrieved`): Memories never accessed after creation are stalest
- **Token count**: Memories over ~500 tokens without proportional value are compression candidates

**Keyword Overlap for Deduplication** (from existing skill-memory):
The existing SKILL.md already defines overlap scoring:
```
overlap_score = |segment_terms intersect memory_terms| / |segment_terms|
>60% = HIGH (merge candidates)
30-60% = MEDIUM (extend candidates)
<30% = LOW (distinct memories)
```
This same threshold logic applies directly to `/distill`'s combination operation.

**Research finding**: Structured Distillation (arxiv 2603.13017) achieves 11x compression from 371 to 38 tokens while maintaining 96% retrieval effectiveness. Key insight: compress to 4-field structures (core, context, themes, referenced_files) rather than raw text truncation.

### 3. Interactive vs Automatic Split

Based on AutoDream design and memory system patterns, the recommended split:

**Automatic (safe to run without confirmation)**:
- Index rebuild (memory-index.json + index.md regeneration)
- Date normalization (relative → absolute)
- Stale reference cleanup (references to nonexistent files)
- Statistics update

**Interactive (requires user confirmation)**:
- Memory deletion / purging (irreversible)
- Memory merging (destructive to source files)
- Content rewriting / compression
- Keyword refinement

This matches AutoDream's conservatism philosophy: automation for bookkeeping, interaction for content changes.

### 4. Scoring Model for This System

Given the current memory fields (`retrieval_count`, `last_retrieved`, `created`, `token_count`, `keywords`), a composite scoring model:

```
distill_priority(mem) = (
  staleness_score(last_retrieved, created)    # 0.0-1.0, higher = staler
  + zero_retrieval_penalty(retrieval_count)   # 1.0 if count==0, 0.0 otherwise
  + size_penalty(token_count)                 # 1.0 if >600 tokens
  + duplicate_score(keyword_overlap)          # 0.0-1.0, higher = more duplicate
) / 4
```

**Staleness calculation**:
```
days_since_created = today - created
days_since_retrieved = today - last_retrieved (or days_since_created if null)
staleness = min(1.0, days_since_retrieved / 90)  # 90-day stale window
```

**Operation thresholds**:
- `duplicate_score > 0.6` → COMBINE candidate (show as pair to user)
- `retrieval_count == 0 AND staleness > 0.5` → PURGE candidate
- `token_count > 600` → COMPRESS candidate
- `keyword quality issues` (< 4 keywords, duplicates) → REFINE candidate

### 5. Command Structure Recommendation

```
/distill                    # Full distillation with all operations
/distill --analyze          # Dry run: show what would change, no writes
/distill --purge-only       # Only show purge candidates
/distill --combine-only     # Only show combination candidates
/distill --compress-only    # Only show compression candidates
/distill --auto             # Run safe automatic operations only (no interactive)
```

### 6. Skill Architecture Decision

**Recommendation: Extend skill-memory with a new `distill` mode rather than creating a separate skill.**

Rationale:
- All distillation operations use the same infrastructure (memory files, index, grep search)
- The existing overlap scoring algorithm in skill-memory is directly reusable
- Index regeneration code from skill-memory is needed by both
- Keeping operations in one skill avoids duplication of index maintenance logic

The `/distill` command would delegate to `skill-memory` with `mode=distill`, analogous to how `/learn` delegates with `mode=text|file|directory|task`.

### 7. /todo Integration

The `/todo` command's Step 7 (Output) currently ends with:
```
Next Steps:
1. Review archive at specs/archive/
2. Run /review for codebase analysis
```

The recommendation is to add `/distill` as a third next step, conditional on memory vault having 5+ memories:

```
Next Steps:
1. Review archive at specs/archive/
2. Run /review for codebase analysis
3. Run /distill to consolidate memory vault (8 memories)   # shown when .memory/ has 5+ entries
```

The count should come from `entry_count` in `memory-index.json` (already available in the todo workflow's environment).

---

## Recommended Approach

### Primary Implementation: Four-Operation /distill with Analyze Mode

**Operation 1: PURGE** (stale/never-retrieved memories)
- Candidates: `retrieval_count == 0 AND days_since_created > 30`
- Present as multiSelect with description showing age and keywords
- User selects which to delete
- Safe default: pre-select none (opt-in purging)

**Operation 2: COMBINE** (high keyword-overlap pairs)
- Candidates: pairs with keyword overlap > 60%
- Present as pairs: "MEM-A (72% overlap with MEM-B) → merge?"
- User selects which pairs to merge
- Merge strategy: keep both content blocks, unify frontmatter, one file survives

**Operation 3: COMPRESS** (oversized memories)
- Candidates: token_count > 600
- Present summary of what would be trimmed
- User confirms before rewriting
- Compression target: reduce to key points, move details to ## History section

**Operation 4: REFINE** (keyword/metadata quality)
- Automatic: fix keyword arrays with < 4 entries, remove duplicate keywords
- Interactive: suggest topic reclassification for misaligned topics
- Automatic: update `modified` dates on changed files

**Final Step: Index Rebuild** (always automatic)
- Regenerate memory-index.json from filesystem
- Regenerate index.md from memory-index.json
- Report: N memories scanned, N changes made

### Execution Flow

```
/distill [flags]
  |
  v
Phase 1: ANALYZE
  - Read memory-index.json
  - Compute staleness scores for all entries
  - Find overlap pairs using keyword intersection
  - Identify oversized memories
  - Identify keyword quality issues
  |
  v
Phase 2: REPORT (--analyze stops here)
  - Show summary: N purge candidates, N combine pairs, N compress targets
  - If no candidates found: "Memory vault is healthy, no distillation needed"
  |
  v
Phase 3: INTERACTIVE SELECTION (skipped for --auto)
  - AskUserQuestion for each operation category
  - User selects specific items per operation
  |
  v
Phase 4: EXECUTE
  - Apply confirmed operations in order: purge → combine → compress → refine
  - Each operation writes to disk immediately after confirmation
  |
  v
Phase 5: INDEX REBUILD (always)
  - Regenerate memory-index.json
  - Regenerate index.md
  - Git commit: "memory: distill vault (N operations)"
```

---

## Evidence and Examples

### AutoDream System Prompt (Source: Piebald-AI/claude-code-system-prompts)

The leaked system prompt directly confirms the four-phase approach and these specific operations:
- **Index size limit**: `${INDEX_MAX_LINES}` lines AND ~25KB
- **Entry format**: `- [Title](file.md) — one-line hook` (~150 char/line)
- **Selective signal gathering**: "Don't exhaustively read transcripts. Look only for things you already suspect matter."
- **Merge strategy**: "Merge new signal into existing topic files rather than creating duplicates"
- **Date normalization**: Convert relative to absolute (verbatim from system prompt)

### Overlap Scoring Already in skill-memory/SKILL.md

The existing skill already defines the thresholds that /distill should reuse:
```
>60% overlap = HIGH → UPDATE (for /learn) = COMBINE (for /distill)
30-60% overlap = MEDIUM → EXTEND (for /learn) = partial overlap (for /distill)
<30% overlap = LOW → CREATE (for /learn) = distinct memories (for /distill)
```

### Current Memory Index Fields Available for Scoring

From `memory-index.json` (all 8 memories have these fields):
- `retrieval_count`: All currently 0 (new system) — purge threshold needs grace period
- `last_retrieved`: All null — use `created` as proxy for age calculation
- `token_count`: Range 345-662 (none over 600 yet — compression not urgent)
- `keywords`: 8 keywords each — quality is good
- `topic`: Two clusters: `zed/*` (5 memories) and `agent-system/*` (3 memories)

**Practical implication**: With all retrieval counts at 0, the purge heuristic needs a `days_since_created` minimum (e.g., 30 days) to avoid purging brand-new memories. The current 8 memories are all from 2026-04-15 — distill would correctly report "no purge candidates" for new vaults.

### Keyword Overlap Example (Cross-Topic)

Computing overlap for MEM-agent-system-architecture vs MEM-claude-code-command-catalog:
- Architecture keywords: `[architecture, pipeline, checkpoint, lifecycle, routing, commands, skills, agents]`
- Commands keywords: `[commands, research, plan, implement, todo, task, review, lifecycle]`
- Intersection: `{commands, lifecycle}` = 2/8 = 25% → LOW overlap, correctly distinct

Computing overlap for MEM-zed-editor-settings vs MEM-zed-keybindings-scheme:
- Settings keywords: `[settings, theme, fonts, lsp, extensions, editor, configuration, zed]`
- Keybindings keywords: `[keybindings, shortcuts, keymap, modifiers, bindings, scheme, zed]`
- Intersection: `{zed}` = 1/8 = 12.5% → LOW overlap, correctly distinct

This shows the current 8 memories are well-differentiated — no combine candidates currently exist. The combine operation will be most useful as the vault grows.

---

## Confidence Level

**High confidence** on:
- Core operations (purge, combine, compress, refine) — well-supported by AutoDream and research
- Interactive vs automatic split — directly matches AutoDream's conservatism philosophy
- Reusing skill-memory rather than creating new skill — clear architectural fit
- Keyword overlap thresholds for combine detection — already defined in existing code
- /todo integration as "Next Steps" item — minimal, non-invasive addition

**Medium confidence** on:
- Specific scoring thresholds (staleness window of 90 days, token limit of 600) — these are reasonable defaults based on research patterns but not empirically validated for this vault
- `--auto` flag scope — what counts as "safe" may need refinement after initial use
- Compression strategy (key points + History section) — based on AutoDream pattern but could be simpler

**Low confidence** on:
- Exact token reduction achievable — the 11x research result is for conversation compression, not knowledge memory compression; realistic target is probably 2-3x
- Optimal trigger conditions for automatic /distill — AutoDream uses 24hr + 5 sessions, but this system has no session tracking infrastructure

---

## Sources

- [Claude Code AutoDream - MindStudio](https://www.mindstudio.ai/blog/what-is-claude-code-autodream-memory-consolidation-2)
- [Auto Dream mechanics - claudefa.st](https://claudefa.st/blog/guide/mechanics/auto-dream)
- [Auto Memory and Auto Dream - AntonioCortes.com](https://antoniocortes.com/en/2026/03/30/auto-memory-and-auto-dream-how-claude-code-learns-and-consolidates-its-memory/)
- [Dream Memory Consolidation System Prompt - Piebald-AI/claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts/blob/main/system-prompts/agent-prompt-dream-memory-consolidation.md)
- [dream-skill implementation - grandamenium/dream-skill](https://github.com/grandamenium/dream-skill)
- [Structured Distillation for Personalized Agent Memory - arxiv 2603.13017](https://arxiv.org/abs/2603.13017)
- [Memory Optimization Strategies in AI Agents - Medium](https://medium.com/@nirdiamant21/memory-optimization-strategies-in-ai-agents-1f75f8180d54)
- [Memory Scaling for AI Agents - Databricks](https://www.databricks.com/blog/memory-scaling-ai-agents)
