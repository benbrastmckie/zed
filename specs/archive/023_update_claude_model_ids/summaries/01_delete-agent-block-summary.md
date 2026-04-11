# Implementation Summary: Stale-Proof Claude Model Configuration

**Task**: 23
**Date**: 2026-04-10
**Status**: [COMPLETED]
**Plan**: [01_delete-agent-block.md](../plans/01_delete-agent-block.md)
**Research**: [01_stale-proof-model-config.md](../reports/01_stale-proof-model-config.md)

## Outcome

Deleted the stale `agent` block from `settings.json` and rewrote the corresponding section of `docs/general/settings.md` to explain the intentional omission and document the `-latest` alias pattern as a fallback. The Zed Agent Panel now uses Zed's shipped default model (which updates automatically with Zed releases), eliminating the "stale model ID" maintenance burden entirely. Claude Code -- the user's primary AI workflow -- is unaffected because it is wired via `agent_servers.claude-acp`, which is a completely independent configuration.

## Phases

### Phase 1: Remove `agent` block from `settings.json` [COMPLETED]

Removed lines 35-47 of `settings.json` (the `// Agent (AI) configuration` comment, the `agent` object with its `default_model` and `inline_alternatives` fields, and the trailing comma). File drops from 203 lines to 187.

**Verification**: JSONC parses (`python3` re-parse succeeds); `grep -c 'claude-.*-4-20250514' settings.json` returns 0; `grep -n 'agent' settings.json` confirms only `agent_servers` (Claude Code ACP bridge) remains.

### Phase 2: Update `docs/general/settings.md` [COMPLETED]

Replaced the stale `### Agent (AI) Configuration` section (which showed the two `*-4-20250514` IDs as the canonical example) with a new `### Agent (AI) Configuration (intentionally unset)` section that:

- Explains why the block is omitted (Claude Code is the primary workflow; `agent.*` only governs the Zed Agent Panel and inline assist; Zed's built-in default auto-updates).
- Preserves the "not `assistant` -- that was the old name" note for users migrating from older Zed docs.
- Provides an `#### If you do use the Agent Panel` subsection with a `-latest`-alias snippet (`claude-opus-4-6-latest`, `claude-sonnet-4-6-latest`) for users who want to pin a model line.

**Verification**: No `claude-.*-4-20250514` matches in `docs/general/settings.md`; surrounding sections unchanged.

### Phase 3: Full-tree verification [COMPLETED]

Ran `grep -r 'claude-.*-4-20250514'` across the working tree. All nine remaining matches are in:

- `specs/TODO.md` (task 23's own description text, historical)
- `specs/state.json` (task 23's description field, historical)
- `specs/023_update_claude_model_ids/plans/01_delete-agent-block.md` (the plan itself, shows old IDs as the "before" state)
- `specs/023_update_claude_model_ids/reports/01_stale-proof-model-config.md` (research report citing the old IDs as the problem)
- `specs/reviews/review-20260410.md` (the review that created this task)
- `specs/archive/011_*` (3 files) and `specs/archive/004_*` (1 file) -- historical research reports explicitly excluded by the plan's "Out of Scope" section.

Zero matches in live configuration (`settings.json`, `keymap.json`, `docs/`, `README.md`, `.claude/`). No further cleanup required.

## Files Changed

| File | Change |
|------|--------|
| `settings.json` | -16 lines (agent block + trailing comma removed) |
| `docs/general/settings.md` | -20 / +28 lines (section rewritten) |

## Success Criteria

- [x] `settings.json` contains no `claude-.*-4-20250514` strings
- [x] `docs/general/settings.md` contains no `claude-.*-4-20250514` strings
- [x] `settings.json` parses as valid JSONC
- [x] `docs/general/settings.md` renders cleanly, replacement section reads coherently
- [x] No unrelated changes introduced

## Follow-ups

None. The user's stated preference ("happy with whatever the default model is") is now the actual behavior: Zed's shipped default is what the Agent Panel will use, and Claude Code uses whatever the `claude` CLI resolves (unchanged). No maintenance burden from this configuration going forward.
