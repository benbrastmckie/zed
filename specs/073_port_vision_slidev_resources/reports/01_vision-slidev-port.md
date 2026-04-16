# Research Report: Port Vision Slidev Resources into Talk Library

**Task**: 73 - Port high-value Slidev resources from Vision repository into talk library
**Date**: 2026-04-16
**Status**: Complete

## Executive Summary

The Vision repository at `/home/benjamin/Projects/Logos/Vision/.context/deck/` contains a comprehensive Slidev presentation toolkit originally built for business/investor pitch decks. This report catalogs the high and medium value resources to port into this repository's academic talk library at `.claude/context/project/present/talk/`, details their current contents, identifies adaptation needs, and maps the index.json integration points.

## Current State of Talk Library

The talk library index (`index.json`) already declares `animations` and `styles` categories but with **null paths** pointing to a founder extension:

```json
"animations": {
  "path": null,
  "note": "Reference .claude/extensions/founder/context/project/founder/deck/animations/ directly"
},
"styles": {
  "path": null,
  "note": "Reference .claude/extensions/founder/context/project/founder/deck/styles/ for base styles"
}
```

This external reference approach is fragile -- the founder extension may not be loaded, and the path assumes a specific extension layout. Porting resources locally eliminates this dependency.

### Existing Talk Library Components (5)

| Component | File | Purpose |
|-----------|------|---------|
| FigurePanel | FigurePanel.vue | Research figure with caption/source |
| DataTable | DataTable.vue | Data table for results |
| CitationBlock | CitationBlock.vue | Citation formatting |
| StatResult | StatResult.vue | Statistical result display |
| FlowDiagram | FlowDiagram.vue | Study design flow diagrams |

These are research-domain-specific. The ported components serve different, complementary purposes.

---

## HIGH VALUE: Animation Pattern Library (6 files)

### Overview

Six reusable Slidev animation patterns covering the full spectrum from simple fades to complex cascades. These are **platform-level** resources -- equally applicable to academic and business presentations.

**Target path**: `talk/animations/`

### File Inventory

#### 1. `fade-in.md` -- CSS fade entrance
- **Trigger**: `v-click`
- **Complexity**: Low
- **Patterns**: Basic v-click fade, CSS transition with duration classes, `<v-clicks>` for lists
- **Academic use**: Default animation for any progressive content reveal

#### 2. `slide-in-below.md` -- Y-axis motion entrance
- **Trigger**: `v-motion`
- **Complexity**: Medium
- **Patterns**: Basic slide-up (y: 80 -> 0), spring physics variant (stiffness: 250, damping: 25), staggered group with delay increments
- **Academic use**: Section headers, key finding reveals

#### 3. `metric-cascade.md` -- Staggered KPI reveal
- **Trigger**: `v-motion`
- **Complexity**: High
- **Patterns**: 3-column grid with scale (0.8 -> 1) + opacity + y-offset, 300ms delay increments, AutoFitText for responsive sizing
- **Academic use**: Primary outcome metrics, key statistics display
- **Adaptation needed**: Replace business examples (ARR, MoM Growth) with academic examples (p-value, HR, NNT) in documentation

#### 4. `rough-marks.md` -- Hand-drawn text emphasis
- **Trigger**: `v-mark`
- **Complexity**: Medium
- **Patterns**: underline, circle, highlight, box, strike-through; color options (orange, red, yellow, blue, green, purple); `at` parameter for click synchronization
- **Academic use**: Highlighting key p-values, confidence intervals, significant findings
- **Dependency**: rough-notation library (bundled with Slidev)

#### 5. `scale-in-pop.md` -- Spring scale entrance
- **Trigger**: `v-motion`
- **Complexity**: Medium
- **Patterns**: Scale from 0 -> 1 with spring physics (stiffness: 300, damping: 20), overshoot bounce variant (damping: 15), delayed pop
- **Academic use**: Key conclusion reveals, funding amounts on acknowledgment slides

#### 6. `staggered-list.md` -- Progressive list reveal
- **Trigger**: `v-clicks`
- **Complexity**: Low
- **Patterns**: Basic `<v-clicks>` wrapper, `depth` for nested lists, `every` for grouped reveals, manual `v-click` indexing
- **Academic use**: Methods steps, inclusion/exclusion criteria, findings lists

### Adaptation Summary

All 6 files can be ported verbatim. Only `metric-cascade.md` benefits from adding academic use-case examples alongside the existing business examples.

---

## HIGH VALUE: Composable Style Architecture (9 CSS files)

### Overview

Nine standalone CSS files implementing a mix-and-match style system with three layers: colors (4), typography (3), and textures (2). Each file sets CSS custom properties that Slidev components consume via `var(--slidev-*)`.

**Target path**: `talk/styles/colors/`, `talk/styles/typography/`, `talk/styles/textures/`

### CSS Custom Property Schema

All color files define these variables:
```
--slidev-bg, --slidev-text, --slidev-text-secondary, --slidev-text-muted,
--slidev-accent, --slidev-accent-light, --slidev-border, --slidev-code-bg, --slidev-card-bg
```

All typography files define:
```
--slidev-font-heading, --slidev-font-body, --slidev-font-mono
```

Plus element selectors for h1/h2/h3 sizing and font-family application.

### Color Files (4)

#### 1. `dark-blue-navy.css`
- Palette: Navy bg (#1e293b), blue accent (#60a5fa), light text (#e2e8f0)
- Compatible with: dark-blue theme
- Academic use: Evening talks, conference presentations with dark rooms

#### 2. `dark-gold-premium.css`
- Palette: Near-black bg (#0f0f1a), gold accent (#d4a574), warm text (#e8e0d4)
- Compatible with: premium-dark theme
- Academic use: Award lectures, special presentations

#### 3. `light-green-growth.css`
- Palette: Mint bg (#f0fdf4), green accent (#38a169), dark green text (#047857)
- Compatible with: growth-green theme
- Academic use: Environmental health, sustainability research

#### 4. `light-blue-corp.css`
- Palette: White bg (#ffffff), blue accent (#2b6cb0), navy text (#1a365d)
- Compatible with: professional-blue theme
- Academic use: General academic presentations, institutional talks

### Typography Files (3)

#### 1. `montserrat-inter.css`
- Headings: Montserrat (bold, geometric), Body: Inter (clean)
- h1: 3em/700, h2: 2.25em/600, h3: 1.75em/600
- Academic use: Modern conference talks

#### 2. `playfair-inter.css`
- Headings: Playfair Display (serif, elegant), Body: Inter
- Same size hierarchy as montserrat-inter
- Academic use: Grand rounds, named lectures, humanities-adjacent talks

#### 3. `inter-only.css`
- All: Inter with tighter letter-spacing (-0.03em headings)
- h1 weight: 800 (vs 700 in others) for visual hierarchy without font change
- Academic use: Minimalist, data-heavy presentations

### Texture Files (2)

#### 1. `grid-overlay.css`
- Effect: Faint 40px grid lines via CSS gradients
- Includes light mode variant (`[data-color-schema="light"]`)
- Academic use: Technical/engineering presentations, methods-heavy talks

#### 2. `noise-grain.css`
- Effect: SVG fractalNoise film grain at 4% opacity via `::before` pseudo-element
- Handles z-index layering (overlay at z-index: 0, content at z-index: 1)
- Academic use: Editorial feel for journal club presentations

### Adaptation Summary

All 9 files can be ported verbatim. No business-specific content -- these are pure CSS presets. The existing talk library themes (academic-clean, clinical-teal, ucsf-institutional) will coexist as **monolithic theme files**, while the ported styles provide a **composable alternative**.

### Relationship to Existing Themes

The existing JSON theme files (e.g., `academic-clean.json`) define complete Slidev headmatter configurations including `themeConfig`. The ported CSS files are a different approach: they define only visual properties and can be composed together. Both systems should coexist:

- **Monolithic themes**: Quick selection, opinionated, complete
- **Composable styles**: Mix-and-match for custom looks (e.g., `playfair-inter.css` + `light-blue-corp.css` + `grid-overlay.css`)

---

## MEDIUM VALUE: Adaptable Vue Components (3 files)

### Overview

Three Vue components from the business deck that serve useful purposes in academic presentations when adapted.

**Target path**: `talk/components/`

### Component Details

#### 1. `ComparisonCol.vue`
- **Props**: `title` (string), `points` (string[]), `color` (CSS color, default: `var(--slidev-accent)`), `highlight` (boolean)
- **Template**: Rounded card with optional ring-2 border highlight, title in accent color, unordered list of points
- **Animation**: Wraps in `v-click` for click-to-reveal
- **Academic use cases**:
  - Treatment vs control group characteristics
  - Before/after intervention comparison
  - Study A vs Study B methodology comparison
  - Strengths vs Limitations columns
- **Adaptation needed**: None -- generic enough as-is

#### 2. `MetricCard.vue`
- **Props**: `value` (string), `label` (string), `delay` (number ms, default: 0), `color` (CSS color)
- **Template**: Centered card with large value (4xl) in accent color, small label below
- **Animation**: `v-motion` with scale 0.8->1, opacity 0->1, y 40->0, configurable delay
- **Academic use cases**:
  - Primary outcome metrics (HR, OR, RR)
  - Sample size / power statistics
  - Key findings triptych (p-value, effect size, NNT)
- **Adaptation needed**: None -- the component is purely structural

#### 3. `TimelineItem.vue`
- **Props**: `date` (string), `label` (string), `description` (string), `status` (enum: done|current|upcoming)
- **Template**: Flex row with colored dot (done=accent, current=accent-light, upcoming=muted), vertical connector line, date/label/description stack
- **Animation**: Wraps in `v-click`
- **Academic use cases**:
  - Study enrollment timeline
  - Research milestones / Gantt-style progress
  - Clinical trial phases
  - Grant timeline visualization
- **Adaptation needed**: None -- generic timeline component

### Overlap Analysis

No overlap with existing components. The existing 5 components (FigurePanel, DataTable, CitationBlock, StatResult, FlowDiagram) handle research content display. The 3 new components handle layout patterns (comparison, metrics, timelines).

---

## Index Integration Plan

The current `index.json` needs these changes:

### 1. Replace null animation reference with local items

```json
"animations": {
  "description": "Reusable animation patterns with syntax examples",
  "path": "animations/",
  "items": [
    { "name": "fade-in", "file": "fade-in.md", "description": "CSS fade entrance via v-click", "trigger": "v-click", "complexity": "low" },
    { "name": "slide-in-below", "file": "slide-in-below.md", "description": "v-motion y-axis entrance with spring physics", "trigger": "v-motion", "complexity": "medium" },
    { "name": "metric-cascade", "file": "metric-cascade.md", "description": "Staggered v-motion for KPI/metric slides", "trigger": "v-motion", "complexity": "high" },
    { "name": "rough-marks", "file": "rough-marks.md", "description": "v-mark hand-drawn emphasis patterns", "trigger": "v-mark", "complexity": "medium" },
    { "name": "scale-in-pop", "file": "scale-in-pop.md", "description": "Spring scale entrance for emphasis elements", "trigger": "v-motion", "complexity": "medium" },
    { "name": "staggered-list", "file": "staggered-list.md", "description": "v-clicks with depth/every for progressive reveal", "trigger": "v-clicks", "complexity": "low" }
  ]
}
```

### 2. Replace null styles reference with local items

```json
"styles": {
  "description": "Composable CSS presets for colors, typography, and textures",
  "path": "styles/",
  "subcategories": {
    "colors": {
      "path": "colors/",
      "items": [
        { "name": "dark-blue-navy", "file": "dark-blue-navy.css", "schema": "dark" },
        { "name": "dark-gold-premium", "file": "dark-gold-premium.css", "schema": "dark" },
        { "name": "light-green-growth", "file": "light-green-growth.css", "schema": "light" },
        { "name": "light-blue-corp", "file": "light-blue-corp.css", "schema": "light" }
      ]
    },
    "typography": {
      "path": "typography/",
      "items": [
        { "name": "montserrat-inter", "file": "montserrat-inter.css", "description": "Geometric headings + clean body" },
        { "name": "playfair-inter", "file": "playfair-inter.css", "description": "Serif headings + sans body" },
        { "name": "inter-only", "file": "inter-only.css", "description": "All-sans minimal" }
      ]
    },
    "textures": {
      "path": "textures/",
      "items": [
        { "name": "grid-overlay", "file": "grid-overlay.css", "description": "Subtle grid lines" },
        { "name": "noise-grain", "file": "noise-grain.css", "description": "Film grain SVG overlay" }
      ]
    }
  }
}
```

### 3. Add 3 new components to existing items array

Append to `components.items`:
```json
{ "name": "ComparisonCol", "file": "ComparisonCol.vue" },
{ "name": "MetricCard", "file": "MetricCard.vue" },
{ "name": "TimelineItem", "file": "TimelineItem.vue" }
```

---

## File Manifest

### Files to Create (18 new files)

| # | Source (Vision) | Target (talk library) | Adaptation |
|---|-----------------|----------------------|------------|
| 1 | animations/fade-in.md | talk/animations/fade-in.md | Verbatim |
| 2 | animations/slide-in-below.md | talk/animations/slide-in-below.md | Verbatim |
| 3 | animations/metric-cascade.md | talk/animations/metric-cascade.md | Add academic examples |
| 4 | animations/rough-marks.md | talk/animations/rough-marks.md | Verbatim |
| 5 | animations/scale-in-pop.md | talk/animations/scale-in-pop.md | Verbatim |
| 6 | animations/staggered-list.md | talk/animations/staggered-list.md | Verbatim |
| 7 | styles/colors/dark-blue-navy.css | talk/styles/colors/dark-blue-navy.css | Verbatim |
| 8 | styles/colors/dark-gold-premium.css | talk/styles/colors/dark-gold-premium.css | Verbatim |
| 9 | styles/colors/light-green-growth.css | talk/styles/colors/light-green-growth.css | Verbatim |
| 10 | styles/colors/light-blue-corp.css | talk/styles/colors/light-blue-corp.css | Verbatim |
| 11 | styles/typography/montserrat-inter.css | talk/styles/typography/montserrat-inter.css | Verbatim |
| 12 | styles/typography/playfair-inter.css | talk/styles/typography/playfair-inter.css | Verbatim |
| 13 | styles/typography/inter-only.css | talk/styles/typography/inter-only.css | Verbatim |
| 14 | styles/textures/grid-overlay.css | talk/styles/textures/grid-overlay.css | Verbatim |
| 15 | styles/textures/noise-grain.css | talk/styles/textures/noise-grain.css | Verbatim |
| 16 | components/ComparisonCol.vue | talk/components/ComparisonCol.vue | Verbatim |
| 17 | components/MetricCard.vue | talk/components/MetricCard.vue | Verbatim |
| 18 | components/TimelineItem.vue | talk/components/TimelineItem.vue | Verbatim |

### Files to Modify (1)

| File | Change |
|------|--------|
| talk/index.json | Replace null animations/styles refs with local items; add 3 components |

---

## Source File Contents

### Animations

<details>
<summary>fade-in.md (complete)</summary>

```markdown
# Fade In Animation

CSS-based fade entrance for slide elements.

## Complexity
Low

## Syntax

### Basic v-click fade
\`\`\`html
<div v-click>
  Content fades in on click
</div>
\`\`\`

### CSS transition fade
\`\`\`html
<div v-click class="transition-opacity duration-500">
  Smooth opacity transition
</div>
\`\`\`

### Multiple elements with staggered fade
\`\`\`html
<v-clicks>

- First item fades in
- Second item fades in
- Third item fades in

</v-clicks>
\`\`\`

## Use Cases
- Default animation for most slide content
- Bullet point progressive reveal
- Simple text and image entrance

## Notes
- Slidev applies fade by default on v-click elements
- Combine with `duration-*` Windi CSS classes for timing control
- Lowest visual weight -- use for content-heavy slides
```
</details>

<details>
<summary>slide-in-below.md (complete)</summary>

```markdown
# Slide In Below Animation

v-motion y-axis entrance for dynamic content reveal.

## Complexity
Medium

## Syntax

### Basic slide-up entrance
\`\`\`html
<div
  v-motion
  :initial="{ y: 80, opacity: 0 }"
  :enter="{ y: 0, opacity: 1 }"
  :delay="200"
>
  Content slides up from below
</div>
\`\`\`

### With spring physics
\`\`\`html
<div
  v-motion
  :initial="{ y: 100, opacity: 0 }"
  :enter="{ y: 0, opacity: 1, transition: { type: 'spring', stiffness: 250, damping: 25 } }"
>
  Bouncy entrance
</div>
\`\`\`

### Staggered group
\`\`\`html
<div v-motion :initial="{ y: 60, opacity: 0 }" :enter="{ y: 0, opacity: 1 }" :delay="0">Item 1</div>
<div v-motion :initial="{ y: 60, opacity: 0 }" :enter="{ y: 0, opacity: 1 }" :delay="200">Item 2</div>
<div v-motion :initial="{ y: 60, opacity: 0 }" :enter="{ y: 0, opacity: 1 }" :delay="400">Item 3</div>
\`\`\`

## Use Cases
- Hero content on cover slides
- Key metric reveals
- Call-to-action elements

## Notes
- Requires @vueuse/motion (bundled with Slidev)
- Use :delay for staggering multiple elements
- Keep y offset between 60-100px for natural feel
```
</details>

<details>
<summary>metric-cascade.md (complete)</summary>

```markdown
# Metric Cascade Animation

Staggered v-motion entrance for KPI/metric slides with scale and opacity.

## Complexity
High

## Syntax

### Three-metric cascade
\`\`\`html
<div class="grid grid-cols-3 gap-8">
  <div
    v-motion
    :initial="{ scale: 0.8, opacity: 0, y: 40 }"
    :enter="{ scale: 1, opacity: 1, y: 0, transition: { delay: 0 } }"
  >
    <AutoFitText :max="48" :min="24" class="text-[var(--slidev-accent)]">
      $2.5M
    </AutoFitText>
    <p class="text-sm opacity-70">ARR</p>
  </div>

  <div
    v-motion
    :initial="{ scale: 0.8, opacity: 0, y: 40 }"
    :enter="{ scale: 1, opacity: 1, y: 0, transition: { delay: 300 } }"
  >
    <AutoFitText :max="48" :min="24" class="text-[var(--slidev-accent)]">
      150%
    </AutoFitText>
    <p class="text-sm opacity-70">MoM Growth</p>
  </div>

  <div
    v-motion
    :initial="{ scale: 0.8, opacity: 0, y: 40 }"
    :enter="{ scale: 1, opacity: 1, y: 0, transition: { delay: 600 } }"
  >
    <AutoFitText :max="48" :min="24" class="text-[var(--slidev-accent)]">
      10K
    </AutoFitText>
    <p class="text-sm opacity-70">Active Users</p>
  </div>
</div>
\`\`\`

## Use Cases
- Traction slides with key metrics
- Financial summary numbers
- Any 2-4 metric display

## Notes
- Use 300ms delay increments between metrics
- Scale from 0.8 (not 0) for subtle effect
- Combine with AutoFitText for responsive sizing
- Works best on layout: fact or layout: center slides
```
</details>

<details>
<summary>rough-marks.md (complete)</summary>

```markdown
# Rough Marks Animation

v-mark emphasis patterns for highlighting key text with hand-drawn style marks.

## Complexity
Medium

## Syntax

### Underline emphasis
\`\`\`html
<span v-mark.underline.orange="{ at: 1 }">key phrase</span>
\`\`\`

### Circle emphasis
\`\`\`html
<span v-mark.circle.red="{ at: 2 }">important number</span>
\`\`\`

### Highlight emphasis
\`\`\`html
<span v-mark.highlight.yellow="{ at: 1 }">highlighted text</span>
\`\`\`

### Box emphasis
\`\`\`html
<span v-mark.box.blue="{ at: 3 }">boxed content</span>
\`\`\`

### Multiple marks in sequence
\`\`\`html
<p>
  We grew <span v-mark.underline.orange="{ at: 1 }">150% MoM</span>
  reaching <span v-mark.circle.red="{ at: 2 }">10K users</span>
  with <span v-mark.highlight.yellow="{ at: 3 }">$0 marketing spend</span>
</p>
\`\`\`

## Use Cases
- Emphasizing key metrics on traction slides
- Drawing attention to important claims
- Progressive emphasis during narration

## Notes
- Uses rough-notation library (bundled with Slidev)
- Colors: orange, red, yellow, blue, green, purple
- Mark types: underline, circle, highlight, box, strike-through
- Use at parameter to sync with v-click steps
```
</details>

<details>
<summary>scale-in-pop.md (complete)</summary>

```markdown
# Scale In Pop Animation

v-motion spring scale entrance for CTAs and emphasis elements.

## Complexity
Medium

## Syntax

### Basic scale pop
\`\`\`html
<div
  v-motion
  :initial="{ scale: 0, opacity: 0 }"
  :enter="{ scale: 1, opacity: 1, transition: { type: 'spring', stiffness: 300, damping: 20 } }"
>
  <h1 class="text-6xl font-bold">$5M</h1>
  <p>Seed Round</p>
</div>
\`\`\`

### With overshoot bounce
\`\`\`html
<div
  v-motion
  :initial="{ scale: 0, opacity: 0 }"
  :enter="{ scale: 1, opacity: 1, transition: { type: 'spring', stiffness: 400, damping: 15 } }"
>
  Call to action content
</div>
\`\`\`

### Delayed pop for sequential reveal
\`\`\`html
<div
  v-motion
  :initial="{ scale: 0, opacity: 0 }"
  :enter="{ scale: 1, opacity: 1, transition: { type: 'spring', stiffness: 300, damping: 20, delay: 500 } }"
>
  Appears after half second
</div>
\`\`\`

## Use Cases
- Ask slide funding amount
- Closing slide CTA
- Key metric callouts
- Logo or brand reveal

## Notes
- Higher stiffness = faster animation
- Lower damping = more bounce/overshoot
- Good defaults: stiffness 300, damping 20
- Scale from 0 for dramatic pop; from 0.5 for subtle grow
```
</details>

<details>
<summary>staggered-list.md (complete)</summary>

```markdown
# Staggered List Animation

v-clicks with depth and every parameters for progressive list reveal.

## Complexity
Low

## Syntax

### Basic staggered list
\`\`\`html
<v-clicks>

- First point appears
- Second point appears
- Third point appears

</v-clicks>
\`\`\`

### With depth control (nested lists)
\`\`\`html
<v-clicks depth="2">

- Main point
  - Sub-point revealed with parent
- Another point
  - Another sub-point

</v-clicks>
\`\`\`

### Every N items
\`\`\`html
<v-clicks every="2">

- These two appear together
- (same click as above)
- These two appear together
- (same click as above)

</v-clicks>
\`\`\`

### Manual click indexing
\`\`\`html
<ul>
  <li v-click="1">First</li>
  <li v-click="1">Also first (same click)</li>
  <li v-click="2">Second</li>
  <li v-click="3">Third</li>
</ul>
\`\`\`

## Use Cases
- Problem evidence points
- Solution benefit lists
- Team member introductions
- Any progressive bullet content

## Notes
- <v-clicks> wraps any list for automatic staggering
- depth controls how deep into nested structures clicks propagate
- every groups multiple items per click
- Prefer <v-clicks> over manual v-click for simple lists
```
</details>

### CSS Styles

<details>
<summary>All 9 CSS files (complete)</summary>

**styles/colors/dark-blue-navy.css**
```css
/* Dark Blue Navy -- AI startup default color preset */
:root {
  --slidev-bg: #1e293b;
  --slidev-text: #e2e8f0;
  --slidev-text-secondary: #cbd5e1;
  --slidev-text-muted: #94a3b8;
  --slidev-accent: #60a5fa;
  --slidev-accent-light: #93c5fd;
  --slidev-border: #334155;
  --slidev-code-bg: #0f172a;
  --slidev-card-bg: #1e293b;
}
```

**styles/colors/dark-gold-premium.css**
```css
/* Dark Gold Premium -- Luxury/fintech color preset */
:root {
  --slidev-bg: #0f0f1a;
  --slidev-text: #e8e0d4;
  --slidev-text-secondary: #c4b8a8;
  --slidev-text-muted: #8a7e6e;
  --slidev-accent: #d4a574;
  --slidev-accent-light: #e6c49a;
  --slidev-border: #2a2535;
  --slidev-code-bg: #0a0a14;
  --slidev-card-bg: #1a1525;
}
```

**styles/colors/light-green-growth.css**
```css
/* Light Green Growth -- Sustainability/biotech color preset */
:root {
  --slidev-bg: #f0fdf4;
  --slidev-text: #047857;
  --slidev-text-secondary: #065f46;
  --slidev-text-muted: #6ee7b7;
  --slidev-accent: #38a169;
  --slidev-accent-light: #68d391;
  --slidev-border: #c6f6d5;
  --slidev-code-bg: #f7fdf9;
  --slidev-card-bg: #ffffff;
}
```

**styles/colors/light-blue-corp.css**
```css
/* Light Blue Corporate -- Enterprise/professional color preset */
:root {
  --slidev-bg: #ffffff;
  --slidev-text: #1a365d;
  --slidev-text-secondary: #2d3748;
  --slidev-text-muted: #a0aec0;
  --slidev-accent: #2b6cb0;
  --slidev-accent-light: #4299e1;
  --slidev-border: #e2e8f0;
  --slidev-code-bg: #f7fafc;
  --slidev-card-bg: #ffffff;
}
```

**styles/typography/montserrat-inter.css**
```css
/* Montserrat + Inter -- Default heading + body typography preset */
:root {
  --slidev-font-heading: 'Montserrat', sans-serif;
  --slidev-font-body: 'Inter', sans-serif;
  --slidev-font-mono: 'Fira Code', monospace;
}
h1, h2, h3 { font-family: var(--slidev-font-heading); letter-spacing: -0.02em; }
h1 { font-size: 3em; font-weight: 700; }
h2 { font-size: 2.25em; font-weight: 600; }
h3 { font-size: 1.75em; font-weight: 600; }
p, li, span, div { font-family: var(--slidev-font-body); }
code, pre { font-family: var(--slidev-font-mono); }
```

**styles/typography/playfair-inter.css**
```css
/* Playfair Display + Inter -- Serif headings + sans body typography preset */
:root {
  --slidev-font-heading: 'Playfair Display', serif;
  --slidev-font-body: 'Inter', sans-serif;
  --slidev-font-mono: 'Fira Code', monospace;
}
h1, h2, h3 { font-family: var(--slidev-font-heading); letter-spacing: -0.01em; }
h1 { font-size: 3em; font-weight: 700; }
h2 { font-size: 2.25em; font-weight: 600; }
h3 { font-size: 1.75em; font-weight: 600; }
p, li, span, div { font-family: var(--slidev-font-body); }
code, pre { font-family: var(--slidev-font-mono); }
```

**styles/typography/inter-only.css**
```css
/* Inter Only -- All-sans clean typography preset */
:root {
  --slidev-font-heading: 'Inter', sans-serif;
  --slidev-font-body: 'Inter', sans-serif;
  --slidev-font-mono: 'Fira Code', monospace;
}
h1, h2, h3 { font-family: var(--slidev-font-heading); letter-spacing: -0.03em; }
h1 { font-size: 3em; font-weight: 800; }
h2 { font-size: 2.25em; font-weight: 700; }
h3 { font-size: 1.75em; font-weight: 600; }
p, li, span, div { font-family: var(--slidev-font-body); font-weight: 400; }
code, pre { font-family: var(--slidev-font-mono); }
```

**styles/textures/grid-overlay.css**
```css
/* Grid Overlay -- Subtle grid background texture */
.slidev-layout {
  background-image:
    linear-gradient(rgba(255, 255, 255, 0.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(255, 255, 255, 0.03) 1px, transparent 1px);
  background-size: 40px 40px;
}
.slidev-layout[data-color-schema="light"] {
  background-image:
    linear-gradient(rgba(0, 0, 0, 0.04) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0, 0, 0, 0.04) 1px, transparent 1px);
  background-size: 40px 40px;
}
```

**styles/textures/noise-grain.css**
```css
/* Noise Grain -- Film grain SVG overlay texture */
.slidev-layout::before {
  content: '';
  position: absolute;
  top: 0; left: 0; width: 100%; height: 100%;
  opacity: 0.04;
  pointer-events: none;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 256 256' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E");
  background-repeat: repeat;
  z-index: 0;
}
.slidev-layout > * { position: relative; z-index: 1; }
```
</details>

### Vue Components

<details>
<summary>All 3 Vue components (complete)</summary>

**components/ComparisonCol.vue**
```vue
<script setup>
const props = defineProps({
  title: { type: String, required: true },
  points: { type: Array, required: true },
  color: { type: String, default: 'var(--slidev-accent)' },
  highlight: { type: Boolean, default: false },
})
</script>
<template>
  <div v-click class="p-6 rounded-lg" :class="{ 'ring-2': props.highlight }"
    :style="{ borderColor: props.highlight ? props.color : 'transparent', ringColor: props.highlight ? props.color : 'transparent' }">
    <h3 class="text-xl font-bold mb-4" :style="{ color: props.color }">{{ props.title }}</h3>
    <ul class="space-y-2">
      <li v-for="(point, i) in props.points" :key="i" class="text-sm opacity-80">{{ point }}</li>
    </ul>
  </div>
</template>
```

**components/MetricCard.vue**
```vue
<script setup>
const props = defineProps({
  value: { type: String, required: true },
  label: { type: String, required: true },
  delay: { type: Number, default: 0 },
  color: { type: String, default: 'var(--slidev-accent)' },
})
</script>
<template>
  <div v-motion :initial="{ scale: 0.8, opacity: 0, y: 40 }"
    :enter="{ scale: 1, opacity: 1, y: 0, transition: { delay: props.delay } }"
    class="text-center p-4">
    <div class="text-4xl font-bold" :style="{ color: props.color }">{{ props.value }}</div>
    <div class="text-sm opacity-70 mt-2">{{ props.label }}</div>
  </div>
</template>
```

**components/TimelineItem.vue**
```vue
<script setup>
const props = defineProps({
  date: { type: String, required: true },
  label: { type: String, required: true },
  description: { type: String, default: '' },
  status: { type: String, default: 'upcoming', validator: (v) => ['done', 'current', 'upcoming'].includes(v) },
})
const dotColor = {
  done: 'var(--slidev-accent)',
  current: 'var(--slidev-accent-light)',
  upcoming: 'var(--slidev-text-muted)',
}
</script>
<template>
  <div v-click class="flex items-start gap-4 mb-4">
    <div class="flex flex-col items-center">
      <div class="w-3 h-3 rounded-full" :style="{ backgroundColor: dotColor[props.status] }" />
      <div class="w-0.5 h-8 bg-gray-500 opacity-30" />
    </div>
    <div>
      <div class="text-xs opacity-50">{{ props.date }}</div>
      <div class="font-bold text-sm">{{ props.label }}</div>
      <div v-if="props.description" class="text-xs opacity-70">{{ props.description }}</div>
    </div>
  </div>
</template>
```
</details>

---

## Risks and Considerations

1. **CSS variable naming**: The ported styles use `--slidev-*` variable names. The existing JSON themes may define different variable names. Need to verify the assembly agent uses these same variables.

2. **Font loading**: Typography CSS files reference Google Fonts (Montserrat, Playfair Display, Inter, Fira Code). The Slidev project's `fonts` headmatter config handles loading -- ensure the assembly agent includes appropriate font declarations.

3. **Composable vs monolithic coexistence**: Both theme systems should be documented so the slide planner agent knows when to offer composable style selection vs monolithic theme selection.

4. **Component naming**: The existing talk library uses PascalCase Vue component names (FigurePanel, DataTable). The ported components follow the same convention (ComparisonCol, MetricCard, TimelineItem) -- no conflict.

## Recommendations

1. Port all 18 files verbatim (17 unchanged, 1 with academic examples added to metric-cascade.md)
2. Update index.json to replace null references with local items
3. Update the slidev-assembly-agent context to document composable style usage
4. Total effort: small-to-medium (mostly file copying + index update)
