# Teammate C Findings: Gaps, Shortcomings, and Blind Spots

## Key Findings

### Finding 1: Garamond is NOT Available on This Linux System (Critical)

The PPTX theme XML declares `Garamond` as the heading font and `Arial` as body. Running `fc-list | grep -i garamond` on this NixOS system returns **zero results**. Garamond is not installed.

The existing themes sidestep this: `academic-clean` uses `Georgia, 'Times New Roman', serif` (safely degrades to generic serif). `clinical-teal` uses `'Segoe UI', 'Helvetica Neue', Arial, sans-serif`. **Neither theme loads web fonts** — no `@import` or `@font-face` in the Slidev setup.

For Garamond: use a fallback chain like `'EB Garamond', Garamond, Georgia, 'Times New Roman', serif`. Optionally add a comment noting EB Garamond can be imported via Google Fonts in the theme CSS.

### Finding 2: Theme Schema Sufficient for Colors but Lacks Cover Variant Semantics

The PPTX has **42 slide layouts** including:
- 9 cover variants (White, Navy, Teal, Blue, Purple)
- 3 section header colors (Blue, Teal, Green)
- 3 divider colors (Navy, Teal, Blue)
- 3 specialty closings (Research, Education, Patient Care)

The existing `palette` has single `accent`/`accent_light` fields. UCSF has 6 accent colors. The schema cannot represent multi-variant covers or the design theme distinction. However, attempting to extend the schema for this one theme adds complexity for marginal benefit — the implementer can reference the PPTX or the UCSF brand guide for variant guidance.

### Finding 3: D1 Question Lists Phantom Themes C and D

Lines 335-342 of `slides.md` list:
- C) Conference Bold — **no JSON file exists**
- D) Minimal Dark — **no JSON file exists**

When a user selects C or D, the choice is stored as `design_decisions.theme` but no theme definition will be found. The implementer will either silently improvise or default. This is a latent bug that pre-dates task 36.

**Recommendation**: Task 36 should either:
1. Add UCSF as option E and leave C/D as-is (minimal scope), or
2. Remove C/D and renumber UCSF as C (clean up the bug while touching the file)

Option 2 is cleaner but technically out of scope.

### Finding 4: Naming Convention

Existing themes use descriptive names (`academic-clean`, `clinical-teal`). The task specifies `ucsf-institutional`, which breaks the pattern by using an institution name. Alternatives:
- `ucsf-classic` — matches PPTX's own theme name "UCSF Classic"
- `ucsf-navy` — follows the character-based convention
- `ucsf-institutional` — as specified, signals institutional branding

The task description is explicit about the name. Proceed with `ucsf-institutional` but note the convention shift.

### Finding 5: No Logo/Image Asset Schema

UCSF slides prominently feature logos. The existing theme schema has no `assets`, `logo`, or `images` section. An implementer building a UCSF talk would need to manually source and position logos. This is a known limitation but not blocking for task 36.

### Finding 6: extensions.json May Need Updating

Theme files appear in `.claude/extensions.json` under `merged_sections` paths (lines 111-112). A new theme file should be added to this list for completeness, though the functional discovery path is via `talk/index.json`.

## Recommended Approach

1. **Font**: Use `Garamond, Georgia, 'Times New Roman', serif` with a JSON comment or description note about EB Garamond availability
2. **Scope**: Create the theme JSON, register in index, add to D1 question. Do NOT attempt to extend the schema for UCSF's full 42-layout complexity
3. **Phantom themes**: Leave C/D as-is (out of scope) but add UCSF as option E
4. **Naming**: Use `ucsf-institutional` as specified despite convention shift

## Evidence/Examples

- Font absence: `fc-list | grep -i garamond` → zero results on NixOS
- PPTX font declaration: `theme1.xml` → `<a:latin typeface="Garamond"/>` (major)
- PPTX theme name: `<a:theme name="UCSF Classic">` with `<a:clrScheme name="UCSF 1">`
- 42 slide layouts extracted from PPTX
- D1 phantom options: `slides.md` lines 335-342; no `conference-bold.json` or `minimal-dark.json` found
- No font loading in existing themes: `epi-slides/theme/styles/index.css` has no `@import` or `@font-face`

## Confidence Level

| Finding | Confidence |
|---------|-----------|
| Garamond absent on Linux | High |
| No font-loading mechanism | High |
| Schema insufficient for 42 layouts | High |
| D1 phantom themes C, D | High |
| extensions.json needs update | Medium |
| Naming convention shift | Medium |
