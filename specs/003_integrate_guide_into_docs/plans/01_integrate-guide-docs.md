# Implementation Plan: Integrate Guide into Docs

- **Task**: 3 - Integrate zed-claude-office-guide.md into docs/
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/003_integrate_guide_into_docs/reports/01_integrate-guide-docs.md
- **Artifacts**: plans/01_integrate-guide-docs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The file `zed-claude-office-guide.md` (315 lines) is a macOS-oriented beginner guide for a collaborator. Research found that approximately 60% of its content has no equivalent in docs/, while 40% overlaps from a different platform perspective. The plan integrates all unique platform-agnostic content into the existing docs/ files, adds concise platform notes where needed, and deletes the guide file once all content is accounted for. Definition of done: every piece of information in the guide either exists in docs/ or has been deliberately excluded as platform-specific, and the guide file is removed.

### Research Integration

Key findings from the research report:
- MCP tool setup (SuperDoc, openpyxl) is completely missing from docs/
- Grant and research commands (/grant, /budget, /funds, /timeline, /talk) are not documented in docs/
- Batch editing, new document creation, and direct spreadsheet editing workflows are absent
- Prompt examples and troubleshooting are unique to the guide
- macOS installation steps (Homebrew, WezTerm) are platform-specific and can be dropped for this Linux-focused repo

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROAD_MAP.md found.

## Goals & Non-Goals

**Goals**:
- Integrate all platform-agnostic content from the guide into docs/
- Add MCP setup instructions to docs/agent-system.md
- Document grant/research commands in docs/agent-system.md
- Expand docs/office-workflows.md with missing workflow recipes
- Add prompt examples and troubleshooting to relevant docs
- Update docs/README.md index if new sections are added
- Delete zed-claude-office-guide.md after full integration
- Fix the broken link in docs/office-workflows.md (line 112 references `guides/keybindings.md` instead of `keybindings.md`)

**Non-Goals**:
- Rewriting docs/ from scratch
- Adding macOS-specific installation instructions (Homebrew, WezTerm)
- Creating a separate macOS guide
- Changing the existing Linux/NixOS focus of docs/

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| docs/office-workflows.md becomes too long after expansion | M | M | Keep new sections concise; split into separate file only if result exceeds ~250 lines |
| Losing unique content during integration | H | L | Systematic section-by-section checklist; verify each guide section is accounted for before deletion |
| Platform confusion from mixing macOS/Linux content | M | L | Use clear platform labels only where both platforms differ; default to Linux conventions |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Expand docs/agent-system.md [NOT STARTED]

**Goal**: Add MCP setup instructions and grant/research commands that are completely missing from docs/.

**Tasks**:
- [ ] Add "MCP Tool Setup" section after the "Configuration" section (~line 92), covering:
  - SuperDoc MCP: what it does, `claude mcp add` command, verification
  - openpyxl MCP: what it does, `claude mcp add` command, verification
  - Platform note: commands are the same on macOS and Linux
- [ ] Add "Grant and Research Commands" section after the "Key commands" table (~line 57), covering:
  - `/grant` -- create and draft grant proposals (with example prompt)
  - `/budget` -- generate budget spreadsheets (with example prompt)
  - `/funds` -- research funding opportunities (with example prompt)
  - `/timeline` -- build project timelines (with example prompt)
  - `/talk` -- create research presentations (with example prompt)
  - Note that each command creates a resumable task
- [ ] Update the "Known Limitations" section to remove the "MCP context servers are not yet configured" line (since we are now documenting MCP setup)
- [ ] Add SuperDoc and openpyxl to the limitations section noting that complex formatting (embedded charts, SmartArt) may need manual touch-up

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `docs/agent-system.md` -- Add MCP setup section and grant/research commands

**Verification**:
- docs/agent-system.md contains MCP setup instructions with `claude mcp add` commands
- docs/agent-system.md contains all five grant/research commands with example prompts
- "MCP context servers are not yet configured" line is removed

---

### Phase 2: Expand docs/office-workflows.md [NOT STARTED]

**Goal**: Add the missing workflow recipes, prompt examples, and troubleshooting section from the guide.

**Tasks**:
- [ ] Expand the "Edit Word documents in-place" section (~line 71-77) with:
  - Save-edit-reload workflow explanation (how Claude, SuperDoc, and Word/LibreOffice interact)
  - Tracked changes example prompt
  - Note: Word stays open on macOS; on Linux, reopen in LibreOffice to see changes
- [ ] Add "Direct Spreadsheet Editing" section covering:
  - Editing .xlsx values, rows, formulas via openpyxl MCP
  - Example prompt from the guide (budget.xlsx Q2 sheet example)
  - Note: save and close the file first
- [ ] Add "Batch Document Editing" section covering:
  - `/edit path/to/folder/ "instructions"` syntax
  - Example prompt from the guide (contract templates)
- [ ] Add "Create New Documents" section covering:
  - `/edit --new path/to/file.docx "description"` syntax
  - Example prompt from the guide (Q2 memo)
- [ ] Add "Prompt Examples" section with the useful phrases from Part 4 of the guide:
  - `/edit file.docx "replace X with Y"`
  - `/edit file.docx "replace X with Y using tracked changes"`
  - `/edit --new file.docx "create a memo about..."`
  - `/edit folder/ "replace X with Y in all files"`
  - "Give me a summary of..." (no /edit needed)
- [ ] Add "Troubleshooting" section at the end covering:
  - MCP tools not showing in `claude mcp list` -- re-run the add command
  - Agent panel not responding -- check Claude Code extension
- [ ] Fix broken link on line 112: change `guides/keybindings.md` to `keybindings.md`

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `docs/office-workflows.md` -- Add workflow recipes, prompts, and troubleshooting

**Verification**:
- docs/office-workflows.md contains all four new workflow sections (spreadsheet editing, batch editing, new documents, prompt examples)
- Troubleshooting section exists
- Broken link is fixed
- File length is reasonable (should be under ~250 lines)

---

### Phase 3: Update docs/README.md and README.md [NOT STARTED]

**Goal**: Ensure documentation indexes reflect the new content and all cross-references are correct.

**Tasks**:
- [ ] Review docs/README.md -- update descriptions if the scope of agent-system.md or office-workflows.md changed significantly
- [ ] Review README.md -- check that the Documentation table descriptions still match the expanded content
- [ ] Verify all internal cross-links between docs/ files are correct (especially any links that reference the guide file)

**Timing**: 15 minutes

**Depends on**: 1, 2

**Files to modify**:
- `docs/README.md` -- Update section descriptions if needed
- `README.md` -- Update documentation table descriptions if needed

**Verification**:
- docs/README.md accurately describes the contents of each docs/ file
- No broken links between docs/ files
- No references to zed-claude-office-guide.md remain in any docs/ file

---

### Phase 4: Delete Guide and Final Verification [NOT STARTED]

**Goal**: Remove the original guide file after confirming all content is integrated.

**Tasks**:
- [ ] Run a final content checklist against the guide's sections:
  - Part 1 (Installation): macOS-specific, intentionally excluded -- CONFIRMED
  - Part 2 (Tool Explanations): MCP tools integrated into agent-system.md -- VERIFY
  - Part 2 (How They Work Together): Save-edit-reload in office-workflows.md -- VERIFY
  - Part 2 (Limitations): Added to agent-system.md -- VERIFY
  - Part 3 (Workflow 1-4): All in office-workflows.md -- VERIFY
  - Part 3 (Workflow 5): Grant commands in agent-system.md -- VERIFY
  - Part 3 (OneDrive tips): macOS-specific, intentionally excluded -- CONFIRMED
  - Part 4 (Cheat sheet): Prompt examples in office-workflows.md -- VERIFY
  - Part 4 (Useful phrases): In office-workflows.md prompt examples -- VERIFY
- [ ] Delete `zed-claude-office-guide.md`
- [ ] Search all files for any remaining references to `zed-claude-office-guide` and remove them

**Timing**: 15 minutes

**Depends on**: 3

**Files to modify**:
- `zed-claude-office-guide.md` -- Delete

**Verification**:
- zed-claude-office-guide.md no longer exists
- No file in the repository references zed-claude-office-guide.md
- All information from the guide is either present in docs/ or documented as intentionally excluded (macOS installation, OneDrive tips)

## Testing & Validation

- [ ] All docs/ files render valid Markdown (no broken syntax)
- [ ] All internal links between docs/ files resolve correctly
- [ ] docs/agent-system.md contains MCP setup and grant/research commands
- [ ] docs/office-workflows.md contains all workflow recipes from the guide
- [ ] No references to zed-claude-office-guide.md remain anywhere in the repo
- [ ] The guide file is deleted
- [ ] docs/office-workflows.md is under 250 lines (manageable length)

## Artifacts & Outputs

- `docs/agent-system.md` -- Expanded with MCP setup and grant/research commands
- `docs/office-workflows.md` -- Expanded with workflow recipes, prompts, and troubleshooting
- `docs/README.md` -- Updated descriptions (if needed)
- `README.md` -- Updated descriptions (if needed)
- `zed-claude-office-guide.md` -- Deleted

## Rollback/Contingency

All changes are to tracked files in a git repository. If integration introduces problems:
1. `git checkout -- docs/ README.md zed-claude-office-guide.md` to restore all files
2. The guide file is preserved in git history even after deletion
3. If docs/office-workflows.md exceeds 250 lines, split the new workflow recipes into a separate `docs/office-workflows-advanced.md` file
