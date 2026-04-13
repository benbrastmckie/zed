# Teammate D Findings: Strategic Horizons

## Key Findings

### 1. Theme System Architecture (Current State)

Two themes exist: `academic-clean.json` and `clinical-teal.json`. Both share an identical schema. Neither has an `institution` field or `brand_assets` section. The schema is generic/visual, not institution-aware.

### 2. The Two "Phantom" Themes

The D1 design question lists four options but only A and B have backing JSON files. Options C (Conference Bold) and D (Minimal Dark) are aspirational. No runtime guard against selecting a non-existent theme exists.

### 3. title-institutional.md Already Exists

`talk/contents/title/title-institutional.md` provides an institutional title slide template with `{{institution_logo}}` and `{{institution_name}}` slots. It instructs: "Use official institutional branding colors if available." This template pairs naturally with the UCSF theme but does not need modification.

### 4. Registration Points (Three Required, One Optional)

1. **Create**: `talk/themes/ucsf-institutional.json`
2. **Edit**: `talk/index.json` — add item to categories.themes.items[]
3. **Edit**: `slides.md` — add option E in D1 question
4. **Optional**: `extensions.json` — add file path to installed_files list

### 5. PPTX-to-Theme Pipeline (Future Direction)

The `/convert` command has no `--extract-theme` mode. Manual extraction is the practical path for task 36. A future `/convert --extract-theme` extension is architecturally feasible via `python-pptx` but out of scope.

### 6. Theme Scalability

The `talk/index.json` themes category is a flat array. At 3 themes it's manageable. At 5-10 themes, a `category` sub-field (e.g., `"category": "institutional"` vs `"category": "visual"`) would enable categorized presentation. This is the right time to introduce it as a non-breaking additive change.

## Recommended Approach

### Schema Addition: Optional `institution` Block

The UCSF theme could include an additive `institution` block:

```json
"institution": {
  "name": "UCSF",
  "full_name": "University of California, San Francisco"
}
```

This is non-breaking — existing code reading `academic-clean.json` won't see this key. Future agents can check for it when building institutional slides.

### Category Field in index.json

Add `"category": "institutional"` to the new theme item and retroactively mark existing themes `"category": "visual"`. Sets the pattern for future institutional themes without breaking anything.

### Phantom Theme Handling

Task 36 should add UCSF as option E without touching C/D (minimal scope). The phantom theme issue is a separate bug. However, note it in the research synthesis as a known issue for a future task.

### No PPTX Extract Pipeline Now

Out of scope. A note in the theme file's description documenting the PPTX source would establish provenance for future reference.

## Evidence/Examples

- Theme schema: `academic-clean.json` (46 lines) and `clinical-teal.json` (same structure)
- Index registration: `talk/index.json` lines 8-13 (items array)
- Phantom themes: `slides.md` lines 335-342 (C/D without files)
- Institutional template: `talk/contents/title/title-institutional.md` (generic institutional slots)
- Extensions registry: `extensions.json` lines 111-112 list theme file paths
- Theme discovery: `talk/themes/` is NOT individually indexed in `context/index.json`

## Confidence Level

**High** on factual audit (registration points, phantom themes, title-institutional.md). **Medium** on schema recommendations (institution block, category field). **Low** on PPTX pipeline timeline.
