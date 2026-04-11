# MCP Server Toolchain

This file documents MCP (Model Context Protocol) servers used by the active `.claude/` extensions in this repository, **in addition to** the two MCP servers already covered in [docs/general/installation.md](../general/installation.md#install-mcp-tools): `superdoc` (`@superdoc-dev/mcp`) for Word editing and `openpyxl` (`@jonemo/openpyxl-mcp`) for spreadsheet editing. Those two remain documented in `installation.md` because they are part of the base install; everything below is optional/per-extension.

## Before you begin

Most of the MCP servers below are launched via `uvx` (ephemeral Python tool runner) or `npx` (ephemeral Node runner). Those prerequisites are covered in:

- [python.md](python.md#uvx-ephemeral-tool-runner) — `uv`/`uvx`
- [docs/general/installation.md](../general/installation.md#install-nodejs) — Node.js / `npx`

> **Network at runtime**: `uvx <tool>` and `npx -y @scope/name@latest` fetch their payload on invocation. In a restricted environment, pre-cache by running each command once while online.

## obsidian-memory (memory vault)

The `memory` extension backs `/learn` and `/research --remember` with a searchable Obsidian vault at `.memory/`. It reaches Obsidian through one of two MCP servers.

Full setup (Obsidian desktop install, plugin install, server selection) is documented in [`.claude/context/project/memory/memory-setup.md`](../../.claude/context/project/memory/memory-setup.md). This section is a pointer and a minimal Check/Verify for readers who have already followed that guide.

### Check

```
claude mcp list | grep -E "obsidian|memory"
```

### Install

Follow the step-by-step in [`.claude/context/project/memory/memory-setup.md`](../../.claude/context/project/memory/memory-setup.md). The short version:

1. Install Obsidian desktop (from [obsidian.md](https://obsidian.md)).
2. Open `.memory/` as an Obsidian vault.
3. Install either the "Claude Code MCP" WebSocket plugin (primary) or the "Local REST API" plugin (fallback).
4. Add the corresponding MCP server entry to `.mcp.json`.

### Verify

```
claude mcp list
```

You should see one of `obsidian-claude-code-mcp` or `obsidian-cli-rest-mcp` listed. Then in Claude Code, running `/learn "test"` should succeed without MCP errors.

## rmcp (R statistical modeling, epidemiology)

The `epidemiology` extension optionally integrates `rmcp` — an MCP server that exposes R statistical modeling via MCP tool calls. Installed as a uvx-runnable tool; requires a working R install at runtime. See [r.md](r.md#rmcp-mcp-server-prerequisite) for the R prereq check.

### Check

```
claude mcp list | grep rmcp
uvx rmcp --help 2>/dev/null && echo "rmcp available"
```

### Install

1. Ensure R is installed (see [r.md](r.md)).
2. Ensure `uvx` is installed (see [python.md](python.md#uvx-ephemeral-tool-runner)).
3. Add to `.mcp.json` (this is set up automatically when the `epidemiology` extension is loaded; the merged `.mcp.json` entry is):

    ```json
    {
      "mcpServers": {
        "rmcp": {
          "command": "uvx",
          "args": ["rmcp"]
        }
      }
    }
    ```

4. Restart Claude Code so it picks up the new server.

### Verify

```
claude mcp list
```

You should see `rmcp` in the list. The full reference is at [`.claude/context/project/epidemiology/tools/mcp-guide.md`](../../.claude/context/project/epidemiology/tools/mcp-guide.md).

## markitdown-mcp (document extraction)

Used by some filetypes workflows as an MCP-wrapped version of the `markitdown` CLI (see [typesetting.md](typesetting.md#markitdown)). Install is analogous — `uvx` runs the server.

### Check

```
claude mcp list | grep markitdown
uvx markitdown-mcp --help 2>/dev/null && echo "markitdown-mcp available"
```

### Install

Add to `.mcp.json`:

```json
{
  "mcpServers": {
    "markitdown": {
      "command": "uvx",
      "args": ["markitdown-mcp"]
    }
  }
}
```

Then restart Claude Code.

### Verify

```
claude mcp list
```

Should show a `markitdown` entry. The filetypes extension's [`mcp-integration.md`](../../.claude/context/project/filetypes/tools/mcp-integration.md) has the authoritative config reference.

## mcp-pandoc (universal conversion)

Wraps Pandoc (see [typesetting.md](typesetting.md#pandoc)) as an MCP server.

### Check

```
claude mcp list | grep pandoc
uvx mcp-pandoc --help 2>/dev/null && echo "mcp-pandoc available"
```

### Install

Add to `.mcp.json`:

```json
{
  "mcpServers": {
    "pandoc": {
      "command": "uvx",
      "args": ["mcp-pandoc"]
    }
  }
}
```

Then restart Claude Code.

### Verify

```
claude mcp list
```

Should show a `pandoc` entry.

## Lean MCP — pruned (decision record)

**Decision (2026-04-10, task 30)**: The Lean MCP server (`lean-lsp-mcp`, referenced in `.claude/settings.json` as `mcp__lean-lsp__*`) was **pruned** from this repository.

**Rationale**:

- `.claude/extensions.json` does not list a `lean` extension. The only references to Lean MCP outside `settings.json` are the two setup/verify scripts (`.claude/scripts/setup-lean-mcp.sh`, `.claude/scripts/verify-lean-mcp.sh`). No active agent, skill, command, or workflow invokes Lean MCP tools.
- Task 21 explicitly reframed this repository as a **macOS Zed IDE for R and Python** work. Lean is a theorem-prover toolchain used in the author's Neovim config repo, not here.
- Keeping a dormant allowlist entry for a tool that cannot be reached is worse than either state: it signals an unmet dependency while providing no benefit.

**What was pruned** (applied in Phase 6 of this task):

- The `mcp__lean-lsp__*` entry was removed from `.claude/settings.json`'s `permissions.allow` array.
- `.claude/scripts/setup-lean-mcp.sh` and `.claude/scripts/verify-lean-mcp.sh` were removed.

**To restore** (if Lean support is later added back to this repo):

1. Re-add `"mcp__lean-lsp__*"` to the `permissions.allow` array in `.claude/settings.json`.
2. Re-add the `lean-lsp-mcp` entry to `.mcp.json`:

    ```json
    {
      "mcpServers": {
        "lean-lsp": {
          "command": "uvx",
          "args": ["lean-lsp-mcp"]
        }
      }
    }
    ```

3. Restore the setup scripts from git history (`git log --diff-filter=D -- .claude/scripts/setup-lean-mcp.sh`) or rewrite them.
4. Add a `lean` entry to `.claude/extensions.json` and load the corresponding extension from the source repo.

## See also

- [docs/general/installation.md](../general/installation.md#install-mcp-tools) — base MCP install (SuperDoc, openpyxl)
- [python.md](python.md#uvx-ephemeral-tool-runner) — `uv`/`uvx` prerequisite
- [r.md](r.md) — R prerequisite for `rmcp`
- [typesetting.md](typesetting.md) — the underlying CLI tools that `markitdown-mcp` and `mcp-pandoc` wrap
- [`.claude/context/project/memory/memory-setup.md`](../../.claude/context/project/memory/memory-setup.md) — obsidian-memory detailed setup
- [`.claude/context/project/epidemiology/tools/mcp-guide.md`](../../.claude/context/project/epidemiology/tools/mcp-guide.md) — rmcp reference
- [`.claude/context/project/filetypes/tools/mcp-integration.md`](../../.claude/context/project/filetypes/tools/mcp-integration.md) — filetypes MCP reference
- [docs/toolchain/README.md](README.md) — toolchain directory index
