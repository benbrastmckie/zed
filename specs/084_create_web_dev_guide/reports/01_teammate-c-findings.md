# Teammate C (Critic) Findings: Task 84

**Task**: Create web development guide with example artifacts
**Date**: 2026-05-11
**Role**: Critic -- gaps, blind spots, and unvalidated assumptions

## Key Findings (Critical Gaps and Blind Spots)

### 1. The website has domain-specific complexity that must be stripped for a general guide

The Logos Website is not a generic Astro/Tailwind site. It includes:

- **Middleware-based password protection** (`middleware.ts`) using SHA-256 cookie auth with Cloudflare Workers runtime (`locals.runtime.env`). The `export const prerender = false` on protected pages forces SSR. A general guide must explain when to use SSR vs static output, not just show the pattern.
- **Cloudflare Pages adapter** with `wrangler.jsonc` configuration. The `output: "static"` in `astro.config.mjs` plus `adapter: cloudflare()` is a hybrid setup. The guide must clarify that the adapter is needed even for mostly-static sites when any page uses SSR.
- **TypeScript path aliases** (`@components/*`, `@layouts/*`, `@data/*`, etc.) in `tsconfig.json`. These are load-bearing -- every import in the codebase uses them. Copying files without documenting this will produce broken code.
- **CSS custom properties semantic layer** in `global.css` mapping `@theme` tokens to semantic variables (`--surface-page`, `--text-heading`, `--accent-primary`). This is an important architectural pattern, not just color config.

### 2. The "data-driven sections" pattern is the website's most reusable architecture

The guide should center on the **data file -> section component -> page** pattern rather than just showing `advantages.ts`:

| Data File | Type Interface | Section Component | Rendering Pattern |
|-----------|---------------|-------------------|-------------------|
| `advantages.ts` | `Advantage` | `Advantages.astro` | Grid of `FeatureCard` |
| `applications.ts` | `ApplicationDomain` | `ApplicationsPreview.astro` | Grid with expand |
| `layers.ts` | `Layer` | `LayerArchitecture.astro` | Stacked cards |
| `packages.ts` | `Package` | `ThreePackages.astro` | Status-aware cards |
| `use-cases.ts` | `UseCase` | (merged into applications) | Accordion detail |
| `site-config.ts` | `SiteConfig` | Header/Footer/BaseLayout | Shared config |
| `publications.ts` | (not examined) | Research page | List/card |

This pattern is the extractable form. The guide should explain: "Define your data as typed arrays, create a section component that maps over them, compose pages from sections."

### 3. The three-tier layout architecture is under-documented as a reusable pattern

The site has a clear three-tier layout hierarchy that should be explicitly documented:

```
BaseLayout.astro     -- HTML shell, <head>, fonts, SEO, JSON-LD
  └── PageLayout.astro   -- Header + <main> + Footer (named slots)
        └── [page].astro       -- Composed from section components
```

Key subtlety: `BaseLayout` uses named slots (`slot="header"`, `slot="footer"`) to place Header/Footer. This is a non-obvious Astro pattern that should be called out.

### 4. The "web/" directory placement is ambiguous

The task says "copy essential artifacts to a web/ directory" but doesn't specify where. Options:

- `docs/web/` -- alongside other workflow docs
- `web/` at repository root -- a standalone example project
- `examples/web/` -- matching existing `examples/epi-study/` and `examples/epi-slides/`

**The `examples/` convention already exists** (see README.md lines 86-91). Placing the web example at `examples/web/` would be consistent. But the task also says "docs/" which implies `docs/workflows/web-development.md` for the guide text.

**Recommendation**: The guide document goes in `docs/workflows/web-development.md`. The example artifacts (skeleton files) go in `examples/web/`. This mirrors the epi pattern exactly.

## Scope Assessment (Is the Task Scope Complete?)

### Missing from scope:

1. **No mention of the web extension's actual tooling**. The web extension provides `skill-web-research` and `skill-web-implementation` agents with specific tool access (WebSearch, WebFetch for research; Bash with `pnpm build/check` for implementation). The guide should explain what these agents actually do during `/research` and `/implement` when `task_type: web`.

2. **No deployment instructions**. The Logos site deploys via GitLab CI/CD (`.gitlab-ci.yml` exists) and uses `wrangler` for Cloudflare Pages. The guide should cover the deployment loop: develop -> `pnpm build` -> `pnpm preview` -> deploy. The `/tag` command exists for versioning deployments.

3. **No mention of dark mode**. The site enforces dark mode via `class="dark"` on `<html>` with a `@custom-variant dark` override in CSS. The semantic color layer switches between light/dark palettes. This is a significant design decision that should be documented.

4. **Content collections are absent from this website**. The Logos site uses data files in `src/data/` instead of Astro content collections. But `content.config.ts` and `src/content/` are the standard Astro pattern for blog/docs sites. The guide should note both approaches.

### Included but needs clarification:

5. **"Extract a basic form for a website"** is vague. The extractable form from `advantages.ts` is really: typed data interface + data array + component that maps over it + page that composes components. This 4-layer pattern is the form.

## Missing Patterns (What Other Researchers Likely Missed)

### A. The CSS architecture is more than just Tailwind config

The `global.css` has four layers:
1. `@import "tailwindcss"` -- framework
2. `@theme { }` -- design tokens (colors, fonts, radii, spacing)
3. `:root` / `.dark` -- semantic CSS variables mapping tokens to purposes
4. `@layer components { }` -- reusable component classes (`.btn`, `.card`, `.card-glass`, `.link-animated`)

This semantic indirection (`--color-brand-400` -> `--accent-primary` -> used in components) is the key architectural insight. It means you can change the entire color scheme by editing the `:root`/`.dark` sections without touching any components.

### B. Accessibility patterns are baked into every component

- `ScrollReveal.astro` checks `prefers-reduced-motion` and shows content immediately
- `global.css` has a comprehensive `prefers-reduced-motion` media query that disables all animations
- `NavLink.astro` uses `aria-current="page"` for active navigation
- `Header.astro` has `aria-label` on the menu toggle and mobile menu
- `Button.astro` extends `HTMLAttributes<"button">` from `astro/types`
- Contact form has honeypot spam protection and `aria-live="polite"` status region
- Focus ring styling uses CSS custom properties (`--focus-ring`)

### C. The mobile-first responsive pattern

The site uses CSS-only mobile menu (no JavaScript) via `<details>` element in Header, plus responsive grid breakpoints (1-col -> 2-col -> 3-col) in section components. This is a notable zero-JS mobile navigation pattern.

### D. JSON-LD structured data

The `index.astro` page includes Organization schema.org JSON-LD. `BaseLayout` has a `jsonLd` prop slot. This is important for SEO and should be mentioned in the guide.

## Audience Considerations (Who Is This Guide For?)

The README targets users who:
- Are using Zed editor on macOS
- May not be web developers (they're academics, researchers, epidemiologists)
- Want to build a website using the existing agent system (`/task`, `/research`, `/plan`, `/implement`)
- Need concrete instructions, not abstract web dev theory

**Gap**: The guide should assume the reader has never used Astro, Tailwind, or TypeScript. It should explain:
1. What these tools are and why they're chosen (one sentence each)
2. How to create a new project (`pnpm create astro@latest`)
3. How the web extension routes tasks to specialized agents
4. A worked example: "Build a landing page with hero, features, and contact sections"

**Risk**: Over-documenting framework internals makes the guide a tutorial on Astro rather than a guide on using the agent system for web development. The guide should stay focused on the agent workflow.

## Artifact Selection Criteria (What to Copy, What to Generalize)

### MUST copy (structural patterns):
- `astro.config.mjs` -- generalized (remove sitemap, possibly cloudflare adapter)
- `tsconfig.json` -- verbatim (path aliases are essential)
- `package.json` -- generalized (remove domain-specific deps like `resend`, `@fontsource/crimson-pro`)
- `.prettierrc` -- verbatim
- `.gitignore` -- verbatim

### MUST copy (architectural patterns, generalized):
- `src/layouts/BaseLayout.astro` -- strip Logos-specific content, keep structure
- `src/layouts/PageLayout.astro` -- keep as-is (it's already generic)
- `src/components/layout/Header.astro` -- generalize nav items
- `src/components/layout/Footer.astro` -- generalize content
- `src/data/site-config.ts` -- generalize values
- `src/styles/global.css` -- keep architecture, change brand colors
- `src/components/ui/Container.astro` -- verbatim (fully generic)
- `src/components/ui/Button.astro` -- verbatim (fully generic)
- `src/components/ui/SectionHeading.astro` -- verbatim (fully generic)

### MUST copy (data-driven pattern example):
- `src/data/advantages.ts` -- rename to generic "features.ts"
- `src/components/sections/Advantages.astro` -- rename to "Features.astro"
- `src/components/ui/FeatureCard.astro` -- verbatim
- `src/pages/index.astro` -- generalized homepage

### SHOULD copy (useful but optional):
- `src/components/ui/ScrollReveal.astro` -- nice progressive enhancement
- `src/components/layout/NavLink.astro` -- active-link pattern
- `src/pages/404.astro` -- standard error page

### MUST NOT copy (domain-specific):
- `middleware.ts` -- password auth is domain-specific
- `src/pages/login.astro` -- domain-specific
- `src/pages/api/` -- API routes are domain-specific
- `src/data/layers.ts`, `packages.ts`, `applications.ts`, `use-cases.ts` -- Logos-specific content
- `wrangler.jsonc` -- only needed for Cloudflare deployment
- `.dev.vars` -- contains secrets
- `.gitlab-ci.yml` -- CI is deployment-specific
- `migrations/` -- database-specific

## Risk Assessment (What Could Go Wrong)

1. **Copied files break without path aliases**: If someone copies the files but not the `tsconfig.json` with path aliases, every `@components/*` import fails silently. This must be prominently called out.

2. **Guide becomes stale as Astro evolves**: Astro 5 is current, Astro 6 is in beta. The guide should target Astro 5 APIs and note v6 is compatible.

3. **Tailwind v4 is new and different**: The CSS-first `@theme` directive replaced the JavaScript config. Users familiar with Tailwind v3 will be confused. The guide should note this explicitly.

4. **Guide may duplicate web extension context files**: The `.claude/context/project/web/` directory already contains `astro-framework.md`, `tailwind-v4.md`, and `web-style-guide.md`. The guide should reference these, not duplicate them.

5. **The examples/ directory expectation**: If we put artifacts in `examples/web/` but the guide says `web/`, there's a disconnect. The plan must be explicit about paths.

6. **README.md link placement**: The README has a "Documentation" table, a "Common Scenarios" table, and a "Workflows" link. A web development workflow link fits naturally in the "Common Scenarios" table and possibly in the "Documentation" table under Workflows.

## Confidence Level

**High** -- The analysis is based on thorough reading of every page, layout, component, data file, config file, and middleware in the website. The architectural patterns are clear and extractable. The main risk is scope ambiguity (where to put files, how much to generalize), not missing information.
