# Implementation Plan: Stale-Proof Claude Model Configuration

**Task**: 23
**Date**: 2026-04-10
**Status**: [COMPLETED]
**Estimated effort**: 15 minutes
**Research**: [01_stale-proof-model-config.md](../reports/01_stale-proof-model-config.md)

## Objective

Eliminate the stale Claude model IDs (`claude-sonnet-4-20250514`, `claude-opus-4-20250514`) from `settings.json` and `docs/general/settings.md` in a way that minimizes future maintenance, per the user's stated preference for "whatever the default model is."

## Approach

Adopt **Option 1** from the research: delete the `agent` block from `settings.json` entirely and rely on Zed's built-in default. This block governs only the Zed Agent Panel and inline assist, not Claude Code (which the user actually uses), so removing it has no functional downside and eliminates the entire class of "stale model ID" issues for this configuration.

Documentation in `docs/general/settings.md` is updated in lockstep to (a) replace the stale example with a brief explanation of why the block is intentionally omitted and (b) show the `-latest` alias pattern as a fallback for users who do want to configure the Agent Panel.

## Phases

### Phase 1: Remove `agent` block from `settings.json` [COMPLETED]

**File**: `settings.json`

**Change**: Delete lines 35-47 (the entire `// Agent (AI) configuration` comment header plus the `agent` object and its trailing comma).

Before:
```jsonc
  // Agent (AI) configuration
  "agent": {
    "default_model": {
      "provider": "anthropic",
      "model": "claude-sonnet-4-20250514"
    },
    "inline_alternatives": [
      {
        "provider": "anthropic",
        "model": "claude-opus-4-20250514"
      }
    ],
  },

  // File and project settings
```

After:
```jsonc
  // File and project settings
```

**Verification**:
- Run `python3 -c "import json, re; text=open('settings.json').read(); text=re.sub(r'//[^\n]*','',text); text=re.sub(r',(\s*[}\]])',r'\1',text); json.loads(text); print('valid')"` to confirm JSONC still parses.
- Confirm `grep -c 'claude-.*-4-20250514' settings.json` returns 0.

**Rollback**: Restore the deleted block from git.

### Phase 2: Update `docs/general/settings.md` [COMPLETED]

**File**: `docs/general/settings.md` (current lines ~55-70 contain the stale example)

**Change**: Replace the example showing the `agent` block with explanatory prose plus a `-latest`-alias fallback snippet.

Replace the existing agent-block example (containing `claude-sonnet-4-20250514` / `claude-opus-4-20250514`) with:

````markdown
### Zed Agent Panel model (intentionally unset)

This configuration does **not** set `agent.default_model` in `settings.json`. The `agent` block governs only Zed's built-in Agent Panel (Ctrl+?) and inline assist -- it has no effect on Claude Code (Ctrl+Shift+A), which is the primary AI workflow here. Leaving the block unset lets Zed use its shipped default, which updates automatically with new Zed releases. No manual model-ID maintenance required.

If you do use the Agent Panel and want to pin a specific model, Zed supports `-latest` aliases internally (see `crates/anthropic/src/anthropic.rs` in the Zed source). For example:

```jsonc
"agent": {
  "default_model": {
    "provider": "anthropic",
    "model": "claude-opus-4-6-latest"
  },
  "inline_alternatives": [
    { "provider": "anthropic", "model": "claude-sonnet-4-6-latest" }
  ]
}
```

The `-latest` suffix auto-advances within a named model family (e.g., within 4.6), but will not jump to 4.7 or 5.x without an explicit edit.
````

**Verification**:
- Confirm `grep -c 'claude-.*-4-20250514' docs/general/settings.md` returns 0.
- Visually scan the surrounding section for broken markdown or orphaned references.

**Rollback**: Restore from git.

### Phase 3: Verify and commit [COMPLETED]

- Run full grep across the working tree for the stale IDs: `grep -rn 'claude-.*-4-20250514' --include='*.json' --include='*.md' .` -- should return only matches under `specs/archive/` and `specs/reviews/` (historical artifacts; leave untouched).
- Read back `settings.json` end-to-end to confirm no dangling comma or orphaned section header.
- Commit with message `task 23: complete implementation` per the git-workflow rule.

## Risks and Mitigations

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Deleting the `agent` block breaks Zed startup | Very low | Zed docs confirm the block is optional; fallback is built in. Mitigation: verify Zed launches after the edit (user action). |
| User discovers they actually do use Agent Panel and wants a model set | Low | Research Option 2 (`-latest` alias) is documented in settings.md as the restoration path. |
| Trailing-comma cleanup introduces JSONC parse error | Very low | Phase 1 verification step validates the file parses as JSONC after edit. |
| Stale IDs still referenced elsewhere in the docs/registry | Low | Phase 3 full grep catches any stragglers in non-archive paths. |

## Out of Scope

- Updating stale IDs in `specs/archive/**` reports (historical record; do not rewrite).
- Updating stale IDs in `specs/reviews/review-20260410.md` (this review report -- the IDs appear as the problem statement).
- Any change to `agent_servers.claude-acp` (Claude Code integration; not affected).
- Any change to `~/.claude/settings.json` (user-global Claude CLI config; outside this repo).

## Success Criteria

- `settings.json` contains no `claude-.*-4-20250514` strings.
- `docs/general/settings.md` contains no `claude-.*-4-20250514` strings.
- `settings.json` parses as valid JSONC.
- `docs/general/settings.md` renders as valid markdown and the replacement section reads coherently.
- Git commit created with the standard `task 23: complete implementation` format.
