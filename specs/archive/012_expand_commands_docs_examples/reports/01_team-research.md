# Research Report: Task #12

**Task**: Expand docs/agent-system/commands.md to include brief examples and explanations for each command
**Date**: 2026-04-10
**Mode**: Team Research (4 teammates)

## Summary

The current `commands.md` is a well-structured quick-reference catalog with 25 commands across 5 groups. Each entry has a one-sentence description, one example, a flags line, and a link — intentionally terse. The task is to expand entries with brief explanations and additional examples without turning the catalog into a full reference manual. Research identified missing flags/modes, inconsistent entry depth, one misplaced command, and a consistent entry template to standardize on.

## Key Findings

### Primary Approach (from Teammate A — Lifecycle Commands)

**7 lifecycle commands analyzed.** Key discoveries:

1. **`/implement` resume is implicit** — the same command always auto-detects the first incomplete phase and resumes there. There is no `--resume` flag. This is the single most important behavioral note missing from docs.

2. **`/revise` has no status restriction** — it works on any task in any status (implementing, partial, even completed). Two code paths: plan revision (if plan exists) vs. description update (no plan).

3. **`/task --review N` vs `/review`** — these are conceptually different. `/task --review N` inspects a specific task's plan phases for completion; `/review` audits the codebase. The naming overlap may confuse users.

4. **Multi-task syntax** (`/research 7, 22-24, 59`) is one of the most powerful features across `/research`, `/plan`, and `/implement` but gets only a flags-line mention.

5. **Team mode** (`--team`) available for `/research` (2-4 agents), `/plan` (2-3), `/implement` (2-4). Each ~5x token cost. Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

6. **`/research --remember`** searches the memory vault for prior relevant knowledge before researching. Currently flags-only, no example.

7. **`/todo`** handles orphaned directories, vault operations (next_project_number > 1000), and meta task `claudemd_suggestions`. The `--dry-run` flag is safe and should always precede large archive operations.

### Alternative Approaches (from Teammate B — Maintenance & Memory Commands)

**8 maintenance/memory commands analyzed.** Key discoveries:

1. **No `/tag` command file exists** — behavior is only in CLAUDE.md routing tables. The docs link to CLAUDE.md which is correct but inconsistent with other entries. Low confidence on edge cases.

2. **Interactive vs. automatic design split** — `/fix-it` and `/meta` always preview before acting (interactive). `/errors` intentionally bypasses interaction for fast triage. This design philosophy should be documented.

3. **`/spawn` output includes dependency graph** — visual chain showing spawned tasks and execution order. Spawned tasks start at `[RESEARCHED]` status (skip research phase).

4. **`/refresh` safety margin** — files modified within the last hour are never deleted regardless of threshold. Four protected files are never deleted.

5. **`/learn` three-operation model** — UPDATE (high overlap with existing), EXTEND (partial overlap), CREATE (new topic). The `--task N` mode classifies segments into TECHNIQUE/PATTERN/CONFIG/WORKFLOW/INSIGHT/SKIP.

6. **`/merge` uses `--fill`** — auto-populates PR/MR title and body from git commit history. Supports both GitHub and GitLab with automatic platform detection.

7. **`/meta` never implements directly** — always creates tasks. Reference implementation of the multi-task creation standard (8 components, Kahn's algorithm, DAG visualization).

### Gaps and Shortcomings (from Critic — Teammate C)

**9 document/grant commands analyzed.** Issues found:

1. **`/grant --fix-it` mode is completely absent** from docs — scans grant directory for FIX:/TODO: tags and creates tasks.

2. **`/table --sheet` flag missing** from docs — exists in source for selecting sheets from multi-sheet workbooks.

3. **`/budget` file-path input mode undocumented** — `/budget ~/grants/r01-aims.md` reads file as context.

4. **Pre-task forcing question pattern undocumented** — central to /grant (4 questions), /budget (3), /timeline (6), /funds (5), and /slides. This is the largest documentation gap. A brief note at the top of the Research & Grants section would eliminate repetitive per-command explanations.

5. **Workflow stopping points unexplained** — users won't know that `/budget "description"` stops at [NOT STARTED] and requires `/research N` next.

6. **Budget mode tables** (MODULAR/DETAILED/NSF/FOUNDATION/SBIR) and **funds analysis modes** (LANDSCAPE/PORTFOLIO/JUSTIFY/GAP) are meaningful differentiators not in docs.

7. **`/slides` is undersold** — described as just "create a task" but actually handles research delegation (`/slides N`) and design confirmation (`--design`).

8. **`/timeline` output is Typst** — users won't know they need `typst compile` for PDF.

9. **`/edit` XLSX limitation** — noted in source as "not yet available" but absent from docs.

### Strategic Horizons (from Teammate D — Structure)

**Structural analysis and entry template proposal:**

1. **`/review` is misplaced** in Lifecycle — `agent-lifecycle.md` treats it as separate from the core five commands. Should move to a "Review & Recovery" group alongside `/spawn`, `/errors`, `/fix-it`.

2. **Entry template should be standardized** — four parts: one-sentence description / 1-2 line code block / optional flags / link line. Target ~30-60 words per entry.

3. **Two examples maximum per command** — one primary invocation, one showing the most useful non-obvious flag. `/learn` (4 examples) and `/slides` (3 examples + deprecation prose) should be trimmed.

4. **No "Common Workflows" section needed** — belongs in `agent-lifecycle.md`, not the catalog.

5. **Add orientation sentence** at the top: "For task workflow tutorial, see agent-lifecycle.md. For full reference, see user-guide.md. This page is the quick-reference catalog."

6. **Fix `/tag` link** — currently points to CLAUDE.md instead of a command file (which doesn't exist).

7. **Proposed regrouping**:
   - Lifecycle: /task, /research, /plan, /implement, /revise, /todo (6)
   - Review & Recovery: /review, /spawn, /errors, /fix-it (4)
   - System & Housekeeping: /refresh, /meta, /tag, /merge (4)
   - Memory: /learn (1)
   - Documents: /convert, /table, /scrape, /edit (4)
   - Research & Grants: /grant, /budget, /timeline, /funds, /slides (5)

## Synthesis

### Conflicts Resolved

1. **Entry depth** — Teammate A provided rich 2-3 sentence explanations with 3-7 examples per command. Teammate D recommends 1-sentence + 2 examples max. **Resolution**: Use Teammate D's template (terse catalog) but incorporate Teammate A's behavioral insights as the content for those terse descriptions. The detailed examples from A/B/C serve as implementation reference, not direct copy.

2. **`/slides` placement** — Teammate C notes `/slides` is in Documents but functionally closer to Research & Grants. Teammate D's regrouping moves it to Research & Grants. **Resolution**: Accept the move — `/slides` uses the `present:talk` task type and shares the forcing-question pattern with grant commands.

3. **How much to expand** — Teammates A/B/C provide extensive per-command content. Teammate D argues for strict brevity. **Resolution**: Expand each entry to include a 2-sentence explanation (what it does + when to use it) and 2 examples (primary + key flag), keeping the catalog character. Document the forcing-question pattern once at section level rather than per-command.

### Gaps Identified

1. No team decided whether mode tables (budget modes, funds modes, talk modes) belong in commands.md or only in the user guide. **Recommendation**: Keep mode tables in the user guide; commands.md can mention "five budget modes" with a link.

2. The relationship between `/task --review N` and `/review` needs a disambiguation note somewhere — either in commands.md or the user guide.

### Implementation Recommendations

For the implementation plan, the work should:

1. **Apply the standardized entry template** to all 25 commands
2. **Regroup commands** per Teammate D's proposal (move /review out of Lifecycle, move /slides to Research & Grants)
3. **Add a forcing-question pattern note** at the top of the Research & Grants section
4. **Add orientation paragraph** at the top of the file
5. **Fix missing flags/modes**: `--sheet` (table), `--fix-it` (grant), file-path input (budget)
6. **Fix `/tag` link** to acknowledge no command file exists
7. **Update lifecycle count** in intro sentence
8. **Trim overlong entries** (/learn, /slides) to match template

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Lifecycle commands (7) | completed | high |
| B | Maintenance & Memory commands (8) | completed | high |
| C | Document & Grant commands (9) + gap analysis | completed | high |
| D | Structural analysis & entry template | completed | high |

## References

- `docs/agent-system/commands.md` — current file to be expanded
- `.claude/commands/*.md` — 24 command source files (no `tag.md`)
- `.claude/docs/guides/user-guide.md` — comprehensive reference
- `docs/workflows/agent-lifecycle.md` — lifecycle narrative
- `docs/agent-system/architecture.md` — system architecture
