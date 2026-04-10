# Main Workflow

Seven commands drive the Claude Code task lifecycle: five lifecycle drivers and two clean-up commands. Learn these first; the remaining 17 commands in [commands.md](commands.md) layer on top.

## Summary

```
/task        -> create
/research    -> investigate
/plan        -> design
/implement   -> execute
/todo        -> archive
```

Each command runs a **checkpoint execution pipeline** (GATE IN -> DELEGATE -> GATE OUT -> COMMIT), generates a session ID, writes a structured artifact, and commits. You can stop between any two steps and resume later.

## Task lifecycle state machine

```
[NOT STARTED] --/research--> [RESEARCHING] --> [RESEARCHED]
              --/plan------> [PLANNING]    --> [PLANNED]
              --/implement-> [IMPLEMENTING]--> [COMPLETED]

Exception states: [BLOCKED]  [ABANDONED]  [PARTIAL]  [EXPANDED]
```

Every command runs a **checkpoint execution pipeline**: GATE IN (preflight) -> DELEGATE (skill/agent) -> GATE OUT (postflight) -> COMMIT. A session ID of the form `sess_{unix}_{random}` is generated at GATE IN and threaded through the delegation chain into the final git commit body, so you can always reconstruct a command's trajectory. See [`.claude/rules/workflows.md`](../../.claude/rules/workflows.md) and [`.claude/rules/git-workflow.md`](../../.claude/rules/git-workflow.md).

Artifacts for each task live under `specs/{NNN}_{slug}/`:

```
specs/{NNN}_{slug}/
├── reports/MM_{short-slug}.md       # from /research
├── plans/MM_{short-slug}.md         # from /plan
└── summaries/MM_{short-slug}-summary.md  # from /implement
```

See [`.claude/rules/artifact-formats.md`](../../.claude/rules/artifact-formats.md) for the full naming and versioning spec.

## Creating a task

```
/task "Add a dark-mode toggle to settings page"
```

Creates a new entry in `specs/TODO.md` and `specs/state.json`, assigns the next task number, creates a `specs/{NNN}_{slug}/` directory, and commits. Subcommands: `--recover N` (rebuild a broken task), `--expand N` (split into subtasks), `--sync` (repair TODO.md/state.json drift), `--abandon N` (mark terminal), `--review N` (review mode). Creates state `[NOT STARTED]`.

## Researching

```
/research 1
/research 1 "focus on accessibility implications"
/research 1 --team       # parallel multi-agent investigation
/research 1 --remember   # search the .memory/ vault first
```

Investigates a task. Routes by the task's `task_type` to the matching research skill and agent (for `general`/`meta`/`markdown`, that is `skill-researcher` -> `general-research-agent`). Produces a report at `reports/MM_{short-slug}.md`. Transitions `[NOT STARTED]` -> `[RESEARCHING]` -> `[RESEARCHED]`.

## Planning

```
/plan 1
/plan 1 --team
```

Delegates to `skill-planner` -> `planner-agent` (model: `opus`), which reads the research report and writes a phased plan at `plans/MM_{short-slug}.md`. See the [agent frontmatter standard](../../.claude/docs/reference/standards/agent-frontmatter-standard.md) for how agents declare models. Transitions `[RESEARCHED]` -> `[PLANNING]` -> `[PLANNED]`.

Need to redo a plan? Use `/revise N` to create a new plan version (e.g., `plans/02_{short-slug}.md`).

## Implementing

```
/implement 1
/implement 1 --team
/implement 1 --force   # overwrite a partial/blocked state
```

Executes the plan. Routes to `skill-implementer` -> `general-implementation-agent` (or a domain agent), which executes phases sequentially. **Resumable**: if interrupted, the next invocation picks up at the first incomplete phase. Writes `summaries/MM_{short-slug}-summary.md`. Transitions `[PLANNED]` -> `[IMPLEMENTING]` -> `[COMPLETED]` (or `[PARTIAL]` on timeout, `[BLOCKED]` on hard failure).

## Finishing with /todo

```
/todo
/todo --dry-run
```

Archives `[COMPLETED]` and `[ABANDONED]` tasks from `specs/TODO.md` to `specs/archive/`, updates `state.json`, appends to `CHANGE_LOG.md`, and annotates `ROAD_MAP.md` with non-meta task completion summaries. Triggers a **vault operation** (task renumbering) when `next_project_number > 1000`; see [`.claude/rules/state-management.md`](../../.claude/rules/state-management.md) for the vault schema.

## Advanced flags

### Multi-task syntax

`/research`, `/plan`, and `/implement` accept comma and range syntax:

```
/research 5, 7-9
```

runs tasks 5, 7, 8, and 9 in parallel, each with its own agent. Flags apply to all tasks in the batch.

### Team mode (--team)

Passing `--team` to `/research`, `/plan`, or `/implement` spawns multiple parallel teammates (2-4) for diverse investigation or parallel phase execution. Team mode requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in the environment, uses roughly 5× the tokens of single-agent mode, and gracefully degrades to single-agent if the harness does not support it.

### --remember

Only on `/research`. Searches the [`.memory/`](context-and-memory.md) vault for relevant prior knowledge and injects matches into the research context.

## Exception states

- **[BLOCKED]** — hard failure or external dependency. Use `/spawn N` to research the blocker and create unblocking tasks.
- **[PARTIAL]** — the implementation timed out mid-phase. Re-run `/implement N` and it resumes at the first incomplete phase.
- **[EXPANDED]** — the task was split into subtasks via `/task --expand N`.
- **[ABANDONED]** — terminal non-completion. `/todo` archives these alongside `[COMPLETED]` tasks.

For the rest of the command catalog (maintenance, memory, document conversion, grants, talks), see [commands.md](commands.md).

## See also

- [commands.md](commands.md) — Full catalog of all 24 commands
- [architecture.md](architecture.md) — How commands, skills, and agents fit together
- [`.claude/docs/guides/user-guide.md`](../../.claude/docs/guides/user-guide.md) — Comprehensive reference with examples
- [`.claude/docs/examples/research-flow-example.md`](../../.claude/docs/examples/research-flow-example.md) — End-to-end research-to-implementation walkthrough
