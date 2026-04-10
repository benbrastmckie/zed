# Research Report: Task #8 — Teammate D Findings (Horizons / Strategic Direction)

**Task**: 8 — Split office-workflows.md into workflows/ directory
**Role**: Teammate D — Strategic direction and long-term alignment
**Started**: 2026-04-10
**Completed**: 2026-04-10
**Effort**: Small research
**Sources/Inputs**: specs/TODO.md, docs/README.md, docs/office-workflows.md, docs/agent-system/workflow.md, docs/agent-system/commands.md, docs/agent-system/README.md, .claude/commands/ survey

---

## Docs Reorg Arc Context (Tasks 6/7/8 Trajectory)

Tasks 1-8 trace a clear documentation maturation arc:

| Task | Action | Pattern |
|------|--------|---------|
| 1 | Initial docs/ scaffold from scratch | Creation |
| 2 | Add keybindings to docs/ | Enrichment |
| 3 | Merge zed-claude-office-guide.md into docs/ | Consolidation |
| 4 | Merge config-report.md into docs/ (planned) | Consolidation |
| 6 | Expand agent-system.md → docs/agent-system/ directory | Directory extraction |
| 7 | Revise installation.md for macOS (drop NixOS) | Narrowing scope / audience |
| 8 | Split office-workflows.md → docs/workflows/ directory | Directory extraction |

The pattern is **repeated directory extraction**: a single flat file grows dense enough to warrant its own subdirectory. Task 6 did this for agent-system.md (→ docs/agent-system/ with 5 files). Task 8 is the next application of the same pattern to office-workflows.md.

**The endgame** is a docs/ root that is a navigation hub — thin files with short orientation paragraphs that point into subdirectories. The two subdirectories serve different audiences:
- `docs/agent-system/` — internal mechanics, technical depth, how the system works
- `docs/workflows/` — user-facing task flows, "how do I do X?", progressive disclosure

This split is deliberate and load-bearing. It separates **reference documentation** (agent-system/) from **how-to documentation** (workflows/).

---

## Future Workflows Inventory

Surveying all 24 slash commands in .claude/commands/, organized by whether they constitute a user-facing "workflow" (a goal-oriented sequence a user would follow):

### Core Task Lifecycle (agent system — already in workflow.md)
| Command | Description | Workflow? |
|---------|-------------|-----------|
| /task | Create / manage tasks | Yes — task lifecycle |
| /research | Investigate a task | Yes — task lifecycle |
| /plan | Create phased plan | Yes — task lifecycle |
| /implement | Execute plan | Yes — task lifecycle |
| /todo | Archive completed tasks | Yes — task lifecycle |
| /revise | Create new plan version | Yes — revision workflow |
| /review | Codebase analysis | Yes — review workflow |

### Maintenance Workflows
| Command | Description | Workflow? |
|---------|-------------|-----------|
| /spawn | Unblock a blocked task | Yes — blocker resolution |
| /errors | Analyze errors, create fix plans | Yes — error recovery |
| /fix-it | Scan tags, create tasks | Yes — tag cleanup |
| /refresh | Kill orphaned processes | Utility (thin) |
| /meta | Modify .claude/ system | Yes — system evolution |
| /tag | Semantic version tag | Yes — release workflow |
| /merge | Create PR/MR | Yes — release workflow |

### Document Workflows (currently in office-workflows.md)
| Command | Description | Workflow? |
|---------|-------------|-----------|
| /edit | DOCX edit with tracked changes | Yes — Word editing |
| /convert | PDF/DOCX/Markdown conversion | Yes — document conversion |
| /table | Spreadsheet → LaTeX/Typst | Yes — table extraction |
| /slides | PPTX → Beamer/Polylux/Touying | Yes — presentation conversion |
| /scrape | PDF annotation extraction | Yes — annotation review |

### Research & Grant Workflows
| Command | Description | Workflow? |
|---------|-------------|-----------|
| /grant | Grant proposal drafting | Yes — grant workflow |
| /budget | Grant budget spreadsheet | Yes — grant workflow |
| /timeline | Research timeline planning | Yes — grant workflow |
| /funds | Funding landscape analysis | Yes — grant workflow |
| /talk | Research talk assembly | Yes — presentation workflow |

### Memory Workflow
| Command | Description | Workflow? |
|---------|-------------|-----------|
| /learn | Add to memory vault | Yes — knowledge capture |

**Summary**: Roughly 22 of 24 commands constitute user-facing workflows. The current content splits naturally into three clusters:
1. **Agent/task lifecycle** — already in docs/agent-system/workflow.md
2. **Office document workflows** — currently in docs/office-workflows.md
3. **Research & grant workflows** — currently undocumented at the user-facing level

---

## Structural Recommendation

### Where workflows/ Should Live

**Recommendation: `docs/workflows/` as a sibling of `docs/agent-system/`**, not nested inside it.

Rationale:
1. **Audience separation**: docs/agent-system/ is for people who want to understand the system internals (checkpoint execution, session IDs, routing, architecture). docs/workflows/ is for people who want to accomplish a goal ("How do I edit a Word document?"). These audiences overlap but are distinct.
2. **Cross-cutting concern**: The workflows/ directory will contain agent workflows (task lifecycle), document workflows, and grant workflows. Not all are "agent system" workflows in the internal sense — document and grant workflows are end-user tasks that happen to use commands. Nesting workflows/ inside agent-system/ would conflate user-facing how-tos with internal system documentation.
3. **Precedent**: Task 6 already created docs/agent-system/ as technical depth. The natural complement is a user-facing workflows/ at the same level.
4. **Navigation symmetry**: The docs/README.md currently has 5 entries. Adding workflows/ as a 6th top-level entry is clean. The current agent-system/ entry would shorten to "internal architecture and command reference", while workflows/ becomes "how to accomplish goals".

### Proposed docs/ Structure After Task 8

```
docs/
├── README.md               # Navigation hub (update to add workflows/)
├── installation.md         # Install Zed, Claude Code, MCP tools (task 7)
├── keybindings.md          # Keyboard shortcuts
├── settings.md             # Configuration reference
├── agent-system/           # Internal mechanics (unchanged)
│   ├── README.md
│   ├── workflow.md         # MOVE to docs/workflows/agent-workflow.md
│   ├── commands.md
│   ├── context-and-memory.md
│   ├── architecture.md
│   └── zed-agent-panel.md
└── workflows/              # NEW: user-facing how-tos
    ├── README.md           # Table of contents with descriptions
    ├── agent-workflow.md   # Moved from agent-system/workflow.md
    ├── word-editing.md     # From office-workflows.md (edit, batch, new-doc)
    ├── document-conversion.md  # From office-workflows.md (/convert, /scrape)
    ├── spreadsheet-tables.md   # From office-workflows.md (/table, direct editing)
    ├── presentations.md    # From office-workflows.md (/slides)
    └── (future: grant-workflow.md, talk-workflow.md)
```

**Note on moving workflow.md**: The task description explicitly says to move docs/agent-system/workflow.md into the new workflows/ folder. The remaining commands.md in agent-system/ can link to the new location. This is the right call — workflow.md is the most user-facing document currently inside agent-system/, and it will be more discoverable in workflows/.

### Extensibility Design

The workflows/ directory should be extensible via:
1. **One file per workflow cluster** (not one per command): The grain should be "a goal a user wants to accomplish" not "one command". /grant, /budget, /timeline, /funds naturally cluster into a single `grant-writing.md` workflow.
2. **README.md as the table of contents**: Every new workflow file gets a row in the README table — name, one-line description, key commands. New extensions (e.g., epidemiology, present) add new rows.
3. **Flat, not nested**: workflows/ should remain a single-level directory. No sub-subdirectories. If content grows very large (e.g., a 500-line grant workflow), split into sections within the file rather than creating a subdirectory.

---

## Alignment with Project Trajectory

This task continues two clear strategic directions:

**Direction 1 — Progressive documentation maturity**: The project moved from "put everything in one file" (tasks 1-3) to "flatten into docs/" (task 6) to "extract into subdirectories" (tasks 6, 8). The next step after task 8 is likely:
- Task 4 completion (merge config-report.md), finishing the consolidation phase
- Possible docs/workflows/grant-workflow.md (the grant/present commands are powerful but undocumented at user level)

**Direction 2 — Audience-aware documentation**: Tasks 6 and 7 both show increasing attention to audience (task 7 drops NixOS, task 6 adds progressive disclosure). The workflows/ directory is the logical completion of this move — a section that speaks exclusively to "I want to get X done" rather than "I want to understand how the system works."

**Anticipated future workflows** (not yet documented anywhere in docs/):
- `grant-writing.md` — /grant, /budget, /timeline, /funds
- `research-talk.md` — /talk
- `memory-and-learning.md` — /learn, .memory/ vault
- `maintenance.md` — /errors, /fix-it, /refresh, /spawn

---

## Confidence Level

**High confidence** on:
- workflows/ as sibling of agent-system/, not nested inside it
- Moving workflow.md into workflows/ (matches task description and audience logic)
- One-file-per-cluster grain (not one-per-command)
- Flat directory structure (no sub-subdirectories)
- Four office-workflow files: word-editing, document-conversion, spreadsheet-tables, presentations

**Medium confidence** on:
- Exact file names (will depend on cross-linking conventions established by other teammates)
- Whether docs/office-workflows.md is deleted entirely or redirected (I recommend delete after splitting; other teammates may have opinions on redirect stubs)
- Whether maintenance-type workflows (errors, fix-it, spawn) belong in workflows/ now or in a future task

**Low confidence** on:
- Exact line between agent-system/ and workflows/ for the commands.md file (it might want to move too, or might be right where it is as a reference document)
