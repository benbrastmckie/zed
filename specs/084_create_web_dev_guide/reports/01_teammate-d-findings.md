# Teammate D: Horizons — Strategic Direction for Web Development Guide

**Task**: 84 — Create web development guide with example artifacts
**Date**: 2026-05-11
**Angle**: Long-term alignment, documentation ecosystem fit, reusability

## Key Findings (Strategic Insights)

1. **Missing workflow gap**: The docs/workflows/ directory covers epidemiology, grants, memory, Office documents, and the generic agent lifecycle — but there is no web development workflow guide. This is a notable gap given that the `web` extension is one of the 10 shared extensions and the Logos Website itself was built using the exact same stack (Astro 5 + Tailwind v4 + TypeScript + Cloudflare Pages).

2. **Proven pattern exists**: The Logos Website at `/home/benjamin/Projects/Logos/Website/` demonstrates a concrete, working implementation of the stack. Its data-driven architecture (TypeScript data files -> Astro section components -> UI components) is a clean, extractable pattern that can serve as a reusable template.

3. **Data file architecture is the "basic form"**: The website's data layer (`src/data/`) provides the clearest extractable pattern:
   - `site-config.ts` — Site-wide config (title, description, nav items)
   - `advantages.ts` — Feature/benefit cards (title + description)
   - `applications.ts` — Domain cards (title + description + icon)
   - `layers.ts` — Complex structured data (nested objects, arrays)
   - `packages.ts` — Status-aware items (with links, status badges)
   - `publications.ts` — Academic/content items (with optional fields)
   - `use-cases.ts` — Long-form content items (multiple text fields)

   These represent a spectrum from simple (title/description pairs) to complex (nested objects with optional fields and discriminated unions). A generalized version of these files becomes the template users populate for their own website.

4. **Composition pattern**: Pages compose sections from data: `index.astro` imports `Hero`, `ProblemStatement`, `SolutionOverview`, `Advantages`, `Explore` — each section imports from `src/data/`. This separation of content from presentation is the key architectural insight to convey.

## Project Alignment

The guide fits the project's dual identity:
- **For the Zed config repo**: It fills a documented workflow gap alongside epidemiology, grants, etc.
- **For users**: It shows how the `web` extension + task system work together to build a website from scratch.
- **For the README documentation table**: The "Common Scenarios" and "Decision guide" sections currently have no web development entry.

The README's documentation table currently lists: General, Toolchain, Agent System, AI Agent Systems, Workflows, Claude Code Config, OpenCode Config, Memory Vault. A web development guide fits in `docs/workflows/` following the same pattern as `epidemiology-analysis.md` and `grant-development.md`.

## Long-term Considerations

### Reusability over specificity
The guide should extract the **generic pattern**, not the Logos-specific content. Instead of showing "Logos Laboratories" in examples, the guide should show placeholder values like `"Your Company"` or `"Project Name"`. The data files should be generalized templates that users can fill in.

### Template directory: `web/` vs `docs/web/`
The task description says "copy essential artifacts to a web/ directory." This should be a `web/` directory at the repo root (parallel to `examples/epi-study/` and `examples/epi-slides/`), not inside docs. However, looking at the existing pattern:
- `examples/epi-study/` — runnable example output
- `examples/epi-slides/` — runnable example output

A `web/` directory at root would break this pattern. Better options:
1. **`examples/web-starter/`** — follows the `examples/` convention, contains a minimal starter template
2. **`docs/web/`** — contains just the guide and reference files (not a runnable project)

Recommendation: Use `web/` at root as the task specifies, containing a minimal starter template with generalized data files and the essential structural files. This is more useful than just documentation — users get something they can copy and build on.

### What to include in `web/`
Essential artifacts to copy (generalized):
- `src/data/site-config.ts` — generalized with placeholder values
- `src/data/advantages.ts` → generalized as `src/data/features.ts`
- `src/layouts/BaseLayout.astro` — the core HTML shell
- `src/layouts/PageLayout.astro` — the header/main/footer wrapper
- `src/pages/index.astro` — the homepage composition pattern
- `src/styles/global.css` — the Tailwind v4 theme configuration
- `astro.config.mjs` — the Astro + Tailwind + Cloudflare setup
- `package.json` — dependencies
- A few essential UI components (Container, Button, SectionHeading, FeatureCard)

### Task system integration
The guide's primary value is showing how to use the task system (`/task` → `/research` → `/plan` → `/implement`) for web development. This is what differentiates it from a generic Astro tutorial. The walkthrough should show:
1. `/task "Build a landing page for [project]"` — creates the task
2. `/research N` — the web-research-agent investigates Astro patterns, Tailwind v4, and content structure
3. `/plan N` — the planner creates a phased plan (data layer → layouts → components → pages → styling → deployment)
4. `/implement N` — the web-implementation-agent builds it phase by phase

## Guide Architecture (Recommended)

Follow the exact structure of `epidemiology-analysis.md` and `grant-development.md`:

```markdown
# Web Development

Build websites with Astro, Tailwind CSS v4, and TypeScript using the AI agent task lifecycle.

> **Requires the `web` extension.** Ensure the extension is loaded.

## Decision guide
| I want to... | Use |
|---|---|
| Start a new website project | `/task "Build landing page for [project]"` |
| Research web patterns | `/research N` |
| Create implementation plan | `/plan N` |
| Build the site | `/implement N` |

## When to use the web extension
...

## Task type routing
| Task Type | Research Skill | Implementation Skill |
|-----------|----------------|---------------------|
| `web` | skill-web-research | skill-web-implementation |

## Starting a new website
...walkthrough with task system commands...

## Example workflow
...concrete /task -> /research -> /plan -> /implement sequence...

## Website architecture patterns
...data-driven content, layout composition, section components...

## Template reference
...pointer to web/ directory with starter files...

## See also
...links to agent-lifecycle.md, commands.md, etc...
```

## Documentation Integration

### Where to link

1. **README.md "Common Scenarios" table**: Add row:
   ```
   | Build a website with Astro and Tailwind | [Web development](docs/workflows/web-development.md) |
   ```

2. **README.md "Documentation" table**: No change needed (it links to `docs/workflows/README.md` which will include the new guide)

3. **docs/workflows/README.md "Contents" section**: Add new subsection:
   ```markdown
   ### Web development
   | File | Description |
   |---|---|
   | [web-development.md](web-development.md) | Website development with Astro/Tailwind v4: `/task`, `/research`, `/plan`, `/implement` *(requires `web` extension)* |
   ```

4. **docs/workflows/README.md "Decision guide" table**: Add row:
   ```
   | Build a website with Astro and Tailwind | [web-development.md](web-development.md) |
   ```

### Naming convention
File should be `docs/workflows/web-development.md` — matches the kebab-case pattern used by all other workflow docs.

## Creative Approaches

1. **Generalized data file templates**: Instead of just copying the Logos data files, create a "data file catalog" showing the 7 common content patterns (simple cards, status items, nested structures, etc.) with blank templates users fill in. This is more useful than one opinionated example.

2. **Phase-by-phase walkthrough**: Structure the guide as a literal walkthrough of running `/task` → `/research` → `/plan` → `/implement` for a website, showing what each command produces. This mirrors the README's "Walkthrough: Adding a New Language Server" but for web development. The example outputs could be lightly fictionalized versions of real Logos Website artifacts.

3. **The "web/" directory as a living example**: Rather than a frozen snapshot, the `web/` directory could contain a `README.md` that explains how it was generated and how to use it as a starting point. This follows the pattern of `examples/epi-study/README.md`.

4. **Cross-reference the existing Logos Website**: The guide could note that the Logos Website at `~/Projects/Logos/Website/` was built using this exact workflow, providing a real-world reference implementation. This adds credibility without requiring the guide to be Logos-specific.

## Confidence Level

**High** — The documentation gap is clear, the existing patterns (epidemiology, grant workflow docs) provide a proven template, and the Logos Website provides rich source material for extraction. The main risk is scope creep — trying to include too much of the website rather than extracting the essential patterns.
