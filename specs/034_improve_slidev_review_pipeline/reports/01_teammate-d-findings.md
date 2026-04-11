---
task: 34
teammate: D
role: Horizons — Strategic alignment and long-term direction
---

# Teammate D Findings: Strategic Horizons

## Key Findings

### 1. Slidev Is the Committed Long-Term Presentation Tool

ROADMAP.md is empty (no phase items, no success metrics). This is not a detractor from
the proposed approach — it means strategic direction must be inferred from the codebase
itself. The evidence is clear: the present extension is deeply invested in Slidev:

- A rich talk library lives in `.claude/context/project/present/talk/` with patterns,
  Vue components, Playwright verification, and two themes
- Task 29 (epi-slides conference talk) was completed successfully with 14 slides and
  working PDF export — the pipeline is already functional
- The slides-agent, planner-agent, and skill-slides all reference Slidev-specific
  context by name
- No Typst or LaTeX equivalents for slides exist (Typst is used for grants/timelines,
  not talks)

The extension is Slidev-first for presentations. There is no signal of a pending
migration. The proposed improvements are aligned with this commitment.

### 2. The Template Approach Is Architecturally Sound — But Has a Staleness Risk

The proposed deliverable (a project template with `package.json`, `.npmrc`,
`vite.config.ts`, `lz-string-esm.js`) correctly addresses the root cause of five of
the six issue classes: they were all setup configuration problems, not content
authoring problems.

However, static file templates carry a staleness risk: if `@slidev/cli` releases a
breaking version change, the pinned template `package.json` will become misleading
rather than helpful. The current `epi-slides/package.json` pins `^52.14.2` — already
tracking a major version change from the `0.49` referenced in the task description.

**Strategic recommendation**: The template `package.json` should include a clear
`# Generated from template: review version before use` header comment, and the
`slidev-pitfalls.md` should document which Slidev version the template was validated
against. This makes staleness visible rather than silent.

### 3. The Playwright Script Already Checks Console Errors

A close reading of `playwright-verify.mjs` (lines 66-67) shows it already captures
`pageerror` events and includes them in failure reports. The task description says the
script needs to be "enhanced to check for console errors (not just visible error text)"
— but this capability already exists.

What the script does NOT check:
- `console.error()` calls (only `page.on('pageerror')` which catches uncaught exceptions)
- Network failures (failed asset loads, 404s for component scripts)
- Render warnings from Vue (e.g., missing required prop on a component)

The real enhancement needed is adding `page.on('console')` for `error`-level console
messages alongside the existing `pageerror` listener. This is a one-line addition.

**Strategic implication**: The task's scope for the Playwright enhancement is smaller
than it sounds — the script is already doing most of what's needed. This means the
effort can be redirected toward the template scaffolding and pitfalls documentation,
which have higher leverage.

### 4. The "Browser Verification" Pattern Can Be Generalized

The Playwright verification pattern is currently Slidev-specific (hardcoded to
`http://localhost:{PORT}/{slideNumber}`, slide counting from markdown). But the
core pattern — spawn a dev server, visit each page, check for errors, capture
screenshots — is generic.

The pattern would generalize to:
- Any Vite-based web app (a future web extension)
- Any future presentation format served as HTML (e.g., RevealJS if ever adopted)

A minimal generalization would be to extract the "start dev server + visit URLs +
check for errors" loop into a shared utility pattern documented in
`.claude/context/patterns/browser-verification.md`. The Slidev-specific slide counting
and URL scheme would remain in the slides-specific script. This aligns with the
project's pattern of documenting reusable patterns in `.claude/context/patterns/`.

This is a low-priority enhancement for after Task 34, not a blocker for it.

### 5. Extension Architecture: Context Lives in the Right Place

The Slidev pitfalls doc and playwright-verify template live in:
```
.claude/context/project/present/talk/patterns/slidev-pitfalls.md
.claude/context/project/present/talk/templates/playwright-verify.mjs
```

The proposed new template files (project scaffold) would logically live at:
```
.claude/context/project/present/talk/templates/project-scaffold/
  package.json
  .npmrc
  vite.config.ts
  lz-string-esm.js
```

This is consistent with the existing architecture. The `talk/index.json` has a
`templates` category already — the scaffold files can be registered there. This
makes them discoverable to the slides-agent without any new index infrastructure.

**No architectural changes needed**: the present extension's context structure can
absorb the new deliverables without modification to `index.json` schema or extension
manifest.

### 6. What Would Remain After Task 34

After implementing the proposed deliverables, the following gaps would still exist:

1. **No automated version compatibility check**: The Playwright script could warn if
   the running Slidev dev server version differs from `package.json`. This would catch
   the "global nix binary vs. project version" issue at runtime rather than requiring
   the developer to notice.

2. **No smoke-test for theme CSS**: The Shiki inline-code dark background issue was a
   CSS specificity problem. Playwright screenshots catch it visually, but only if
   someone looks at them. An automated check for abnormally dark background colors on
   inline `<code>` elements would be more reliable.

3. **No CI integration**: The verification script runs manually. A `.github/workflows`
   or Zed task that runs verification on every slides.md commit would prevent
   regressions from being introduced unnoticed. This is beyond the meta-task scope
   but is the natural next step.

4. **No component validation before rendering**: Vue components referenced in
   markdown are only validated at render time. A pre-flight check that scans
   slides.md for `<ComponentName>` references and verifies each exists in
   `components/` would catch missing-component errors before launching the browser.

## Recommended Approach

**Prioritize in this order**:

1. **Template scaffold** (highest leverage): Create
   `talk/templates/project-scaffold/` with the four files. Register in `talk/index.json`.
   This prevents 5 of 6 issue classes for all future decks.

2. **Update slidev-pitfalls.md**: Add the two missing issue classes (Shiki CSS,
   Vue components in tables) and a "npx @slidev/cli" note. Document the Slidev version
   the template was validated against.

3. **Minimal Playwright enhancement**: Add `page.on('console')` filtering for
   `error`-level messages. Do not overhaul the script — it already works.

4. **Register template in index.json**: Add the scaffold to the `templates` section
   so the slides-agent can discover it.

**Do not**:
- Attempt dynamic template generation (premature; Slidev's API is not designed for
  programmatic scaffolding and the maintenance cost exceeds the benefit)
- Generalize the Playwright pattern now (do it when a second use case emerges)
- Add CI integration (out of scope for a meta task; belongs in a separate task)

## Evidence / Examples

- `examples/epi-slides/package.json`: Current working package.json with `^52.14.2`
- `examples/epi-slides/vite.config.ts`: Current working vite config with lz-string alias
- `examples/epi-slides/.npmrc`: (untracked) Contains `shamefully-hoist=true`
- `.claude/context/project/present/talk/templates/playwright-verify.mjs`: Lines 66-67
  already capture `pageerror`; lines 73-76 check visible errors
- `.claude/context/project/present/talk/index.json`: `templates` category exists,
  ready for scaffold registration
- `.claude/context/project/present/talk/patterns/slidev-pitfalls.md`: Current doc has
  4 of 6 issue classes; missing Shiki CSS and Vue-in-tables

## Confidence Level

**High** for findings 1, 3, 5 (directly verified from code).

**Medium** for finding 4 (Playwright generalization is straightforward but the
need for it depends on future extension development that hasn't started).

**Medium** for finding 6 gap items (reasonable inferences from the current state,
but the user's priorities may differ).
