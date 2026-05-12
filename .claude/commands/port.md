---
description: Port existing websites to Astro/Tailwind with pre-task forcing questions for site analysis
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(date:*), Bash(sed:*), Read, Edit, AskUserQuestion
argument-hint: "description" | TASK_NUMBER | https://example.com | /path/to/site
model: opus
---

# /port Command

Website porting command with structured scoping and task system integration.

## Overview

This command initiates website porting tasks through a 6-question forcing flow. It asks essential scoping questions BEFORE creating the task, storing gathered data in task metadata. After task creation, the user runs `/research`, `/plan`, and `/implement` to complete the workflow. The command focuses on collecting source site details, content scope, design approach, and feature preferences for porting to Astro/Tailwind CSS v4.

## Syntax

- `/port "Port the company marketing site to Astro"` - Ask questions, create task with gathered data
- `/port 500` - Resume existing web task (delegate to research)
- `/port https://example.com` - Use URL as source, ask questions, create task
- `/port /path/to/site/` - Use local path as source, ask questions, create task

## Input Types

| Input | Behavior |
|-------|----------|
| Description string | Ask 6 forcing questions, create task with forcing_data, stop at [NOT STARTED] |
| Task number | Load existing task, delegate to research, stop at [RESEARCHED] |
| URL | Use as source for Question 0.1, ask remaining questions, create task |
| File/directory path | Use as source for Question 0.1, ask remaining questions, create task |

---

## STAGE 0: PRE-TASK FORCING QUESTIONS

**This stage runs BEFORE task creation for new tasks (description, URL, or file path input).**

**Skip this stage if**: task number input.

### Step 0.1: Source Site

If the user already provided a URL or file path as input, store it directly and skip this question.

Otherwise, use AskUserQuestion:

```
What site do you want to port?

Provide a URL or local file path to the existing website:
- URL: https://example.com
- Local path: /path/to/site/ or ./old-site/index.html

The agent will analyze the site's structure, content, and design.
```

Store response as `forcing_data.source`.

### Step 0.2: Content Scope

Use AskUserQuestion:

```
What content should be ported?

- ALL: Port all pages and content
- SELECTED: Port specific pages (list paths or describe sections)
- STRUCTURE_ONLY: Port the layout/design but replace all content
- LANDING: Create a single landing page inspired by the source
```

Store response as `forcing_data.content_scope`.

### Step 0.3: Design Approach

Use AskUserQuestion:

```
How should the design relate to the source?

- FAITHFUL: Match the source design as closely as possible (same colors, layout, typography)
- INSPIRED: Use the source as inspiration but modernize with Tailwind defaults
- REBRAND: Keep the structure but apply a completely new visual identity
- MINIMAL: Strip to content with clean, minimal styling
```

Store response as `forcing_data.design_approach`.

### Step 0.4: Target Pages

Use AskUserQuestion:

```
What pages should the new site have?

Describe the desired page structure, or type 'auto' to mirror the source site.
Examples:
- "Home, About, Services, Contact"
- "auto" (mirror source structure)
- "Single landing page with all sections"
```

Store response as `forcing_data.target_pages`.

### Step 0.5: Features and Interactivity

Use AskUserQuestion:

```
Any specific features or interactive elements needed?

Examples:
- Dark mode toggle
- Contact form
- Blog/content section
- Image gallery
- Navigation menu style (hamburger, sidebar, top bar)
- "none" for static content only

Type 'skip' to let the agent decide based on the source site.
```

Store response as `forcing_data.features` (null if skipped).

### Step 0.6: Additional Context

Use AskUserQuestion:

```
Any additional context or requirements? Type 'skip' if none.

Examples:
- Brand guidelines or color preferences
- Target audience
- Hosting preferences beyond Cloudflare Pages
- SEO requirements
- Accessibility priorities
```

Store response as `forcing_data.additional_context` (null if skipped).

### Step 0.7: Assemble Forcing Data

```json
{
  "source": "{url_or_path}",
  "content_scope": "ALL|SELECTED|STRUCTURE_ONLY|LANDING",
  "design_approach": "FAITHFUL|INSPIRED|REBRAND|MINIMAL",
  "target_pages": "Home, About, Services, Contact",
  "features": "Dark mode, contact form" or null,
  "additional_context": "..." or null,
  "gathered_at": "{ISO timestamp}"
}
```

---

## CHECKPOINT 1: GATE IN

**Display header**:
```
[Port] Website Porting
```

### Step 1: Generate Session ID

```bash
session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
```

### Step 2: Detect Input Type

```bash
# Check for task number
if echo "$ARGUMENTS" | grep -qE '^[0-9]+$'; then
  input_type="task_number"
  task_number="$ARGUMENTS"

# Check for URL
elif echo "$ARGUMENTS" | grep -qE '^https?://'; then
  input_type="url"
  source_url="$ARGUMENTS"

# Check for file/directory path
elif echo "$ARGUMENTS" | grep -qE '^\.|^/|^~|\.html$|\.htm$'; then
  input_type="file_path"
  source_path="$ARGUMENTS"

# Default: treat as description for new task
else
  input_type="description"
  description="$ARGUMENTS"
fi
```

### Step 3: Handle Input Type

**If task number**:
Load existing task, validate task_type is "web", then delegate to research via skill-orchestrator.

**If URL**:
Store URL as `forcing_data.source`, skip Question 0.1, run remaining Stage 0 forcing questions (Steps 0.2-0.6). Then proceed to task creation.

**If file path**:
Store path as `forcing_data.source`, skip Question 0.1, run remaining Stage 0 forcing questions (Steps 0.2-0.6). Then proceed to task creation.

**If description**:
Run Stage 0 forcing questions (Steps 0.1-0.6), then proceed to task creation.

---

## STAGE 1: TASK CREATION

**This stage runs for new tasks only (description, URL, or file path input).**

### Step 1: Read next_project_number

```bash
next_num=$(jq -r '.next_project_number' specs/state.json)
```

### Step 2: Create slug from description

- Lowercase, replace spaces with underscores
- Remove special characters
- Max 50 characters
- Prefix with "port_" if not already descriptive (e.g., "port_example_site")

### Step 2.5: Enrich Description

Construct an enriched description incorporating forcing data:

1. Start with the base description:
   - If `input_type="description"`: use the user's original text
   - If `input_type="url"`: synthesize from URL domain and content scope
   - If `input_type="file_path"`: synthesize from directory name and content scope

2. Append design approach in parentheses.

**Target format**:
```
Port {source} to Astro ({design_approach}, {content_scope})
```

### Step 3: Update state.json

```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg desc "$enriched_description" \
  --argjson forcing "$forcing_data_json" \
  --arg slug "$slug" \
  --argjson num "$next_num" \
  '.next_project_number = ($num + 1) |
   .active_projects = [{
     "project_number": $num,
     "project_name": $slug,
     "status": "not_started",
     "task_type": "web",
     "description": $desc,
     "forcing_data": $forcing,
     "created": $ts,
     "last_updated": $ts
   }] + .active_projects' \
  specs/state.json > specs/tmp/state.json && \
  mv specs/tmp/state.json specs/state.json
```

### Step 4: Update TODO.md

**Part A - Update frontmatter**:
```bash
sed -i 's/^next_project_number: [0-9]*/next_project_number: {NEW_NUMBER}/' \
  specs/TODO.md
```

**Part B - Add task entry** by prepending to `## Tasks` section:
```markdown
### {N}. {Title}
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Task Type**: web

**Description**: {enriched_description}

**Forcing Data Gathered**:
- Source: {forcing_data.source}
- Content scope: {forcing_data.content_scope}
- Design approach: {forcing_data.design_approach}
- Target pages: {forcing_data.target_pages}
- Features: {forcing_data.features}
- Additional context: {forcing_data.additional_context}
```

### Step 5: Git commit

```bash
git add specs/
git commit -m "task {N}: create {title}

Session: {session_id}"
```

### Step 6: Output

```
Port task #{N} created: {TITLE}
Status: [NOT STARTED]
Task Type: web
Source: {forcing_data.source}
Artifacts path: specs/{NNN}_{SLUG}/ (created on first artifact)

Forcing Data Gathered:
- Source: {forcing_data.source}
- Content scope: {forcing_data.content_scope}
- Design approach: {forcing_data.design_approach}
- Target pages: {forcing_data.target_pages}
- Features: {forcing_data.features}
- Additional context: {forcing_data.additional_context}

Recommended workflow:
1. /research {N} - Analyze source site structure, content, and design
2. /plan {N} - Create implementation plan for Astro migration
3. /implement {N} - Build the new Astro/Tailwind site
```

---

## STAGE 2: RESEARCH DELEGATION (task number input only)

When input is a task number, delegate to the appropriate research skill.

### Step 1: Validate Task

```bash
task_data=$(jq -r --argjson num "$task_number" \
  '.active_projects[] | select(.project_number == $num)' \
  specs/state.json)

# Validate exists
# Validate task_type is "web"
# Validate status is not terminal (block completed, abandoned, expanded)
```

### Step 2: Delegate

Route through skill-orchestrator which will select the appropriate web research skill:

**Invoke Skill tool**:
```
skill: "skill-orchestrator"
args: "command=research task_number={N} session_id={session_id}"
```

### Step 3: Gate Out

Verify research completed:
- Check status updated to "researched" in state.json
- Check for report artifact in specs/{NNN}_{SLUG}/reports/

**On success, output**:
```
Port research completed for Task #{N}
Status: [RESEARCHED]
Report: specs/{NNN}_{SLUG}/reports/{MM}_site-analysis.md

Next steps:
1. /plan {N} - Create implementation plan for Astro migration
2. /implement {N} - Build the new Astro/Tailwind site
```

---

## Error Handling

### Task Creation Errors
- Invalid description: Return guidance on expected format
- State update failure: Log error, do not commit partial state

### Research Errors
- Task not found: Return error with guidance to create task first
- Wrong task_type: Return error suggesting `/port` for website porting tasks
- Invalid status: Return error with current status and valid transitions

### Forcing Question Errors
- Empty source (Q1): Re-prompt with explanation of why required
- Invalid content scope: Re-prompt with valid options
- Invalid design approach: Re-prompt with valid options

### Git Commit Failure
- Non-blocking: Log failure but continue with success response
- Report to user that manual commit may be needed

---

## Output Format (Errors)

```
Port command error:
- {error description}
- {recovery guidance}
```
