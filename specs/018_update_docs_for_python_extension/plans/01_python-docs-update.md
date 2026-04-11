# Implementation Plan: Update docs/ for Python extension

- **Task**: 18 - Update docs/ documentation to reflect newly loaded Python extension
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/018_update_docs_for_python_extension/reports/01_python-extension-docs.md
- **Artifacts**: plans/01_python-docs-update.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: true

## Overview

Add Python extension mentions to the three docs/ files that reference loaded extensions. The Python extension follows the LaTeX/Typst documentation pattern (no custom command, no dedicated workflow guide) so changes are minimal: one bullet in the Extensions list, one name addition plus one routing table row in architecture.md, and a short phrase in the top-level docs/README.md. Research report 01_python-extension-docs.md provides exact change specifications for each file.

### Research Integration

Key findings from the research report:
- Python extension adds 2 agents, 2 skills, 6 context files (ModelChecker framework focus)
- Only 3 docs files need updating; 10+ docs files confirmed to need no changes
- The LaTeX/Typst documentation pattern (minimal mention, no dedicated workflow) is the correct template
- Exact line-level change specifications provided for all 3 files

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add Python to the Extensions bullet list in docs/agent-system/README.md
- Add Python to the extension list and routing table in docs/agent-system/architecture.md
- Add Python to the Agent System description in docs/README.md
- Maintain consistency with how LaTeX/Typst extensions are documented

**Non-Goals**:
- Creating a dedicated Python workflow guide (not needed, uses standard lifecycle)
- Adding a Python command entry to commands.md (no custom command exists)
- Updating context-and-memory.md (generic extension mechanism already covers Python)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Docs files changed since research | L | L | Verify line numbers before editing; use content-matching edits rather than line-based |
| Missing a file that needs updating | L | L | Research report audited all 20+ docs files; low risk of omission |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

Phases within the same wave can execute in parallel.

### Phase 1: Update three docs files [NOT STARTED]

**Goal**: Add Python extension references to all three identified docs files

**Tasks**:
- [ ] Add Python bullet to Extensions section in `docs/agent-system/README.md` (after LaTeX/Typst bullet)
- [ ] Add "python" to the parenthetical extension list in `docs/agent-system/architecture.md` (alphabetical order)
- [ ] Add Python row to the task routing table in `docs/agent-system/architecture.md`
- [ ] Update the "Specialty task types" sentence in `docs/agent-system/architecture.md` to include Python
- [ ] Add "Python" to the Agent System description in `docs/README.md`
- [ ] Verify all edits render correctly and are consistent with LaTeX/Typst pattern

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `docs/agent-system/README.md` - Add 1 bullet to Extensions section
- `docs/agent-system/architecture.md` - Add name to extension list, add routing table row, update specialty sentence
- `docs/README.md` - Add "Python" to Agent System section description

**Verification**:
- grep for "python" (case-insensitive) across all three modified files confirms new content present
- No broken markdown formatting in modified sections
- Python appears in alphabetical order within extension lists

## Testing & Validation

- [ ] All three files contain Python references
- [ ] Python routing table row shows `skill-python-research` and `skill-python-implementation`
- [ ] Extension lists maintain alphabetical ordering
- [ ] No other docs files were modified

## Artifacts & Outputs

- plans/01_python-docs-update.md (this plan)
- summaries/01_python-docs-update-summary.md (after implementation)

## Rollback/Contingency

Changes are additive text insertions in 3 files. Revert by removing the added lines. Git revert of the implementation commit would cleanly undo all changes.
