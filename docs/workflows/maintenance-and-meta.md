# Maintenance and System Building

Investigate code quality, track down errors, clean up resources, modify the agent system, and ship changes. These commands keep the codebase and the Claude Code agent system healthy. Run them from Claude Code (Ctrl+Shift+A) or from a Zed terminal (Cmd+`).

## Decision guide

| I want to... | Use |
|---|---|
| Get a code quality assessment of the project | `/review` |
| Find and analyze recurring errors | `/errors` |
| Scan for FIX/TODO/NOTE tags and create tasks from them | `/fix-it` |
| Clean up orphaned processes or stale files | `/refresh` |
| Change the agent system itself (commands, skills, agents) | `/meta` |
| Create a pull request or merge request for my branch | `/merge` |
| Tag a release version | `/tag` (user-only) |

## Reviewing code quality

```
/review
```

Runs a code review across the codebase and produces an analysis report. The reviewer examines security, performance, maintainability, and style. Results go into the task's `reports/` directory. Use this when you want a broad quality check before shipping or after a large refactor.

## Finding and fixing errors

```
/errors
```

Analyzes error patterns from `specs/errors.json` and creates a fix plan. Useful when you notice recurring failures and want a structured approach to resolving them.

```
/fix-it
/fix-it src/
```

Scans files for `FIX:`, `TODO:`, `NOTE:`, and `QUESTION:` tags, then lets you interactively select which ones to turn into tasks. You can pass a path to limit the scan. This is a good way to convert scattered inline notes into trackable work items.

## Cleaning up resources

```
/refresh
/refresh --dry-run
```

Terminates orphaned Claude Code processes and cleans up stale files in `~/.claude/`. Run `--dry-run` first to see what would be removed. Use this when things feel sluggish or you suspect background processes have accumulated.

## Changing the agent system

```
/meta
```

The system builder for `.claude/` architecture changes. `/meta` creates tasks for modifying commands, skills, agents, rules, or context — it never implements directly. Use this when you want to add a new command, change how routing works, or restructure the agent system. The created tasks then go through the normal `/research` -> `/plan` -> `/implement` lifecycle.

## Shipping changes

```
/merge
```

Creates a pull request (GitHub) or merge request (GitLab) for the current branch. Generates a summary from the branch's commits and opens the PR with a structured description.

```
/tag --patch
/tag --minor
/tag --major
```

Creates a semantic version tag for deployment. This is a **user-only** command — agents cannot invoke it. Use after merging when you are ready to cut a release.

## See also

- [agent-lifecycle.md](agent-lifecycle.md) — The core task lifecycle (`/task` through `/todo`)
- [`../agent-system/commands.md`](../agent-system/commands.md) — Full command reference with flags
- [tips-and-troubleshooting.md](tips-and-troubleshooting.md) — Common errors and environment fixes
