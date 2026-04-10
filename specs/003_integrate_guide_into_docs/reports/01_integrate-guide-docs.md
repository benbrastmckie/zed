# Research Report: Integrate Guide into Docs

- **Task**: 3 - Integrate zed-claude-office-guide.md into docs/
- **Started**: 2026-04-10T12:00:00Z
- **Completed**: 2026-04-10T12:30:00Z
- **Effort**: 30 minutes
- **Dependencies**: None
- **Sources/Inputs**:
  - `zed-claude-office-guide.md` (315 lines, macOS-oriented beginner guide)
  - `docs/README.md` (11 lines, index)
  - `docs/agent-system.md` (107 lines, AI integration overview)
  - `docs/office-workflows.md` (113 lines, Linux/LibreOffice office workflows)
  - `docs/keybindings.md` (199 lines, keyboard shortcuts)
  - `docs/settings.md` (210 lines, configuration reference)
  - `README.md` (90 lines, project navigation hub)
- **Artifacts**: `specs/003_integrate_guide_into_docs/reports/01_integrate-guide-docs.md`
- **Standards**: report-format.md, artifact-management.md, tasks.md

## Executive Summary

- The guide is a macOS-oriented beginner tutorial written for a non-technical collaborator; the docs/ directory targets a Linux/NixOS user who is already set up.
- Approximately 60% of the guide's content has NO equivalent in docs/ (installation, MCP setup, tool explanations, OneDrive tips, grant/research workflow recipes, cheat sheet).
- Approximately 40% overlaps with docs/ but from a different platform perspective (macOS/Cmd vs Linux/Ctrl, Word vs LibreOffice).
- The guide should NOT be deleted outright -- it contains substantial unique content.
- Recommended approach: extract the unique, platform-agnostic content into docs/, then delete or archive the guide file.

## Context & Scope

The task asks whether `zed-claude-office-guide.md` can be deleted because its content is already covered by `docs/`. This requires a section-by-section comparison of both sources, identifying overlap and gaps.

The guide was written for a macOS collaborator who uses Word/Excel. The docs/ directory was written for the primary user on NixOS Linux using LibreOffice. This platform difference means even "overlapping" content serves different audiences.

## Findings

### Section-by-Section Comparison

#### Guide Part 1: Installation (Lines 19-96)

| Guide Topic | Covered in docs/? | Notes |
|---|---|---|
| Prerequisites (macOS 11+) | No | Platform-specific |
| Open WezTerm | No | Not mentioned anywhere in docs/ |
| Install Homebrew | No | Linux uses nix package manager |
| Install Zed via brew | No | Linux uses nix; docs mention `zeditor` binary |
| Install SuperDoc MCP (`claude mcp add`) | No | `agent-system.md` line 100 notes "MCP context servers are not yet configured" |
| Install openpyxl MCP | No | Same as above |
| Verify MCP installation | No | No MCP verification guidance in docs/ |
| Troubleshooting (Homebrew, MCP, Agent Panel) | No | No troubleshooting section in any docs/ file |

**Verdict**: 0% overlap. Entirely unique content, but macOS-specific.

#### Guide Part 2: Tool Explanations (Lines 98-144)

| Guide Topic | Covered in docs/? | Notes |
|---|---|---|
| What is Zed? | Partially | `agent-system.md` describes Zed agent panel but not "what is Zed" for beginners |
| What is Claude Code? | Partially | `agent-system.md` section 2 covers Claude Code features |
| What is SuperDoc? | No | Not mentioned in docs/ |
| What is openpyxl? | No | Not mentioned in docs/ |
| How They Work Together (workflow diagram) | No | `office-workflows.md` has workflow examples but not this save-edit-reload explanation |
| Limitations | Partially | `agent-system.md` has "Known Limitations" but different items |
| First-Time Setup Note (macOS permissions) | No | macOS-specific |

**Verdict**: ~20% overlap. The beginner-level explanations and MCP tool descriptions are unique.

#### Guide Part 3: Common Workflows (Lines 146-270)

| Guide Topic | Covered in docs/? | Notes |
|---|---|---|
| Workflow 1: Edit Word doc with tracked changes | Yes (partial) | `office-workflows.md` lines 73-78 cover `/edit` but briefly; guide has full step-by-step |
| Workflow 2: Update spreadsheet | No | `office-workflows.md` has `/table` (conversion) but not direct xlsx editing via openpyxl |
| Workflow 3: Batch edit multiple documents | No | Not covered in docs/ |
| Workflow 4: Create new document from scratch | No | `/edit --new` not mentioned in docs/ |
| Workflow 5: Grant writing commands | No | `/grant`, `/budget`, `/funds`, `/timeline`, `/talk` not in docs/ |
| OneDrive/SharePoint tips | No | Not applicable to Linux but useful for macOS collaborator |

**Verdict**: ~15% overlap. The grant/research workflow section (Workflow 5) is substantial unique content that is platform-agnostic.

#### Guide Part 4: Quick Reference (Lines 273-315)

| Guide Topic | Covered in docs/? | Notes |
|---|---|---|
| Daily workflow (3 steps) | No | No equivalent quick-start workflow |
| Cheat sheet table | Partially | `keybindings.md` has a Quick Reference table but different scope |
| Grant/research commands in cheat sheet | No | Not in any docs/ file |
| Useful phrases for Claude | No | Unique prompt examples |

**Verdict**: ~20% overlap. The cheat sheet format and prompt examples are unique.

### Content Unique to the Guide (Not in docs/)

1. **MCP tool setup** (SuperDoc, openpyxl) -- `claude mcp add` commands and verification
2. **MCP tool explanations** -- What SuperDoc and openpyxl do, how they integrate
3. **Save-edit-reload workflow diagram** -- How Claude, SuperDoc, and Word interact
4. **Direct spreadsheet editing** -- Editing .xlsx values via openpyxl (not just conversion)
5. **Batch document editing** -- `/edit path/to/folder/` for multiple files
6. **New document creation** -- `/edit --new` syntax
7. **Grant and research commands** -- `/grant`, `/budget`, `/funds`, `/timeline`, `/talk` with examples
8. **OneDrive sync tips** -- Pausing sync during batch edits
9. **Prompt examples** -- Useful phrases and example prompts for each workflow
10. **Troubleshooting** -- Common issues and fixes

### Content Already Covered in docs/

1. **What Zed is and how to open it** -- README.md and agent-system.md
2. **Agent panel shortcut** -- keybindings.md (Ctrl+? vs Cmd+Shift+?)
3. **Claude Code basic commands** -- agent-system.md (/research, /plan, /implement)
4. **`/edit` command** -- office-workflows.md (brief mention)
5. **`/convert`, `/table`, `/slides`, `/scrape`** -- office-workflows.md
6. **Basic Zed shortcuts** (Cmd+P -> Ctrl+P, Cmd+S -> Ctrl+S) -- keybindings.md

### Platform Divergence

The guide uses macOS conventions (Cmd key, Word, Excel, WezTerm, Homebrew). The docs/ use Linux conventions (Ctrl key, LibreOffice, NixOS, terminal). Merging requires either:
- (A) Making docs/ platform-aware with macOS/Linux variants, or
- (B) Keeping the guide as a separate macOS-specific document

## Decisions

1. The guide cannot simply be deleted -- it contains substantial unique content (MCP setup, grant commands, batch editing, prompt examples).
2. The platform-agnostic content should be integrated into docs/.
3. Platform-specific content (macOS installation, OneDrive tips) should either be kept in a separate file or added as platform variants.

## Recommendations

### Option A: Integrate and Archive (Recommended)

1. **Expand `docs/office-workflows.md`** with:
   - MCP tool setup section (SuperDoc, openpyxl) with both macOS and Linux instructions
   - Save-edit-reload workflow explanation
   - Direct spreadsheet editing workflow
   - Batch document editing workflow (`/edit folder/`)
   - New document creation (`/edit --new`)
   - Prompt examples for each workflow
   - Troubleshooting section

2. **Expand `docs/agent-system.md`** with:
   - Grant and research commands section (`/grant`, `/budget`, `/funds`, `/timeline`, `/talk`) with example prompts
   - Or create a new `docs/research-workflows.md` if the section is large enough to warrant its own file

3. **Add platform notes** to relevant sections (macOS: Cmd, Homebrew, Word; Linux: Ctrl, nix, LibreOffice)

4. **Delete `zed-claude-office-guide.md`** after all content is integrated

### Option B: Keep as Separate Audience Document

Keep `zed-claude-office-guide.md` as a standalone beginner guide for macOS collaborators. Add a link from `README.md` and `docs/README.md`. Only extract the platform-agnostic content (grant commands, prompt examples) into docs/.

### Recommended File Organization (Option A)

```
docs/
├── README.md                # Update index
├── keybindings.md           # No changes needed
├── settings.md              # No changes needed
├── agent-system.md          # Add grant/research commands section
└── office-workflows.md      # Major expansion: MCP setup, all workflows, prompts, troubleshooting
```

### Priority of Content to Integrate

1. **High**: Grant/research commands (`/grant`, `/budget`, `/funds`, `/timeline`, `/talk`) -- completely missing, platform-agnostic
2. **High**: MCP setup (SuperDoc, openpyxl) -- needed for `/edit` to work properly
3. **Medium**: Batch editing and new document creation workflows -- useful recipes
4. **Medium**: Prompt examples and cheat sheet -- practical user value
5. **Low**: macOS installation steps -- only relevant to collaborator
6. **Low**: OneDrive tips -- only relevant to macOS/Windows users

## Risks & Mitigations

- **Risk**: Integrating macOS content into Linux-focused docs could confuse the primary user.
  **Mitigation**: Use clear platform labels (e.g., "On macOS: ..., On Linux: ...") or keep platform-specific installation in a collapsible section.

- **Risk**: `docs/office-workflows.md` could become too long after expansion.
  **Mitigation**: If it exceeds ~200 lines, split into `office-workflows.md` (overview + Linux) and `office-setup-macos.md` (macOS-specific installation and tips).

- **Risk**: The guide references `Cmd+Shift+?` while docs use `Ctrl+?` for the same action.
  **Mitigation**: Standardize on showing both with a "(Cmd on macOS, Ctrl on Linux)" note in shared sections.

## Appendix

### Files Examined
- `/home/benjamin/.config/zed/zed-claude-office-guide.md` (315 lines)
- `/home/benjamin/.config/zed/docs/README.md` (11 lines)
- `/home/benjamin/.config/zed/docs/agent-system.md` (107 lines)
- `/home/benjamin/.config/zed/docs/office-workflows.md` (113 lines)
- `/home/benjamin/.config/zed/docs/keybindings.md` (199 lines)
- `/home/benjamin/.config/zed/docs/settings.md` (210 lines)
- `/home/benjamin/.config/zed/README.md` (90 lines)

### Search Methods
- Direct file reading and line-by-line comparison
- Topic-based cross-referencing between guide sections and docs/ files
