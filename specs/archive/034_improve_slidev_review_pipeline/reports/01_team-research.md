# Research Report: Task #34

**Task**: Improve Slidev review pipeline to catch rendering issues during first implementation
**Date**: 2026-04-11
**Mode**: Team Research (4 teammates)

## Summary

The Slidev review pipeline improvements are well-scoped and architecturally aligned with the project's existing extension structure. The core deliverables — project scaffold template, updated pitfalls documentation, and Playwright script fixes — are achievable with moderate effort. However, research reveals the task's scope is both smaller and larger than initially described: several "enhancements" are already partially implemented (pageerror capture exists), while important gaps were not identified (NixOS/Playwright tension, implicit context loading, a 7th issue class).

## Key Findings

### Primary Approach (from Teammate A)

1. **slidev-pitfalls.md already documents 5 of 6 issue classes** — but has one factual error: line 44 says "Use `npx slidev`" when it should be "Use `npx @slidev/cli`". This contradicts the working Zed tasks configuration.

2. **playwright-verify.mjs has the same `npx slidev` bug** on line 17 — it spawns `['npx', 'slidev', ...]` instead of `['npx', '@slidev/cli', ...]`. The script already captures `pageerror` events (line 67), so console error capture is partially implemented.

3. **No template directory exists** — `talk/templates/` contains only `playwright-verify.mjs`. The four project scaffold files (package.json, .npmrc, vite.config.ts, lz-string-esm.js) need to be extracted from `examples/epi-slides/` into a new `templates/slidev-project/` directory.

4. **The implementation agent reconstructs scaffolding from prose** — there's no concrete template to copy, making each new deck implementation error-prone.

5. **index.json entry for slidev-pitfalls.md is stale** — records `line_count: 73` but file is now 117 lines; summary/description fields are outdated.

6. **epi-slides package.json already at v52** — the version mismatch (v0.49 vs v52) has been resolved in the working example.

### Alternative Approaches (from Teammate B)

1. **Three-layer error detection model**: pre-flight shell checks (milliseconds) → `slidev build` (Vite compilation) → Playwright (visual + silent failures). Each layer catches distinct issue subsets.

2. **`slidev build` as first-pass validator** — catches lz-string ESM crashes, CLI version issues, and major Vue compile errors without launching a browser. Should be a required step before Playwright in the plan template.

3. **No Slidev `doctor` command exists** — `slidev build` is the closest equivalent.

4. **Console.error gap** — `playwright-verify.mjs` only listens to `pageerror` events (thrown JS errors). Silent Vue component failures in pipe tables surface as `console.error` calls. Adding `page.on('console', msg => { if (msg.type() === 'error') ... })` is a one-liner fix.

5. **lz-string ESM shim remains the right approach** — no viable ESM alternative exists at Slidev's current dependency tree. The shim should be a template file, not per-project authored.

### Gaps and Shortcomings (from Critic)

1. **Undocumented 7th issue class** — footer/absolute positioning overlap (slide 14 fix in task 29's final commit) is not in the six-class list. Should be documented as: "avoid `position: absolute` in slide content; use flow positioning or Slidev's `::bottom::` slot."

2. **NixOS/Playwright tension** — the proposed `playwright-verify.mjs` template uses `playwright-chromium`, but phase 6 of the epi-slides implementation was literally titled "PDF export skipped (NixOS chromium)." The template and the NixOS limitation are in direct tension. The pitfalls doc acknowledges the issue but the proposed fix doesn't address it.

3. **Pitfalls doc loading is implicit and fragile** — neither `slides-agent.md` nor `planner-agent.md` have explicit `@-references` to `slidev-pitfalls.md`. The doc only reaches planner-agent if a context discovery query runs with the right parameters. If that query doesn't run, the Playwright verification phase never appears in the plan.

4. **Playwright blind spots** — the script cannot catch: broken images (no pageerror), empty SVG mermaid renders, CSS overflow/clipping, font load failures, or print media query differences. The `textLen < 30` heuristic false-positives on diagram-only slides.

5. **Template maintenance** — no mechanism to detect or handle Slidev version drift. Template goes stale within one major release.

6. **Root cause not addressed** — the six issues share a common root cause (Slidev's toolchain sharp edges at the pnpm/ESM/Vue/MDC intersection). A nix devShell could eliminate classes 1, 2, and potentially 3 at the toolchain level.

### Strategic Horizons (from Teammate D)

1. **Slidev is the committed long-term tool** — no migration signals, deep extension investment. The proposed approach is strategically aligned.

2. **Template scaffold is highest leverage** — prevents 5 of 6 issue classes by addressing root causes at setup time rather than content-authoring time.

3. **Playwright enhancement is smaller than described** — `pageerror` capture already exists. The real gap is `page.on('console')` for error-level messages, which is a one-liner.

4. **Browser verification pattern could generalize** — the core "spawn dev server + visit pages + check errors" pattern could serve other web-based outputs. Low priority for now; document when a second use case emerges.

5. **No architectural changes needed** — new template files fit into existing `talk/templates/` directory and `talk/index.json` templates category.

6. **Remaining gaps after task 34**: automated version compatibility check, CSS smoke-test for theme conflicts, CI integration, component validation before rendering.

## Synthesis

### Conflicts Resolved

1. **pitfalls doc coverage** — Teammate A says "all six documented", Teammate D says "4 of 6 documented". Resolution: A is correct that the doc covers all six issue topics, but D is correct that the Shiki CSS and Vue-in-tables entries are only in the "Fixing Common Errors" subsection, not as standalone setup sections. Both need promotion to full documentation with prevention guidance, not just fix instructions.

2. **Playwright console error capture** — All teammates agree `pageerror` exists but `console.error` capture is missing. No conflict; the enhancement is a targeted addition, not a rewrite.

3. **Template location** — A proposes `templates/slidev-project/`, B proposes `templates/scaffold/`, D proposes `templates/project-scaffold/`. Resolution: use `templates/slidev-project/` as it's most descriptive and follows naming conventions in the codebase.

### Gaps Identified

1. **NixOS workaround needed** — The Playwright template will fail on NixOS without a documented workaround (e.g., `executablePath` pointing to system chromium, or a `slidev build` fallback). This should be addressed in the pitfalls doc and plan template.

2. **Explicit context loading** — The pitfalls doc's reachability depends on implicit index.json queries. The planner-agent should have an explicit reference for slides task types. This is a meta-system improvement worth including.

3. **Template staleness strategy** — Add a version comment to the template `package.json` and a "validate version before use" note in the pitfalls doc. This makes staleness visible rather than silent.

4. **7th issue class** — Footer absolute positioning overlap should be documented.

### Recommendations

**Concrete deliverables (ordered by leverage)**:

1. **Create template directory** at `.claude/context/project/present/talk/templates/slidev-project/` with four files from `examples/epi-slides/`:
   - `package.json` (with version comment header)
   - `.npmrc` (`shamefully-hoist=true`)
   - `vite.config.ts` (lz-string alias)
   - `lz-string-esm.js` (vendored ESM shim)

2. **Update slidev-pitfalls.md**:
   - Fix line 44: `npx slidev` → `npx @slidev/cli`
   - Add "Project Scaffolding" section referencing template directory
   - Promote Shiki CSS and Vue-in-tables to full prevention sections
   - Add 7th issue: footer/absolute positioning overlap
   - Add NixOS Playwright workaround documentation
   - Add `slidev build` as pre-Playwright validation step
   - Document template version for staleness visibility

3. **Fix playwright-verify.mjs**:
   - Line 17: `'slidev'` → `'@slidev/cli'`
   - Add `page.on('console')` for error-level messages
   - Add NixOS `executablePath` option or fallback guidance

4. **Update index.json**:
   - Fix stale entry for `slidev-pitfalls.md` (line_count, summary, description)
   - Register new template directory

5. **Add explicit pitfalls reference** to planner-agent or slides context loading path to ensure the Playwright verification phase always appears in slides plans.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary implementation approaches | completed | high |
| B | Alternative patterns and prior art | completed | high |
| C | Critic — gaps and blind spots | completed | high |
| D | Strategic horizons | completed | high/medium |

## References

- `examples/epi-slides/` — working Slidev project (canonical template source)
- `.claude/context/project/present/talk/patterns/slidev-pitfalls.md` — current pitfalls doc (117 lines)
- `.claude/context/project/present/talk/templates/playwright-verify.mjs` — current Playwright script
- `.claude/agents/slides-agent.md` — slides research agent (no scaffolding logic)
- `.claude/agents/planner-agent.md` — planner agent (no explicit pitfalls reference)
- `.claude/context/index.json` — stale entry for slidev-pitfalls.md
- `.zed/tasks.json` — working `npx @slidev/cli` invocation
- `git log examples/epi-slides/` — 8 commits, footer fix in final commit
