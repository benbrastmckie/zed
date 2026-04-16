---
name: skill-memory
description: Memory vault management - create, search, classify, and index memories. Invoke for /learn command memory operations.
allowed-tools: Bash, Grep, Read, Write, Edit, AskUserQuestion
---

# Memory Skill (Direct Execution)

Direct execution skill for memory vault management. Handles memory creation, similarity search, classification, and index maintenance through content mapping, MCP-based deduplication, and three memory operations (UPDATE, EXTEND, CREATE).

**MANDATORY INTERACTIVE REQUIREMENT -- DO NOT SKIP**:
- STOP at Step 4 and call AskUserQuestion to show files. Write NOTHING to disk until user responds.
- STOP at Memory Search and call AskUserQuestion for each segment. Write NOTHING to disk until user responds.
- These are not optional. Running autonomously without user input is a critical failure.

## Context References

Reference (do not load eagerly):
- Path: `@.memory/30-Templates/memory-template.md` - Memory template
- Path: `@.memory/20-Indices/index.md` - Memory index
- Path: `@.claude/context/project/memory/learn-usage.md` - Usage guide

---

## Execution Modes

| Mode | Input | Description |
|------|-------|-------------|
| `text` | Text content | Add quoted text as memory |
| `file` | File path | Add single file content as memory |
| `directory` | Directory path | Scan directory for learnable content |
| `task` | Task number | Review task artifacts and create memories |
| `distill` | Flags | Vault health maintenance (via /distill command) |

All non-task modes flow through: **Content Mapping** -> **Memory Search** -> **Memory Operations**

---

## Content Mapping

Content mapping is the intermediate representation between input acquisition and memory operations. It segments input into topic-aligned chunks that can be matched against existing memories.

### Content Map Data Structure

```json
{
  "source": {
    "type": "text|file|directory",
    "path": "/path/to/input",
    "total_tokens": 2500
  },
  "segments": [
    {
      "id": "seg-001",
      "topic": "neovim/plugins/telescope",
      "source_file": "/path/to/file.md",
      "source_lines": "15-42",
      "summary": "Telescope custom picker creation pattern",
      "estimated_tokens": 350,
      "key_terms": ["telescope", "picker", "finders", "sorters", "attach_mappings"]
    }
  ]
}
```

### Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique segment identifier (seg-NNN) |
| `topic` | string | Inferred topic path (slash-separated hierarchy) |
| `source_file` | string | Original file path (for file/directory modes) |
| `source_lines` | string | Line range in source file (e.g., "15-42") |
| `summary` | string | 1-2 sentence summary of segment content |
| `estimated_tokens` | number | Approximate token count for this segment |
| `key_terms` | array | 3-5 significant terms for matching |

### Segmentation Algorithms

#### Structured Files (Markdown)

Split at heading boundaries:

```
1. Identify all headings (# ## ### ####)
2. Each heading starts a new segment
3. Segment includes all content until next same-or-higher level heading
4. Top-level content before first heading becomes its own segment
```

#### Structured Files (Code)

Split at blank-line-separated blocks:

```
1. Identify function/class definitions
2. Group related comments with their definitions
3. Separate standalone comment blocks as documentation segments
4. Keep import/require blocks together
```

#### Unstructured Text

Split at paragraph boundaries with topic grouping:

```
1. Split at double-newline (paragraph boundaries)
2. Group adjacent paragraphs with keyword overlap >40%
3. Single-sentence paragraphs merge with adjacent
```

#### Directory Input

Each file becomes an initial segment, then large files are split:

```
1. Each file is an initial segment
2. Files >800 tokens are split at section boundaries
3. Files <100 tokens are candidates for merging with related files
```

### Small-Input Bypass

Inputs under 500 tokens skip segmentation and become a single segment:

```
if total_tokens < 500:
  segments = [{
    "id": "seg-001",
    "topic": inferred_topic,
    "summary": first_line_or_60_chars,
    "estimated_tokens": total_tokens,
    "key_terms": extract_keywords(content, 5)
  }]
```

### Segment Size Guidelines

| Condition | Action |
|-----------|--------|
| Segment <100 tokens | Merge with adjacent same-topic segment |
| Segment 200-500 tokens | Ideal size, no action |
| Segment >800 tokens | Split at next heading/paragraph boundary |

### Key Term Extraction

Extract 3-5 significant terms per segment:

```
1. Remove stop words (the, a, is, are, etc.)
2. Extract nouns and technical terms (>4 characters)
3. Prioritize: proper nouns > technical terms > common nouns
4. Deduplicate (case-insensitive)
5. Return top 5 by frequency within segment
```

---

## Memory Search

After content mapping, each segment is matched against existing memories to determine the appropriate operation (UPDATE, EXTEND, or CREATE).

### MCP Search Path

When MCP server is available, use the execute pattern:

```
For each segment in content_map.segments:
  query = segment.key_terms.join(" ")
  results = execute("search", {
    "query": query,
    "vault": ".memory",
    "limit": 5
  })
```

### Grep Fallback Path

When MCP is unavailable, use keyword-based file search:

```bash
# For each segment
for keyword in $key_terms; do
  grep -l -i "$keyword" .memory/10-Memories/*.md 2>/dev/null
done | sort | uniq -c | sort -rn | head -5
```

### Overlap Scoring

Score keyword overlap between segment and each matching memory:

```
overlap_score = |segment_terms intersect memory_terms| / |segment_terms|

Where:
- segment_terms = segment.key_terms
- memory_terms = keywords extracted from memory content (same algorithm)
```

### Classification Thresholds

| Overlap Score | Classification | Action |
|---------------|----------------|--------|
| >60% | HIGH | UPDATE - Replace memory content |
| 30-60% | MEDIUM | EXTEND - Append new section |
| <30% | LOW | CREATE - New memory |

### Search Result Presentation -- MANDATORY STOP

**YOU MUST call AskUserQuestion for EACH segment before writing anything. Do NOT infer what the user wants. Do NOT skip segments. Do NOT write memory files without explicit user confirmation per segment.**

Present each segment with related memories via AskUserQuestion:

```
Segment: {segment.summary}
Topic: {segment.topic}
Key terms: {segment.key_terms.join(", ")}

Related Memories:
1. MEM-telescope-custom-pickers (72% overlap) -> Recommended: UPDATE
2. MEM-neovim-plugin-patterns (45% overlap) -> Recommended: EXTEND
3. MEM-lua-module-structure (18% overlap) -> Recommended: CREATE (no strong match)

What would you like to do with this segment?
[ ] UPDATE MEM-telescope-custom-pickers (replace content)
[ ] EXTEND MEM-neovim-plugin-patterns (append section)
[ ] CREATE new memory
[ ] SKIP - don't save this segment
```

### Interactive Override

Users can override any recommendation:
- Change UPDATE to CREATE (preserve existing, create duplicate)
- Change EXTEND to UPDATE (replace instead of append)
- Skip any segment
- Merge segments before processing (combine into single memory)

---

## Memory Operations

Three distinct operations for memory management:

### UPDATE Operation

Replace memory content while preserving structure:

```
1. Read existing memory file
2. Preserve frontmatter: created (original), tags, topic
3. Update frontmatter: modified = today
4. Move current content to ## History section with date marker
5. Replace main content with new segment content
6. Preserve ## Connections section
7. Write updated memory
```

Template for UPDATE:

```markdown
---
title: "{new_title_from_segment}"
created: {original_created}
tags: {merged_tags}
topic: "{existing_or_updated_topic}"
source: "{new_source}"
modified: {today}
---

# {new_title}

{new_content_from_segment}

## History

### Previous Version ({original_created})

{previous_content}

## Connections
{preserved_connections}
```

### EXTEND Operation

Append new dated section without modifying existing content:

```
1. Read existing memory file
2. Find insertion point (before ## Connections, or end of file)
3. Add dated extension section
4. Update frontmatter: modified = today
5. Optionally update tags if new topics introduced
6. Write updated memory
```

Template for EXTEND:

```markdown
## Extension ({today})

**Source**: {segment.source_file}

{segment_content}
```

### CREATE Operation

Generate new memory from segment:

```
1. Generate semantic slug from topic and title:

   generate_slug() {
     local topic="$1"
     local title="$2"
     local base=""

     # Priority 1: Topic path (most specific segment)
     if [ -n "$topic" ]; then
       base=$(echo "$topic" | rev | cut -d'/' -f1 | rev)
     fi

     # Priority 2: First 2-3 words of title
     local title_slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | \
       sed 's/[^a-z0-9 ]/-/g' | tr ' ' '-' | \
       cut -d'-' -f1-3 | sed 's/-$//')

     # Combine
     if [ -n "$base" ]; then
       slug="${base}-${title_slug}"
     else
       slug="$title_slug"
     fi

     # Sanitize and truncate to 50 chars
     slug=$(echo "$slug" | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//' | cut -c1-50)

     # Handle collision - NOTE: MEM- prefix preserved for grep discoverability
     local final_slug="$slug"
     local counter=2
     while [ -f ".memory/10-Memories/MEM-${final_slug}.md" ]; do
       final_slug="${slug}-${counter}"
       counter=$((counter + 1))
     done

     echo "$final_slug"
   }

   slug=$(generate_slug "$topic" "$title")
   filename="MEM-${slug}.md"

2. Apply memory template with all fields
3. Infer and apply topic
4. Add to index (both category and topic sections)
5. Write new memory file
```

Template for CREATE:

```markdown
---
title: "{segment.summary}"
created: {today}
tags: {inferred_tags}
topic: "{segment.topic}"
source: "{segment.source_file or 'user input'}"
modified: {today}
retrieval_count: 0
last_retrieved: null
keywords: {segment.key_terms}
summary: "{one-line summary of content}"
---

# {segment.summary}

{segment_content}

## Connections
<!-- Add links to related memories using [[filename]] syntax -->
```

**Note**: The MEM- prefix is preserved for grep discoverability (`grep -r "MEM-" .memory/`). Filenames follow the pattern `MEM-{semantic-slug}.md` (e.g., `MEM-telescope-custom-pickers.md`).

### Topic Inference

Infer topic using four-source priority:

```
1. Source directory path (highest priority)
   - /project/src/utils/ -> "project/utils"
   - /home/user/notes/neovim/ -> "neovim"

2. Keyword analysis
   - Extract domain indicators: neovim, lua, telescope, lazy
   - Map to topic: "neovim/plugins" or "neovim/config"

3. Related memory topics
   - If UPDATE/EXTEND: inherit topic from target memory
   - If CREATE with high-overlap match: suggest that topic

4. User confirmation/override
   - Always present inferred topic for confirmation
   - User can modify or create new topic path
```

### Index Maintenance

After each operation, update both `index.md` and `.memory/10-Memories/README.md`:

**index.md**:
```
1. Add/update entry in "## By Category" under appropriate tag
2. Add/update entry in "## By Topic" under topic path
3. Update "## Recent Memories" (prepend, keep last 10)
4. Update "## Statistics" counts
```

**`.memory/10-Memories/README.md`** -- regenerate the full file listing:
```
1. List all MEM-*.md files in the directory (ls .memory/10-Memories/MEM-*.md)
2. For each file, extract: title, topic, tags, created from frontmatter
3. Rewrite README.md with updated count and one entry per memory:
   ### [MEM-{slug}](MEM-{slug}.md)
   **Title**: {title}
   **Topic**: {topic}
   **Tags**: {tags}
   **Created**: {created}
4. Keep "## Navigation" section at the bottom
```

### Index Regeneration Pattern

To avoid concurrent write conflicts, regenerate both `index.md` and `memory-index.json` from filesystem state rather than append:

```bash
# 1. List all memory files
memories=$(ls .memory/10-Memories/MEM-*.md 2>/dev/null)

# 2. Extract metadata from each file
for mem in $memories; do
  title=$(grep -m1 "^title:" "$mem" | cut -d'"' -f2)
  topic=$(grep -m1 "^topic:" "$mem" | cut -d'"' -f2)
  created=$(grep -m1 "^created:" "$mem" | cut -d: -f2 | tr -d ' ')
  # Store for index generation
done

# 3. Regenerate index.md from extracted data
# Sort by date descending, write complete file

# 4. Regenerate memory-index.json (JSON manifest for two-phase retrieval)
# For each memory file:
#   - Extract frontmatter: title, topic, tags, summary, keywords, retrieval_count, last_retrieved
#   - Compute token_count = word_count * 1.3
#   - Derive category from first tag
#   - Extract status from frontmatter (default: "active", or "tombstoned" if present)
#   - Build JSON entry with all fields
# Write complete .memory/memory-index.json with:
#   version: 1, generated_at: ISO8601, entry_count: N, total_tokens: sum,
#   entries: [{id, path, title, summary, topic, category, keywords, token_count, created, modified, last_retrieved, retrieval_count, status}]
#   status field: "active" (default) or "tombstoned" (read from frontmatter)
```

Benefits:
- No append conflicts (complete overwrite)
- Self-healing (missing entries recovered)
- Idempotent (multiple regenerations produce same result)
- JSON index enables two-phase retrieval (index scan + selective file read)

### Validate-on-Read Pattern

Before using `memory-index.json` for retrieval, validate that the index is fresh:

```bash
# 1. List all MEM-*.md files on disk
disk_files=$(ls .memory/10-Memories/MEM-*.md 2>/dev/null | xargs -n1 basename | sed 's/.md$//')

# 2. List all entries in memory-index.json
index_ids=$(jq -r '.entries[].id' .memory/memory-index.json 2>/dev/null)

# 3. Compare: if any file exists on disk but not in index, or vice versa, regenerate
if [ "$(echo "$disk_files" | sort)" != "$(echo "$index_ids" | sort)" ]; then
  echo "Memory index stale - regenerating..."
  # Trigger full index regeneration (same as Index Regeneration Pattern step 4)
fi
```

This detects when memory files are added or removed without running `/learn`, ensuring retrieval always operates on fresh data.

---

## Task Mode Execution

Task mode has special handling for reviewing existing task artifacts.

### Step 1: Locate Task Directory

```bash
task_num=$task_number
padded_num=$(printf "%03d" $task_num)
task_dir=$(ls -d specs/${padded_num}_* 2>/dev/null | head -1)

if [ -z "$task_dir" ]; then
  task_dir=$(ls -d specs/${task_num}_* 2>/dev/null | head -1)
fi

if [ -z "$task_dir" ]; then
  echo "Task directory not found: specs/${padded_num}_*"
  exit 1
fi
```

### Step 2: Scan Artifacts

```bash
artifacts=$(find "$task_dir" -type f -name "*.md" | sort)

if [ -z "$artifacts" ]; then
  echo "No artifacts found for task ${task_number}"
  exit 1
fi
```

### Step 3: Present Artifact List

Display via AskUserQuestion:

```json
{
  "question": "Select artifacts to review for memory extraction:",
  "header": "Task Artifacts",
  "multiSelect": true,
  "options": [
    {
      "label": "{artifact_1_name}",
      "description": "{artifact_1_path}"
    }
  ]
}
```

### Step 4: Process Through Content Mapping

For each selected artifact:
1. Read content
2. If >500 tokens: run through content mapping (segmentation)
3. If <=500 tokens: treat as single segment
4. Proceed to Memory Search (Phase 4)
5. Proceed to Memory Operations (Phase 5)

### Step 5: Classification Taxonomy

For task artifacts, also present classification options:

```json
{
  "question": "Classify this segment:",
  "header": "Classification: {segment.summary}",
  "multiSelect": false,
  "options": [
    {"label": "[TECHNIQUE]", "description": "Reusable method or approach"},
    {"label": "[PATTERN]", "description": "Design or implementation pattern"},
    {"label": "[CONFIG]", "description": "Configuration or setup knowledge"},
    {"label": "[WORKFLOW]", "description": "Process or procedure"},
    {"label": "[INSIGHT]", "description": "Key learning or understanding"},
    {"label": "[SKIP]", "description": "Not valuable for memory"}
  ]
}
```

### Step 6: Return Result

```json
{
  "status": "completed",
  "mode": "task",
  "artifacts_reviewed": [...],
  "content_map": { ... },
  "operations": [
    {"type": "CREATE", "memory_id": "MEM-...", "category": "[PATTERN]"}
  ],
  "memories_affected": 3
}
```

---

## Directory Mode Execution

Directory mode scans a directory tree for learnable content.

### Step 1: Recursive Scanning

```bash
# Exclusion patterns
EXCLUDES="-path '*/.git' -prune -o -path '*/node_modules' -prune -o -path '*/__pycache__' -prune -o -path '*/.obsidian' -prune"

# Find all files
files=$(find "$directory_path" $EXCLUDES -type f -print | head -250)
```

### Step 2: Two-Tier Text Detection

**Tier 1: Extension Whitelist**

Recognized text extensions (alphabetized by category):

| Category | Extensions |
|----------|------------|
| Code | .c, .cpp, .cs, .go, .h, .hpp, .java, .js, .jsx, .kt, .lua, .php, .pl, .py, .r, .rb, .rs, .scala, .sh, .swift, .ts, .tsx, .vim |
| Config | .cfg, .conf, .ini, .json, .toml, .xml, .yaml, .yml |
| Data | .csv, .sql |
| Documentation | .adoc, .asciidoc, .md, .org, .rdoc, .rst, .tex, .txt |
| Web | .css, .htm, .html, .less, .sass, .scss, .svg |
| Neovim | .fnl, .janet, .nix |

**Tier 2: MIME-Type Fallback**

For files without recognized extensions:

```bash
mime=$(file --mime-type -b "$file")
if [[ "$mime" == text/* ]]; then
  # Include file
fi
```

### Step 3: Size Limits

```bash
# Per-file limit
if [ $(stat -c%s "$file") -gt 102400 ]; then
  echo "Skipping large file: $file (>100KB)"
  continue
fi

# Warning at 50 files
if [ ${#files[@]} -gt 50 ]; then
  echo "Warning: ${#files[@]} files found. Consider narrowing scope."
fi

# Hard limit at 200 files
if [ ${#files[@]} -gt 200 ]; then
  echo "Error: Too many files (${#files[@]}). Maximum is 200."
  echo "Narrow your path or use file mode for specific files."
  exit 1
fi
```

### Step 4: File Selection (Paginated) -- MANDATORY STOP

**YOU MUST call AskUserQuestion here. Do NOT skip to Step 5. Do NOT process any files until the user has made their selection.**

Present files in pages of 10 to avoid overwhelming the display. Accumulate selections across all pages before processing.

```
selected_files = []
page_size = 10
total_files = len(files)
page = 0

while page * page_size < total_files:
  start = page * page_size
  end = min(start + page_size, total_files)
  page_files = files[start:end]
  remaining = total_files - end
  page_num = page + 1
  total_pages = ceil(total_files / page_size)

  # Build options for this page
  options = [{"label": relative_path, "description": file_size} for each file in page_files]

  # Add navigation options at the bottom
  if remaining > 0:
    options.append({"label": "--- Continue to next page ---", "description": f"{remaining} more files remaining"})

  AskUserQuestion({
    "question": f"Select files to include (page {page_num}/{total_pages}, showing {start+1}-{end} of {total_files}):",
    "header": f"Directory Scan: {directory_path}",
    "multiSelect": true,
    "options": options
  })

  # Add any selected files (excluding the navigation option) to accumulated list
  selected_files.extend(user_selections excluding navigation option)

  # If user selected "Continue to next page" OR there are more pages, advance
  # If user did NOT select "Continue to next page" on the last page, stop
  if "--- Continue to next page ---" not in user_selections and remaining > 0:
    # User is done selecting (didn't ask for more)
    break

  page += 1

# After all pages processed, confirm total selection
if len(selected_files) == 0:
  print("No files selected. Exiting.")
  exit
```

Example page 1 of 3:
```json
{
  "question": "Select files to include (page 1/3, showing 1-10 of 28):",
  "header": "Directory Scan: /home/user/project/",
  "multiSelect": true,
  "options": [
    {"label": "README.md", "description": "4.1KB"},
    {"label": "src/main.lua", "description": "2.3KB"},
    {"label": "--- Continue to next page ---", "description": "18 more files remaining"}
  ]
}
```

### Step 5: Route Through Pipeline

For each selected file:
1. Read file content
2. Run through content mapping (directory-type segmentation)
3. Route segments through memory search
4. Route through memory operations
5. Update index

### Step 6: Return Result

```json
{
  "status": "completed",
  "mode": "directory",
  "files_scanned": 45,
  "files_selected": 12,
  "content_map": { ... },
  "operations": [...],
  "memories_affected": 8
}
```

---

## Text Mode Execution

### Step 1: Parse Input

```bash
content="$text_content"
source="user input"
```

### Step 2: Content Mapping

For text >500 tokens, segment at paragraph boundaries:

```
1. Split at double-newline
2. Group related paragraphs
3. Generate single content map
```

For text <500 tokens, create single segment.

### Step 3: Memory Search & Operations

Route through standard memory search and operations pipeline.

### Step 4: Return Result

```json
{
  "status": "completed",
  "mode": "text",
  "content_map": { ... },
  "operations": [...],
  "memories_affected": 1
}
```

---

## File Mode Execution

### Step 1: Read File

```bash
if [ ! -f "$file_path" ]; then
  echo "File not found: $file_path"
  exit 1
fi

content=$(cat "$file_path")
source="file: $file_path"
```

### Step 2: Content Mapping

Apply structured or unstructured segmentation based on file type.

### Step 3: Memory Search & Operations

Route through standard pipeline.

### Step 4: Return Result

```json
{
  "status": "completed",
  "mode": "file",
  "file_path": "...",
  "content_map": { ... },
  "operations": [...],
  "memories_affected": 2
}
```

---

## Distill Mode Execution (mode=distill)

Distill mode maintains vault health through scoring, reporting, and four distillation operations. Invoked via `/distill` command with flag routing.

### Execution Modes

| Mode | Flag | Description |
|------|------|-------------|
| `report` | (bare) | Read-only health report with vault metrics |
| `purge` | `--purge` | Tombstone stale/zero-retrieval memories |
| `combine` | `--merge` | Merge overlapping memories with keyword superset guarantee |
| `compress` | `--compress` | Reduce verbose memories to key points |
| `auto` | `--auto` | Automatic safe metadata fixes (no interaction) |
| `gc` | `--gc` | Hard-delete tombstoned memories past grace period |

### Scoring Engine

Compute composite distillation score for each memory entry in memory-index.json.

#### Score Components

**Staleness Score** (weight: 0.30):
```
days_since = (today - last_retrieved_or_created) in days
staleness = min(days_since / 90, 1.0)

# FSRS-inspired adjustment: old-but-retrieved memories are valuable
if retrieval_count > 0 AND days_since_created > 60:
  staleness = max(0, staleness - 0.3)
```

**Zero-Retrieval Penalty** (weight: 0.25):
```
if retrieval_count == 0 AND days_since_created > 30:
  zero_retrieval = 1.0
else:
  zero_retrieval = 0.0
```

**Size Penalty** (weight: 0.20):
```
size_penalty = max(0, (token_count - 600) / 600)
# Linear penalty above 600 tokens; capped at 1.0 for display
```

**Duplicate Score** (weight: 0.25):
```
# For each memory, compute keyword overlap with every other memory
# Use same overlap algorithm as Memory Search classification
duplicate = max(overlap_score(memory, other) for other in all_memories if other != memory)
```

**Composite Score**:
```
composite = (staleness * 0.30) + (zero_retrieval * 0.25) + (size_penalty * 0.20) + (duplicate * 0.25)
```

#### Topic-Cluster Grouping

Group memories by topic prefix (first path segment) before scoring:
```
clusters = {}
for memory in memories:
  prefix = memory.topic.split("/")[0] if "/" in memory.topic else memory.topic
  clusters[prefix].append(memory)
```

Process clusters independently to limit comparison scope for duplicate detection.

### Health Report Generation (bare invocation)

Read memory-index.json and compute:

1. **Overview metrics**: total memories, total tokens, average tokens/memory
2. **Category distribution**: Count by category (PATTERN, CONFIG, WORKFLOW, TECHNIQUE, INSIGHT)
3. **Topic cluster sizes**: Count memories per topic prefix
4. **Retrieval statistics**: retrieved-at-least-once vs never-retrieved, most/least retrieved
5. **Distillation candidates**:
   - Purge candidates: `zero_retrieval_penalty == 1.0` OR `staleness > 0.8`
   - Merge candidates: any pair with `overlap > 0.60`
   - Compress candidates: `token_count > 600`
6. **Health score**: `100 - (purge_candidates * 3) - (merge_candidates * 5) - (compress_candidates * 2)`, clamped to 0-100

Update `memory_health` in state.json after computing (even for bare report).

### Purge Operation (--purge)

**Step 1: Identify candidates**
Select memories where `zero_retrieval_penalty == 1.0` OR `staleness_score > 0.8`.

**Step 2: Category-aware TTL advisory thresholds** (for ranking, not automatic action):
- CONFIG: 180 days
- WORKFLOW: 365 days
- PATTERN: 540 days
- TECHNIQUE: 270 days
- INSIGHT: no TTL

**Step 3: Present candidates via AskUserQuestion**:
```json
{
  "question": "Select memories to purge ({N} candidates):",
  "header": "Distill: Purge",
  "multiSelect": true,
  "options": [
    {"label": "MEM-{slug}", "description": "Score: {score} | Created: {date} | Retrievals: {count} | {token_count} tokens"}
  ]
}
```

**Step 4: Tombstone selected memories**:
- Add to memory file frontmatter:
  ```yaml
  status: tombstoned
  tombstoned_at: {ISO8601}
  tombstone_reason: "purge"
  ```
- Do NOT delete the file
- Do NOT remove from memory-index.json (but set `status: "tombstoned"` in index entry)
- Tombstoned memories are excluded from retrieval scoring

**Step 5: Link scan**:
After tombstoning, scan all non-tombstoned memories for `[[MEM-{affected-slug}]]` references in Connections sections. Warn user about stale links.

**Step 6: Log to distill-log.json**:
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

### Garbage Collection (--gc)

**Step 1**: Scan for tombstoned memories where `tombstoned_at` is older than 7-day grace period.

**Step 2**: Present list via AskUserQuestion for confirmation:
```json
{
  "question": "Permanently delete {N} tombstoned memories past 7-day grace period?",
  "header": "Distill: Garbage Collection",
  "multiSelect": true,
  "options": [
    {"label": "MEM-{slug}", "description": "Tombstoned: {date} | Reason: {reason}"}
  ]
}
```

**Step 3**: On confirmation: delete memory files, remove from memory-index.json, regenerate index.md.

**Step 4**: Log deletion to distill-log.json.

### Combine Operation (--merge)

**Step 1: Identify merge candidates**:
For each topic cluster, compute pairwise keyword overlap. Pair memories with overlap > 60%. Rank pairs by overlap score descending.

**Step 2: Present by topic cluster via AskUserQuestion**:
```json
{
  "question": "Topic: {cluster_name} - Select pairs to merge ({N} candidates):",
  "header": "Distill: Combine",
  "multiSelect": true,
  "options": [
    {"label": "Merge: MEM-{a} + MEM-{b}", "description": "{overlap}% overlap | Shared: {shared_keywords}"}
  ]
}
```

**Step 3: Execute merge for each selected pair**:
1. Determine primary memory (higher retrieval_count, or older if equal)
2. Merge content: primary content + `## Merged From {secondary_id}` section with secondary content
3. **Keyword superset guarantee**: `merged_keywords = union(primary.keywords, secondary.keywords)`
   - Verify: `len(merged_keywords) >= len(union)` -- fail merge if not satisfied
4. Update frontmatter: `modified = today`, combine `retrieval_count`, keep earliest `created` date
5. Tombstone the secondary memory with `tombstone_reason: "merged_into:{primary_id}"`

**Step 4: Update cross-references**:
Scan all memories for `[[{secondary_id}]]` references, replace with `[[{primary_id}]]`.

**Step 5: Regenerate memory-index.json and index.md**.

**Step 6: Log each merge to distill-log.json**:
```json
{
  "timestamp": "ISO8601",
  "operation": "combine",
  "primary": "MEM-primary-slug",
  "secondary": "MEM-secondary-slug",
  "overlap_score": 0.72,
  "keywords_before": {"primary": [], "secondary": []},
  "keywords_after": [],
  "keyword_superset_verified": true,
  "pre_metrics": {"total_memories": 8},
  "post_metrics": {"total_memories": 7, "tombstoned": 1}
}
```

### Compress Operation (--compress)

**Step 1: Identify candidates**: Select memories where `token_count > 600`.

**Step 2: Present via AskUserQuestion**:
```json
{
  "question": "Select memories to compress ({N} candidates, all >600 tokens):",
  "header": "Distill: Compress",
  "multiSelect": true,
  "options": [
    {"label": "MEM-{slug}", "description": "{token_count} tokens | Topic: {topic} | Retrievals: {retrieval_count}"}
  ]
}
```

**Step 3: Execute compression**:
1. Read full content
2. Generate compressed version: extract key points, preserve code blocks and examples, remove redundant prose
3. Move original content to `## History > ### Pre-Compression ({date})` section (same pattern as UPDATE operation)
4. Recalculate `token_count` in frontmatter
5. Preserve all keywords (compression must not drop keywords)

**Step 4: Log to distill-log.json**:
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

### Refine and Auto Operation (--auto)

**Step 1: Identify refine candidates**:
- Missing or sparse keywords: memories with < 4 keywords
- Duplicate keywords within a single memory
- Missing `summary` field in frontmatter
- Missing or incorrect category classification
- Topic path inconsistencies

**Step 2: Automatic fixes (run with --auto, no confirmation needed)**:
- Deduplicate keywords within each memory
- Add missing `summary` field (generate from first line of content)
- Normalize topic paths (lowercase, consistent separators)

**Step 3: Interactive fixes (require confirmation, skipped with --auto)**:
- Keyword enrichment: suggest additional keywords based on content analysis
- Category reclassification: suggest category changes based on content
- Topic path correction: suggest topic changes based on cluster analysis

**Step 4: Rebuild memory-index.json from filesystem state**.

**Step 5: Update `memory_health` in state.json**.

**Step 6: Log all changes to distill-log.json**:
```json
{
  "timestamp": "ISO8601",
  "operation": "refine",
  "fixes_applied": {
    "keyword_dedup": 3,
    "summary_added": 2,
    "topic_normalized": 1
  },
  "memories_affected": ["MEM-slug-1", "MEM-slug-2"]
}
```

### Distill Log Schema

The distill log at `.memory/distill-log.json` records all operations for auditability:

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

The log file is created on first `/distill` invocation if it does not exist.

### Tombstone Pattern

Tombstoned memories are soft-deleted: they remain on disk but are excluded from retrieval.

**Frontmatter fields added on tombstone**:
```yaml
status: tombstoned
tombstoned_at: {ISO8601}
tombstone_reason: "purge" | "merged_into:{primary_id}"
```

**Index entry update**: Set `"status": "tombstoned"` in memory-index.json entry.

**Retrieval exclusion**: During two-phase retrieval scoring, filter out entries where `status == "tombstoned"`:
```bash
# When reading memory-index.json for retrieval
jq '.entries[] | select(.status == "tombstoned" | not)' .memory/memory-index.json
```

**Grace period**: Tombstoned memories are eligible for hard deletion via `--gc` after 7 days.

### Memory Health State (state.json)

The `memory_health` field in state.json (parallel to `repository_health`):

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

**Status values**:
- `"healthy"`: health_score >= 70
- `"needs_attention"`: health_score 40-69
- `"unhealthy"`: health_score < 40

Updated after every `/distill` invocation (including bare report).
For non-bare operations, `last_distilled` and `distill_count` are also updated.

---

## Error Handling

### No Content Provided

```
Usage: /learn <text or file path or directory> OR /learn --task N
```

### File Not Found

```
File not found: {path}
```

### Directory Not Found

```
Directory not found: {path}
```

### Empty Directory

```
No text files found in: {path}
```

### Too Many Files

```
Too many files ({N}). Maximum is 200.
Narrow your path or use file mode for specific files.
```

### Task Directory Not Found

```
Task directory not found: specs/{NNN}_*
```

### User Cancels

```
Memory operation cancelled. No files created.
```

### All Content Skipped

```
No memories created (all content skipped)
```

### MCP Unavailable

```
MCP search unavailable. Using grep-based fallback.
```

---

## Git Commit (Postflight)

After successful memory operations:

```bash
git add .memory/
git commit -m "memory: add/update ${memories_affected} memories

Session: ${session_id}
```
