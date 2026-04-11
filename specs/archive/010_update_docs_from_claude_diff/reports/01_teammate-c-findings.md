# Teammate C (Critic) Findings: Task 10

**Task**: 10 - Update docs/ from .claude/ diff
**Role**: Critic - stress-test the primary approach
**Started**: 2026-04-10
**Sources**: git status/log/diff, docs/ tree, .claude/ tree, scripts inspection

## Key Findings

1. **There is no `main` branch.** The repo's default branch is `master`. The delegation prompt (and most gh/PR tooling) assumes `main..HEAD`, which errors out (`ambiguous argument 'main..HEAD'`). Any teammate scoping the diff against `main` will either produce no output or silently skip.

2. **The working tree has no commit boundary for "the diff".** HEAD is `01d79a4 task 10: create update docs from claude diff` -- the task creation commit. All 50 .claude/ changes are **uncommitted, staged or unstaged**, sitting on master. There is no "PR" or branch to diff against. The correct diff is `git diff HEAD -- .claude/` for modifications and `git ls-files --others --exclude-standard .claude/` for new files. Teammate A must use `HEAD`, not `main`.

3. **`/talk` command was DELETED and `/slides` was REPURPOSED to replace it.** This is the single biggest doc-impacting change and it is NOT a simple rename -- the former `/slides` semantics (PPTX -> Beamer/Polylux/Touying conversion) has been absorbed into `/convert --format`. Every mention of `/slides` and `/talk` in docs/ is wrong or misleading and requires narrative rewriting, not just find-and-replace.

4. **`ROAD_MAP.md` was globally renamed to `ROADMAP.md`.** Docs still reference `ROAD_MAP.md` in at least `docs/workflows/agent-lifecycle.md:87` and `docs/agent-system/commands.md:82`. This is low-effort but easy to miss with a sloppy cataloging pass.

5. **`Co-Authored-By` trailer was removed from the commit convention**, but `docs/agent-system/architecture.md:58` still shows an example commit message with the trailer. This directly contradicts the new CLAUDE.md rule.

6. **`docs/agent-system/context-and-memory.md` refers to `.claude/extensions/*/context/`, but `.claude/extensions/` does not exist** in this repo. Extensions are managed via the flat `.claude/extensions.json` registry. This is pre-existing stale documentation that teammates may not catch because it's not in the diff -- but the diff to `extensions.json` (570 lines) makes it timely to fix.

7. **`.claude/scripts/check-extension-docs.sh` cannot run in this repo.** The script hard-exits with `ERROR: $EXT_DIR does not exist` because `.claude/extensions/` is absent. Any plan that proposes running it as a validation step for this task will fail. It is also a **new untracked file** the naive cataloger may miss.

## Scope Ambiguities (and recommended resolution)

| Ambiguity | Resolution |
|---|---|
| `master` vs `main` | Use `master` (or just `HEAD`). There is no `main` in this repo. |
| Committed vs staged vs unstaged | Include all uncommitted work (`git diff HEAD`, `git status`, plus `ls-files --others --exclude-standard`). The task commit itself only added the task directory, not content. |
| Backup files (`.claude/CLAUDE.md.backup`, `.claude/settings.local.json.backup`, `.claude/context/index.json.backup`) | **Ignore for doc updates.** They are WIP snapshots. Explicitly note this in the plan so the implementer doesn't get confused. Recommend adding them to `.gitignore`. |
| `.claude/scripts/setup-lean-mcp.sh`, `verify-lean-mcp.sh` | Untracked scripts unrelated to extension docs. Should likely be added to a neovim/lean-lsp docs section, but that's orthogonal to this task. Flag and defer. |
| `.claude/scripts/check-extension-docs.sh` | Untracked. Mentioned in CLAUDE.md diff as "Utility Scripts". Should be documented in both `.claude/docs/` and (maybe) `docs/` but only if users run scripts manually. See risk #7. |
| `specs/tmp/*` modified files | Runtime state, ignore. |

**Recommended diff scope for the implementer**:
```bash
git diff HEAD -- .claude/     # modifications
git ls-files --others --exclude-standard .claude/   # new files, filter .backup
# IGNORE: *.backup, settings.local.json.backup, index.json.backup
```

## Hidden Coupling / Out-of-Scope Documentation

**There are at least FIVE places that document `.claude/` behavior, not just `docs/`:**

1. `/home/benjamin/.config/zed/docs/` -- the task's target
2. `/home/benjamin/.config/zed/.claude/docs/` -- an **independent** doc tree (different audience: system builders, not users), also modified in the diff (`README.md`, `guides/creating-commands.md`, `guides/creating-extensions.md`, `guides/user-guide.md`, `templates/*`)
3. `/home/benjamin/.config/zed/.claude/README.md` -- modified in the diff
4. `/home/benjamin/.config/zed/.claude/CLAUDE.md` -- the source-of-truth config file, modified in the diff (it is the "spec" `docs/` describes)
5. `/home/benjamin/.config/CLAUDE.md` (repo-parent) -- the outer project index; links to `.claude/CLAUDE.md`

**The two docs/ trees are NOT the same thing:**
- `docs/` (14 files) is user-facing: installation, Zed integration, workflows, command usage
- `.claude/docs/` (25 files) is system-builder-facing: architecture, creating-agents.md, extension-slim-standard.md, templates

The task says "the documentation in /home/benjamin/.config/zed/docs/" so `.claude/docs/` is **out of scope** -- but Teammate B's catalog MUST explicitly state this, and the plan should confirm which of the two the user intends. Several modified .claude/docs/ files (e.g. `creating-commands.md` +383 lines, `agent-template.md` +415 lines, `command-template.md` +144 lines) could plausibly have been the target if the user forgot the `.claude/` prefix.

**Ask the user** before assuming `docs/` is the only target.

## Assumptions That Need Validation

1. **Assumption**: "The diff is only .claude/*." -- But CLAUDE.md at the parent (`~/.config/CLAUDE.md`) and `.claude/README.md` also describe the system. Validate whether those need to stay in sync with docs/.
2. **Assumption**: "ROADMAP vs ROAD_MAP is just a rename." -- Check if `specs/ROADMAP.md` actually exists or if this is aspirational. If it doesn't exist, docs referencing it are doubly stale.
3. **Assumption**: "All skill-agent-mapping additions are documented upstream." -- New entries `skill-reviser`, `skill-spawn`, `skill-orchestrator`, `skill-git-workflow`, `skill-fix-it` need to be cross-checked against `docs/agent-system/commands.md` and `docs/workflows/`.
4. **Assumption**: "Team mode docs are correct." -- `skill-team-research/plan/implement` had 25-27 line additions each. Docs reference `--team` at a high level; need to verify nothing material (e.g., new flags, token cost estimates, new teammate roles) changed.
5. **Assumption**: "Backup files are noise." -- But `.claude/CLAUDE.md.backup` suggests the user is mid-edit on CLAUDE.md. The implementer should confirm CLAUDE.md is in its intended final state before regenerating docs from it.
6. **Assumption**: "talk-agent.md is obsolete because /talk is gone." -- But `talk-agent.md` still exists in `.claude/agents/`, is still listed in `extensions.json`, and is referenced by `skill-talk`. The subsystem was reshuffled, not removed. Docs should describe the new chain: `/slides` -> `skill-talk` -> `talk-agent`.

## Known Risks & Traps

1. **Broken relative links.** `docs/agent-system/commands.md:330` links to `../../.claude/commands/talk.md`, which no longer exists. A naive find-and-replace from `/talk` to `/slides` will leave this dead link (the old slides.md section remains too). Needs manual reconciliation.

2. **Duplicate `/slides` section.** After the rename, `docs/agent-system/commands.md` will end up with TWO `/slides` entries if the implementer edits rather than rewrites: the old conversion section (lines ~217-227) and the repurposed talk section. Plan must explicitly delete the old one.

3. **`docs/workflows/convert-documents.md` is wrong but in a subtle way.** Line 35 says "/slides — presentations to source-based slides" but the functionality moved to `/convert --format beamer`. A simple rename would create a `/convert` section duplicating `/slides`, or an orphaned `/slides` section describing the wrong command.

4. **The doc-lint script (`check-extension-docs.sh`) is broken by design in this repo.** If the plan recommends running it as a validation gate, implementation will fail. Alternative validation: manual grep for `ROAD_MAP`, `/talk`, `Co-Authored-By`, and dead `.claude/*` links.

5. **`.claude/context/standards/documentation.md` was DELETED** (replaced by expanded `documentation-standards.md`). Nothing outside .claude/ references it (verified via grep), but any plan that tries to "update" it will fail.

6. **Giant noise diffs.** `.claude/context/index.json` has 4528 line delta and `index.json.backup` has 4006 line delta. These are largely **reordering** (jq key-order changes), not semantic. Teammate A must not treat this as a large semantic change -- otherwise the plan will allocate effort disproportionately.

7. **extensions.json grew by 570 lines.** The new `present` extension entry duplicates files (grant-agent, budget-agent, etc.) that were previously listed under separate entries. User-facing docs don't currently describe extension internals so impact is probably nil, but verify.

8. **`/commands/review.md` diff (+23 lines) and `/commands/convert.md` diff (+202 lines).** These are functional changes, not cleanups. `docs/agent-system/commands.md` entries for these commands need review, not just link verification.

## Gaps the Other Teammates May Miss

1. **Untracked files.** A teammate doing `git diff HEAD -- .claude/` will NOT see `.claude/scripts/check-extension-docs.sh`, `setup-lean-mcp.sh`, `verify-lean-mcp.sh`, `CLAUDE.md.backup`, `settings.local.json.backup`. Must combine with `git ls-files --others --exclude-standard`.

2. **Deleted file: `.claude/commands/talk.md`.** `git diff --stat` shows it as `D`, but `git diff HEAD` output for a deleted file may be skipped if the teammate only looks at the modified-files list.

3. **Deleted file: `.claude/context/standards/documentation.md`.** Same issue. Teammate A must explicitly enumerate deletions.

4. **File-level diffs don't surface semantic collisions.** Just cataloging "slides.md changed" misses the fact that the file's MEANING flipped 180 degrees (conversion tool -> task creator). Teammate A must diff the frontmatter `description:` field, not just line count.

5. **docs/ internal cross-links.** `docs/workflows/README.md` links to `../agent-system/commands.md`. If commands.md is restructured (e.g., `/slides` section moves or splits), these cross-links need updating. Plan must audit links, not just content.

6. **No mention of `docs/general/`.** Installation, settings, keybindings docs may reference `.claude/` paths that changed. Verify with a grep for `.claude/` in `docs/general/`.

7. **Zed-specific context.** `docs/agent-system/zed-agent-panel.md` describes Zed ACP integration. If any `.claude/` changes affect what Zed shows (e.g., new skills visible in the agent panel), that doc may need a note. Low priority but worth checking.

8. **CLAUDE.md is the source of truth for docs/.** If `.claude/CLAUDE.md` is incomplete (see the `.backup` file), then regenerating docs/ from it propagates incompleteness.

## Questions That Should Be Asked

1. **"Which `docs/` do you mean?"** Confirm: user-facing `/home/benjamin/.config/zed/docs/` or system-builder `/home/benjamin/.config/zed/.claude/docs/`? Or both?
2. **"Is `.claude/CLAUDE.md` in its final state?"** The `.backup` file suggests ongoing edits. Regenerating docs from WIP is wasteful.
3. **"Should backup files be cleaned up as part of this task?"** They're polluting `git status`.
4. **"Is the /talk -> /slides transition intentional and final?"** Confirm before rewriting large sections of convert-documents.md and commands.md.
5. **"Does specs/ROADMAP.md exist, or is it aspirational?"** Affects whether docs should reference it at all.
6. **"Should `docs/` document internal scripts (`check-extension-docs.sh`, `setup-lean-mcp.sh`, `verify-lean-mcp.sh`)?"** Or are those only for `.claude/docs/`?
7. **"Do you want the doc update to be commit-per-file or a single large commit?"** The plan needs to know for sequencing.
8. **"Are team-mode docs supposed to stay high-level or expand to match the SKILL.md additions?"**

## Confidence Level

**Medium-high confidence on identified risks.** I verified diff scope, file existence, cross-references, and command semantics directly. The biggest residual uncertainty:

- Whether `.claude/CLAUDE.md` is truly the intended final state (backup file suggests maybe not) -- **this could invalidate the entire task**
- Whether the user intended `docs/` or `.claude/docs/` or both -- **this doubles or halves the task scope**
- Whether there are additional stale references I did not grep for (e.g., `/talk` in hidden places, `ROAD_MAP` in rule files)

**Recommendation to the planner**: Do not proceed to implementation without answering Questions 1, 2, and 4 above. Treat the `/slides` <-> `/talk` reshuffling as a narrative rewrite, not a rename. Explicitly enumerate deletions (`.claude/commands/talk.md`, `.claude/context/standards/documentation.md`). Skip `index.json` / `index.json.backup` diffs as noise. Do not rely on `check-extension-docs.sh` as a validation gate.

## Context Extension Recommendations

- **Topic**: docs/ vs .claude/docs/ distinction
- **Gap**: No existing context file explains that this repo has two parallel documentation trees with different audiences.
- **Recommendation**: Add a short entry to `.claude/context/repo/project-overview.md` (or a new `docs-architecture.md`) clarifying the two-tree layout so future agents don't conflate them.

- **Topic**: Branch naming (master vs main)
- **Gap**: Delegation prompts and some skill files assume `main` but this repo uses `master`.
- **Recommendation**: Document the actual default branch in `.claude/context/repo/project-overview.md` so agents stop generating broken git commands.
