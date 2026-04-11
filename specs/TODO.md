---
next_project_number: 27
---

# Task List

## Tasks

### 26. Remove redundant ctrl-h/ctrl-l in Editor context of keymap.json
- **Effort**: TBD
- **Status**: [PLANNING]
- **Task Type**: general
- **Priority**: low
- **Source**: review-20260410

**Description**: Remove the redundant ctrl-h / ctrl-l pane navigation bindings from the Editor context block in keymap.json:35-36 (already covered by the Workspace context block at L14-15), or add a comment explaining why they are duplicated.

### 25. Fix keymap.json default-reference comment for macOS
- **Effort**: TBD
- **Status**: [PLANNING]
- **Task Type**: markdown
- **Priority**: medium
- **Source**: review-20260410

**Description**: Rewrite the default-reference comment block in keymap.json (lines 46-116) to use Cmd+ modifiers for macOS defaults instead of Ctrl+, except for the four intentional Ctrl+ custom bindings. Consider folding into task 21 if scope allows.

### 24. Untrack Claude Code TTS log files from git
- **Effort**: TBD
- **Status**: [PLANNING]
- **Task Type**: general
- **Priority**: medium
- **Source**: review-20260410

**Description**: Run `git rm --cached` on specs/tmp/claude-tts-last-notify and specs/tmp/claude-tts-notify.log, then add an entry to .gitignore so the Claude Code TTS notification hook stops dirtying the working tree on every run.

### 23. Update Claude model IDs in settings.json and docs
- **Effort**: TBD
- **Status**: [RESEARCHED]
- **Task Type**: general
- **Priority**: high
- **Source**: review-20260410
- **Research**: [01_stale-proof-model-config.md](023_update_claude_model_ids/reports/01_stale-proof-model-config.md)

**Description**: Update outdated Claude model IDs in settings.json (lines 39, 44) and docs/general/settings.md (lines 59, 64) from `claude-sonnet-4-20250514` / `claude-opus-4-20250514` to `claude-sonnet-4-6` / `claude-opus-4-6` so the Zed Agent Panel uses current models.

### 22. Create epi study example demo in zed/examples/epi-study/
- **Effort**: TBD
- **Status**: [PLANNED]
- **Task Type**: general
- **Research**: [01_epi-study-example-demo.md](022_epi_study_example_demo/reports/01_epi-study-example-demo.md)
- **Plan**: [01_epi-study-example-demo.md](022_epi_study_example_demo/plans/01_epi-study-example-demo.md)

**Description**: Create zed/examples/epi-study/ directory that organizes and documents the synthetic RCT study produced by task 20, as a demo for new users to understand how to run the /epi command to create an epi study.

### 21. Update README and docs to reflect R/Python + Claude Code + Zed IDE configuration
- **Effort**: TBD
- **Status**: [COMPLETED]
- **Task Type**: markdown
- **Research**: [01_update-docs-r-python-zed.md](021_update_docs_r_python_zed/reports/01_update-docs-r-python-zed.md)
- **Plan**: [01_update-docs-r-python-zed.md](021_update_docs_r_python_zed/plans/01_update-docs-r-python-zed.md)
- **Summary**: [01_update-docs-r-python-zed-summary.md](021_update_docs_r_python_zed/summaries/01_update-docs-r-python-zed-summary.md)
- **Completion**: Reframed repository documentation and settings.json from an epidemiology/macOS framing to a macOS-only Zed IDE configuration for R and Python with Claude Code, surfacing the existing R.md and python.md guides and removing all NixOS-specific paths from user-facing docs and configs.

**Description**: Update /home/benjamin/.config/zed/README.md and the other documentation in /home/benjamin/.config/zed/docs/README.md and /home/benjamin/.config/zed/docs/ to reflect that this is a configuration for working in R and Python with Claude Code in the Zed IDE.

### 20. Test epi RCT study: ketamine-assisted therapy for methamphetamine use disorder
- **Effort**: TBD
- **Status**: [COMPLETED]
- **Task Type**: epi:study
- **Artifacts**:
  - [01_epi-research.md](020_test_epi_rct_ketamine_meth/reports/01_epi-research.md) (report)
  - [01_epi-rct-test-study.md](020_test_epi_rct_ketamine_meth/plans/01_epi-rct-test-study.md) (plan)
  - [01_epi-rct-test-study-summary.md](020_test_epi_rct_ketamine_meth/summaries/01_epi-rct-test-study-summary.md) (summary)
  - [config_gaps.md](020_test_epi_rct_ketamine_meth/logs/config_gaps.md) (log)
  - [06_zed_verification_summary.md](020_test_epi_rct_ketamine_meth/reports/06_zed_verification_summary.md) (report)
  - [05_consort_report.md](020_test_epi_rct_ketamine_meth/reports/05_consort_report.md) (report)
- **Summary**: Synthetic RCT pipeline executed as Zed R/Python/Quarto toolchain verification on NixOS. All 7 phases completed with graceful fallbacks (base R only, Quarto unavailable). Primary deliverable is the prioritized config gap log with nix remediation snippets for missing R packages, Python modules, and Quarto.

**Description**: Simple test RCT study on fake generated data to verify R and Python are configured correctly in Zed and identify configuration shortcomings. Research question: Does ketamine-assisted therapy improve recovery from methamphetamine use disorder?
