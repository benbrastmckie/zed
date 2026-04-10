# Implementation Plan: Expand commands.md with examples and explanations

- **Task**: 12 - Expand docs/agent-system/commands.md to include brief examples and explanations for each command
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/012_expand_commands_docs_examples/reports/01_team-research.md
- **Artifacts**: plans/01_expand-commands-docs.md
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
- **Type**: markdown

## Overview

The current `docs/agent-system/commands.md` is a terse quick-reference catalog with 25 commands across 5 groups. Each entry has a one-sentence description, one example, and a flags line. The task is to expand each entry with a 2-sentence explanation (what it does + when to use it) and up to 2 examples (primary invocation + key non-obvious flag), regroup commands for better discoverability, add missing flags/modes, and add an orientation paragraph. The definition of done is: every command entry follows a standardized template, groups are reorganized per research recommendations, and missing documentation gaps are filled.

## Goals & Non-Goals

**Goals**:
- Standardize every command entry to a consistent template: 2-sentence explanation, 2 examples max, flags line, link line
- Regroup commands into 6 sections (Lifecycle, Review & Recovery, System & Housekeeping, Memory, Documents, Research & Grants)
- Add orientation paragraph at top linking to related docs
- Document missing flags: `--sheet` (table), `--fix-it` (grant), file-path input (budget)
- Add forcing-question pattern note to Research & Grants section header
- Fix `/tag` link acknowledgment (no command file exists)
- Add key behavioral notes: `/implement` auto-resume, `/revise` dual mode, multi-task syntax

**Non-Goals**:
- Adding mode tables (budget modes, funds modes, talk modes) — these belong in the user guide
- Creating a "Common Workflows" section — belongs in agent-lifecycle.md
- Expanding entries beyond the 2-sentence + 2-example template
- Modifying any files other than `docs/agent-system/commands.md`

## Risks & Mitigations

- **Risk**: Entries become too verbose, losing the catalog character. **Mitigation**: Strict adherence to the 2-sentence + 2-example template; trim any entry exceeding ~60 words of prose.
- **Risk**: Regrouping breaks existing links from other docs. **Mitigation**: The file has no internal anchors referenced externally (section headers are plain text). Verify with grep after completion.
- **Risk**: Missing flags documented incorrectly. **Mitigation**: Research report cross-referenced against command source files; only document flags confirmed in sources.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Restructure file skeleton and add orientation [COMPLETED]

**Goal:** Replace the current intro paragraph and group headings with the new structure, without changing individual command entries yet.

**Tasks:**
- [ ] Replace the opening paragraph with an orientation paragraph that links to agent-lifecycle.md (workflow tutorial), user-guide.md (full reference), and architecture.md (system design)
- [ ] Rename section headings to the 6 new groups: Lifecycle, Review & Recovery, System & Housekeeping, Memory, Documents, Research & Grants
- [ ] Move `/review` from Lifecycle to Review & Recovery
- [ ] Move `/spawn`, `/errors`, `/fix-it` from Maintenance to Review & Recovery
- [ ] Move `/refresh`, `/meta`, `/tag`, `/merge` from Maintenance to System & Housekeeping
- [ ] Move `/slides` from Documents to Research & Grants
- [ ] Update the Lifecycle intro sentence to reference 6 commands (not 7)
- [ ] Add a brief intro sentence to each new group (1 line each)
- [ ] Add a forcing-question pattern note at the top of the Research & Grants section (2-3 sentences explaining that `/grant`, `/budget`, `/timeline`, `/funds`, and `/slides` begin with interactive forcing questions to scope the task)

**Timing:** 20 minutes
**Depends on:** none

### Phase 2: Expand Lifecycle and Review & Recovery entries [COMPLETED]

**Goal:** Apply the standardized entry template to the 10 commands in Lifecycle (6) and Review & Recovery (4).

**Tasks:**
- [ ] `/task`: Add explanation about task creation and management modes. Keep existing example; add second example showing `--review N`
- [ ] `/research`: Add explanation about research reports and task-type routing. Keep existing example; add example showing `--remember` flag
- [ ] `/plan`: Add explanation about phased plans from research. Keep existing example; add example showing multi-task syntax
- [ ] `/implement`: Add explanation noting auto-resume behavior (detects first incomplete phase). Keep existing example; add example showing `--force` flag
- [ ] `/revise`: Add explanation about dual mode (plan revision vs. description update). Keep existing example; add example with a task that has no plan
- [ ] `/todo`: Add explanation about archival, CHANGE_LOG updates, and vault operations. Trim to 2 examples (basic + `--dry-run`)
- [ ] `/review`: Add explanation distinguishing from `/task --review N`. Keep both existing examples
- [ ] `/spawn`: Add explanation about blocker analysis and dependency graph output. Keep existing example; note that spawned tasks start at [RESEARCHED]
- [ ] `/errors`: Add explanation about automatic mode (intentionally non-interactive). Keep existing examples
- [ ] `/fix-it`: Add explanation about interactive selection and topic grouping. Keep existing example; add example showing multiple paths

**Timing:** 30 minutes
**Depends on:** 1

### Phase 3: Expand System & Housekeeping, Memory, and Documents entries [COMPLETED]

**Goal:** Apply the standardized entry template to the 9 commands in System & Housekeeping (4), Memory (1), and Documents (4).

**Tasks:**
- [ ] `/refresh`: Add explanation about safety margin (files < 1 hour old are protected). Trim to 2 examples
- [ ] `/meta`: Add explanation about always creating tasks, never implementing directly. Keep existing examples
- [ ] `/tag`: Add explanation about user-only restriction. Keep existing examples; fix link text to acknowledge no command file exists
- [ ] `/merge`: Add explanation about `--fill` auto-population and platform detection (GitHub/GitLab). Keep existing examples
- [ ] `/learn`: Add explanation about three-operation model (UPDATE/EXTEND/CREATE). Trim from 4 examples to 2 (inline text + `--task N`)
- [ ] `/convert`: Add explanation about format detection and MCP tool requirement. Trim to 2 examples
- [ ] `/table`: Add explanation about spreadsheet conversion. Add `--sheet` flag to flags line. Keep existing examples
- [ ] `/scrape`: Add explanation about annotation extraction. Keep existing examples
- [ ] `/edit`: Add explanation about tracked changes and XLSX limitation note. Trim to 2 examples (single file + `--new`)

**Timing:** 25 minutes
**Depends on:** 2

### Phase 4: Expand Research & Grants entries and final review [COMPLETED]

**Goal:** Apply the standardized entry template to the 6 commands in Research & Grants, then do a final consistency pass over the entire file.

**Tasks:**
- [ ] `/grant`: Add explanation about multi-mode workflow (create, draft, budget, revise). Add `--fix-it` to flags or add second example. Trim to 2 examples
- [ ] `/budget`: Add explanation about forcing questions and workflow stopping point (stops at [NOT STARTED], needs `/research N` next). Add file-path input mode to examples or flags. Trim to 2 examples
- [ ] `/timeline`: Add explanation about Typst output format (needs `typst compile` for PDF). Keep existing examples
- [ ] `/funds`: Add explanation about analysis modes (mention "four analysis modes" with link to user guide). Keep existing examples
- [ ] `/slides`: Add explanation about three input modes (description, task number, file path) and design confirmation. Trim to 2 examples. Note that it is now in Research & Grants (moved from Documents)
- [ ] Final consistency pass: verify every entry follows the template (2-sentence explanation, 2 examples max, flags line, link line)
- [ ] Verify all links are valid (spot-check 3-4 link targets)
- [ ] Update the "See also" section at bottom if any references changed

**Timing:** 25 minutes
**Depends on:** 3

## Testing & Validation

- [ ] Read through the final file end-to-end and confirm every entry matches the standardized template
- [ ] Confirm exactly 6 groups with correct command counts: Lifecycle (6), Review & Recovery (4), System & Housekeeping (4), Memory (1), Documents (4), Research & Grants (6) = 25 total
- [ ] Grep the codebase for links to `commands.md` section anchors to verify no external references are broken
- [ ] Verify no entry exceeds ~60 words of prose (excluding code blocks and flags line)
- [ ] Confirm `/slides` appears in Research & Grants, not Documents
- [ ] Confirm `/review` appears in Review & Recovery, not Lifecycle

## Artifacts & Outputs

- `docs/agent-system/commands.md` — expanded and reorganized command catalog (primary output)
- `specs/012_expand_commands_docs_examples/plans/01_expand-commands-docs.md` — this plan
- `specs/012_expand_commands_docs_examples/summaries/01_execution-summary.md` — post-implementation summary

## Rollback/Contingency

The only file modified is `docs/agent-system/commands.md`. If changes must be reverted:
```bash
git checkout HEAD -- docs/agent-system/commands.md
```
Since this is a single markdown file with no downstream dependencies, rollback is trivial.
