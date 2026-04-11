---
next_project_number: 23
---

# Task List

## Tasks

### 22. Create epi study example demo in zed/examples/epi-study/
- **Effort**: TBD
- **Status**: [RESEARCHING]
- **Task Type**: general

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
