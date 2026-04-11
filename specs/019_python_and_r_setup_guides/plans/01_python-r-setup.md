# Implementation Plan: Python and R Setup Guides

- **Task**: 19 - Create Python and R setup guides for macOS
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: Task 15 (installation.md improvements, completed)
- **Research Inputs**: specs/019_python_and_r_setup_guides/reports/01_python-r-setup.md
- **Artifacts**: plans/01_python-r-setup.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Create two new language-specific setup guides (`docs/general/python.md` and `docs/general/R.md`) that walk macOS users through installing interpreters, linters, formatters, and LSP tooling for Python and R development in Zed. Update `docs/general/installation.md` to reference both guides. All content follows the Check/Install/Verify pattern and beginner-friendly tone established in installation.md. Done when both guides are complete, installation.md links to them, and a reader can follow each guide end-to-end on a fresh macOS system.

### Research Integration

Key findings from the research report:
- The user's NixOS dotfiles confirm the exact toolset: Python 3.12 + ruff + uv + pyright (bundled by Zed), R + languageserver + lintr + styler
- Zed `settings.json` already configures Python (pyright + ruff LSP) and R (r-language-server) with auto-install extensions
- On macOS, all Python tools install via Homebrew; R packages (languageserver, lintr, styler) must be installed from within R via `install.packages()`
- Ruff replaces black, isort, flake8, and pylint; pyright is bundled by Zed's Python extension (no separate install)
- Custom `.Rprofile` startup messages can break the R language server -- needs a troubleshooting note

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Create `docs/general/python.md` with complete Python dev environment setup for macOS
- Create `docs/general/R.md` with complete R dev environment setup for macOS
- Update `docs/general/installation.md` with brief mention at top and full links at bottom
- Follow the Check/Install/Verify pattern from installation.md
- Cover: interpreter, package manager (uv for Python), linter, formatter, LSP, Zed configuration
- Maintain beginner-friendly tone consistent with installation.md

**Non-Goals**:
- Do not cover Linux/NixOS setup (these are macOS-only guides)
- Do not modify Zed settings.json (configuration is already in place)
- Do not create guides for other languages
- Do not cover advanced topics like virtual environments, project scaffolding, or CI/CD

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Tool version changes invalidate install commands | M | M | Use generic `brew install` without pinned versions; note that exact version numbers may differ |
| basedpyright vs pyright naming confusion | L | M | Explain in guide that Zed bundles basedpyright (a pyright fork) and existing settings work for both |
| R package compilation failures on macOS | M | L | Reference Xcode CLT section from installation.md as prerequisite |
| Tone/structure drift from installation.md | M | L | Phase 1 establishes template from installation.md patterns before writing content |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Create python.md [COMPLETED]

**Goal**: Write the complete Python setup guide following installation.md patterns.

**Tasks**:
- [ ] Create `docs/general/python.md` with front matter and introduction
- [ ] Write "Before you begin" section noting prerequisites (Homebrew, Xcode CLT from installation.md)
- [ ] Write "Install Python" section with Check/Install/Verify pattern (`brew install python`)
- [ ] Write "Install uv" section with Check/Install/Verify pattern (`brew install uv`), explain as modern pip replacement
- [ ] Write "Install ruff" section with Check/Install/Verify pattern (`brew install ruff`), explain it replaces black/isort/flake8
- [ ] Write "Zed configuration" section explaining auto-install extensions, pyright for type checking, ruff for linting/formatting; show relevant settings.json snippets for reference
- [ ] Write "Optional tools" section covering pytest and ipython (install via uv or pip)
- [ ] Write "Verify in Zed" section: open a .py file, confirm diagnostics and format-on-save work
- [ ] Write "See also" section linking back to installation.md

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `docs/general/python.md` - New file, complete Python setup guide

**Verification**:
- File exists and follows Check/Install/Verify pattern
- All sections from research recommendations are present
- Tone matches installation.md (beginner-friendly, no jargon without explanation)

---

### Phase 2: Create R.md [COMPLETED]

**Goal**: Write the complete R setup guide following installation.md patterns.

**Tasks**:
- [ ] Create `docs/general/R.md` with front matter and introduction
- [ ] Write "Before you begin" section noting prerequisites (Homebrew, Xcode CLT from installation.md)
- [ ] Write "Install R" section with Check/Install/Verify pattern (`brew install r`)
- [ ] Write "Install R packages" section: open R console, `install.packages()` for languageserver, lintr, styler -- explain each package's purpose
- [ ] Write "Zed configuration" section explaining auto-install R extension, r-language-server for diagnostics and formatting; show relevant settings.json snippets for reference
- [ ] Write "Troubleshooting" section with `.Rprofile` warning (custom startup messages break the language server)
- [ ] Write "Verify in Zed" section: open a .R file, confirm diagnostics and format-on-save work
- [ ] Write "See also" section linking back to installation.md

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `docs/general/R.md` - New file, complete R setup guide

**Verification**:
- File exists and follows Check/Install/Verify pattern
- R package installation uses `install.packages()` syntax (not Homebrew)
- Troubleshooting section addresses .Rprofile issue
- Tone matches installation.md

---

### Phase 3: Update installation.md with links [NOT STARTED]

**Goal**: Add references to the new language guides in installation.md.

**Tasks**:
- [ ] Add a brief note near the top of installation.md (after the quick-start block, before "Before you begin") mentioning that language-specific setup guides are available
- [ ] Add links to `python.md` and `R.md` in the "See also" section at the bottom of installation.md
- [ ] Verify all relative links resolve correctly

**Timing**: 15 minutes

**Depends on**: 1, 2

**Files to modify**:
- `docs/general/installation.md` - Add language guide references at top and bottom

**Verification**:
- Brief mention appears early in the document without disrupting flow
- "See also" section includes working links to both guides
- No existing content is removed or broken

---

### Phase 4: Final review and consistency check [NOT STARTED]

**Goal**: Verify all three files are consistent in tone, structure, and cross-references.

**Tasks**:
- [ ] Re-read all three files end-to-end for tone consistency
- [ ] Verify all cross-links between files work (installation.md -> python.md, installation.md -> R.md, python.md -> installation.md, R.md -> installation.md)
- [ ] Confirm Check/Install/Verify pattern is used consistently in both guides
- [ ] Verify no duplicate content between the guides and installation.md
- [ ] Check that Zed settings.json snippets shown in guides match the actual settings

**Timing**: 30 minutes

**Depends on**: 3

**Files to modify**:
- `docs/general/python.md` - Minor fixes if needed
- `docs/general/R.md` - Minor fixes if needed
- `docs/general/installation.md` - Minor fixes if needed

**Verification**:
- All cross-references resolve
- Consistent terminology across all three files
- A new user could follow either guide from start to finish without confusion

## Testing & Validation

- [ ] Each Check/Install/Verify section has all three sub-sections with correct commands
- [ ] `brew install` commands are correct for each tool (python, uv, ruff, r)
- [ ] R package install commands use `install.packages()` syntax
- [ ] Zed extension auto-install is mentioned (users do not need to manually install extensions)
- [ ] All relative links between the three files work
- [ ] No sensitive information or user-specific paths are included
- [ ] Tone is consistent with installation.md (beginner-friendly, explains jargon)

## Artifacts & Outputs

- `docs/general/python.md` - Complete Python setup guide for macOS
- `docs/general/R.md` - Complete R setup guide for macOS
- `docs/general/installation.md` - Updated with language guide references
- `specs/019_python_and_r_setup_guides/plans/01_python-r-setup.md` - This plan

## Rollback/Contingency

Revert is straightforward: delete `docs/general/python.md` and `docs/general/R.md`, then undo edits to `docs/general/installation.md` via `git checkout docs/general/installation.md`. No other files are modified.
