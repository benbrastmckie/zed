# Implementation Plan: Task #5

- **Task**: 5 - Update docs/agent-system.md to accurately represent the .claude/ agent system
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/005_update_agent_system_docs/reports/01_agent-system-docs.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, artifact-formats.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Rewrite `docs/agent-system.md` from a partial command listing into a topic-organized orientation document that accurately reflects the `.claude/` system in this Zed workspace. The rewrite is grounded in the research report's ground-truth inventory (24 commands, 32 skills, 25 agents) and executes as a mostly single-file edit with verification of cross-reference targets. Preserve load-bearing sections (installation, MCP tool setup, Zed Agent Panel) verbatim; replace the command catalog with a Main Workflow section plus topic-grouped reference; add a dedicated Memory System section distinguishing the project `.memory/` vault from Claude Code auto-memory.

### Research Integration

The research report (`reports/01_agent-system-docs.md`) provides: (1) a full audit of what the current doc gets right vs wrong, (2) a verified inventory of all 24 commands with frontmatter descriptions, (3) detailed prose for the 7 main workflow commands, (4) topic groupings for the remaining 17 commands, (5) a two-layer memory model, (6) 22 pre-verified cross-reference targets with relative paths, and (7) seven structural improvements. The planner treats this report as the single source of truth and cites it; the implementer should not need to re-derive the inventory.

Key decisions from the research to honor:
- **D1** topic-based grouping, main lifecycle up top
- **D2** treat extensions as documented-but-not-installed; no `<leader>ac` mentions
- **D3** drop `/tag` entirely (no command file in this repo)
- **D4** split memory into Project Vault + Auto-Memory sub-sections
- **D5** preserve installation and MCP sections verbatim
- **D6** link to `.claude/CLAUDE.md` as canonical power-user reference

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROAD_MAP.md consulted for this task.

## Goals & Non-Goals

**Goals**:
- Rewrite `docs/agent-system.md` so every command mentioned exists in `.claude/commands/` and every command in `.claude/commands/` is discoverable from the doc.
- Provide a clear "Main Workflow" section covering the seven lifecycle + clean-up commands with lifecycle state transitions.
- Group the remaining 17 commands by topic (Task mgmt & recovery, System/meta, Memory, Document conversion, Research presentation & grants).
- Add a dedicated Memory System section that distinguishes `.memory/` (agent-written, shared with OpenCode) from `~/.claude/projects/.../memory/` (harness-managed auto-memory).
- Add 22 verified cross-reference links into `.claude/`, `.claude/docs/`, `.claude/rules/`, and `.memory/`.
- Preserve the Installation, MCP Tool Setup, Zed Agent Panel, and Zed keybindings sections without content changes.

**Non-Goals**:
- No changes to `.claude/CLAUDE.md`, `.claude/README.md`, or `.claude/docs/`.
- No new commands, skills, agents, or extensions.
- No changes to `.memory/` structure or its README.
- No reconciliation of CLAUDE.md's "extensions" advertising with the actual filesystem (tracked separately as a context extension recommendation in the research report).
- Not a reference manual — the doc stays orientation-focused; detail lives in `.claude/docs/`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-reference target file missing or renamed | M | L | Phase 1 verifies every target path with Read/ls before writing links in Phase 5 |
| Doc drifts into reference manual, bloats past ~400 lines | M | M | Hard cap main-workflow section at ~150 lines; push detail into links |
| Rewrite loses accurate sections (installation, MCP setup, Zed panel) | H | L | Phase 1 extracts verbatim blocks into a preservation list; Phase 2 reinserts them untouched |
| Extension mentions re-introduce `<leader>ac` confusion | M | M | Explicit non-goal; reviewer checklist in Phase 6 greps for `leader ac` and `extensions/` to confirm absence |
| `/tag` reference sneaks back in via copy-paste from CLAUDE.md | L | M | Phase 6 greps for `/tag` and confirms zero occurrences |
| Markdown link syntax errors break navigation | M | L | Phase 5 validates all 22 links with a relative-path existence check |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 2, 3, 4 |
| 4 | 6 | 5 |

Phases 2, 3, and 4 edit disjoint sections of the new doc and can run in parallel once Phase 1 has produced the outline and preservation list. Phase 5 integrates and cross-links; Phase 6 verifies.

### Phase 1: Preparation, Outline, and Target Verification [NOT STARTED]

**Goal**: Produce a concrete section outline for the new `docs/agent-system.md`, verify every cross-reference target exists, and extract the verbatim blocks to preserve from the current file.

**Tasks**:
- [ ] Read `/home/benjamin/.config/zed/docs/agent-system.md` in full and identify the exact line ranges of the Installation, MCP Tool Setup, Zed Agent Panel, and Zed keybindings sections to preserve verbatim.
- [ ] Create a preservation snippet file at `/tmp/agent-system-preserved.md` (temp, discarded after) containing the verbatim blocks, or capture them in working memory.
- [ ] Verify each of the 22 cross-reference targets listed in Finding 6 of the research report exists:
  - `.claude/CLAUDE.md`, `.claude/README.md`, `.claude/docs/README.md`
  - `.claude/docs/architecture/system-overview.md`, `.claude/docs/architecture/extension-system.md`
  - `.claude/docs/guides/user-guide.md`, `.claude/docs/guides/user-installation.md`, `.claude/docs/guides/component-selection.md`, `.claude/docs/guides/creating-commands.md`, `.claude/docs/guides/creating-skills.md`, `.claude/docs/guides/creating-agents.md`, `.claude/docs/guides/creating-extensions.md`
  - `.claude/docs/reference/standards/agent-frontmatter-standard.md`, `.claude/docs/reference/standards/multi-task-creation-standard.md`
  - `.claude/rules/state-management.md`, `.claude/rules/git-workflow.md`, `.claude/rules/artifact-formats.md`, `.claude/rules/error-handling.md`, `.claude/rules/workflows.md`
  - `.memory/README.md`
  - `.claude/docs/examples/research-flow-example.md`, `.claude/docs/examples/fix-it-flow-example.md`
- [ ] For any missing target: log it, pick the closest existing alternative, or drop the link.
- [ ] Confirm `.claude/commands/tag.md` does NOT exist (re-verify research finding) and `.claude/extensions/` does NOT exist.
- [ ] Write the final section outline as a comment block or scratch notes:
  1. Title + 2-sentence tagline
  2. Two AI Systems overview (Zed panel vs Claude Code) — preserve
  3. Installation — preserve verbatim
  4. Claude Code: Main Workflow (lifecycle + clean-up) — NEW
  5. Command Catalog by Topic — NEW
  6. Memory System (Project Vault + Auto-Memory) — NEW
  7. Architecture & Configuration (checkpoint execution, state machine, session IDs) — NEW
  8. MCP Tool Setup — preserve verbatim
  9. Zed Agent Panel (keybindings, panel commands) — preserve verbatim
  10. Related Documentation (cross-references) — NEW
  11. Known Limitations — revise (drop `/tag`)

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- None in this phase (read-only preparation)

**Verification**:
- Outline written and covers all 11 sections above.
- List of missing cross-reference targets is empty, OR each miss has a documented substitute/drop.
- Preserved-section line ranges recorded.

---

### Phase 2: Main Workflow Section [NOT STARTED]

**Goal**: Draft the "Claude Code: Main Workflow" section covering `/task`, `/research`, `/plan`, `/revise`, `/implement`, `/review`, `/todo` with the task lifecycle state machine.

**Tasks**:
- [ ] Write an ASCII lifecycle diagram:
  ```
  [NOT STARTED] --/research--> [RESEARCHING] --> [RESEARCHED]
                --/plan-----> [PLANNING]    --> [PLANNED]
                --/implement-> [IMPLEMENTING]--> [COMPLETED]
  ```
  including `[BLOCKED]`, `[ABANDONED]`, `[PARTIAL]`, `[EXPANDED]` as exception states.
- [ ] For each of the seven commands, write a ~8-12 line entry using Finding 3 of the research report as source:
  - `/task` — create/recover/expand/sync/abandon (include `--review`)
  - `/research` — routes by task_type; multi-task syntax; `--team` flag; writes to `reports/MM_{short-slug}.md`
  - `/plan` — delegates to `planner-agent` (opus); writes to `plans/MM_{short-slug}.md`
  - `/revise` — versions plans or updates descriptions
  - `/implement` — resumable; `--force`; `--team`; writes `summaries/MM_{short-slug}-summary.md`
  - `/review` — tier-grouped; optional `--create-tasks`
  - `/todo` — archives completed/abandoned; annotates ROAD_MAP.md; vault operation trigger
- [ ] Add a short "Multi-task syntax" callout: `/research 5, 7-9` runs tasks in parallel.
- [ ] Add a short "Team mode" callout: `--team` requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, ~5x tokens, degrades gracefully.
- [ ] Add artifact path reference: `specs/{NNN}_{slug}/{reports,plans,summaries}/MM_{short-slug}.md`.
- [ ] Keep total section at ~150 lines. Push anything longer into links to `.claude/docs/guides/user-guide.md`.

**Timing**: 60 minutes

**Depends on**: 1

**Files to modify**:
- `/home/benjamin/.config/zed/docs/agent-system.md` — draft Main Workflow section content (not yet merged; stage in working buffer or scratch)

**Verification**:
- All seven commands have entries.
- Lifecycle diagram present with exception states.
- Multi-task and team-mode callouts present.
- Section is <= ~150 lines.

---

### Phase 3: Topic-Grouped Command Reference [NOT STARTED]

**Goal**: Draft the "Command Catalog by Topic" section covering all 17 non-main-workflow commands organized into five topic groups.

**Tasks**:
- [ ] Create group headers and entries using Finding 4 of the research report. Each entry: 2-4 lines with the command syntax and one-line purpose.
- [ ] **Task management & recovery**: `/spawn`, `/errors`, `/fix-it`, `/refresh`.
- [ ] **System / meta**: `/meta`, `/merge`. Note that `/meta` never implements directly — it always produces tasks.
- [ ] **Memory**: `/learn` (four modes: text, file, directory, `--task N`). Cross-link forward to the Memory System section.
- [ ] **Document conversion & editing** (filetypes domain): `/convert`, `/table`, `/slides`, `/scrape`, `/edit`.
- [ ] **Research presentation & grants** (present domain): `/grant`, `/budget`, `/timeline`, `/funds`, `/talk`. Include the five talk modes (CONFERENCE, SEMINAR, DEFENSE, POSTER, JOURNAL_CLUB) in a compact table under `/talk`.
- [ ] Confirm every command in the catalog exists in `.claude/commands/` (17 = 24 total - 7 main workflow).
- [ ] Explicitly do NOT mention `/tag` anywhere.
- [ ] Add a one-sentence note that "all 24 commands in this repo are always available; no extension loading is required".

**Timing**: 60 minutes

**Depends on**: 1

**Files to modify**:
- `/home/benjamin/.config/zed/docs/agent-system.md` — draft Command Catalog section

**Verification**:
- 17 commands listed across 5 topic groups.
- No `/tag` reference.
- Count: 7 (main workflow) + 17 (catalog) = 24 (total in `.claude/commands/`).

---

### Phase 4: Memory System Section [NOT STARTED]

**Goal**: Draft a dedicated "Memory System" section with two sub-sections distinguishing the project memory vault from Claude Code auto-memory.

**Tasks**:
- [ ] Write a 2-3 sentence intro framing the two-layer model.
- [ ] **Sub-section: Project Memory Vault (`.memory/`)** using Finding 5 of the research report:
  - Location: `/home/benjamin/.config/zed/.memory/`
  - Managed by agents via `skill-memory` and `/learn`
  - Shared with OpenCode (Obsidian-compatible, MCP ports 22360 / 27124, grep fallback)
  - Structure tree: `00-Inbox/`, `10-Memories/`, `20-Indices/`, `30-Templates/`
  - File format: YAML frontmatter; filename `MEM-{semantic-slug}.md`
  - Write path: `/learn` (four modes)
  - Read path: grep-based discovery; `/research N --remember` injects matches into research context
  - What belongs: learned facts, discoveries, decisions, reusable patterns
- [ ] **Sub-section: Auto-Memory (Claude Code harness)**:
  - Location: `~/.claude/projects/-home-benjamin--config-zed/memory/`
  - Managed by the Claude Code harness, not by agents
  - Stores user preferences and behavioral corrections automatically captured from conversation
  - Agents do not read or write this directory; users do not edit it directly
  - Cite the current `feedback_no_vim_mode_zed.md` example.
- [ ] Add a **Context architecture table** (from CLAUDE.md's five-layer model) showing agent context / extensions / project context / project memory / auto-memory with owner and purpose columns.
- [ ] Link forward to `.memory/README.md` for full vault documentation.

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `/home/benjamin/.config/zed/docs/agent-system.md` — draft Memory System section

**Verification**:
- Two sub-sections present and clearly distinguish vault from auto-memory.
- Both absolute paths shown.
- Five-layer context table included.
- `.memory/README.md` link present.

---

### Phase 5: Assemble, Cross-Link, and Polish [NOT STARTED]

**Goal**: Merge the Phase 2/3/4 drafts into the new `docs/agent-system.md` in the order established by Phase 1, insert all 22 cross-references, reinsert the preserved sections verbatim, and add the remaining structural elements.

**Tasks**:
- [ ] Using Write, produce the full new `docs/agent-system.md` in the order:
  1. Title + tagline
  2. Two AI Systems intro (preserved, possibly lightly updated)
  3. Installation (preserved verbatim)
  4. Main Workflow (from Phase 2)
  5. Command Catalog by Topic (from Phase 3)
  6. Memory System (from Phase 4)
  7. Architecture & Configuration — checkpoint execution (GATE IN -> DELEGATE -> GATE OUT -> COMMIT), state machine recap, session ID format (`sess_{unix}_{random}`), directory tree expanded to include `docs/`, `rules/`, `scripts/`, `specs/{state.json,TODO.md,errors.json,{NNN}_{SLUG}/}`
  8. MCP Tool Setup (preserved verbatim)
  9. Zed Agent Panel + keybindings (preserved verbatim)
  10. Known Limitations — revised: drop `/tag`; add note about extension loading being a neovim-only feature
  11. Related Documentation — bulleted list grouping the 22 verified cross-reference links
- [ ] Insert inline cross-reference links throughout the body where natural (e.g., link `planner-agent` in the `/plan` entry to `.claude/docs/reference/standards/agent-frontmatter-standard.md`).
- [ ] Ensure the Related Documentation section groups links under: **Canonical references**, **Guides**, **Standards**, **Rules**, **Examples**, **Memory vault**.
- [ ] Add one sentence in the intro linking to `.claude/CLAUDE.md` as the power-user canonical reference.
- [ ] Quick proofread: fix tense, voice, and formatting consistency.

**Timing**: 60 minutes

**Depends on**: 2, 3, 4

**Files to modify**:
- `/home/benjamin/.config/zed/docs/agent-system.md` — full rewrite (single Write call)

**Verification**:
- File exists and is between ~350 and ~500 lines.
- All 11 sections present in order.
- All 22 cross-reference links present (count them).
- Preserved sections match the originals exactly (diff check against Phase 1 extracts).

---

### Phase 6: Verification Pass [NOT STARTED]

**Goal**: Systematically verify the rewritten doc matches the research report inventory and has no regressions.

**Tasks**:
- [ ] **Command parity check**: grep the new doc for each of the 24 command names and confirm all 24 appear at least once. Confirm `/tag` appears zero times.
- [ ] **Forbidden-term check**: grep for `leader ac`, `<leader>ac`, `.claude/extensions/`, `extension loading`, `/tag`. Each should return zero hits (or in the case of the documented-not-available note about extensions, exactly one explicit disclaimer hit).
- [ ] **Cross-reference resolution check**: for each of the 22 links, use Read or ls to confirm the relative path resolves to an existing file from `/home/benjamin/.config/zed/docs/`.
- [ ] **Section presence check**: confirm all 11 top-level sections from Phase 1's outline exist.
- [ ] **Preserved-content check**: diff-compare preserved sections against Phase 1 extracts; should be byte-identical (except possibly surrounding whitespace).
- [ ] **Length check**: new doc is between ~350 and ~500 lines; Main Workflow section is <= ~150 lines.
- [ ] **Read-through pass**: read the doc end-to-end once for flow, tense, and clarity. Fix any final issues with Edit.
- [ ] Run the postflight script: `bash .claude/scripts/update-task-status.sh postflight 5 plan sess_1775846087_planner`.

**Timing**: 45 minutes

**Depends on**: 5

**Files to modify**:
- `/home/benjamin/.config/zed/docs/agent-system.md` — only minor fixes found during the read-through

**Verification**:
- All 24 commands present; `/tag` absent.
- All 22 links resolve.
- Forbidden terms absent.
- Postflight script exits 0.

---

## Testing & Validation

- [ ] All 24 commands from `.claude/commands/` are mentioned in the new doc.
- [ ] `/tag` is absent.
- [ ] All 22 cross-reference links resolve to existing files.
- [ ] Preserved sections (Installation, MCP Tool Setup, Zed Agent Panel, Zed keybindings) are byte-identical to the original.
- [ ] The Memory System section has two clearly distinguished sub-sections.
- [ ] Main Workflow section is <= ~150 lines.
- [ ] Total doc length between ~350 and ~500 lines.
- [ ] Read-through pass finds no broken sentences, missing links, or formatting errors.

## Artifacts & Outputs

- `/home/benjamin/.config/zed/docs/agent-system.md` (rewritten)
- `/home/benjamin/.config/zed/specs/005_update_agent_system_docs/summaries/01_agent-system-docs-summary.md` (produced by `/implement` postflight)

## Rollback/Contingency

- The current `docs/agent-system.md` is under git version control. If the rewrite is unsatisfactory, `git checkout HEAD -- docs/agent-system.md` restores the original.
- If Phase 1 discovers that >3 cross-reference targets are missing, pause and report: the research report's link inventory may be out of date and a quick re-audit is cheaper than embedding broken links.
- If Phase 5 produces a doc >600 lines, trim the Command Catalog entries to 2 lines each and push any remaining detail to `.claude/docs/guides/user-guide.md` via a forward link.
