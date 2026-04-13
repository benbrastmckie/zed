# Teammate A Findings: Primary Implementation Approach

## Key Findings

### Theme JSON Schema (from existing themes)

Both `academic-clean.json` and `clinical-teal.json` share identical top-level structure:
- `name`, `description`, `use_case`
- `palette`: background, text, heading, accent, accent_light, muted, highlight, success, warning, error
- `typography`: heading_font, body_font, code_font, heading_weight, body_weight, heading_size, body_size, caption_size
- `spacing`: slide_padding, section_gap, element_gap
- `borders`: divider, accent_bar, table_header
- `footer`: custom_footer_style, positioning
- `slidev_config`: theme, highlighter, css

### UCSF Color Mapping to Theme Schema

From PPTX theme XML (`theme1.xml`), "UCSF Classic" with color scheme "UCSF 1":

| PPTX Color | Hex | -> Schema Field |
|-----------|-----|-----------------|
| dk1/dk2 (navy) | #052049 | `heading` (dark navy headings) |
| lt1/lt2 (white) | #FFFFFF | `background` |
| accent1 (bright blue) | #0093D0 | `accent` (primary accent) |
| accent2 (teal) | #16A0AC | `highlight` (secondary interactive) |
| accent3 (green) | #32A03E | `success` |
| accent4 (purple) | #A238BA | (extra, not in base schema) |
| accent5 (pink) | #C32882 | `error` (strong signal color) |
| accent6 (violet) | #6C61D0 | (extra, not in base schema) |
| hyperlink | #178CCB | (for link styling guidance) |

Derived values:
- `text`: #1a202c (dark gray, matching clinical-teal pattern — pure navy #052049 may be too dark for body text)
- `accent_light`: #e6f2fa (light wash of accent blue #0093D0)
- `muted`: #5f6b7a (gray for captions, footers)
- `warning`: #d97706 (amber, consistent with existing themes)

### Typography Mapping

- **heading_font**: `Garamond, Georgia, 'Times New Roman', serif` — Garamond is the PPTX heading font; Georgia as fallback
- **body_font**: `Arial, 'Helvetica Neue', sans-serif` — Arial is the PPTX body font
- **code_font**: `'Courier New', monospace` — consistent with existing themes
- **heading_weight**: `700` (bold, matching PPTX title text)
- **body_weight**: `400`
- Sizes match existing themes: 2rem headings, 1.1rem body, 0.85rem captions

### Proposed ucsf-institutional.json

```json
{
  "name": "ucsf-institutional",
  "description": "UCSF institutional theme with navy/blue palette, Garamond headings, and Arial body",
  "use_case": "UCSF presentations, institutional talks, departmental meetings, grand rounds",
  "palette": {
    "background": "#ffffff",
    "text": "#1a202c",
    "heading": "#052049",
    "accent": "#0093D0",
    "accent_light": "#e6f2fa",
    "muted": "#5f6b7a",
    "highlight": "#16A0AC",
    "success": "#32A03E",
    "warning": "#d97706",
    "error": "#C32882"
  },
  "typography": {
    "heading_font": "Garamond, Georgia, 'Times New Roman', serif",
    "body_font": "Arial, 'Helvetica Neue', sans-serif",
    "code_font": "'Courier New', monospace",
    "heading_weight": "700",
    "body_weight": "400",
    "heading_size": "2rem",
    "body_size": "1.1rem",
    "caption_size": "0.85rem"
  },
  "spacing": {
    "slide_padding": "2rem 3rem",
    "section_gap": "1.5rem",
    "element_gap": "0.75rem"
  },
  "borders": {
    "divider": "1px solid #d1d5db",
    "accent_bar": "3px solid #0093D0",
    "table_header": "2px solid #052049"
  },
  "footer": {
    "custom_footer_style": "margin-top: 1.5rem; font-size: 0.8rem; color: #5f6b7a; display: flex; justify-content: space-between;",
    "positioning": "flow (margin-top), sits above Slidev built-in footer bar"
  },
  "slidev_config": {
    "theme": "none",
    "highlighter": "shiki",
    "css": "unocss"
  }
}
```

### Files Requiring Modification

1. **NEW**: `.claude/context/project/present/talk/themes/ucsf-institutional.json`
2. **EDIT**: `.claude/context/project/present/talk/index.json` — add theme to `categories.themes.items[]`
3. **EDIT**: `.claude/commands/slides.md` — add option E to D1 design question (~line 337)
4. **EDIT**: `.claude/extensions/present/manifest.json` or `.claude/extensions.json` — add theme file path to installed_files if required

### Files NOT Requiring Modification

- `talk-structure.md` — does not enumerate themes by name
- `context/index.json` — theme files are not individually indexed (discovered via talk/index.json)
- Agent files — no hardcoded theme name references found
- Content templates — theme-agnostic

## Recommended Approach

1. Create `ucsf-institutional.json` following the exact schema of existing themes
2. Register in `talk/index.json` categories.themes.items
3. Add option E to slides.md D1 question
4. Verify extensions.json lists the new file path

## Evidence/Examples

- `academic-clean.json`: 46-line theme with muted blue (#3b5998) accent, Georgia headings
- `clinical-teal.json`: 46-line theme with teal (#0d9488) accent, Segoe UI headings
- PPTX `theme1.xml`: Garamond major font, Arial minor font, 6-accent UCSF palette
- PPTX slide dimensions: 16:9 (9144000 x 5143500 EMU)

## Confidence Level

**High** — The theme schema is well-established with two existing examples. The color mapping from PPTX to JSON is straightforward. The integration points are minimal and well-defined.
