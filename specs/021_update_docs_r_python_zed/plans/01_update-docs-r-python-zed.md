---
task_number: 21
task_name: update_docs_r_python_zed
date: 2026-04-10
status: [NOT STARTED]
session_id: sess_planner_21
estimated_hours: 4.5
phase_count: 5
---

# Implementation Plan: Task #21 — Update Docs for R/Python in Zed (macOS)

- **Task**: 21 - update_docs_r_python_zed
- **Status**: [NOT STARTED]
- **Effort**: 4.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/021_update_docs_r_python_zed/reports/01_update-docs-r-python-zed.md
- **Artifacts**: plans/01_update-docs-r-python-zed.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Reframe the user-facing documentation and top-level Zed configuration of this repository from its current "Zed + Claude Code for Epidemiology on macOS" framing to **"Zed IDE configuration for working in R and Python with Claude Code, for macOS users"**. The research report at `specs/021_update_docs_r_python_zed/reports/01_update-docs-r-python-zed.md` identified 6 documentation files that mis-frame the repo's core purpose, plus orphaned `docs/general/R.md` and `docs/general/python.md` language guides that are never referenced from top-level docs.

**User focus override**: Although the repo currently runs on NixOS Linux, it is intended to be consumed by **macOS users only**. All documentation must target macOS exclusively (Homebrew, Cmd shortcuts, macOS paths), and `settings.json` must be audited so paths, commands, and tooling match a macOS environment — in particular the `claude-acp` agent server block currently points at `/home/benjamin/.nix-profile/bin/...`, which must be replaced with macOS-appropriate paths (Homebrew or `~/.npm-global` / `/opt/homebrew`).

### Research Integration

Research identified the following concrete files needing updates (report sections 1-7):

1. `README.md` — retitle, reframe intro, add Languages section, cross-link R.md/python.md
2. `docs/README.md` — reframe intro, surface R.md/python.md in General section
3. `docs/general/README.md` — add R.md/python.md to navigation and quick-start reading order
4. `docs/general/R.md` — already macOS/Homebrew-framed; keep framing, add back-links
5. `docs/general/python.md` — already macOS/Homebrew-framed; keep framing, add back-links
6. `docs/workflows/README.md` — reframe intro for R/Python, add optional Languages cross-link
7. `docs/agent-system/README.md` — minor extensions-list clarification (low priority)

Plus a new concern added by the user focus prompt:

8. `settings.json` — macOS path audit (`claude-acp` agent server block)

**Key deviation from research recommendations**: The research report's Open Question #1 recommended dual-platform (Linux + macOS) framing. The user has **overridden** this: docs are macOS-only. NixOS/Linux-specific guidance that the research suggested adding must NOT be added; existing Homebrew framing in `R.md` and `python.md` is correct as-is and does not need the NixOS tip the report proposed.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No explicit ROADMAP.md entry consulted for this task; the task is a standalone documentation reframing driven by the research report and user focus prompt.

## Goals & Non-Goals

**Goals**:

- Reframe top-level README and docs index to present this repo as a macOS Zed IDE configuration for R and Python development with Claude Code.
- Surface the existing `docs/general/R.md` and `docs/general/python.md` guides via cross-links from README.md, `docs/README.md`, and `docs/general/README.md`.
- Ensure `settings.json` (and any other top-level Zed config files) contain macOS-appropriate paths and commands — no NixOS-specific paths in committed settings.
- Demote epidemiology/grants framing from the headline to "also available — domain extensions".
- Keep `.claude/` and `specs/` untouched.

**Non-Goals**:

- Rewriting individual workflow narratives under `docs/workflows/` (epidemiology-analysis.md, grant-development.md, etc.).
- Touching agent-system internals (architecture.md, commands.md, context-and-memory.md, zed-agent-panel.md).
- Touching `.claude/**` or `specs/**`.
- Full rewrite of `docs/general/installation.md`, `keybindings.md`, `settings.md` (already macOS-framed).
- Introducing dual-platform or Linux/NixOS notes anywhere in user-facing docs.
- Modifying `keymap.json`, `tasks.json`, or themes.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| settings.json path changes break the developer's current NixOS working environment | H | H | Replace NixOS paths with macOS paths as the committed default, but document (in commit message or a comment) that the developer can keep a local untracked override. Verify Zed still parses the file after edit. |
| Broken relative cross-links after reorganization | M | M | Use repo-root-relative paths in README.md; use `./` or `../` relative paths inside docs/; manually spot-check every new link during Phase 5. |
| Over-demotion of epi/grant commands frustrates existing workflow users | M | L | Keep epi/grant/budget/funds/timeline/slides in the README command table under an "Also available — domain extensions" sub-heading rather than removing them. |
| Inconsistent capitalization ("Python" vs "python", "R" vs "r") across docs | L | M | Standardize on "Python" and "R" as proper nouns in prose; keep lowercase only for code/filenames. |
| Title choice bikeshed delays work | L | M | Commit to "Zed IDE Configuration for R and Python with Claude Code" in Phase 1; no further debate. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 4 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 5 | 1, 2, 3, 4 |

Phase 1 (README.md) and Phase 4 (settings.json audit) are independent and may run in parallel. Phase 2 (docs index) depends on Phase 1 because it links back to the reframed README. Phase 3 (individual docs files) depends on Phase 2 so cross-links from docs/README.md are in place when the language guides add back-links. Phase 5 is the final verification and depends on everything.

---

### Phase 1: Reframe README.md and Top-Level Framing [NOT STARTED]

**Goal**: Rewrite `/home/benjamin/.config/zed/README.md` so it presents this repo as a macOS Zed IDE configuration for R and Python development with Claude Code. Add a Languages section with cross-links to the existing language guides.

**Tasks**:

- [ ] Retitle to "Zed IDE Configuration for R and Python with Claude Code".
- [ ] Rewrite the intro paragraph: macOS Zed config optimized for R and Python with Claude Code as the integrated AI assistant; mention epidemiology, grant, memory, and Office extensions as secondary offerings.
- [ ] Keep the platform line as "Platform: macOS 11 (Big Sur) or newer" (no dual-platform wording).
- [ ] Keep `brew install --cask zed` and Cmd+Space quick-start instructions; verify they are consistent with the new intro.
- [ ] Add a new "Languages" section before (or replacing) the "Research Commands" section with two sub-sections:
  - Python: pyright + ruff + uv, cross-link to `docs/general/python.md`.
  - R: r-language-server + lintr/styler, cross-link to `docs/general/R.md`.
- [ ] Restructure the command table: lead with `/research`, `/plan`, `/implement` as primary commands for R/Python development; group `/epi`, `/grant`, `/budget`, `/funds`, `/timeline`, `/slides` under an "Also available — domain extensions" sub-heading.
- [ ] Update the "AI integration" section to name Claude Code's role for writing, testing, and refactoring R and Python code — not only epi/grant workflows.
- [ ] Keep the Platform Notes section macOS-only; do not add Linux notes.
- [ ] Leave directory layout section unchanged.

**Timing**: 1.25 hours

**Depends on**: none

**Files to modify**:

- `/home/benjamin/.config/zed/README.md` — retitle, rewrite intro, add Languages section, restructure commands, update AI integration

**Verification**:

- Title line reads "Zed IDE Configuration for R and Python with Claude Code".
- Platform line still says macOS.
- "Languages" section contains working relative links `docs/general/python.md` and `docs/general/R.md`.
- Command table has `/research`, `/plan`, `/implement` as first rows.
- No NixOS or Linux mentions.

---

### Phase 2: Reframe docs/README.md Index [NOT STARTED]

**Goal**: Update `/home/benjamin/.config/zed/docs/README.md` so it presents the documentation set as "macOS Zed configuration for R and Python with Claude Code", and surface the existing R.md and python.md guides in the General section.

**Tasks**:

- [ ] Rewrite the intro paragraph: "documentation for this Zed configuration on macOS, focused on working in R and Python with Claude Code".
- [ ] Keep the "on macOS" qualifier (per focus override).
- [ ] Update the General section description to mention `R.md` and `python.md` alongside installation/keybindings/settings.
- [ ] Add an inline "For R/Python development" callout near the top linking directly to `general/R.md` and `general/python.md`.
- [ ] Leave Agent System and Workflows sections structurally unchanged (only light intro tweaks as needed).

**Timing**: 0.5 hours

**Depends on**: 1

**Files to modify**:

- `/home/benjamin/.config/zed/docs/README.md` — intro rewrite, General section update, R/Python callout

**Verification**:

- Intro paragraph names R and Python as the primary focus.
- "on macOS" phrase retained.
- General section lists `general/R.md` and `general/python.md`.
- Direct links to `general/R.md` and `general/python.md` resolve.

---

### Phase 3: Update Individual docs/*.md Files [NOT STARTED]

**Goal**: Update the three in-scope individual doc files under `docs/general/` and `docs/workflows/` and the `docs/agent-system/README.md` minor clarification.

**Tasks**:

- [ ] `docs/general/README.md`:
  - [ ] Intro: drop any NixOS/Linux wording; reframe around R/Python focus for macOS users.
  - [ ] Navigation list: add entries for `R.md` and `python.md` alongside `installation.md`, `keybindings.md`, `settings.md`.
  - [ ] Quick start reading order: add step "Set up Python ([python.md](python.md))" and "Set up R ([R.md](R.md))".
- [ ] `docs/general/R.md`:
  - [ ] Keep existing macOS/Homebrew framing — do NOT add NixOS tip from research report.
  - [ ] Keep Cmd+S as the save shortcut — do NOT add Linux Ctrl+S note.
  - [ ] Add a "See also" entry linking back to `../../README.md` and `../README.md`.
  - [ ] Confirm cross-link to `python.md` is present and correct.
- [ ] `docs/general/python.md`:
  - [ ] Keep existing macOS/Homebrew framing — do NOT add NixOS tip from research report.
  - [ ] Keep Cmd+S as the save shortcut — do NOT add Linux Ctrl+S note.
  - [ ] Add a "See also" entry linking back to `../../README.md` and `../README.md`.
  - [ ] Confirm cross-link to `R.md` is present.
- [ ] `docs/workflows/README.md`:
  - [ ] Intro: keep "on macOS"; reframe around "working in R and Python with Claude Code".
  - [ ] Add a short "Languages" section linking to `../general/R.md` and `../general/python.md`, noting the generic task lifecycle (`agent-lifecycle.md`) is the primary workflow for R/Python development.
  - [ ] Do NOT rewrite epidemiology/grant/Office narratives.
- [ ] `docs/agent-system/README.md` (minor):
  - [ ] Clarify the extensions list so both Python (general Python development) and R (via Epidemiology or Languages) are visible.
  - [ ] No structural changes.

**Timing**: 1.25 hours

**Depends on**: 2

**Files to modify**:

- `/home/benjamin/.config/zed/docs/general/README.md`
- `/home/benjamin/.config/zed/docs/general/R.md`
- `/home/benjamin/.config/zed/docs/general/python.md`
- `/home/benjamin/.config/zed/docs/workflows/README.md`
- `/home/benjamin/.config/zed/docs/agent-system/README.md`

**Verification**:

- `docs/general/README.md` navigation lists R.md and python.md.
- Neither R.md nor python.md contains the word "NixOS" or "Linux" in user-facing prose.
- R.md and python.md both have "See also" back-links to README files.
- `docs/workflows/README.md` has a Languages sub-section with valid relative links.

---

### Phase 4: macOS Audit of settings.json [NOT STARTED]

**Goal**: Audit `/home/benjamin/.config/zed/settings.json` and adjust paths, commands, and tooling so the committed file matches a clean macOS environment. No NixOS-specific paths in the committed version.

**Tasks**:

- [ ] Replace the header comment `// Platform: NixOS Linux (binary: zeditor)` with `// Platform: macOS 11 (Big Sur) or newer`.
- [ ] In the `agent_servers.claude-acp` block:
  - [ ] Replace `command: "/home/benjamin/.nix-profile/bin/npx"` with a macOS-appropriate path. Prefer `"npx"` (letting PATH resolve it) as the most portable macOS default; document Homebrew path `/opt/homebrew/bin/npx` (Apple Silicon) or `/usr/local/bin/npx` (Intel) as alternatives in a comment.
  - [ ] Replace `env.CLAUDE_CODE_EXECUTABLE: "/home/benjamin/.nix-profile/bin/claude"` with `"claude"` (PATH-resolved) or document Homebrew-equivalent as comment.
  - [ ] Replace `env.HOME: "/home/benjamin"` with a macOS convention. Preferred: remove the hardcoded HOME entry entirely and let Zed inherit from the environment; alternatively document `/Users/${USER}` pattern.
- [ ] Verify no other hardcoded `/home/benjamin` or `/nix/` or `.nix-profile` paths remain anywhere in `settings.json`.
- [ ] Confirm `file_scan_exclusions` does not contain Nix-specific entries like `**/result` that are irrelevant on macOS. (Decision: keep `**/result` as it is harmless on macOS and preserves parity; no change needed.)
- [ ] Verify the file is valid JSONC (Zed parses JSONC with comments) after edits.
- [ ] Do NOT touch `keymap.json` or `tasks.json` (out of scope per task description).

**Timing**: 0.75 hours

**Depends on**: none

**Files to modify**:

- `/home/benjamin/.config/zed/settings.json` — header comment, `agent_servers.claude-acp` block paths and env

**Verification**:

- Grep for `nix-profile`, `/home/benjamin`, `NixOS` in `settings.json` returns zero matches.
- Header comment reads `// Platform: macOS 11 (Big Sur) or newer`.
- `claude-acp` block uses bare command names or macOS Homebrew paths.
- JSONC still parses (spot-check via `python3 -c 'import json; json.load(open("settings.json"))'` after stripping comments, or visual inspection).

---

### Phase 5: Cross-Link Verification and Consistency Pass [NOT STARTED]

**Goal**: Verify every new and updated cross-link resolves correctly; ensure macOS framing is consistent across all edited files; confirm no NixOS/Linux contamination leaked into user-facing docs.

**Tasks**:

- [ ] Enumerate all new/modified markdown links from Phases 1-3 and verify each target file exists (manual check of each link).
- [ ] Grep the edited files for `NixOS`, `nix-profile`, `Linux`, `Ctrl\+` — should return zero matches in user-facing docs (`README.md`, `docs/README.md`, `docs/general/*.md`, `docs/workflows/README.md`, `docs/agent-system/README.md`).
- [ ] Grep the edited files for `macOS`, `Homebrew`, `Cmd\+` — should return multiple matches confirming macOS framing is consistent.
- [ ] Spot-check that `.claude/**` and `specs/**` were not touched (`git status` shows only the 6 doc files + `settings.json`).
- [ ] Verify titles/headings are consistent: README title matches the intro paragraph framing in docs/README.md.
- [ ] Confirm demoted epi/grant commands still appear in the README under "Also available — domain extensions".

**Timing**: 0.75 hours

**Depends on**: 1, 2, 3, 4

**Files to modify**: none (verification only)

**Verification**:

- Zero matches for `NixOS|nix-profile|Linux` in user-facing docs.
- Multiple matches for `macOS|Homebrew|Cmd` confirming consistent framing.
- All cross-links resolve to existing files.
- `git status` shows exactly these modified paths: `README.md`, `settings.json`, `docs/README.md`, `docs/general/README.md`, `docs/general/R.md`, `docs/general/python.md`, `docs/workflows/README.md`, `docs/agent-system/README.md`.
- No files under `.claude/` or `specs/` modified.

---

## Testing & Validation

- [ ] All 7 edited documentation/config files render/parse correctly.
- [ ] README.md opens and displays the new title, intro, Languages section, and restructured command table.
- [ ] `docs/README.md` surfaces R.md and python.md in the General section.
- [ ] `docs/general/R.md` and `docs/general/python.md` both have back-links to the README files.
- [ ] `settings.json` contains no `/home/benjamin/.nix-profile/` or `NixOS` references and is valid JSONC.
- [ ] Zed still starts and loads the config correctly on the developer's machine (test by reloading Zed after the settings.json change, or confirm no syntax errors via comment-stripped JSON parse).
- [ ] Cross-links resolve: clicking through from README to `docs/general/python.md` works; back-links from the language guides work.
- [ ] Epidemiology/grant workflow narratives in `docs/workflows/*.md` are untouched (only `docs/workflows/README.md` changes).
- [ ] `.claude/**` and `specs/**` untouched.

## Artifacts & Outputs

- Modified: `/home/benjamin/.config/zed/README.md`
- Modified: `/home/benjamin/.config/zed/settings.json`
- Modified: `/home/benjamin/.config/zed/docs/README.md`
- Modified: `/home/benjamin/.config/zed/docs/general/README.md`
- Modified: `/home/benjamin/.config/zed/docs/general/R.md`
- Modified: `/home/benjamin/.config/zed/docs/general/python.md`
- Modified: `/home/benjamin/.config/zed/docs/workflows/README.md`
- Modified: `/home/benjamin/.config/zed/docs/agent-system/README.md`
- Implementation summary: `specs/021_update_docs_r_python_zed/summaries/01_update-docs-r-python-zed-summary.md`

## Rollback/Contingency

- All edits are localized to 7 files in the repository root and `docs/`. `git checkout -- <file>` per file reverts any individual phase.
- If the `settings.json` edit breaks the developer's current NixOS environment, they can maintain an untracked local override or temporarily revert just the `agent_servers.claude-acp` block via `git checkout -p settings.json`. The task commit should not block the developer's ability to keep using NixOS paths locally.
- If cross-links are discovered to be broken after commit, a follow-up phase can add a verification script or manual patch.
- If the title wording is objected to, `git revert` the Phase 1 commit and re-run only Phase 1 with an alternate title.
