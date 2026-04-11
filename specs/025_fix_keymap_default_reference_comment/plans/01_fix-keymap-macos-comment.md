# Implementation Plan: Task #25

- **Task**: 25 - Fix keymap.json default-reference comment for macOS
- **Status**: [IMPLEMENTING]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: None (review-generated task, no research report)
- **Artifacts**: plans/01_fix-keymap-macos-comment.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: true

## Overview

Rewrite the "ZED DEFAULT REFERENCE" comment block in `keymap.json` (lines 41-115) so that the documented Zed built-in shortcuts use the correct macOS modifier (`Cmd+`) instead of `Ctrl+`. This repository is a macOS-only Zed configuration (confirmed by task 21's completion summary), so the current `Ctrl+`-prefixed reference list is misleading. Custom bindings defined earlier in the file intentionally use `Ctrl+` and must remain documented as `Ctrl+`.

### Research Integration

No research report. The task is a straightforward text edit inside a JSON `//` comment block; correctness is verifiable by reading the Zed macOS default keymap documentation and by matching the four intentional custom `Ctrl+` bindings already present in the active JSON.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found in specs/. This task advances the broader post-task-21 cleanup of the Zed configuration for its macOS-only R/Python + Claude Code framing.

## Goals & Non-Goals

**Goals**:
- Replace `Ctrl+` with `Cmd+` throughout the ZED DEFAULT REFERENCE block (lines 41-115) for all entries that correspond to Zed macOS defaults.
- Preserve `Ctrl+` annotations for the four intentional custom bindings that remain `Ctrl+` on macOS in this config (see "Custom binding exceptions" below).
- Keep non-modifier keys (`F2`, `F12`, `Alt+Left`, `Alt+Right`, `Alt+G B`) unchanged.
- Keep comment formatting (section headers, column alignment, leading `//`) consistent with the current style.
- Leave the active JSON bindings array (lines 1-39) untouched.

**Non-Goals**:
- No changes to any actual keybinding (active JSON objects).
- No changes to the "CUSTOM BINDINGS" header comment block (lines 2-8).
- No addition of new documented shortcuts beyond those currently listed.
- Not folding into task 21 -- task 21 is already [COMPLETED], so this runs standalone.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Flipping a shortcut that is actually `Ctrl+` on macOS in Zed | M | L | Cross-check each entry against Zed macOS default keymap docs during Phase 1; treat any uncertain entry as a discrete review item before committing. |
| Accidentally modifying JSON (outside the comment block) and breaking keymap parsing | H | L | Restrict edits to lines 41-115; after edit, verify the file still parses by opening in Zed or by running a JSON5/JSONC validator; confirm first line is still `[` and last line is still `]`. |
| Ambiguity about which bindings count as "the four intentional Ctrl+ custom bindings" | M | M | Phase 1 explicitly enumerates the custom bindings by re-reading the active JSON; if `ctrl-shift-c` (CopyPath) makes the set five, surface as an open question and prefer documenting all five as `Ctrl+` rather than five as `Cmd+`. |
| Comment column alignment drifts after `Ctrl+` -> `Cmd+` (one-character shorter) | L | H | Re-pad the gap between shortcut and description so that descriptions remain vertically aligned, or accept a single-space shift and apply uniformly. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1    | 1      | --         |

### Phase 1: Rewrite default-reference comment block for macOS [IN PROGRESS]

**Goal**: Replace `Ctrl+` with `Cmd+` in the ZED DEFAULT REFERENCE comment block for all Zed macOS defaults, while preserving `Ctrl+` annotations for intentional custom bindings.

**Tasks**:
- [ ] Re-read `keymap.json` lines 1-40 to enumerate the actual custom bindings defined in the active JSON array (Workspace, Terminal, and Editor contexts). Record the exact `Ctrl+` prefixed bindings that the repo intentionally uses on macOS.
- [ ] Cross-check each line in the ZED DEFAULT REFERENCE block (lines 41-115) against Zed's macOS default keymap. For each entry, decide: flip to `Cmd+`, leave as `Ctrl+` (custom-binding exception), or leave unchanged (non-modifier key).
- [ ] Identify the "Agent / AI" subsection: `Ctrl+Shift+A` is a custom binding (Claude Code launch) and MUST stay `Ctrl+Shift+A`. Verify whether `Ctrl+?`, `Ctrl+N` (new conversation), `Ctrl+Enter` (send message), and `Ctrl+;` (inline assist) are Zed defaults on macOS (likely `Cmd+...`) and flip accordingly; `Ctrl+?` in this repo is a custom binding (ToggleRightDock) and must stay `Ctrl+?`.
- [ ] For each "Custom binding exception" line, append an inline annotation such as `(custom)` so the comment explains why it diverges from the macOS default. Example: `// Ctrl+H           ActivatePaneLeft (custom; see Workspace bindings above)`.
- [ ] Apply the `Ctrl+` -> `Cmd+` edits to lines 47-115 via the Edit tool. Prefer a single replace-block per subsection to keep diffs readable.
- [ ] Re-pad the shortcut column so descriptions remain vertically aligned (the `Cmd+` token is one character shorter than `Ctrl+`, so add one extra space after each flipped shortcut).
- [ ] Save the file. Verify visually that:
  - Line 1 is still `[` and the trailing `]` of the bindings array is intact.
  - No lines outside 41-115 were modified.
  - The four intentional custom `Ctrl+` bindings (`Ctrl+H`, `Ctrl+L`, `Ctrl+?`, `Ctrl+Shift+A`) are still documented as `Ctrl+` with a `(custom)` annotation.
  - If `Ctrl+Shift+C` (CopyPath) is also present in the Editor bindings, either extend the exception list to five or resolve with the user before merging.
- [ ] Run a JSONC-aware validator (e.g., `deno fmt --check` or open in Zed) to confirm the file still parses.

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `keymap.json` - Rewrite lines 41-115 (comment block only); annotate custom-binding exceptions; re-pad alignment.

**Verification**:
- `keymap.json` lines 1-40 are byte-identical to the pre-edit version.
- All Zed macOS default shortcuts in the reference block use `Cmd+` (except `F2`, `F12`, `Alt+...`, and custom-binding exceptions).
- The four intentional custom `Ctrl+` bindings are annotated with `(custom)` and remain `Ctrl+`.
- File still loads in Zed without a parse error.

---

## Testing & Validation

- [ ] Open `keymap.json` in Zed and confirm no parse error banner.
- [ ] Confirm all active bindings still work: `Ctrl+H`/`Ctrl+L` pane nav, `Ctrl+?` toggle right dock, `Ctrl+Shift+A` Claude Code launch, `Alt+J`/`Alt+K` line movers, `Ctrl+Shift+C` copy path.
- [ ] Spot-check 3 flipped entries against Zed macOS default keymap docs to confirm accuracy (e.g., `Cmd+P` file finder, `Cmd+S` save, `Cmd+Shift+P` command palette).
- [ ] Run `git diff keymap.json` and confirm the diff is contained to the comment block (lines 41-115).

## Artifacts & Outputs

- Modified file: `keymap.json` (comment block lines 41-115 rewritten for macOS).
- Summary artifact: `specs/025_fix_keymap_default_reference_comment/summaries/01_fix-keymap-macos-comment-summary.md` (created by `/implement`).

## Rollback/Contingency

- `git checkout -- keymap.json` reverts the single-file edit.
- If `Cmd+` flips introduce uncertainty (e.g., a shortcut turns out not to be a macOS default), revert that specific line only and add a `// TODO: verify macOS default` annotation for follow-up.
- If the custom-binding exception set turns out to be five (including `Ctrl+Shift+C`) rather than four, update the task description via `/revise 25` before committing.
