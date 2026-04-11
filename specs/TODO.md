---
next_project_number: 34
---

# Task List

## Tasks

### 33. Improve documentation to present core agent system and extension architecture
- **Effort**: 4 hours
- **Status**: [NOT STARTED]
- **Task Type**: meta

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
- **Status**: [PARTIAL]
- **Task Type**: slides
- **Research**:
  - [01_talk-research.md](029_talk_epi_study_walkthrough/reports/01_talk-research.md)
  - [02_talk-research.md](029_talk_epi_study_walkthrough/reports/02_talk-research.md)
- **Plan**: [02_talk-assembly.md](029_talk_epi_study_walkthrough/plans/02_talk-assembly.md)
- **Summary**: [02_talk-assembly-summary.md](029_talk_epi_study_walkthrough/summaries/02_talk-assembly-summary.md)

**Description**: Conference talk (15-20 min) walking through `zed/examples/epi-study/` — the synthetic RCT demo (ketamine-assisted therapy vs TAU for methamphetamine use disorder, N=200, adjusted OR=3.29) — as an end-to-end showcase of the `/epi` Claude Code workflow for a mixed clinical/informatics audience. Balance tooling narrative, CONSORT/methods rigor, and the headline finding; emphasize reproducibility (deterministic seeds, base-R fallbacks).


## Recommended Order

1. **33** -> research (independent)
