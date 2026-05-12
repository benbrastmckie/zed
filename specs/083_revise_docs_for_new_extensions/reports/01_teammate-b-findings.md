# Teammate B Findings: Documentation Structure, Balance, and Presentation Quality

**Task**: 83 — Revise documentation to reflect new extensions
**Angle**: Alternative approaches — structural analysis
**Date**: 2026-05-11

## Key Findings

### 1. Extension count is wrong everywhere — "9" should be "10"

The `web` extension exists on disk (`.claude/extensions/web/`) but is completely absent from documentation:
- **README.md** line 3: says "9 shared domain extensions" — should be 10
- **docs/README.md** line 3: "9 domain extensions" — wrong
- **docs/agent-system/README.md** lines 3, 13, 48: "9" x3 — wrong
- **docs/agent-system/extensions.md** line 3: "9 extensions" — wrong
- **README.md** line 239: "9 extensions" — wrong

The `web` extension provides Astro, Tailwind CSS v4, TypeScript, and Cloudflare Pages support. It has its own agents (`web-research-agent`, `web-implementation-agent`), skills, rules, and context files. Zero mentions of it exist in `docs/`.

### 2. Feature matrix in extensions.md is missing the `web` row

The table in `docs/agent-system/extensions.md` (lines 7-17) lists 9 rows. The `web` extension should be added:
```
| **web** | 1.0.0 | Web development with Astro, Tailwind CSS v4, TypeScript, and Cloudflare Pages | `web` |
```

### 3. Toolchain extensions.md is missing `python` and `web` sections

`docs/toolchain/extensions.md` only covers: latex, typst, epidemiology, filetypes, present, memory. It is missing sections for:
- **python** extension (prerequisites: uv, ruff, pytest, mypy)
- **web** extension (prerequisites: Node.js, pnpm)

The file's active extension list (line 9-15) should be updated.

### 4. `/sheet` command is undocumented

The `/sheet` command (XLSX creation, editing, and analysis) exists in the skill system (`skill-sheet`, `sheet-agent`) but:
- Not in `docs/agent-system/commands.md`
- Not in `docs/workflows/edit-spreadsheets.md`
- Not in the README.md Document Tools section
- The edit-spreadsheets workflow only describes raw MCP usage from the Agent Panel, not the structured `/sheet` command

### 5. README mentions languages but not the `web` extension's language

README line 3 lists "language support for Python, R, LaTeX, and Typst" but the web extension adds Astro/TypeScript. Either:
- Add web to the language list
- Or keep the Languages section for toolchain-level support and note web separately in the extensions section

## Structure Analysis

### Well-organized
- **docs/ hierarchy** is clean: general/, agent-system/, toolchain/, workflows/ is a natural split
- **README.md** flows well: Quick Start → How It Works → Languages → Commands → Scenarios
- **Cross-referencing** between docs is thorough — nearly every file has "See also" sections
- **Decision guide** in workflows/README.md is excellent for new users
- **Toolchain docs** consistently use the Check/Install/Verify pattern

### Needs improvement
- **Extension coverage is inconsistent**: epidemiology and filetypes get dedicated workflow docs, dedicated toolchain sections, and README mentions. `web` and `python` extensions get nothing beyond the feature matrix (and web doesn't even get that).
- **docs/agent-system/extensions.md** mixes two concerns: the feature matrix (useful) and system architecture details like naming differences and shared state (less useful for users). The architecture parts could move to architecture.md.
- **edit-spreadsheets.md** is 30 lines and only covers raw MCP tool usage. It should be updated to cover `/sheet` as the primary interface.

## Balance Assessment

### Over-documented
- **Toolchain docs** are proportionally heavy at ~1,200 lines total for 4 languages. Individual tool docs (python.md 338 lines, r.md 272 lines) are comprehensive but this is appropriate given their Check/Install/Verify structure.
- **Office/document workflows** have 4 separate files (edit-word, edit-spreadsheets, convert, tips) — justified given the diverse use cases.

### Under-documented
- **Web extension**: 0 lines of user-facing documentation. Has rich context files but no user docs at all.
- **Python extension**: Listed in feature matrix but no workflow doc, no toolchain/extensions.md section. The existing `docs/toolchain/python.md` covers the language setup but not the extension's agent capabilities.
- **`/sheet` command**: Completely undocumented.
- **Slidev extension**: Listed in feature matrix as a dependency of `present`, has a toolchain doc (`slidev.md`), but no workflow coverage. This may be intentional since it's a utility dependency.

### Proportional (good balance)
- **Epidemiology**: workflow doc + toolchain doc + README mentions — proportional to its complexity
- **Present/grant**: workflow doc + README mentions — appropriate
- **Memory**: workflow doc + commands coverage — good
- **Filetypes/documents**: 4 workflow docs — justified by breadth of features
- **LaTeX/Typst**: toolchain doc + feature matrix — appropriate for their scope

## Recommended Approach

1. **Add `web` extension to all documentation surfaces**:
   - Feature matrix row in extensions.md
   - Toolchain extensions.md section (pnpm, Node.js prereqs)
   - README.md extension count fix (9 → 10)
   - Consider a brief workflow doc or at minimum mention in the agent-system README

2. **Add `python` extension section** to toolchain/extensions.md, linking to existing python.md

3. **Document `/sheet` command**:
   - Add to commands.md in the Documents section
   - Update edit-spreadsheets.md to feature `/sheet` as the primary interface
   - Add to README.md Document Tools table

4. **Fix extension count globally**: Search-replace "9 extensions" to "10 extensions" or use "shared domain extensions" without a number (more future-proof)

5. **Keep existing balance for other extensions** — the current proportional coverage of epi, present, filetypes, memory, latex, typst is appropriate. Don't add docs for their own sake.

## Confidence Level

**High** — findings are based on direct comparison of extension directories against documentation content. The `web` omission and extension count error are factual, not interpretive. The `/sheet` gap is confirmed by grep across all docs.
