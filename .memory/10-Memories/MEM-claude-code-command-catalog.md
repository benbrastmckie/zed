---
title: "Claude Code 25-command catalog with usage"
created: 2026-04-15
tags: [WORKFLOW, claude-code, commands, reference]
topic: "agent-system/commands"
source: "docs/agent-system/commands.md, docs/workflows/"
modified: 2026-04-15
---

# Claude Code Command Catalog

## Lifecycle (core 6)

| Command | Usage | Description |
|---------|-------|-------------|
| `/task` | `/task "Description"` | Create task; flags: --recover, --expand, --sync, --abandon, --review |
| `/research` | `/research N [focus] [--team] [--remember]` | Investigate task, produce report; multi-task: `5, 7-9` |
| `/plan` | `/plan N [--team]` | Create phased plan from research; slides tasks route to skill-slide-planning |
| `/implement` | `/implement N [--team] [--force]` | Execute plan phase-by-phase, resumable from interruption |
| `/revise` | `/revise N ["guidance"]` | Create new plan version or update task description |
| `/todo` | `/todo [--dry-run]` | Archive completed/abandoned tasks, update CHANGE_LOG+ROADMAP |

## Review & Recovery

| Command | Usage | Description |
|---------|-------|-------------|
| `/review` | `/review` | Codebase quality assessment |
| `/spawn` | `/spawn N ["blocker"]` | Research blocker, create unblocking tasks |
| `/errors` | `/errors` | Analyze error patterns, auto-create fix plans |
| `/fix-it` | `/fix-it [PATH...]` | Scan for FIX:/TODO:/NOTE: tags, create tasks interactively |

## System & Housekeeping

| Command | Usage | Description |
|---------|-------|-------------|
| `/refresh` | `/refresh [--dry-run] [--force]` | Clean orphaned processes and stale files |
| `/meta` | `/meta` | System builder for .claude/ changes (creates tasks, never implements) |
| `/tag` | `/tag --patch\|--minor\|--major` | Semantic version tag (user-only) |
| `/merge` | `/merge [--draft]` | Create PR/MR for current branch |

## Memory
| `/learn` | `/learn "text"\|file\|dir\|--task N` | Add to memory vault with deduplication |

## Documents
| `/convert` | `/convert file.pdf\|.docx\|.md` | Format conversion; `--format beamer\|polylux\|touying` for PPTX |
| `/table` | `/table data.xlsx [--format typst]` | Spreadsheet to LaTeX/Typst table |
| `/scrape` | `/scrape paper.pdf` | Extract PDF annotations to Markdown/JSON |
| `/edit` | `/edit file.docx "instruction"` | Edit DOCX in-place with tracked changes; `--new` to create |

## Research & Grants
| `/grant` | `/grant "Desc" \| N --draft \| N --budget` | Grant proposal lifecycle |
| `/budget` | `/budget "Desc"` | Budget spreadsheet with justification (XLSX) |
| `/timeline` | `/timeline "Desc"` | Research timeline with WBS/PERT/Gantt |
| `/funds` | `/funds "Desc"` | Funding landscape analysis |
| `/slides` | `/slides "Desc"\|N\|file [--critic]` | Research talks; 5 modes: CONFERENCE/SEMINAR/DEFENSE/POSTER/JOURNAL_CLUB |

## Epidemiology
| `/epi` | `/epi "Desc"\|N\|file` | R-based epi study with 10 forcing questions |

## Key Patterns
- **Multi-task syntax**: `/research 5, 7-9` runs tasks in parallel
- **--team flag**: Spawns 2-4 parallel teammates (~5x tokens)
- **--remember flag**: Searches .memory/ vault before research
- **Skill keywords**: Natural language also activates skills (e.g., "research and plan task 14")
- **Forcing questions**: /grant, /budget, /funds, /timeline, /slides, /epi ask scoping questions before task creation

## Connections
<!-- Add links to related memories using [[filename]] syntax -->
