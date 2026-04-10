# Implementation Plan: Integrate Guide into Docs

- **Task**: 3 - Integrate zed-claude-office-guide.md into docs/
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/003_integrate_guide_into_docs/reports/01_integrate-guide-docs.md
- **Artifacts**: plans/01_integrate-guide-docs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false
- **Plan Version**: 2 (revision: assume macOS throughout)

## Overview

The file `zed-claude-office-guide.md` (315 lines) is a macOS-oriented beginner guide for a collaborator. Research found that approximately 60% of its content has no equivalent in docs/, while 40% overlaps from a different platform perspective. This revision assumes macOS as the target platform throughout, which means the guide's macOS-specific installation steps, keyboard shortcuts (Cmd-based), and application references (Word, Excel, WezTerm) become the baseline rather than content to be excluded. The plan integrates all guide content into the existing docs/ files, converts existing Linux/Ctrl-based references to macOS/Cmd-based conventions, and deletes the guide file once all content is accounted for. Definition of done: every piece of information in the guide exists in docs/, docs/ assumes macOS throughout, and the guide file is removed.

### Research Integration

Key findings from the research report:
- MCP tool setup (SuperDoc, openpyxl) is completely missing from docs/
- Grant and research commands (/grant, /budget, /funds, /timeline, /talk) are not documented in docs/
- Batch editing, new document creation, and direct spreadsheet editing workflows are absent
- Prompt examples and troubleshooting are unique to the guide
- macOS installation steps (Homebrew, WezTerm) are now IN SCOPE since we assume macOS throughout
- OneDrive/SharePoint tips are now IN SCOPE

### Prior Plan Reference

v1 plan assumed Linux focus and excluded macOS-specific content. This v2 revision reverses that: macOS is the default platform, and Linux-specific content (NixOS, LibreOffice, Ctrl shortcuts) is removed or adapted.

### Roadmap Alignment

No ROAD_MAP.md found.

## Goals & Non-Goals

**Goals**:
- Convert all docs/ files from Linux/Ctrl conventions to macOS/Cmd conventions
- Integrate ALL content from the guide into docs/, including installation and OneDrive tips
- Add MCP setup instructions to docs/agent-system.md
- Document grant/research commands in docs/agent-system.md
- Expand docs/office-workflows.md with missing workflow recipes, now referencing Word/Excel (not LibreOffice)
- Add prompt examples and troubleshooting to relevant docs
- Convert docs/keybindings.md from Ctrl-based to Cmd-based shortcuts
- Update docs/README.md index if new sections are added
- Delete zed-claude-office-guide.md after full integration
- Fix the broken link in docs/office-workflows.md (line 112 references `guides/keybindings.md` instead of `keybindings.md`)

**Non-Goals**:
- Rewriting docs/ from scratch
- Maintaining Linux/NixOS instructions alongside macOS
- Creating dual-platform documentation with platform toggles

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| docs/office-workflows.md becomes too long after expansion | M | M | Keep new sections concise; split into separate file only if result exceeds ~250 lines |
| Losing unique content during integration | H | L | Systematic section-by-section checklist; verify each guide section is accounted for before deletion |
| Keybindings file becomes inconsistent with mixed Ctrl/Cmd | M | M | Do a complete pass converting all shortcuts; verify no Ctrl references remain for user-facing actions |
| LibreOffice references left behind | L | M | Search-and-replace pass; Word/Excel replaces LibreOffice throughout |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |
| 3 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Convert docs/keybindings.md to macOS [COMPLETED]

**Goal**: Replace all Ctrl-based shortcuts with Cmd-based equivalents and update application references for macOS.

**Tasks**:
- [ ] Replace all `Ctrl+` with `Cmd+` for standard shortcuts (Cmd+P, Cmd+S, Cmd+Z, Cmd+C, Cmd+X, Cmd+V, Cmd+F, Cmd+W, etc.)
- [ ] Replace `Ctrl+Shift+` with `Cmd+Shift+` throughout
- [ ] Keep `Alt+` shortcuts as-is (Alt exists on macOS keyboards, though labeled Option)
- [ ] Add a note at the top: "This guide assumes macOS. On macOS, the Cmd key () is used where other platforms use Ctrl."
- [ ] Replace `Ctrl+?` (custom sidebar toggle) with `Cmd+Shift+?` to match the guide's convention
- [ ] Update the "Adding more shortcuts" section to reference macOS keymap conventions
- [ ] Replace any references to "Ctrl+`" (terminal) with "Cmd+`" or the appropriate macOS equivalent
- [ ] Remove the NixOS/Linux-specific note about `zeditor` binary if present

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `docs/keybindings.md` -- Convert all shortcuts to macOS conventions

**Verification**:
- No `Ctrl+` shortcuts remain for standard user actions (Cmd+ used instead)
- All shortcuts match what a macOS user would press
- File is internally consistent

---

### Phase 2: Expand docs/agent-system.md [COMPLETED]

**Goal**: Add MCP setup instructions and grant/research commands, convert all shortcuts to macOS, and add installation guidance.

**Tasks**:
- [ ] Convert all keyboard shortcuts from Ctrl to Cmd (Cmd+? or Cmd+Shift+? for agent panel, Cmd+` for terminal, Cmd+N for new thread, etc.)
- [ ] Add "Installation" section near the top covering:
  - Prerequisites (macOS 11+)
  - Install Homebrew (with verification step)
  - Install Zed via `brew install --cask zed`
  - Open Zed from Applications or Spotlight (Cmd+Space)
- [ ] Add "MCP Tool Setup" section after the "Configuration" section, covering:
  - SuperDoc MCP: what it does, `claude mcp add --scope user superdoc -- npx @superdoc-dev/mcp` command
  - openpyxl MCP: what it does, `claude mcp add --scope user openpyxl -- npx @jonemo/openpyxl-mcp` command
  - Verification: `claude mcp list` should show both
- [ ] Add "Grant and Research Commands" section after the "Key commands" table, covering:
  - `/grant` -- create and draft grant proposals (with example prompt)
  - `/budget` -- generate budget spreadsheets (with example prompt)
  - `/funds` -- research funding opportunities (with example prompt)
  - `/timeline` -- build project timelines (with example prompt)
  - `/talk` -- create research presentations (with example prompt)
  - Note that each command creates a resumable task
- [ ] Update the "Known Limitations" section:
  - Remove the "MCP context servers are not yet configured" line
  - Add note that complex formatting (embedded charts, SmartArt) may need manual touch-up in Word
  - Add note about API credit usage
- [ ] Update "Related Documentation" links if any paths changed

**Timing**: 40 minutes

**Depends on**: none

**Files to modify**:
- `docs/agent-system.md` -- Add installation, MCP setup, grant commands; convert to macOS shortcuts

**Verification**:
- docs/agent-system.md contains installation instructions for macOS
- docs/agent-system.md contains MCP setup instructions with `claude mcp add` commands
- docs/agent-system.md contains all five grant/research commands with example prompts
- All shortcuts use Cmd instead of Ctrl
- "MCP context servers are not yet configured" line is removed

---

### Phase 3: Expand docs/office-workflows.md [NOT STARTED]

**Goal**: Add the missing workflow recipes, prompt examples, and troubleshooting section from the guide. Replace all Linux/LibreOffice references with macOS/Word/Excel.

**Tasks**:
- [ ] Replace the Linux framing: change "Working with Office documents on Linux" to "Working with Office documents on macOS"
- [ ] Replace all LibreOffice references with Word/Excel as appropriate
- [ ] Replace "Open in LibreOffice" task runner references with macOS-appropriate workflow (Word stays open; Claude handles save-edit-reload)
- [ ] Convert all Ctrl shortcuts to Cmd shortcuts
- [ ] Expand the "Edit Word documents in-place" section with:
  - Save-edit-reload workflow explanation (how Claude, SuperDoc, and Word interact)
  - Word stays open the whole time; Claude handles saving and reloading
  - Tracked changes example prompt
  - First-time macOS permissions note (grant Zed/WezTerm permission to control Word)
- [ ] Add "Direct Spreadsheet Editing" section covering:
  - Editing .xlsx values, rows, formulas via openpyxl MCP
  - Example prompt from the guide (budget.xlsx Q2 sheet example)
  - Note: save and close the file in Excel first
- [ ] Add "Batch Document Editing" section covering:
  - `/edit path/to/folder/ "instructions"` syntax
  - Example prompt from the guide (contract templates)
  - OneDrive sync tip: pause syncing during batch edits
- [ ] Add "Create New Documents" section covering:
  - `/edit --new path/to/file.docx "description"` syntax
  - Example prompt from the guide (Q2 memo)
- [ ] Add "Prompt Examples" section with the useful phrases from Part 4 of the guide:
  - `/edit file.docx "replace X with Y"`
  - `/edit file.docx "replace X with Y using tracked changes"`
  - `/edit --new file.docx "create a memo about..."`
  - `/edit ~/Documents/Contracts/ "replace X with Y in all files"`
  - "Give me a summary of..." (no /edit needed)
- [ ] Add "OneDrive and SharePoint Tips" section:
  - Pause syncing for batch edits (menu bar icon instructions)
  - Resume syncing when done
- [ ] Add "Troubleshooting" section at the end covering:
  - MCP tools not showing in `claude mcp list` -- re-run the add command with `--scope user`
  - Agent panel not responding -- check Claude Code extension in Settings > Extensions
  - "command not found" after Homebrew install -- close and reopen WezTerm
  - macOS permissions dialog for Word automation -- click OK
- [ ] Fix broken link on line 112: change `guides/keybindings.md` to `keybindings.md`
- [ ] Update the "Available Tasks" table to reflect macOS tools (remove LibreOffice task or adapt)

**Timing**: 50 minutes

**Depends on**: none

**Files to modify**:
- `docs/office-workflows.md` -- Major expansion with macOS-native workflows, prompts, troubleshooting

**Verification**:
- No references to LibreOffice remain (replaced by Word/Excel)
- No Ctrl shortcuts remain (replaced by Cmd)
- docs/office-workflows.md contains all workflow sections (tracked changes, spreadsheet editing, batch editing, new documents, prompt examples)
- OneDrive tips section exists
- Troubleshooting section exists
- Broken link is fixed
- File length is reasonable (should be under ~300 lines given expanded scope)

---

### Phase 4: Update docs/README.md and README.md [NOT STARTED]

**Goal**: Ensure documentation indexes reflect the new macOS-focused content and all cross-references are correct.

**Tasks**:
- [ ] Review docs/README.md -- update descriptions to reflect macOS focus and expanded scope of agent-system.md and office-workflows.md
- [ ] Review README.md -- update the Documentation table descriptions to reflect macOS platform and expanded content
- [ ] Replace any Linux/NixOS platform references in README.md with macOS
- [ ] Verify all internal cross-links between docs/ files are correct
- [ ] Search all docs/ files for any remaining references to `zed-claude-office-guide.md` and remove them
- [ ] Search for any remaining `Ctrl+` shortcuts that should be `Cmd+` in docs/README.md and README.md

**Timing**: 20 minutes

**Depends on**: 1, 2, 3

**Files to modify**:
- `docs/README.md` -- Update section descriptions for macOS focus
- `README.md` -- Update documentation table and platform references

**Verification**:
- docs/README.md accurately describes the contents of each docs/ file
- No broken links between docs/ files
- No references to zed-claude-office-guide.md remain
- No Linux/NixOS platform references remain in user-facing docs

---

### Phase 5: Delete Guide and Final Verification [NOT STARTED]

**Goal**: Remove the original guide file after confirming all content is integrated.

**Tasks**:
- [ ] Run a final content checklist against the guide's sections:
  - Part 1 (Installation): Integrated into agent-system.md -- VERIFY
  - Part 1 (MCP Setup, Steps 4-5): Integrated into agent-system.md -- VERIFY
  - Part 1 (Troubleshooting): Integrated into office-workflows.md troubleshooting -- VERIFY
  - Part 2 (Tool Explanations): MCP tools integrated into agent-system.md -- VERIFY
  - Part 2 (How They Work Together): Save-edit-reload in office-workflows.md -- VERIFY
  - Part 2 (Limitations): Added to agent-system.md -- VERIFY
  - Part 2 (First-Time Setup Note): macOS permissions in office-workflows.md -- VERIFY
  - Part 3 (Workflow 1-4): All in office-workflows.md -- VERIFY
  - Part 3 (Workflow 5): Grant commands in agent-system.md -- VERIFY
  - Part 3 (OneDrive tips): In office-workflows.md -- VERIFY
  - Part 4 (Cheat sheet): Prompt examples in office-workflows.md -- VERIFY
  - Part 4 (Useful phrases): In office-workflows.md prompt examples -- VERIFY
- [ ] Delete `zed-claude-office-guide.md`
- [ ] Search all files for any remaining references to `zed-claude-office-guide` and remove them
- [ ] Final grep for `Ctrl+` in docs/ to catch any missed conversions (only `Ctrl` references should be in technical contexts like terminal escape sequences, not user-facing shortcuts)
- [ ] Final grep for `LibreOffice` in docs/ to catch any missed conversions

**Timing**: 20 minutes

**Depends on**: 4

**Files to modify**:
- `zed-claude-office-guide.md` -- Delete

**Verification**:
- zed-claude-office-guide.md no longer exists
- No file in the repository references zed-claude-office-guide.md
- All information from the guide is present in docs/
- No Ctrl-based user shortcuts remain in docs/
- No LibreOffice references remain in docs/

## Testing & Validation

- [ ] All docs/ files render valid Markdown (no broken syntax)
- [ ] All internal links between docs/ files resolve correctly
- [ ] docs/agent-system.md contains macOS installation, MCP setup, and grant/research commands
- [ ] docs/office-workflows.md contains all workflow recipes from the guide with macOS conventions
- [ ] docs/keybindings.md uses Cmd-based shortcuts throughout
- [ ] No references to zed-claude-office-guide.md remain anywhere in the repo
- [ ] The guide file is deleted
- [ ] No `Ctrl+` shortcuts remain in user-facing documentation (all converted to `Cmd+`)
- [ ] No `LibreOffice` references remain (replaced by Word/Excel)
- [ ] docs/office-workflows.md is under 300 lines (manageable length)

## Artifacts & Outputs

- `docs/keybindings.md` -- Converted from Ctrl to Cmd shortcuts throughout
- `docs/agent-system.md` -- Expanded with installation, MCP setup, and grant/research commands; macOS shortcuts
- `docs/office-workflows.md` -- Expanded with workflow recipes, prompts, OneDrive tips, and troubleshooting; Word/Excel instead of LibreOffice
- `docs/README.md` -- Updated descriptions for macOS focus (if needed)
- `README.md` -- Updated platform references (if needed)
- `zed-claude-office-guide.md` -- Deleted

## Rollback/Contingency

All changes are to tracked files in a git repository. If integration introduces problems:
1. `git checkout -- docs/ README.md zed-claude-office-guide.md` to restore all files
2. The guide file is preserved in git history even after deletion
3. If docs/office-workflows.md exceeds 300 lines, split the new workflow recipes into a separate `docs/office-workflows-advanced.md` file
