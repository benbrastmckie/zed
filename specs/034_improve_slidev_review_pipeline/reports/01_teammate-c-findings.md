# Teammate C: Critic Findings — Task 34 Slidev Review Pipeline

**Role**: Critic — gaps, blind spots, and overconfident assumptions
**Method**: Git history analysis, codebase exploration, agent/context audit

---

## Key Findings

### 1. Git History Shows Only One Debug Commit (Expected Many)

The full git log for `examples/epi-slides/` has exactly 8 commits, all from task 29:

```
f0991dd task 29: complete implementation        ← fixes footer overlap, final verif
508ad35 task 29 phase 7: README, rehearsal...
ed85294 task 29 phase 6: slidev build succeeds, PDF export skipped (NixOS chromium)
f915de2 task 29 phase 5: author slides 8-14
...
880521c task 29 phase 1: scaffold examples/epi-slides/
```

The task 29 final commit message says: "Fixed slide 14 footer overlap (absolute->flow
positioning)". This is an **undocumented seventh issue** not in the six-class list:

- **Footer absolute positioning causing overlap** — switching from `position: absolute`
  to flow positioning fixed an overlap on slide 14. This is distinct from Shiki or
  mermaid issues and is worth documenting as a standalone pitfall.

There are no debugging "fix" commits separate from phase commits. This means the actual
debugging happened within phases, and the commit history understates how many issues
were encountered. The six-class list may be **complete by design** (the author chose
what to document) but the positioning issue was observed in the code.

### 2. slides-agent.md Does NOT Reference slidev-pitfalls.md

The slides-agent loads context via index.json, which *does* have an entry for
`slidev-pitfalls.md` tagged with `load_when.agents: ["slides-agent", "planner-agent",
"general-implementation-agent"]`. However:

- The pitfalls doc is for *planner context* (Playwright verification phase template),
  not slides-agent (which does research/content mapping, not implementation).
- The slides-agent's `## Context References` section lists talk patterns and domain
  docs but does NOT explicitly name `slidev-pitfalls.md`.
- The pitfalls doc is only loaded if the index.json query runs and the agent is in
  the matched list. This is **conditional and implicit** — it depends on the agent
  or orchestrator doing a context discovery query at runtime.
- **Risk**: If the planner-agent doesn't query context for `present` task types,
  or queries with wrong parameters, the pitfalls doc never loads and the Playwright
  phase never appears in the plan.

Evidence: `planner-agent.md` has no explicit reference to `slidev-pitfalls.md`. Its
context references load `plan-format.md`, `task-breakdown.md`, and `CLAUDE.md`. The
pitfalls doc only reaches planner-agent if a context discovery query is run with
`agent=planner-agent` AND `task_type=slides`. This is an implicit dependency chain.

### 3. NixOS Chromium Issue Is Documented but Unsolved

The pitfalls doc says:

> "If `slidev export` shows 'An error occurred on this slide' but `slidev build`
> works fine, the issue is Playwright/chromium configuration (common on NixOS),
> not diagram syntax."

Phase 6 commit is literally titled "slidev build succeeds, PDF export skipped (NixOS
chromium)". The proposed Playwright verification phase template (`playwright-verify.mjs`)
**uses `playwright-chromium`** — meaning it will hit the same NixOS chromium issue
that caused PDF export to be skipped in the actual implementation.

The plan calls for running `node scripts/verify-slides.mjs` as the final phase, but
on NixOS this will likely fail with chromium launch errors. The pitfalls doc acknowledges
the issue but the proposed fix doesn't address it. **The template and the NixOS
limitation are in direct tension.**

`package.json` already lists `playwright-chromium: ^1.48.0` as a devDependency but
`pnpm-lock.yaml` has `1.59.1` resolved — there's a `^` range discrepancy that could
cause version drift.

### 4. Playwright Script Has Real Blind Spots Not Mentioned in Docs

The `playwright-verify.mjs` template checks:
- Visible "An error occurred on this slide" text
- Console `pageerror` events
- Text content length < 30 chars (blank slide proxy)

What it **cannot** catch:
- **CSS print media query differences** — slides that look correct in browser but
  render differently in PDF (e.g., elements hidden under `@media print`)
- **Font rendering failures** — if a custom font doesn't load, text falls back
  silently; no error fires, text length passes
- **Image 404s** — a broken image shows a broken icon with no pageerror; textLen
  passes if other content exists
- **Mermaid partially rendered** — a mermaid diagram that renders an empty SVG
  (common with complex syntax) won't show "An error occurred" and won't be blank
- **Slide overflow/clipping** — content that overflows the slide container is
  visually broken but passes all three checks
- **Speaker notes not checked** — if speaker notes contain broken Vue or HTML,
  presenter mode breaks but verification passes
- **Transition/animation states** — screenshots taken at 2-second wait may capture
  mid-animation state; for slides with entrance animations, content may not be
  fully visible

The `textLen < 30` heuristic is fragile: a slide with only a large mermaid diagram
and no text will fail this check even if it rendered correctly.

### 5. Template Maintenance Risk Is Real and Unaddressed

The proposed deliverable includes a "project template" with a pinned `package.json`.
Current `package.json` pins `@slidev/cli: "^52.14.2"`. Slidev releases frequently
(52.x → 53.x is plausible within months). The template will drift from current
versions within one Slidev major release.

No mechanism is proposed for:
- Detecting when the template is stale (no version check)
- Updating the template as Slidev releases new versions
- Warning implementers that template packages may be outdated
- Testing the template against new Slidev versions

This is a **maintenance burden that scales with usage**. Every new slides task using
a stale template will import the same old bugs or miss new features.

### 6. Fundamental Root Cause Not Addressed

The six issue classes share a common root cause: **Slidev's toolchain has sharp edges
at the pnpm strict layout/ESM/Vue/MDC intersection** that aren't surfaced by Slidev's
own error messages. The proposed fix is defensive documentation + post-hoc detection.

An alternative approach not considered: **configure Slidev globally per environment
rather than per-project**. A nix shell or devShell for slides development could:
- Pre-install the correct Slidev version system-wide
- Pre-configure pnpm hoisting globally
- Avoid the lz-string shim entirely by using npm instead of pnpm
- Pre-install playwright chromium with NixOS-compatible wrappers

This would solve classes 1, 2, and potentially 3 at the toolchain level rather than
the documentation level. The task description doesn't ask this question.

### 7. Missing Validation Targets Not Listed in the Task

The task focuses on mermaid and Vue components. These rendering targets have no
coverage in the proposed Playwright script:

- **KaTeX / math rendering** — `$\text{inline math}$` or `$$\text{block math}$$`
  renders via KaTeX which loads asynchronously; the 2-second wait may not be
  sufficient for complex expressions
- **Code blocks with shiki** — the shiki override CSS fix covers inline code, but
  fenced code blocks in slides can still have theming conflicts
- **Custom layouts** — slides using `layout: two-cols` or custom theme layouts have
  additional CSS that can break; the verification script checks all slides uniformly
  but doesn't know layout names
- **Embedded iframes** — Slidev supports iframe embeds; these timeout silently in
  local dev

---

## Recommended Approach

**For addressing the NixOS/Playwright tension**: The pitfalls doc should document
a NixOS-specific workaround for `playwright-verify.mjs` (e.g., using `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1`
with a system chromium, or wrapping the launch with `executablePath`). The phase
template should include a conditional: "if on NixOS, run `slidev build` instead
and verify page count from dist/".

**For the slides-agent/pitfalls loading gap**: The planner-agent should have an
explicit `@-reference` to `slidev-pitfalls.md` in its Context References section
when `task_type=slides`, not just rely on implicit index.json discovery.

**For Playwright blind spots**: Extend `playwright-verify.mjs` to also check for
broken image `src` attributes (via `page.$$eval`) and SVG elements with zero
dimensions (mermaid empty render proxy).

**For template staleness**: Add a `# Template version` comment to the template
`package.json` and a line to the pitfalls doc: "Update `@slidev/cli` version to
match `pnpm info @slidev/cli version` before first install."

**For footer/positioning issues**: Add the slide 14 positioning fix as a seventh
documented pitfall: "avoid `position: absolute` in slide content; use flow
positioning or Slidev's `::bottom::` slot instead."

---

## Evidence / Examples

- `git log --oneline examples/epi-slides/` — 8 commits, no debugging commits separate
  from phase commits; footer fix in final commit message
- `.claude/agents/slides-agent.md` — no mention of `slidev-pitfalls` or `playwright`
- `.claude/agents/planner-agent.md` — no mention of `slidev-pitfalls` in Context
  References; pitfalls reachability is implicit via index.json only
- `.claude/context/index.json` entry for `slidev-pitfalls.md` — `load_when.agents`
  includes `planner-agent` but agents don't run context discovery queries themselves;
  the orchestrating skill must do it
- `talk/templates/playwright-verify.mjs:17` — uses `spawn('npx', ['slidev', ...])`,
  same invocation pattern that NixOS chromium breaks
- `examples/epi-slides/package.json` — `playwright-chromium: "^1.48.0"` but lockfile
  resolves `1.59.1`
- Phase 6 commit: "slidev build succeeds, **PDF export skipped** (NixOS chromium)"
  — demonstrates the NixOS gap is real and unresolved

---

## Confidence Level

| Finding | Confidence |
|---------|-----------|
| Undocumented footer/positioning issue (7th class) | High |
| slides-agent does not load pitfalls explicitly | High |
| planner-agent pitfalls loading is implicit/fragile | High |
| NixOS/Playwright tension in template | High |
| Playwright blind spots (images, empty SVG, overflow) | High |
| Template maintenance risk | Medium |
| Alternative toolchain-level solution not considered | Medium |
| Missing validation targets (KaTeX, custom layouts) | Medium |
