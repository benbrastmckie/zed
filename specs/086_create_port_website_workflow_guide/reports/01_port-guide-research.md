# Research Report: Task #86

**Task**: 86 - Create port-website workflow guide
**Started**: 2026-05-11T00:00:00Z
**Completed**: 2026-05-11T00:15:00Z
**Effort**: small
**Dependencies**: None
**Sources/Inputs**: Codebase (.claude/commands/port.md, .claude/agents/port-agent.md, .claude/skills/skill-port/SKILL.md, docs/workflows/*.md)
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- The `/port` command has a well-defined 6-question forcing flow, four input types, and a clear three-step recommended workflow (`/research`, `/plan`, `/implement`)
- Existing workflow guides follow a consistent pattern: extension callout, decision guide table, forcing questions summary, example workflow code block, capabilities list, and "See also" links
- The new guide should be approximately 80-120 lines, matching the style and depth of `epidemiology-analysis.md` (single-command guide with forcing questions)
- The guide needs to be linked from `docs/workflows/web-development.md` and registered in `docs/workflows/README.md`

## Context and Scope

This research examines the `/port` command, its agent (`port-agent`), its skill (`skill-port`), and three existing workflow guides to determine the optimal structure, content, and cross-references for `docs/workflows/port-website.md`.

## Findings

### /port Command Flow

The `/port` command accepts four input types:

| Input Type | Example | Behavior |
|------------|---------|----------|
| Description string | `/port "Port the company site to Astro"` | Ask 6 forcing questions, create task, stop at [NOT STARTED] |
| Task number | `/port 42` | Resume existing web task, delegate to research |
| URL | `/port https://example.com` | Use URL as source, ask remaining 5 questions, create task |
| File/directory path | `/port /path/to/site/` | Use path as source, ask remaining 5 questions, create task |

**Forcing Questions** (6 total, asked before task creation):

1. **Source Site** (Q0.1) -- URL or local file path to the existing website. Skipped if URL/path provided as input.
2. **Content Scope** (Q0.2) -- ALL, SELECTED, STRUCTURE_ONLY, or LANDING.
3. **Design Approach** (Q0.3) -- FAITHFUL (match source), INSPIRED (modernize), REBRAND (new identity), or MINIMAL (strip to content).
4. **Target Pages** (Q0.4) -- Desired page structure or "auto" to mirror source.
5. **Features and Interactivity** (Q0.5) -- Dark mode, contact form, blog, gallery, nav style, or "none"/"skip".
6. **Additional Context** (Q0.6) -- Brand guidelines, audience, hosting, SEO, accessibility.

**Output**: Task created with type `web` at [NOT STARTED], with all forcing data stored in task metadata. The command prints a "Recommended workflow" suggesting `/research N`, `/plan N`, `/implement N`.

### Port Agent Capabilities

The `port-agent` performs site analysis through 8 stages:

1. **Source Site Analysis** -- Fetches/reads source (URL via WebFetch, local path via Read), discovers subpages
2. **Design Extraction** -- Color palette (mapped to oklch), typography, layout patterns, spacing
3. **Content Inventory** -- Page-by-page section inventory, content types, navigation structure
4. **Technology Detection** -- Framework/CMS identification (WordPress, Next.js, Gatsby, Hugo markers), JS dependencies, external services
5. **Astro Migration Notes** -- Components to create, layouts needed, interactive elements needing client directives, content collections, static assets
6. **Tailwind v4 Theme Mapping** -- Proposed `@theme` block based on extracted design tokens
7. **Report Generation** -- Structured site analysis report at `specs/{NNN}_{SLUG}/reports/{NN}_site-analysis.md`

**Limitations the guide should mention**:
- JavaScript-rendered sites (SPAs) may appear empty via WebFetch; recommend providing local build output
- Large sites (100+ pages) are sampled, not fully analyzed
- External CSS may not always be accessible

### Existing Guide Patterns

Analyzed three workflow guides for consistent structural patterns:

#### epidemiology-analysis.md (104 lines) -- best match for /port

- **Opening**: One-sentence description + blockquote extension requirement
- **Decision guide**: 3-row table mapping user intent to command variant
- **When to use**: Paragraph explaining scope and applicability
- **Task type routing**: Table showing task type keys -> skill mapping
- **Starting a new study**: Command example + forcing questions summary (numbered list, 10 items, one line each)
- **Example workflow**: Code block with 4 commands showing full lifecycle with inline comments
- **Capabilities list**: Bulleted list of what the agents can do
- **Resuming**: Short section on task number input
- **Using a file**: Short section on file path input
- **See also**: 4 links to related guides

#### web-development.md (123 lines) -- parent guide for /port link

- Same opening pattern with extension requirement callout
- Decision guide table
- "When to use" section explaining scope boundary
- Task type routing table
- Example workflow code block
- "Iterating on design" section showing `/revise` and `/review`
- "Build and deploy" section with terminal commands
- "Web development capabilities" bulleted list
- "See also" links

#### grant-development.md (93 lines) -- multi-command guide pattern

- Groups multiple related commands (`/grant`, `/budget`, `/timeline`, `/funds`, `/slides`)
- Each command gets a short section with code example and brief description
- Less deep forcing-question detail (just mentions "forcing questions ask about X, Y, Z")
- Cross-references lifecycle guide

**Key style observations across all guides**:
- Second-person voice ("Use `/port` when...")
- Code blocks use inline comments for context (`# -> creates task #15 at [NOT STARTED]`)
- No explicit "Prerequisites" section; extension requirement is a blockquote at top
- Forcing questions are summarized briefly (not full question text reproduced)
- "See also" always includes `agent-lifecycle.md` and `../agent-system/commands.md`

### Recommended Guide Structure

Based on the pattern analysis, `port-website.md` should follow the `epidemiology-analysis.md` template most closely, since both are single-command guides with forcing questions:

```
# Port a Website

Opening paragraph (1-2 sentences).

> **Requires the `web` extension.** callout

## Decision guide
| I want to... | Use |
3 rows: description, URL, task number

## When to use /port
Paragraph on scope: existing site -> Astro/Tailwind.
Note: contrasts with /task --type web for new sites.

## Starting a new port
Code example + forcing questions summary (numbered, 6 items, one line each).

## Input types
Short table or list showing URL, path, description, task number behaviors.

## Example workflow
Code block with /port -> /research -> /plan -> /implement lifecycle.
Include inline comments showing what each step produces.

## Design approach options
Brief table: FAITHFUL, INSPIRED, REBRAND, MINIMAL with one-line descriptions.

## Limitations
- JavaScript-rendered sites
- Large sites (sampling)
- External CSS accessibility

## See also
- agent-lifecycle.md
- ../agent-system/commands.md
- web-development.md (parent guide)
- memory-and-learning.md
```

**Estimated length**: 80-100 lines.

### Cross-Reference Points

**From docs/workflows/README.md** -- Add entry to the "Web development" table:

```markdown
### Web development

| File | Description |
|---|---|
| [web-development.md](web-development.md) | Build websites with Astro 5, ... |
| [port-website.md](port-website.md) | Port existing websites to Astro/Tailwind: `/port` *(requires `web` extension)* |
```

Also add to the decision guide table:
```
| Port an existing website to Astro/Tailwind | [port-website.md](port-website.md) |
```

And to the "Common scenarios" section, add a "Porting an existing website" scenario.

**From docs/workflows/web-development.md** -- Add to the "See also" section:

```markdown
- [port-website.md](port-website.md) -- Port existing websites with `/port`
```

Also consider adding to the decision guide table in web-development.md:

```
| Port an existing website to Astro/Tailwind | `/port https://example.com` |
```

**From web-development.md decision guide** -- Currently has 4 rows. Adding a `/port` row creates a clear entry point for porting vs. building from scratch.

## Decisions

- Model the guide on `epidemiology-analysis.md` (single-command, forcing-question pattern) rather than `grant-development.md` (multi-command pattern)
- Summarize forcing questions as a numbered list with one line each, not the full question text
- Include a "Design approach options" section since the 4 design modes are a key differentiator
- Include a "Limitations" section since WebFetch has known constraints for SPAs
- Do not reproduce the full port-agent stage list; focus on user-facing workflow

## Risks and Mitigations

- **Risk**: Guide becomes stale if `/port` forcing questions change. **Mitigation**: Reference command file as source of truth, keep question summaries high-level.
- **Risk**: Overlaps with `web-development.md`. **Mitigation**: Clear scope boundary -- `/port` is for converting existing sites, `/task --type web` is for new sites.

## Appendix

### Files Examined

- `/home/benjamin/.config/zed/.claude/commands/port.md` (400 lines) -- Full command definition
- `/home/benjamin/.config/zed/.claude/agents/port-agent.md` (551 lines) -- Agent with 10-stage execution flow
- `/home/benjamin/.config/zed/.claude/skills/skill-port/SKILL.md` (308 lines) -- Skill wrapper with postflight
- `/home/benjamin/.config/zed/docs/workflows/web-development.md` (123 lines) -- Parent guide
- `/home/benjamin/.config/zed/docs/workflows/epidemiology-analysis.md` (104 lines) -- Style reference
- `/home/benjamin/.config/zed/docs/workflows/grant-development.md` (93 lines) -- Multi-command style reference
- `/home/benjamin/.config/zed/docs/workflows/README.md` (133 lines) -- Index to update
