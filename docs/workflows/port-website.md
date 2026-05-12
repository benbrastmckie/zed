# Port a Website

Convert an existing website to Astro 5 and Tailwind CSS v4. The `/port` command scopes a porting project through structured forcing questions, then the standard task lifecycle drives it to completion.

> **Requires the `web` extension.** Ensure the extension is loaded before using these commands.

## Decision guide

| I want to... | Use |
|---|---|
| Port a live website by URL | `/port https://example.com` |
| Port a local site from disk | `/port /path/to/site/` |
| Describe a porting project | `/port "Port the company marketing site to Astro"` |
| Resume an existing port task | `/port N` |

## When to use /port

Use `/port` when you have an existing website and want to recreate it in Astro with Tailwind CSS v4. The command handles source site analysis, content inventory, design token extraction, and Astro component mapping.

For building a new site from scratch, use `/task "description" --type web` instead. See [web-development.md](web-development.md) for the general web development workflow.

## Starting a port

```
/port https://example.com
```

The command asks 6 forcing questions covering:

1. **Source site** -- URL or local file path (skipped if provided as input)
2. **Content scope** -- ALL, SELECTED, STRUCTURE_ONLY, or LANDING
3. **Design approach** -- FAITHFUL, INSPIRED, REBRAND, or MINIMAL
4. **Target pages** -- desired page structure or "auto" to mirror source
5. **Features** -- dark mode, contact form, blog, gallery, nav style, or "none"
6. **Additional context** -- brand guidelines, audience, hosting, SEO, accessibility

After answering, the task is created at `[NOT STARTED]` with all forcing data stored in task metadata.

## Input types

| Input | Behavior |
|---|---|
| URL | Fetch and analyze the live site, ask 5 remaining questions, create task |
| Local path | Read local files, ask 5 remaining questions, create task |
| Description string | Ask all 6 questions, create task |
| Task number | Resume an existing port task (delegates to research) |

## Example workflow

```
/port https://oldsite.example.com
  # -> answers 6 forcing questions, creates task #22 at [NOT STARTED]

/research 22
  # -> port-agent analyzes site structure, design, content, and technology
  # -> produces report at specs/022_port_oldsite/reports/01_site-analysis.md

/plan 22
  # -> planner-agent creates phased migration plan (layout, pages, components, styling)
  # -> produces plan at specs/022_port_oldsite/plans/01_migration-plan.md

/implement 22
  # -> web-implementation-agent builds the Astro/Tailwind site phase by phase
  # -> produces summary at specs/022_port_oldsite/summaries/01_execution-summary.md
```

## Design approach options

| Approach | Description |
|---|---|
| FAITHFUL | Match the source design closely -- same colors, layout, typography |
| INSPIRED | Use the source as inspiration but modernize with Tailwind defaults |
| REBRAND | Keep the structure but apply a completely new visual identity |
| MINIMAL | Strip to content with clean, minimal styling |

The research agent extracts design tokens (colors mapped to oklch, typography, spacing) and proposes a Tailwind `@theme` block regardless of approach. The design approach controls how closely the new site mirrors the original.

## Limitations

- **JavaScript-rendered sites (SPAs)**: Sites that require JavaScript to render content may appear empty when fetched. For React/Vue/Angular SPAs, provide a local build output directory instead of a URL.
- **Large sites**: Sites with 100+ pages are sampled rather than fully analyzed. Specify target pages explicitly for best results.
- **External CSS**: Stylesheets loaded from third-party CDNs may not always be accessible for design extraction.

## See also

- [agent-lifecycle.md](agent-lifecycle.md) -- The core task lifecycle that port tasks follow
- [`../agent-system/commands.md`](../agent-system/commands.md) -- Full command reference with flags
- [web-development.md](web-development.md) -- Build new websites from scratch with Astro/Tailwind
- [memory-and-learning.md](memory-and-learning.md) -- Save porting discoveries for future projects
