# Research Report: Task #11 — Teammate C (Critic)
# Fix Zed ACP Subagent Invocation to Match Neovim Claude Code Plugin Behavior

**Task**: 11 - fix_zed_acp_subagent_invocation
**Role**: Teammate C — Critic (interrogate problem framing, identify gaps)
**Started**: 2026-04-10T00:00:00Z
**Completed**: 2026-04-10T00:00:00Z
**Effort**: ~1 hour
**Sources/Inputs**: output/test.md, settings.json, ACP package source, skill-implementer/SKILL.md, commands/implement.md

---

## Key Findings

### Finding 1: The ACP adapter IS running Claude Code CLI — but it is the SDK-bundled CLI, not the user's installed `claude` binary

The `@agentclientprotocol/claude-agent-acp` package (`v0.26.0`, authored by Zed Industries) depends on `@anthropic-ai/claude-agent-sdk@0.2.96`. That SDK ships a bundled `cli.js` inside its package directory. The ACP adapter's `claudeCliPath()` function resolves to this bundled CLI:

```js
import.meta.resolve("@anthropic-ai/claude-agent-sdk").replace("sdk.mjs", "cli.js")
```

This is NOT `~/.nix-profile/bin/claude` or any user-installed binary. It is the SDK's own bundled Claude Code CLI, version-pinned to 0.2.96. Consequence: the user's `~/.claude/` settings, keybindings, and project-level `CLAUDE_CODE_*` environment variables do NOT apply unless explicitly forwarded.

### Finding 2: The Task tool (subagent delegation) IS structurally available — but there is no evidence it fired in test.md

Reading all 1,757 lines of `output/test.md` reveals:

- The model used: Bash (jq, ls, grep, date), Read, Write, Edit, git commit
- The model correctly expanded `/implement 9`, read state.json, read the plan, updated status, created files, committed — all phases completed
- **No `Task` tool call appears anywhere in test.md**
- **No `Skill` tool call appears anywhere in test.md**
- **No error message about unavailable tools appears**

The `/implement` command file (`commands/implement.md`) has `allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read, Edit, Glob` in its frontmatter. The `skill-implementer/SKILL.md` has `allowed-tools: Task, Bash, Edit, Read, Write`. These allowed-tools declarations constrain what the command and skill may call, but they do not prevent the command from existing — they only restrict tool availability.

**The critical question**: Did the ACP environment see `Skill` and `Task` as available tools? test.md contains no tool list preamble, no system prompt dump, and no error like "Tool 'Skill' not available." We cannot determine from test.md alone whether Skill/Task were unavailable or simply not invoked.

### Finding 3: The model executed implementation INLINE — correctly matching the GATE IN path, but skipping the Skill delegation stage

Looking at the execution in test.md:

1. Model read state.json, found task 9 `[PLANNED]` — correct GATE IN
2. Model read the plan — correct
3. Model directly updated state.json status to "implementing" — this is the preflight step that `skill-implementer` would normally do
4. Model then created all 4 files and updated README directly — this is what `general-implementation-agent` would do
5. Model committed with `task 9: complete implementation` — correct format

The model replicated the behavior described in `skill-implementer/SKILL.md` and `general-implementation-agent` — but did so inline without spawning any subagent. It "short-circuited" the skill/agent delegation layer.

### Finding 4: The ACP adapter disallows `AskUserQuestion` but does not explicitly disallow `Skill` or `Task`

From `acp-agent.js` line 1028:
```js
const disallowedTools = ["AskUserQuestion"];
```

There is no explicit disallow for `Skill` or `Task`. However, the tools available are controlled by:
```js
const tools = userProvidedOptions?.tools ??
    (params._meta?.disableBuiltInTools === true ? [] : { type: "preset", preset: "claude_code" });
```

The `claude_code` preset is what Claude Code uses. Whether `Skill` and `Task` are in the `claude_code` preset for the SDK version (`0.2.96`) is unknown from the source examined — the `cli.js` is a large minified bundle.

### Finding 5: The `env: {}` in settings.json means `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` is not set

The Zed settings.json ACP config passes `"env": {}`. Team mode (`--team` flag) requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. This env var would not be inherited from the parent shell because it is not set in the user's environment by default. However, `/implement 9` did not use `--team`, so this is not the root cause of the inline execution.

### Finding 6: The model is `claude-sonnet-4-20250514`, not opus

The Neovim setup uses `model: opus` (declared in command frontmatter). The `/implement` command in this repo also declares `model: opus` in frontmatter. The Zed ACP adapter uses `claude-sonnet-4-20250514` from `settings.json`. Whether the ACP adapter respects frontmatter `model:` fields is unknown.

---

## Unvalidated Assumptions

### Assumption A: "The Skill/Agent tools were unavailable in the ACP environment"

**Status**: UNCONFIRMED. test.md shows no error about unavailable tools. The ACP adapter only explicitly disallows `AskUserQuestion`. However, the `Skill` tool in Claude Code is a synthetic tool implemented by the CLI harness, not a built-in API tool. If the bundled CLI version (0.2.96) does not support `Skill` as a tool, it would silently fall back to inline execution rather than error.

**Verification path**: Run `claude --version` via the bundled CLI (`node ~/.npm/_npx/.../claude-agent-sdk/cli.js --version`) and compare to the Neovim plugin's Claude Code version. Check if `Skill` tool appears in tool listings for the SDK version.

### Assumption B: "Neovim's Claude Code plugin uses the same underlying mechanism"

**Status**: UNCONFIRMED. The Neovim Claude Code plugin likely launches the user's installed `claude` CLI binary directly (e.g., from PATH). That binary may be a different version than the SDK-bundled CLI used by the ACP adapter. The two environments may have different tool availability, different `~/.claude/` config loading, and different subagent capabilities.

### Assumption C: "The .claude/ system (commands, skills, agents) is loaded correctly in the ACP environment"

**Status**: PARTIALLY CONFIRMED. The model correctly expanded `/implement 9` and read CLAUDE.md content (evident from it knowing the task structure). So `.claude/commands/` discovery IS working. However, whether it sees `Skill` and `Task` as callable tools is separate from whether it can read `.md` command files.

### Assumption D: "The problem is fixable by changing .claude/ config"

**Status**: UNCERTAIN. If `Skill` and `Task` tools are absent from the bundled CLI's tool set, no change to `.claude/` will fix it. The fix would require either: (a) configuring the ACP adapter to use the user's installed CLI binary, or (b) pinning to a different SDK version, or (c) restructuring the orchestration to avoid using `Skill`/`Task` tools.

### Assumption E: "The result (task 9 completed correctly) is a problem"

**Status**: CONTESTED. Task 9 was implemented correctly — all files created, status updated, commit made. The inline execution produced the correct outcome. The "problem" is architectural (single-agent vs. subagent delegation), not functional. This may matter for: (a) complex tasks needing subagent isolation, (b) opus routing (skill-specific model selection), (c) --team mode requiring TaskCreate.

---

## Questions That Should Be Asked

### Q1: What version of Claude Code CLI does the SDK bundle, and does that version support the `Skill` and `Task` tools?

The `@anthropic-ai/claude-agent-sdk@0.2.96` bundles `cli.js` which is itself a minified Claude Code binary. The `Skill` tool (used for skill delegation) and `Task` tool (used for subagent spawning) were introduced at specific Claude Code versions. If the bundled binary predates these tools, they would not be available.

### Q2: Does the ACP adapter's `claude_code` tool preset include `Skill` and `Task`?

The code shows `tools = { type: "preset", preset: "claude_code" }`. This preset is defined inside the bundled CLI. What tools it includes is opaque without decompiling the minified bundle. This is the single most important question to answer.

### Q3: Is there a way to configure the ACP adapter to use the user's installed `claude` binary rather than the SDK-bundled CLI?

The ACP adapter checks `CLAUDE_CODE_EXECUTABLE` env var first:
```js
process.env.CLAUDE_CODE_EXECUTABLE
    ? { pathToClaudeCodeExecutable: process.env.CLAUDE_CODE_EXECUTABLE }
```

If the user sets `CLAUDE_CODE_EXECUTABLE=/path/to/claude` in the ACP `env:` config, the adapter would use the user-installed binary. This is likely the simplest fix.

### Q4: Does the user-installed `claude` binary support `Skill` and `Task` tools in the current version?

Even if we redirect to the user's binary, we need to confirm that binary supports subagent delegation. Check `~/.nix-profile/bin/claude --version`.

### Q5: Does the Neovim Claude Code plugin actually spawn subagents successfully, or is this assumed?

The problem statement says "Neovim's Claude Code plugin works correctly" but this may mean the slash commands run (rather than being undefined), not necessarily that Skill/Task delegation occurs. Has `/implement` been run in Neovim and confirmed to spawn a `general-implementation-agent` subagent?

### Q6: Does the `model:` frontmatter field in command files work in the ACP environment?

The `/implement` command declares `model: opus`. The ACP adapter has its own model configuration (settings.json `default_model`). Which takes precedence? If the ACP environment ignores frontmatter `model:`, all commands run on sonnet, which may produce different delegation behavior.

### Q7: What does the system prompt look like in the ACP environment?

The ACP adapter's `systemPrompt` construction (line ~1036, not shown in detail) determines what the model knows about available tools. If the system prompt does not list `Skill` and `Task` as available, the model would never attempt to use them.

### Q8: Are there per-session tool grants needed for `Task` and `Skill`?

The ACP adapter has a `canUseTool` callback (line 1056). This may restrict tools based on session state or user permissions. If `Task` or `Skill` require explicit grants that are not provided by default, they would be unavailable.

---

## Evidence / Examples

### Evidence 1: test.md shows no subagent invocation

The entire test.md (1,757 lines) contains tool calls: Bash, Read, Write, Edit, git. No `Task`, `Skill`, `TaskCreate`, `TeamCreate`, or similar tool appears. No error messages about tool availability appear. The absence of error messages is ambiguous — it could mean tools are available but not chosen, or that they are absent from the tool list and therefore not even considered.

### Evidence 2: The ACP adapter is version-pinned to SDK 0.2.96

The package.json shows `"@anthropic-ai/claude-agent-sdk": "0.2.96"`. This is the bundled CLI version. The user may have a newer Claude Code installed. Version skew between the SDK-bundled CLI and the user's installed CLI could explain behavioral differences.

### Evidence 3: The `env: {}` config means no custom env vars are passed

The Zed settings.json `"env": {}` passes no environment variables to the ACP process. Any behavior that depends on env vars (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`, `CLAUDE_CODE_EXECUTABLE`, model overrides) would use defaults from `process.env` inheritance. On NixOS with a login shell, what gets inherited is uncertain.

### Evidence 4: The model completed task 9 correctly — so .claude/ is loading

The model correctly: read state.json structure, found task by project_number, understood the task_type, read the plan, updated status markers, created files matching plan specs, updated README, committed with the right format. This confirms CLAUDE.md and the commands directory are being loaded and interpreted correctly by the ACP environment.

### Evidence 5: The `skill-implementer/SKILL.md` says `allowed-tools: Task`

The skill frontmatter declares `allowed-tools: Task, Bash, Edit, Read, Write`. This means when `skill-implementer` runs, it is supposed to use the `Task` tool to spawn `general-implementation-agent`. If `Task` is not in the tool set available to the skill, the skill would fail or fall through. But the model never invoked the skill at all — it executed inline before reaching the Skill delegation stage.

---

## Confidence Level

| Finding | Confidence |
|---------|-----------|
| ACP uses SDK-bundled CLI, not user's claude binary | High |
| Task tool was not invoked in test.md | Certain |
| Skill tool was not invoked in test.md | Certain |
| Whether Skill/Task are in the claude_code tool preset | Unknown |
| The root cause is tool availability vs. model choice | Unknown (contested) |
| CLAUDE_CODE_EXECUTABLE env var would redirect to user's binary | High |
| The problem is fixable via config without code changes | Moderate |

---

## Reframing the Problem

The problem as stated ("subagent invocation failed") may be a misdiagnosis. The actual observation is: "the model executed inline without using Skill/Task tools." Two distinct hypotheses explain this:

**Hypothesis A (Tool Absence)**: The `claude_code` preset in SDK 0.2.96 does not include `Skill` and `Task` tools. The model cannot invoke them. Inline execution is a forced fallback. Fix: set `CLAUDE_CODE_EXECUTABLE` to the user's newer claude binary.

**Hypothesis B (Model Choice)**: `Skill` and `Task` are available but the model (sonnet) chose to execute inline rather than delegate. This could be because: sonnet is less inclined to delegate than opus; the system prompt or context framing discouraged delegation; or the model's reasoning concluded inline execution was sufficient for a markdown task. Fix: ensure opus model is used, or restructure prompts to make delegation more explicit.

Both hypotheses are consistent with the evidence in test.md. Distinguishing them requires either examining the actual tool list available in a fresh ACP session, or checking whether `Skill` tool calls appear in logs from the same SDK version running in other contexts.

---

## Context Extension Recommendations

- **Topic**: ACP adapter behavior and tool availability
- **Gap**: No documentation in `.claude/context/` covers differences between ACP-based invocation and direct CLI invocation, or which tools are available in each environment.
- **Recommendation**: After root cause is confirmed, create `.claude/context/repo/acp-environment.md` documenting the tool availability differences and any required env var configuration.
