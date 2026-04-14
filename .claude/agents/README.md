# Agents

Agent specifications for the Claude Code task management system. Each `.md` file defines a single agent's system prompt, tools, and execution flow.

## Core Agents (7)

| Agent | Purpose | Model |
|-------|---------|-------|
| general-research-agent | General web/codebase research | opus |
| general-implementation-agent | General file implementation | default |
| planner-agent | Implementation plan creation | opus |
| meta-builder-agent | System building and meta tasks | default |
| code-reviewer-agent | Code quality assessment and review | default |
| reviser-agent | Plan revision with research synthesis | opus |
| spawn-agent | Blocker analysis and task decomposition | opus |

## Epidemiology Extension (2)

| Agent | Purpose | Model |
|-------|---------|-------|
| epi-research-agent | Study design, analysis planning, causal inference | opus |
| epi-implement-agent | R code implementation, statistical modeling | default |

## Filetypes Extension (6)

| Agent | Purpose | Model |
|-------|---------|-------|
| filetypes-router-agent | Format detection and routing | default |
| document-agent | Document format conversion (PDF/DOCX/Markdown) | default |
| docx-edit-agent | In-place DOCX editing with tracked changes | default |
| spreadsheet-agent | Spreadsheet to LaTeX/Typst table conversion | default |
| presentation-agent | Presentation extraction and slide generation | default |
| scrape-agent | PDF annotation extraction | default |

## LaTeX Extension (2)

| Agent | Purpose | Model |
|-------|---------|-------|
| latex-research-agent | LaTeX documentation research | opus |
| latex-implementation-agent | LaTeX document implementation | default |

## Present Extension (8)

| Agent | Purpose | Model |
|-------|---------|-------|
| grant-agent | Grant proposal research and drafting | opus |
| budget-agent | Grant budget spreadsheet generation | opus |
| timeline-agent | Research project timeline planning | opus |
| funds-agent | Research funding landscape analysis | opus |
| slides-research-agent | Research talk material synthesis | opus |
| pptx-assembly-agent | PowerPoint presentation assembly | opus |
| slidev-assembly-agent | Slidev presentation assembly | opus |
| slide-planner-agent | Slide plan with design questions | opus |
| slide-critic-agent | Interactive slide critique with rubric evaluation | opus |

## Python Extension (2)

| Agent | Purpose | Model |
|-------|---------|-------|
| python-research-agent | Python/library research | opus |
| python-implementation-agent | Python implementation | default |

## Typst Extension (2)

| Agent | Purpose | Model |
|-------|---------|-------|
| typst-research-agent | Typst documentation research | opus |
| typst-implementation-agent | Typst document implementation | default |

## Total: 30 agents

## See also

- [CLAUDE.md](../CLAUDE.md) -- Skill-to-agent mapping table
- [README.md](../README.md) -- Architecture navigation hub
