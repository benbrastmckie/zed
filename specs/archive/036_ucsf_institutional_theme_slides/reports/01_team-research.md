# Research Report: Task #36

**Task**: Add UCSF institutional theme to slides workflow
**Date**: 2026-04-12
**Mode**: Team Research (4 teammates)

## Summary

All four teammates agree on the core implementation: create `ucsf-institutional.json` following the existing theme schema, register it in `talk/index.json`, add as option E in the `/slides --design` D1 question, and update `extensions.json`. The UCSF brand palette is well-defined (navy #052049, Pacific Blue #0093D0, teal #16A0AC, Garamond/Arial typography). Key debates center on schema extension depth and font fallback strategy.

## Key Findings

### 1. UCSF Brand Palette (Confirmed by All Teammates)

From PPTX `theme1.xml`, the "UCSF Classic" theme with color scheme "UCSF 1":

| Role | Hex | Schema Mapping |
|------|-----|----------------|
| Navy (dk1) | #052049 | `heading` |
| White (lt1) | #FFFFFF | `background` |
| Pacific Blue (accent1) | #0093D0 | `accent` |
| Teal (accent2) | #16A0AC | `highlight` |
| Green (accent3) | #32A03E | `success` |
| Purple (accent4) | #A238BA | (extra — not in base schema) |
| Magenta (accent5) | #C32882 | (extra — could map to `error`) |
| Violet (accent6) | #6C61D0 | (extra — not in base schema) |
| Hyperlink | #178CCB | (link styling reference) |

Typography: Garamond (headings), Arial (body). 36pt headers, 18pt sub-headers per brand guidelines.

### 2. Theme JSON Schema Is Sufficient (Teammate A + C Consensus)

The existing schema (`palette`, `typography`, `spacing`, `borders`, `footer`, `slidev_config`) can represent the UCSF theme without modification. While the PPTX has 42 layouts and 6 accent colors, the theme JSON is a reference specification (not runtime data) — the implementer maps values to CSS manually. Trying to represent all 42 layout variants would over-engineer the JSON for marginal benefit.

### 3. Font Availability (Critic Finding — High Confidence)

**Garamond is NOT installed on this NixOS system.** No existing theme loads web fonts. The safe approach is a fallback chain: `Garamond, Georgia, 'Times New Roman', serif`. If Garamond is available (macOS, Windows, or manually installed), it renders; otherwise Georgia provides a graceful serif fallback. This matches the pattern used by `academic-clean` (Georgia-based) and `clinical-teal` (Segoe UI with Arial fallback).

### 4. Four Integration Points Required

| File | Change | Priority |
|------|--------|----------|
| `talk/themes/ucsf-institutional.json` | **Create** — new theme file | Required |
| `talk/index.json` | **Edit** — add to `categories.themes.items[]` | Required |
| `.claude/commands/slides.md` | **Edit** — add option E to D1 question | Required |
| `.claude/extensions.json` | **Edit** — add path to `installed_files` | Required |

Files confirmed NOT needing changes: `talk-structure.md`, `context/index.json`, agent files, content templates.

### 5. Phantom Themes C and D (Critic + Horizons)

The D1 design question lists "Conference Bold" (C) and "Minimal Dark" (D) — neither has a backing JSON file. This is a pre-existing latent bug. When selected, the choice is stored but no definition is found at implementation time.

**Decision**: Out of scope for task 36. Add UCSF as option E alongside existing A-D. The phantom theme issue can be addressed in a separate task.

### 6. Naming Convention (Critic Analysis)

Existing themes use descriptive names (`academic-clean`, `clinical-teal`). `ucsf-institutional` introduces an institution-based naming convention. This is an intentional shift — the user explicitly requested an institutional template. The name `ucsf-institutional` signals this is brand-specific, not just a color scheme.

## Synthesis

### Conflicts Resolved

**Conflict 1: Schema extension depth**
- Teammate B proposed extended sections (`variants`, `logo`, `institutional_footer`, `slide_layouts`)
- Teammate A and C recommended sticking to the existing schema
- **Resolution**: Use the existing schema only. Add `institution` as a single optional block with name/full_name for future-proofing. Do NOT add variants/logo/slide_layouts — these add complexity the current system cannot consume.

**Conflict 2: Text color choice**
- Teammate A proposed `#1a202c` (dark gray, matching clinical-teal pattern)
- Teammate B proposed `#052049` (navy, matching PPTX dk1)
- **Resolution**: Use `#1a202c` for body text (better readability at small sizes) and `#052049` for headings only. This follows the clinical-teal approach where heading and text colors differ.

**Conflict 3: Error color mapping**
- Teammate A proposed mapping UCSF magenta (#C32882) to `error`
- Existing themes use standard #dc2626 (red) for error
- **Resolution**: Use #dc2626 for `error` (semantic consistency). Magenta is a brand accent, not a signal color. Keep the UCSF accent colors as reference in the description field.

### Gaps Identified

1. **No mechanism for extra accent colors** — UCSF has 6 accents but schema has 1 `accent` + `accent_light`. The theme description should document the full palette for implementer reference.
2. **No logo asset management** — implementers need to manually source UCSF logos. Not blocking for the theme file.
3. **Phantom themes C/D** — pre-existing issue, not introduced by this task.

### Recommendations

1. **Create `ucsf-institutional.json`** with the proposed color mapping:
   - `background`: #ffffff, `text`: #1a202c, `heading`: #052049
   - `accent`: #0093D0, `accent_light`: #e6f2fa, `highlight`: #16A0AC
   - `muted`: #5f6b7a, `success`: #32A03E, `warning`: #d97706, `error`: #dc2626
   - Headings: Garamond with Georgia fallback, Body: Arial
   - Add optional `institution` block: `{ "name": "UCSF", "full_name": "University of California, San Francisco" }`

2. **Register in talk/index.json** with description: "UCSF institutional palette: navy/blue, Garamond headings"

3. **Add option E to slides.md D1 question**:
   ```
   E) UCSF Institutional - Navy/blue palette, Garamond serif headings (UCSF presentations)
   ```

4. **Add file path to extensions.json** installed_files array

5. **CSS prefix convention**: When implemented, use `--ucsf-` prefix for CSS custom properties (following `--ac-` pattern from academic-clean)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary implementation | completed | high |
| B | Alternative approaches | completed | high |
| C | Critic (gaps/risks) | completed | high |
| D | Strategic horizons | completed | medium |

## References

- PPTX source: `examples/test-files/UCSF_ZSFG_Template_16x9.pptx`
- Existing themes: `.claude/context/project/present/talk/themes/academic-clean.json`, `clinical-teal.json`
- Talk library index: `.claude/context/project/present/talk/index.json`
- Slides command: `.claude/commands/slides.md` (D1 question at lines 335-342)
- Extensions registry: `.claude/extensions.json` (installed_files at lines 60-62)
- CSS mapping example: `examples/epi-slides/theme/styles/index.css`
