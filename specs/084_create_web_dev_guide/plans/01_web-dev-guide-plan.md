# Implementation Plan: Task #84

- **Task**: 84 - Create web development guide
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/084_create_web_dev_guide/reports/01_team-research.md
- **Artifacts**: plans/01_web-dev-guide-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Create user-facing documentation for the web development extension, which is fully built (2 agents, 2 skills, 22 context files, 1 rule) but has zero user docs. The deliverables are: (1) a workflow guide at `docs/workflows/web-development.md` following existing guide conventions, (2) a `web/` starter template directory at the repo root with ~17-20 generalized skeleton files extracted from the Logos Website, (3) a `web/README.md` explaining the starter template, and (4) cross-reference updates to `docs/workflows/README.md`, `docs/README.md`, and the repo root `README.md`. Done when all files exist, all cross-links resolve, and the guide follows the style of `epidemiology-analysis.md`.

### Research Integration

Team research (4 teammates, all high confidence) identified:
- The 4-layer data-driven architecture pattern (interface -> data array -> section component -> page) with `advantages.ts` as the canonical simplest example
- 3-layer component hierarchy (BaseLayout -> PageLayout -> pages composed from sections)
- 4-layer CSS architecture (@import tailwindcss -> @theme tokens -> :root/.dark semantics -> @layer components)
- Tiered artifact selection: 17 MUST-copy files, 3 SHOULD-copy files, explicit MUST-NOT list (middleware, login, domain-specific data)
- Guide target: ~150 lines following `epidemiology-analysis.md` pattern (decision table -> per-command walkthrough -> examples -> see-also)
- Path aliases in `tsconfig.json` are load-bearing and must be included

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Create `docs/workflows/web-development.md` (~150 lines) matching existing workflow guide style
- Create `web/` starter template at repo root with generalized skeleton files from the Logos Website
- Create `web/README.md` explaining the template structure and usage
- Update `docs/workflows/README.md` with web development section and decision guide entries
- Update `docs/README.md` with web development reference
- Update `README.md` Common Scenarios table with web development entry

**Non-Goals**:
- Writing an Astro or Tailwind CSS tutorial (the extension context files already cover framework internals)
- Creating a `docs/toolchain/` guide for Node.js/pnpm setup (separate task)
- Including Cloudflare deployment configuration details
- Copying domain-specific Logos content (middleware, login, API routes)
- Making the `web/` directory a runnable project (it is a reference skeleton, not `npm init`)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Generalization removes too much from source files, leaving non-functional skeleton | M | M | Keep structural code intact; only replace Logos-specific text content with placeholder strings |
| Path aliases break if tsconfig.json is not included or is incomplete | H | L | Research confirmed tsconfig.json is MUST-copy; verify alias paths match directory structure |
| Guide exceeds ~150 lines and becomes an Astro tutorial | M | M | Focus strictly on agent workflow (how to use /task -> /research -> /plan -> /implement for web tasks); reference extension context for framework details |
| Cross-reference links break in README updates | L | L | Verify all links point to existing files after completion |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Create web/ Starter Template [COMPLETED]

**Goal**: Extract and generalize ~17-20 files from the Logos Website into a `web/` starter template directory at the repo root.

**Tasks**:
- [ ] Create directory structure: `web/src/{components/{layout,sections,ui},data,layouts,pages,styles}`
- [ ] Copy and generalize `astro.config.mjs` (remove Logos-specific site URL, keep Tailwind + Cloudflare adapter)
- [ ] Copy and generalize `tsconfig.json` (keep path aliases: @components, @layouts, @data, @assets, @styles)
- [ ] Copy and generalize `package.json` (strip Logos metadata, keep Astro 5 + Tailwind 4 + TypeScript deps)
- [ ] Copy and generalize `src/styles/global.css` (replace Logos brand colors with neutral placeholder palette, keep 4-layer CSS architecture)
- [ ] Copy and generalize `src/data/site-config.ts` (replace Logos content with placeholder site name/nav/metadata)
- [ ] Create `src/data/features.ts` from `advantages.ts` (rename interface to `Feature`, replace Logos content with generic placeholder features)
- [ ] Copy and generalize `src/layouts/BaseLayout.astro` (replace Logos-specific SEO, keep HTML shell with slots)
- [ ] Copy and generalize `src/layouts/PageLayout.astro` (keep Header + main + Footer pattern)
- [ ] Copy and generalize `src/components/layout/Header.astro` (replace Logos nav items, keep CSS-only mobile menu)
- [ ] Copy and generalize `src/components/layout/Footer.astro` (replace Logos content, keep 3-column layout)
- [ ] Copy and generalize `src/components/sections/Hero.astro` (replace Logos content with placeholder hero text)
- [ ] Create `src/components/sections/Features.astro` from Advantages.astro (rename, replace data import from features.ts)
- [ ] Copy `src/components/ui/Container.astro` (already generic)
- [ ] Copy `src/components/ui/Button.astro` (already generic)
- [ ] Copy `src/components/ui/SectionHeading.astro` (already generic)
- [ ] Copy `src/components/ui/FeatureCard.astro` (already generic)
- [ ] Copy and generalize `src/pages/index.astro` (replace Logos sections with Hero + Features)
- [ ] Copy SHOULD-include files: `NavLink.astro`, `ScrollReveal.astro`, `404.astro`
- [ ] Create `web/README.md` explaining the starter template structure, the 4-layer pattern, and how to customize

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `web/astro.config.mjs` - new file
- `web/tsconfig.json` - new file
- `web/package.json` - new file
- `web/src/styles/global.css` - new file
- `web/src/data/site-config.ts` - new file
- `web/src/data/features.ts` - new file (generalized from advantages.ts)
- `web/src/layouts/BaseLayout.astro` - new file
- `web/src/layouts/PageLayout.astro` - new file
- `web/src/components/layout/Header.astro` - new file
- `web/src/components/layout/Footer.astro` - new file
- `web/src/components/layout/NavLink.astro` - new file
- `web/src/components/sections/Hero.astro` - new file
- `web/src/components/sections/Features.astro` - new file (generalized from Advantages.astro)
- `web/src/components/ui/Container.astro` - new file
- `web/src/components/ui/Button.astro` - new file
- `web/src/components/ui/SectionHeading.astro` - new file
- `web/src/components/ui/FeatureCard.astro` - new file
- `web/src/components/ui/ScrollReveal.astro` - new file
- `web/src/pages/index.astro` - new file
- `web/src/pages/404.astro` - new file
- `web/README.md` - new file

**Verification**:
- All ~20 files exist in `web/` with proper directory structure
- No Logos-specific content remains (grep for "Logos", "Infinite Clean Data", etc.)
- Path aliases in tsconfig.json match the actual directory structure
- `web/README.md` explains the template and references the 4-layer pattern

---

### Phase 2: Write Workflow Guide [COMPLETED]

**Goal**: Create `docs/workflows/web-development.md` (~150 lines) following the existing workflow guide conventions.

**Tasks**:
- [ ] Write opening paragraph matching epidemiology-analysis.md style (1-2 sentences describing the extension, requires-note)
- [ ] Write decision guide table (I want to... / Use) covering: start a new website project, research web technologies, create a web implementation plan, build web components
- [ ] Write "When to use the web extension" section explaining when tasks route to web-specific agents
- [ ] Write task type routing table (task_type "web" -> skill-web-research / skill-web-implementation)
- [ ] Write "Starting a new website" section showing `/task "Build landing page"` workflow
- [ ] Write example workflow section showing end-to-end: /task -> /research -> /plan -> /implement with web task
- [ ] Write "Web development capabilities" section listing what the extension context covers (Astro, Tailwind v4, TypeScript, accessibility, performance)
- [ ] Write "Using the starter template" section referencing `web/` directory
- [ ] Write "See also" section with links to agent-lifecycle.md, commands.md, and web extension context files

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `docs/workflows/web-development.md` - new file (~150 lines)

**Verification**:
- Guide follows epidemiology-analysis.md structure: decision table -> when to use -> task type routing -> starting a project -> example workflow -> capabilities -> see also
- Line count is ~120-180 lines (mid-large workflow guide range)
- No Astro tutorial content; focuses on agent workflow
- All internal links resolve

---

### Phase 3: Write web/README.md [COMPLETED]

**Goal**: Create README for the web/ starter template explaining its structure, the 4-layer architecture pattern, and how to customize it.

**Tasks**:
- [ ] Write overview explaining the starter template is extracted from a production Astro 5 + Tailwind CSS v4 site
- [ ] Write directory structure section showing the file tree
- [ ] Write "The 4-Layer Pattern" section: interface -> data array -> section component -> page
- [ ] Write "Customizing the Template" section: how to change brand colors (@theme), add new data-driven sections, modify nav items
- [ ] Write "Build Commands" section: pnpm install, pnpm dev, pnpm build, pnpm check
- [ ] Write note that this is a reference skeleton, not a standalone runnable project until pnpm install is run

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `web/README.md` - new file (may have been started in Phase 1; this phase completes it)

**Verification**:
- README accurately describes the files in web/
- 4-layer pattern explanation is clear and references features.ts as the canonical example
- Build commands are correct

---

### Phase 4: Update Cross-References [NOT STARTED]

**Goal**: Add web development links to docs/workflows/README.md, docs/README.md, and the repo root README.md.

**Tasks**:
- [ ] Add "Web development" section to `docs/workflows/README.md` Contents table (after Grant development, before Memory)
- [ ] Add web development entries to `docs/workflows/README.md` decision guide table
- [ ] Add web development common scenario to `docs/workflows/README.md` common scenarios section
- [ ] Update `docs/README.md` Workflows description to mention web development
- [ ] Add web development row to `README.md` Common Scenarios table: "Build a website with Astro and Tailwind" -> link to docs/workflows/web-development.md
- [ ] Add web development entry to `README.md` Domain Extensions section under Agent Commands (if appropriate pattern exists)

**Timing**: 30 minutes

**Depends on**: 2, 3

**Files to modify**:
- `docs/workflows/README.md` - add web development section, decision guide entries, common scenario
- `docs/README.md` - update Workflows description
- `README.md` - add Common Scenarios row, potentially add Domain Extension entry

**Verification**:
- All added links resolve to existing files
- Table formatting is consistent with adjacent entries
- No duplicate entries created
- grep for "web-development.md" shows links in all three README files

## Testing & Validation

- [ ] Verify `web/` directory contains ~20 files matching the research-specified artifact list
- [ ] Verify no Logos-specific content in web/ files: `grep -ri "logos\|infinite clean data\|proof-checker\|model-checker" web/`
- [ ] Verify `docs/workflows/web-development.md` exists and is ~120-180 lines
- [ ] Verify `web/README.md` exists and explains the 4-layer pattern
- [ ] Verify all cross-reference links resolve: check that `docs/workflows/web-development.md` is linked from `docs/workflows/README.md`, `docs/README.md`, and `README.md`
- [ ] Verify tsconfig.json path aliases match actual web/ directory structure
- [ ] Verify workflow guide follows epidemiology-analysis.md style (decision table, when-to-use, routing table, example workflow, capabilities, see-also)

## Artifacts & Outputs

- `web/` directory (~20 files) - Generalized Astro 5 + Tailwind CSS v4 starter template
- `web/README.md` - Starter template documentation
- `docs/workflows/web-development.md` - User-facing workflow guide
- `docs/workflows/README.md` - Updated with web development section
- `docs/README.md` - Updated with web development reference
- `README.md` - Updated Common Scenarios table

## Rollback/Contingency

All changes are additive (new files and appended entries in existing files). Rollback by:
1. Remove `web/` directory: `rm -rf web/`
2. Remove `docs/workflows/web-development.md`
3. Revert changes to `docs/workflows/README.md`, `docs/README.md`, and `README.md` via `git checkout -- docs/workflows/README.md docs/README.md README.md`
