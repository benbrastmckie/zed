---
name: skill-port
description: Analyze source websites for porting to Astro/Tailwind. Invoke for web porting research tasks.
allowed-tools: Task, Bash, Edit, Read, Write
---

# Port Research Skill

Thin wrapper that delegates site analysis to `port-agent` subagent.

**IMPORTANT**: This skill implements the skill-internal postflight pattern. After the subagent returns,
this skill handles all postflight operations (status update, artifact linking, git commit) before returning.

## Context References

Reference (do not load eagerly):
- Path: `.claude/context/project/web/README.md` - Web context overview
- Path: `.claude/context/project/web/domain/astro-framework.md` - Astro reference
- Path: `.claude/context/project/web/domain/tailwind-v4.md` - Tailwind v4 reference

## Trigger Conditions

This skill activates when:
- Task type is "web" AND forcing_data contains port-specific fields (source, content_scope, design_approach)
- Site analysis is needed for a website porting task created by /port

---

## Execution Flow

### Stage 1: Input Validation

Validate required inputs:
- `task_number` - Must be provided and exist in state.json
- `session_id` - Must be provided

```bash
# Lookup task
task_data=$(jq -r --argjson num "$task_number" \
  '.active_projects[] | select(.project_number == $num)' \
  specs/state.json)

# Validate exists
if [ -z "$task_data" ]; then
  return error "Task $task_number not found"
fi

# Extract fields
task_type=$(echo "$task_data" | jq -r '.task_type // "web"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')
forcing_data=$(echo "$task_data" | jq -r '.forcing_data // empty')

# Validate task_type is "web"
if [ "$task_type" != "web" ]; then
  return error "Task $task_number is type '$task_type', expected 'web'"
fi
```

---

### Stage 2: Preflight Status Update

Update task status to "researching" BEFORE invoking subagent.

**Update state.json**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researching" \
   --arg sid "$session_id" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    session_id: $sid
  }' specs/state.json > specs/tmp/state.json && mv specs/tmp/state.json specs/state.json
```

**Update TODO.md**: Use Edit tool to change status marker to `[RESEARCHING]`.

---

### Stage 3: Create Postflight Marker

```bash
padded_num=$(printf "%03d" "$task_number")
mkdir -p "specs/${padded_num}_${project_name}"

cat > "specs/${padded_num}_${project_name}/.postflight-pending" << EOF
{
  "session_id": "${session_id}",
  "skill": "skill-port",
  "task_number": ${task_number},
  "operation": "research",
  "reason": "Postflight pending: status update, artifact linking, git commit",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
```

---

### Stage 4: Prepare Delegation Context

```json
{
  "session_id": "sess_{timestamp}_{random}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "research", "skill-port"],
  "timeout": 3600,
  "task_context": {
    "task_number": N,
    "task_name": "{project_name}",
    "description": "{description}",
    "task_type": "web"
  },
  "forcing_data": {
    "source": "{url_or_path}",
    "content_scope": "ALL|SELECTED|STRUCTURE_ONLY|LANDING",
    "design_approach": "FAITHFUL|INSPIRED|REBRAND|MINIMAL",
    "target_pages": "{target_pages}",
    "features": "{features_or_null}",
    "additional_context": "{context_or_null}",
    "gathered_at": "{ISO timestamp}"
  },
  "metadata_file_path": "specs/{NNN}_{SLUG}/.return-meta.json"
}
```

---

### Stage 5: Invoke Subagent

**CRITICAL**: You MUST use the **Task** tool to spawn the subagent.

```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "port-agent"
  - prompt: [Include task_context, delegation_context, forcing_data, metadata_file_path]
  - description: "Analyze source website for porting task {N}"
```

The subagent will:
- Fetch/read the source site (URL via WebFetch, local path via Read)
- Analyze page structure, design, and content
- Extract design tokens (colors, typography, layout patterns)
- Identify technology stack and interactive elements
- Create structured site analysis report
- Write metadata file
- Return brief text summary

---

### Stage 5b: Self-Execution Fallback

**CRITICAL**: If you performed the work above WITHOUT using the Task tool (i.e., you read files,
wrote artifacts, or updated metadata directly instead of spawning a subagent), you MUST write a
`.return-meta.json` file now before proceeding to postflight. Use the schema from
`return-metadata-file.md` with status value "researched".

If you DID use the Task tool, skip this stage -- the subagent already wrote the metadata.

---

## Postflight (ALWAYS EXECUTE)

The following stages MUST execute after work is complete, whether the work was done by a
subagent or inline (Stage 5b). Do NOT skip these stages for any reason.

### Stage 6: Parse Subagent Return

Read the metadata file:

```bash
metadata_file="specs/${padded_num}_${project_name}/.return-meta.json"

if [ -f "$metadata_file" ] && jq empty "$metadata_file" 2>/dev/null; then
    status=$(jq -r '.status' "$metadata_file")
    artifact_path=$(jq -r '.artifacts[0].path // ""' "$metadata_file")
    artifact_type=$(jq -r '.artifacts[0].type // ""' "$metadata_file")
    artifact_summary=$(jq -r '.artifacts[0].summary // ""' "$metadata_file")
else
    status="failed"
fi
```

---

### Stage 7: Update Task Status (Postflight)

If status is "researched", update state.json and TODO.md.

**Update state.json**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researched" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts
  }' specs/state.json > specs/tmp/state.json && mv specs/tmp/state.json specs/state.json
```

**Update TODO.md**: Use Edit tool to change status marker to `[RESEARCHED]`.

---

### Stage 8: Link Artifacts

Add artifact to state.json with summary.

**IMPORTANT**: Use two-step jq pattern to avoid escaping issues.

```bash
if [ -n "$artifact_path" ]; then
    # Step 1: Filter out existing research artifacts (use "| not" pattern)
    jq '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
        [(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type == "research" | not)]' \
      specs/state.json > specs/tmp/state.json && mv specs/tmp/state.json specs/state.json

    # Step 2: Add new research artifact
    jq --arg path "$artifact_path" \
       --arg type "$artifact_type" \
       --arg summary "$artifact_summary" \
      '(.active_projects[] | select(.project_number == '$task_number')).artifacts += [{"path": $path, "type": $type, "summary": $summary}]' \
      specs/state.json > specs/tmp/state.json && mv specs/tmp/state.json specs/state.json
fi
```

**Update TODO.md**: Link artifact using count-aware format.

Apply the four-case Edit logic from `@.claude/context/patterns/artifact-linking-todo.md`
with `field_name=**Research**`, `next_field=**Plan**`.

---

### Stage 9: Git Commit

```bash
git add -A
git commit -m "task ${task_number}: complete research

Session: ${session_id}"
```

---

### Stage 10: Cleanup

```bash
rm -f "specs/${padded_num}_${project_name}/.postflight-pending"
rm -f "specs/${padded_num}_${project_name}/.postflight-loop-guard"
rm -f "specs/${padded_num}_${project_name}/.return-meta.json"
```

---

### Stage 11: Return Brief Summary

```
Site analysis completed for task {N}:
- Analyzed source site structure and design
- Extracted design tokens and content inventory
- Identified Astro migration requirements
- Created report at specs/{NNN}_{SLUG}/reports/MM_{short-slug}.md
- Status updated to [RESEARCHED]
- Changes committed
```

---

## Error Handling

### Input Validation Errors
Return immediately if task not found or wrong task type.

### Metadata File Missing
Keep status as "researching" for resume.

### Git Commit Failure
Non-blocking: Log failure but continue.

---

## Return Format

Brief text summary (NOT JSON).

Example successful return:
```
Site analysis completed for task 500:
- Fetched and analyzed https://example.com (12 pages)
- Extracted color palette, typography, and layout patterns
- Identified 3 interactive elements needing Astro islands
- Created report at specs/500_port_example_site/reports/01_site-analysis.md
- Status updated to [RESEARCHED]
- Changes committed with session sess_1736700000_abc123
```

Example partial return:
```
Site analysis partially completed for task 500:
- Fetched homepage and 3 subpages
- WebFetch failed for dynamic pages (JavaScript-rendered)
- Partial report created at specs/500_port_example_site/reports/01_site-analysis.md
- Status remains [RESEARCHING] - run /research 500 to continue
```
