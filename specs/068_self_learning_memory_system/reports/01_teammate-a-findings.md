---
title: "Self-Learning Memory System: Current Architecture and Implementation Approach"
task: 68
artifact_type: report
teammate: A
focus: Current architecture and primary implementation approach
created: 2026-04-15
---

# Self-Learning Memory System: Teammate A Findings

## Executive Summary

The current memory system is fully interactive and user-driven. Auto-capture and auto-retrieval
can be injected at well-defined lifecycle checkpoints with minimal invasiveness. The primary
challenge is noise filtering -- not all research findings or implementation decisions merit
long-term memory. A three-tier quality gate is recommended.

---

## Key Findings

### 1. Current Memory Architecture

The memory vault lives at `.memory/` with the following structure:

```
.memory/
├── 00-Inbox/          -- Quick capture staging
├── 10-Memories/       -- MEM-{semantic-slug}.md files
├── 20-Indices/        -- index.md with by-category and by-topic navigation
└── 30-Templates/      -- Memory entry templates
```

Memory files follow frontmatter with `title`, `created`, `tags`, `topic`, `source`, `modified`
fields. The index is regenerated from filesystem state (idempotent) after each write.

**Current write path**: User invokes `/learn` -> `skill-memory` direct execution -> content
mapping -> MCP or grep search -> user confirms UPDATE/EXTEND/CREATE per segment.

**Current read path**: Agents load `.memory/` files directly. The `--remember` flag on
`/research` is the only automatic injection mechanism, and it requires explicit user invocation.
No lifecycle checkpoints automatically search or inject memories.

### 2. Lifecycle Checkpoints for Auto-Capture Injection

The lifecycle follows the GATE IN -> DELEGATE -> GATE OUT -> COMMIT pattern. There are three
candidate injection points:

#### A. Research Postflight (skill-researcher, Stage 7-8)

After `general-research-agent` writes a research report and returns metadata, skill-researcher
runs postflight operations (status update, artifact linking, git commit). This postflight runs
in the skill context (not subagent context), so it has direct filesystem access.

**Candidate content**: The research report in `specs/{NNN}_{SLUG}/reports/` contains synthesized
findings, recommendations, and evidence. This is the richest content for memory capture.

**Constraint**: The `postflight-tool-restrictions.md` standard explicitly lists `Write` to
`.memory/` and MCP tool calls as **prohibited** in postflight. The restriction exists to keep
postflight focused on state management.

**Resolution**: Auto-capture must occur as a non-blocking, low-priority appended stage AFTER
the mandatory postflight stages (6-10), or be delegated back into the agent's work via the
metadata file.

#### B. Implementation Postflight (skill-implementer, Stage 7-8)

After implementation, the completion metadata includes `completion_summary` and `roadmap_items`.
This is a natural extraction point for workflow patterns and configuration discoveries.

**Candidate content**: `completion_summary` field (required on completion), implementation
decisions embedded in summaries, configuration patterns discovered.

**Constraint**: Same postflight restriction. Skill-implementer postflight also writes more
files than skill-researcher (state, TODO, plan file), increasing complexity of adding stages.

#### C. Archival (skill-todo, Stage 7: HarvestMemories)

The `/todo` command already has a `HarvestMemories` stage (Stage 7) that scans artifacts and
generates suggestions, then presents them via `AskUserQuestion` at Stage 9. This is the most
mature capture point -- it already does what auto-capture needs to do, but interactively.

**Current behavior**: Fully interactive -- user selects from multiSelect, skill creates memories
with category tags in Stage 14 (CreateMemories).

**Auto-capture opportunity**: Stage 7 analysis already classifies content into TECHNIQUE,
PATTERN, CONFIG, WORKFLOW, INSIGHT categories. An auto-mode could skip the interactive step
for high-confidence PATTERN and CONFIG extractions, while still presenting INSIGHT and WORKFLOW
to the user.

### 3. Context Loading System for Auto-Retrieval

The context loading system uses `index.json` with a `load_when` schema:

```json
{
  "load_when": {
    "always": true,
    "agents": ["general-research-agent"],
    "task_types": ["meta"],
    "commands": ["/plan"]
  }
}
```

**Current memory loading**: `.memory/` files are listed in the context discovery documentation
as "Layer 3: Project Memory -- loaded directly, no index needed." The discovery pattern is:

```bash
find .memory -name "*.md" -type f 2>/dev/null
```

This loads ALL memory files for any agent that discovers them. There is no selective loading
based on relevance to the current task.

**The --remember flag**: Documented as requiring MCP search to find relevant memories.
Currently only on `/research`. The flag triggers keyword-based search against the vault and
injects matches into research context.

**Auto-retrieval gap**: The `.memory/` discovery is all-or-nothing. There is no mechanism for
an agent to receive only the memories relevant to its current task without reading everything
or using MCP search.

### 4. Quality Filtering Gap Analysis

The current system has no automated quality filter. The interactive skill-memory workflow
requires a human to:
- Select which content segments to save
- Choose UPDATE/EXTEND/CREATE
- Confirm operation

For autonomous capture, a quality filter must distinguish between:

| Category | Capture? | Filter Criteria |
|----------|----------|-----------------|
| Reusable patterns | YES | Appears generalizable, not task-specific |
| Configuration decisions | YES | Tool/system configuration with rationale |
| Research findings | CONDITIONAL | Novel, not in existing memories |
| Task-specific details | NO | Tied to this specific task context |
| Error messages | NO | Implementation noise |
| Intermediate decisions | NO | Superseded by final outcome |

---

## Recommended Approach

### A. Auto-Capture: Three-Tier Quality Gate at Archival

**Primary injection point**: skill-todo's existing HarvestMemories stage (Stage 7).

**Rationale**: This is the best natural checkpoint because:
1. Task is fully complete -- no risk of capturing incomplete or abandoned work
2. Stage 7 already does the analysis work (scans reports, plans, summaries)
3. It has the full task context (type, completion_summary, all artifacts)
4. It already classifies into TECHNIQUE/PATTERN/CONFIG/WORKFLOW/INSIGHT

**Three-tier gate**:

```
Tier 1 (AUTO-CAPTURE): High-confidence, low-noise
  - Category: PATTERN or CONFIG
  - Source: summary artifact (completion_summary field)
  - Deduplication: MCP/grep search shows <30% overlap with existing memories
  - Capture: CREATE new memory without user confirmation

Tier 2 (SUGGEST with default YES): Medium confidence
  - Category: WORKFLOW or TECHNIQUE
  - Source: research report key findings section
  - Deduplication: <60% overlap
  - Present in AskUserQuestion with "Yes" pre-selected

Tier 3 (SUGGEST with default NO): Low confidence / high noise risk
  - Category: INSIGHT
  - Source: any artifact
  - Overlap: Any
  - Present in AskUserQuestion with "Skip" pre-selected, user must opt-in
```

**Why not research/implement postflight**:
- Postflight restrictions explicitly prohibit extra tool calls and writes to `.memory/`
- Would require either violating the standard or restructuring the standard
- Archival captures completed work, not in-progress work (better signal quality)
- Research postflight happens when the task may later be abandoned -- wasted capture

### B. Auto-Retrieval: Selective Injection via index.json Extension

**Primary mechanism**: Extend the `load_when` schema to support topic-based memory selection.

Currently, memory loading is all-or-nothing. For auto-retrieval, introduce a `memory_topics`
array in the `load_when` schema:

```json
{
  "load_when": {
    "agents": ["general-research-agent"],
    "memory_topics": ["agent-system/architecture", "meta/commands"]
  }
}
```

This would allow agents to declare which memory topics are relevant to their context, and
the context discovery query would filter `.memory/` files by topic.

**Implementation path**:

1. The research command's Stage 4 (prepare delegation context) constructs a `memory_query`
   from the task description keywords and task_type.
2. Context discovery runs against `.memory/` files, filtering by matching topics.
3. Relevant memory file paths are injected into the agent prompt alongside other context.
4. No MCP required for basic filtering -- grep on frontmatter `topic:` field.

**Without changing context schema**: A simpler approach injects memory retrieval as a new
step in skill-researcher's Stage 4 (prepare delegation context):

```bash
# Auto-retrieval in skill-researcher Stage 4:
task_keywords=$(echo "$task_name $description" | tr ' ' '\n' | grep -E '.{4,}' | head -10)
for kw in $task_keywords; do
  grep -l -i "$kw" .memory/10-Memories/*.md 2>/dev/null
done | sort | uniq -c | sort -rn | head -3
# Inject top-3 relevant memories into delegation context
```

This is cheap, requires no schema change, and produces relevant results for most tasks.

### C. Quality Filtering: Category Confidence Scores

Introduce a `memory_confidence` score derived from:

```
base_score = category_score[PATTERN=1.0, CONFIG=0.9, WORKFLOW=0.7, TECHNIQUE=0.7, INSIGHT=0.5]
novelty_score = 1.0 - max_overlap_with_existing
combined = base_score * novelty_score

Tier 1 (auto-capture): combined >= 0.8
Tier 2 (suggest yes):  0.5 <= combined < 0.8
Tier 3 (suggest no):   combined < 0.5
```

This filter ensures:
- Common patterns that already exist are not duplicated
- Novel insights (even low-confidence category) can be captured if sufficiently novel
- Configuration that already has a memory gets EXTEND not CREATE

---

## Evidence / Examples

### Example: skill-todo HarvestMemories Stage (current)

From `skill-todo/SKILL.md`, Stage 7 currently does:
```
1. For each completed task:
   - Scan reports/ for insights and findings
   - Scan plans/ for reusable patterns
   - Check summaries/ for key learnings
2. Extract potential memory candidates
3. Generate suggestions list with:
   - Source file path
   - Brief description of insight
   - Suggested memory category (TECHNIQUE, PATTERN, CONFIG, WORKFLOW, INSIGHT)
```

This is already exactly the auto-capture analysis. The gap is that Stage 9 presents
everything interactively. Adding the three-tier gate at Stage 7 would enable auto-capture
of Tier 1 items without Stage 9 interaction.

### Example: Postflight Restriction Enforcement

From `postflight-tool-restrictions.md`:
```
Prohibited Operations:
- Any MCP tool
- Write to source files
- Write to .claude/ (except specs/)
```

Writing to `.memory/` in postflight is technically not explicitly listed, but the principle
("postflight is LIMITED TO state management") clearly excludes it. The cleanest path avoids
this boundary entirely.

### Example: Current --remember Flag (manual retrieval)

From `CLAUDE.md` Memory Extension section:
```
The --remember flag on /research searches the memory vault for relevant prior knowledge
and includes matches in the research context.
```

This is the current manual retrieval mechanism. Auto-retrieval would make this behavior
the default for research agents when memory content is relevant, without requiring the flag.

### Example: All-or-Nothing Memory Loading

From `context-discovery.md`, Layer 3:
```bash
# List all memory files
find .memory -name "*.md" -type f 2>/dev/null
```

With only 8 memories, this is fine. As the vault grows to 100+ memories, selective loading
becomes necessary. The `topic:` frontmatter field in every memory file provides a free
filtering mechanism that doesn't require MCP.

---

## Confidence Level

| Finding | Confidence | Basis |
|---------|------------|-------|
| Postflight restriction prevents direct injection | HIGH | Documented standard |
| skill-todo HarvestMemories is best capture point | HIGH | Code review of Stage 7 |
| Topic-based filtering is viable for auto-retrieval | HIGH | topic: field in all memories |
| Three-tier quality gate design | MEDIUM | Extrapolated from category taxonomy |
| Confidence score formula | MEDIUM | Proposed; needs validation |
| Auto-capture at archival produces better signal | MEDIUM | Hypothesis (task complete = stable) |

**Overall design confidence**: MEDIUM-HIGH. The injection points are clear and well-understood.
The quality gate design is reasonable but the exact thresholds need empirical validation.

---

## Gaps for Teammate B

The following questions remain open for complementary research:

1. **Retrieval strategy**: Should auto-retrieval use semantic similarity, topic matching, or
   keyword overlap? How should the memory injection be bounded (top-N, token budget)?

2. **MCP dependency**: The `--remember` flag uses MCP for search. Is MCP availability the
   bottleneck, or is grep-based topic matching sufficient for auto-retrieval?

3. **Schema changes**: Does the `load_when` schema need to be extended, or can auto-retrieval
   be implemented entirely within skill/agent logic without schema changes?

4. **Conflict with interactive mandate**: `skill-memory/SKILL.md` has a MANDATORY INTERACTIVE
   REQUIREMENT ("STOP at Step 4 and call AskUserQuestion"). Any auto-capture path must either
   use a different code path or explicitly override this requirement for agent-triggered captures.

5. **Memory inflation risk**: Without quality filtering, automated capture could flood the
   vault with low-value memories, degrading retrieval signal. What is the right vault
   maintenance strategy (pruning, archival, summarization)?
