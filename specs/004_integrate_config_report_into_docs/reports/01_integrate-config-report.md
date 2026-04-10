# Research Report: Integrate config-report.md into docs/

- **Task**: 4 - integrate_config_report_into_docs
- **Started**: 2026-04-10T00:00:00Z
- **Completed**: 2026-04-10T00:00:00Z
- **Effort**: Small (single-pass edits to two docs files + delete one file)
- **Dependencies**: None
- **Sources/Inputs**:
  - /home/benjamin/.config/zed/config-report.md
  - /home/benjamin/.config/zed/README.md
  - /home/benjamin/.config/zed/docs/README.md
  - /home/benjamin/.config/zed/docs/settings.md
  - /home/benjamin/.config/zed/docs/agent-system.md
  - /home/benjamin/.config/zed/docs/office-workflows.md
  - /home/benjamin/.config/zed/docs/keybindings.md
- **Artifacts**: specs/004_integrate_config_report_into_docs/reports/01_integrate-config-report.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Executive Summary

- config-report.md is a dated (2026-04-09) setup snapshot written before docs/ existed; most of its content is already covered better by the current docs/ set, with three categories of unique content worth preserving.
- Unique content to migrate: (1) the external Zed documentation URL table (https://zed.dev/docs/*), (2) the runtime/data directory paths under ~/.local/share/zed/ (extensions, logs, db), and (3) optionally the short Neovim-vs-Zed comparison table.
- The "Current State" snapshot table is stale (reports settings.json missing, vim_mode true, Linux-style paths like /run/current-system/sw/bin/zeditor) and conflicts with the current macOS-focused docs -- must NOT be copied.
- The Setup Steps section is fully superseded by docs/agent-system.md (Installation + MCP Tool Setup) and docs/settings.md, with the current docs being more accurate (VSCode base keymap, no vim mode, agent block not assistant).
- Recommended integration: add a "Reference" section to docs/README.md with the Zed docs URL table, add a "Runtime Data Locations" subsection to docs/settings.md under "Configuration Files", and add the Neovim comparison as an optional subsection in docs/settings.md "Platform Notes". Then delete config-report.md.

## Context & Scope

Task 4 asks for a targeted extraction: pull only the unique, non-stale content out of config-report.md into the docs/ tree, then delete the source file. This report performs the section-by-section comparison needed to safely decide what to move and where. Scope is limited to file contents; no code or setting behavior needs verification.

## Findings

### Section-by-Section Comparison of config-report.md

**1. Header (lines 1-7)** -- Zed Version 0.230.1, platform "macOS (installed via Homebrew)", generated 2026-04-09.
- Status: STALE metadata; the version number is a point-in-time snapshot. Not worth preserving.
- Note: The header claims macOS but line 13 contradicts this with a NixOS-style path `/run/current-system/sw/bin/zeditor`, confirming the file is internally inconsistent.

**2. Current State table (lines 9-22)** -- Claims settings.json missing, keymap.json missing, only html extension installed, Claude Code extension not installed, MCP not configured.
- Status: STALE. docs/settings.md documents an existing settings.json with full sections (theme, base_keymap, agent block, auto_install_extensions including claude-code-extension). docs/agent-system.md documents MCP setup as completed. README.md line 4 states "Standard keybindings (no vim mode)" which contradicts config-report.md's `"vim_mode": true` example.
- Do NOT copy.

**3. Step 1: Create settings.json (lines 25-55)** -- Example JSON with vim_mode:true, assistant block, claude-sonnet-4-6.
- Status: SUPERSEDED and INCORRECT. docs/settings.md has the authoritative reference: base_keymap="VSCode" (no vim mode), block name is `agent` not `assistant`, model is claude-sonnet-4-20250514. The config-report example would actively mislead if copied.
- Do NOT copy.

**4. Step 2: Create keymap.json (lines 58-72)** -- Minimal example with ctrl-shift-/ -> assistant::ToggleFocus.
- Status: SUPERSEDED. docs/settings.md "keymap.json Structure" covers format; docs/keybindings.md covers actual bindings (Scheme A -- 6 bindings, not this example). README.md lines 59-67 documents the current custom set.
- Do NOT copy.

**5. Step 3: Install Claude Code Extension (lines 74-81)** -- Manual install via Ctrl+Shift+X.
- Status: SUPERSEDED. docs/settings.md lists claude-code-extension in auto_install_extensions; README.md says "Extensions install automatically on first launch". Manual install is no longer needed. Keyboard shortcut Ctrl+Shift+X is also Linux-style; macOS would be Cmd+Shift+X.
- Do NOT copy.

**6. Step 4: Configure MCP Servers (lines 83-98)** -- superdoc and openpyxl install commands.
- Status: SUPERSEDED. docs/agent-system.md "MCP Tool Setup" section has the same exact commands with more context (what each tool does, how to verify, troubleshooting reference). config-report.md adds nothing.
- Do NOT copy.

**7. Step 5: Verify Setup (lines 100-104)** -- Open agent panel with Ctrl+Shift+?.
- Status: SUPERSEDED (and Linux shortcut; macOS is Cmd+Shift+?). Covered by docs/agent-system.md "Zed Agent Panel" section.
- Do NOT copy.

**8. Step 6: Add to Dotfiles (lines 107-120)** -- Nix Home Manager symlink example.
- Status: UNIQUE but out-of-scope. This is Nix/Linux-specific content that contradicts the macOS + Homebrew stance of docs/. Task description does not list dotfiles integration as content to preserve.
- Do NOT copy.

**9. Documentation and Reference -> Where Zed Docs Live (lines 124-141)** -- Table of zed.dev/docs URLs.
- Status: UNIQUE and VALUABLE. No file in docs/ provides a centralized table of external Zed documentation URLs. docs/settings.md mentions `https://zed.dev/docs/configuring-zed` only tangentially in comments. This table has 9 rows covering main docs, configuring, key bindings, vim, extensions, assistant, languages, linux, releases.
- COPY to docs/README.md as a new "Reference" section (per task description point 1).
- Minor edits when copying: remove the "Linux-specific" row (not relevant to macOS docs) or label it as "Platform-specific: Linux"; keep "Release notes" row.

**10. Config File Locations table (lines 143-154)** -- Two types of entries mixed:
- Config files (settings.json, keymap.json, themes/, tasks.json, snippets/): ALREADY COVERED by docs/settings.md "Configuration Files" table and docs/README.md "Directory Layout".
- Runtime data paths (`~/.local/share/zed/extensions/`, `~/.local/share/zed/logs/`, `~/.local/share/zed/db/`): UNIQUE. No file in docs/ documents these runtime paths.
- COPY only the runtime data rows to docs/settings.md as a new subsection (per task description point 2).
- Caveat: On macOS, Zed's data directory is typically `~/Library/Application Support/Zed/` rather than `~/.local/share/zed/`. The config-report.md paths reflect Linux XDG conventions. Recommendation: when integrating, note both locations or verify against current Zed docs and use the macOS path. This is a content-accuracy issue the implementation phase must resolve (flag as risk below).

**11. Comparison with Neovim Config table (lines 156-167)** -- 6-row table comparing config format, complexity, plugin mgmt, LSP, key files, AI integration.
- Status: UNIQUE. No other docs/ file has this comparison.
- Value: Useful for readers migrating from nvim (which the parent ~/.config repo uses heavily).
- COPY OPTIONALLY to docs/settings.md (end of file, before "Related Documentation") as a "Comparison with Neovim" subsection, or to docs/README.md "Contents" appendix. Task description lists this as "optional".

**12. Included Files (lines 172-174)** -- Lists config-report.md and zed-claude-office-guide.md as siblings.
- Status: STALE. zed-claude-office-guide.md no longer exists in this location; its content has been absorbed into docs/office-workflows.md.
- Do NOT copy.

### Existing Coverage Map (docs/ files)

| Topic | File | Evidence |
|-------|------|----------|
| Installation (Homebrew, prereqs) | docs/agent-system.md | Lines 7-34 (Prerequisites, Step 1-2) |
| MCP tool install commands | docs/agent-system.md | Lines 108-134 (MCP Tool Setup) |
| settings.json reference | docs/settings.md | Lines 17-129 (all sections) |
| keymap.json format | docs/settings.md | Lines 131-178 |
| Custom keybindings (Scheme A) | README.md, docs/keybindings.md, docs/settings.md | README 59-67; keybindings 1-28; settings 146-159 |
| tasks.json | docs/settings.md | Lines 180-198 |
| Config file paths | docs/settings.md | Lines 5-16 |
| Directory layout | README.md | Lines 32-46 |
| Agent panel usage | docs/agent-system.md, docs/keybindings.md | agent-system 41-73; keybindings 84-155 |
| Claude Code commands | docs/agent-system.md, docs/office-workflows.md | extensive coverage |

### Gaps in docs/ (the unique content)

1. **External Zed documentation URLs** -- no consolidated table anywhere in docs/.
2. **Runtime/data directory paths** (extensions, logs, db) -- no mention of where Zed stores its state outside the config dir.
3. **Neovim vs Zed comparison** -- no migration orientation for nvim users.

## Decisions

- Treat config-report.md as a historical snapshot to be dismantled, not a document to preserve.
- Prefer docs/ content as authoritative wherever the two disagree (e.g., vim_mode, assistant vs agent block name, manual vs auto extension install).
- Do not migrate the Linux-flavored Nix dotfiles section (Step 6); it is off-platform for the current macOS-focused docs.
- The runtime data paths must be converted to macOS conventions before being inserted into docs/settings.md, or the destination section should honestly document both conventions.
- The Neovim comparison table is genuinely useful and low-cost to carry over; recommend including it.

## Recommendations

Prioritized integration plan for the implementation phase:

1. **HIGH -- Add Reference section to docs/README.md** (task point 1)
   - Location: after the existing "Contents" list (after line 10).
   - Heading: `## Reference`
   - Content: Copy the "Where Zed Docs Live" table (config-report.md lines 128-141), relabelled as "External Zed Documentation". Drop the "Linux-specific" row or retain as "Platform guides (Linux)" for completeness.
   - Add a short intro line: "Zed has no bundled manpages; all reference documentation lives online."

2. **HIGH -- Add Runtime Data Locations to docs/settings.md** (task point 2)
   - Location: immediately after the existing "Configuration Files" table (after line 16).
   - Heading: `### Runtime Data Locations` (H3 under "Configuration Files" block) or a new `## Runtime Data Locations` section.
   - Content: three rows (extensions, logs, db) from config-report.md lines 151-153.
   - **Accuracy fix required**: verify macOS path. Use `~/Library/Application Support/Zed/` as primary, mention `~/.local/share/zed/` as the Linux/XDG equivalent. Implementation phase should verify via Zed docs or by checking the running macOS system.

3. **MEDIUM -- Add Neovim Comparison subsection to docs/settings.md** (task point 3, optional)
   - Location: end of file, before "Related Documentation" (insert before line 206).
   - Heading: `## Comparison with Neovim`
   - Content: Copy the 6-row table from config-report.md lines 157-164 plus the one-paragraph commentary on lines 166-167.
   - Light edit: replace "~/.config/nvim/" example with a more generic reference since readers of this repo may or may not use nvim.

4. **HIGH -- Delete config-report.md**
   - After the three integrations above, remove `/home/benjamin/.config/zed/config-report.md`.
   - No references to it exist in README.md or docs/ (verified: README.md lists only docs/* files, and docs/README.md lists only docs/* files).

5. **LOW -- Update repo README.md cross-reference** (only if needed)
   - README.md does not currently mention config-report.md, so no link cleanup is required.
   - Confirm during implementation with a quick grep for "config-report".

## Risks & Mitigations

- **Risk**: Runtime data paths may be wrong for macOS if copied verbatim from the Linux-flavored config-report.md.
  - **Mitigation**: Implementation phase must confirm macOS path (`~/Library/Application Support/Zed/`) before writing; consider documenting both conventions with a platform label.
- **Risk**: External Zed documentation URLs may drift over time (zed.dev could reorganize).
  - **Mitigation**: Introduce the table with a disclaimer line and a link to the docs root for recovery if any subpath breaks.
- **Risk**: Neovim comparison table could read as off-topic in a macOS/Zed reference doc.
  - **Mitigation**: Scope it clearly as a migration aid subsection; leave a short sentence explaining why it is included.
- **Risk**: Accidentally copying stale content (vim_mode, manual extension install) during implementation.
  - **Mitigation**: Implementation plan should reference this report's section-by-section verdicts table explicitly.

## Appendix

### Content classification summary

| config-report.md section | Verdict | Destination |
|---|---|---|
| Header / Zed version | STALE | drop |
| Current State table | STALE | drop |
| Step 1: settings.json example | SUPERSEDED/WRONG | drop |
| Step 2: keymap.json example | SUPERSEDED | drop |
| Step 3: Install Claude Code ext | SUPERSEDED | drop |
| Step 4: MCP servers | DUPLICATE | drop |
| Step 5: Verify setup | DUPLICATE | drop |
| Step 6: Add to dotfiles (Nix) | UNIQUE/off-platform | drop |
| Where Zed Docs Live (URL table) | UNIQUE | docs/README.md Reference |
| Config File Locations: config rows | DUPLICATE | drop |
| Config File Locations: data rows | UNIQUE | docs/settings.md Runtime Data |
| Comparison with Neovim table | UNIQUE | docs/settings.md Comparison (opt.) |
| Included Files | STALE | drop |

### References

- config-report.md: /home/benjamin/.config/zed/config-report.md
- docs/README.md: /home/benjamin/.config/zed/docs/README.md
- docs/settings.md: /home/benjamin/.config/zed/docs/settings.md
- docs/agent-system.md: /home/benjamin/.config/zed/docs/agent-system.md
- docs/office-workflows.md: /home/benjamin/.config/zed/docs/office-workflows.md
- docs/keybindings.md: /home/benjamin/.config/zed/docs/keybindings.md
- Top-level README.md: /home/benjamin/.config/zed/README.md
