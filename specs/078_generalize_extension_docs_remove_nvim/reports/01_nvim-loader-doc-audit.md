# Research Report: Task #76

**Task**: 76 - Generalize extension system documentation to remove nvim loader references
**Started**: 2026-04-19T12:00:00Z
**Completed**: 2026-04-19T12:30:00Z
**Effort**: Small
**Dependencies**: None
**Sources/Inputs**:
- `.claude/context/guides/loader-reference.md` (174 lines)
- `.claude/docs/architecture/extension-system.md` (557 lines)
- `.claude/context/guides/extension-development.md` (253 lines)
- Grep across `.claude/` for Lua/nvim references
- Cross-reference search for incoming links
**Artifacts**:
- `specs/076_generalize_extension_docs_remove_nvim/reports/01_nvim-loader-doc-audit.md`
**Standards**: report-format.md

---

## Executive Summary

- **loader-reference.md** is entirely a Lua API reference (174 lines). Every section contains Lua function signatures, `vim.fn` calls, and source file listings. Recommendation: **delete** rather than rewrite -- the conceptual information it provides is already covered by `extension-system.md`.
- **extension-system.md** contains 11 Lua-specific references concentrated in the Two-Layer Architecture diagram (lines 48-52) and section headers (lines 222, 263, 292, 302, 315). All are easily generalized.
- **extension-development.md** has 2 Lua-specific leaks on lines 126 and 131 (`loader.lua`, `vim.fn.isdirectory()`, `vim.fn.filereadable()`).
- **context-layers.md** has 4 additional Lua references (lines 49-54) that should also be generalized.
- Two files link to `loader-reference.md` and will need link removal if it is deleted.

---

## Context & Scope

Three documentation files were identified as containing references to the nvim Lua extension loader implementation. The goal is to make all extension system documentation implementation-agnostic so it describes *what* each component does without naming Lua files, vim APIs, or Telescope UI.

---

## Findings

### File 1: `.claude/context/guides/loader-reference.md` (174 lines)

**Assessment**: Entire file is a Lua API reference. Every section is implementation-specific.

| Line | Reference | Type |
|------|-----------|------|
| 3 | "Lua extension loader functions" | Lua language |
| 8 | "Public Functions in loader.lua" | Lua source file |
| 12-15 | `function M.{name}(manifest, source_dir, target_dir)` Lua code block | Lua syntax |
| 45 | `vim.fn.filereadable(target_path)` | vim API |
| 54-125 | Full Lua function signatures code block (71 lines) | Lua syntax |
| 129-142 | "Loader Source Files" table listing 8 `.lua` files | Lua source files |
| 135 | `init.lua` | Lua source file |
| 136 | `loader.lua` | Lua source file |
| 137 | `merge.lua` | Lua source file |
| 138 | `state.lua` | Lua source file |
| 139 | `manifest.lua` | Lua source file |
| 140 | `config.lua` | Lua source file |
| 141 | `picker.lua` with "Telescope picker UI" | Lua source file + Telescope |
| 142 | `verify.lua` | Lua source file |
| 146 | "Usage in init.lua" | Lua source file |

**Useful conceptual content that exists elsewhere**: The function-to-category table (lines 19-32) and copy semantics detail (lines 36-48) provide useful reference, but this same information already exists in `extension-system.md` lines 226-258 (the "Loader" section with all 12 functions and their semantics). The load order (lines 150-163) is also documented in `extension-system.md` lines 347-362.

**Decision**: DELETE this file. Reasons:
1. Every line is implementation-specific -- generalization would require a complete rewrite
2. The conceptual content (what each function does, copy semantics, load order) is already documented in `extension-system.md`
3. The file provides value only to someone modifying the Lua loader source code, which is no longer in this repository

### File 2: `.claude/docs/architecture/extension-system.md` (557 lines)

| Line | Exact Text | Proposed Replacement |
|------|-----------|---------------------|
| 47 | `│ (.claude/extensions/lua/)                                       │` | `│ (implementation-specific)                                        │` |
| 48 | `│  init.lua          manager.load() / manager.unload()           │` | `│  Manager          load() / unload() / reload()                  │` |
| 49 | `│  loader.lua        12 copy functions, conflict detection        │` | `│  Loader           12 copy functions, conflict detection          │` |
| 50 | `│  merge.lua         generate_claudemd(), merge_settings(), ...   │` | `│  Merger           generate_claudemd(), merge_settings(), ...     │` |
| 51 | `│  state.lua         extensions.json read/write                   │` | `│  State Tracker    extensions.json read/write                     │` |
| 52 | `│  config.lua        target paths, section prefixes              │` | `│  Config           target paths, section prefixes                │` |
| 222 | `### 2. Loader (loader.lua)` | `### 2. Loader` |
| 224 | `The loader handles all file copy operations. For detailed function signatures and parameters, see [Loader Reference](../../context/guides/loader-reference.md).` | `The loader handles all file copy operations.` (remove link) |
| 263 | `### 3. Merger (merge.lua)` | `### 3. Merger` |
| 292 | `This means \`inject_section()\` and \`remove_section()\` still exist in merge.lua but are **not called** for CLAUDE.md management.` | `This means \`inject_section()\` and \`remove_section()\` still exist in the merger but are **not called** for CLAUDE.md management.` |
| 302 | `### 4. State (state.lua)` | `### 4. State` |
| 315 | `### 5. Config (config.lua)` | `### 5. Config` |
| 318-328 | Lua code block with config preset | Replace with a plain-text or JSON description of the config fields |
| 551 | `- [Loader Reference](../../context/guides/loader-reference.md) - Detailed loader function signatures` | Remove line entirely (file being deleted) |

**Config preset replacement** (lines 318-328): Replace the Lua code block:
```lua
{
  base_dir = ".claude",
  ...
}
```
With a table or JSON representation:
```
| Field | Value | Description |
|-------|-------|-------------|
| `base_dir` | `.claude` | Target base directory |
| `config_file` | `CLAUDE.md` | Generated config file name |
| `section_prefix` | `extension_` | Section ID prefix for tracking |
| `state_file` | `extensions.json` | Extension state tracking file |
| `global_extensions_dir` | `$PROJECT_ROOT/.claude/extensions` | Where extension sources live |
| `merge_target_key` | `claudemd` | Key in merge_targets for CLAUDE.md source |
```

### File 3: `.claude/context/guides/extension-development.md` (253 lines)

| Line | Exact Text | Proposed Replacement |
|------|-----------|---------------------|
| 126 | `The \`copy_context_dirs()\` function in \`loader.lua\` handles two types of entries in \`provides.context\`:` | `The \`copy_context_dirs()\` operation handles two types of entries in \`provides.context\`:` |
| 131 | `The function detects which case applies by checking \`vim.fn.isdirectory()\` first, then falling back to \`vim.fn.filereadable()\` for individual files.` | `The loader detects which case applies by checking whether the path is a directory first, then falling back to checking if it is a readable file.` |

Only 2 lines need changes. The rest of the file is already implementation-agnostic.

### Additional File: `.claude/context/architecture/context-layers.md` (lines 49-54)

| Line | Exact Text | Proposed Replacement |
|------|-----------|---------------------|
| 49 | `Confirmed by code review (2026-03-25) of the extension loader source:` | `Confirmed by code review (2026-03-25) of the extension loader:` |
| 51 | `- \`loader.lua\`: All target paths derive from \`target_dir\` parameter...` | `- **Loader**: All target paths derive from the \`target_dir\` parameter...` |
| 52 | `- \`merge.lua\`: \`append_index_entries\` operates on a \`target_path\` parameter...` | `- **Merger**: \`append_index_entries\` operates on a \`target_path\` parameter...` |
| 53 | `- \`config.lua\`: \`base_dir\` is set to \`.claude\` (or \`.opencode\`)...` | `- **Config**: \`base_dir\` is set to \`.claude\` (or \`.opencode\`)...` |
| 54 | `- Grep for \`.context/\` across all 8 files in the extensions module: zero matches.` | `- Search for \`.context/\` references across the extension loader modules: zero matches.` |

---

## Cross-Reference Analysis (Broken Link Risk)

Files that link to `loader-reference.md` (will break if deleted):
1. **`.claude/docs/architecture/extension-system.md`** line 224 and line 551 -- two links to `../../context/guides/loader-reference.md`
2. **`.claude/context/guides/loader-reference.md`** line 172-173 -- outgoing links (irrelevant if file is deleted)

Files that link to `extension-system.md` (no risk -- file is being edited, not deleted):
- `.claude/docs/docs-README.md` (lines 37, 63)
- `.claude/docs/guides/adding-domains.md` (lines 3, 446, 454)
- `.claude/docs/guides/creating-extensions.md` (lines 3, 117, 245, 709, 716)
- `.claude/context/guides/extension-development.md` (lines 13, 29, 86)
- `.claude/context/repo/project-overview.md` (line 20)
- `.claude/docs/README.md` (lines 136, 201)

Files that link to `extension-development.md` (no risk -- file is being edited, not deleted):
- `.claude/CLAUDE.md` (line 86)

---

## Decisions

1. **DELETE** `loader-reference.md` rather than rewrite -- its content is redundant with `extension-system.md` and is entirely Lua-specific
2. **EDIT** `extension-system.md` -- 14 line-level changes to replace Lua file names with conceptual component names
3. **EDIT** `extension-development.md` -- 2 line-level changes to remove `loader.lua` and `vim.fn.*` references
4. **EDIT** `context-layers.md` -- 4 line-level changes to replace `*.lua` references with component names
5. **REMOVE** links to `loader-reference.md` from `extension-system.md` (2 occurrences)

---

## Recommendations

1. **Phase 1**: Delete `loader-reference.md` and remove its 2 incoming links from `extension-system.md`
2. **Phase 2**: Apply the 14 edits to `extension-system.md` (diagram, headers, config block, link removal)
3. **Phase 3**: Apply the 2 edits to `extension-development.md`
4. **Phase 4**: Apply the 4 edits to `context-layers.md`
5. **Verify**: Run `check-extension-docs.sh` after all edits to catch any remaining references

Total scope: 1 file deletion, ~22 line edits across 3 files.

---

## Risks & Mitigations

- **Risk**: Deleting `loader-reference.md` loses the only detailed function signature documentation
  - **Mitigation**: That documentation is only useful for the Lua loader source code, which is not in this repository. The conceptual information is already in `extension-system.md`.
- **Risk**: `context/index.json` references `loader-reference.md` (confirmed at line 559)
  - **Mitigation**: Remove the index entry for `guides/loader-reference.md` during implementation

---

## Appendix

### Search Queries Used
- `grep -rn "loader\.lua|merge\.lua|init\.lua|state\.lua|config\.lua|picker\.lua|verify\.lua|manifest\.lua|vim\.fn|Telescope|Neovim|<leader>" .claude/ --include="*.md"`
- `grep -rn "loader-reference\.md|extension-system\.md|extension-development\.md" .claude/ --include="*.md"`

### Files Outside Scope (Lua references, not extension-loader-specific)
- `.claude/context/formats/frontmatter.md` line 329 -- mentions `init.lua` in a deny-pattern example (generic, not loader-specific)
- `.claude/context/repo/update-project.md` line 21 -- mentions `init.lua` as a project entry point to look for (generic)
- `.claude/docs/guides/permission-configuration.md` lines 416-417 -- mentions `init.lua` in a deny-pattern example (generic)

These are generic references to `init.lua` as a common project file, not references to the extension loader's `init.lua`. They should NOT be changed.
