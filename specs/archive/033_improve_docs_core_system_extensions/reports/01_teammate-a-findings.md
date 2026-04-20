# Research Report: Task #33 (Teammate A - Primary Angle)

**Task**: 033 - Improve README.md and supporting documentation to better present the Claude Code core system and extensions
**Started**: 2026-04-11T00:00:00Z
**Completed**: 2026-04-11T00:30:00Z
**Effort**: ~1 hour
**Dependencies**: None
**Sources/Inputs**: README.md, docs/README.md, docs/agent-system/README.md, docs/workflows/README.md, .claude/README.md, .claude/CLAUDE.md, docs/agent-system/commands.md, docs/workflows/agent-lifecycle.md
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- README.md is well-structured but buries the task lifecycle -- the core of the system -- inside a flat command table that treats lifecycle and domain commands as equal-weight items
- The "core + extensions" architecture is not surfaced as the organizing concept; a reader cannot grasp from README.md alone that the system has a stable lifecycle core that domain extensions augment
- docs/agent-system/README.md successfully conveys the extension story but is separated from README.md by two clicks, making most users miss it
- Recommended approach: restructure README.md's command section around the task lifecycle as the primary story, with extensions introduced as domain-specific augmentations; add an "Architecture in one paragraph" prose section; and let docs/README.md and docs/agent-system/README.md serve as amplifiers rather than primary sources

---

## Key Findings

### Finding 1: README.md presents commands as an unordered catalog, not a workflow story

The current "Claude Code Commands" section in README.md has two tables -- "Core commands for R and Python development" and "Also available -- domain extensions" -- but neither table conveys progression. The lifecycle commands (`/task`, `/research`, `/plan`, `/implement`, `/todo`) appear alongside utility commands (`/review`, `/learn`, `/convert`) in the first table with no indication that they form a sequential state machine.

The separation into "core" and "domain extensions" is a good instinct, but the framing emphasizes "what exists" not "how to use it." A new reader's mental model after reading this section: "there are some commands." The intended mental model should be: "tasks move through a lifecycle; I use `/task`, `/research`, `/plan`, `/implement`, `/todo` to drive that; and domain extensions add specialized capabilities on top."

### Finding 2: The task lifecycle is never explained in README.md

The state machine (`[NOT STARTED] -> [RESEARCHING] -> [RESEARCHED] -> [PLANNING] -> [PLANNED] -> [IMPLEMENTING] -> [COMPLETED]`) is not mentioned anywhere in README.md. This is the conceptual spine of the entire system. Without it, users don't understand:
- Why there are separate `/research`, `/plan`, and `/implement` commands (instead of one command)
- That you can stop between phases and resume later
- That each command produces a structured artifact committed to git

The state machine is documented thoroughly in `docs/workflows/agent-lifecycle.md` and mentioned briefly in `docs/agent-system/README.md` ("you can stop between any two steps and resume later"), but it is completely absent from README.md -- the first document most users read.

### Finding 3: Extensions are described as an afterthought ("Also available")

The phrase "Also available -- domain extensions" in the README.md command table positions the extensions as supplementary or optional add-ons of lower status. But `/epi`, `/grant`, `/slides`, `/budget`, `/funds`, `/timeline` are full first-class capabilities -- each with its own agent, skill, context library, and workflow guide. They represent a significant part of the system's value.

The current structure also doesn't group extensions by domain. The reader sees a flat list: `/epi`, `/grant`, `/budget`, `/funds`, `/timeline`, `/slides`. Without grouping, the relationship between `/grant`, `/budget`, `/funds`, `/timeline`, and `/slides` (all under the "present" extension) and `/epi` (a separate epidemiology extension) is invisible.

### Finding 4: The "Architecture in one paragraph" gap

README.md has no prose section that explains the system's conceptual model in plain language. The closest it comes is the AI Integration section ("Claude Code ... Helps you write, test, debug, and refactor R and Python code through the full project lifecycle"), but this describes Claude Code generically rather than explaining the specific architecture: that there is a task management system backed by `specs/TODO.md` and `specs/state.json`, that tasks move through research -> plan -> implement phases, that each phase is handled by a specialized agent, and that domain extensions layer specialized knowledge and commands on top of the core.

### Finding 5: docs/agent-system/README.md has good content but wrong placement

`docs/agent-system/README.md` contains the clearest single explanation of the extension architecture:

> "The agent system includes domain-specific extensions that provide specialized research and implementation capabilities"

It also has the best quick-start walkthrough showing the task lifecycle in action (steps 1-5 showing `/task`, `/research`, `/plan`, `/implement`). However, this content is two clicks away from README.md. Users who don't explore into `docs/` will never encounter it.

### Finding 6: .claude/README.md is agent-facing internals, not user narrative

The `.claude/README.md` file is well-designed as an architecture hub for agents and power users, with ASCII diagrams of the commands -> skills -> agents pipeline and an extension table. However, its content is not appropriate for README.md: it lists agents, skills, and context directories rather than workflows users care about. The conceptual gap is: `.claude/README.md` explains _how the system is built_, while README.md should explain _how to use it_. These are different stories.

### Finding 7: docs/README.md is accurate but doesn't reinforce the core narrative

`docs/README.md` organizes by section (General, Agent System, Workflows) with accurate descriptions. It doesn't describe the core/extension architecture. A user reading docs/README.md looking for "how does the AI system work" would navigate to docs/agent-system/README.md, which is the right destination -- but docs/README.md doesn't prime them with the framing.

---

## Recommended Approach

### Change 1: Restructure the command section in README.md around the task lifecycle

**Current structure**:
```
## Claude Code Commands
[flat table: research, plan, implement, review, learn, convert]
[flat table: epi, grant, budget, funds, timeline, slides]
```

**Proposed structure**:
```
## Claude Code

One paragraph explaining: tasks are tracked in specs/TODO.md, move through
research -> plan -> implement, each step writes an artifact and commits.
Extensions add domain capabilities on top.

### Task Lifecycle (core)
[table showing /task, /research, /plan, /implement, /todo with lifecycle framing]

### Domain Extensions
[grouped by domain with brief intro]

**Research & Grants (present extension)**
[table: /grant, /budget, /funds, /timeline, /slides]

**Epidemiology (epi extension)**
[table: /epi]

**Document Tools (filetypes extension)**
[table: /convert, /edit, /table, /scrape]

**Knowledge & Memory (memory extension)**
[table: /learn]

### Housekeeping
[table: /review, /fix-it, /errors, /refresh, /meta, /revise, /spawn, /merge, /tag]
```

This change alone makes the architecture visible from the first place users land.

### Change 2: Add an "Architecture in 3 sentences" callout near the top

A short prose block (3-4 sentences) before or within the Claude Code section:

> Claude Code manages work through a task lifecycle: you create a task, research it, plan it, implement it, and archive it. Each step is handled by a specialized agent and produces a structured artifact committed to git -- so you can stop and resume at any point. Domain extensions (epidemiology, grant writing, presentation slides, document conversion) layer specialized commands, agents, and knowledge on top of this core lifecycle without changing how it works.

This gives users a mental model before they see any commands.

### Change 3: Surface the lifecycle example in README.md

`docs/agent-system/README.md` has a clean 5-step "your first task" example. A condensed version of this belongs in README.md, immediately after the architecture prose:

```bash
/task "Analyze vaccine effectiveness in elderly cohorts"
/research 1
/plan 1
/implement 1
/todo       # archive when done
```

This shows the pattern concretely before listing all 25 commands.

### Change 4: Rename "Also available" to domain-grouped sections with purpose statements

Each extension group should have a 1-sentence purpose statement before the command table:

- **Research & Grants**: "Develop NIH/NSF proposals, generate budgets, plan timelines, survey funding sources, and create research talks."
- **Epidemiology**: "Design and run epidemiological studies in R with causal inference, statistical modeling, and STROBE-compliant reporting."
- **Document Tools**: "Convert between PDF/DOCX/Markdown, edit Word documents with tracked changes, extract spreadsheet tables, and pull annotations from PDFs."
- **Memory**: "Persist knowledge across sessions; augment research with prior findings."

### Change 5: docs/README.md - add one framing sentence to Agent System description

Current: "Claude Code and Zed AI integration: the Agent Panel, the Claude Code terminal interface, the command catalog, context and memory layers, and the three-layer execution architecture."

Proposed addition: append "The core lifecycle (task -> research -> plan -> implement) is always available; domain extensions for epidemiology, grants, and document tools augment it."

This primes readers with the right mental model before they click into docs/agent-system/README.md.

### Change 6: docs/agent-system/README.md - move "quick start: your first task" earlier

Currently, the "quick start: your first task" section appears near the bottom of docs/agent-system/README.md, after the two AI systems comparison table, the navigation table, and the extensions list. The lifecycle walkthrough (steps 1-5) is the most important piece of content in that document -- it should appear first, before navigation details.

Proposed reordering:
1. Brief opening (current)
2. Quick start: your first task (currently near bottom -- move here)
3. Two AI systems comparison
4. Extensions
5. Navigation files
6. See also

---

## Evidence and Examples

### README.md current "Claude Code Commands" section (lines 71-97)

The section begins: "Claude Code provides structured research and development workflows." The first table lists 6 "core" commands without lifecycle context. The second table lists 6 domain commands with "Also available" framing. Neither table explains relationships between commands or the state machine.

By contrast, `docs/workflows/agent-lifecycle.md` opens with:

> "Seven commands drive the Claude Code task lifecycle... Learn these first; the remaining 18 commands in commands.md layer on top."

This is the right framing. It should propagate back to README.md.

### docs/agent-system/commands.md section grouping (as a positive model)

`docs/agent-system/commands.md` is well-organized: it groups commands into "Lifecycle," "Review & Recovery," "System & Housekeeping," "Memory," "Documents," "Research & Grants," and "Epidemiology." This grouping makes the architecture visible. README.md should adopt a simplified version of this same grouping rather than the current two-table structure.

### Extension framing gap in README.md

The current README.md intro says: "Domain extensions for epidemiology research, grant development, memory capture, and Office document editing are also available." The phrase "are also available" is the clearest evidence that extensions are positioned as optional additions rather than first-class capabilities. Compare with `.claude/README.md` which lists extensions with explicit domain descriptions and links.

### The "quick start example" in docs/agent-system/README.md (lines 50-72)

This is the most user-friendly content in the entire documentation set. It demonstrates the entire lifecycle with a concrete example task. This level of concreteness is missing from README.md.

---

## Confidence Level

**High confidence**:
- The task lifecycle is absent from README.md and should be the organizing frame
- "Also available" framing underserves the extensions
- A 3-sentence architecture prose block is missing and would help enormously

**Medium confidence**:
- The specific grouping structure for the command section (exactly how to split lifecycle / domain / housekeeping in README.md) may benefit from input from Teammate B (who may have a different angle on what new users most need to see)
- The exact location of the lifecycle example relative to the command tables

**Low confidence**:
- Whether `docs/workflows/README.md` needs structural changes (current organization is reasonable; the decision guide at the bottom is effective)
- Whether `.claude/README.md` needs any changes at all (it's correctly agent-facing; changing it risks confusing its intended audience)

---

## Context Extension Recommendations

- **Topic**: Core/extension architecture for README navigation
- **Gap**: No context file documents the expected narrative arc for README.md -- what story it should tell and in what order
- **Recommendation**: No new context file needed; the architectural principle (lifecycle as core, extensions as domain augmentations) is captured in `.claude/README.md` and could inform a revision guide. This is primarily a documentation restructuring task, not a context gap.
