---
next_project_number: 35
---

# Task List

## Tasks

### 34. Improve Slidev review pipeline to catch rendering issues during first implementation
- **Effort**: 3 hours
- **Status**: [RESEARCHED]
- **Task Type**: meta
- **Research**:
  - [01_teammate-a-findings.md](034_improve_slidev_review_pipeline/reports/01_teammate-a-findings.md)
  - [01_teammate-b-findings.md](034_improve_slidev_review_pipeline/reports/01_teammate-b-findings.md)
  - [01_teammate-c-findings.md](034_improve_slidev_review_pipeline/reports/01_teammate-c-findings.md)
  - [01_teammate-d-findings.md](034_improve_slidev_review_pipeline/reports/01_teammate-d-findings.md)
  - [01_team-research.md](034_improve_slidev_review_pipeline/reports/01_team-research.md)

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


## Recommended Order

1. **33** -> research (independent)
