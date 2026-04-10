# Research Report: Task #10 — Teammate B (docs/ side mapping)

**Task**: 10 - Update /home/benjamin/.config/zed/docs/ to reflect changes in .claude/
**Teammate**: B (Alternatives / Prior Art) — focus: docs/ current state
**Started**: 2026-04-10
**Completed**: 2026-04-10
**Sources/Inputs**: docs/**/*.md (all 16 files), .claude/commands/, .claude/agents/, .claude/skills/, `git log -- docs/`, `git diff HEAD -- .claude/` (selective)
**Artifacts**: this report
**Standards**: report-format.md

## Key Findings

1. **docs/ is small, tight, and recently rebuilt** — only 16 markdown files, 1,969 lines total, across four top-level areas (`general/`, `agent-system/`, `workflows/`, plus root `README.md`). The entire tree was reorganized or written within the last ~35 commits (tasks 5-9), so the surface to update is small and the conventions are fresh.

2. **Only two docs files will need substantive content edits** from the current .claude/ diff: `docs/agent-system/commands.md` (heavy) and `docs/workflows/convert-documents.md` (moderate). Everything else needs only small token-level fixes or is untouched.

3. **The dominant upstream change is a `/talk` -> `/slides` rename combined with a repurposing of `/slides`**. The old `/slides` (PPTX-to-Beamer/Polylux/Touying conversion) has been folded into `/convert --format`. The new `/slides` is the research-talk creation command (formerly `/talk`). docs/ currently describes the OLD meaning of both commands and has an entire section for `/talk` that now points at a deleted file (`.claude/commands/talk.md`).

4. **Secondary upstream changes that touch docs/**: (a) `ROAD_MAP.md` -> `ROADMAP.md` rename; (b) command count drifts from 24 to 23; (c) agent count drifts from 25 to 24; (d) a new utility script (`.claude/scripts/check-extension-docs.sh`); (e) a new rule file (`.claude/rules/plan-format-enforcement.md`); (f) a user-preference change that commit examples should omit the `Co-Authored-By` trailer.

5. **Surgical updates are sufficient.** No structural rewrite of docs/ is warranted. The docs/ architecture (the four-section split, the "see also" footers, the command catalog grouped by topic, the navigation hubs) matches the .claude/ architecture and continues to hold. Only specific paragraphs, tables, and link targets need changing.

6. **Prior-art convention**: the ~35 docs commits since mid-task-5 show a strongly phased editing pattern (`task N phase P: …`) with scoped commits per file, and the team is willing to move/rename/delete files when the source of truth moves (see task 8, which physically moved agent-system/workflow.md -> workflows/agent-lifecycle.md and fixed inbound links in two follow-up phases). The planner should follow the same pattern: one phase per docs file that actually needs editing.

## Context & Scope

In scope: enumerate every file under `docs/`, identify every reference to .claude/ content (command names, skill names, agent names, file paths, extension names, numeric counts), and determine which references are stale vs still correct given the current .claude/ diff. The downstream planner needs a surgical edit list, not a rewrite.

Out of scope (covered by Teammate A): the full enumeration of what changed inside .claude/. This report consults the .claude/ diff only enough to sanity-check docs/ references against current reality.

## docs/ Structure Map

All paths relative to `/home/benjamin/.config/zed/`. Line counts from `wc -l`; last-touched from `git log -1 --format='%h %s' -- <file>` (limited to task boundaries for readability).

| File | Lines | Purpose | Audience | Last substantive touch |
|---|---:|---|---|---|
| `docs/README.md` | 9 | Top-level index; three bullets pointing at general/, agent-system/, workflows/ | Any reader entering the docs tree | task 8 phase 1 (scaffold) |
| `docs/general/README.md` | 26 | Subdir index for installation/keybindings/settings | First-time setup user | task 8 phase 1/2 (move) |
| `docs/general/installation.md` | 301 | macOS step-by-step install walkthrough (Xcode CLT -> Homebrew -> Node -> Zed -> Claude CLI -> claude-acp -> MCP tools); each section has detect/install/verify blocks | macOS user installing from scratch | task 7 phases 2-5 |
| `docs/general/keybindings.md` | 207 | Everyday keyboard shortcut cheat sheet organized by task category; includes "How do I use the AI agent?" section | Day-to-day Zed user | task 2/3 era |
| `docs/general/settings.md` | 251 | Annotated walkthrough of settings.json / keymap.json / tasks.json including the `agent_servers.claude-acp` block | Config tweaker | task 3/4 era |
| `docs/agent-system/README.md` | 58 | Orientation: "two AI systems" table, nav table, quick-start five-command flow | User choosing between panel and Claude Code | task 6 (expand) |
| `docs/agent-system/zed-agent-panel.md` | 123 | Panel overview, built-in vs Claude Code thread, `claude-acp` bridge architecture, `/login`, inline assist, edit predictions, troubleshooting | Panel user | task 6/7 era |
| `docs/agent-system/commands.md` | 337 | **Command catalog.** All slash commands grouped by topic (Lifecycle / Maintenance / Memory / Documents / Research & Grants); each entry has summary, example, flag list, link to `.claude/commands/<name>.md` and `.claude/docs/guides/user-guide.md#<name>` | Users learning the command surface | task 6 era |
| `docs/agent-system/architecture.md` | 118 | Three-layer pipeline, checkpoint execution, session IDs, state files, configuration tree, extensions note, task-type routing table | Advanced/power user | task 6 era |
| `docs/agent-system/context-and-memory.md` | 110 | Two memory layers, five context layers, `/learn` modes, `/research --remember`, where-to-put-new-content decision tree | User writing memories / configuring context | task 6 era |
| `docs/workflows/README.md` | 63 | Subdir index for agent-lifecycle + office workflows; decision-guide table; common-scenario walkthroughs | User choosing a workflow | task 8 phase 7 |
| `docs/workflows/agent-lifecycle.md` | 124 | Task lifecycle state machine, seven lifecycle commands in narrative form, multi-task syntax, --team, --remember, exception states | Claude Code user | task 8 phase 2 (moved from agent-system/workflow.md) |
| `docs/workflows/convert-documents.md` | 62 | `/convert`, `/table`, `/slides`, `/scrape` walkthroughs with decision table | Document-conversion user | task 8 phase 5 |
| `docs/workflows/edit-word-documents.md` | 89 | `/edit` walkthroughs: in-place, batch, create new | Word user | task 8 (extracted) |
| `docs/workflows/edit-spreadsheets.md` | 30 | Thin wrapper describing direct openpyxl-driven .xlsx editing (no slash command per se) | Excel user | task 8 phase 4 |
| `docs/workflows/tips-and-troubleshooting.md` | 61 | OneDrive pause, macOS permissions, common errors, tasks.json runners table | Cross-cutting | task 8 phase 6 |

Total: 1,969 lines, 16 files.

## References to .claude/ Content

Inventory of every material reference from docs/ into .claude/ (the noise of generic slash commands like `/task` inside prose is compressed — I call out only the cases where the reference is load-bearing or the target path is concrete). "Status" is the result of a quick existence check against the current .claude/ tree (not the diff).

### commands.md (the heavy hitter — 113 matches, ~35 distinct concrete references)

| Line(s) | Reference | Type | Status |
|---|---|---|---|
| 3 | "All 24 slash commands" | Count claim | **STALE** — actual = 23 |
| 3 | `.claude/docs/guides/user-guide.md` | Doc link | OK (exists) |
| 3 | `.claude/commands/` | Dir link | OK |
| 21 | `.claude/commands/task.md`, user-guide#task | Command link | OK |
| 33 | `.claude/commands/research.md`, user-guide#research | Command link | OK |
| 45 | `.claude/commands/plan.md`, user-guide#plan | Command link | OK |
| 57 | `.claude/commands/implement.md`, user-guide#implement | Command link | OK |
| 67 | `.claude/commands/revise.md`, user-guide#revise | Command link | OK |
| 78 | `.claude/commands/review.md`, user-guide#review | Command link | OK |
| 89 | `.claude/commands/todo.md`, user-guide#todo | Command link | OK |
| 103 | `.claude/commands/spawn.md` | Command link | OK |
| 114 | `.claude/commands/errors.md` | Command link | OK |
| 124 | `.claude/commands/fix-it.md` · `.claude/docs/examples/fix-it-flow-example.md` | Command + example | OK |
| 135 | `.claude/commands/refresh.md` | Command link | OK |
| 146 | `.claude/commands/meta.md` | Command link | OK |
| 158 | `.claude/CLAUDE.md` for /tag routing | File link | OK |
| 171 | `.claude/commands/merge.md` | Command link | OK |
| 186 | `.claude/commands/learn.md` | Command link | OK |
| 202 | `.claude/commands/convert.md` · `../workflows/convert-documents.md` | Command + workflow | OK, but description above is thin |
| 215 | `.claude/commands/table.md` | Command link | OK |
| **217-227** | **"### /slides" section** describes "Convert presentations to Beamer, Polylux, or Touying source" with `/slides deck.pptx --format beamer` | Command description | **STALE SEMANTICS** — `/slides` is now the research-talk creation command; PPTX conversion now lives on `/convert --format beamer\|polylux\|touying` |
| 240 | `.claude/commands/scrape.md` | Command link | OK |
| 254 | `.claude/commands/edit.md` · `../workflows/edit-word-documents.md` | Command + workflow | OK |
| 271 | `.claude/commands/grant.md` | Command link | OK |
| 285 | `.claude/commands/budget.md` | Command link | OK |
| 296 | `.claude/commands/timeline.md` | Command link | OK |
| 310 | `.claude/commands/funds.md` | Command link | OK |
| **312-330** | **Entire "### /talk" section** (five-mode table, `/talk "..."`, `/talk N`, `/talk /path/to/file.pdf`, link to `.claude/commands/talk.md`) | Command section | **DEAD** — `.claude/commands/talk.md` is deleted; `/talk` is renamed to `/slides`; the five-mode talk table (CONFERENCE/SEMINAR/DEFENSE/POSTER/JOURNAL_CLUB) should move to the new `/slides` section and the link repointed at `.claude/commands/slides.md` |
| 336 | `.claude/docs/guides/user-guide.md` · `.claude/commands/` | "See also" | OK |

### architecture.md

| Line | Reference | Type | Status |
|---|---|---|---|
| 14 | `.claude/README.md`, `.claude/docs/architecture/system-overview.md` | Arch doc links | OK |
| 30 | `.claude/docs/guides/component-selection.md` | Guide link | OK |
| 45 | `.claude/rules/workflows.md`, `.claude/rules/git-workflow.md` | Rule links | OK |
| **58** | `Co-Authored-By: Claude Opus 4.6 (1M context)` in commit example | Example content | **STALE** — user preference is to omit Co-Authored-By from commits; `.claude/CLAUDE.md` now explicitly says so. Recent commits (task 10: create, earlier task 9 commits) are inconsistent — some still include it — but the documented convention is "omit". Example should be updated. |
| 67 | `.claude/rules/error-handling.md` | Rule link | OK |
| 70 | `.claude/rules/state-management.md` | Rule link | OK |
| **84** | `commands/ # 24 slash command definitions` | Count | **STALE** — actual 23 |
| **85** | `skills/ # 32 skill routers` | Count | OK (actual 32) |
| **86** | `agents/ # 25 agent specifications` | Count | **STALE** — actual 24 non-README entries |
| **95** | `All 24 commands are always available` | Count | **STALE** — 23 |
| 109 | `.claude/CLAUDE.md` for routing table | File link | OK |
| 113-116 | Multiple `.claude/` links | Doc links | OK |

### agent-lifecycle.md (workflows/)

| Line | Reference | Type | Status |
|---|---|---|---|
| 3 | `commands.md` cross-link (mentions "the remaining 17 commands" -> 24-7 = 17, but 23-7 = 16) | Count | **STALE arithmetic** — "17 commands in commands.md" should be "16" |
| 27 | `.claude/rules/workflows.md`, `.claude/rules/git-workflow.md` | Rule links | OK |
| 38 | `.claude/rules/artifact-formats.md` | Rule link | OK |
| 66 | `.claude/docs/reference/standards/agent-frontmatter-standard.md` | Standard link | OK |
| **87** | "annotates `ROAD_MAP.md`" | File reference | **STALE** — renamed to `ROADMAP.md` |
| 87 | `.claude/rules/state-management.md` | Rule link | OK |
| 107 | `../agent-system/context-and-memory.md` | Internal link | OK |
| **120** | "Full catalog of all 24 commands" | Count | **STALE** — 23 |
| 122-123 | `.claude/docs/guides/user-guide.md`, `.claude/docs/examples/research-flow-example.md` | Doc links | OK |

### agent-system/README.md

| Line | Reference | Status |
|---|---|---|
| 3 | `.claude/CLAUDE.md` | OK |
| 20 | "all 24 Claude Code commands" | **STALE** — 23 |
| 56-58 | `.claude/README.md`, `.claude/CLAUDE.md`, `.claude/docs/guides/user-guide.md` | OK |
| 29 | `All 24 .claude/commands/*` (in zed-agent-panel.md actually — see below) | — |

### zed-agent-panel.md

| Line | Reference | Status |
|---|---|---|
| **29** | "Slash commands: All 24 `.claude/commands/*`" | **STALE** — 23 |
| 122-123 | `.claude/docs/guides/user-guide.md`, `.claude/docs/architecture/system-overview.md` | OK |

### context-and-memory.md

| Line | Reference | Status |
|---|---|---|
| 17 | `.memory/README.md` | OK (out of .claude/ scope) |
| 61 | `.claude/commands/learn.md` | OK |
| 77-81 | Context-layer table with `.claude/context/`, `.claude/extensions/*/context/`, `.context/`, `.memory/`, `~/.claude/projects/` | OK |
| 102 | `.claude/context/architecture/context-layers.md` | OK |
| 106-108 | `.memory/README.md`, context-layers.md, learn.md | OK |

This page is untouched by the current .claude/ diff — no known-stale references.

### workflows/convert-documents.md

| Line | Reference | Status |
|---|---|---|
| **12** | "Turn a PowerPoint deck into Beamer/Polylux/Touying source | `/slides`" | **STALE** — should be `/convert --format beamer\|polylux\|touying` |
| **35** | `## /slides — presentations to source-based slides` (entire section) | **STALE** — this is the OLD `/slides`; the new `/slides` is research-talk creation. This section should be deleted or rewritten to cover `/convert --format` for PPTX output; PPTX-to-slide material moves under the `/convert` section above. The `/slides` research-talk command does not belong in convert-documents.md at all (it's a grant/talk workflow, not a document-conversion workflow). |
| 55 | `../agent-system/commands.md` | OK |

### workflows/README.md

| Line | Reference | Status |
|---|---|---|
| 11 | "[agent-lifecycle.md] … seven main-workflow commands (`/task`, `/research`, `/plan`, `/implement`, `/todo`)" | OK — only names five, not seven, but that's an existing copy bug unrelated to the diff |
| 19 | "Convert between PDF, DOCX, Markdown, XLSX, PPTX; extract PDF annotations; generate LaTeX/Typst tables" | OK |
| **33** | "Convert a PowerPoint deck into Beamer/Polylux/Touying \| convert-documents.md#slides--presentations-to-source-based-slides" | **STALE anchor** — section header will change or disappear; anchor should point to the new `/convert --format` section |

### workflows/edit-word-documents.md, edit-spreadsheets.md, tips-and-troubleshooting.md

Only `../agent-system/commands.md` and `../general/installation.md#install-mcp-tools` cross-links. No changes needed from the current .claude/ diff.

### general/installation.md, keybindings.md, settings.md, general/README.md

Greps show these reference `.claude/` only in "see also" sections and in the keybindings.md "Claude Code (terminal-based)" block that lists example commands (`/research`, `/plan`, `/implement`, `/convert`). None of these names changed. The one `.claude/docs/guides/user-installation.md` link in installation.md line 301 is valid (file exists). No updates needed.

### docs/README.md

Nine lines, three bullets, no concrete `.claude/` references. No update needed.

## Likely Update Hotspots (ranked)

Ranking combines blast radius (how much content is affected) and severity (how wrong the current text is).

1. **docs/agent-system/commands.md — HIGH, REQUIRED.**
   - Delete the `### /talk` section (lines ~312-330) and repoint its content (the five-mode table, the examples, the description) into a rewritten `### /slides` section.
   - Rewrite the existing `### /slides` section (lines 217-227): remove the "PPTX -> Beamer/Polylux/Touying" description; turn this slot into the research-talk command (new `/slides`).
   - Move the PPTX conversion description into the `### /convert` section (lines 191-202): expand the examples to include `/convert deck.pptx --format beamer` etc.; update flags list to include `--format beamer\|polylux\|touying` and `--theme NAME`.
   - Update the title/header count from "All 24 slash commands" to "All 23 slash commands" (line 3).
   - Sanity-check every `user-guide.md#<anchor>` link against the current `.claude/docs/guides/user-guide.md` (Teammate A/downstream planner work, not this report's scope).

2. **docs/workflows/convert-documents.md — HIGH, REQUIRED.**
   - Rewrite the decision row (line 12) from `/slides` to `/convert --format beamer|polylux|touying`.
   - Delete or rewrite the `## /slides — presentations to source-based slides` section (lines 35-41).
   - Extend the `## /convert` section to cover PPTX -> Beamer/Polylux/Touying with at least one example per format.
   - Update intro paragraph on line 3 if it currently lists `/slides` as a "presentation" tool (it does, implicitly via the decision guide).

3. **docs/workflows/README.md — LOW, REQUIRED.**
   - Fix the decision-guide row on line 33 (anchor change).
   - Everything else still reads correctly.

4. **docs/agent-system/architecture.md — LOW, REQUIRED.**
   - Update the configuration-tree counts on lines 84-86 (24 -> 23 commands, 25 -> 24 agents; 32 skills is correct).
   - Update line 95: "All 24 commands" -> "All 23 commands".
   - Update the commit example on lines 53-59 to omit the `Co-Authored-By` trailer per the new documented user preference in `.claude/CLAUDE.md`.

5. **docs/workflows/agent-lifecycle.md — LOW, REQUIRED.**
   - Line 3: "the remaining 17 commands" -> "the remaining 16 commands".
   - Line 87: `ROAD_MAP.md` -> `ROADMAP.md`.
   - Line 120: "all 24 commands" -> "all 23 commands".

6. **docs/agent-system/README.md — LOW, REQUIRED.**
   - Line 20: "all 24 Claude Code commands" -> "all 23 Claude Code commands".

7. **docs/agent-system/zed-agent-panel.md — LOW, REQUIRED.**
   - Line 29 (table row "Slash commands"): "All 24 `.claude/commands/*`" -> "All 23 `.claude/commands/*`".

8. **docs/agent-system/commands.md — the ROAD_MAP.md mention on line 82.**
   - "update CHANGE_LOG and ROAD_MAP" -> "update CHANGE_LOG and ROADMAP".

9. **docs/README.md, docs/general/\*, docs/workflows/edit-\*, workflows/tips-and-troubleshooting.md, agent-system/context-and-memory.md — NO CHANGE.**
   - Verified via Grep: these files either contain no load-bearing `.claude/` reference, or every reference is still valid.

## Historical Update Patterns

### How past .claude/ changes were reflected in docs/

Signal from `git log --oneline -- docs/` (most recent 35 commits):

- **Task 9** (`task 9: create populate docs/workflows/ with command workflow guides`) — single commit, populated the workflows directory after the agent system grew new commands. This is the precedent for "new commands arrived in .claude/, now reflect in workflow docs". The commit touched multiple files in one shot with phase-style language.
- **Task 8** (~10 phases, commits `task 8 phase 1` through `task 8 phase 10`) — restructured docs/ to add `workflows/`, moved `agent-system/workflow.md` into `workflows/agent-lifecycle.md`, and then explicitly had two follow-up phases (`phase 8: repair inbound links to agent-system/workflow.md`, `phase 9: repair inbound links to office-workflows.md`) dedicated to fixing link rot from the rename. **This is the prior-art pattern for handling the `/talk` -> `/slides` rename**: do the content change in one phase, then a follow-up phase for "repair inbound links to /talk".
- **Task 7** (5 phases) — retrofitted the `installation.md` detect/install/verify pattern across existing sections. Illustrative of how style conventions ripple: one phase per section, one phase for summary/quickstart, one phase for verification checklist.
- **Task 6** (not visible as numbered phases, but inferable from content) — expanded `agent-system/` docs, added commands.md, context-and-memory.md, architecture.md.
- **Task 5, task 3, task 2, task 1** — earlier iterations that built up the tree.
- Task 10 is the current task (this research).

### Convention patterns observed

1. **Phase-per-file when touching multiple files**. `task N phase P: <action>` with P scoped to a single file or single concern.
2. **Dedicated "repair inbound links" phase** when a file moves, renames, or a concept moves between files. The `/talk` -> `/slides` change is exactly this kind of cross-file rename.
3. **"update summary" or "update verify checklist" as its own phase** at the end of a multi-phase edit. Suggests the planner should budget a final phase to re-verify the whole docs/ tree and fix drifted cross-links.
4. **Counts are hand-maintained** (24 commands, 25 agents, 32 skills). There is no script generating these numbers, so drift is expected and correction is a known maintenance chore.
5. **No README/top-level index rewrites for content changes** — `docs/README.md` at 9 lines is essentially static and does not get touched when the command surface changes. Keep it that way.
6. **`.claude/`-side changes propagate to docs/ manually with a lag**. Commits in .claude/ (e.g., the `/talk` -> `/slides` rename lives in task 9's planning and earlier commits) are not mirrored until an explicit "update docs from claude diff" task like this one.

## Recommended Update Strategy

### Surgical, not broad

The docs/ tree architecture is sound and was rebuilt in task 8. Do **not** restructure. Do **not** rewrite files wholesale. Do **not** change the four-section layout (general / agent-system / workflows / root). Downstream planner should treat this as a targeted patch.

### Suggested phase plan (rough; planner owns the final shape)

- **Phase 1** — `docs/agent-system/commands.md`: rewrite `/slides`, delete `/talk`, extend `/convert`, fix the count in the title and the ROAD_MAP mention on line 82. This is the single biggest edit; it's also the anchor the rest of docs/ links to.
- **Phase 2** — `docs/workflows/convert-documents.md`: retire the old `/slides` section; document PPTX-to-slide inside `/convert`. Update decision guide at the top.
- **Phase 3** — `docs/workflows/README.md`: fix the decision-guide row that links to the old `/slides` anchor in convert-documents.md. (Dependent on phase 2's final anchor names.)
- **Phase 4** — `docs/agent-system/architecture.md`: update the configuration tree counts (24 -> 23 commands, 25 -> 24 agents), the "All 24 commands" sentence, and the commit example Co-Authored-By trailer removal.
- **Phase 5** — count and rename corrections in the three cheap files: `agent-system/README.md` (one count), `agent-system/zed-agent-panel.md` (one count), `workflows/agent-lifecycle.md` (count + arithmetic + ROAD_MAP -> ROADMAP).
- **Phase 6** — whole-tree verification: re-Grep for `/talk`, `ROAD_MAP`, `24 commands`, `25 agent`, `deck.pptx`, `Co-Authored-By` to make sure nothing was missed. Fix any inbound-link drift. This is the analogue of task 8 phases 8-9 ("repair inbound links").

### What NOT to change

- Do not rewrite `general/installation.md` — the MCP tool setup is unchanged.
- Do not touch `general/keybindings.md`'s "Claude Code (terminal-based)" example block — it lists `/research`, `/plan`, `/implement`, `/convert`, all of which are still valid.
- Do not touch `agent-system/context-and-memory.md` — the five-layer and two-memory architecture is unchanged.
- Do not touch `workflows/edit-word-documents.md`, `edit-spreadsheets.md`, or `tips-and-troubleshooting.md` — `/edit`, openpyxl, and SuperDoc are unchanged.
- Do not touch `docs/README.md`.
- Do not propose mentioning `.claude/scripts/check-extension-docs.sh` or `.claude/rules/plan-format-enforcement.md` in docs/ — neither of these user-invisible pieces has ever been documented there, and this task should not expand the docs surface.

### Known risks for the planner

- **Link anchors**: section headers will change in commands.md and convert-documents.md. Inbound `#<anchor>` links from workflows/README.md and any "See also" section that points into these files need to be re-verified after phase 2.
- **Talk-mode table**: the five-mode table (CONFERENCE/SEMINAR/DEFENSE/POSTER/JOURNAL_CLUB) exists in both docs/agent-system/commands.md AND in `.claude/CLAUDE.md`. When moving it from the old `/talk` slot to the new `/slides` slot in commands.md, double-check it still matches the CLAUDE.md version word-for-word (Teammate A likely has the authoritative version from the .claude/ diff).
- **Command count may drift again** mid-edit if another extension command lands. Planner should recount `ls .claude/commands/ | wc -l` in the final verification phase, not rely on "23" being baked into the plan.
- **Co-Authored-By inconsistency**: the current git log shows recent commits still carrying the trailer despite the new "omit" policy. Planner should treat the docs/ example as documentation-of-intent, not documentation-of-current-practice, and update it to match the documented policy.

## Decisions

- **Scope**: docs/ content only, not docs/-adjacent files like the root README.md or .claude/ itself. Confirmed by re-reading the task prompt.
- **Depth of .claude/ diff inspection**: enough to confirm or refute each docs/ reference's current validity. Full .claude/ diff enumeration delegated to Teammate A.
- **Do not edit**: explicit directive from the prompt, honored. This report is analysis only.
- **Count claims**: verified by `ls .claude/commands/ | wc -l` (=23), `ls .claude/agents/ | grep -v README | wc -l` (=24), `ls .claude/skills/ | wc -l` (=32).

## Risks & Mitigations

- **Risk**: Teammate A's findings could reveal additional stale content in docs/ that I did not catch (e.g., a skill rename, an agent model change, a new task-type). *Mitigation*: downstream planner should overlay Teammate A's catalog on my docs/ reference map and grep for any names flagged there that appear in docs/.
- **Risk**: The `/slides` command's argument surface may grow again (e.g., `--design` flag is visible in the current slides.md). Docs/ need to stay intentionally terse on flags and defer to user-guide.md. *Mitigation*: in the commands.md rewrite, list only stable flags and leave deep flag docs to `.claude/docs/guides/user-guide.md` — same pattern already used for other commands.
- **Risk**: PPTX conversion examples in docs/ may duplicate examples in `.claude/commands/convert.md`. *Mitigation*: keep docs/ examples minimal (one per slide format) and link into `.claude/commands/convert.md` for the full list.
- **Risk**: Mid-edit, the `Co-Authored-By` policy may be walked back. *Mitigation*: keep that single change isolated in phase 4 so it can be reverted without affecting the other docs changes.

## Context Extension Recommendations

- **Topic**: "docs/ maintenance playbook — how to propagate .claude/ changes into docs/".
- **Gap**: There is no documented convention for *when* docs/ should be updated in response to .claude/ changes. The pattern is clearly "manually, in a dedicated task like task 10", but that's implicit in git history rather than written down.
- **Recommendation**: Consider adding a short `.claude/context/patterns/docs-sync-pattern.md` that documents (a) the grep targets to check (`24`, `25`, `ROAD_MAP`, `/talk`, `deck.pptx`, etc.), (b) the phase-per-file update convention, and (c) the "final verification phase" convention seen in task 8. This is out of scope for the current task but would make future updates cheaper.

## Appendix

### Commands used

```
Glob: docs/**/*
Read: all 16 docs/*.md files in full
Grep: \.claude/|\bskill-|\bagent\b|/[a-z][a-z-]+\b   (over docs/)
Grep: /talk\b                                         (over docs/)
Grep: /slides                                         (over docs/)
Grep: 24 (commands|slash)|25 agent|32 skill           (over docs/)
Grep: ROAD_MAP|ROADMAP                                (over docs/, whole repo)
Grep: Co-Authored-By|Claude Opus 4\.6                 (over docs/)
Grep: --create-tasks|--quick|--analyze                (over .claude/commands/)
Grep: export-to-markdown|check-extension-docs|tasks\.json (over docs/)
Bash: ls .claude/commands/ | wc -l                    (=23)
Bash: ls .claude/agents/ | grep -v README | wc -l     (=24)
Bash: ls .claude/skills/ | wc -l                      (=32)
Bash: ls .claude/commands/talk.md                     (does not exist)
Bash: head -30 .claude/commands/slides.md             (shows new research-talk command with explicit "was previously named /talk" note)
Bash: head -30 .claude/commands/convert.md            (shows new --format beamer|polylux|touying flag)
Bash: git diff HEAD -- .claude/CLAUDE.md              (confirms /slides rename, ROADMAP rename, Co-Authored-By omission policy, new script, new rule file)
Bash: git diff HEAD -- .claude/commands/review.md     (confirms ROAD_MAP -> ROADMAP across roadmap-handling steps)
Bash: git diff HEAD -- .claude/commands/todo.md       (same — ROADMAP rename)
Bash: git diff HEAD -- .claude/commands/convert.md    (confirms --format beamer|polylux|touying, expanded examples, "Research-talk task creation uses /slides" cross-reference)
Bash: git log --oneline -15 -- docs/                  (historical update patterns)
Bash: git log -5 --format=%B                          (commit-format sanity check)
```

### Evidence snippets

From `.claude/commands/slides.md` (current head):
```
description: Create research talk tasks with pre-task forcing questions for academic presentations
...
**Note**: This command was previously named `/talk`. For PPTX slide file conversion (not research talk creation), use `/convert --format beamer|polylux|touying` in the `filetypes` extension.
```

From `.claude/commands/convert.md` (current head):
```
argument-hint: SOURCE_PATH [OUTPUT_PATH] [--format beamer|polylux|touying] [--theme NAME]
...
| PPTX | Beamer | Uses python-pptx + pandoc (via `--format beamer`) |
| PPTX | Polylux | Uses python-pptx -> Typst (via `--format polylux`) |
| PPTX | Touying | Uses python-pptx -> Typst (via `--format touying`) |
```

From `.claude/CLAUDE.md` diff:
```
-| `/convert` | `/convert file.pdf` | Convert between document formats |
+| `/convert` | `/convert file.pdf` | Convert between document formats; `/convert deck.pptx --format beamer` for slide output |
-| `/slides` | `/slides deck.pptx` | Convert presentations to Beamer/Polylux/Touying |
...
-| `/talk` | `/talk "Description"` | Create research talk task with forcing questions |
+| `/slides` | `/slides "Description"` | Create research talk task with forcing questions |
```

And the Co-Authored-By policy note added to `.claude/CLAUDE.md`:
```
**Note**: Per user preference (see `~/.claude/projects/.../feedback_no_coauthored_by.md`), omit `Co-Authored-By` trailers from all commits.
```

File existence checks:
- `.claude/commands/talk.md` — does not exist (deleted)
- `.claude/commands/slides.md` — exists, content is now research-talk creation
- `.claude/commands/convert.md` — exists, content now includes PPTX-to-slide formats

## Confidence Level

**High** for all claims in the "References to .claude/ Content" tables and the "Likely Update Hotspots" list — every stale reference was verified by either (a) direct existence check of the referenced file, (b) direct Grep against the current .claude/ tree, or (c) reading the current .claude/CLAUDE.md diff hunk.

**Medium** for the "Historical Update Patterns" section — inferred from `git log` and spot-checks of commit subject lines; I did not read the bodies of every referenced commit.

**Medium-High** for the surgical-vs-broad recommendation — this is a judgment call, but the evidence (docs/ was rebuilt in task 8, architecture matches, only 2 files need substantive content edits, everything else is token-level) all points the same direction.

**Low uncertainty areas**:
- Whether Teammate A's .claude/ catalog will surface additional items that ripple into docs/. Most likely candidates: a skill rename, an agent removal, or a new task-type. Planner should reconcile both reports before finalizing phase 1.
- Whether the planner will consolidate phases 5 and 6 into one "mop-up" phase (reasonable) or keep them separate.
