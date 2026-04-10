# Implementation Plan: Integrate config-report.md (scope collapsed)

- **Task**: 4 - integrate_config_report_into_docs
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/004_integrate_config_report_into_docs/reports/01_integrate-config-report.md
- **Artifacts**: plans/01_integrate-config-report.md
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
- **Type**: markdown
- **Lean Intent**: true

## Overview

The research report identified config-report.md as a stale, internally inconsistent setup snapshot whose unique content fell into three buckets: external Zed doc URLs, runtime data paths, and a Neovim-vs-Zed comparison. All three recommended destinations were files under `docs/`. Per explicit user guidance, this project is for a macOS-only Zed user and no work under `zed/docs/` or `docs/` is in scope. After filtering out all docs/-targeting recommendations, the only remaining actionable item is **removal of the stale config-report.md file** and a verification that nothing in `.claude/` or the root `README.md` references it.

### Research Integration

Key findings from reports/01_integrate-config-report.md that survive the docs/ filter:

- config-report.md is dated 2026-04-09 and internally inconsistent (claims macOS while using a NixOS-style `/run/current-system/sw/bin/zeditor` path).
- Its "Current State" table is stale and contradicts the live `settings.json` (claims settings.json missing, claims `vim_mode: true`, names the block `assistant` instead of `agent`, claims Claude Code extension not installed).
- Its setup steps are superseded by the actual current configuration already in place.
- No file in `.claude/` or root `README.md` references config-report.md (per the research report's recommendation #5).

All "copy into docs/" recommendations (HIGH-priority items 1-3 in the report) are explicitly out of scope per user guidance and are dropped.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROAD_MAP.md consulted.

## Goals & Non-Goals

**Goals**:
- Remove the stale `config-report.md` file from the repository root.
- Verify no dangling references to `config-report.md` remain in `.claude/` or root-level markdown files.

**Non-Goals**:
- Updating `zed/docs/` or `docs/` in any way (explicit user exclusion; user is macOS-only Zed user and does not need docs/ touched).
- Migrating the external Zed documentation URL table (would target docs/README.md -- out of scope).
- Migrating the runtime data paths table (would target docs/settings.md -- out of scope).
- Migrating the Neovim-vs-Zed comparison table (would target docs/settings.md -- out of scope).
- Modifying `settings.json`, `keymap.json`, or any functional Zed configuration.
- Modifying the root `README.md` unless a stale reference to config-report.md is found.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deleting content a user might still want to reference | L | L | The research report already captured the full section-by-section analysis; report remains in `specs/004_*/reports/` as the historical record. |
| A hidden reference to config-report.md exists somewhere | L | L | Phase 1 grep across `.claude/` and root-level `*.md` files before deletion. |
| User later wants the docs/ integration after all | L | L | This plan is reversible: reports/01 preserves the exact content and the precise destination recommendations. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Verify no references to config-report.md [NOT STARTED]

**Goal**: Confirm that removing `config-report.md` will not create broken links anywhere in `.claude/` or root-level markdown.

**Tasks**:
- [ ] Grep for `config-report` in root-level `*.md` files (README.md, CLAUDE.md)
- [ ] Grep for `config-report` across `.claude/` (excluding `.claude/context` auto-generated artifacts if any)
- [ ] Grep for `config-report` across `specs/` outside the task 4 directory (just to be safe)
- [ ] If any references are found, record them and stop for user review before deletion

**Timing**: 10 minutes

**Depends on**: none

**Files to inspect** (read-only):
- `/home/benjamin/.config/zed/README.md`
- `/home/benjamin/.config/zed/CLAUDE.md` (if present)
- `/home/benjamin/.config/zed/.claude/` (tree)
- `/home/benjamin/.config/zed/specs/` (excluding `specs/004_integrate_config_report_into_docs/`)

**Verification**:
- Grep command returns no hits outside `specs/004_integrate_config_report_into_docs/` (the task's own reports/plans are expected to mention it).
- Any hits found are logged and escalated to the user; phase 2 does not proceed.

---

### Phase 2: Delete config-report.md [NOT STARTED]

**Goal**: Remove the stale file from the repository root.

**Tasks**:
- [ ] Delete `/home/benjamin/.config/zed/config-report.md`
- [ ] Confirm the file no longer exists
- [ ] Leave a note in the implementation summary explaining: scope was collapsed because all docs/ integration was excluded by user guidance; only the deletion remained.

**Timing**: 5 minutes

**Depends on**: 1

**Files to modify**:
- `/home/benjamin/.config/zed/config-report.md` -- delete

**Verification**:
- `ls config-report.md` returns "No such file or directory"
- `git status` shows a single deletion and no other unexpected changes

---

## Testing & Validation

- [ ] Grep for `config-report` across `.claude/`, root `*.md`, and `specs/` (excluding task 4 dir) returns no hits
- [ ] `config-report.md` no longer exists at the repo root
- [ ] `git status` shows only the expected deletion
- [ ] No changes to `docs/`, `settings.json`, `keymap.json`, or any `.claude/` content

## Artifacts & Outputs

- Deletion of `/home/benjamin/.config/zed/config-report.md`
- Implementation summary at `specs/004_integrate_config_report_into_docs/summaries/01_integrate-config-report-summary.md` (written by /implement) noting the collapsed scope.

## Rollback/Contingency

If deletion causes issues or the user changes their mind:

1. `git restore config-report.md` (or `git checkout HEAD -- config-report.md` before commit) restores the file.
2. The original content is preserved in git history permanently.
3. The research report (`reports/01_integrate-config-report.md`) retains the full section-by-section analysis and integration recommendations should the user later decide to integrate into docs/ after all.

**Alternative**: If the user prefers to keep config-report.md in place as a historical artifact, this task can be marked `[ABANDONED]` with the rationale that all three HIGH-priority integration targets were excluded by scope and no actionable non-docs/ work remains.
