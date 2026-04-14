# Grant Development

Develop research proposals, budgets, timelines, funding analyses, and research talks. These commands use a **forcing-questions pattern**: they ask clarifying questions before creating the task, so the resulting work is well-scoped from the start.

> **Requires the `present` extension.** Ensure the extension is loaded before using these commands.

## Decision guide

| I want to... | Use |
|---|---|
| Start a grant proposal | `/grant "Description"` |
| Draft narrative sections for an existing grant | `/grant N --draft` |
| Build a budget with justification | `/budget` or `/grant N --budget` |
| Plan a research project timeline | `/timeline` |
| Explore funding sources for a research area | `/funds` |
| Prepare slides for a research talk | `/slides` |

## Starting a grant proposal

```
/grant "NIH R01 on neural mechanisms of decision-making"
```

Creates a grant task and stops at `[NOT STARTED]`. The forcing questions ask about the funder, mechanism, deadline, and key aims. From there, use the normal lifecycle:

```
/research 42          # investigate funder priorities, related grants
/plan 42              # design the proposal structure
/grant 42 --draft     # draft narrative sections
/grant 42 --budget    # develop the budget
```

You can also create a revision of an existing grant:

```
/grant --revise 42 "Reviewer feedback: strengthen Aim 2 methodology"
```

## Building a budget

```
/budget "R01 budget for 3-year clinical trial"
/budget 42
```

Creates a budget task (or resumes one) with forcing questions about personnel, equipment, travel, and indirect cost rates. Produces an XLSX spreadsheet with line-item justification. Can also be invoked as `/grant N --budget` from an existing grant task.

## Planning a research timeline

```
/timeline "Phase II clinical trial with 18-month enrollment"
/timeline 42
```

Creates a research timeline with work breakdown structure. The forcing questions ask about milestones, dependencies, and reporting periods. Supports WBS, PERT, and Gantt-style output.

## Exploring funding sources

```
/funds "machine learning applications in genomics"
/funds 42
```

Analyzes the funding landscape for a research area. Produces a funder portfolio map with budget ranges, eligibility criteria, and deadline calendars. Includes gap analysis showing which aspects of your research align with each funder's priorities.

## Preparing a research talk

```
/slides "Conference talk on causal inference methods"
/slides 42
/slides paper.pdf
```

Creates a research talk task with forcing questions about the venue, audience, duration, and key message. You can point it at a source file (PDF, manuscript) to use as primary material. Talk modes include CONFERENCE (15-20 min), SEMINAR (45-60 min), DEFENSE (30-60 min), JOURNAL_CLUB (15-30 min), and POSTER.

After creating the task, use the standard lifecycle to develop the slides:

```
/research 42          # synthesize source material
/plan 42              # interactive 5-stage slide design review (skill-slide-planning)
/implement 42         # generate the slide deck
```

**Note**: For slides tasks, `/plan` routes to `skill-slide-planning` rather than the generic planner. This runs an interactive design review covering narrative arc, per-slide content, and visual layout before producing the slide plan.

## See also

- [agent-lifecycle.md](agent-lifecycle.md) — The core task lifecycle that grant tasks follow
- [`../agent-system/commands.md`](../agent-system/commands.md) — Full command reference with flags
- [memory-and-learning.md](memory-and-learning.md) — Save grant research findings for future use
