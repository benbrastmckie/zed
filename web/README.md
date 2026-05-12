# Web Starter Template

A generalized Astro 5 + Tailwind CSS v4 starter template extracted from a production website. Use this as a starting point for new web projects or as a reference for component patterns when building with the web extension.

This is a reference skeleton. Run `pnpm install` to make it a runnable project.

## Directory structure

```
web/
├── astro.config.mjs                    # Astro + Tailwind + Cloudflare config
├── tsconfig.json                       # Strict TypeScript with path aliases
├── package.json                        # Astro 5 + Tailwind 4 dependencies
├── README.md                           # This file
└── src/
    ├── styles/
    │   └── global.css                  # 4-layer CSS architecture
    ├── data/
    │   ├── site-config.ts              # Site name, nav items, metadata
    │   └── features.ts                 # Feature data (interface + array)
    ├── layouts/
    │   ├── BaseLayout.astro            # HTML shell with SEO, fonts, slots
    │   └── PageLayout.astro            # Header + main + Footer wrapper
    ├── components/
    │   ├── layout/
    │   │   ├── Header.astro            # Sticky header with CSS-only mobile menu
    │   │   ├── Footer.astro            # 3-column footer with nav + social
    │   │   └── NavLink.astro           # Active-aware nav link with underline
    │   ├── sections/
    │   │   ├── Hero.astro              # Full-viewport hero with gradient orbs
    │   │   └── Features.astro          # Data-driven feature grid
    │   └── ui/
    │       ├── Button.astro            # Polymorphic button/link component
    │       ├── Container.astro         # Max-width content wrapper
    │       ├── SectionHeading.astro    # Heading with decorative lines
    │       ├── FeatureCard.astro       # Card with glass variant
    │       └── ScrollReveal.astro      # Intersection Observer scroll animation
    └── pages/
        ├── index.astro                 # Homepage: Hero + Features
        └── 404.astro                   # Not-found page
```

## The 4-layer data pattern

The template demonstrates a data-driven architecture for building page sections. The canonical example is the features section:

**Layer 1 -- Interface** (`src/data/features.ts`):
Define a TypeScript interface for your data shape.
```typescript
export interface Feature {
  title: string;
  description: string;
}
```

**Layer 2 -- Data array** (`src/data/features.ts`):
Export an array of data conforming to the interface.
```typescript
export const features: Feature[] = [
  { title: "Fast by Default", description: "..." },
  // ...
];
```

**Layer 3 -- Section component** (`src/components/sections/Features.astro`):
Import the data and map it to UI components.
```astro
---
import { features } from "@data/features";
---
{features.map((feature) => <FeatureCard title={feature.title} ... />)}
```

**Layer 4 -- Page composition** (`src/pages/index.astro`):
Compose sections into a page with a layout.
```astro
<PageLayout title={siteConfig.title}>
  <Hero />
  <Features />
</PageLayout>
```

To add a new data-driven section (e.g., testimonials, pricing tiers), repeat these four layers: define the interface, export the data, create a section component, and add it to a page.

## CSS architecture

The global stylesheet (`src/styles/global.css`) follows a 4-layer pattern:

1. **Tailwind import** -- `@import "tailwindcss"` loads the framework
2. **@theme tokens** -- brand colors, fonts, radii, and spacing defined as CSS custom properties; Tailwind auto-generates utility classes from these
3. **Semantic variables** -- `:root` and `.dark` blocks map tokens to roles (surface, text, accent, border, focus)
4. **Component classes** -- `@layer components` defines reusable `.btn`, `.card`, `.card-glass`, and `.link-animated` classes

To change your brand identity, edit the `--color-brand-*` values in `@theme`. Every component that uses semantic variables will update automatically.

## Customization guide

### Change brand colors

Edit `src/styles/global.css` and replace the `--color-brand-*` values in the `@theme` block. The semantic layer maps these to surface, text, and accent roles.

### Add navigation items

Edit `src/data/site-config.ts` and add entries to the `navItems` array. The Header and Footer render these automatically.

### Add a new data-driven section

1. Create an interface and data array in `src/data/` (follow `features.ts` as a model)
2. Create a section component in `src/components/sections/` that imports the data
3. Add the section to a page in `src/pages/`

### Switch to light mode

Remove `class="dark"` from the `<html>` element in `src/layouts/BaseLayout.astro`.

## Path aliases

The `tsconfig.json` defines path aliases for clean imports:

| Alias | Maps to |
|-------|---------|
| `@components/*` | `src/components/*` |
| `@layouts/*` | `src/layouts/*` |
| `@data/*` | `src/data/*` |
| `@assets/*` | `src/assets/*` |
| `@styles/*` | `src/styles/*` |

Use these in imports: `import Button from "@components/ui/Button.astro"`.

## Build commands

```bash
pnpm install    # Install dependencies (required before first run)
pnpm dev        # Start development server with hot reload
pnpm build      # Build for production (static output)
pnpm preview    # Preview the production build locally
pnpm check      # Run TypeScript and Astro diagnostics
pnpm format     # Format all files with Prettier
```

## See also

- [docs/workflows/web-development.md](../docs/workflows/web-development.md) -- Workflow guide for using the web extension
- [.claude/context/project/web/](../.claude/context/project/web/) -- Web extension context files (Astro, Tailwind, accessibility, performance)
