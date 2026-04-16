# Implementation Plan: /distill Command and Memory Refinement System

- **Task**: 69 - Create /distill command for memory refinement
- **Status**: [IMPLEMENTING]
- **Effort**: 8 hours
- **Dependencies**: None
- **Research Inputs**: specs/069_create_distill_command_memory_refinement/reports/01_team-research.md
- **Artifacts**: plans/01_distill-command-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Build a complete /distill command system that maintains .memory/ vault health at scale through four operations (purge, combine, compress, refine), a scoring engine for candidate identification, a distillation log for auditability, and integration with /todo for conditional maintenance suggestions. The system extends skill-memory with a `mode=distill` execution path, uses a tombstone pattern for safe deletion, enforces keyword superset guarantees on merges, and tracks vault health metrics in state.json. Done when: /distill bare produces a health report, all four operation flags work with interactive confirmation, /todo conditionally suggests /distill and /review, distill-log.json records all operations, and documentation is updated across CLAUDE.md, skill README, context index, and memory extension docs.

### Research Integration

Team research (4 teammates) established the design through synthesis of Claude Code Auto-Dream consolidation patterns, Mem0 arbiter-agent conflict resolution, FSRS-inspired staleness scoring, and Factory.ai anchored iterative summarization. Key design decisions: extend skill-memory rather than new skill, default to read-only health report, tombstone pattern for safe deletion, keyword superset guarantee for merges, topic-cluster grouping for processing, and conditional /todo suggestions based on vault metrics.

### Roadmap Alignment

No ROADMAP.md items currently defined. This task establishes memory maintenance infrastructure.

## Goals & Non-Goals

**Goals**:
- Build a production-quality /distill command that works from 0 to 500+ memories
- Implement all four distillation operations: purge, combine, compress, refine
- Create a scoring engine that correctly identifies distillation candidates using composite metrics
- Enforce keyword superset guarantee on all merge operations to prevent retrieval degradation
- Track vault health in state.json with memory_health field
- Log all distillation operations to .memory/distill-log.json for auditability and rollback
- Update /todo to conditionally suggest /distill and /review based on vault state
- Provide safe defaults (read-only report) with destructive ops behind explicit flags

**Non-Goals**:
- Meta-memories (deferred until 50+ memories exist in practice)
- Scheduled background distillation via /schedule
- Agent-assisted compression using a dedicated distill-agent (can be added later)
- MCP server integration for memory search during distillation
- Automatic distillation without user interaction

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Keyword loss during merge degrades retrieval | H | M | Enforce superset guarantee: merged keywords = union of all source keywords |
| Silent information loss from compression | H | L | Distill-log.json records full before/after state; git provides backup |
| Scoring model misidentifies candidates | M | M | All operations interactive with user confirmation; --auto limited to safe ops |
| Overlap with /learn UPDATE/EXTEND semantics | M | L | Distill operates cross-memory (batch); /learn operates single-input-to-memory |
| Stale wiki-links after merge/purge | L | H | Link-scan step updates Connections sections referencing affected memories |
| Large vault performance (500+ memories) | M | L | Topic-cluster grouping limits comparison scope; index-based scoring avoids full file reads |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Scoring Engine and Health Report Infrastructure [COMPLETED]

**Goal**: Build the distillation scoring engine, health report generator, distill-log infrastructure, and memory_health state.json field. This is the foundation everything else depends on.

**Tasks**:
- [ ] Create `.claude/commands/distill.md` command file with argument parsing for bare (report), --purge, --merge, --compress, --auto, --gc flags
- [ ] Extend `.claude/skills/skill-memory/SKILL.md` with `mode=distill` execution section defining the distill pipeline stages
- [ ] Implement scoring engine in the skill definition with composite score calculation:
  - Staleness score: `days_since_last_retrieval / 90` (capped at 1.0), with FSRS-inspired adjustment: `if retrieval_count > 0 AND days_since_created > 60: reduce staleness by 0.3` (old-but-retrieved memories are valuable)
  - Zero-retrieval penalty: `1.0 if retrieval_count == 0 AND days_since_created > 30, else 0.0`
  - Size penalty: `max(0, (token_count - 600) / 600)` (linear penalty above 600 tokens)
  - Duplicate score: highest keyword overlap with any other memory (using existing overlap scoring from skill-memory)
  - Composite: `(staleness * 0.3) + (zero_retrieval * 0.25) + (size * 0.2) + (duplicate * 0.25)`
- [ ] Implement topic-cluster grouping: group memories by topic prefix (first path segment) before scoring, process clusters independently
- [ ] Implement health report output for `/distill` bare invocation:
  - Total memories, total tokens, average tokens per memory
  - Category distribution (PATTERN, CONFIG, WORKFLOW, TECHNIQUE, INSIGHT)
  - Topic cluster sizes
  - Retrieval statistics: retrieved at least once vs never retrieved, most/least retrieved
  - Purge candidates (zero-retrieval > 30 days), merge candidates (overlap > 60%), compress candidates (> 600 tokens)
  - Overall health score: 100 - (purge_candidates * 3) - (merge_candidates * 5) - (compress_candidates * 2), clamped to 0-100
- [ ] Create `.memory/distill-log.json` schema and initialization:
  ```json
  {
    "version": 1,
    "operations": [],
    "summary": {
      "total_operations": 0,
      "last_distilled": null,
      "memories_purged": 0,
      "memories_merged": 0,
      "memories_compressed": 0,
      "memories_refined": 0
    }
  }
  ```
- [ ] Add `memory_health` field to state.json schema (parallel to `repository_health`):
  ```json
  "memory_health": {
    "last_distilled": null,
    "distill_count": 0,
    "total_memories": 8,
    "never_retrieved": 8,
    "health_score": 100,
    "status": "healthy"
  }
  ```
- [ ] Update memory_health in state.json whenever /distill runs (even bare report mode updates total_memories, never_retrieved, health_score)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `.claude/commands/distill.md` - New command file
- `.claude/skills/skill-memory/SKILL.md` - Add mode=distill section
- `.memory/distill-log.json` - New log file (created on first run)
- `specs/state.json` - Add memory_health field

**Verification**:
- `/distill` bare produces a formatted health report with all metric categories
- state.json contains memory_health field with correct counts
- distill-log.json exists with valid schema

---

### Phase 2: Purge Operation with Tombstone Pattern [COMPLETED]

**Goal**: Implement the PURGE operation that identifies stale memories, presents them for interactive selection, tombstones selected entries, and provides --gc for hard deletion after grace period.

**Tasks**:
- [ ] Implement purge candidate identification using scoring engine: select memories where `zero_retrieval_penalty == 1.0` OR `staleness_score > 0.8`
- [ ] Implement category-aware TTL advisory thresholds (used for ranking, not automatic action):
  - CONFIG: 180 days, WORKFLOW: 365 days, PATTERN: 540 days, TECHNIQUE: 270 days, INSIGHT: no TTL
- [ ] Present purge candidates via AskUserQuestion with multiSelect:
  ```
  question: "Select memories to purge ({N} candidates):"
  options: [
    {label: "MEM-{slug}", description: "Score: {score} | Created: {date} | Retrievals: {count} | {token_count} tokens"}
  ]
  ```
- [ ] Implement tombstone pattern for selected memories:
  - Add `status: tombstoned` and `tombstoned_at: ISO8601` to memory frontmatter
  - Add `tombstone_reason: "purge"` to frontmatter
  - Do NOT delete file; do NOT remove from index
  - Tombstoned memories are excluded from retrieval (update retrieval scoring to skip `status: tombstoned`)
- [ ] Implement `--gc` flag for hard deletion:
  - Scan for tombstoned memories where `tombstoned_at` is older than 7-day grace period
  - Present list via AskUserQuestion for confirmation
  - On confirmation: delete memory files, remove from memory-index.json, regenerate index.md
  - Log deletion to distill-log.json
- [ ] Implement link-scan step: after tombstoning, scan all non-tombstoned memories for `[[MEM-{affected-slug}]]` references in Connections sections; warn user about stale links
- [ ] Log each purge operation to distill-log.json:
  ```json
  {
    "timestamp": "ISO8601",
    "operation": "purge",
    "memories_affected": ["MEM-slug-1", "MEM-slug-2"],
    "action": "tombstoned",
    "scores": {"MEM-slug-1": 0.82, "MEM-slug-2": 0.91},
    "pre_metrics": {"total_memories": 8, "total_tokens": 3751},
    "post_metrics": {"total_memories": 8, "total_tokens": 3751, "tombstoned": 2}
  }
  ```

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `.claude/skills/skill-memory/SKILL.md` - Add purge operation section
- `.claude/commands/distill.md` - Add --purge and --gc flag handling
- `.memory/distill-log.json` - Receive purge operation entries

**Verification**:
- `--purge` shows ranked candidates with scores, allows interactive selection
- Selected memories get tombstone frontmatter fields added
- Tombstoned memories are skipped during retrieval
- `--gc` finds and deletes tombstoned memories past grace period
- distill-log.json records the operation with before/after metrics

---

### Phase 3: Combine Operation with Keyword Guarantee [COMPLETED]

**Goal**: Implement the COMBINE operation that identifies duplicate/overlapping memories, presents merge candidates by topic cluster, merges selected pairs with keyword superset enforcement, and updates cross-references.

**Tasks**:
- [ ] Implement merge candidate identification:
  - For each topic cluster, compute pairwise keyword overlap between all memories
  - Pair memories where overlap > 60% (HIGH from existing skill-memory scoring)
  - Rank pairs by overlap score descending
  - Group candidates by topic cluster for presentation
- [ ] Present merge candidates via AskUserQuestion per topic cluster:
  ```
  question: "Topic: {cluster_name} - Select pairs to merge ({N} candidates):"
  options: [
    {label: "Merge: MEM-{a} + MEM-{b}", description: "{overlap}% overlap | Keywords: {shared_keywords}"}
  ]
  ```
- [ ] Implement merge execution for each selected pair:
  - Determine primary memory (higher retrieval_count, or older if equal)
  - Merge content: primary content + "## Merged From {secondary}" section with secondary content
  - **Keyword superset guarantee**: merged_keywords = union(primary.keywords, secondary.keywords) -- verify `len(merged_keywords) >= len(union)`, fail merge if not
  - Update frontmatter: modified = today, merge combined retrieval_count, keep earliest created date
  - Tombstone the secondary memory (same tombstone pattern as purge, with `tombstone_reason: "merged_into:{primary_id}"`)
- [ ] Update Connections sections: scan all memories for `[[{secondary_id}]]` references, replace with `[[{primary_id}]]`
- [ ] Regenerate memory-index.json and index.md after all merges complete
- [ ] Log each merge operation to distill-log.json:
  ```json
  {
    "timestamp": "ISO8601",
    "operation": "combine",
    "primary": "MEM-primary-slug",
    "secondary": "MEM-secondary-slug",
    "overlap_score": 0.72,
    "keywords_before": {"primary": [...], "secondary": [...]},
    "keywords_after": [...],
    "keyword_superset_verified": true,
    "pre_metrics": {"total_memories": 8},
    "post_metrics": {"total_memories": 7, "tombstoned": 1}
  }
  ```

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `.claude/skills/skill-memory/SKILL.md` - Add combine operation section
- `.claude/commands/distill.md` - Add --merge flag handling
- `.memory/distill-log.json` - Receive combine operation entries

**Verification**:
- `--merge` identifies overlapping pairs grouped by topic cluster
- Merged memory has keywords as superset of union of both source memories
- Secondary memory is tombstoned with merge reference
- Cross-references in other memories are updated
- Index files are regenerated
- distill-log.json records merge with keyword verification

---

### Phase 4: Compress and Refine Operations [COMPLETED]

**Goal**: Implement COMPRESS (reduce verbose memories to key points) and REFINE (fix metadata quality issues) operations, plus the --auto flag for safe automatic operations.

**Tasks**:
- [ ] Implement compress candidate identification: select memories where `token_count > 600`
- [ ] Present compress candidates via AskUserQuestion:
  ```
  question: "Select memories to compress ({N} candidates, all >600 tokens):"
  options: [
    {label: "MEM-{slug}", description: "{token_count} tokens | Topic: {topic} | Retrievals: {retrieval_count}"}
  ]
  ```
- [ ] Implement compression execution for each selected memory:
  - Read full content
  - Generate compressed version: extract key points, preserve code blocks and examples, remove redundant prose
  - Move original content to `## History > ### Pre-Compression ({date})` section (same pattern as UPDATE operation in skill-memory)
  - Recalculate token_count in frontmatter
  - Preserve all keywords (compression must not drop keywords)
- [ ] Implement refine candidate identification:
  - Missing or sparse keywords: memories with < 4 keywords
  - Duplicate keywords within a single memory
  - Missing summary field in frontmatter
  - Missing or incorrect category classification
  - Topic path inconsistencies (e.g., topic doesn't match similar memories)
- [ ] Implement refine execution:
  - **Automatic fixes** (no confirmation needed, run with --auto):
    - Deduplicate keywords within each memory
    - Add missing summary field (generate from first line of content)
    - Normalize topic paths (lowercase, consistent separators)
  - **Interactive fixes** (require confirmation):
    - Keyword enrichment: suggest additional keywords based on content analysis
    - Category reclassification: suggest category changes based on content
    - Topic path correction: suggest topic changes based on cluster analysis
- [ ] Implement `--auto` flag execution:
  - Run refine automatic fixes (keyword dedup, summary generation, topic normalization)
  - Rebuild memory-index.json from filesystem state (validate-on-read regeneration)
  - Update memory_health in state.json
  - Skip all interactive operations
  - Log all changes to distill-log.json
- [ ] Log compress and refine operations to distill-log.json:
  ```json
  {
    "timestamp": "ISO8601",
    "operation": "compress",
    "memory": "MEM-slug",
    "tokens_before": 850,
    "tokens_after": 340,
    "compression_ratio": 0.60,
    "keywords_preserved": true
  }
  ```

**Timing**: 2 hours

**Depends on**: 2, 3

**Files to modify**:
- `.claude/skills/skill-memory/SKILL.md` - Add compress, refine, and --auto sections
- `.claude/commands/distill.md` - Add --compress and --auto flag handling
- `.memory/distill-log.json` - Receive compress/refine operation entries

**Verification**:
- `--compress` identifies verbose memories, shows candidates, compresses with history preservation
- Compressed memories retain all keywords
- `--auto` runs only safe operations without user interaction
- Refine identifies and fixes metadata quality issues
- distill-log.json records compression ratios and refine changes

---

### Phase 5: /todo Integration and Retrieval Updates [NOT STARTED]

**Goal**: Update /todo to conditionally suggest /distill and /review, update memory retrieval to skip tombstoned memories, and wire up memory_health state tracking.

**Tasks**:
- [ ] Update `.claude/commands/todo.md` Step 7 (Output) to add conditional "Next Steps" section:
  - Read memory_health from state.json (or compute if absent)
  - Compute suggestion conditions:
    - Always suggest `/review` after archival (unconditional)
    - Suggest `/distill --report` when `total_memories >= 10` (awareness tier)
    - Suggest `/distill` (full interactive) when ANY of:
      - `total_memories >= 30`
      - `never_retrieved / total_memories > 0.5` (and total_memories >= 5)
      - `last_distilled` older than 30 days (or null and total_memories >= 10)
    - Suppress all /distill suggestions when `total_memories < 5`
  - Format as numbered list in output:
    ```
    Next Steps:
    1. Review archive at specs/archive/
    2. Run /review for codebase analysis
    3. Run /distill to maintain memory vault ({N} memories, {health_score}/100 health)
    ```
- [ ] Update memory retrieval logic to skip tombstoned memories:
  - In the two-phase retrieval scoring (documented in CLAUDE.md Memory Extension section), add filter: `select(.status == "tombstoned" | not)` when reading memory-index.json entries
  - This requires adding `status` field to memory-index.json entries (default: "active", set to "tombstoned" when tombstoned)
- [ ] Add `status` field to memory-index.json entry schema:
  - Default value: `"active"`
  - Set to `"tombstoned"` when memory is tombstoned by purge or combine
  - Index regeneration must read status from memory file frontmatter
- [ ] Ensure /distill updates memory_health in state.json after every invocation:
  - Recount total_memories (excluding tombstoned), never_retrieved, recalculate health_score
  - Update last_distilled timestamp (only for non-bare invocations that perform operations)
  - Increment distill_count (only for non-bare invocations)

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `.claude/commands/todo.md` - Add conditional /distill and /review suggestions to output
- `.claude/skills/skill-memory/SKILL.md` - Update index regeneration to include status field; update retrieval skip logic
- `specs/state.json` - memory_health field updates (already created in Phase 1, wired here)

**Verification**:
- /todo output shows /review suggestion unconditionally
- /todo output shows /distill suggestion only when conditions are met
- /todo suppresses /distill when vault has < 5 memories
- Tombstoned memories are excluded from retrieval scoring
- memory-index.json entries include status field
- memory_health in state.json reflects accurate counts after distillation

---

### Phase 6: Testing, Cleanup, and Documentation [NOT STARTED]

**Goal**: Validate the complete /distill system end-to-end, clean up any temporary artifacts, and systematically update all documentation touchpoints.

**Tasks**:
- [ ] **End-to-end validation**: Run /distill bare against the current 8-memory vault and verify:
  - Health report produces correct counts (8 memories, 3751 tokens, 8 never-retrieved)
  - state.json memory_health field is populated correctly
  - distill-log.json is created with valid schema
  - No errors or warnings during execution
- [ ] **Flag validation**: Verify each flag parses correctly in distill.md command file:
  - `--purge` routes to purge candidate identification
  - `--merge` routes to combine candidate identification
  - `--compress` routes to compress candidate identification
  - `--auto` routes to safe automatic operations
  - `--gc` routes to tombstone cleanup
  - Bare invocation (no flags) routes to health report
- [ ] **Scoring engine validation**: Manually verify scoring for at least 3 memories:
  - Check staleness calculation against known created/retrieved dates
  - Check zero-retrieval penalty against known retrieval_count values
  - Check size penalty against known token_count values
  - Verify composite score ordering makes sense
- [ ] **Keyword superset guarantee validation**: Create a test scenario description in the plan summary:
  - Document how to verify: if memory A has keywords [a, b, c] and memory B has keywords [b, c, d], merged must have [a, b, c, d]
- [ ] **Update `.claude/CLAUDE.md`** Memory Extension section:
  - Add /distill command to Commands table with usage and description
  - Add distill operation to Memory Extension lifecycle description
  - Add memory_health to state.json structure documentation
  - Document /todo conditional suggestion behavior
- [ ] **Update `.claude/skills/skill-memory/README.md`**:
  - Add distill mode documentation with flag reference
  - Document scoring engine parameters
  - Document tombstone pattern and --gc lifecycle
  - Document distill-log.json schema
- [ ] **Update `.claude/context/index.json`**:
  - Add entry for distill-related context if any new context files were created
  - Verify memory-related entries are current
- [ ] **Update `.claude/context/project/memory/` files**:
  - Update `learn-usage.md` or create `distill-usage.md` with /distill usage guide
  - Document the relationship: `/learn` (create) -> retrieval (use) -> `/todo` harvest (capture) -> `/distill` (maintain)
- [ ] **Verify command registration**: Ensure /distill appears in command discovery (commands/ directory scan)
- [ ] **Clean up**: Remove any temporary files, verify no debug output remains in skill definitions

**Timing**: 1 hour

**Depends on**: 5

**Files to modify**:
- `.claude/CLAUDE.md` - Add /distill to Memory Extension section, update state.json docs
- `.claude/skills/skill-memory/README.md` - Add distill mode documentation
- `.claude/context/index.json` - Add distill context entries
- `.claude/context/project/memory/distill-usage.md` - New usage guide (or update learn-usage.md)

**Verification**:
- /distill bare runs without errors against current vault
- All documentation references are consistent (no stale cross-references)
- CLAUDE.md Memory Extension section includes /distill command
- Context index includes new files
- No temporary or debug artifacts remain

## Testing & Validation

- [ ] /distill bare produces health report with correct metrics for the current 8-memory vault
- [ ] /distill --purge identifies zero-retrieval memories older than 30 days
- [ ] /distill --merge identifies memory pairs with >60% keyword overlap
- [ ] /distill --compress identifies memories with >600 tokens
- [ ] /distill --auto runs without user interaction, performs safe metadata fixes
- [ ] /distill --gc deletes tombstoned memories past 7-day grace period
- [ ] Tombstoned memories are excluded from retrieval scoring
- [ ] Merged memories have keyword superset of both source memories
- [ ] distill-log.json records all operations with before/after metrics
- [ ] state.json memory_health is updated after each /distill invocation
- [ ] /todo conditionally suggests /distill based on vault health metrics
- [ ] /todo always suggests /review after archival
- [ ] All new documentation is internally consistent

## Artifacts & Outputs

- `.claude/commands/distill.md` - Command file with argument parsing and flag routing
- `.claude/skills/skill-memory/SKILL.md` - Extended with mode=distill pipeline (scoring, purge, combine, compress, refine, auto)
- `.claude/skills/skill-memory/README.md` - Updated with distill documentation
- `.memory/distill-log.json` - Operation log (created on first /distill run)
- `.claude/commands/todo.md` - Updated with conditional /distill and /review suggestions
- `.claude/CLAUDE.md` - Updated Memory Extension section
- `.claude/context/index.json` - Updated with new context entries
- `.claude/context/project/memory/distill-usage.md` - Usage guide for /distill
- `specs/state.json` - memory_health field added

## Rollback/Contingency

All changes are to .claude/ configuration files and .memory/ metadata. Git provides full rollback capability:
- `git diff HEAD~1` to review changes
- `git checkout HEAD~1 -- .claude/ .memory/ specs/state.json` to revert all changes
- Tombstone pattern ensures no memories are permanently deleted during distillation; only --gc performs hard deletes
- distill-log.json provides targeted rollback information for individual operations
