---
next_project_number: 50
---

# Task List

## Tasks

### 49. HIV Grand Rounds: MXM LA-ART & LA-PrEP presentation
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Task Type**: present
- **Research**: [01_slides-research.md](049_hiv_grand_rounds_la_art_prep/reports/01_slides-research.md)

**Description**: HIV Grand Rounds presentation on MXM LA-ART & LA-PrEP program. CONFERENCE talk (15-20 min), PPTX output. Source: examples/test-files/HIV_Grand_Rounds.md. Audience: ID faculty and HIV clinic community members at UCSF/ZSFG, ~20-25 min with 4 patient cases and audience polls.

### 48. Move visual theme selection into /slides planning phase
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**: [01_slides-theme-planning.md](048_slides_theme_in_planning/reports/01_slides-theme-planning.md)
- **Plan**: [01_slides-theme-planning.md](048_slides_theme_in_planning/plans/01_slides-theme-planning.md)
- **Summary**: [01_slides-theme-planning-summary.md](048_slides_theme_in_planning/summaries/01_slides-theme-planning-summary.md)

**Description**: Move visual theme selection into /slides planning phase. Currently theme (Academic Clean, Clinical Teal, Conference Bold, Minimal Dark, UCSF Institutional) is only selectable via a separate `/slides N --design` invocation (STAGE 3). Refactor so theme and design questions are asked interactively during `/plan N` for slides tasks. Remove `--design` as a separate entry point from slides.md. Update skill-slides planning routing to include interactive design questions (theme, message ordering, section emphasis) before delegating to planner-agent. Store results in `design_decisions` on state.json. Verify assembly agents read `design_decisions` correctly.

### 46. Enrich /slides task description with source material paths and forcing data
- **Effort**: 1 hour
- **Status**: [ABANDONED] - Scope absorbed into task 44
- **Task Type**: meta
- **Research**: [01_enrich-slides-description.md](046_enrich_slides_task_description/reports/01_enrich-slides-description.md)

**Description**: Enrich /slides task description to include source material file paths, template references, and key forcing data details. Currently, /slides creates a task whose description omits the file paths passed as input and gathered during forcing questions — these end up only in forcing_data.source_materials in state.json but not in the user-facing description or TODO.md entry. Changes target .claude/commands/slides.md Stage 1 (Steps 2-4): construct the description by incorporating the primary source file path, any example template paths from source_materials, talk type, audience context summary, and output format. Ensure the TODO.md Description block includes the same detail.

### 44. Refactor slides system: split slides-agent into three focused agents
- **Effort**: 4 hours
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**:
  - [01_slides-agent-split.md](044_refactor_slides_agent_split/reports/01_slides-agent-split.md)
  - [02_task46-integration.md](044_refactor_slides_agent_split/reports/02_task46-integration.md)
- **Plan**: [02_slides-agent-split.md](044_refactor_slides_agent_split/plans/02_slides-agent-split.md)

**Description**: Split slides-agent.md (553 lines) into three focused agents to reduce context window usage and improve consistency. slides-research-agent handles format-agnostic content mapping (Stages 0-8). pptx-assembly-agent handles PPTX generation via python-pptx (Stages A1-A8). slidev-assembly-agent handles Slidev markdown generation (new). Update skill-slides routing to dispatch to the correct agent based on workflow_type and output_format. Update /slides command, context index, extensions.json, and CLAUDE.md documentation. Each agent should only load the context it needs, progressively.

### 43. Disable system-wide Claude Code auto-memories and use per-repo .memory/ exclusively
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-04-12
- **Summary**: Migrated 4 auto-memory entries to .memory/, added autoMemoryEnabled:false to dotfiles settings, updated CLAUDE.md context architecture.
- **Task Type**: meta
- **Research**:
  - [01_auto-memory-research.md](043_disable_system_wide_auto_memories/reports/01_auto-memory-research.md)
- **Plan**: [01_disable-auto-memory.md](043_disable_system_wide_auto_memories/plans/01_disable-auto-memory.md)
- **Summary**: [01_disable-auto-memory-summary.md](043_disable_system_wide_auto_memories/summaries/01_disable-auto-memory-summary.md)

**Description**: Disable system-wide Claude Code auto-memories (~/.claude/projects/) and rely exclusively on per-repo .memory/ system. Different repos require different behavior, so cross-repo memories in ~/.claude/ cause interference. Tasks: (1) Configure Claude Code settings to disable auto-memory persistence in ~/.claude/projects/, (2) Clean up or neutralize existing auto-memory files in ~/.claude/projects/ that may conflict, (3) Ensure .memory/ per-repo system is properly set up as the sole memory mechanism.

### 42. Fix /meta creating tasks at RESEARCHED status without research artifacts
- **Effort**: 1 hour
- **Status**: [COMPLETED]
- **Completed**: 2026-04-12
- **Summary**: Removed Stage 5.5 from meta-builder-agent, changed task creation to NOT STARTED status, updated skill-meta and multi-task-creation-standard.
- **Task Type**: meta
- **Research**:
  - [01_meta-research-fix.md](042_fix_meta_researched_status/reports/01_meta-research-fix.md)
- **Plan**: [01_meta-status-fix.md](042_fix_meta_researched_status/plans/01_meta-status-fix.md)
- **Summary**: [01_meta-status-fix-summary.md](042_fix_meta_researched_status/summaries/01_meta-status-fix-summary.md)

**Description**: The meta-builder-agent's Stage 5.5 (GenerateResearchArtifacts) specifies creating `01_meta-research.md` files for each task, but the LLM agent skips this step at runtime — jumping from confirmation (Stage 5) directly to state updates (Stage 6). No enforcement mechanism catches the missing files, so tasks end up at [RESEARCHED] status with no actual reports. Fix: (1) Remove Stage 5.5 from meta-builder-agent.md — interview context is pre-task metadata, not a research artifact. (2) Change Stage 6 to set status `not_started` instead of `researched`. (3) Remove artifact array references from Stage 6 state.json and TODO.md templates. (4) Update skill-meta SKILL.md expected return examples to show `not_started` status. (5) Update multi-task-creation-standard.md to remove GenerateResearchArtifacts from the compliance table. Tasks from /meta should follow the normal `/research -> /plan -> /implement` lifecycle, consistent with how `/slides` handles forcing_data.

### 41. Update talk library index and slides documentation for PowerPoint support
- **Effort**: 1 hour
- **Status**: [COMPLETED]
- **Completed**: 2026-04-12
- **Summary**: Updated talk/index.json, talk-structure.md, and CLAUDE.md to reflect dual-format (Slidev + PowerPoint) support, removing stale PPTX support planned references.
- **Task Type**: meta
- **Dependencies**: 38, 39, 40
- **Research**: [01_pptx-docs.md](041_slides_pptx_documentation/reports/01_pptx-docs.md)
- **Plan**: [01_pptx-docs.md](041_slides_pptx_documentation/plans/01_pptx-docs.md)
- **Summary**: [01_pptx-docs-summary.md](041_slides_pptx_documentation/summaries/01_pptx-docs-summary.md)

**Description**: Update `talk/index.json` to include PowerPoint templates alongside Slidev. Update `talk-structure.md` and `presentation-types.md` to mention both output formats. Update CLAUDE.md present extension section to document PowerPoint support. Ensure all references to "Slidev output" are generalized to "Slidev or PowerPoint output" where appropriate.

### 40. Update skill-slides for format-specific assembly routing
- **Effort**: 1 hour
- **Status**: [COMPLETED]
- **Completed**: 2026-04-12
- **Summary**: Added output_format extraction and format-specific routing to skill-slides SKILL.md (Stages 2, 4, 9, 11) and updated present manifest with :assemble suffix for slides implement routing.
- **Task Type**: meta
- **Dependencies**: 39
- **Research**: [01_format-routing.md](040_skill_slides_format_routing/reports/01_format-routing.md)
- **Plan**: [01_format-routing.md](040_skill_slides_format_routing/plans/01_format-routing.md)
- **Summary**: [01_format-routing-summary.md](040_skill_slides_format_routing/summaries/01_format-routing-summary.md)

**Description**: Add format-aware routing in skill-slides so the `workflow_type=assemble` step checks `forcing_data.output_format` and passes the correct variant (`assemble_slidev` or `assemble_pptx`) to the slides-agent. Update commit messages and return summaries to reflect the chosen output format. Ensure backward compatibility: if `output_format` is absent, default to Slidev.

### 39. Add PowerPoint assembly workflow to slides-agent
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-04-12
- **Summary**: Added assemble_pptx workflow branch (Stages A1-A8) to slides-agent.md with conditional routing, PPTX context references, assembly-specific error handling, and slide type reference table.
- **Task Type**: meta
- **Dependencies**: 37, 38
- **Research**: [01_pptx-assembly.md](039_pptx_agent_assembly/reports/01_pptx-assembly.md)
- **Plan**: [01_pptx-assembly.md](039_pptx_agent_assembly/plans/01_pptx-assembly.md)
- **Summary**: [01_pptx-assembly-summary.md](039_pptx_agent_assembly/summaries/01_pptx-assembly-summary.md)

**Description**: Add an `assemble_pptx` workflow branch in slides-agent that generates a `.pptx` file from the slide-mapped research report using python-pptx. Reuse existing slide pattern JSON files (conference-standard.json etc.) since slide structure is format-agnostic. Map themes (academic-clean, clinical-teal) to PPTX master slide formatting. Handle figures, tables, and speaker notes. The agent should produce a complete, buildable .pptx file in the task's output directory.

### 38. Create PowerPoint context files for talk library
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**: [01_pptx-context.md](specs/038_pptx_context_files/reports/01_pptx-context.md)
- **Plan**: [01_pptx-context.md](specs/038_pptx_context_files/plans/01_pptx-context.md)
- **Summary**: [01_pptx-context-summary.md](specs/038_pptx_context_files/summaries/01_pptx-context-summary.md)

**Description**: Create `talk/templates/pptx-project/` with python-pptx generation patterns. Create PowerPoint theme mappings translating academic-clean and clinical-teal themes to PPTX master slide specs (colors, fonts, layouts). Create `talk/patterns/pptx-generation.md` documenting python-pptx API patterns for slide creation, speaker notes, figure insertion, and table formatting. These context files guide the slides-agent when assembling PowerPoint output.

### 37. Add output format selection to /slides command
- **Effort**: 1 hour
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**: [01_format-selection.md](specs/037_slides_format_selection/reports/01_format-selection.md)
- **Plan**: [01_format-selection.md](specs/037_slides_format_selection/plans/01_format-selection.md)
- **Summary**: [01_format-selection-summary.md](specs/037_slides_format_selection/summaries/01_format-selection-summary.md)

**Description**: Insert a new Step 0.0 in the `/slides` Stage 0 forcing questions asking the user to choose between Slidev or PowerPoint output format. Store the choice as `forcing_data.output_format` (values: `slidev` or `pptx`). Update output messages and recommended workflow text to reflect the chosen format. Slidev remains the default if the user doesn't specify.

### 36. Add UCSF institutional theme to slides workflow
- **Effort**: 1 hour
- **Status**: [COMPLETED]
- **Completed**: 2026-04-12
- **Summary**: Created ucsf-institutional.json theme, registered in talk library and extensions, added option E to /slides design question.
- **Task Type**: meta
- **Research**:
  - [01_teammate-a-findings.md](036_ucsf_institutional_theme_slides/reports/01_teammate-a-findings.md)
  - [01_teammate-b-findings.md](036_ucsf_institutional_theme_slides/reports/01_teammate-b-findings.md)
  - [01_teammate-c-findings.md](036_ucsf_institutional_theme_slides/reports/01_teammate-c-findings.md)
  - [01_teammate-d-findings.md](036_ucsf_institutional_theme_slides/reports/01_teammate-d-findings.md)
  - [01_team-research.md](036_ucsf_institutional_theme_slides/reports/01_team-research.md)
- **Plan**: [01_ucsf-theme.md](036_ucsf_institutional_theme_slides/plans/01_ucsf-theme.md)
- **Summary**: [01_ucsf-theme-summary.md](036_ucsf_institutional_theme_slides/summaries/01_ucsf-theme-summary.md)

**Description**: Create a UCSF institutional Slidev theme (`ucsf-institutional.json`) extracted from `examples/test-files/UCSF_ZSFG_Template_16x9.pptx`. UCSF brand palette: navy #052049 (dark/heading), #0093D0 (primary accent blue), #16A0AC (teal), #32A03E (green), #A238BA (purple), #C32882 (pink), #6C61D0 (violet). Typography: Garamond headings, Arial body. Register theme in talk library index (`talk/index.json`), add as option E in `/slides --design` D1 question, and update any theme reference documentation so the new theme is selectable during presentation design.

### 35. Create Zed keybindings cheat sheet in Typst
- **Effort**: 2 hours
- **Status**: [COMPLETED]
- **Task Type**: typst
- **Research**:
  - [01_teammate-a-findings.md](035_zed_keybindings_cheat_sheet/reports/01_teammate-a-findings.md)
  - [01_teammate-b-findings.md](035_zed_keybindings_cheat_sheet/reports/01_teammate-b-findings.md)
  - [01_teammate-c-findings.md](035_zed_keybindings_cheat_sheet/reports/01_teammate-c-findings.md)
  - [01_teammate-d-findings.md](035_zed_keybindings_cheat_sheet/reports/01_teammate-d-findings.md)
  - [01_team-research.md](035_zed_keybindings_cheat_sheet/reports/01_team-research.md)
- **Plan**: [01_keybindings-cheat-sheet.md](035_zed_keybindings_cheat_sheet/plans/01_keybindings-cheat-sheet.md)
- **Summary**: [01_keybindings-cheat-sheet-summary.md](035_zed_keybindings_cheat_sheet/summaries/01_keybindings-cheat-sheet-summary.md)

**Description**: Use docs/general/keybindings.md to create a cheat sheet for learning Zed keybindings, organized from most basic/fundamental to less used or specific. Output as a Typst document following a natural and well-organized legend of different keybindings and their abilities

### 34. Improve Slidev review pipeline to catch rendering issues during first implementation
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**:
  - [01_teammate-a-findings.md](034_improve_slidev_review_pipeline/reports/01_teammate-a-findings.md)
  - [01_teammate-b-findings.md](034_improve_slidev_review_pipeline/reports/01_teammate-b-findings.md)
  - [01_teammate-c-findings.md](034_improve_slidev_review_pipeline/reports/01_teammate-c-findings.md)
  - [01_teammate-d-findings.md](034_improve_slidev_review_pipeline/reports/01_teammate-d-findings.md)
  - [01_team-research.md](034_improve_slidev_review_pipeline/reports/01_team-research.md)
- **Plan**: [01_improve-slidev-pipeline.md](034_improve_slidev_review_pipeline/plans/01_improve-slidev-pipeline.md)
- **Summary**: [01_implementation-summary.md](034_improve_slidev_review_pipeline/summaries/01_implementation-summary.md)

**Description**: Improve the Slidev implementation pipeline to catch rendering issues during first implementation rather than requiring manual post-hoc debugging. Based on troubleshooting of examples/epi-slides, the following issues were only caught post-implementation: (1) lz-string CJS/ESM incompatibility under pnpm strict layout crashing all mermaid slides, (2) Slidev CLI version mismatch between global nix binary (v52) and project package.json (v0.49), (3) Shiki syntax highlighter overriding custom theme inline code styles with dark backgrounds, (4) Vue components inside markdown pipe tables failing silently, (5) `<br/>` tags in mermaid node labels consumed by Vue/MDC parser before reaching mermaid, (6) `npx slidev` fails because the npm package name is `@slidev/cli` not `slidev` — Zed tasks and export scripts must use `npx @slidev/cli`. Update the slides implementation agent, planner context, Playwright verification template, and project scaffolding so these classes of errors are prevented or caught automatically during implementation. Deliverables should include: a Slidev project template (package.json, .npmrc, vite.config.ts, lz-string-esm.js) that the implementation agent copies when scaffolding new decks; updated slidev-pitfalls.md with all six issue classes; and an enhanced Playwright verification script that checks for console errors (not just visible error text)

### 33. Improve documentation to present core agent system and extension architecture
- **Effort**: 4 hours
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**:
  - [01_teammate-a-findings.md](033_improve_docs_core_system_extensions/reports/01_teammate-a-findings.md)
  - [01_teammate-b-findings.md](033_improve_docs_core_system_extensions/reports/01_teammate-b-findings.md)
  - [01_teammate-c-findings.md](033_improve_docs_core_system_extensions/reports/01_teammate-c-findings.md)
  - [01_teammate-d-findings.md](033_improve_docs_core_system_extensions/reports/01_teammate-d-findings.md)
  - [01_team-research.md](033_improve_docs_core_system_extensions/reports/01_team-research.md)
- **Plan**: [01_improve-docs-extensions.md](033_improve_docs_core_system_extensions/plans/01_improve-docs-extensions.md)

**Description**: Improve README.md and supporting documentation to better present the Claude Code core system and the extensions used to augment it for writing grants, developing epi studies, building presentation slides, and other utilities. Documentation should highlight the range of commands the .claude/ agent system provides with the task management workflow system at the core

### 32. Update documentation to reflect current .claude/ configuration
- **Effort**: 3 hours
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**:
  - [01_teammate-a-findings.md](032_update_docs_from_claude_diff/reports/01_teammate-a-findings.md)
  - [01_teammate-b-findings.md](032_update_docs_from_claude_diff/reports/01_teammate-b-findings.md)
  - [01_teammate-c-findings.md](032_update_docs_from_claude_diff/reports/01_teammate-c-findings.md)
  - [01_teammate-d-findings.md](032_update_docs_from_claude_diff/reports/01_teammate-d-findings.md)
  - [01_team-research.md](032_update_docs_from_claude_diff/reports/01_team-research.md)
- **Plan**: [01_update-docs-config.md](032_update_docs_from_claude_diff/plans/01_update-docs-config.md)
- **Summary**: [01_update-docs-summary.md](032_update_docs_from_claude_diff/summaries/01_update-docs-summary.md)

**Description**: Review git diff of .claude/ changes and update all documentation to accurately reflect the current state without historical declarations (documentation should describe current reality, not mention what changed)

### 29. Conference talk walkthrough of the epi-study demo
- **Effort**: 9.5 hours
- **Status**: [COMPLETED]
- **Completed**: 2026-04-11
- **Summary**: 14-slide Slidev conference deck with working PDF export via Playwright. Fixed slide 14 footer overlap and confirmed all Mermaid diagrams render correctly.
- **Task Type**: slides
- **Research**:
  - [01_talk-research.md](029_talk_epi_study_walkthrough/reports/01_talk-research.md)
  - [02_talk-research.md](029_talk_epi_study_walkthrough/reports/02_talk-research.md)
- **Plan**: [02_talk-assembly.md](029_talk_epi_study_walkthrough/plans/02_talk-assembly.md)
- **Summary**: [02_talk-assembly-summary.md](029_talk_epi_study_walkthrough/summaries/02_talk-assembly-summary.md)

**Description**: Conference talk (15-20 min) walking through `zed/examples/epi-study/` — the synthetic RCT demo (ketamine-assisted therapy vs TAU for methamphetamine use disorder, N=200, adjusted OR=3.29) — as an end-to-end showcase of the `/epi` Claude Code workflow for a mixed clinical/informatics audience. Balance tooling narrative, CONSORT/methods rigor, and the headline finding; emphasize reproducibility (deterministic seeds, base-R fallbacks).
