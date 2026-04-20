# Research Report: PPTX Context Files for Slides-Agent

- **Task**: 38 - pptx_context_files
- **Started**: 2026-04-12T12:00:00Z
- **Completed**: 2026-04-12T12:45:00Z
- **Effort**: ~45 minutes
- **Dependencies**: None
- **Sources/Inputs**:
  - Codebase exploration of `.claude/context/project/present/talk/` (themes, patterns, components, templates)
  - Slides-agent definition (`.claude/agents/slides-agent.md`)
  - Presentation-agent definition (`.claude/agents/presentation-agent.md`)
  - Filetypes extension patterns (`project/filetypes/patterns/presentation-slides.md`)
  - python-pptx 1.0.0 official documentation (readthedocs)
  - Web search for python-pptx generation patterns
- **Artifacts**:
  - `specs/038_pptx_context_files/reports/01_pptx-context.md` (this report)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Executive Summary

- The talk library at `.claude/context/project/present/talk/` has a well-structured system with three themes (academic-clean, clinical-teal, ucsf-institutional), four talk mode patterns, content templates, and five Vue components -- all targeting Slidev output.
- No PPTX generation context files exist yet. The existing `presentation-slides.md` covers python-pptx for *extraction* only, not generation.
- Three deliverables are needed: (1) a `pptx-project/` template directory parallel to `slidev-project/`, (2) theme mapping files translating the JSON themes to PPTX master slide specs, and (3) a `pptx-generation.md` pattern document for the slides-agent.
- python-pptx provides full API coverage for programmatic PPTX creation: slide layouts, RGBColor/font formatting, tables, images, speaker notes, and placeholder manipulation. The "template PPTX" approach (starting from a styled blank deck) is the recommended pattern for theme consistency.
- The Vue components (DataTable, FigurePanel, CitationBlock, StatResult, FlowDiagram) each need equivalent python-pptx generation functions that produce the same visual output using shapes, tables, and text formatting.

## Context & Scope

The task is to create context files that guide the slides-agent when producing PowerPoint (.pptx) output instead of Slidev. Currently the slides-agent exclusively produces Slidev markdown mapped to slide patterns. Adding PPTX output requires:

1. **Template directory** (`talk/templates/pptx-project/`) -- a starter PPTX template or Python generation script
2. **Theme mappings** -- translating the existing JSON theme definitions (colors, fonts, spacing) to python-pptx RGBColor values, font names, and layout constants
3. **Pattern document** (`talk/patterns/pptx-generation.md`) -- documenting the python-pptx API patterns the agent should use for slide creation, tables, figures, notes, etc.

### Constraints

- Task type is `meta` -- deliverables are context/documentation files only, not runnable code
- Must parallel the existing Slidev template structure for consistency
- Must map all five Vue component equivalents to python-pptx patterns
- The slides-agent reads these context files on-demand via `@`-references

## Findings

### 1. Existing Talk Library Structure

The talk library at `.claude/context/project/present/talk/` contains:

```
talk/
  index.json                          # Library manifest
  themes/
    academic-clean.json               # Blue accent, serif headings
    clinical-teal.json                # Teal accent, sans-serif headings
    ucsf-institutional.json           # Navy/Pacific Blue, Garamond headings
  patterns/
    conference-standard.json          # 12-slide CONFERENCE pattern
    seminar-deep-dive.json            # 35-slide SEMINAR pattern
    defense-grant.json                # 30-slide DEFENSE pattern
    journal-club.json                 # 12-slide JOURNAL_CLUB pattern
    slidev-pitfalls.md                # Slidev-specific gotchas
  contents/
    title/title-standard.md           # Title slide template
    title/title-institutional.md      # Institutional title variant
    motivation/motivation-gap.md      # Research question framing
    motivation/motivation-clinical.md # Clinical motivation variant
    methods/methods-study-design.md   # Study design slide
    methods/methods-flowchart.md      # CONSORT/STROBE flowchart
    methods/methods-analysis.md       # Analysis plan slide
    results/results-table.md          # DataTable-based results
    results/results-figure.md         # FigurePanel-based results
    results/results-forest-plot.md    # Forest plot slide
    results/results-kaplan-meier.md   # KM curve slide
    discussion/discussion-comparison.md
    conclusions/conclusions-takeaway.md
    conclusions/limitations-standard.md
    acknowledgments/acknowledgments-funding.md
    acknowledgments/questions-contact.md
  components/
    FigurePanel.vue                   # Image with caption/source
    DataTable.vue                     # Formatted data table
    CitationBlock.vue                 # Inline literature reference
    StatResult.vue                    # Statistical result display
    FlowDiagram.vue                   # CONSORT participant flow
  templates/
    slidev-project/                   # Slidev starter files
      package.json
      .npmrc
      vite.config.ts
      lz-string-esm.js
      README.md
    playwright-verify.mjs             # Slide verification script
```

### 2. Theme Definitions and PPTX Mapping

Each theme JSON defines: `palette` (10 colors), `typography` (3 font families, weights, sizes), `spacing`, `borders`, and `footer` styles. These map to PPTX concepts as follows:

#### Color Mapping (CSS hex -> python-pptx RGBColor)

| Theme Property | PPTX Equivalent | python-pptx API |
|---|---|---|
| `palette.background` | Slide background fill | `slide.background.fill.solid()` + `.fore_color.rgb` |
| `palette.text` | Default body text color | `run.font.color.rgb = RGBColor(...)` |
| `palette.heading` | Title placeholder font color | `run.font.color.rgb` on title shapes |
| `palette.accent` | Accent bar, table header border, citation border | `RGBColor(...)` on shape fills/borders |
| `palette.accent_light` | Highlighted row background | Cell fill color |
| `palette.muted` | Caption text, footnotes | `run.font.color.rgb` |
| `palette.highlight` | Hyperlinks, emphasis | `run.font.color.rgb` |

#### Typography Mapping

| Theme Property | PPTX Equivalent | python-pptx API |
|---|---|---|
| `heading_font` | Title font name | `run.font.name = "Georgia"` (first in CSS fallback chain) |
| `body_font` | Body text font name | `run.font.name = "Helvetica Neue"` |
| `code_font` | Code/stat text font name | `run.font.name = "Courier New"` |
| `heading_weight: "700"` | Bold title | `run.font.bold = True` |
| `heading_size: "2rem"` | Title font size | `run.font.size = Pt(32)` (2rem ~ 32pt at 16px base) |
| `body_size: "1.1rem"` | Body font size | `run.font.size = Pt(18)` (1.1rem ~ 17.6pt) |
| `caption_size: "0.85rem"` | Caption font size | `run.font.size = Pt(14)` (0.85rem ~ 13.6pt) |

**Font fallback**: CSS font stacks (e.g., `"Georgia, 'Times New Roman', serif"`) should use the *first* font in PPTX since PowerPoint handles its own fallback. For clinical-teal, `"Segoe UI"` is Windows-native; on macOS/Linux, `"Helvetica Neue"` is the equivalent.

#### Spacing Mapping

| Theme Property | PPTX Equivalent | python-pptx API |
|---|---|---|
| `slide_padding: "2rem 3rem"` | Content area margins | `left=Inches(0.75), top=Inches(0.5)` (adjusted for 10x7.5 slide) |
| `section_gap: "1.5rem"` | Space between shapes | Vertical offset between placed shapes |
| `element_gap: "0.75rem"` | Space within sections | `paragraph.space_after = Pt(9)` |

### 3. Vue Component to python-pptx Equivalents

Each Vue component needs a python-pptx generation pattern:

#### DataTable -> `add_pptx_table()`

The DataTable Vue component renders a formatted table with optional row highlighting and caption. The python-pptx equivalent:
- Uses `slide.shapes.add_table(rows, cols, left, top, width, height)`
- Sets header row background fill to `accent_light` color
- Sets header row border-bottom to `accent` color (2pt)
- Applies `body_font` to all cells
- Highlights specified row with `accent_light` background
- Adds caption as a separate text box below the table

#### FigurePanel -> `add_pptx_figure()`

The FigurePanel displays an image with caption and source. The python-pptx equivalent:
- Uses `slide.shapes.add_picture(image_path, left, top, width, height)`
- Centers image on slide with scaling factor
- Adds caption text box below image in `caption_size` font
- Adds optional source text box in italic, smaller font

#### CitationBlock -> `add_pptx_citation()`

The CitationBlock renders a bordered reference box. The python-pptx equivalent:
- Creates a text box with left border (accent color, 3pt)
- Background fill with light gray (`#f8fafc`)
- First paragraph: bold author + gray "(year, *journal*)"
- Second paragraph: italic finding text

#### StatResult -> `add_pptx_stat_result()`

The StatResult displays a formatted statistical result. The python-pptx equivalent:
- Creates a text box with monospace font (`code_font`)
- Light background fill
- Formats: bold test name, blue value, gray CI, and red p-value if significant
- Uses `run.font.color.rgb` for per-segment coloring within a paragraph

#### FlowDiagram -> `add_pptx_flow_diagram()`

The FlowDiagram shows a CONSORT-style participant flow. The python-pptx equivalent:
- Creates auto shapes (rounded rectangles) for each stage box
- Connects with arrow connectors between boxes
- Adds exclusion boxes (yellow background) branching right from connectors
- Uses `slide.shapes.add_shape()` and `slide.shapes.add_connector()`

### 4. python-pptx API Patterns for Generation

Key patterns from the python-pptx documentation:

#### Presentation and Slide Creation

```python
from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR

prs = Presentation()  # or Presentation("template.pptx")
prs.slide_width = Inches(13.333)   # 16:9 widescreen
prs.slide_height = Inches(7.5)

# Standard layouts: 0=Title, 1=Title+Content, 5=Title Only, 6=Blank
layout = prs.slide_layouts[6]  # Blank for maximum control
slide = prs.slides.add_slide(layout)
```

#### Speaker Notes

```python
notes_slide = slide.notes_slide
notes_tf = notes_slide.notes_text_frame
notes_tf.text = "Speaker notes content here"
```

#### Table Creation

```python
table_shape = slide.shapes.add_table(
    rows=5, cols=4,
    left=Inches(0.75), top=Inches(2.0),
    width=Inches(8.5), height=Inches(3.0)
)
table = table_shape.table

# Set cell content
cell = table.cell(0, 0)
cell.text = "Header"

# Format header row
for col_idx in range(4):
    cell = table.cell(0, col_idx)
    cell.fill.solid()
    cell.fill.fore_color.rgb = RGBColor(0xEB, 0xF0, 0xF9)
    for para in cell.text_frame.paragraphs:
        for run in para.runs:
            run.font.bold = True
            run.font.size = Pt(14)
```

#### Image Insertion

```python
slide.shapes.add_picture(
    image_path,
    left=Inches(1.5), top=Inches(1.5),
    width=Inches(7.0)  # height auto-calculated from aspect ratio
)
```

#### Text Box with Formatting

```python
txBox = slide.shapes.add_textbox(
    left=Inches(0.75), top=Inches(1.0),
    width=Inches(8.5), height=Inches(0.5)
)
tf = txBox.text_frame
tf.word_wrap = True

p = tf.paragraphs[0]
p.alignment = PP_ALIGN.LEFT
run = p.add_run()
run.text = "Heading text"
run.font.name = "Georgia"
run.font.size = Pt(32)
run.font.bold = True
run.font.color.rgb = RGBColor(0x16, 0x21, 0x3E)
```

### 5. Template PPTX Approach

The recommended approach for the `pptx-project/` template is to use a **blank template PPTX** file pre-configured with:
- 16:9 aspect ratio (13.333 x 7.5 inches)
- Custom slide layouts in the master:
  - Layout 0: Title slide (centered title, subtitle, affiliations)
  - Layout 1: Content slide (title at top, body area below)
  - Layout 2: Section divider (centered section title)
  - Layout 3: Blank (for custom shape placement)
  - Layout 4: Two-column (side-by-side content areas)

However, since we cannot ship a binary `.pptx` file as a context file (context files are text), the template should instead be a **Python generation script** (`generate_template.py`) that creates the base PPTX with themed layouts programmatically. This parallels how `slidev-project/` ships text files (package.json, etc.) rather than a pre-built project.

### 6. Existing Patterns for Template Organization

The `slidev-project/` template directory establishes the pattern:
- Self-contained directory under `talk/templates/`
- `README.md` explaining usage and contents
- Template files are copied to a new project directory
- Version tracking in a metadata field

The `pptx-project/` directory should follow the same pattern with:
- `README.md` -- Usage instructions
- `generate_deck.py` -- Main generation script (theme-aware)
- `theme_mappings.json` -- Theme color/font/layout constants for all three themes

## Decisions

1. **Template format**: Use a Python generation script rather than a binary `.pptx` template file, since context files should be text-based and version-controllable.
2. **Theme mapping location**: Create `theme_mappings.json` inside `pptx-project/` containing PPTX-specific constants derived from all three theme JSON files, rather than modifying the existing theme JSONs.
3. **Slide dimensions**: Use 16:9 widescreen (13.333 x 7.5 inches) as the standard, matching modern Slidev defaults.
4. **Layout strategy**: Use `prs.slide_layouts[6]` (Blank) as the primary layout and place all content programmatically for maximum control, rather than relying on PowerPoint's built-in placeholder system.
5. **Component equivalents**: Document five python-pptx helper functions corresponding to the five Vue components, using the same prop interfaces where possible.
6. **Font sizing**: Convert CSS rem units to PowerPoint points using the ratio 1rem = 16pt (matching the standard 16px browser base).

## Recommendations

### Deliverable 1: `talk/templates/pptx-project/`

Create the following files:

| File | Purpose |
|------|---------|
| `README.md` | Usage instructions, theme selection, copy workflow |
| `generate_deck.py` | Skeleton Python script for theme-aware PPTX generation |
| `theme_mappings.json` | All three themes mapped to PPTX constants (RGBColor hex, font names, Pt sizes, Inches positions) |

### Deliverable 2: `talk/patterns/pptx-generation.md`

Create a pattern document covering:

1. **Imports and setup** -- standard python-pptx imports, unit helpers
2. **Slide creation** -- layout selection, blank slide pattern
3. **Theme application** -- loading theme_mappings.json, applying colors/fonts
4. **Component patterns** -- five helper functions (table, figure, citation, stat result, flow diagram)
5. **Speaker notes** -- adding notes to every slide
6. **Export** -- saving the final PPTX file
7. **Error handling** -- missing images, font fallback, table overflow

### Deliverable 3: Update `talk/index.json`

Add entries for the new pptx-project template and pptx-generation pattern in the library manifest.

### Priority Order

1. `pptx-generation.md` (highest value -- directly guides the slides-agent)
2. `pptx-project/theme_mappings.json` (concrete theme data the generation patterns reference)
3. `pptx-project/generate_deck.py` (skeleton script)
4. `pptx-project/README.md`
5. Update `talk/index.json`

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Font availability across platforms | Medium | Medium | Use only widely available fonts (Georgia, Arial, Courier New); document platform-specific font names in theme_mappings.json |
| python-pptx not installed in user environment | Medium | High | Document `pip install python-pptx` requirement; slides-agent should check availability before attempting generation |
| FlowDiagram connector rendering varies across PowerPoint versions | Low | Low | Use simple straight connectors; avoid complex routing |
| Binary PPTX template would be more reliable than programmatic generation | Medium | Medium | The generation script approach trades some visual fidelity for text-based version control; if precision is critical, a future enhancement could add a binary template |

## Appendix

### Web Search Queries Used

- "python-pptx create presentation programmatically slide layouts master slides theme colors fonts 2025"
- "python-pptx RGBColor MSO_THEME_COLOR custom theme slide master font color table formatting speaker notes"
- "python-pptx add table to slide speaker notes image insertion Inches Pt Emu formatting best practices"

### Key References

- [python-pptx Working with Slides](https://python-pptx.readthedocs.io/en/latest/user/slides.html)
- [python-pptx Working with Presentations](https://python-pptx.readthedocs.io/en/latest/user/presentations.html)
- [python-pptx Working with Tables](https://python-pptx.readthedocs.io/en/latest/user/table.html)
- [python-pptx Working with Notes Slides](https://python-pptx.readthedocs.io/en/latest/user/notes.html)
- [python-pptx Font Color Analysis](https://python-pptx.readthedocs.io/en/latest/dev/analysis/txt-font-color.html)
- [python-pptx MSO_THEME_COLOR_INDEX](https://python-pptx.readthedocs.io/en/latest/api/enum/MsoThemeColorIndex.html)
- [python-pptx Concepts](https://python-pptx.readthedocs.io/en/latest/user/concepts.html)
- [python-pptx Slide Layout Analysis](https://python-pptx.readthedocs.io/en/latest/dev/analysis/sld-layout.html)

### Codebase Files Examined

- `.claude/context/project/present/talk/index.json`
- `.claude/context/project/present/talk/themes/academic-clean.json`
- `.claude/context/project/present/talk/themes/clinical-teal.json`
- `.claude/context/project/present/talk/themes/ucsf-institutional.json`
- `.claude/context/project/present/talk/patterns/conference-standard.json`
- `.claude/context/project/present/talk/patterns/slidev-pitfalls.md`
- `.claude/context/project/present/talk/contents/title/title-standard.md`
- `.claude/context/project/present/talk/contents/results/results-table.md`
- `.claude/context/project/present/talk/components/DataTable.vue`
- `.claude/context/project/present/talk/components/FigurePanel.vue`
- `.claude/context/project/present/talk/components/CitationBlock.vue`
- `.claude/context/project/present/talk/components/StatResult.vue`
- `.claude/context/project/present/talk/components/FlowDiagram.vue`
- `.claude/context/project/present/talk/templates/slidev-project/README.md`
- `.claude/context/project/present/talk/templates/slidev-project/package.json`
- `.claude/context/project/present/patterns/talk-structure.md`
- `.claude/context/project/filetypes/patterns/presentation-slides.md`
- `.claude/agents/slides-agent.md`
- `.claude/agents/presentation-agent.md`
- `.claude/skills/skill-slides/SKILL.md`
