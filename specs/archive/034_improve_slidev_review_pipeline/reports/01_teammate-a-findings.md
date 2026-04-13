# Teammate A Findings: Implementation Approaches and Patterns

## Key Findings

### 1. Working Configuration Files (Template Source)

The `examples/epi-slides/` project is the canonical working implementation. These four files solve all six issue classes and should be the template basis:

**`package.json`** — pins `@slidev/cli` at `^52.14.2` (not `v0.49`), includes `playwright-chromium` as devDependency, uses `pnpm@9.12.0`, and defines `export`/`export-png`/`dev` scripts.

**`.npmrc`** — single line: `shamefully-hoist=true`. Fixes the pnpm strict layout issue that crashes mermaid slides.

**`vite.config.ts`** — aliases `lz-string` to `./lz-string-esm.js` using `new URL(..., import.meta.url).pathname`. Placed next to `slides.md` (not at project root), because Slidev resolves `vite.config.ts` from the slide file's parent directory (`userRoot`).

**`lz-string-esm.js`** — full LZString source with the UMD footer replaced by explicit ESM exports (`export default LZString; export const compress = ...`). This is a self-contained vendored file, not a generated build artifact.

### 2. Current State of slidev-pitfalls.md

The file at `.claude/context/project/present/talk/patterns/slidev-pitfalls.md` already documents **all six issue classes** from the task description:
- pnpm shamefully-hoist (issue 1)
- lz-string ESM shim (issue 1 / combined)
- Version alignment with `npx slidev` guidance (issue 2)
- Shiki inline code dark background with `!important` override fix (issue 3)
- Vue components in markdown tables — use HTML `<table>` instead (issue 4)
- `\n` not `<br/>` in mermaid node labels (issue 5)
- Playwright verification phase template (comprehensive)

**However**: Issue 6 (`npx slidev` vs `npx @slidev/cli`) is NOT documented in slidev-pitfalls.md. The file says "Use `npx slidev` in Zed tasks and scripts" on line 44 — this is wrong. The correct invocation is `npx @slidev/cli`.

The current line count is 117 (the index.json records 73, which is stale — the file has been updated since the index was last generated).

### 3. Playwright Verification Script Gaps

The current `playwright-verify.mjs` starts the dev server with:
```javascript
spawn('npx', ['slidev', '--port', String(PORT)], ...)
```

This uses `npx slidev` which fails because the npm package is `@slidev/cli` not `slidev`. It should be:
```javascript
spawn('npx', ['@slidev/cli', '--port', String(PORT)], ...)
```

The script already captures `pageerror` console errors (line 67) — so "checking for console errors (not just visible error text)" is already implemented. The gap is the wrong npx invocation.

**Other script gaps**:
- No `--timeout` flag for slow slides
- Uses `cat slides.md` via `execSync` (could accept a `--slides` path argument for non-standard filenames)
- No check for `console.warn` or Vue hydration warnings (only `pageerror`)
- No network error capture (`requestfailed` events)

### 4. How the Implementation Agent Currently Scaffolds Projects

The `slides-agent.md` handles only **research/synthesis** (Stage 1-8: reading source materials, mapping content to slide structure, writing reports). It has no scaffolding logic — it does not create `package.json`, `.npmrc`, `vite.config.ts`, or `lz-string-esm.js`.

The general-implementation-agent handles the actual scaffolding when executing plan phases. The planner-agent creates the plan referencing `slidev-pitfalls.md`. The implementation agent reads `slidev-pitfalls.md` as context during `/implement`.

**Problem**: The implementation agent reads the pitfalls doc but has no concrete template to copy. Each new deck implementation must reconstruct the correct `package.json`, `.npmrc`, `vite.config.ts`, and `lz-string-esm.js` from scratch based on the text in slidev-pitfalls.md. This is error-prone — an agent reading prose instructions may get `package.json` versions wrong.

### 5. Template Directory Does Not Exist

There is currently **one template file**: `playwright-verify.mjs`. There is no `templates/` subdirectory with project scaffolding files. The existing templates/ directory only contains the playwright script.

The proposed deliverable (a Slidev project template directory with package.json, .npmrc, vite.config.ts, lz-string-esm.js) would be new content.

### 6. Context Index Is Stale for slidev-pitfalls.md

The `index.json` records `line_count: 73` for `slidev-pitfalls.md` but the file is now 117 lines. The `summary` and `description` fields also don't reflect the six-issue coverage — they mention "Mermaid scale parameters" (a removed concern) and miss the pnpm/lz-string setup. The index entry needs regeneration.

### 7. Zed Tasks and Export Script Are Already Correct

Both `.zed/tasks.json` and `.zed/scripts/slidev-export.sh` already use `npx @slidev/cli` (verified at lines 21 and 12 respectively). The bug is only in `playwright-verify.mjs` and in the prose of `slidev-pitfalls.md` (line 44 says "Use `npx slidev`").

## Recommended Approach

### A. Create Template Directory

Create `.claude/context/project/present/talk/templates/slidev-project/` with four files copied from `examples/epi-slides/`:
- `package.json` — with `@slidev/cli` version, playwright-chromium devDep, pnpm packageManager
- `.npmrc` — `shamefully-hoist=true`
- `vite.config.ts` — lz-string alias
- `lz-string-esm.js` — full ESM shim (vendored copy)

The implementation agent's plan phase for "scaffold project" should instruct: copy all four files from `.claude/context/project/present/talk/templates/slidev-project/` and customize `name`/`description` in `package.json`.

### B. Update slidev-pitfalls.md

Add one correction:
- Line 44: change "Use `npx slidev`" to "Use `npx @slidev/cli`" — this is factually wrong in the current file and conflicts with the working Zed tasks configuration

The rest of the document is accurate and comprehensive for all six issue classes.

### C. Fix playwright-verify.mjs

Change line 17:
```javascript
// Before (broken):
const server = spawn('npx', ['slidev', '--port', String(PORT)], ...)

// After (correct):
const server = spawn('npx', ['@slidev/cli', '--port', String(PORT)], ...)
```

Optionally add network error capture (`page.on('requestfailed', ...)`) to catch resource load failures that don't trigger `pageerror`.

### D. Update index.json Entry for slidev-pitfalls.md

Update the `line_count`, `summary`, and `description` fields to reflect the current file content.

### E. Add Template Reference to slidev-pitfalls.md or planner context

The slidev-pitfalls.md "Required Final Phase" section should be supplemented with a "Project Scaffolding" section that explicitly tells the implementation agent to copy from the template directory rather than reconstruct from prose.

## Evidence/Examples

**Bug in playwright-verify.mjs**: Line 17 `spawn('npx', ['slidev', ...])` vs working Zed task at `.zed/tasks.json:21` using `['@slidev/cli', ...]`.

**Stale index entry**: `index.json` records `line_count: 73` for `slidev-pitfalls.md` but `wc -l` shows 117 lines.

**Wrong prose in pitfalls doc**: `slidev-pitfalls.md:44` says "Use `npx slidev` in Zed tasks and scripts" but the actual Zed tasks use `npx @slidev/cli`.

**No template directory**: `Glob('.claude/context/project/present/talk/templates/**')` returns only `playwright-verify.mjs` — no project scaffold files exist.

**lz-string-esm.js footer**: The ESM exports section starts after the `return LZString; })();` closing, replacing what would be a UMD footer with `export default LZString` plus named exports. This is the correct pattern for the shim.

**Package version**: `examples/epi-slides/package.json` shows `"@slidev/cli": "^52.14.2"` — this is the working version. The task description mentions a mismatch between "global nix binary (v52)" and "project package.json (v0.49)"; the epi-slides project has already been updated to v52.

## Confidence Level

**High** — All findings are based on direct file reads. The bug in playwright-verify.mjs is confirmed by comparing line 17 to the working Zed task configuration. The template gap is confirmed by globbing the templates directory. The stale index entry is confirmed by comparing line counts.
