# Research Report: Task #84

**Task**: Create web development guide with example artifacts
**Date**: 2026-05-11
**Mode**: Team Research (4 teammates)

## Summary

The Logos Website at `~/Projects/Logos/Website/` is a mature Astro 5 + Tailwind CSS v4 + TypeScript + Cloudflare Pages project with a clean, extractable 4-layer architecture: typed data files -> section components -> UI components -> page composition. The `web` extension is fully functional (2 agents, 2 skills, 22 context files, 1 rule) but has zero user-facing documentation despite being as comprehensive as the epidemiology and present extensions which both have workflow guides. The guide belongs at `docs/workflows/web-development.md` following the exact structure of existing workflow docs (decision table, per-command walkthrough, examples, see-also). A `web/` starter directory at repo root should contain generalized (not Logos-specific) skeleton files demonstrating the core patterns. The README.md needs a link in its Common Scenarios table.

## Key Findings

### 1. The Extractable "Basic Form" (4-Layer Data-Driven Architecture)

The website's core reusable pattern is:

```
TypeScript interface → typed data array → section component (maps over data) → page (composes sections)
```

Seven data files demonstrate a spectrum of complexity:

| Data File | Interface | Complexity | Pattern |
|-----------|-----------|------------|---------|
| `site-config.ts` | `SiteConfig` | Global singleton | Nav items, metadata, external links |
| `advantages.ts` | `Advantage` | Minimal (title+desc) | Grid of `FeatureCard` components |
| `applications.ts` | `ApplicationDomain` | Simple + icon | Grid with visual differentiation |
| `layers.ts` | `Layer` | Nested arrays + booleans | Expandable `<details>` cards |
| `packages.ts` | `Package` | Union status + links | Status badges, conditional rendering |
| `publications.ts` | `Publication` | Optional fields + multi-export | Multiple lifecycle stages |
| `use-cases.ts` | `UseCase` | Long-form text | Accordion expand/collapse |

The simplest pattern (`advantages.ts`) is the canonical example: define a `{title, description}` interface, export a typed array, map it in a section component through `FeatureCard`, and compose the section on a page.

### 2. Component Architecture (3-Layer Hierarchy)

```
BaseLayout.astro          -- HTML shell: <head>, SEO, fonts, JSON-LD, named slots
  └── PageLayout.astro    -- Header + <main id="main-content"> + Footer (via named slots)
        └── [page].astro  -- Composed from section components
```

**Layout components** (3): Header (sticky nav, CSS-only mobile menu), Footer (3-column), NavLink (active-aware)

**Section components** (13): Full-width content blocks, each importing Container + SectionHeading + data, with alternating backgrounds for visual rhythm

**UI components** (13): Reusable primitives — Container (max-width wrapper), Button (polymorphic a/button), SectionHeading (title + decorative lines), FeatureCard (glass/solid), GlassCard, StatusBadge, ScrollReveal (IntersectionObserver), plus domain-specific cards

**Key patterns**:
- Every component defines `interface Props` and destructures from `Astro.props`
- `class` prop renamed to `className` (reserved word)
- `Container` uses polymorphic `as` prop for element type
- `Button` extends `HTMLAttributes<"button">` for rest props
- Zero client-side JavaScript by default (islands architecture)

### 3. CSS Architecture (4-Layer Styling System)

```css
@import "tailwindcss";          /* 1. Framework */
@theme { }                       /* 2. Design tokens (oklch colors, fonts, radii) */
:root { } / .dark { }           /* 3. Semantic variables (--surface-page, --text-heading) */
@layer components { }            /* 4. Component classes (.btn, .card, .card-glass) */
```

The semantic indirection layer (`--color-brand-400` -> `--accent-primary` -> used in components) means you can change the entire color scheme by editing `:root`/`.dark` without touching components. Dark mode is enforced via `class="dark"` on `<html>` with `@custom-variant dark`.

Glassmorphism is the signature visual style: `bg-white/[0.03] backdrop-blur-sm border border-white/10`.

### 4. Web Extension Architecture (Fully Built, Zero User Docs)

| Component | Count | Details |
|-----------|-------|---------|
| Agents | 2 | web-research-agent (WebSearch, WebFetch, Astro Docs MCP), web-implementation-agent (Read, Write, Edit, Bash with pnpm build/check) |
| Skills | 2 | skill-web-research, skill-web-implementation |
| Context files | 22 | 5 domain, 5 patterns, 3 standards, 5 tools, 2 templates, 2 other |
| Rules | 1 | web-astro.md (TypeScript strict, accessibility, performance, Tailwind ordering) |
| Custom commands | 0 | Uses generic /task, /research, /plan, /implement |

**Routing flow**:
```
/task "Build landing page" → auto-detects task_type: "web"
/research N → skill-web-research → web-research-agent
/plan N     → skill-planner (generic)
/implement N → skill-web-implementation → web-implementation-agent
```

### 5. Accessibility and Performance Patterns

Baked into every component:
- `prefers-reduced-motion` media query in CSS and ScrollReveal JS
- `aria-label`, `aria-current="page"`, `aria-expanded`, `aria-controls`
- CSS-only mobile menu (zero JavaScript for hamburger toggle)
- Semantic HTML throughout (`<header>`, `<main>`, `<nav>`, `<footer>`, `<section>`)
- `<Image>` from `astro:assets` (never raw `<img>`)
- JSON-LD structured data in BaseLayout

### 6. Configuration Essentials

- `astro.config.mjs`: `output: "static"`, `adapter: cloudflare()`, `tailwindcss` as Vite plugin, `sitemap` integration
- `tsconfig.json`: extends `astro/tsconfigs/strict`, path aliases (`@components/*`, `@layouts/*`, `@data/*`, `@assets/*`, `@styles/*`)
- `package.json`: Astro 5.7, Tailwind 4.1, TypeScript 5.8, pnpm 10.28
- Build: `pnpm dev`, `pnpm build`, `pnpm check`, `pnpm preview`

**Critical**: Path aliases are load-bearing — every import uses them. Copying files without `tsconfig.json` produces broken code.

## Synthesis

### Conflicts Resolved

1. **Artifact placement** (B: `docs/web/`, C: `examples/web-starter/`, D: `web/` at root):
   - **Resolution**: Use `web/` at repo root as the task description specifies. This is a minimal starter template, not just documentation. The `examples/` convention is for extension-specific runnable outputs (epi-study, epi-slides), while `web/` is a project skeleton.

2. **Guide depth** (B: 120-180 lines matching mid-large workflow guides, C: risk of becoming Astro tutorial):
   - **Resolution**: Target ~150 lines. Stay focused on the agent workflow (how to use `/task` → `/research` → `/plan` → `/implement` for web tasks), not Astro framework internals. Reference the 22 extension context files for deep framework knowledge.

3. **What to extract from the website** (A: everything, C: MUST/SHOULD/MUST-NOT tiers):
   - **Resolution**: Follow C's tiered approach. Copy ~15 structural/generic files to `web/`, generalize all Logos-specific content to placeholders. The canonical example is `advantages.ts` → generalized as `features.ts`.

### Gaps Identified

1. **No toolchain doc**: Python and R have `docs/toolchain/` guides for prerequisites. Web has none for Node.js/pnpm/Astro CLI. Low priority — can be a separate task.
2. **Content collections not covered**: The Logos site uses data files in `src/data/`, not Astro content collections. The guide should note content collections as an alternative for blog/docs sites.
3. **Deployment workflow**: The `/tag` command handles versioning. The guide should mention `pnpm build` → `pnpm preview` → deploy cycle but can defer detailed Cloudflare deployment.

### Recommendations

1. **Create `docs/workflows/web-development.md`** (~150 lines) following the decision-table + per-command walkthrough pattern of existing workflow guides
2. **Create `web/` directory** at repo root with ~15 generalized skeleton files demonstrating the 4-layer data-driven architecture
3. **Update `docs/workflows/README.md`** with web development section
4. **Update `docs/README.md`** with web development entry
5. **Update `README.md`** with link in Common Scenarios table
6. **Include `web/README.md`** explaining the starter template and how to use it

### Artifact File List for `web/`

**MUST include (generalized)**:
- `astro.config.mjs` — Astro + Tailwind + Cloudflare setup
- `tsconfig.json` — Strict TypeScript + path aliases
- `package.json` — Minimal dependencies
- `src/styles/global.css` — 4-layer CSS architecture with placeholder brand colors
- `src/data/site-config.ts` — Generalized site configuration
- `src/data/features.ts` — Generalized from advantages.ts (the canonical data pattern)
- `src/layouts/BaseLayout.astro` — HTML shell with SEO, fonts, slots
- `src/layouts/PageLayout.astro` — Header + main + Footer wrapper
- `src/components/layout/Header.astro` — Generalized sticky nav
- `src/components/layout/Footer.astro` — Generalized 3-column footer
- `src/components/sections/Features.astro` — Data-driven section (maps FeatureCard)
- `src/components/sections/Hero.astro` — Hero section pattern
- `src/components/ui/Container.astro` — Max-width wrapper (already generic)
- `src/components/ui/Button.astro` — Polymorphic button (already generic)
- `src/components/ui/SectionHeading.astro` — Section heading (already generic)
- `src/components/ui/FeatureCard.astro` — Card component (already generic)
- `src/pages/index.astro` — Generalized homepage composition

**SHOULD include**:
- `src/components/layout/NavLink.astro` — Active-aware navigation
- `src/components/ui/ScrollReveal.astro` — Progressive enhancement
- `src/pages/404.astro` — Standard error page

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary — website structure, data, components, styling, config | completed | high |
| B | Alternative — web extension config, existing docs, gap analysis | completed | high |
| C | Critic — gaps, blind spots, artifact selection, risk | completed | high |
| D | Horizons — strategic direction, documentation integration | completed | high |

## References

- Logos Website: `/home/benjamin/Projects/Logos/Website/src/`
- Web extension: `.claude/extensions/web/`
- Web context files: `.claude/context/project/web/` (22 files)
- Existing workflow guides: `docs/workflows/` (agent-lifecycle, epidemiology, grants, memory, office-documents)
- README.md: repo root
