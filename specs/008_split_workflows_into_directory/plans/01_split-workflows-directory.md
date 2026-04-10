# Implementation Plan: Split office-workflows.md into workflows/ directory

- **Task**: 8 - Split office-workflows.md into workflows/ directory
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/008_split_workflows_into_directory/reports/01_team-research.md
- **Artifacts**: plans/01_split-workflows-directory.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/context/formats/status-markers.md
  - .claude/context/formats/artifact-management.md
  - .claude/rules/state-management.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Convert the flat `docs/office-workflows.md` (210 lines) into a `docs/workflows/` directory of five goal-clustered workflow files plus a README.md table of contents, and move `docs/agent-system/workflow.md` (123 lines) into the new directory as `agent-lifecycle.md`. The split follows the directory-extraction pattern established by task 6 (agent-system/), uses command-cluster granularity rather than per-command splits, and consolidates cross-cutting content (OneDrive tips, macOS permissions, Agent Panel invocation) into a dedicated `tips-and-troubleshooting.md` file. All 16 inbound links across 9 files must be repaired before the source files are deleted.

### Research Integration

The team research resolved five major decisions. File count: 5 workflow files + README (proportional to task 6's 6-file split). Naming of moved file: `agent-lifecycle.md` (disambiguates "workflow" in the enclosing directory name, addresses semantic-divergence concern). Office file naming: verb-prefixed kebab-case (`edit-word-documents.md`, `convert-documents.md`). Cross-cutting content: dedicated `tips-and-troubleshooting.md` to avoid triple-duplication of macOS permissions and Agent Panel steps. Relationship to `docs/agent-system/commands.md`: workflows/ files are macOS-focused usage narratives that link back to commands.md for flag reference, not duplicate it. The research report's grep-verified link inventory (7 refs to office-workflows.md in 4 files; 9 refs to agent-system/workflow.md in 5 files) drives the dedicated link-repair phases.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the docs reorganization arc (tasks 6/7/8) that extracts flat docs/ files into focused subdirectories. It establishes `docs/workflows/` as the user-facing how-to complement to `docs/agent-system/` (reference documentation), creating navigation symmetry in docs/README.md. It also prepares the structure for future workflow documentation (grant writing, research talks, memory, maintenance commands) identified in the research phase.

## Goals & Non-Goals

**Goals**:
- Create `docs/workflows/` as a sibling of `docs/agent-system/`
- Produce 5 workflow files + README.md covering all content in the two source files
- Move and rename `docs/agent-system/workflow.md` to `docs/workflows/agent-lifecycle.md`
- Repair all 16 inbound links (9 to agent-system/workflow.md, 7 to office-workflows.md)
- Delete both source files once repairs are verified
- Ensure workflows/ files are usage narratives (macOS-focused steps) rather than command reference duplicates
- Add cross-links between workflow files and out to related docs
- Update `docs/README.md` navigation hub to list the new directory

**Non-Goals**:
- Adding new content beyond what exists in the two source files (no new workflows)
- Restructuring `docs/agent-system/commands.md` or other sibling docs
- Creating per-command stub files (`/table`, `/slides`, `/scrape` as standalone files)
- Adding workflow documentation for grant/talk/memory/maintenance commands (future work)
- Backward-compatibility redirect stubs (all refs are in-repo and repairable)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Missed inbound link causes broken navigation | M | M | Dedicated verification phase with grep for `office-workflows` and `agent-system/workflow` patterns |
| Content drift during splitting (accidentally dropping source material) | M | L | Work from a section inventory; diff word-count of source files vs new files for sanity check |
| Cross-cutting content re-duplicated across new files | L | M | Enforce "link to tips-and-troubleshooting.md, do not inline" rule during authoring |
| Workflows/ files duplicate `docs/agent-system/commands.md` flag tables | M | M | Keep usage-narrative voice: steps and screenshots, not flag syntax; link back to commands.md |
| Internal links in moved `agent-lifecycle.md` break (path depth changed) | M | H | Path-depth audit during move phase (was `../../.claude/rules/` from agent-system/, still works from workflows/) |
| `docs/agent-system/commands.md` office-workflow refs become ambiguous (which specific file?) | L | M | Map each ref to the most specific workflow file during link-repair phase |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 5 | 1 |
| 3 | 6 | 2, 3, 4, 5 |
| 4 | 7, 8 | 6 |
| 5 | 9 | 7, 8 |
| 6 | 10 | 9 |

Phases within the same wave can execute in parallel.

### Phase 1: Create directory scaffold and content inventory [COMPLETED]

**Goal**: Establish `docs/workflows/` directory with a placeholder README and a shared content inventory used by subsequent phases.

**Tasks**:
- [ ] Create `docs/workflows/` directory
- [ ] Create `docs/workflows/README.md` placeholder with title and TODO-marked TOC
- [ ] Produce section-to-file mapping table (source section -> destination file) from `docs/office-workflows.md`
- [ ] Note path-depth change for `agent-lifecycle.md` (moving from `docs/agent-system/` to `docs/workflows/`; both are 2 deep so `../../.claude/` paths remain correct)
- [ ] Confirm grep-verified link inventory from research still matches current file state

**Timing**: 20 minutes

**Depends on**: none

**Files to modify**:
- `docs/workflows/README.md` - new placeholder

**Verification**:
- Directory `docs/workflows/` exists
- Section inventory captures every H2 and H3 from `docs/office-workflows.md`
- Link-inventory grep matches the research report's counts (7 and 9)

---

### Phase 2: Move and rename agent-system/workflow.md [COMPLETED]

**Goal**: Move `docs/agent-system/workflow.md` to `docs/workflows/agent-lifecycle.md` with internal relative links still resolving.

**Tasks**:
- [ ] Copy `docs/agent-system/workflow.md` content into `docs/workflows/agent-lifecycle.md`
- [ ] Update heading from `# Main Workflow` to `# Agent Task Lifecycle` (disambiguate from office workflows)
- [ ] Update intra-`agent-system/` links in moved file: `[commands.md](commands.md)` -> `[commands.md](../agent-system/commands.md)`; same for `architecture.md`, `zed-agent-panel.md`, `context-and-memory.md`
- [ ] Verify `../../.claude/rules/workflows.md` and `../../.claude/rules/git-workflow.md` and `../../.claude/rules/artifact-formats.md` still resolve (path depth unchanged)
- [ ] Update `.claude/docs/guides/user-guide.md` and `.claude/docs/examples/research-flow-example.md` relative paths if present (they use `../../` so they remain correct)
- [ ] Add "See also" link back to `README.md` (workflows index) at the bottom

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `docs/workflows/agent-lifecycle.md` - new file (content from workflow.md)
- (Old file not yet deleted; deletion in Phase 10)

**Verification**:
- `agent-lifecycle.md` exists and renders
- Every internal link in the new file resolves (manual spot-check + grep for relative paths)
- Heading says "Agent Task Lifecycle"

---

### Phase 3: Create edit-word-documents.md [COMPLETED]

**Goal**: Consolidate all `/edit` Word workflows (in-place, batch, create-new) and the "How Claude Edits" explanation into one file.

**Tasks**:
- [ ] Create `docs/workflows/edit-word-documents.md`
- [ ] Port source sections: "How Claude Edits Word Documents", "Edit Word Documents In-Place", "Batch Document Editing", "Create New Documents", "Prompt Examples"
- [ ] Deduplicate the Agent Panel (Cmd+Shift+?) invocation step: mention once in an intro; link to `tips-and-troubleshooting.md` for macOS permission details
- [ ] Ensure the save-edit-reload explanation appears once (not repeated from intro to `/edit` section)
- [ ] Add cross-links: See also `edit-spreadsheets.md`, `convert-documents.md`, `tips-and-troubleshooting.md`
- [ ] Link to `../agent-system/commands.md#edit` for flag reference (do not duplicate flags)
- [ ] Link to `../installation.md#install-mcp-tools` for SuperDoc prerequisite

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `docs/workflows/edit-word-documents.md` - new file (~80 lines expected)

**Verification**:
- File contains all three `/edit` variants
- Agent Panel invocation appears at most once
- Cross-links render; no duplicate flag tables from commands.md
- Prompt Examples table preserved

---

### Phase 4: Create edit-spreadsheets.md [COMPLETED]

**Decision**: Kept as a separate file (content expanded past 25-line threshold with Tips and See also; symmetry with edit-word-documents.md and standalone constraint about save-and-close justify a standalone file).

**Goal**: Split the openpyxl "Direct Spreadsheet Editing" section into its own file (threshold check: if under 25 lines, merge into edit-word-documents.md instead).

**Tasks**:
- [ ] Extract "Direct Spreadsheet Editing" section from source
- [ ] Measure resulting content; if under 25 lines, fold into `edit-word-documents.md` under a "Spreadsheets" section and skip the separate file
- [ ] If kept separate: create `docs/workflows/edit-spreadsheets.md` with the content
- [ ] Note the "Save and close in Excel first" constraint prominently
- [ ] Add cross-links to `edit-word-documents.md` and `convert-documents.md` (for /table)
- [ ] Link to `tips-and-troubleshooting.md` for macOS permissions

**Timing**: 25 minutes

**Depends on**: 1

**Files to modify**:
- `docs/workflows/edit-spreadsheets.md` - new file (or integrated into edit-word-documents.md per threshold)

**Verification**:
- Content present in exactly one location (not both files)
- "Save and close first" warning preserved
- Cross-links render

---

### Phase 5: Create convert-documents.md [COMPLETED]

**Goal**: Consolidate `/convert`, `/table`, `/slides`, and `/scrape` into a single conversion-workflows file with each command as a subsection.

**Tasks**:
- [ ] Create `docs/workflows/convert-documents.md`
- [ ] Port source sections: "Document Conversion with Claude Code" intro, `/convert`, "Extract tables from spreadsheets" (`/table`), "Convert presentations" (`/slides`), "Extract PDF annotations" (`/scrape`)
- [ ] Preserve code-block examples verbatim
- [ ] Add a short decision guide at top ("I want to... -> use...")
- [ ] Cross-link to `edit-word-documents.md` (for editing converted output) and `tips-and-troubleshooting.md` (OneDrive tip for source files)
- [ ] Link to `../agent-system/commands.md` for full command reference
- [ ] Link to `../installation.md#install-mcp-tools` for MCP prerequisites

**Timing**: 40 minutes

**Depends on**: 1

**Files to modify**:
- `docs/workflows/convert-documents.md` - new file (~60 lines expected)

**Verification**:
- All four conversion commands covered as subsections
- Decision guide present
- Cross-links render

---

### Phase 6: Create tips-and-troubleshooting.md [COMPLETED]

**Goal**: Centralize cross-cutting content (OneDrive sync pauses, macOS permissions, Agent Panel invocation, common errors) so the command-workflow files can link here instead of repeating.

**Tasks**:
- [ ] Create `docs/workflows/tips-and-troubleshooting.md`
- [ ] Port "OneDrive and SharePoint Tips" verbatim
- [ ] Port "Troubleshooting" section verbatim
- [ ] Consolidate Agent Panel invocation (Cmd+Shift+?) into one canonical step list
- [ ] Consolidate macOS permissions dialog explanation into one section (currently duplicated between "How Claude Edits" and "Troubleshooting" in source)
- [ ] Add `tasks.json` runner table here OR in `docs/settings.md` (decision: keep here if it is already in settings.md, else add a brief entry and link)
- [ ] Add back-links from the four workflow files (enforced in phases 3-5, verified here)

**Timing**: 35 minutes

**Depends on**: 2, 3, 4, 5

**Files to modify**:
- `docs/workflows/tips-and-troubleshooting.md` - new file (~50 lines expected)
- Possibly `docs/settings.md` - if tasks.json runner content is relocated there

**Verification**:
- OneDrive, macOS permissions, and Agent Panel steps appear exactly once across the workflows/ directory
- All office workflow files link back to this file for shared topics
- tasks.json content placed in exactly one canonical location

---

### Phase 7: Populate workflows/README.md [NOT STARTED]

**Goal**: Turn the placeholder README into the authoritative TOC + decision guide + common scenarios section.

**Tasks**:
- [ ] Replace placeholder with real content
- [ ] Build TOC table with one row per file and brief descriptions:
  - `agent-lifecycle.md` - Claude Code task lifecycle state machine
  - `edit-word-documents.md` - Edit .docx files with tracked changes
  - `edit-spreadsheets.md` - Direct .xlsx editing via openpyxl (if kept)
  - `convert-documents.md` - Convert between PDF/DOCX/MD/XLSX/PPTX
  - `tips-and-troubleshooting.md` - OneDrive, macOS permissions, common errors
- [ ] Add "Common scenarios" section with 3 end-to-end examples from source "Workflow Examples" (PDF review, report from data, collaborator doc)
- [ ] Add decision guide: "I want to... -> see..."
- [ ] Group TOC into two sections: "Agent system" (agent-lifecycle) and "Office documents" (the four office files) to address semantic-divergence concern
- [ ] Add "See also" links outward: `../agent-system/README.md`, `../settings.md`, `../installation.md`

**Timing**: 30 minutes

**Depends on**: 6

**Files to modify**:
- `docs/workflows/README.md` - replace placeholder

**Verification**:
- TOC lists every file in workflows/
- Each file is linked
- Common scenarios section contains the three end-to-end examples
- Decision guide present
- Sectioned to separate agent-lifecycle from office workflows

---

### Phase 8: Repair inbound links to agent-system/workflow.md [NOT STARTED]

**Goal**: Update all 9 references in 5 files to point at `../workflows/agent-lifecycle.md` (from `docs/agent-system/*`) or the equivalent from other locations.

**Tasks**:
- [ ] `docs/agent-system/README.md` lines 19, 52: `[workflow.md](workflow.md)` -> `[agent-lifecycle.md](../workflows/agent-lifecycle.md)`
- [ ] `docs/agent-system/architecture.md` lines 3, 117: `[workflow.md](workflow.md)` -> `[agent-lifecycle.md](../workflows/agent-lifecycle.md)`
- [ ] `docs/agent-system/commands.md` lines 3, 9, 334: same pattern
- [ ] `docs/agent-system/zed-agent-panel.md` line 121: same pattern
- [ ] `docs/agent-system/context-and-memory.md` line 109: same pattern
- [ ] Grep for any remaining `workflow\.md` references in `docs/` and confirm only `.claude/rules/workflow.md` / `workflows.md` unrelated matches remain
- [ ] Update link text from "workflow.md" to "agent-lifecycle.md" where the text was the filename

**Timing**: 30 minutes

**Depends on**: 6

**Files to modify**:
- `docs/agent-system/README.md`
- `docs/agent-system/architecture.md`
- `docs/agent-system/commands.md`
- `docs/agent-system/zed-agent-panel.md`
- `docs/agent-system/context-and-memory.md`

**Verification**:
- `grep -rn "workflow\.md" docs/agent-system/` returns zero results pointing at the old location
- All updated links resolve to the new path

---

### Phase 9: Repair inbound links to office-workflows.md [NOT STARTED]

**Goal**: Update all 7 references in 4 live files to point at the appropriate workflow file in `docs/workflows/`.

**Tasks**:
- [ ] `README.md` (root) lines 43, 57, 92: update directory tree, docs table, and body prose to reference `docs/workflows/` (not the old single file)
- [ ] `docs/README.md` line 11: replace `office-workflows.md` entry with `workflows/` directory entry (link to `workflows/README.md`)
- [ ] `docs/settings.md` line 250: update link target to `workflows/README.md` or a specific file
- [ ] `docs/agent-system/commands.md` lines 202, 254: map each ref to most specific file (`edit-word-documents.md` or `convert-documents.md`)
- [ ] Verify no references to `docs/office-workflows.md` remain in live docs
- [ ] Confirm historical plan files in `specs/003_integrate_guide_into_docs/` are left alone (these are archived plans, not navigation)

**Timing**: 35 minutes

**Depends on**: 7

**Files to modify**:
- `README.md` (root)
- `docs/README.md`
- `docs/settings.md`
- `docs/agent-system/commands.md`

**Verification**:
- `grep -rn "office-workflows" README.md docs/` returns only desired (if any) results
- All updated links resolve

---

### Phase 10: Delete source files and final verification [NOT STARTED]

**Goal**: Remove source files and run a full verification pass on the new structure.

**Tasks**:
- [ ] Delete `docs/office-workflows.md`
- [ ] Delete `docs/agent-system/workflow.md`
- [ ] Run `grep -rn "office-workflows" docs/ README.md` - expect zero live-navigation hits
- [ ] Run `grep -rn "agent-system/workflow\.md" docs/ README.md .claude/` - expect zero live-navigation hits
- [ ] Manually render / eyeball each new file in `docs/workflows/` (six files total)
- [ ] Walk through every "See also" and cross-link; confirm all resolve
- [ ] Diff source-file word counts vs new-file word counts; flag any >10% loss as a content-drop risk
- [ ] Confirm the 3 common scenarios from source "Workflow Examples" are preserved (in README.md)

**Timing**: 35 minutes

**Depends on**: 8, 9

**Files to modify**:
- Delete: `docs/office-workflows.md`
- Delete: `docs/agent-system/workflow.md`

**Verification**:
- Source files no longer exist
- Zero broken-link grep matches
- All six new files render
- Word-count sanity check passes

---

## Testing & Validation

- [ ] `docs/workflows/` contains exactly 6 files (README + 5 workflows), or 5 files if edit-spreadsheets.md was merged
- [ ] Every file has a title H1 matching its filename intent
- [ ] `grep -rn "office-workflows" docs/ README.md` returns no live navigation hits
- [ ] `grep -rn "agent-system/workflow\.md" docs/ README.md .claude/` returns no hits
- [ ] Every cross-link in `docs/workflows/` resolves (manual walk)
- [ ] Every inbound link from `README.md`, `docs/README.md`, `docs/settings.md`, `docs/agent-system/*` resolves
- [ ] `docs/workflows/README.md` TOC lists every sibling file
- [ ] OneDrive, macOS permissions, and Agent Panel steps appear exactly once across workflows/
- [ ] Word count of new files >= 90% of combined source files (no accidental content drop)

## Artifacts & Outputs

- `docs/workflows/README.md` (new; TOC + decision guide + common scenarios)
- `docs/workflows/agent-lifecycle.md` (new; moved from docs/agent-system/workflow.md)
- `docs/workflows/edit-word-documents.md` (new)
- `docs/workflows/edit-spreadsheets.md` (new; may be folded into edit-word-documents.md per Phase 4 threshold)
- `docs/workflows/convert-documents.md` (new)
- `docs/workflows/tips-and-troubleshooting.md` (new)
- Updated: `README.md`, `docs/README.md`, `docs/settings.md`, `docs/agent-system/{README,architecture,commands,zed-agent-panel,context-and-memory}.md`
- Deleted: `docs/office-workflows.md`, `docs/agent-system/workflow.md`

## Rollback/Contingency

All changes are in git. If the split produces unusable output:

1. `git restore docs/office-workflows.md docs/agent-system/workflow.md` (revert deletions)
2. `git rm -r docs/workflows/` (remove the new directory)
3. `git restore README.md docs/README.md docs/settings.md docs/agent-system/` (revert link edits)
4. Commit the rollback as `task 8: rollback split-workflows-directory`

Partial rollback is possible phase-by-phase because phases 2-7 create new files independently and phases 8-10 are the only destructive steps. If link repair is done but content files are bad, re-edit content files without touching link repair. If the source-file deletion (Phase 10) is premature, `git restore` recovers them and the link-repair changes can coexist until files are regenerated.
