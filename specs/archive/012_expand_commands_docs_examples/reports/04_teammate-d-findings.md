# Teammate D — Structural Analysis and Strategic Direction
## Task 12: Expand docs/agent-system/commands.md

---

## 1. Current Structure Assessment

### Grouping Evaluation

The five-group structure (Lifecycle, Maintenance, Memory, Documents, Research & Grants) is **largely sound but has one structural problem**: `/review` is listed under Lifecycle when it is functionally a Maintenance command. Its placement in the Lifecycle group implies it is part of the core seven-command workflow, which it is not — it produces a standalone codebase audit, not a task artifact.

**Recommended regrouping**:

| Group | Commands | Rationale |
|-------|----------|-----------|
| Lifecycle | `/task`, `/research`, `/plan`, `/implement`, `/revise`, `/todo` | True lifecycle: create -> research -> plan -> implement -> archive |
| Review & Recovery | `/review`, `/spawn`, `/errors`, `/fix-it` | All analyze existing state and generate remediation tasks |
| System & Housekeeping | `/refresh`, `/meta`, `/tag`, `/merge` | Infrastructure operations, not task-workflow |
| Memory | `/learn` | Unchanged |
| Documents | `/convert`, `/table`, `/scrape`, `/edit` | Unchanged |
| Research & Grants | `/grant`, `/budget`, `/timeline`, `/funds`, `/slides` | Unchanged |

Moving `/review` out of Lifecycle removes a false implication that review is required for every task. The `/revise` command should stay in Lifecycle — it produces a new plan version and keeps the task `[PLANNED]`, which is part of the normal iteration loop.

### Lifecycle Count

The introductory sentence says "seven commands" but the current Lifecycle group contains seven entries: `/task`, `/research`, `/plan`, `/implement`, `/revise`, `/review`, `/todo`. The `agent-lifecycle.md` narrative only covers five core commands plus `/revise` and exception commands. If `/review` is moved out, the Lifecycle group has six entries, which matches reality better. Recommend updating the intro sentence to match whichever final count is used.

---

## 2. Documentation Tone and Depth

### The Correct Division of Labor

`commands.md` is a **quick-reference catalog** — the first place a user looks when they remember a command name but forget the exact flag. The user guide (`user-guide.md`) is the comprehensive reference with full explanations, language detection tables, troubleshooting, and worked examples.

This distinction must be enforced:

| Content Type | commands.md | user-guide.md |
|---|---|---|
| One-sentence description | Yes | Yes (part of section header) |
| Minimal example (1-2 lines) | Yes | Yes (plus extended examples) |
| Flag list | Yes (brief) | Yes (with explanations) |
| Output paths/artifacts | No | Yes |
| Status transitions | No | Yes (table) |
| Language routing table | No | Yes |
| Troubleshooting | No | Yes |
| Workflow narrative | No | Yes |

The current `commands.md` correctly omits most detail, but it is **inconsistent across entries**:
- `/learn` has four examples and an explanatory sentence about deduplication (too much for a catalog)
- `/meta` has a 60-word description explaining what the command does and does not do (appropriate depth, but inconsistent with `/plan` which has 10 words)
- `/tag` has no link to its command file (points to CLAUDE.md instead — should be fixed)
- `/review` shows `--create-tasks` example but Maintenance section commands like `/spawn` show only one example

**Target word budget per command entry**: 30-60 words total (description + examples + flags + link). The `/learn` entry at ~80 words and the `/meta` entry at ~70 words are on the outer boundary; they could be trimmed without losing utility.

---

## 3. Cross-Reference Strategy

### Current State

Every command entry ends with: `See [.claude/commands/X.md](path) · [user guide](path#anchor)`.

This pattern is **effective and consistent** for Lifecycle and Maintenance commands. Problems:
1. `/tag` links to CLAUDE.md instead of a command file (there may be no `tag.md` — needs verification or a note)
2. `/fix-it` has three links (command, user guide implied, and an example) — the example link is valuable and should be standardized for other commands that have worked examples
3. Research & Grants commands (`/grant`, `/budget`, etc.) link only to command files, not to user guide anchors — but those anchors may not exist yet in the user guide

### Recommended Cross-Reference Pattern

Each entry should have exactly two link types:
1. **Source link**: `.claude/commands/X.md` — the canonical definition
2. **Guide or workflow link**: either `user-guide.md#anchor` (for core commands) or a workflow file (e.g., `convert-documents.md` for `/convert`)

For commands with worked examples, add a third optional link: `example: X-flow-example.md`.

The link line should follow a consistent format:
```
See [command source](path) · [user guide §section](path#anchor)
```
or for specialty commands:
```
See [command source](path) · [workflow](path)
```

---

## 4. Example Quality Guidelines

### What Makes a Good Catalog Example

A catalog example should satisfy two criteria:
1. **The most common invocation** — show the 80% case, not the edge case
2. **One flag variation** — reveal the most useful flag, giving users a glimpse of power

Bad example (too minimal, hides complexity):
```
/research 5
```

Better example (reveals multi-task and focus-string patterns):
```
/research 5
/research 5 "focus on accessibility implications"
/research 5, 7-9   # parallel
```

Bad example (too many lines, crosses into tutorial territory):
```
/learn "text"
/learn ~/notes/debugging.md
/learn ~/papers/
/learn --task 5
```

Better example (shows the mode that users forget exists):
```
/learn "macOS shows permission dialog when Claude edits Word while Word is open"
/learn --task 5     # harvest memories from task artifacts
```

**Rule of thumb**: Two code lines maximum per command (one primary, one showing a meaningful flag or mode). Three lines only when the command has genuinely distinct modes with non-obvious syntax (e.g., `/task` with its five subcommands).

### Illuminating Flags to Surface

These flags are currently underrepresented or absent in examples:
- `/research --remember` (memory-augmented research — currently only in flags line, no example)
- `/implement --force` (overrides partial/blocked — currently in flags but no example showing when to use it)
- `/todo --dry-run` (already shown — good)
- `/refresh --dry-run` (already shown — good)
- `/task --sync` (currently no example at all, just in flags)
- `/errors --fix 12` (already shown — good)

---

## 5. Missing Structural Elements

### Should There Be a "Quick Start" Section?

The user guide has a Quick Start section; `agent-lifecycle.md` has a summary diagram; `commands.md` has neither. Given that `commands.md` is a reference catalog (not a tutorial), a full Quick Start section would duplicate `agent-lifecycle.md` and violate the division of labor.

**Recommendation**: Add a single-paragraph "How to use this catalog" note at the top — after the existing intro paragraph — clarifying the three-level documentation hierarchy:
```
For a task workflow tutorial, see agent-lifecycle.md.
For the full command reference, see user-guide.md.
This page is the quick-reference catalog: one example per command.
```

This orients users without duplicating narrative content.

### Should There Be a "Common Workflows" Section?

A multi-command workflow section (e.g., "to unblock a task: `/spawn N` -> `/implement N`") would be useful but belongs in `agent-lifecycle.md` or a workflows README, not in `commands.md`. The catalog's job is individual command reference, not orchestration guidance.

**Recommendation**: Do not add Common Workflows to `commands.md`. Instead, verify that `agent-lifecycle.md` covers the key multi-command sequences (it currently covers exception states and multi-task syntax — sufficient).

### Should Each Group Have a Descriptor?

Current groups have brief descriptors: "Task recovery, error tracking, tag scanning, and cleanup" for Maintenance. These are good and should be kept. The Documents group descriptor should mention the MCP dependency more prominently (it currently does mention it).

---

## 6. Consistency Patterns — Proposed Entry Template

Every command entry should follow this template:

```markdown
### /commandname

One sentence: what it does, from the user's perspective. Mention key behavior (e.g., resumable, user-only, creates tasks not changes).

\```
/commandname primary-invocation
/commandname --key-flag value   # terse comment on when to use this
\```

**Flags**: `--flag-a`, `--flag-b val`, multi-task syntax   ← omit if no flags

See [`.claude/commands/commandname.md`](path) · [user guide §section](path#anchor)
```

**Template rules**:
- Description: one sentence, 10-20 words, active voice, present tense
- Code block: 1-2 lines (3 only for genuinely distinct mode syntax)
- Flags line: optional — include only if flags are non-obvious or numerous
- Link line: always present; always links to at least the command source

**Commands that violate the template today**:

| Command | Issue |
|---------|-------|
| `/learn` | Four examples, explanatory prose after code block |
| `/tag` | Links to CLAUDE.md, not a command file |
| `/slides` | Prose explanation of PPTX deprecation mid-entry (should move to user guide) |
| `/review` | Misplaced in Lifecycle group |
| `/task` | Flags line is getting long — could use a sub-table or just trim |

---

## 7. Section-Level Structural Recommendations (Priority Order)

1. **Move `/review` to a renamed "Review & Recovery" group** (high priority — fixes a conceptual error)
2. **Apply the entry template uniformly** (high priority — the core ask of Task 12)
3. **Trim `/learn` to two examples** (medium priority — restore catalog depth)
4. **Add a "How to use this catalog" orientation sentence** (medium priority — helps new users)
5. **Fix `/tag` link** (low priority — verify whether `tag.md` exists first)
6. **Remove the PPTX deprecation note from `/slides`** (low priority — move to user guide)
7. **Update the "seven commands" count** if `/review` moves out (low priority — cosmetic)

---

## Recommendations

1. **Do not restructure wholesale** — the five-group organization is intuitive. One targeted move (relocating `/review`) fixes the main conceptual problem.
2. **Adopt the four-part entry template** (description / code block / flags / link) as the specification for Teammate implementations.
3. **Two examples maximum** per command, with the second line showing the most useful non-obvious flag.
4. **Keep commands.md lean** — it is a catalog, not a tutorial. Any content longer than ~60 words per command should be considered for the user guide instead.
5. **Preserve the "See also" section** at the bottom — it correctly orients commands.md within the documentation tree.

---

## Confidence Level

**Overall: High** — The current file is well-structured; this analysis identifies incremental improvements rather than fundamental problems.

| Finding | Confidence |
|---------|------------|
| `/review` misplaced in Lifecycle | High — agent-lifecycle.md explicitly names only 5+2 commands |
| Entry template proposal | High — derived from cross-reading all source docs |
| Two-example rule | High — current inconsistency is demonstrably a problem |
| No "Common Workflows" section needed | Medium — could be useful, but belongs elsewhere |
| `/tag` link fix | Medium — need to verify whether `tag.md` exists |
| Lifecycle count update | Low — depends on final regrouping decision |
