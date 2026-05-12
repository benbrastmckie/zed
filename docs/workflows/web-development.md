# Web Development

Build websites with Astro 5, Tailwind CSS v4, and TypeScript using the agent task lifecycle. The `web` extension routes tasks to specialized agents that understand Astro's islands architecture, Tailwind's CSS-first configuration, accessibility standards, and Cloudflare deployment.

> **Requires the `web` extension.** Ensure the extension is loaded before using these commands.

## Decision guide

| I want to... | Use |
|---|---|
| Port an existing website to Astro/Tailwind | [`/port`](port-website.md) |
| Start a new website project | `/task "Build a landing page for my project" --type web` |
| Research a web technology or pattern | `/research N` on a web-typed task |
| Create a phased build plan | `/plan N` on a web-typed task |
| Implement components and pages | `/implement N` on a web-typed task |

## When to use the web extension

Use task type `web` when your work involves building or modifying an Astro site with Tailwind CSS. The extension provides context covering:

- Astro 5 framework patterns (components, layouts, routing, content collections, islands)
- Tailwind CSS v4 configuration (@theme directive, utility classes, dark mode)
- TypeScript strict mode with Astro type utilities
- Accessibility requirements (WCAG 2.2, semantic HTML, ARIA, keyboard navigation)
- Performance targets (Core Web Vitals, zero-JS defaults, image optimization)
- Cloudflare Pages deployment

If your task is a general coding task that happens to touch `.astro` files, the standard `general` task type works fine. Use `web` when you want the agents to have deep framework knowledge for design decisions and code review. To convert an existing website to Astro/Tailwind, use [`/port`](port-website.md) instead.

## Task type routing

| Task Type | Research Skill | Implementation Skill |
|-----------|----------------|---------------------|
| `web` | skill-web-research | skill-web-implementation |

Tasks created with type `web` automatically route to agents loaded with Astro, Tailwind, and accessibility context. The standard `/research`, `/plan`, and `/implement` commands work -- no special commands are needed.

## Starting a website project

```
/task "Build a marketing landing page with hero, features, and contact form"
```

When prompted for task type, choose `web`. The task is created at `[NOT STARTED]` and ready for the research-plan-implement cycle.

### Using the starter template

A `web/` directory at the repository root provides a generalized starter template extracted from a production Astro 5 + Tailwind CSS v4 site. It includes:

- **20 files**: layouts, components, pages, data layer, and CSS
- **4-layer data pattern**: TypeScript interface, data array, section component, page composition
- **4-layer CSS architecture**: Tailwind import, @theme tokens, semantic variables, component classes
- **Accessible components**: semantic HTML, ARIA labels, keyboard navigation, reduced-motion support

Copy the `web/` directory to start a new project, or reference it as a pattern library when the agent builds components. See [web/README.md](../../web/README.md) for the full template documentation.

## Example workflow

```
/task "Build a project showcase site with homepage and feature highlights"
  # -> creates task #15 with type web at [NOT STARTED]

/research 15
  # -> web-research-agent investigates Astro patterns, component architecture
  # -> produces report at specs/015_project_showcase/reports/01_web-research.md

/plan 15
  # -> planner-agent creates phased build plan (layout, pages, components, styling)
  # -> produces plan at specs/015_project_showcase/plans/01_build-plan.md

/implement 15
  # -> web-implementation-agent builds the site phase by phase
  # -> commits after each phase, produces summary when complete
```

## Iterating on design

After the initial implementation, you can refine the site through additional rounds:

```
/research 15 "Investigate accessible contact form patterns with validation"
  # -> produces a focused research report on form patterns

/revise 15
  # -> creates a new plan version incorporating the research findings

/implement 15
  # -> resumes from the first incomplete phase of the revised plan
```

You can also use `/review` to get a code quality assessment of the implemented site, or `/fix-it src/` to scan for inline TODO/FIX tags and create follow-up tasks.

## Build and deploy

The starter template is configured for Cloudflare Pages with static output. After implementation:

```bash
pnpm install        # Install dependencies
pnpm dev            # Development server with hot reload
pnpm check          # TypeScript + Astro diagnostics
pnpm build          # Production build
pnpm preview        # Preview the production build locally
```

Use `/tag` to create semantic version tags for deployment when ready to ship.

## Web development capabilities

The web agents have access to context covering:

- **Astro framework** -- .astro file format, islands architecture, client directives, routing, content collections, SSG/SSR modes, image optimization
- **Tailwind CSS v4** -- @theme directive, CSS-first configuration, utility class ordering, dark mode, container queries, responsive design
- **Component patterns** -- props with `interface Props`, scoped styles, `class:list`, slot composition, `define:vars`
- **Accessibility** -- WCAG 2.2 compliance, semantic HTML, ARIA labels, keyboard navigation, color contrast, focus visibility, reduced motion
- **Performance** -- Core Web Vitals targets, zero-JS defaults, image optimization with `<Image>`, font loading, preloading
- **TypeScript** -- strict mode, explicit return types, `unknown` over `any`, Astro type utilities
- **Coding standards** -- file naming (kebab-case), import ordering, Tailwind class ordering, comment conventions

## See also

- [agent-lifecycle.md](agent-lifecycle.md) -- The core task lifecycle that web tasks follow
- [`../agent-system/commands.md`](../agent-system/commands.md) -- Full command reference with flags
- [port-website.md](port-website.md) -- Port existing websites to Astro/Tailwind with `/port`
- [web/README.md](../../web/README.md) -- Starter template structure and customization guide
- [maintenance-and-meta.md](maintenance-and-meta.md) -- Code review, error tracking, and shipping changes
