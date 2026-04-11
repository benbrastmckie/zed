# Teammate C Findings: Documents & Research/Grants Commands

**Task 12**: Expand `docs/agent-system/commands.md` with examples and explanations.
**Scope**: /convert, /table, /slides, /scrape, /edit, /grant, /budget, /timeline, /funds

---

## Current State of commands.md

The current `docs/agent-system/commands.md` uses a deliberately terse format ("intentionally terse: one-sentence summary, minimal example, flag list, and link"). The Documents and Research/Grants sections exist but are sparse — most entries have 1-3 examples and a flag list, nothing more. There are no explanations of when to use a command, no description of multi-mode behavior, and no edge cases documented.

---

## Per-Command Analysis

### /convert

**What it does**: Converts documents between formats by routing to one of two skill paths: general document conversion (PDF/DOCX/XLSX/HTML/images → Markdown, Markdown → PDF) via `skill-filetypes`, or PowerPoint-to-slide-format conversion (PPTX → Beamer, Polylux, Touying) via `skill-presentation`. When source is a PPTX with `--format beamer|polylux|touying`, it takes the slide path; all other inputs go through the general converter.

**Current docs.md coverage**: Three examples shown (PDF, DOCX, Markdown), no explanation of the dual routing logic, no slide format explanation, no tool dependency note.

**Recommended additions**:
- Explain the two routing paths (general vs. slide)
- Note that PPTX without `--format` produces plain Markdown (not slides)
- Note tool dependencies: `markitdown` or `pandoc` for general; `python-pptx` + `pandoc` for slides
- Output format is inferred from source extension; specify output path explicitly for unusual cases

**Examples worth adding**:
```
/convert report.pdf                          # -> report.md (inferred)
/convert draft.md README.pdf                 # Markdown to PDF via pandoc/typst
/convert deck.pptx --format beamer          # -> deck.tex (LaTeX slides)
/convert deck.pptx --format polylux        # -> deck.typ (Typst/Polylux slides)
/convert deck.pptx --format beamer --theme metropolis  # with Metropolis theme
/convert page.html page.md                  # HTML to Markdown
```

**Key behavior notes**:
- PPTX without `--format` → Markdown (uses markitdown), NOT slides
- Slide metadata: slide count and speaker notes presence reported in output
- Git commit is optional (not automatic)
- For spreadsheet table conversion, use `/table` instead

---

### /table

**What it does**: Converts XLSX, CSV, or ODS spreadsheets to typeset-ready LaTeX or Typst table markup. Uses pandas + openpyxl under the hood. Default output is LaTeX booktabs format. Unlike `/convert`, which targets general Markdown output, `/table` is specifically for producing publication-quality table code.

**Current docs.md coverage**: Two examples, `--format` flag listed. Missing: `--sheet` flag for multi-sheet workbooks.

**Recommended additions**:
- Add `--sheet` flag to flag list (it exists in source, missing from docs)
- Explain the booktabs output default and why to prefer `/table` over `/convert` for tabular data
- Note supported source types: xlsx, xls, csv, ods

**Examples worth adding**:
```
/table data.xlsx                             # -> data.tex (LaTeX booktabs, default)
/table data.xlsx output.typ --format typst   # Typst csv() or tabut table
/table workbook.xlsx --sheet "Q4 Data"       # Specific sheet from multi-sheet workbook
/table budget.csv budget.tex --format latex  # Explicit format and output path
```

**Key behavior notes**:
- `--sheet` flag exists in command source but is absent from commands.md
- Output format inferred from `--format`: latex → `.tex`, typst → `.typ`
- Git commit is optional

---

### /slides

**What it does**: Creates a research talk task with a structured pre-task interview (talk type, source materials, audience context), then stops at [NOT STARTED]. The user then runs `/research N`, `/plan N`, `/implement N` to generate a Slidev-based HTML presentation. When given a task number, it runs the research phase via `skill-talk`. The optional `--design` flag (after research) prompts visual theme selection and section emphasis choices stored as `design_decisions` for the planner.

**Current docs.md coverage**: Three examples shown, five modes listed, note about PPTX conversion redirect. No explanation of the pre-task forcing questions, the multi-stage workflow, or the `--design` flag.

**Recommended additions**:
- Explain the two-phase interaction model (forcing questions first, task creation second)
- Clarify `--design` flag purpose and when to use it
- Mention that file-path input reads the file as primary source material
- Note that output format is Slidev (Vue.js-based), not PPTX

**Examples worth adding**:
```
/slides "Conference talk on survival analysis"   # Asks questions, creates task, stops
/slides 12                                        # Runs research on existing task 12
/slides 12 --design                               # Prompts theme/emphasis after research
/slides ~/papers/manuscript.md                    # Uses file as primary source
```

**Talk modes table (already in docs, but could add slide count)**:
| Mode | Duration | Slides | Use Case |
|------|----------|--------|----------|
| CONFERENCE | 15-20 min | 12-18 | Conference presentations |
| SEMINAR | 45-60 min | 30-45 | Department seminars, job talks |
| DEFENSE | 30-60 min | 25-40 | Grant defense, thesis defense |
| POSTER | N/A | 1 large | Poster sessions |
| JOURNAL_CLUB | 15-30 min | 10-15 | Paper critique discussions |

**Key behavior notes**:
- Forcing questions gathered BEFORE task creation (talk type, materials, audience)
- Design decisions stored in state.json for planner use
- Output: Slidev presentation in `talks/{N}_{slug}/`
- `/slides N` stops at [RESEARCHED], not [COMPLETED]
- For PPTX file conversion (not talk creation), use `/convert --format beamer|polylux|touying`

---

### /scrape

**What it does**: Extracts annotations, highlights, comments, sticky notes, bookmarks, and drawings from PDF files and writes them to Markdown or JSON. Only accepts PDF input. Output filename defaults to `{basename}_annotations.md`. Useful for capturing reading notes without manually re-typing highlighted passages.

**Current docs.md coverage**: Two examples, three flags listed. Missing: explanation of annotation types, note about empty output behavior (PDF with no annotations), tool dependencies.

**Recommended additions**:
- Explain what "annotations" includes (highlights, comments, sticky notes, bookmarks, drawings)
- Note tool dependencies: `pdfannots` or `PyMuPDF` (pymupdf)
- Describe empty output behavior (PDF with no annotations produces warning, not error)

**Examples worth adding**:
```
/scrape paper.pdf                                  # -> paper_annotations.md (all types)
/scrape paper.pdf --format json                    # -> paper_annotations.json
/scrape paper.pdf notes/highlights.md              # Explicit output path
/scrape paper.pdf --types highlights,comments      # Only highlights and comments
/scrape paper.pdf output.md --format markdown --types highlights,comments,notes
```

**Key behavior notes**:
- Only accepts `.pdf` files; use `/convert` for other document types
- Available annotation types depend on the PDF content
- Empty output (no annotations) returns warning with `Status: scraped`, not an error
- Git commit is optional

---

### /edit

**What it does**: Edits Word documents in-place using natural language instructions via the SuperDoc MCP. Supports three modes: single-file edit (DOCX with tracked changes), batch edit (all DOCX files in a directory), and new document creation (`--new`). Changes are tracked so reviewers can accept/reject. XLSX editing is declared in the source but explicitly not yet implemented.

**Current docs.md coverage**: Three examples, `--new` flag listed, link to workflow doc. The docs already explain batch and create modes well.

**Recommended additions**:
- Note that tracked changes are the default (reviewers can accept/reject)
- Note XLSX editing is planned but not yet available
- Clarify that instruction is natural language (no special syntax)

**Examples worth adding** (current examples are good; minor additions):
```
/edit contract.docx "Replace ACME Corp with NewCo Inc using tracked changes"
/edit ~/Documents/proposal.docx "Change deadline from March to April"
/edit ~/Contracts/ "Replace Old Company LLC with New Company LLC in all files"
/edit --new memo.docx "Draft Q2 Budget Review memo with executive summary and recommendations"
```

**Key behavior notes**:
- Requires SuperDoc MCP (Node.js 18+) or python-docx fallback
- Batch mode processes all `.docx` files in a directory
- XLSX support: `Not yet available` per source (existing docs.md mentions it correctly)
- Git commit is optional

---

### /grant

**What it does**: A multi-mode command for grant proposal development. In task creation mode (string input), it asks four pre-task forcing questions (mechanism/funder, existing content, regulatory materials, constraints) then stops at [NOT STARTED]. The `--draft` and `--budget` modes run exploratory drafting/budget workflows on an existing task. The `--revise` mode creates a new revision task referencing the original grant directory. The `--fix-it` mode scans the grant directory for embedded FIX:/TODO: tags and creates tasks.

**Current docs.md coverage**: Four examples shown, all modes demonstrated. However, docs do not explain the pre-task forcing questions, the exploratory nature of `--draft`/`--budget`, or what `--fix-it` does. The `--fix-it` mode is completely absent from docs.md.

**Recommended additions**:
- Document `--fix-it` mode (currently missing entirely from docs.md)
- Explain that `--draft` and `--budget` are exploratory phases that inform `/plan`
- Note that drafts can start before or after research (flexible status requirements)
- Explain the recommended 5-step workflow

**Examples worth adding**:
```
/grant "NIH R01 on community-level TB surveillance"  # Asks questions, creates task
/grant 12 --draft                                     # Draft narrative sections
/grant 12 --draft "Focus on innovation and methodology"  # Guided draft
/grant 12 --budget                                    # Develop budget
/grant 12 --budget "Emphasize personnel, 3 conferences/year"  # Guided budget
/grant --revise 12 "Address reviewer comments on methodology"
/grant 12 --fix-it                                    # Scan grant dir for FIX:/TODO: tags
```

**Key behavior notes**:
- Pre-task forcing questions: mechanism/funder, existing content paths, regulatory materials, constraints
- `--draft` starts at `not_started` status (pre-research drafting is valid)
- Recommended workflow: `/research N` → `/grant N --draft` → `/grant N --budget` → `/plan N` → `/implement N`
- Grant materials assembled to `grants/{N}_{slug}/` on implement
- `--fix-it` is a non-destructive scan; does not change task status

---

### /budget

**What it does**: Generates multi-year grant budget spreadsheets (.xlsx) with native Excel formulas (salary cap, F&A calculations, annual escalation). In task creation mode (string input), asks three forcing questions (budget type, project period, direct cost target) then stops at [NOT STARTED]. When given a task number, runs the research phase generating the XLSX spreadsheet. The `--quick` flag is a legacy mode that bypasses task creation and generates output immediately.

**Current docs.md coverage**: Three examples including `--quick`. The `--quick` flag entry is labeled with a mode parameter (`--quick [mode]`). This is accurate. However, docs do not explain the five budget modes, what "forcing questions" means, or that the main workflow stops at [NOT STARTED].

**Recommended additions**:
- Explain the five budget modes (MODULAR, DETAILED, NSF, FOUNDATION, SBIR)
- Clarify that description input creates a task and stops — research runs separately
- Explain that `--quick` bypasses task creation entirely (legacy standalone mode)
- Mention file path input mode (`/budget ~/grants/r01-aims.md`)

**Budget modes**:
| Mode | Format | Use Case |
|------|--------|----------|
| MODULAR | NIH Modular | Under $250K/year, $25K modules |
| DETAILED | NIH Detailed | $250K+/year, full categorical |
| NSF | NSF Standard | Categories A through J |
| FOUNDATION | Foundation | Simplified, limited overhead |
| SBIR | SBIR | Phase-specific, includes fee/profit |

**Examples worth adding**:
```
/budget "NIH R01 budget for AI interpretability project"  # Asks questions, creates task
/budget 234                                               # Research existing task → XLSX generated
/budget ~/grants/r01-aims.md                              # File as context, asks questions
/budget --quick MODULAR                                   # Legacy standalone (no task)
```

**Key behavior notes**:
- Description input: creates task, stops at [NOT STARTED] — user must run `/research N` next
- Task number input: runs research immediately, generates XLSX, stops at [RESEARCHED]
- Artifacts: XLSX spreadsheet + JSON metrics + research report
- Requires `openpyxl` Python package

---

### /timeline

**What it does**: Creates research project timelines for NIH/NSF grants with Gantt-style milestone tracking. In task creation mode (string input), asks six forcing questions (grant mechanism, project period, aims count, key milestones, regulatory approvals, existing aims document) then stops at [NOT STARTED]. When given a task number, runs the timeline research phase and generates a Typst-format output.

**Current docs.md coverage**: Two examples shown. No explanation of the forcing questions, no mention of Typst output format, no description of what the timeline contains.

**Recommended additions**:
- Explain the six pre-task forcing questions and what they capture
- Note that output format is Typst (not Markdown or PDF)
- Mention supported grant mechanisms (R01/R21/K-series/U01/Other)
- Clarify that regulatory approvals (IRB/IACUC/FDA) are tracked as milestones

**Examples worth adding**:
```
/timeline "3-year R21 cohort study with 6-month follow-up"  # Asks questions, creates task
/timeline 12                                                  # Runs research on existing task
```

**Key behavior notes**:
- Forcing questions capture: mechanism, period, aims count, milestones, regulatory, existing aims doc
- Output: Typst timeline in `specs/{NNN}_{SLUG}/` via `/implement N`
- Both `/timeline N` and `/research N` route to `skill-timeline` for timeline tasks
- Implementation generates Typst output (not PDF directly; compile with `typst compile`)

---

### /funds

**What it does**: Conducts funding landscape analysis with four specialized modes: LANDSCAPE (survey opportunities across funders), PORTFOLIO (deep-dive on one funder's priorities and past awards), JUSTIFY (verify budget against funder guidelines), GAP (identify unfunded strategic areas). Asks five forcing questions before task creation to gather research area, funding history, target funders, budget parameters, and decision context.

**Current docs.md coverage**: Three examples including `--quick`. Flags listed. No description of the four analysis modes or what information the forcing questions capture.

**Recommended additions**:
- Explain the four analysis modes and when to use each
- Note the five pre-task forcing questions
- Clarify that `--quick` is a legacy standalone mode
- Note that output includes a funding landscape spreadsheet (.xlsx) and metrics JSON

**Analysis modes**:
| Mode | Use When |
|------|---------|
| LANDSCAPE | Surveying what funding opportunities exist for a research area |
| PORTFOLIO | Analyzing a specific funder's priorities and award patterns |
| JUSTIFY | Checking if a budget meets funder cost guidelines |
| GAP | Finding strategic unfunded niches in a research area |

**Examples worth adding**:
```
/funds "NIH R01 funding landscape for computational biology"  # Asks questions, creates task
/funds 12                                                      # Research existing task
/funds --quick "F&A rate comparison across institutes"         # Legacy standalone mode
```

**Key behavior notes**:
- Five forcing questions gathered before task creation (research area, funding history, target funders, budget parameters, decision context)
- Output: funding landscape spreadsheet + metrics JSON + research report
- `--quick` bypasses task creation entirely

---

## Gaps and Issues

### Missing from commands.md

1. **`/grant --fix-it` mode is completely absent**. The source file defines a full Fix-It Scan Mode that scans grant directories for `FIX:`, `TODO:`, `NOTE:`, `QUESTION:` tags and creates structured tasks. This mode has no mention anywhere in `docs/agent-system/commands.md`.

2. **`/table --sheet` flag is absent**. The `--sheet NAME` flag for selecting a specific sheet from multi-sheet workbooks is defined in the source command (`table.md`) but missing from the flag list in `commands.md`.

3. **`/budget ~/path/to/file.md` input mode is absent**. The budget command supports file path input (reads file as context, asks questions, creates task) but this mode is not mentioned in commands.md.

### Inconsistencies Between Source and Docs

4. **`/budget --quick [mode]` flag description is partially accurate**. The docs list `--quick [mode]` which matches the source's `--quick MODULAR` usage, but the docs entry does not clarify this is a legacy mode that bypasses task creation entirely.

5. **`/convert` dual routing is not explained**. The docs show PPTX and non-PPTX examples together without explaining that these are fundamentally different code paths (different skills, different agent, different output verification).

6. **`/slides` workflow scope is undersold**. The command description says "Create a research talk task with forcing questions" but doesn't convey that it's a multi-stage command (also handles research delegation and design confirmation via `--design`). Users reading the docs would not know `/slides 12` does anything different from `/slides "description"`.

7. **`/grant` mode table is implicit, not explicit**. The source command has 5 distinct modes (Task Creation, Draft, Budget, Fix-It, Revise) but commands.md only shows examples for 4 of them and doesn't label them as "modes".

8. **`/funds` and `/budget` STAGE 0 forcing questions are completely hidden**. Both commands ask extensive pre-task questions (5 for /funds, 3 for /budget) that are central to how they work, but commands.md gives no hint that these interactive sessions happen.

### Potentially Misleading Descriptions

9. **`/slides` note about PPTX conversion** is helpful but creates confusion about what `/slides` actually does. A reader might think `/slides` is for file conversion at all when it's exclusively for research talk task creation.

10. **`/edit` XLSX note** ("not yet available") in the source is not reflected in commands.md at all. A user might try `/edit budget.xlsx ...` and get an unhelpful error.

11. **`/timeline` output is Typst**, not a document format most users would guess. The docs don't mention this, so users won't know they need `typst compile` to get a PDF.

### Structural Observations

12. The "Documents" section (convert, table, slides, scrape, edit) and "Research & Grants" section (grant, budget, timeline, funds) are sensibly separated, but the relationship between them is not clear. For example, `/slides` is in Documents but is closely related to `/grant` (both use the "present" task type and similar forcing question patterns).

13. The commands.md file currently has no description of the **pre-task forcing question pattern** that most grant/present commands use. A brief explanatory note at the top of the Research & Grants section would save significant documentation duplication.

---

## Key Findings

1. **All 9 commands are present in commands.md** — no commands are entirely missing, though `/grant --fix-it` mode is undocumented.

2. **Three missing flags/modes**: `--sheet` (table), `--fix-it` (grant), file-path input (budget).

3. **The forcing question pattern** is central to /grant, /budget, /timeline, /funds, and /slides but is not mentioned anywhere in commands.md. This is the largest documentation gap.

4. **Workflow explanations are absent**: All grant/present commands have a "create task → research → plan → implement" workflow with specific stopping points, but docs.md shows only the first step. Users won't know what to do next.

5. **Budget mode tables** for /budget (MODULAR/DETAILED/NSF/FOUNDATION/SBIR) and /funds (LANDSCAPE/PORTFOLIO/JUSTIFY/GAP) are meaningful differentiators that help users choose the right tool, but are not in docs.md.

6. **The most accurate existing entries** are /edit (well-explained modes) and /scrape (adequate flags). The weakest are /timeline and /funds (almost no explanatory content).

---

## Confidence Level

**High confidence** on:
- Command behavior analysis (read full source for all 9 commands)
- Missing flags and modes (cross-referenced source vs. docs)
- Workflow patterns (consistent across all grant/present commands)

**Medium confidence** on:
- How much to expand each entry — the stated goal of commands.md is to be "intentionally terse" with links to full docs; expanding too much may conflict with that intent. Recommend expanding to 3-5 sentences + 3-4 examples per command, with a flag table, without reproducing full workflow documentation.
- Whether the "Documents" vs "Research & Grants" section split should be adjusted (e.g., moving /slides to Research & Grants section)

**Low confidence** on:
- Whether `/funds`'s four analysis modes and `/budget`'s five budget modes should be table-listed in commands.md or kept as a "see source file" reference
