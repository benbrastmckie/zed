# Research Report: Task #67

**Task**: 67 - strip_install_script_shortcuts
**Started**: 2026-04-15T00:00:00Z
**Completed**: 2026-04-15T00:15:00Z
**Effort**: small
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `scripts/install/lib.sh`, `scripts/install/install.sh`, all `install-*.sh` scripts
- Codebase: `README.md`, `docs/general/installation.md`, `docs/toolchain/*.md`
**Artifacts**:
- `specs/067_strip_install_script_shortcuts/reports/01_install-script-audit.md`
**Standards**: report-format.md, artifact-management.md

## Executive Summary

- The install system has 6 non-interactive flags: `--dry-run`, `--yes`/`-y`, `--check`, `--only`, `--preset`, and `--help`/`-h`.
- Per the task, `--dry-run` and `--check` are retained; `--yes`/`-y`, `--only`, and `--preset` are removed.
- `--help`/`-h` is informational (not a "non-interactive shortcut") and should be retained.
- Flag parsing is centralized in `lib.sh:parse_common_flags` -- a single edit point for removal.
- The master `install.sh` has additional logic for `--preset`, `--only`, and `--yes` pass-through that must be stripped.
- 9 documentation files reference the removed flags and need updating, plus README.md line 18.

## Context & Scope

The task requires removing all non-interactive shortcuts from the installation script except `--dry-run` and `--check`, then updating documentation accordingly. README.md line 18 must be revised to briefly state what the two retained flags do.

The install system consists of:
- `scripts/install/lib.sh` -- shared library with centralized flag parsing
- `scripts/install/install.sh` -- master wizard dispatcher
- `scripts/install/install-base.sh` -- base tools group
- `scripts/install/install-shell-tools.sh` -- shell utilities group
- `scripts/install/install-python.sh` -- Python group
- `scripts/install/install-r.sh` -- R group
- `scripts/install/install-typesetting.sh` -- typesetting group
- `scripts/install/install-mcp-servers.sh` -- MCP servers group

## Findings

### Complete Flag Inventory

| Flag | Variable | Defined | Action | Verdict |
|------|----------|---------|--------|---------|
| `--dry-run` | `DRY_RUN` | `lib.sh:454` | Print actions without executing | **KEEP** |
| `--check` | `CHECK_MODE` | `lib.sh:456` | Run presence checks only | **KEEP** |
| `--yes`, `-y` | `ASSUME_YES` | `lib.sh:455` | Auto-accept all prompts | **REMOVE** |
| `--only <groups>` | `ONLY_GROUPS` | `lib.sh:457-461` | Comma-separated group list | **REMOVE** |
| `--preset <name>` | `PRESET` | `lib.sh:462-466` | Named group bundles | **REMOVE** |
| `--help`, `-h` | `SHOW_HELP` | `lib.sh:467` | Show help text | **KEEP** (informational) |

### Flag Definitions -- Where Each Is Defined

#### `--yes` / `-y` (REMOVE)

**Definition**: `lib.sh:455` (`--yes|-y) ASSUME_YES=1`)

**Variable initialization**: `lib.sh:79` (`ASSUME_YES=0`)

**References in scripts** (all must be updated):

| File | Line(s) | Usage |
|------|---------|-------|
| `lib.sh:79` | Variable init `ASSUME_YES=0` | Remove |
| `lib.sh:127,135-142` | `prompt_yn` honors `$ASSUME_YES` | Remove ASSUME_YES logic |
| `lib.sh:164,172-173` | `prompt_accept_skip_cancel` honors `$ASSUME_YES` | Remove ASSUME_YES logic |
| `lib.sh:443` | Help text: `--yes, -y` | Remove line |
| `lib.sh:455` | Flag parsing case | Remove case |
| `install.sh:18` | Comment: `--yes, -y` | Remove line |
| `install.sh:46` | Help example: `--only base,python --yes` | Remove example |
| `install.sh:139` | `build_child_args`: passes `--yes` to children | Remove line |
| `install.sh:241` | Comment: "honoring ASSUME_YES" | Update comment |
| `install-base.sh:8` | Comment: `--dry-run --yes --check --help` | Remove `--yes` |
| `install-base.sh:52` | `if [ "$ASSUME_YES" = "0" ]` | Remove guard (always prompt) |
| `install-mcp-servers.sh:30` | Comment: `--dry-run --yes --check --help` | Remove `--yes` |
| `install-mcp-servers.sh:107` | `ASSUME_YES` check | Remove guard |
| `install-r.sh:12` | Comment: `--dry-run --yes --check --help` | Remove `--yes` |
| `install-python.sh:9` | Comment: `--dry-run --yes --check --help` | Remove `--yes` |
| `install-typesetting.sh:9` | Comment: `--dry-run --yes --check --help` | Remove `--yes` |
| `install-typesetting.sh:43` | Comment about `--yes` staying with BasicTeX | Remove comment |
| `install-shell-tools.sh:10` | Comment: `--dry-run --yes --check --help` | Remove `--yes` |

#### `--only <groups>` (REMOVE)

**Definition**: `lib.sh:457-461` (two cases: `--only` with shift and `--only=*`)

**Variable initialization**: `lib.sh:81` (`ONLY_GROUPS=""`)

**References in scripts**:

| File | Line(s) | Usage |
|------|---------|-------|
| `lib.sh:81` | Variable init `ONLY_GROUPS=""` | Remove |
| `lib.sh:445` | Help text: `--only <groups>` | Remove line |
| `lib.sh:457-461` | Flag parsing cases (2 forms) | Remove cases |
| `install.sh:14` | Comment: presets and `--only` | Update comment |
| `install.sh:20` | Comment: `--only <groups>` | Remove line |
| `install.sh:46` | Help example: `--only base,python --yes` | Remove example |
| `install.sh:103` | Comment: `resolve_groups` mentions `--only` | Update |
| `install.sh:112-117` | `resolve_groups`: ONLY_GROUPS branch | Remove branch |
| `install.sh:135` | Comment: "Strips master-only flags (--preset, --only)" | Update |
| `install.sh:240` | `if [ -n "$ONLY_GROUPS" ]` condition | Remove condition |

#### `--preset <name>` (REMOVE)

**Definition**: `lib.sh:462-466` (two cases: `--preset` with shift and `--preset=*`)

**Variable initialization**: `lib.sh:82` (`PRESET=""`)

**References in scripts**:

| File | Line(s) | Usage |
|------|---------|-------|
| `lib.sh:82` | Variable init `PRESET=""` | Remove |
| `lib.sh:446` | Help text: `--preset <name>` | Remove line |
| `lib.sh:462-466` | Flag parsing cases (2 forms) | Remove cases |
| `lib.sh:480-488` | `preset_groups` function | Remove entire function |
| `install.sh:14` | Comment: presets and --only | Update comment |
| `install.sh:21` | Comment: `--preset <name>` | Remove line |
| `install.sh:45` | Help example: `--preset epi-demo --dry-run` | Remove example |
| `install.sh:46` | Help example: `--only base,python --yes` | Remove example |
| `install.sh:48-60` | Help text: Groups and Presets sections | Remove Presets section |
| `install.sh:103-119` | `resolve_groups` function: preset/only branches | Simplify |
| `install.sh:135` | Comment: "Strips master-only flags" | Update |
| `install.sh:234` | Info message mentioning presets | Update |
| `install.sh:240` | `if [ -n "$PRESET" ]` condition | Remove condition |

### Documentation Files Requiring Updates

| File | Line(s) | Current Content | Change Needed |
|------|---------|-----------------|---------------|
| **README.md:18** | L18 | HTML comment listing all shortcuts | Replace with brief `--dry-run` and `--check` descriptions |
| **docs/general/installation.md:33-42** | L33-42 | "Non-interactive shortcuts" section with 7 bullet points | Reduce to 2 bullets: `--dry-run` and `--check` |
| **docs/toolchain/README.md:3** | L3 | Blockquote mentioning `--dry-run`, `--check`, `--yes`, `--help` | Remove `--yes` |
| **docs/toolchain/python.md:7-9** | L7-9 | Three quick-install examples: `--dry-run`, `--check`, `--yes` | Remove `--yes` line |
| **docs/toolchain/r.md:7-9** | L7-9 | Same pattern as python.md | Remove `--yes` line |
| **docs/toolchain/typesetting.md:7-9** | L7-9 | Same pattern | Remove `--yes` line |
| **docs/toolchain/shell-tools.md:7-9** | L7-9 | Same pattern | Remove `--yes` line |
| **docs/toolchain/mcp-servers.md:7-9** | L7-9 | Same pattern | Remove `--yes` line |
| **docs/general/installation.md:43** | L43 | "Each group script ... supports the same flags" | Update to mention only `--dry-run`, `--check`, `--help` |

### README.md Line 18 Analysis

**Current content** (line 18):
```
<!-- Non-interactive shortcuts: `bash scripts/install/install.sh --dry-run` (preview), `--check` (health report), `--preset epi-demo`, `--preset writing`, `--preset everything`, or `--only base,python --yes`. -->
```

This is an HTML comment (hidden from rendered output). The task says to revise it to "briefly state what each of these two retained flags does."

**Recommended replacement for line 18**:
```
Add `--dry-run` to preview every action without installing, or `--check` to print a health report of which tools are present or missing.
```

This should be uncommented (made visible) since it provides useful information about the only two remaining non-interactive options. Alternatively, keep it as a comment if the intent is minimal README surface area.

### Impact on `build_child_args` Function

`install.sh:136-140` builds child arguments to pass to group scripts. Currently passes `--dry-run` and `--yes`. After removal:
- Remove the `ASSUME_YES` pass-through line (139)
- The function becomes simpler: only passes `--dry-run` when set

### Impact on `resolve_groups` Function

`install.sh:104-119` resolves groups from `--preset`, `--only`, or defaults to all. After removing preset and only:
- The function simplifies to just returning `$ALL_GROUPS`
- Could be inlined or kept as a trivial function

### Impact on Non-Interactive Dispatch Path

`install.sh:240-248` has a conditional: if `$PRESET` or `$ONLY_GROUPS` is set, dispatch non-interactively. After removal:
- This entire branch is eliminated
- The wizard always runs interactively (via `interactive_wizard`)
- Exception: `--check` mode already has its own early-exit path (line 219)

### Behavioral Consequence

After this change, the only ways to run the install script will be:
1. `bash install.sh` -- interactive wizard (accept/skip/cancel per group)
2. `bash install.sh --dry-run` -- interactive wizard with dry-run mode (no real actions)
3. `bash install.sh --check` -- non-interactive health report
4. `bash install.sh --help` -- print help and exit

The `--yes` removal means there is no longer a way to auto-accept all prompts. The `--preset`/`--only` removal means there is no way to select a subset of groups non-interactively. This is intentional per the task description.

## Decisions

- `--help`/`-h` is retained as it is informational, not a "non-interactive shortcut" in the sense of the task.
- The `prompt_yn` and `prompt_accept_skip_cancel` functions in lib.sh should have their `ASSUME_YES` branches removed, making them always interactive.
- The `preset_groups` function in lib.sh should be removed entirely.
- README.md line 18 should be revised from an HTML comment listing all shortcuts to visible text describing `--dry-run` and `--check`.

## Risks & Mitigations

- **Risk**: Removing `--yes` breaks any CI or scripted usage of the installer. **Mitigation**: The task description explicitly requires this removal; the install wizard is designed for interactive use on a developer's machine.
- **Risk**: Removing `--preset` makes onboarding slightly harder for new users who want a canned configuration. **Mitigation**: The interactive wizard is straightforward (accept/skip/cancel) and is the recommended path.
- **Risk**: lib.sh `ASSUME_YES` is used by child scripts for `prompt_yn` calls (e.g., opt-in extras like MacTeX, epi bundle). Removing it means these prompts always appear interactively. **Mitigation**: This is the desired behavior -- users should explicitly opt in.

## Appendix

### Files to modify (implementation checklist)

**Scripts** (7 files):
1. `scripts/install/lib.sh` -- remove `ASSUME_YES`, `ONLY_GROUPS`, `PRESET` variables, flag cases, help text, `preset_groups` function, `ASSUME_YES` branches in prompt functions
2. `scripts/install/install.sh` -- remove flag comments, help examples, `build_child_args` `--yes` line, simplify `resolve_groups`, remove preset/only dispatch path, update info messages
3. `scripts/install/install-base.sh` -- remove `--yes` from flag comment, remove `ASSUME_YES` guard
4. `scripts/install/install-shell-tools.sh` -- remove `--yes` from flag comment
5. `scripts/install/install-python.sh` -- remove `--yes` from flag comment
6. `scripts/install/install-r.sh` -- remove `--yes` from flag comment
7. `scripts/install/install-typesetting.sh` -- remove `--yes` from flag comment, remove `--yes` comment on MacTeX line
8. `scripts/install/install-mcp-servers.sh` -- remove `--yes` from flag comment, remove `ASSUME_YES` guard

**Documentation** (7 files):
1. `README.md` -- revise line 18
2. `docs/general/installation.md` -- reduce "Non-interactive shortcuts" section
3. `docs/toolchain/README.md` -- remove `--yes` from blockquote
4. `docs/toolchain/python.md` -- remove `--yes` example
5. `docs/toolchain/r.md` -- remove `--yes` example
6. `docs/toolchain/typesetting.md` -- remove `--yes` example
7. `docs/toolchain/shell-tools.md` -- remove `--yes` example
8. `docs/toolchain/mcp-servers.md` -- remove `--yes` example

### Search queries used
- `Glob: **/install*` -- find all install-related files
- `Grep: --yes|--dry-run|--check|--preset|--only` in `scripts/install/`
- `Grep: --preset|--only.*groups|ASSUME_YES|ONLY_GROUPS` in `*.md` files
- `Grep: --dry-run|--check|--yes|--preset|--only` in `docs/`
- `Grep: --dry-run|--check|--yes|--preset|--only` in `.claude/`
