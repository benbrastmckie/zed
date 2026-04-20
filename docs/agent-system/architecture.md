# Architecture

The Claude Code framework in this workspace is a three-layer execution pipeline with checkpoint-based command lifecycle, session-ID-linked git history, and task-type routing. This page is the advanced reference; for day-to-day usage, see [agent-lifecycle.md](../workflows/agent-lifecycle.md) and [commands.md](commands.md).

## Summary

```
                 ┌─────────────────┐
                 │      USER       │
                 │ /{command} args │
                 └────────┬────────┘
                          │
                          ▼
          ┌───────────────────────────────┐
          │  COMMANDS                     │
          │  .claude/commands/*.md        │
          │  parse, route by task_type,   │
          │  checkpoint                   │
          └───────────────┬───────────────┘
                          │
                          ▼
          ┌───────────────────────────────┐
          │  SKILLS                       │
          │  .claude/skills/*/SKILL.md    │
          │  validate, prepare context,   │
          │  invoke agents                │
          └───────────────┬───────────────┘
                          │
                          ▼
          ┌───────────────────────────────┐
          │  AGENTS                       │
          │  .claude/agents/*.md          │
          │  execute, create artifacts,   │
          │  return metadata              │
          └───────────────────────────────┘
```

Commands are thin routers; skills handle validation and context loading; agents do the actual work and write artifacts. See [`.claude/README.md`](../../.claude/README.md) for the full architecture diagram and component specifications, and [`.claude/docs/architecture/system-overview.md`](../../.claude/docs/architecture/system-overview.md) for the detailed walkthrough.

## Three-layer pipeline

**Commands** (`.claude/commands/*.md`)

Thin routers. They parse arguments, read task state, look up the task's `task_type`, and route to the matching skill. They never do work directly.

**Skills** (`.claude/skills/*/SKILL.md`)

Validation and context preparation. A skill checks preconditions, loads the right context files for the agent, invokes the agent subprocess, collects the agent's metadata, updates state, and commits.

**Agents** (`.claude/agents/*.md`)

The actual work. An agent is a subprocess with a specific system prompt, tool set, and model. It reads inputs, writes artifacts (reports, plans, summaries), and returns a metadata file that the parent skill reads.

See [`.claude/docs/guides/component-selection.md`](../../.claude/docs/guides/component-selection.md) for the command-vs-skill-vs-agent decision tree.

## Checkpoint execution

Every lifecycle command runs four checkpoints:

```
GATE IN (preflight)  -> DELEGATE  -> GATE OUT (postflight)  -> COMMIT
```

1. **GATE IN** — preflight validation. Read state, verify the task is in the right status, generate a session ID (`sess_{unix_timestamp}_{6_char_random}`), update status to the `-ING` state.
2. **DELEGATE** — hand off to the skill, which invokes the agent. The agent does the work.
3. **GATE OUT** — postflight. Read the agent's return metadata, validate artifacts, transition the task status to the terminal state (or a `[PARTIAL]` / `[BLOCKED]` exception state).
4. **COMMIT** — create a git commit with the session ID in the trailer, linking the commit back to the originating command invocation.

See [`.claude/rules/workflows.md`](../../.claude/rules/workflows.md) for the full lifecycle specification and [`.claude/rules/git-workflow.md`](../../.claude/rules/git-workflow.md) for the commit format.

## Session IDs

Format: `sess_{unix_timestamp}_{6_char_random}`. Example: `sess_1736700000_a1b2c3`.

Generated at GATE IN, passed through the skill-to-agent delegation, included in error logs, and written into the final git commit body:

```
task 12 phase 2: implement modal semantics evaluator

Session: sess_1736701234_d4e5f6
```

See [Zed adaptations](README.md#zed-adaptations) for workspace-specific deviations from the upstream configuration.

Any commit, error log entry, or artifact can be traced back to the command invocation that produced it.

## State files

- `specs/TODO.md` — human-readable task list (source of truth for users)
- `specs/state.json` — machine-readable state (source of truth for commands)
- `specs/errors.json` — error tracking for retry and recovery; see [`.claude/rules/error-handling.md`](../../.claude/rules/error-handling.md)
- `specs/{NNN}_{slug}/` — per-task directories with `reports/`, `plans/`, and `summaries/` subdirectories

TODO.md and state.json must stay synchronized; both are updated atomically. See [`.claude/rules/state-management.md`](../../.claude/rules/state-management.md) for the sync protocol and vault schema (task renumbering when `next_project_number > 1000`).

## Configuration tree

```
.
├── specs/                    # Task management
│   ├── TODO.md              # Human-readable task list
│   ├── state.json           # Machine-readable state
│   ├── errors.json          # Error tracking
│   └── {NNN}_{SLUG}/        # Per-task artifacts
└── .claude/
    ├── CLAUDE.md            # Always-loaded quick reference
    ├── README.md            # Architecture navigation hub
    ├── commands/            # slash command definitions
    ├── skills/              # 33 skill routers
    ├── agents/              # 30 agent specifications
    ├── rules/               # Auto-applied behavioral rules
    ├── context/             # Core agent context (patterns, formats)
    ├── docs/                # Guides, examples, standards
    └── scripts/             # Utility scripts (e.g., update-task-status.sh)
```

## Extensions

The `.claude/CLAUDE.md` file describes an extension loader -- a pattern for merging language-specific task types, skills, and rules into the core framework. All extensions are pre-merged into the active configuration in this workspace. All commands are always available without any manual loading step.

Every extension entry in `.claude/CLAUDE.md` (epidemiology, filetypes, latex, memory, present, typst) is pre-merged into the active configuration in this workspace. You do not need to load anything; just run the command.

## Task routing by task_type

Every task has a `task_type` field in `state.json` that tells the lifecycle commands which skill and agent to route to. Core task types:

| task_type | Research skill | Implementation skill |
|-----------|----------------|----------------------|
| `general` | `skill-researcher` | `skill-implementer` |
| `meta` | `skill-researcher` | `skill-implementer` |
| `markdown` | `skill-researcher` | `skill-implementer` |

Specialty task types (for grants, talks, LaTeX, Typst, Python, epidemiology, etc.) route to their respective specialized skills. See [`.claude/CLAUDE.md`](../../.claude/CLAUDE.md) for the full routing table.

## Skills as keywords vs commands as workflows

Commands (`/research`, `/plan`, `/implement`) guarantee a specific execution workflow — checkpoint gates, state transitions, git commits, and artifact validation all happen in a fixed sequence. When you need that structure, use commands.

Skills, however, are also activated by **keywords in natural language prompts**. When Claude encounters terms like "research", "plan", "implement", "review", "convert", or "budget" in your message, it matches them against available skill definitions and follows the corresponding instructions. This means you can invoke skill behavior without using a slash command — just describe what you need using the right vocabulary.

The practical consequence: you can **compose multi-step workflows in a single prompt** by describing each step with skill keywords. Claude will execute them in sequence, following each skill's instructions as it encounters the relevant phase of your description.

### Example: composing skills in a single prompt

Instead of running three separate commands:

```
/research 14
/plan 14
/implement 14
```

You can write a single prompt that chains the work:

```
For task 14 (standardize docs and root readme):

1. Research the current state of documentation files across the repo —
   check which docs have stale references, missing sections, or
   inconsistent formatting. Write a research report.

2. Based on the research findings, create an implementation plan
   that groups the fixes into logical phases.

3. Implement the plan, starting from phase 1.
```

Claude will pick up the skill keywords ("research … write a research report", "create an implementation plan", "implement the plan") and follow the corresponding skill instructions for each step. The artifacts, state updates, and commits still happen — but you control the narrative rather than issuing discrete commands.

This is especially useful when:

- You want to add **guidance or focus** to each phase (e.g., "research specifically the cross-references between docs" or "in the plan, keep each phase under 5 files")
- You want to **skip or combine phases** (e.g., "research and plan together, then implement")
- You want to **chain unrelated skills** (e.g., "convert the spreadsheet to a LaTeX table, then research grant formatting requirements, then draft the budget section")

The trade-off: commands enforce the full checkpoint lifecycle with validation gates; keyword-driven skill composition relies on Claude following the instructions correctly without the structural guarantees. For critical or complex tasks, commands are safer. For exploratory or multi-faceted work, composing with keywords is more flexible.

## See also

- [`.claude/README.md`](../../.claude/README.md) — Architecture navigation hub and component inventory
- [`.claude/docs/architecture/system-overview.md`](../../.claude/docs/architecture/system-overview.md) — Detailed architecture walkthrough
- [`.claude/docs/architecture/extension-system.md`](../../.claude/docs/architecture/extension-system.md) — Extension loader pattern (portability reference)
- [`.claude/docs/guides/component-selection.md`](../../.claude/docs/guides/component-selection.md) — Command vs skill vs agent decision tree
- [agent-lifecycle.md](../workflows/agent-lifecycle.md) — Lifecycle from a user's perspective
- [context-and-memory.md](context-and-memory.md) — How context and memory flow into agents
