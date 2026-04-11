# Teammate A Findings: Catalog of `.claude/` Changes for docs/ Update

**Task**: 10 - Update docs/ based on .claude/ diff
**Teammate**: A (Primary Angle)
**Branch**: `master` (no `main` branch exists in this repo)
**Diff Scope**: working-tree (staged + unstaged) vs `HEAD`, as `git diff main...HEAD` is not resolvable (no `main` ref)
**Methodology**: Full `git diff HEAD -- .claude/` saved to disk (17,879 lines across 49 files) and read section-by-section.

Commits are already on `master` and not pending; the meaningful change surface for this task is entirely the **uncommitted working-tree diff against HEAD**. Recent committed history (tasks 7-9) does not touch `.claude/` structurally.

---

## Key Findings

- **Command rename `/talk` -> `/slides`** is the single biggest user-facing change. `.claude/commands/talk.md` is **deleted** and its entire body (forcing questions, talk modes, design workflow) is merged into `.claude/commands/slides.md`. The *old* `/slides` command (PPTX file conversion to Beamer/Polylux/Touying) is **moved into `/convert` as a `--format` flag**. Two user-facing mentions of `/slides` and one mention of `/talk` in `docs/` are now stale.
- **Repository-wide file rename `specs/ROAD_MAP.md` -> `specs/ROADMAP.md`** affects 16+ `.claude/` files. `docs/workflows/agent-lifecycle.md` still refers to `ROAD_MAP.md`.
- **Convert command gains slide-output flags** `--format beamer|polylux|touying` and `--theme NAME`, plus dispatch logic that routes PPTX+format to `skill-presentation` (keeping `skill-filetypes` for everything else). `docs/workflows/convert-documents.md` and `docs/agent-system/commands.md` both need updating.
- **Agent frontmatter standard simplified** to the minimal `name` / `description` / `model` form. Old XML/YAML fields (`mode`, `temperature`, `tools`, `max_tokens`, `timeout`, `permissions`, `context_loading`, `delegation`, `lifecycle`) are explicitly documented as unsupported and are removed from all 5 committed core agent files. `docs/` does not show agent frontmatter examples, so this is likely a no-op for `docs/` but worth confirming.
- **New agent `reviser-agent`** is added to `.claude/README.md` and the skill-agent-mapping table. Not present in `docs/agent-system/commands.md` command listings, but commands.md does mention `/revise` — confirm whether the agent list needs updating.
- **Standards consolidation**: `.claude/context/standards/documentation.md` is **deleted**, its content merged and expanded into `.claude/context/standards/documentation-standards.md` (now includes Core Principles, Content Guidelines, Formatting Standards, README template, Version History prohibition, Validation section, Quality Checklist).
- **New utility script** `.claude/scripts/check-extension-docs.sh` is added (doc-lint for extension READMEs/manifests). Referenced in CLAUDE.md and `creating-extensions.md`.
- **Co-Authored-By trailers removed** from all commit example blocks per user feedback memory. `docs/agent-system/architecture.md` still contains a `Co-Authored-By: Claude Opus 4.6 (1M context)` example.
- **New rule file reference** `.claude/rules/plan-format-enforcement.md` added to core rules list in CLAUDE.md.
- **creating-commands.md guide completely rewritten** from the old "OpenAgents vs Neovim / XML frontmatter / hybrid architecture" narrative to a simpler checkpoint-based (GATE IN -> DELEGATE -> GATE OUT -> COMMIT) guide with the new minimal frontmatter.
- **Agent and subagent templates** (`.claude/context/templates/{agent,subagent}-template.md` and `.claude/docs/templates/{agent,command}-template.md`) rewritten from verbose 8-stage XML bodies to compact Stage 0-7 markdown templates aligned with the new frontmatter standard.
- **Extensions.json shows structural cleanup**: the `opencode_json` merged-sections key is removed from every extension entry (latex, filetypes, typst, epidemiology, memory, present). The `filetypes` extension's `installed_files` no longer lists `.claude/commands/slides.md`; the `present` extension now owns `.claude/commands/slides.md` (replacing `.claude/commands/talk.md`).
- **Context index reshuffle**: `.claude/context/index.json` and its backup have ~4000 lines of changes, but nearly all are key-order reshuffling (sorted differently) — the only **semantic** change is the removal of `standards/documentation.md` and the updated `line_count`/`summary`/`keywords` for `standards/documentation-standards.md`.
- **Team skills (research/plan/implement)** now include explicit "Update TODO.md" blocks with the count-aware artifact-linking format (inline vs multi-line handling) that was previously only in `state-management.md`.

---

## Change Inventory

### Root / CLAUDE.md / README

| File | Type | Area | Summary |
|------|------|------|---------|
| `.claude/CLAUDE.md` | MODIFIED | root config | ROAD_MAP->ROADMAP; /talk->/slides mention; check-extension-docs.sh added; Co-Authored-By removed from example + feedback note added; plan-format-enforcement.md added; /convert row updated (removed standalone /slides row from filetypes table); /slides row rewritten under present extension |
| `.claude/README.md` | MODIFIED | agents table | Added `reviser-agent` to agents list |
| `.claude/agents/README.md` | MODIFIED | agents doc | Added `reviser-agent.md`; rewrote frontmatter example from verbose YAML (`mode`, `temperature`, `tools:`) to minimal (`name`, `description`, `model`); added pointer to `agent-frontmatter-standard.md`; describes required vs optional fields |

### Commands

| File | Type | Area | Summary |
|------|------|------|---------|
| `.claude/commands/talk.md` | DELETED | commands | Entire 477-line command removed; content migrated to slides.md |
| `.claude/commands/slides.md` | MODIFIED (effective rename) | commands | Full rewrite: from PPTX-file-conversion command to research-talk task command (forcing questions, talk modes, design workflow). Adds note at top: "This command was previously named `/talk`. For PPTX slide file conversion use `/convert --format beamer|polylux|touying`." |
| `.claude/commands/convert.md` | MODIFIED | commands | Adds `--format beamer|polylux|touying` and `--theme` flags, parse loop, PPTX-to-slide dispatch branching between `skill-presentation` and `skill-filetypes`, slide-output examples, new success/error output formats for slide path, validate output format step, removed Co-Authored-By line |
| `.claude/commands/review.md` | MODIFIED | commands | ROAD_MAP->ROADMAP rename; adds default ROADMAP.md creation block when file missing (ensures file exists before parsing) |
| `.claude/commands/todo.md` | MODIFIED | commands | ROAD_MAP->ROADMAP rename throughout (~15 occurrences); adds default ROADMAP.md creation block before scanning |

### Agents

| File | Type | Area | Summary |
|------|------|------|---------|
| `.claude/agents/code-reviewer-agent.md` | MODIFIED | agents | Frontmatter minimized: removed `mode`, `temperature`, `tools:` block; added `model: opus` |
| `.claude/agents/general-implementation-agent.md` | MODIFIED | agents | ROAD_MAP->ROADMAP in a comment/example |
| `.claude/agents/general-research-agent.md` | MODIFIED | agents | ROAD_MAP->ROADMAP in roadmap-context stage |
| `.claude/agents/planner-agent.md` | MODIFIED | agents | ROAD_MAP->ROADMAP in roadmap-context stage and plan template example |

### Skills

| File | Type | Area | Summary |
|------|------|------|---------|
| `.claude/skills/skill-planner/SKILL.md` | MODIFIED | skills | ROAD_MAP->ROADMAP in delegation context |
| `.claude/skills/skill-researcher/SKILL.md` | MODIFIED | skills | ROAD_MAP->ROADMAP in delegation context |
| `.claude/skills/skill-reviser/SKILL.md` | MODIFIED | skills | ROAD_MAP->ROADMAP in delegation context |
| `.claude/skills/skill-presentation/SKILL.md` | MODIFIED | skills | Trigger description: "User explicitly runs `/slides`" -> "User runs `/convert` with `.pptx`/`.ppt` source and `--format beamer|polylux|touying`"; delegation_path updated from `["orchestrator","slides",...]` to `["orchestrator","convert",...]` |
| `.claude/skills/skill-talk/SKILL.md` | MODIFIED | skills | All `/talk` references changed to `/slides`; delegation_path updated; error messages updated |
| `.claude/skills/skill-team-research/SKILL.md` | MODIFIED | skills | ROAD_MAP->ROADMAP; adds "Update TODO.md with count-aware artifact linking format" block (~25 lines of edit-tool instructions for single vs multi-line artifact links) |
| `.claude/skills/skill-team-plan/SKILL.md` | MODIFIED | skills | Adds identical count-aware "Update TODO.md" block (~25 lines) |
| `.claude/skills/skill-team-implement/SKILL.md` | MODIFIED | skills | Adds identical count-aware "Update TODO.md" block (~25 lines) |
| `.claude/skills/skill-todo/SKILL.md` | MODIFIED | skills | ROAD_MAP->ROADMAP; adds default ROADMAP.md creation block at Stage 5 |

### Context

| File | Type | Area | Summary |
|------|------|------|---------|
| `.claude/context/core-index-entries.json` | MODIFIED | context index | Updated `standards/documentation-standards.md` entry (new summary, keywords, line_count 300); removed `standards/documentation.md` entry |
| `.claude/context/formats/return-metadata-file.md` | MODIFIED | context format | ROAD_MAP->ROADMAP in roadmap_items field description |
| `.claude/context/formats/roadmap-format.md` | MODIFIED | context format | ROAD_MAP->ROADMAP |
| `.claude/context/formats/task-order-format.md` | MODIFIED | context format | ROAD_MAP->ROADMAP |
| `.claude/context/index.json` | MODIFIED (mostly reshuffle) | context index | Key-ordering reshuffle; semantic diff: removes `standards/documentation.md` entry (line 4708, 11227) and updates `standards/documentation-standards.md` metadata |
| `.claude/context/index.json.backup` | MODIFIED (mostly reshuffle) | context index | Same shape as above |
| `.claude/context/patterns/roadmap-update.md` | MODIFIED | context pattern | ROAD_MAP->ROADMAP |
| `.claude/context/processes/research-workflow.md` | MODIFIED | context process | References to `documentation.md standards` changed to `documentation-standards.md` |
| `.claude/context/project/filetypes/README.md` | MODIFIED | extension context | Heading "Presentations (/slides)" -> "Presentations (/convert --format)" |
| `.claude/context/project/filetypes/domain/conversion-tables.md` | MODIFIED | extension context | Section heading "via /slides" -> "via /convert"; PPTX examples use `/convert ... --format`; note added disambiguating `/slides` (present extension) from PPTX-to-slide conversion; `pandoc` tool row no longer claims `/slides` |
| `.claude/context/project/memory/knowledge-capture-usage.md` | MODIFIED | extension context | ROAD_MAP->ROADMAP |
| `.claude/context/project/present/domain/presentation-types.md` | MODIFIED | extension context | "supported by the /talk command" -> "supported by the /slides command" |
| `.claude/context/reference/README.md` | MODIFIED | context reference | `state-json-schema.md` renamed to `state-management-schema.md`; adds `artifact-templates.md` and `workflow-diagrams.md` rows |
| `.claude/context/reference/skill-agent-mapping.md` | MODIFIED | context reference | Adds reviser-agent, spawn-agent to core skills table; adds skill-orchestrator, skill-git-workflow, skill-fix-it to direct-execution table; renames state-json-schema link |
| `.claude/context/reference/state-management-schema.md` | MODIFIED | context reference | ROAD_MAP->ROADMAP in field description |
| `.claude/context/standards/documentation-standards.md` | MODIFIED (absorbs documentation.md) | standards | Major expansion: adds Core Principles, Content Guidelines (Do/Don't), Formatting Standards (Line Length, Headings, Code Blocks, File Trees, Lists), README Structure Template, README Anti-Patterns, Emoji alternatives as table, Version History prohibition section, External Links, Validation (Pre-Commit Checks, Automated Validation), Quality Checklist |
| `.claude/context/standards/documentation.md` | DELETED | standards | 311 lines; absorbed into documentation-standards.md |
| `.claude/context/templates/agent-template.md` | MODIFIED (rewrite) | templates | 363 lines of orchestrator/research/validation/processing/generation templates with XML bodies replaced with compact ~114-line version describing minimal frontmatter, Stage 0-7 canonical structure, agent-type variants (research/planning/implementation) |
| `.claude/context/templates/subagent-template.md` | MODIFIED (rewrite) | templates | 261 -> 58 lines; old XML process-flow templates replaced with short reference pointing to agent-template.md, with subagent-specific Stage 1 delegation context example and depth-limit note |

### `.claude/docs/` (internal developer docs, distinct from repo `docs/`)

| File | Type | Area | Summary |
|------|------|------|---------|
| `.claude/docs/README.md` | MODIFIED | internal docs | Adds `development/` subdirectory reference with `context-index-migration.md` |
| `.claude/docs/guides/creating-commands.md` | MODIFIED (rewrite) | internal guide | Full rewrite from "OpenAgents vs Neovim / hybrid architecture / XML" to checkpoint-based (GATE IN -> DELEGATE -> GATE OUT -> COMMIT) tutorial using minimal frontmatter, Skill/Task tool invocation, and artifact-formats.md conventions |
| `.claude/docs/guides/creating-extensions.md` | MODIFIED | internal guide | Requires extensions provide `README.md`; describes section-applicability matrix (simple vs complex extensions); lists required sections for all vs complex only; references `.claude/templates/extension-readme-template.md` and the new doc-lint script |
| `.claude/docs/guides/user-guide.md` | MODIFIED | internal guide | ROAD_MAP->ROADMAP in /todo section |
| `.claude/docs/reference/standards/extension-slim-standard.md` | MODIFIED | internal standard | Removes standalone `/slides` row from filetypes command table; updates `/convert` description to mention `--format beamer` |
| `.claude/docs/templates/README.md` | MODIFIED | internal template | `subagent-return-format.md` -> `subagent-return.md` (file rename throughout) |
| `.claude/docs/templates/agent-template.md` | MODIFIED (rewrite) | internal template | 415 lines replaced with ~90-line version using minimal frontmatter and Stage 0-7 pattern |
| `.claude/docs/templates/command-template.md` | MODIFIED (rewrite) | internal template | 144 lines replaced with checkpoint-based command template using new frontmatter (`description`, `allowed-tools`, `argument-hint`, `model`) |

### Extensions / scripts

| File | Type | Area | Summary |
|------|------|------|---------|
| `.claude/extensions.json` | MODIFIED | extensions registry | Reordered extensions (present, memory listed first); removed `opencode_json` merged-sections key from every extension; `filetypes.installed_files` no longer contains `.claude/commands/slides.md`; `present.installed_files` now contains `.claude/commands/slides.md` (replacing `.claude/commands/talk.md`); updated `loaded_at` timestamps |
| `.claude/scripts/check-extension-docs.sh` | UNTRACKED (new file) | scripts | Doc-lint script for extension READMEs, manifests, and cross-references; referenced in CLAUDE.md Utility Scripts section |
| `.claude/scripts/setup-lean-mcp.sh` | UNTRACKED (new file) | scripts | Lean MCP setup helper (not referenced in diff; user-added) |
| `.claude/scripts/verify-lean-mcp.sh` | UNTRACKED (new file) | scripts | Lean MCP verification helper (not referenced in diff; user-added) |
| `.claude/CLAUDE.md.backup` | UNTRACKED | backup | Not relevant |
| `.claude/settings.local.json.backup` | UNTRACKED | backup | Not relevant |

---

## Notable Additions

- **`.claude/scripts/check-extension-docs.sh`** — New doc-lint script. Added to `Utility Scripts` table in `.claude/CLAUDE.md` line 106 and referenced in `.claude/docs/guides/creating-extensions.md` as the tool that flags missing extension README files.
- **`.claude/rules/plan-format-enforcement.md`** — Listed in CLAUDE.md core rules references (line 220). (The file itself is not in the diff, so it was committed previously.)
- **reviser-agent** — Added to `.claude/README.md` agents table (line 105) and `.claude/agents/README.md` table. Also added to `.claude/context/reference/skill-agent-mapping.md` core skills table.
- **`/convert --format beamer|polylux|touying`** — New slide-format dispatch branch in `.claude/commands/convert.md`. Dispatches to `skill-presentation` when source is `.pptx`/`.ppt` AND a slide format flag is present; otherwise routes to `skill-filetypes`. Slide-format success output includes `slide_count` and `has_speaker_notes`.
- **Default ROADMAP.md template auto-creation** — `.claude/commands/review.md`, `.claude/commands/todo.md`, and `.claude/skills/skill-todo/SKILL.md` now create a default `specs/ROADMAP.md` with `# Project Roadmap`, `## Phase 1: Current Priorities (High Priority)`, and `## Success Metrics` headings if the file is missing.
- **Count-aware TODO.md artifact linking** — Added to all three team skills (`skill-team-research`, `skill-team-plan`, `skill-team-implement`). Converts single `- **Research**: [file](path)` to multi-line list when a second artifact is added.
- **Documentation Standards expansion** — `.claude/context/standards/documentation-standards.md` gains: Core Principles, Content Guidelines Do/Don't, Line Length rule (100 chars), ATX heading rule, code block language rules, Unicode file-tree example, emoji-alternative lookup table, Version History prohibition, External Links section, Validation section (Pre-Commit Checks, Automated Validation grep examples), Quality Checklist.

---

## Notable Removals

- **`.claude/commands/talk.md`** — Deleted (477 lines). All content migrated to `slides.md`. Any doc that links to `.claude/commands/talk.md` now has a dead link.
- **`.claude/context/standards/documentation.md`** — Deleted (311 lines). Content merged into `documentation-standards.md`. Anything referencing `documentation.md` as a standalone file is broken.
- **Verbose agent frontmatter fields** — `mode`, `temperature`, `tools:` block, `max_tokens`, `timeout`, `permissions`, `context_loading`, `delegation`, `lifecycle`, `agent_type`, `return_format`, `version` are documented in the new agent template and `.claude/agents/README.md` as **not supported**. Removed from committed agent files.
- **`Co-Authored-By` trailer from example commit blocks** — Removed from `.claude/CLAUDE.md`, `.claude/commands/convert.md`. Per-user-preference memory note added to CLAUDE.md pointing at `~/.claude/projects/.../feedback_no_coauthored_by.md`.
- **`opencode_json` merged-sections** — Removed from every extension entry in `.claude/extensions.json`.
- **Standalone `/slides` row from filetypes extension tables** — Removed from CLAUDE.md filetypes table (line 406) and from `.claude/docs/reference/standards/extension-slim-standard.md`.

---

## Notable Renames/Moves

| From | To | Notes |
|------|----|----|
| `specs/ROAD_MAP.md` | `specs/ROADMAP.md` | Repository-wide rename; ~16 `.claude/` files touched; **`docs/workflows/agent-lifecycle.md:87` still says `ROAD_MAP.md`** |
| `.claude/commands/talk.md` | `.claude/commands/slides.md` | Effective rename: talk.md deleted, old slides.md content replaced with talk.md content; explicit migration note in slides.md line 23 |
| (old `/slides` PPTX conversion) | `/convert --format beamer\|polylux\|touying` | Behavior moved from `slides.md` into `convert.md` dispatcher |
| `.claude/context/standards/documentation.md` | merged into `.claude/context/standards/documentation-standards.md` | Also index.json, core-index-entries.json updated |
| `state-json-schema.md` | `state-management-schema.md` | Referenced in `.claude/context/reference/README.md` and `skill-agent-mapping.md`. The file `state-management-schema.md` already exists; this is a link/reference update |
| `subagent-return-format.md` | `subagent-return.md` | Referenced in `.claude/docs/templates/README.md` |

---

## Semantic/Behavioral Changes

### Command surface

1. **`/slides` command changed meaning entirely.** It was "convert PPTX deck to LaTeX/Typst" and is now "create research talk task with forcing questions". Downstream: users who typed `/slides my-deck.pptx` must now type `/convert my-deck.pptx --format beamer`.
2. **`/talk` command is gone.** Users who relied on `/talk "description"` must now type `/slides "description"`.
3. **`/convert` dispatches to two different skills** based on source type and flags. Previously `/convert` always went to `skill-filetypes`. Now:
   - PPTX/PPT + `--format beamer|polylux|touying` -> `skill-presentation`
   - everything else -> `skill-filetypes`

### Policy / convention changes

4. **Commit messages no longer include `Co-Authored-By`** (per user memory `feedback_no_coauthored_by.md`). CLAUDE.md line 162 adds an explicit note; example blocks updated.
5. **ROAD_MAP.md renamed to ROADMAP.md** (no underscore). Affects all roadmap consumers (review, todo, researcher, planner, reviser skills/agents).
6. **Auto-creation of ROADMAP.md.** `/review`, `/todo`, and `skill-todo` now create a default ROADMAP.md (Phase 1 Priorities + Success Metrics) if missing, rather than erroring.
7. **Agent frontmatter simplification is now normative.** Only `name`, `description`, and optional `model` are supported. XML process-flow bodies and verbose YAML blocks are explicitly called out as unsupported by the Task tool.

### Architecture / templates

8. **Agent template canonical form is Stage 0-7** (Initialize Early Metadata, Parse Delegation Context, Load Context, Execute Core Work, Write Artifacts, Validate Artifacts, Write Final Metadata, Return Brief Summary) — not the old 8-stage XML workflow with `<step_X>` blocks.
9. **Command template canonical form is 4 checkpoints**: GATE IN -> DELEGATE -> GATE OUT -> COMMIT. The old `agent: orchestrator` frontmatter is no longer used; commands now use `description` / `allowed-tools` / `argument-hint` / `model`.
10. **Team skills now update TODO.md inline** using count-aware artifact-link formatting (single-link inline vs multi-link bulleted list). Was previously owned only by state-management.md.

### Agent roster

11. **`reviser-agent` is a first-class core agent** now surfaced in .claude/README.md, .claude/agents/README.md, and skill-agent-mapping.md core-skills table (previously only appeared in extended mappings).
12. **Skill-agent mapping additions**: `skill-orchestrator`, `skill-git-workflow`, `skill-fix-it` added to the direct-execution skills table in `.claude/context/reference/skill-agent-mapping.md`.

### Extension-registry cleanup

13. **`opencode_json` merged-sections key dropped** from every extension in `.claude/extensions.json`. Signals that OpenCode integration is no longer maintained alongside the Claude extension loader.
14. **Filetypes extension no longer owns `slides.md`**. The present extension now owns `slides.md` (via the talk.md->slides.md rename). Filetypes still owns `convert.md`.

### Documentation standards policy

15. **Version History sections are explicitly forbidden** in documentation (new section in documentation-standards.md with forbidden/correct examples).
16. **100-character line length cap** codified.
17. **Quality Checklist added** as a pre-commit self-check for documentation.
18. **Extension README.md is required** (new section in `creating-extensions.md`), with a section-applicability matrix distinguishing simple from complex extensions. Doc-lint script enforces this.

---

## Recommended Approach for Updating `docs/`

### Pass 1 (Must-fix, high-certainty)

1. **`docs/agent-system/commands.md` — /slides section (lines 217-227)**
   - Current text describes `/slides` as PPTX conversion to Beamer/Polylux/Touying.
   - Replace with: note that PPTX conversion moved to `/convert deck.pptx --format beamer` (cross-link to convert-documents.md). The `/slides` command is now the research-talk creation command and should be described in the Research & Grants section.
   - Update the "See" link from `.claude/commands/slides.md` to reflect that the file is now a talk-creation command.

2. **`docs/agent-system/commands.md` — /talk section (lines 312-330)**
   - Current `### /talk` heading must be renamed to `### /slides`.
   - Update example invocations: `/talk "job talk..."` -> `/slides "job talk..."`, `/talk 12` -> `/slides 12`, `/talk ~/papers/my-paper.pdf` -> `/slides ~/papers/my-paper.pdf`.
   - Update "See" link from `.claude/commands/talk.md` to `.claude/commands/slides.md`.
   - Consider adding a "Previously named `/talk`" migration note.

3. **`docs/workflows/convert-documents.md` — decision table (line 12) and /slides section (lines 35-42)**
   - Decision-table row "Turn a PowerPoint deck into Beamer/Polylux/Touying source | `/slides`" -> change to `/convert --format beamer` (or similar).
   - Rename `## /slides — presentations to source-based slides` section to `## /convert --format — presentations to source-based slides` (or fold into the `## /convert` section above).
   - Update the example `/slides deck.pptx` to `/convert deck.pptx --format beamer` (or other flags).
   - Clarify that `/slides` is now a separate research-talk creation command and link to wherever that gets documented.

4. **`docs/workflows/agent-lifecycle.md` line 87**
   - Change "annotates `ROAD_MAP.md`" to "annotates `ROADMAP.md`".

5. **`docs/agent-system/architecture.md` line 58**
   - Remove the `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>` line from the example commit block. Example should now be two lines (subject + `Session: ...` trailer).

### Pass 2 (Recommended but optional)

6. **Commands.md should mention reviser-agent** if it lists agents at all (spot-check whether the current file already has an agent list — if yes, add it).
7. **Commands.md /convert section should mention the new `--format` and `--theme` flags** and the PPTX-to-slide dispatch behavior, now that `/slides` no longer does it.
8. **`docs/agent-system/README.md`** — review for any stale `/talk`, `/slides`, or `ROAD_MAP` references.
9. **`docs/workflows/README.md`** — verify the workflow index (convert-documents.md) does not still describe the old /slides command in its blurb.

### Pass 3 (Lower-priority)

10. **Mention `/convert --format` in the `docs/` landing/README** if there is a command summary listing the conversion commands.
11. **Consider adding a brief "Research talks" workflow** under `docs/workflows/` describing the `/slides` research-talk flow, since it is now structurally similar to `/grant` and deserves equal footing.

### Anti-pattern: do NOT update

- **Do not edit `.claude/context/index.json.backup`** — it is a backup file and its diff is mostly key reordering.
- **Do not rewrite agent frontmatter examples in `docs/`** unless they currently exist; a quick grep shows `docs/` does not embed agent YAML frontmatter, so the frontmatter standard change is .claude/-internal.
- **Do not touch `specs/ROADMAP.md` itself** — that is a state file, not a doc.

---

## Evidence / Examples

### Stale references in `docs/` (found via Grep)

| Location | Current text | Needed change |
|----------|--------------|---------------|
| `docs/workflows/convert-documents.md:12` | `| Turn a PowerPoint deck into Beamer/Polylux/Touying source | `/slides` |` | Change `/slides` to `/convert --format beamer` |
| `docs/workflows/convert-documents.md:35` | `## /slides — presentations to source-based slides` | Rename section or fold into /convert |
| `docs/workflows/convert-documents.md:38` | `/slides deck.pptx            # PowerPoint to Beamer/Polylux/Touying slides` | Change to `/convert deck.pptx --format beamer` |
| `docs/workflows/agent-lifecycle.md:87` | `annotates ``ROAD_MAP.md``` | `annotates ``ROADMAP.md``` |
| `docs/agent-system/architecture.md:58` | `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>` | Delete line (and blank line above it if it creates a double blank) |
| `docs/agent-system/commands.md:82` | "Archive completed/abandoned tasks; update CHANGE_LOG and ROAD_MAP." | Change to `ROADMAP` |
| `docs/agent-system/commands.md:217-227` | `### /slides` section describing PPTX to Beamer/Polylux/Touying | Replace with migration note; describe `/convert --format` instead |
| `docs/agent-system/commands.md:312-330` | `### /talk` section with `/talk ...` examples and `.claude/commands/talk.md` link | Rename to `/slides`, update examples, fix link |

### Commits referenced

No pre-committed commits on master need documentation reflection (they are task 7/8/9 completion commits that pre-date these working-tree changes). All the changes catalogued here are in the working tree.

### File evidence for new content

- New script lives at `.claude/scripts/check-extension-docs.sh` (untracked)
- Migration note for `/slides`: `.claude/commands/slides.md:23` — "This command was previously named `/talk`. For PPTX slide file conversion (not research talk creation), use `/convert --format beamer|polylux|touying` in the `filetypes` extension."
- Full diff saved at: `/tmp/full-claude-diff.txt` (17,879 lines) — cross-reference line numbers in Grep output above map directly to this file.

---

## Confidence Level

**High** for:
- /talk -> /slides rename and the split of /slides conversion into /convert --format
- ROAD_MAP -> ROADMAP rename
- Exact docs/ locations needing updates (verified via targeted Grep)
- Co-Authored-By removal
- reviser-agent addition
- documentation.md -> documentation-standards.md consolidation
- Extensions.json cleanup
- Agent frontmatter simplification

**Medium** for:
- Whether any `docs/` files need agent-frontmatter updates (did not find any current YAML blocks in docs/ that would break, but a deeper grep on specific patterns might reveal more)
- Whether `docs/agent-system/README.md` and `docs/workflows/README.md` have stale references beyond the ones explicitly found (only spot-checked via a single Grep pass)
- Exact format the implementer should use for the /slides renaming in commands.md (fold old section into new, or keep separate subsections)

**Low** for:
- Context/index.json semantic changes — the diff is 99% key-ordering shuffle, but I only spot-checked for `+path` entries vs the `standards/documentation.md` removal. There may be other subtle entries added/removed hidden in the reshuffle that I missed.
- Whether the three `.claude/scripts/*.sh` untracked files (check-extension-docs, setup-lean-mcp, verify-lean-mcp) should be mentioned in `docs/` at all — none are currently referenced and they may be internal tooling not intended for user-facing docs.
