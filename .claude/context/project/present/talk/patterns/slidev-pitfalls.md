# Slidev Implementation Pitfalls

Common issues when building Slidev decks, discovered through prior implementations. Consult this file when writing plans or implementing slides tasks.

## Footer Positioning

Slidev renders a built-in footer bar at the very bottom of each slide (showing title and other metadata). Custom footer elements must not collide with it.

**Wrong** -- absolute positioning in the footer zone:
```css
.slide-footer {
  position: absolute;
  bottom: 0.75rem;  /* COLLIDES with Slidev's built-in footer */
}
```

This produces garbled/overlapping text in PDF export because both the custom div and Slidev's footer render at the same vertical position.

**Correct** -- use flow positioning:
```html
<div style="margin-top: 1.5rem; font-size: 0.8rem; color: #6b7280;
     display: flex; justify-content: space-between;">
  <span>Left footer text</span>
  <span>Right footer text</span>
</div>
```

**Rule**: Never use `position: absolute` with `bottom` values below `3rem` on any slide element. Slidev's footer bar occupies the bottom ~2.5rem. Use normal document flow with `margin-top` to push content toward the bottom of the slide instead.

## Mermaid Diagrams

Mermaid diagrams render correctly in `slidev build` (SPA) and `slidev export` (PDF via Playwright), but may fail if:

1. **Playwright chromium is misconfigured** -- on NixOS or other non-FHS systems, the bundled chromium may be missing system libraries. The `slidev build` SPA will work fine but `slidev export` will show "An error occurred on this slide" for Mermaid slides. This is an environment issue, not a syntax issue.

2. **Complex Mermaid syntax** -- keep diagrams simple. Use `flowchart LR` or `flowchart TD` for directed graphs. Avoid advanced features (subgraphs with complex nesting, click events) that may not render in PDF export mode.

3. **Scale parameter** -- use `{scale: 0.65}` to `{scale: 0.85}` to fit diagrams on slides without overflow:
   ```markdown
   ```mermaid {scale: 0.75}
   flowchart LR
       A --> B --> C
   ```

**Verification**: Always run both `slidev build` AND `slidev export` when the deck contains Mermaid diagrams. If export fails but build succeeds, the issue is Playwright/chromium, not the diagram syntax.

## Vue Component Scoped Styles

When authoring custom Vue components (e.g., `CodeDiff.vue`, `LangBadge.vue`):

- Use `<style scoped>` to avoid leaking styles to other slides
- Test components with `slidev build` before authoring all slides -- a broken component silently produces error slides
- Slidev auto-imports components from `components/` -- no explicit registration needed

## Two-Column Layout Slots

The `two-column.vue` layout uses named slots. In Slidev markdown, use `::slotname::` syntax:

```markdown
---
layout: two-column
---

::heading::
# Slide Title

::left::
Left column content

::right::
Right column content

::footer::
Footer content (uses flow positioning, not absolute)
```

**Pitfall**: If a layout defines a `::footer::` slot, that slot content must use flow positioning. Do not add `position: absolute` styles inside slot content.

## PDF Export Checklist

Before marking a slides task as complete, verify:

1. `pnpm run build` exits 0 (SPA build)
2. `pnpm run export` exits 0 (PDF via Playwright)
3. PDF has the expected page count (one page per slide separator `---`)
4. Mermaid diagrams render (no red error messages)
5. Vue components render (no blank areas where components should be)
6. Footer text is readable and not overlapping with Slidev's footer bar
7. No content overflows the slide boundaries
