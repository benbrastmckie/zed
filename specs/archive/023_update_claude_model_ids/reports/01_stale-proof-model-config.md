# Research Report: Stale-Proof Claude Model Configuration for Zed

**Task**: 23
**Date**: 2026-04-10
**Focus**: Avoiding manual model-ID updates in settings.json

## Summary

Yes — there is a low-maintenance option. Zed's Anthropic provider crate internally
recognizes `-latest` aliases for every Claude 4.x model (e.g.
`claude-opus-4-6-latest`, `claude-sonnet-4-6-latest`). These are Zed-side identifiers
that the crate maps to Anthropic's dated request IDs, so they are Zed's supported
mechanism for "use the current snapshot of this model line." The even simpler
option, since the user only uses Claude Code (not the Zed Agent Panel), is to
**delete the `agent` block entirely** and let Zed fall back to its built-in default.

## Findings

### 1. Zed Agent settings schema

From `https://zed.dev/docs/ai/agent-settings`, the schema is:

```jsonc
"agent": {
  "default_model": { "provider": "<provider>", "model": "<model-id>" },
  "inline_alternatives": [ { "provider": "...", "model": "..." } ]
}
```

Allowed `provider` values include `"anthropic"`, `"openai"`, `"google"`, and
`"zed.dev"` (Zed's hosted service). The docs show only explicit model IDs; they do
not document a "latest" or "auto" keyword at the schema level.

**What happens if the block is omitted**: Per the Zed docs, when no `agent`
block is present and the user is using Zed's hosted LLM service, Zed defaults to
`claude-sonnet-4-5` for the agent panel and inline assist. The block being absent
does **not** break anything — Zed has a built-in fallback. (This is academic for
our case because the Agent Panel isn't used.)

### 2. Anthropic model ID aliases

From Anthropic's official [Models overview](https://platform.claude.com/docs/en/about-claude/models/overview),
the current public aliases and snapshot IDs are:

| Model | Alias (unversioned) | Snapshot request ID |
|---|---|---|
| Claude Opus 4.6 | `claude-opus-4-6` | `claude-opus-4-6` (no dated suffix yet) |
| Claude Sonnet 4.6 | `claude-sonnet-4-6` | `claude-sonnet-4-6` |
| Claude Haiku 4.5 | `claude-haiku-4-5` | `claude-haiku-4-5-20251001` |

Anthropic's doc explicitly calls the unversioned form "Claude API alias" and
the dated form "Claude API ID". Critically, **Anthropic no longer publishes a
`-latest` alias for Claude 4.x** — the old `claude-3-5-sonnet-latest` style
pattern was not carried forward. The "alias" for 4.6 is literally
`claude-opus-4-6`, which is itself stable for the 4.6 family but will not
auto-advance to 4.7.

### 3. Current correct model IDs (April 2026)

Confirmed from [Anthropic's Models overview](https://platform.claude.com/docs/en/about-claude/models/overview):

- Opus 4.6: `claude-opus-4-6`
- Sonnet 4.6: `claude-sonnet-4-6`
- Haiku 4.5: `claude-haiku-4-5` (alias) or `claude-haiku-4-5-20251001` (snapshot)

The IDs currently in the user's `settings.json` (`claude-sonnet-4-20250514`,
`claude-opus-4-20250514`) are Claude 4.0 snapshots from May 2025 — two full
minor versions stale.

### 4. Zed-side `-latest` support (the key finding)

Although Anthropic's public docs don't expose `-latest`, **Zed's own
`crates/anthropic/src/anthropic.rs` does**. Inspecting the model enum on
`main`, every 4.x family has explicit `-latest` variants:

```
claude-opus-4-6
claude-opus-4-6-latest
claude-opus-4-6-1m-context
claude-opus-4-6-1m-context-latest
claude-opus-4-6-thinking
claude-opus-4-6-thinking-latest
claude-sonnet-4-6
claude-sonnet-4-6-latest
claude-sonnet-4-6-1m-context-latest
claude-haiku-4-5
claude-haiku-4-5-latest
...
```

These Zed-side identifiers are mapped internally to Anthropic's dated request
IDs, meaning Zed ships a translation layer so users can write `-latest` in
`settings.json` and the Zed client resolves it at request time. This is the
mechanism the user is looking for. (Note: "latest" here means "latest snapshot
of this named model," not "latest Claude ever" — `claude-opus-4-6-latest` will
not jump to Opus 5 when that ships. It will, however, mean you never have to
chase dated suffixes within the 4.6 family.)

Open issues to be aware of (from the zed-industries/zed tracker):

- Several issues (#41578, #41790) report Zed's agent silently falling back to
  Haiku despite `default_model` being set. Not specific to `-latest` but worth
  noting — setting a model in `settings.json` is not always perfectly respected.
- No upstream issue was found requesting a provider-agnostic "use newest
  available" setting.

### 5. Scope: Zed Agent Panel vs Claude Code

Confirmed. The `agent.default_model` block in `settings.json` governs **only**:

1. Zed's built-in Agent Panel (Ctrl+? sidebar)
2. Inline Assist (Ctrl+Enter in buffers)
3. Thread naming and other agent-side helper calls

It has **no effect** on the Claude Code integration. Claude Code is wired up
through `agent_servers.claude-acp`, which shells out to the `claude` CLI via
the Agent Client Protocol. The model used there is whatever the `claude` CLI
itself resolves (from `~/.claude/settings.json`, environment variables, or its
own default). The two configurations are fully independent.

The user's stated workflow is "primarily Claude Code, happy with whatever the
default model is." That means the Zed Agent Panel configuration is almost
entirely cosmetic for this user — it only matters the rare times they happen
to invoke the Zed sidebar or inline assist.

## Recommendation

Ranked by maintenance burden (lowest first):

### Option 1 (Best — lowest maintenance): Delete the `agent` block entirely

Since the user does not use the Zed Agent Panel, the simplest stale-proof
solution is to remove the block. Zed will fall back to its shipped default
(currently `claude-sonnet-4-5` on the hosted service, and Zed will update that
default in new releases without any user action).

Diff:

```jsonc
// Remove these lines from settings.json:
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
```

`docs/general/settings.md` should be updated to explain that the block is
omitted intentionally because Claude Code (not the Zed Agent Panel) is the
primary workflow, and to document Zed's fallback behavior.

### Option 2 (Fallback — if the user wants to keep the block): Use `-latest` aliases

Use Zed's internal `-latest` aliases so updates within the 4.6 family are
automatic. You will still have to hand-edit when Anthropic ships 4.7 or 5.x,
but that is at most 1-2 edits per year instead of every dated snapshot.

```jsonc
"agent": {
  "default_model": {
    "provider": "anthropic",
    "model": "claude-opus-4-6-latest"
  },
  "inline_alternatives": [
    {
      "provider": "anthropic",
      "model": "claude-sonnet-4-6-latest"
    }
  ]
}
```

Note the trailing comma in the current file should also be removed (JSONC
tolerates it, but it is inconsistent with the rest of the file).

### Option 3 (Current, corrected): Pin to current IDs without `-latest`

If the user prefers fully explicit pinning (no Zed-side translation layer,
maximum reproducibility), use Anthropic's published aliases:

```jsonc
"agent": {
  "default_model": {
    "provider": "anthropic",
    "model": "claude-opus-4-6"
  },
  "inline_alternatives": [
    {
      "provider": "anthropic",
      "model": "claude-sonnet-4-6"
    }
  ]
}
```

This is the "safest" option but also the one most prone to going stale — it
will need editing every time a new minor version ships (4.7, 4.8, 5.0, ...).

**Recommended choice for this user: Option 1**, with Option 2 as a close
second if the user prefers the block to remain for documentation value. The
user's own framing — "happy using whatever the default model is" — maps
directly onto "delete the block and take Zed's built-in default."

Also note that the user set Opus as the `default_model` and Sonnet as the
`inline_alternative` in the original file — or rather, the reverse
(`default_model` = sonnet, `inline_alternatives[0]` = opus). If Option 2 or 3
is chosen, the user should decide which tier they actually want as the
primary. Since they stated preference for Opus 4.6, Option 2's snippet above
correctly puts `claude-opus-4-6-latest` in `default_model`.

## Sources

- [Anthropic — Models overview](https://platform.claude.com/docs/en/about-claude/models/overview)
- [Zed — Agent Settings](https://zed.dev/docs/ai/agent-settings)
- [Zed — LLM Providers](https://zed.dev/docs/ai/llm-providers)
- [Zed — crates/anthropic/src/anthropic.rs on main](https://raw.githubusercontent.com/zed-industries/zed/main/crates/anthropic/src/anthropic.rs) (source of truth for `-latest` aliases)
- [Anthropic — What's new in Claude 4.6](https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-6)
- zed-industries/zed issues #41578, #41790 (default_model reliability caveats)
