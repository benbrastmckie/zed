# Research Report: Task #85

**Task**: 85 - Create /port command, skill-port, and port-agent
**Started**: 2026-05-11T00:00:00Z
**Completed**: 2026-05-11T00:45:00Z
**Effort**: Medium (3-5 files to create, 2-3 files to modify)
**Dependencies**: web extension (must be loaded)
**Sources/Inputs**: Codebase analysis of existing commands, skills, agents, and manifests
**Artifacts**: - This report at specs/085_create_port_command_skill_agent/reports/01_port-command-research.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The /port command follows the established **forcing-questions command pattern** used by /epi, /slides, /grant, and /budget
- The three-layer architecture (command -> skill -> agent) has well-defined templates extracted from existing implementations
- /port should live in the **web extension** (not as a standalone extension) since it creates web-typed tasks
- The command needs 5-7 forcing questions covering source URL/path, target design system, content scope, structure decisions, and feature preferences
- The port-agent should be a specialized variant of web-implementation-agent with additional WebFetch capabilities for scraping source sites

## Context and Scope

This research analyzed the existing command/skill/agent architecture to extract precise templates for creating the /port command. The goal is to enable users to point at an existing website (by URL or local path), answer scoping questions, and then use the standard /research -> /plan -> /implement lifecycle to build a new Astro/Tailwind site that ports the content and design intent.

## Findings

### 1. Command Pattern (Forcing Questions Structure)

All forcing-questions commands share a common structure with minor variations.

**Common Structure Across /epi, /slides, /grant, /budget**:

```
1. Frontmatter: description, allowed-tools (always includes AskUserQuestion), argument-hint, model
2. STAGE 0: PRE-TASK FORCING QUESTIONS (runs before task creation)
   - 3-10 AskUserQuestion calls (varies by command)
   - Each response stored as forcing_data.{field_name}
   - Final step assembles forcing_data JSON object with gathered_at timestamp
3. CHECKPOINT 1: GATE IN
   - Generate session ID
   - Detect input type (description vs task_number vs file_path)
   - Route based on input type
4. STAGE 1: TASK CREATION (for new tasks only)
   - Read next_project_number from state.json
   - Create slug from description
   - Update state.json (with forcing_data embedded in task)
   - Update TODO.md (frontmatter + entry)
   - Git commit
   - Output: task created summary with recommended workflow
5. STAGE 2: RESEARCH DELEGATION (task number input only)
   - Validate task exists and has correct task_type
   - Delegate to appropriate skill
   - Gate Out: verify research completed
```

**Key Frontmatter Pattern**:
```yaml
---
description: Short description of what the command does
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(date:*), Bash(sed:*), Read, Edit, AskUserQuestion
argument-hint: "description" | TASK_NUMBER | /path/to/file | URL
model: opus
---
```

**Input Type Detection Pattern** (from all commands):
```bash
# Check for task number
if echo "$ARGUMENTS" | grep -qE '^[0-9]+$'; then
  input_type="task_number"
# Check for file path
elif echo "$ARGUMENTS" | grep -qE '^\.|^/|^~|\.md$|\.html$'; then
  input_type="file_path"
# Check for URL (NEW for /port)
elif echo "$ARGUMENTS" | grep -qE '^https?://'; then
  input_type="url"
# Default: description
else
  input_type="description"
fi
```

**Forcing Data Assembly Pattern** (from all commands):
```json
{
  "field_1": "{response}",
  "field_2": ["{parsed}", "{array}"],
  "field_3": "{response_or_null}",
  "gathered_at": "{ISO timestamp}"
}
```

**Task Type Assignment**:
- /epi uses `task_type: "epi:study"`
- /slides uses `task_type: "present:slides"`
- /grant uses `task_type: "grant"` (under present)
- /budget uses `task_type: "budget"` (under present)
- /port should use `task_type: "web"` (simple, under web extension)

### 2. Skill Pattern (Thin Wrapper Template)

All thin-wrapper skills share an identical structure with minor variations for workflow routing.

**Common SKILL.md Structure**:

```markdown
---
name: skill-{domain}-{operation}
description: One-line description. Invoke for X tasks.
allowed-tools: Task, Bash, Edit, Read, Write
---

# {Domain} {Operation} Skill

Thin wrapper that delegates work to `{agent-name}` subagent.

## Stages:
1. Input Validation (lookup task in state.json, validate task_type)
2. Preflight Status Update (researching/implementing in state.json + TODO.md)
3. Create Postflight Marker (.postflight-pending file)
4. Prepare Delegation Context (JSON with task_context, session_id, metadata_file_path)
5. Invoke Subagent (via Task tool, NOT Skill tool)
5b. Self-Execution Fallback (write .return-meta.json if Task tool wasn't used)

## Postflight (ALWAYS EXECUTE):
6. Read Metadata File (.return-meta.json)
7. Update Task Status (state.json + TODO.md)
8. Link Artifacts (two-step jq pattern)
9. Git Commit
10. Cleanup (remove .postflight-pending, .return-meta.json)
11. Return Brief Summary (text, NOT JSON)
```

**Key Observations**:
- Skills ALWAYS use the Task tool (not Skill tool) to spawn agents
- Skills own the preflight and postflight; agents own the work
- The postflight includes artifact linking in state.json with the "| not" jq pattern
- Skills return brief text summaries, never JSON

**For /port**: The skill-port should be a single-workflow skill (like skill-web-research) rather than a multi-workflow skill (like skill-slides or skill-grant). The /port command creates a web task, and the standard /research -> /plan -> /implement lifecycle handles the rest. The skill-port only needs to handle the research phase (analyzing the source site).

### 3. Agent Pattern (Execution Agent Template)

All agents share a common structure.

**Common Agent Structure**:

```markdown
---
name: {agent-name}
description: One-line description
disallowedTools: (optional tool restrictions)
model: opus (optional, defaults to opus)
---

# {Agent Name}

## Overview
Purpose, invocation pattern, return format note.

## Agent Metadata
- Name, Purpose, Invoked By, Return Format

## Allowed Tools
List of tools with descriptions.

## Context References
@-references loaded on-demand.

## Execution Flow
- Stage 0: Initialize Early Metadata (CRITICAL)
- Stage 1: Parse Delegation Context
- Stage 2: Analyze Task / Load Context
- Stage 3-5: Execute Work
- Stage 6: Create Artifacts
- Stage 7: Write Metadata File (.return-meta.json)
- Stage 8: Return Brief Text Summary

## Error Handling
Recovery strategies by error type.

## Critical Requirements
MUST DO / MUST NOT lists.
```

**Key Observations**:
- Stage 0 (early metadata) is CRITICAL and must happen before any work
- Agents write to `.return-meta.json`, never return JSON to console
- Agents use status values like "researched", "implemented", "partial", "failed" -- never "completed"
- The `disallowedTools` frontmatter field restricts specific MCP tools

**For port-agent**: The agent should combine web-research-agent's web search capabilities with specific WebFetch-based site scraping. It needs:
- WebFetch to retrieve the source site's HTML
- Read for local file paths
- Write/Edit for creating reports
- Glob/Grep for analyzing the existing Astro project structure

### 4. Web Extension Integration

The web extension manifest at `.claude/extensions/web/manifest.json` shows the registration pattern.

**Current Web Extension Structure**:
```json
{
  "name": "web",
  "provides": {
    "agents": ["web-implementation-agent.md", "web-research-agent.md"],
    "skills": ["skill-web-implementation", "skill-web-research"],
    "commands": [],
    "rules": ["web-astro.md"],
    "context": ["project/web"]
  },
  "routing": {
    "research": { "web": "skill-web-research" },
    "plan": { "web": "skill-planner" },
    "implement": { "web": "skill-web-implementation" }
  }
}
```

**Updates Needed for /port**:
1. Add `"port.md"` to `provides.commands`
2. Add `"port-agent.md"` to `provides.agents`
3. Add `"skill-port"` to `provides.skills`
4. The routing table does NOT need changes -- /port creates web-typed tasks, so the existing routing handles /research, /plan, /implement
5. Update `EXTENSION.md` to document the /port command
6. Consider adding `"web:port"` routing if port-specific research is needed (optional)

**Decision Point**: Should /port research use a specialized port-agent or the existing web-research-agent?

- **Option A**: Use existing web-research-agent for /research, add port-agent only for a custom /port N workflow that analyzes the source site. This means /port creates the task AND performs initial site analysis in one step.
- **Option B**: Create a separate web:port task_type with its own routing to skill-port for research. This follows the present:slides pattern but adds complexity.
- **Recommendation**: Option A is simpler and more aligned with the web extension's flat structure. The /port command should do the site analysis during task creation (like /slides does for source materials), storing results in forcing_data. Then standard /research -> /plan -> /implement builds the new site.

### 5. Existing Web Workflow Documentation

The file `docs/workflows/web-development.md` documents the current web workflow. The /port command should be cross-referenced here. A new section like "Porting an existing site" would fit naturally after the "Starting a website project" section.

## Recommended /port Forcing Questions

Based on patterns from /epi (10 questions), /slides (4 questions), /grant (4 questions), and /budget (3 questions), the /port command should ask 5-7 focused questions.

### Question 0.1: Source Site

```
What site do you want to port?

Provide a URL or local file path to the existing website:
- URL: https://example.com
- Local path: /path/to/site/ or ./old-site/index.html

The agent will analyze the site's structure, content, and design.
```

Store as `forcing_data.source` (string).

### Question 0.2: Content Scope

```
What content should be ported?

- ALL: Port all pages and content
- SELECTED: Port specific pages (list paths or describe sections)
- STRUCTURE_ONLY: Port the layout/design but replace all content
- LANDING: Create a single landing page inspired by the source
```

Store as `forcing_data.content_scope`.

### Question 0.3: Design Approach

```
How should the design relate to the source?

- FAITHFUL: Match the source design as closely as possible (same colors, layout, typography)
- INSPIRED: Use the source as inspiration but modernize with Tailwind defaults
- REBRAND: Keep the structure but apply a completely new visual identity
- MINIMAL: Strip to content with clean, minimal styling
```

Store as `forcing_data.design_approach`.

### Question 0.4: Target Pages

```
What pages should the new site have?

Describe the desired page structure, or type 'auto' to mirror the source site.
Examples:
- "Home, About, Services, Contact"
- "auto" (mirror source structure)
- "Single landing page with all sections"
```

Store as `forcing_data.target_pages`.

### Question 0.5: Features and Interactivity

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

Store as `forcing_data.features` (null if skipped).

### Question 0.6: Additional Context

```
Any additional context or requirements? Type 'skip' if none.

Examples:
- Brand guidelines or color preferences
- Target audience
- Hosting preferences beyond Cloudflare Pages
- SEO requirements
- Accessibility priorities
```

Store as `forcing_data.additional_context` (null if skipped).

### Forcing Data Assembly

```json
{
  "source": "https://example.com",
  "content_scope": "ALL|SELECTED|STRUCTURE_ONLY|LANDING",
  "design_approach": "FAITHFUL|INSPIRED|REBRAND|MINIMAL",
  "target_pages": "Home, About, Services, Contact",
  "features": "Dark mode, contact form" or null,
  "additional_context": "..." or null,
  "gathered_at": "{ISO timestamp}"
}
```

## Recommended port-agent Capabilities

The port-agent serves as a **site analysis agent** invoked during the /port command's task creation or as part of /research on a web:port task. Its job is to analyze the source site and produce a structured report that informs the planner and implementation agents.

### Core Capabilities

1. **URL Fetching and HTML Analysis**
   - Use WebFetch to retrieve the source site's HTML
   - Parse page structure (headings, sections, navigation, footer)
   - Identify content areas and their hierarchy
   - Detect responsive design patterns

2. **Design Extraction**
   - Identify color palette from CSS/inline styles
   - Detect typography (font families, sizes, weights)
   - Map layout patterns (grid, flexbox, containers)
   - Note spacing and visual rhythm

3. **Content Inventory**
   - Catalog all pages and their URLs
   - Extract text content for each section
   - Identify images and their roles (hero, gallery, icons)
   - Map navigation structure

4. **Technology Detection**
   - Identify the source framework/CMS (WordPress, Next.js, Hugo, etc.)
   - Note JavaScript dependencies that may need Astro island equivalents
   - Identify forms, embeds, or dynamic content that needs special handling

5. **Local Path Analysis** (for file path input)
   - Read HTML/CSS files directly
   - Parse directory structure
   - Extract assets list

### Output: Site Analysis Report

The port-agent should produce a structured report at `specs/{NNN}_{SLUG}/reports/01_site-analysis.md` containing:

```markdown
# Site Analysis Report: {source_url}

## Source Overview
- URL/Path: {source}
- Technology: {detected_framework}
- Page Count: {N}
- Content Scope: {from forcing_data}

## Page Inventory
| Page | URL/Path | Sections | Content Summary |
|------|----------|----------|-----------------|
| Home | / | Hero, Features, CTA | ... |
| About | /about | Team, Mission, History | ... |

## Design Analysis
### Color Palette
- Primary: {color}
- Secondary: {color}
- Background: {color}
- Text: {color}

### Typography
- Headings: {font}
- Body: {font}
- Monospace: {font}

### Layout Patterns
- Navigation: {type}
- Content Width: {max-width}
- Grid: {columns/pattern}

## Content Extraction
### Page: {name}
{Extracted text content, section by section}

## Astro Migration Notes
- Components to create: {list}
- Layouts needed: {list}
- Islands (interactive elements): {list with recommended client: directives}
- Content collections: {if blog or similar}
- Static assets to port: {images, fonts, etc.}

## Tailwind v4 Theme Mapping
{Proposed @theme block based on extracted design}

## Risks and Considerations
- {Dynamic content that may not port cleanly}
- {JavaScript-dependent features needing islands}
- {External service integrations}
```

### Tool Requirements

| Tool | Purpose |
|------|---------|
| WebFetch | Retrieve source site HTML/CSS |
| WebSearch | Research source framework patterns |
| Read | Read local files, existing Astro project |
| Write | Create analysis report |
| Glob | Find related files in project |
| Grep | Search for patterns |
| Bash | Run build commands if needed |

## Architecture Decision: Where /port Lives

**Recommendation**: Add /port to the **web extension**, not as a standalone extension.

**Rationale**:
1. /port creates tasks with `task_type: "web"` -- it belongs with the web ecosystem
2. The present extension's /grant, /budget, /slides commands demonstrate that an extension can have multiple commands
3. Adding to web avoids creating a new extension with its own manifest, EXTENSION.md, and loader integration
4. The existing web routing (`web -> skill-web-research` for research, `web -> skill-web-implementation` for implementation) handles the downstream workflow automatically

**Alternative Considered**: A `web:port` compound task_type (like `present:slides`). This would require adding routing entries to the manifest. However, since port is a one-time analysis step followed by standard web development, the simple `web` task_type with forcing_data containing the port-specific information is sufficient.

## Files to Create

| File | Purpose |
|------|---------|
| `.claude/extensions/web/commands/port.md` | /port command definition (forcing questions + task creation) |
| `.claude/extensions/web/skills/skill-port/SKILL.md` | Thin wrapper skill for port-agent |
| `.claude/extensions/web/agents/port-agent.md` | Site analysis agent |

## Files to Modify

| File | Change |
|------|--------|
| `.claude/extensions/web/manifest.json` | Add port.md, port-agent.md, skill-port to provides; optionally add web:port routing |
| `docs/workflows/web-development.md` | Add "Porting an existing site" section |

## Decisions

1. **/port creates web-typed tasks** (not a new task type) -- simpler routing, reuses existing web agents for plan+implement
2. **port-agent runs during /research** (or as part of /port N) -- site analysis is research work
3. **Forcing questions focus on design intent** (not technical details) -- the agent handles technical analysis
4. **5-6 questions is optimal** -- enough to scope without being tedious (compared to /epi's 10)
5. **Source can be URL or local path** -- both use cases are common for porting

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| WebFetch may not fully render JavaScript-heavy sites | Note limitation in agent; recommend local path for SPA sites |
| Source site may be very large (100+ pages) | Content scope question lets user constrain; agent pageinates analysis |
| Design extraction from CSS is imprecise | Design approach question lets user choose fidelity level |
| Port agent may overlap with web-research-agent | Clear separation: port-agent does source analysis, web-research-agent does Astro/Tailwind research |

## Appendix

### Search Queries Used
- Codebase analysis: Read commands/epi.md, commands/slides.md, commands/grant.md, commands/budget.md
- Codebase analysis: Read skills/skill-web-research/SKILL.md, skills/skill-web-implementation/SKILL.md, skills/skill-slides/SKILL.md, skills/skill-grant/SKILL.md
- Codebase analysis: Read agents/web-research-agent.md, agents/web-implementation-agent.md, agents/grant-agent.md
- Codebase analysis: Read extensions/web/manifest.json, extensions/present/manifest.json
- Codebase analysis: Read docs/workflows/web-development.md
- Codebase analysis: Read context/guides/extension-development.md

### References
- Extension Development Guide: `.claude/context/guides/extension-development.md`
- Web Extension Manifest: `.claude/extensions/web/manifest.json`
- Present Extension Manifest: `.claude/extensions/present/manifest.json` (compound task_type pattern)
- Forcing Questions Pattern: `/epi` (10 questions), `/slides` (4 questions), `/grant` (4 questions), `/budget` (3 questions)
