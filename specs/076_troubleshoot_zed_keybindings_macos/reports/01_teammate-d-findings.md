# Teammate D (Horizons) Findings: Task #76

**Task**: 76 - Troubleshoot Zed keybindings on macOS and update cheat sheet
**Role**: Strategic/Creative Thinking -- Documentation ecosystem, modifier philosophy, scalability, testing
**Started**: 2026-04-19
**Confidence Level**: High (based on thorough review of existing config, prior task artifacts, and Zed documentation)

## Key Findings

### 1. Cheat Sheet Platform Strategy

The current cheat sheet (`docs/general/keybindings-cheat-sheet.typ`) uses a hybrid approach: most entries show "Ctrl" while 5 entries use "Ctrl/Cmd" notation with a dagger footnote for platform-adaptive bindings. This was introduced in task 56 and is **functional but fragile**.

**Problems with the current approach:**
- The dagger symbol system is easy to miss when scanning quickly. A user on macOS has to mentally translate "Ctrl" to "Ctrl (literal, not Cmd)" for 8 custom bindings and "Ctrl" to "Cmd" for all Zed defaults -- this is cognitively expensive.
- The cheat sheet has a manual sync date comment (line 2: "Synced with keybindings.md and keymap.json on 2026-04-13") which is a warning sign -- manual sync dates go stale.

**Recommended approach -- single adaptive cheat sheet (not separate per-platform):**
- Separate macOS and Linux cheat sheets would double maintenance burden and drift apart quickly. The current config has only 17 custom bindings; the complexity does not justify two documents.
- Instead, improve the notation within the single cheat sheet. Replace the ambiguous "Ctrl" with explicit symbols:
  - Use **Cmd** (or the Apple symbol) for all platform-adaptive bindings on a macOS-targeted sheet
  - Use **Ctrl** only for bindings that are literally Ctrl on macOS (the 8 fixed-ctrl custom bindings)
  - The footer already has the dagger legend; augment it with a color or bold treatment to make the distinction unmissable.

**On auto-generation from keymap.json:**
- Zed does not provide any built-in cheat sheet generation tooling. There is no `zed --dump-keymap` or equivalent.
- A custom script is feasible: parse `keymap.json` (it is valid JSONC), extract binding entries, and emit Typst `#shortcut()` calls. The cheat sheet already uses a clean DSL (`shortcut`, `key-combo`, `chord`, `section`) that maps directly to keymap.json structure.
- **Cost-benefit**: With only 17 custom bindings and ~30 Zed defaults documented, manual maintenance is still viable. Auto-generation becomes worthwhile only if the binding count exceeds ~40 or if frequent keymap changes are expected. A middle ground: add a validation script that compares keymap.json bindings against cheat sheet entries and reports drift, without full generation.

### 2. Documentation Ecosystem -- Single-Sourcing Strategy

Three documents currently exist with overlapping content:

| Document | Format | Purpose | Audience |
|----------|--------|---------|----------|
| `keymap.json` | JSONC | Machine config | Zed runtime |
| `keybindings.md` | Markdown | Narrative guide (FAQ-style) | New users learning Zed |
| `keybindings-cheat-sheet.typ` | Typst (PDF) | Printable quick reference | Daily use at desk |

**Current sync status**: All three were synchronized as of task 59 (2026-04-13). The memory file `MEM-zed-keybindings-scheme.md` serves as a fourth reference for the agent system.

**Single-source-of-truth strategy:**

The ideal architecture is **keymap.json as the canonical source**, with downstream documents derived or validated against it:

```
keymap.json (source of truth)
    |
    +---> validation script (CI or pre-commit)
    |         |
    |         +---> keybindings.md (drift check)
    |         +---> keybindings-cheat-sheet.typ (drift check)
    |
    +---> memory file (MEM-zed-keybindings-scheme.md)
              auto-updated by /learn --task after keymap changes
```

**Practical recommendation**: Rather than full auto-generation (which loses the narrative quality of keybindings.md and the careful layout of the cheat sheet), implement a **drift detector**:
- A script that parses keymap.json custom bindings and checks that each appears in both keybindings.md and the cheat sheet
- Reports missing, extra, or mismatched entries
- Can be run manually or as a pre-commit hook
- Output: "3 bindings in keymap.json not found in cheat sheet: ctrl->, ctrl-<, alt-r"

This preserves the hand-crafted quality of each document while preventing silent drift.

### 3. Modifier Philosophy -- Decision Framework

The existing three-tier modifier scheme (established in task 56) is sound. Here is a formalized decision framework:

```
Should this binding use Cmd on macOS?
    |
    YES --> Does Cmd+key collide with a FATAL macOS default?
    |           |
    |           YES --> Use ctrl- (fixed). Document why.
    |           |       Examples: Cmd+Q (quit), Cmd+H (hide), Cmd+O (open)
    |           |
    |           NO --> Does Cmd+key collide with a USEFUL Zed default?
    |                     |
    |                     YES --> Is your action more valuable than the default?
    |                     |         |
    |                     |         YES --> Use secondary- (override is acceptable)
    |                     |         NO  --> Use ctrl- or alt-
    |                     |
    |                     NO --> Use secondary- (platform-adaptive)
    |
    NO --> Is this a vim-style or terminal-compatible operation?
    |           |
    |           YES --> Use ctrl- (matches vim/terminal muscle memory)
    |           |       Examples: Ctrl+O/I (jump list), Ctrl+H/L (pane nav)
    |           |
    |           NO --> Use alt- (non-conflicting, always available)
    |                   Examples: Alt+J/K (line move), Alt+V (vim toggle)
```

**Modifier tier summary:**

| Tier | Prefix | macOS key | When to use |
|------|--------|-----------|-------------|
| 1. Platform-adaptive | `secondary-` | Cmd | Standard editor operations that should feel native |
| 2. Fixed Ctrl | `ctrl-` | Ctrl | Vim-compatible operations, or when Cmd collides fatally |
| 3. Alt | `alt-` | Option | Custom operations with no standard equivalent |

**Key insight from prior work (task 56)**: The ctrl- tier is not a compromise -- it is a deliberate choice. Bindings like Ctrl+O/I (jump list) and Ctrl+H/L (pane navigation) intentionally match vim conventions. Even if there were no macOS collisions, these bindings arguably *should* be Ctrl because they follow established terminal/vim muscle memory.

### 4. Future Keybinding Scalability

**Current binding budget analysis:**

| Modifier | Used slots | Available single-key slots | Saturation |
|----------|-----------|---------------------------|------------|
| secondary- | 4 | ~20 (most alphabet + punctuation) | ~20% |
| ctrl- | 8 unique | ~15 remaining safe keys | ~35% |
| alt- | 6 | ~20 | ~30% |
| alt-shift- | 2 | ~24 | ~8% |

The current scheme is **nowhere near saturated**. There is ample room for growth.

**Chord bindings -- underutilized opportunity:**

The current config uses exactly one chord: `Ctrl+K V` (markdown preview, a Zed default). Chords provide a massive expansion of the binding namespace:

- A single chord prefix like `Ctrl+K` opens 26+ second-key slots
- Zed supports arbitrary-length chords with a 1-second timeout between keys
- Examples of useful chord namespaces:
  - `Ctrl+K _` for preview/view operations (already partially used by Zed defaults)
  - `Alt+G _` for git operations (Zed uses `Alt+G B` for blame)
  - `Secondary+Shift+_ _` for rarely-used but important operations

**Leader-key patterns:**

Zed does not have a native leader-key concept like vim's `<leader>`. However, chord bindings effectively serve the same purpose:

- In vim mode, space-prefixed chords in `VimControl` context work as a leader key (e.g., `"space space"` for file finder)
- Without vim mode, any rarely-used single key combo can serve as a chord prefix
- **Recommendation**: If the user ever needs more than ~30 custom bindings, designate `Ctrl+,` or `Alt+Space` as a "leader" prefix and build a chord tree under it

**Which-key discovery:**

Zed has an active development discussion around a which-key popup feature (zed-industries/zed Discussion #45181). This feature would show available chord completions after pressing a prefix key, solving the discoverability problem. If/when this ships, chord-heavy keybinding schemes become much more practical.

**Scaling recommendations:**
1. The current 17-binding scheme can grow to ~40 before needing structural changes
2. When growth is needed, expand `alt-shift-` first (only 8% saturated)
3. Beyond ~40 bindings, introduce chord namespaces (e.g., `Alt+G _` for git, `Alt+T _` for terminal/task operations)
4. Monitor the which-key feature -- it will make chords dramatically more usable

### 5. Testing and Verification Strategy

**Primary diagnostic tool: `dev: Open Key Context View`**

Accessible from the command palette, this shows:
- The current context stack (which context guards are active)
- What key bindings are resolved for the current context
- Helps diagnose why a binding is not firing (wrong context) or firing the wrong action (shadowed by a more specific context)

**Keybinding editor: `Cmd+K Cmd+S` (macOS) / `Ctrl+K Ctrl+S`**

Opens Zed's built-in keybinding viewer showing:
- All active bindings (defaults + custom)
- Which bindings are overridden by user keymap
- Search by action name or key combo

**Systematic verification procedure for after any keymap change:**

1. **Quick smoke test** (30 seconds): Press each modified binding and verify the action fires
2. **Context verification**: Test bindings in all declared contexts (Workspace, Editor, Terminal, ProjectPanel)
3. **Conflict detection**: Open `dev: Open Key Context View`, type the key combo, and check that only the intended action is bound
4. **Cross-platform check** (if relevant): The `secondary-` prefix resolves at keymap load time. On macOS, `secondary-?` shows as `Cmd+?` in the keybinding editor. Verify this mapping is correct.

**Automated validation approach:**

A script could parse keymap.json and check for common problems:
- Duplicate key combos in the same context (shadowing)
- `ctrl-` bindings that collide with known macOS system shortcuts
- Missing context declarations (binding in Editor but not Workspace when both are intended)
- Bindings declared in keymap.json but absent from documentation

**Conflict resolution rule in Zed**: When two bindings match the same key in the same context, the one defined **later** in the keymap file wins. User keybindings always load after Zed defaults, so they take precedence. Within the user keymap, later entries override earlier ones.

## Recommended Approach

### Immediate Actions (Task 76 scope)

1. **Fix cheat sheet notation**: On macOS, the cheat sheet should show `Cmd` for platform-adaptive bindings and `Ctrl` for fixed-ctrl bindings. Drop the ambiguous "Ctrl" for everything approach. The dagger footnote can remain but should not be the only distinguishing indicator.

2. **Add platform-detection header**: The cheat sheet could include a Typst variable at the top (`#let platform = "macos"`) that switches notation throughout. This is a one-variable change to flip the entire sheet between platforms if needed.

3. **Document the modifier decision framework** in keybindings.md (the "Adding more shortcuts" section at the bottom is the right place). This helps future-self and any collaborators understand *why* certain bindings use Ctrl vs Cmd.

### Medium-Term Actions

4. **Build a drift-detection script** (`scripts/check-keybinding-sync.sh`) that parses keymap.json and validates entries exist in both keybindings.md and the cheat sheet. Run it after any keymap edit.

5. **Add verification instructions** to keybindings.md: document the `dev: Open Key Context View` and `Cmd+K Cmd+S` tools so the user has a clear diagnostic path when bindings misbehave.

### Long-Term Considerations

6. **Monitor Zed's which-key feature** (Discussion #45181). When it ships, consider restructuring bindings into chord namespaces for better discoverability.

7. **Revisit `ctrl-shift-a` migration** if Terminal SelectAll becomes less important (e.g., if the user primarily uses Claude Code via the agent panel rather than terminal).

## Evidence/Examples

**Cheat sheet ambiguity example**: Line 130 of the cheat sheet shows `key-combo("Ctrl", "P")` for "Open file by name." On macOS, the actual key is Cmd+P. A macOS user reading the printed cheat sheet must mentally translate every "Ctrl" to "Cmd" for Zed defaults, while keeping "Ctrl" as literal for custom bindings like Ctrl+O (jump back). This is the core usability problem.

**Drift detection feasibility**: The keymap.json is clean JSONC with a consistent structure. Each binding block has `"context"` and `"bindings"` keys. A `jq` pipeline (after stripping comments) can extract all custom bindings in under 10 lines of shell script. Cross-referencing against `grep` patterns in keybindings.md and keybindings-cheat-sheet.typ is straightforward.

**Chord namespace example**: If the user wanted to add 5 git-related shortcuts, they could use:
```json
{
  "context": "Workspace",
  "bindings": {
    "alt-g s": "git::OpenStatus",
    "alt-g c": "git::Commit",
    "alt-g p": "git::Push",
    "alt-g l": "git::Log",
    "alt-g d": "git::Diff"
  }
}
```
This uses a single prefix (`Alt+G`) and 5 second keys -- zero collision risk, infinite scalability.

## Appendix

### Sources
- [Zed Key Bindings Documentation](https://zed.dev/docs/key-bindings) -- official modifier reference including `secondary-`
- [Zed All Actions Reference](https://zed.dev/docs/all-actions) -- complete action list for binding targets
- [Which-key menu discussion (zed-industries/zed #45181)](https://github.com/zed-industries/zed/discussions/45181) -- upcoming chord discovery feature
- [Leader key discussion (zed-industries/zed #26818)](https://github.com/zed-industries/zed/discussions/26818) -- community patterns for leader-key bindings
- [Key chord support issue (zed-industries/zed #5260)](https://github.com/zed-industries/zed/issues/5260) -- chord binding implementation details
- Task 56 artifacts -- platform-adaptive migration research and implementation
- Task 59 artifacts -- documentation revision post-task-56

### Binding Budget Table (Full)

| Key | ctrl- status | secondary- status | alt- status |
|-----|-------------|-------------------|-------------|
| A | free | free | free |
| B | free | free (Cmd+B = toggle sidebar) | free |
| C | free | taken (Shift+C = CopyPath) | free |
| D | free | free | free |
| E | free | taken (Shift+E = ToggleLeftDock) | taken (Shift+E = Build PDF) |
| F | free | free | free |
| G | free | free | free |
| H | taken (PaneLeft) | FATAL (Hide app) | free |
| I | taken (GoForward) | SERIOUS (SignatureHelp) | free |
| J | free | free | taken (MoveLineDown) |
| K | free | free | taken (MoveLineUp) |
| L | taken (PaneRight) | SERIOUS (SelectLine) | free |
| M | free | free | free |
| N | free | free | free |
| O | taken (GoBack) | FATAL (Open dialog) | free |
| P | free | free | taken (Shift+P = Preview) |
| Q | taken (CloseTab) | FATAL (Quit app) | free |
| R | free | free | taken (ReloadFile) |
| S | free | free | free |
| T | free | free | free |
| U | free | free | free |
| V | free | free | taken (VimToggle) |
| W | free | free | free |
| X | free | free | free |
| Y | free | free | free |
| Z | free | free | free |
| ? | free | taken (ToggleRightDock) | free |
| Enter | free | taken (OpenFile) | free |
| > | taken (Indent) | SERIOUS (AddToThread) | free |
| < | taken (Outdent) | free | free |
| Shift+A | taken (Claude Code) | RISKY (SplitMenu) | free |
