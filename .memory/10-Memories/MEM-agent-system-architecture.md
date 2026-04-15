---
title: "Claude Code agent system three-layer architecture"
created: 2026-04-15
tags: [PATTERN, agent-system, architecture, claude-code]
topic: "agent-system/architecture"
source: "docs/agent-system/architecture.md, docs/agent-system/README.md"
modified: 2026-04-15
---

# Claude Code Agent System Architecture

## Three-Layer Pipeline

```
USER -> COMMANDS (.claude/commands/*.md) -> SKILLS (.claude/skills/*/SKILL.md) -> AGENTS (.claude/agents/*.md)
```

- **Commands**: Thin routers. Parse args, read task state, look up task_type, route to skill. Never do work directly.
- **Skills**: Validation + context preparation. Check preconditions, load context, invoke agent, collect metadata, update state, commit.
- **Agents**: Actual work. Subprocess with system prompt, tool set, and model. Read inputs, write artifacts, return metadata.

## Checkpoint Execution

Every lifecycle command runs four checkpoints:
```
GATE IN (preflight) -> DELEGATE -> GATE OUT (postflight) -> COMMIT
```

1. **GATE IN** — Read state, verify task status, generate session ID (`sess_{unix_timestamp}_{6_char_random}`), update to -ING state
2. **DELEGATE** — Hand off to skill which invokes agent
3. **GATE OUT** — Read agent return metadata, validate artifacts, transition to terminal state
4. **COMMIT** — Git commit with session ID in trailer

## Task Lifecycle State Machine

```
[NOT STARTED] --/research--> [RESEARCHING] --> [RESEARCHED]
              --/plan------> [PLANNING]    --> [PLANNED]
              --/implement-> [IMPLEMENTING]--> [COMPLETED]

Exception states: [BLOCKED]  [ABANDONED]  [PARTIAL]  [EXPANDED]
```

## Task-Type Routing

| task_type | Research Skill | Implementation Skill |
|-----------|----------------|---------------------|
| general | skill-researcher | skill-implementer |
| meta | skill-researcher | skill-implementer |
| markdown | skill-researcher | skill-implementer |
| epi/epi:study | skill-epi-research | skill-epi-implement |
| present (grant/budget/slides/timeline/funds) | domain-specific | domain-specific |

## State Files
- `specs/TODO.md` — human-readable task list
- `specs/state.json` — machine-readable state (source of truth)
- `specs/errors.json` — error tracking
- `specs/{NNN}_{slug}/` — per-task directories with reports/, plans/, summaries/

## Artifact Naming
`{NNN}_{SLUG}/reports|plans|summaries/MM_{short-slug}.md`
- NNN = 3-digit zero-padded task dir number
- MM = zero-padded sequence number within task

## Session IDs
Format: `sess_{unix_timestamp}_{6_char_random}` — links commits, errors, and artifacts to command invocations.

## Extensions
All extensions (epidemiology, filetypes, latex, typst, present, memory) are pre-merged. No manual loading step.

## Connections
<!-- Add links to related memories using [[filename]] syntax -->
