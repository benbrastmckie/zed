# Teammate B Findings: Web Extension, Documentation Patterns, and Gap Analysis

**Task**: 84 - Create web development guide with example artifacts
**Date**: 2026-05-12
**Angle**: Alternative patterns, web extension configuration, existing documentation style, gap analysis

## Key Findings

1. **No web development workflow guide exists.** The `docs/workflows/` directory has guides for agent-lifecycle, epidemiology, grant development, memory, and Office documents -- but nothing for web/Astro/Tailwind development. This is a clear gap given that the `web` extension is a first-class, fully-featured extension.

2. **The web extension is comprehensive but entirely machine-facing.** There are 22 web context files under `.claude/context/project/web/` covering Astro framework, Tailwind v4, Cloudflare Pages, accessibility, performance, templates, tools, and patterns. Two agents (`web-research-agent`, `web-implementation-agent`), two skills, and one rule file (`web-astro.md`) exist. None of this is surfaced in user-facing documentation.

3. **Existing workflow guides follow a consistent pattern.** Every `docs/workflows/*.md` doc uses: (a) a decision guide table, (b) a section per command/operation with code blocks showing usage, (c) a narrative "what happens when you run this" style, (d) cross-references to other docs via `See also`, and (e) notes about required extensions.

4. **The web extension is on par with epidemiology and present in complexity** but has zero user documentation, while both of those have dedicated workflow guides.

## Web Extension Configuration

### Manifest (`manifest.json`)

```json
{
  "name": "web",
  "version": "1.0.0",
  "description": "Web development support with Astro, Tailwind CSS v4, TypeScript, and Cloudflare Pages",
  "task_type": "web",
  "dependencies": ["core"],
  "provides": {
    "agents": ["web-implementation-agent.md", "web-research-agent.md"],
    "skills": ["skill-web-implementation", "skill-web-research"],
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

Key observations:
- Uses the generic `skill-planner` for planning (no web-specific planner)
- Research routes to `skill-web-research` -> `web-research-agent`
- Implementation routes to `skill-web-implementation` -> `web-implementation-agent`
- No custom commands (unlike `present` which has `/grant`, `/budget`, etc.)
- No custom hooks or scripts

### Routing Flow

```
/task "Add hero section" (task_type auto-detects "web" from keywords)
  -> specs/state.json: task_type = "web"

/research N
  -> manifest routing: skill-web-research -> web-research-agent
  -> Uses: WebSearch, WebFetch, Read, Bash, Astro Docs MCP, Context7 MCP

/plan N
  -> manifest routing: skill-planner (generic)
  -> Reads research report, writes phased plan

/implement N
  -> manifest routing: skill-web-implementation -> web-implementation-agent
  -> Uses: Read, Write, Edit, Bash (pnpm build/check), Astro Docs MCP
```

### Context Files (22 files across 5 categories)

| Category | Files | Coverage |
|----------|-------|----------|
| **domain/** | 5 | Astro framework, Tailwind v4, Cloudflare Pages, TypeScript, web reference |
| **patterns/** | 5 | Components, layouts, content collections, Tailwind UI, accessibility |
| **standards/** | 3 | Style guide, performance (Core Web Vitals), accessibility (WCAG 2.2) |
| **tools/** | 5 | Astro CLI, CI/CD pipeline, Cloudflare deploy, debugging utilities, pnpm |
| **templates/** | 2 | Page boilerplate, component boilerplate |

### Agent Capabilities

**web-research-agent**:
- Local project file analysis (src/, public/)
- Astro Docs MCP integration (real-time official docs)
- Context7 MCP integration (library API references)
- WebSearch/WebFetch fallback
- Decision tree for search strategy (6 categories)
- Produces research report with accessibility and performance sections

**web-implementation-agent**:
- Creates/modifies .astro, .ts, .tsx, .css files
- Build verification: `pnpm build`, `pnpm check`, `npx astro check`
- Follows web-astro.md rules (TypeScript strict, accessibility, performance)
- Islands architecture awareness (zero-JS default)
- Image optimization patterns
- Deployment debugging utilities
- Resumable phase execution

### Rules File (`web-astro.md`)

Applies to `src/**/*.astro`, `src/**/*.ts`, `src/**/*.tsx`. Enforces:
- 2-space indentation, kebab-case files, PascalCase components
- TypeScript strict (no `any`, explicit returns, `interface Props`)
- Tailwind class ordering (box-model order)
- Accessibility: alt text, semantic HTML, heading hierarchy, ARIA, keyboard nav, contrast, touch targets
- Performance: zero JS default, `<Image>` over `<img>`, Core Web Vitals targets
- Client directive usage guidelines

## Existing Documentation Patterns

### Structure Pattern (from `docs/workflows/*.md`)

Every workflow guide follows this template:

```markdown
# {Topic Title}

{1-2 sentence intro explaining what this workflow covers.}

> **Requires the `{extension}` extension.**

## Decision guide

| I want to... | Use |
|---|---|
| {action} | `/command` |

## {First Operation}

```
/command "description"
```

{1-3 paragraphs explaining what happens, what's produced, and what to do next.}

## {Second Operation}
...

## See also
- [Related doc](path)
```

### Tone and Style

- **User-facing narrative**: Written for the person typing commands, not for the AI agent
- **Code blocks as primary examples**: Show the exact command to type
- **Brief explanations**: 1-3 paragraphs per operation, focus on "what happens" and "what to do next"
- **Decision tables**: First section is always a quick lookup table
- **Extension requirements**: Note at top if extension needed
- **Cross-references**: "See also" section with links to related docs
- **No internal implementation details**: Don't mention agents, skills, metadata files, or postflight patterns

### Length Benchmarks

| Doc | Approximate Lines | Sections |
|-----|-------------------|----------|
| agent-lifecycle.md | 152 | 11 (summary, creating, researching, planning, implementing, finishing, flags, revising, unblocking, exceptions, see-also) |
| grant-development.md | ~130 | 8 (decision guide, grants, budgets, timelines, funds, talks, common scenarios, see-also) |
| epidemiology-analysis.md | ~80-100 | ~6 |
| memory-and-learning.md | ~80-100 | ~6 |

Target for web guide: **120-180 lines**, matching the mid-to-large workflow guides.

### README Integration Pattern

The `docs/README.md` groups docs by section and has a "Sections" overview. The `docs/workflows/README.md` lists docs in a table and has a "Decision guide" and "Common scenarios" section. Both would need a new web entry.

The main `README.md` (repo root) already mentions web in its 1-line description of extensions. No additional entry is needed there beyond adding a link from docs/.

## Agent/Skill Architecture

### Skill-to-Agent Mapping (Web)

| Skill | Agent | Model | Purpose |
|-------|-------|-------|---------|
| skill-web-research | web-research-agent | opus | Astro/Tailwind/Cloudflare research |
| skill-web-implementation | web-implementation-agent | opus | Web file creation/modification with build verification |

### MCP Tool Integration

The web agents can use optional MCP tools when configured:

| MCP Server | Tool | Purpose |
|------------|------|---------|
| astro-docs | `search_astro_docs` | Real-time Astro documentation search |
| context7 | `resolve-library-id`, `query-docs` | Library API references (Astro, Tailwind, Cloudflare, TypeScript) |
| playwright | `browser_navigate`, `browser_snapshot`, etc. | Visual verification (deferred) |

### Build Verification Pipeline

```
pnpm check    -> TypeScript + Astro diagnostics
pnpm build    -> Full production build
npx astro check -> Astro-specific detailed diagnostics
pnpm dev      -> Development server (user runs manually)
```

## Gap Analysis

### What's Missing (Critical)

1. **User-facing workflow guide** (`docs/workflows/web-development.md`): No guide exists explaining how to use `/task`, `/research`, `/plan`, `/implement` for web development tasks.

2. **Web entry in `docs/workflows/README.md`**: The workflows index has no web development section. Needs a "Web development" subsection with table entry.

3. **Web entry in `docs/README.md`**: The top-level docs README mentions R, Python, epidemiology, grants, memory, documents -- but not web development.

4. **Example artifacts**: No reference website example showing what an Astro project created through the task system looks like (file structure, data patterns, component patterns).

### What's Missing (Nice-to-Have)

5. **Toolchain doc for web prerequisites** (`docs/toolchain/web.md`): Node.js, pnpm, Astro CLI installation. Currently only Python and R have toolchain guides.

6. **Common scenarios in workflows README**: The "Common scenarios" section in `docs/workflows/README.md` has grant development, code review, PDF review, report creation, and Word document scenarios -- no web development scenario.

7. **Decision guide entry in workflows README**: The "Decision guide" table in `docs/workflows/README.md` has no entries for "Build a website" or "Create a web component".

### What Already Exists (No Duplication Needed)

- The agent-facing context files (22 files) are comprehensive and should NOT be duplicated in the guide
- The `extensions.md` doc already lists the web extension in the feature matrix
- The `agent-lifecycle.md` already explains the `/task`/`/research`/`/plan`/`/implement` workflow generically
- The `README.md` already mentions web in the extensions summary

## Recommended Guide Structure

Based on the existing doc patterns, the web development guide should follow this structure:

```markdown
# Web Development

Build websites with Astro, Tailwind CSS v4, and Cloudflare Pages using the 
agent task lifecycle.

> **Requires the `web` extension.**

## Decision guide (table)

## Prerequisites
- Node.js 22+, pnpm, Astro CLI
- Brief toolchain setup instructions

## Starting a web project
- /task "Build a landing page with hero, features, and contact form"
- What the task system auto-detects (task_type: web)
- Project structure overview

## Designing and researching
- /research N
- What the web research agent investigates
- What the research report contains

## Planning the implementation
- /plan N
- Phased plan structure for web tasks

## Implementing
- /implement N
- Build verification (pnpm build, pnpm check)
- Resumable phases

## Website structure patterns
- Project layout (src/pages/, src/components/, src/data/, src/layouts/)
- Data files pattern (TypeScript arrays with interfaces)
- Component hierarchy (layout -> sections -> ui)
- Tailwind theming (@theme directive)

## Example: Building a feature grid
- Walk through a concrete example extracting a pattern from advantages.ts
- Show the data file, section component, card component, layout integration

## Common scenarios
- Adding a new page
- Creating a reusable component
- Setting up content collections for a blog
- Deploying to Cloudflare Pages

## See also
```

### Files to Create/Modify

1. **Create**: `docs/workflows/web-development.md` (main guide, ~150-180 lines)
2. **Create**: `web/` directory with example artifacts (stripped-down reference project)
3. **Modify**: `docs/workflows/README.md` (add web development section)
4. **Modify**: `docs/README.md` (add web mention)
5. **Modify**: `README.md` (add link to web guide)

### Example Artifacts to Include in `web/`

Based on the Logos Website source structure:
- `web/src/data/advantages.ts` - Data file pattern
- `web/src/components/sections/Advantages.astro` - Section component pattern
- `web/src/components/ui/FeatureCard.astro` - UI card component pattern
- `web/src/layouts/BaseLayout.astro` - Layout pattern
- `web/src/pages/index.astro` - Page pattern
- `web/src/styles/global.css` - Tailwind v4 theme configuration
- `web/astro.config.mjs` - Astro configuration

## Confidence Level

**High** - The gap is clear (no web guide exists), the documentation patterns are consistent and well-established, the web extension is fully implemented with comprehensive context files, and the target structure naturally follows from existing workflow guides. The main research question (what example artifacts to include) is answered by the Logos Website source structure which demonstrates clean Astro/Tailwind patterns.
