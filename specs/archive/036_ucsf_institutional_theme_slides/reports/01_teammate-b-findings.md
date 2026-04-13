# Teammate B Findings: UCSF Institutional Theme - Alternative Approaches

**Task**: 036 - Add UCSF institutional theme to slides workflow
**Role**: Teammate B (Alternative Approaches)
**Focus**: PPTX layout patterns, theme consumption mechanics, extended theme properties

---

## Key Findings

### 1. PPTX Color Palette (from `theme1.xml` — "UCSF Classic" color scheme)

The PPTX contains a formally named color scheme called "UCSF 1" within the "UCSF Classic" theme:

| Role | Hex | Name |
|------|-----|------|
| Primary dark (navy) | `#052049` | UCSF Navy (dk1/tx1) |
| Primary light | `#FFFFFF` | White (lt1/bg1) |
| Accent 1 (blue) | `#0093D0` | UCSF Pacific Blue |
| Accent 2 (teal) | `#16A0AC` | UCSF Teal (+ variant `#18A3AC`) |
| Accent 3 (green) | `#32A03E` | UCSF Green |
| Accent 4 (purple) | `#A238BA` | UCSF Purple |
| Accent 5 (magenta) | `#C32882` | UCSF Magenta |
| Accent 6 (indigo) | `#6C61D0` | UCSF Indigo |
| Hyperlink | `#178CCB` | UCSF Link Blue |
| Quote accent | `#90BD31` | Lime green (hardcoded in Quote layouts) |

**Typography**: majorFont = Garamond (headings), minorFont = Arial (body). Brand guidelines specify Garamond 36pt headers, Arial 18pt sub-headers, Arial 22pt content body; minimum 14pt.

### 2. The 42 Slide Layouts Map to 5 Functional Categories

The template has two slide masters (Classic and Contemporary):

**Cover slides** (9 variants): White, Teal, Blue, Navy, Purple, Blue1, Blue2, Teal2, Navy — all use full-bleed color backgrounds against the UCSF color scheme. The Navy cover (`slideLayout19`) places title at 1.23in from top, subtitle at 2.76in, presenter name at 3.67in.

**Content slides** (6 variants): Bullet, Chart, Two Column, Blank — available in both White and Navy backgrounds. Two Column slides use equal 50/50 column split with optional subhead.

**Section Dividers** (3 variants): Navy (`scheme:tx1` = `#052049`), Teal (`scheme:accent2` = `#16A0AC`), Blue (`scheme:accent1` = `#0093D0`) — full-background colored dividers.

**Section Headers** (3 variants): Blue, Teal, Green — side-bar or stripe header variants.

**Quote Slides** (5 variants): Navy, Teal, Blue, Green — colored background with accent lime stripe.

**Specialty Closings** (5 variants): Two generic logo closings + three institutional mission closings (Research, Education, Patient Care) — these use embedded JPEG photography backgrounds (25–500KB) with the UCSF logo overlay (EMF vector format).

### 3. How Theme JSON Values Are Actually Consumed

The CSS variable mapping from `academic-clean.json` to `theme/styles/index.css` in the epi-slides example is direct and manual — an implementer reads the JSON and creates corresponding CSS custom properties. Key pattern:

- JSON `palette.background` → CSS `--ac-bg: #ffffff`
- JSON `palette.accent` → CSS `--ac-accent: #3b5998` (used for `border-bottom` on h1, table headers)
- JSON `typography.heading_font` → CSS `--ac-heading-font: Georgia, ...`
- JSON `borders.accent_bar` → CSS border declarations on h1 elements
- JSON `palette.accent_light` → CSS `--ac-accent-light` used for code blocks and callout backgrounds

The theme prefix convention is `--ac-` for academic-clean. A UCSF theme should use `--ucsf-` or `--ui-` as its prefix.

**The CSS is NOT auto-generated** — it must be manually authored in `theme/styles/index.css`. The JSON serves as a reference specification for the implementer, not a runtime data source.

### 4. Theme Registration Has Three Required Steps

A new theme must be registered in all three of these locations:

1. **Theme JSON file**: `.claude/context/project/present/talk/themes/ucsf-institutional.json` — the specification document
2. **`talk/index.json` items array**: Add entry to `categories.themes.items` array with `name`, `file`, and `description`
3. **`extensions.json` installed_files**: Add the path `.claude/context/project/present/talk/themes/ucsf-institutional.json` at position 62 (after existing themes)
4. **`/slides --design` D1 prompt**: Add option E in `slides.md` command to present the UCSF theme choice to users

The slides-agent reads the research report's "Recommended Theme" section but only has access to themes in `talk/index.json`. If `ucsf-institutional` isn't listed there, the agent can't recommend it.

### 5. UCSF-Specific Theme Properties Beyond Existing Themes

The existing themes (`academic-clean`, `clinical-teal`) have 5 sections: `palette`, `typography`, `spacing`, `borders`, `footer`. UCSF's institutional branding complexity justifies additional sections:

**Additional sections to consider**:
- `variants`: sub-theme names (navy, white, teal) for cover/divider slide background selection
- `logo`: placement guidance (UCSF logo required on cover/closing slides)
- `institutional_footer`: standard footer text ("UCSF | Department of X")
- `slide_layouts`: mapping of PPTX layout names to Slidev layout Vue component names

### 6. The epi-slides Theme Has 5 Vue Layout Components

The existing `academic-clean` theme in `examples/epi-slides/theme/layouts/` provides:
- `title.vue` — cover with gradient from white to `#ebf0f9`
- `default.vue` — content slide with footer
- `section.vue` — dark blue (`#16213e`) section divider
- `two-column.vue` — 50/50 grid layout
- `caveat.vue` — banner + body layout

A UCSF theme would need equivalent layouts but using UCSF Navy (`#052049`) for section slides instead of `#16213e`.

---

## Recommended Approach

### JSON Schema (Extended)

```json
{
  "name": "ucsf-institutional",
  "description": "UCSF institutional theme extracted from UCSF_ZSFG_Template_16x9.pptx",
  "use_case": "UCSF/ZSFG institutional presentations, grand rounds, departmental seminars",
  "palette": {
    "background": "#ffffff",
    "text": "#052049",
    "heading": "#052049",
    "accent": "#0093D0",
    "accent_light": "#e8f4fb",
    "muted": "#5a6a7a",
    "highlight": "#0093D0",
    "navy": "#052049",
    "teal": "#16A0AC",
    "green": "#32A03E",
    "purple": "#A238BA",
    "magenta": "#C32882",
    "success": "#32A03E",
    "warning": "#d97706",
    "error": "#dc2626"
  },
  "typography": {
    "heading_font": "Garamond, Georgia, 'Times New Roman', serif",
    "body_font": "Arial, 'Helvetica Neue', sans-serif",
    "code_font": "'Courier New', monospace",
    "heading_weight": "700",
    "body_weight": "400",
    "heading_size": "2.25rem",
    "body_size": "1.1rem",
    "caption_size": "0.875rem"
  },
  "spacing": {
    "slide_padding": "2rem 3rem",
    "section_gap": "1.5rem",
    "element_gap": "0.75rem"
  },
  "borders": {
    "divider": "1px solid #d1dbe8",
    "accent_bar": "3px solid #0093D0",
    "table_header": "2px solid #0093D0",
    "navy_bar": "4px solid #052049"
  },
  "footer": {
    "custom_footer_style": "margin-top: 1.5rem; font-size: 0.75rem; color: #5a6a7a; display: flex; justify-content: space-between;",
    "positioning": "flow (margin-top), sits above Slidev built-in footer bar",
    "institutional_text": "UCSF | Zuckerberg San Francisco General"
  },
  "variants": {
    "cover_default": "navy",
    "available_covers": ["white", "navy", "teal", "blue"],
    "section_default": "navy",
    "available_sections": ["navy", "teal", "blue", "green"]
  },
  "logo": {
    "placement": "top-right or top-left on cover slides",
    "asset_note": "Place UCSF logo at public/ucsf-logo.png in project",
    "required_on": ["cover", "closing"]
  },
  "slidev_config": {
    "theme": "none",
    "highlighter": "shiki",
    "css": "unocss"
  }
}
```

### Registration Steps (Ordered)

1. Create `ucsf-institutional.json` at `.claude/context/project/present/talk/themes/`
2. Update `talk/index.json` categories.themes.items array
3. Update `extensions.json` installed_files array (after position 61)
4. Update `/slides --design` D1 theme question to add option E
5. (Optional) Create `examples/ucsf-slides/theme/` with UCSF-specific Vue layouts

### Vue Layout Recommendations for a Full UCSF Theme

| Layout | Background | Key Feature |
|--------|-----------|-------------|
| `title.vue` | Navy `#052049` or White | UCSF logo slot, teal accent bar |
| `default.vue` | White | Navy h1 underline, UCSF footer |
| `section.vue` | Navy `#052049` | White text, teal accent bar |
| `two-column.vue` | White | Pacific Blue column separators |
| `closing.vue` | White + logo | For basic institutional closing |

---

## Evidence / Examples

### Direct Evidence from PPTX Extraction

- `theme1.xml` → official UCSF color scheme confirmed (8 accent colors + navy + white)
- 43 layout XML files → layout taxonomy fully enumerated above
- `slideMaster2.xml` → Contemporary master uses `#052049` + `#18A3AC` directly (not via scheme refs)
- Slide 5 text → confirms Garamond/Arial typography + min 14pt rule
- Slide 3 text → "Classic" vs "Contemporary" sub-themes (Classic = white-primary, Contemporary = colorful)
- Closing layout rels → specialty closings (Research/Education/Patient Care) embed JPEG photography

### Direct Evidence from Codebase

- `examples/epi-slides/theme/styles/index.css:1` → "Palette sourced from .claude/context/project/present/talk/themes/academic-clean.json" — confirms manual JSON→CSS mapping
- `examples/epi-slides/theme/styles/index.css:6-21` → CSS variable convention `--ac-*` for academic-clean
- `.claude/context/project/present/talk/index.json:9-12` → `categories.themes.items` is the registration point
- `.claude/extensions.json:60-61` → installed_files is second registration point
- `.claude/commands/slides.md:335-341` → D1 design question lists themes A-D (current gap: UCSF not listed)
- `.claude/commands/slides.md:384-393` → design_decisions.theme stored in state.json task metadata

### Gap Analysis

The `/slides --design` D1 prompt currently lists 4 themes (Academic Clean, Clinical Teal, Conference Bold, Minimal Dark). However:
- `Conference Bold` and `Minimal Dark` have no corresponding JSON files in `themes/` — they are aspirational placeholders
- Only `academic-clean.json` and `clinical-teal.json` exist as actual files
- Adding `ucsf-institutional` completes the first truly institutional theme with real PPTX provenance

---

## Confidence Level

**High confidence (directly verified)**:
- Exact UCSF hex color values from `theme1.xml`
- Typography specification (Garamond heading / Arial body) from `theme1.xml` + slide 5 text
- 42 layout names and their color scheme relationships
- JSON→CSS mapping pattern from epi-slides example
- Three required registration locations (theme JSON, talk/index.json, extensions.json)
- Slides command D1 gap (no UCSF option presented to user)

**Medium confidence (inferred from patterns)**:
- Extended JSON sections (`variants`, `logo`, `footer.institutional_text`) are recommendations — no existing theme uses these, so they add forward-looking structure
- CSS variable prefix convention (`--ucsf-`) follows `--ac-` precedent but is not mandated anywhere
- Vue layout component names and structure follow epi-slides pattern

**Lower confidence (requires Teammate A coordination)**:
- Whether `Conference Bold` and `Minimal Dark` are planned themes that Teammate A intends to implement — if so, ucsf-institutional should use position E not C
- Whether the Slidev theme directory should live under `examples/` (as epi-slides does) or be purely context-JSON-based
