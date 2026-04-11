#!/usr/bin/env bash
# sync-assets.sh -- Re-copy task-28 enriched outputs from examples/epi-study/
# into examples/epi-slides/public/assets/. Idempotent; uses rsync -a.
#
# Run from repo root or from examples/epi-slides/. Safe to re-run.

set -euo pipefail

# Resolve script directory and walk up to the slide deck root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SLIDES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SLIDES_ROOT/../.." && pwd)"
STUDY="$REPO_ROOT/examples/epi-study"

if [ ! -d "$STUDY" ]; then
  echo "ERROR: $STUDY not found" >&2
  exit 1
fi

echo "[sync-assets] study source: $STUDY"
echo "[sync-assets] slides root:  $SLIDES_ROOT"

mkdir -p "$SLIDES_ROOT/public/assets/tables"
mkdir -p "$SLIDES_ROOT/public/assets/receipts"
mkdir -p "$SLIDES_ROOT/public/assets/consort"

# Tables
rsync -a \
  "$STUDY/reports/tables/primary_results.txt" \
  "$STUDY/reports/tables/primary_results_tidy.txt" \
  "$STUDY/reports/tables/cox_results.txt" \
  "$STUDY/reports/tables/sensitivity_mice.txt" \
  "$STUDY/reports/tables/sensitivity_results.txt" \
  "$SLIDES_ROOT/public/assets/tables/"

# Receipts
rsync -a \
  "$STUDY/logs/rerun_028/identity_check.txt" \
  "$STUDY/logs/rerun_028/baseline/sha256sums.txt" \
  "$STUDY/logs/rerun_028/branch_probe.txt" \
  "$STUDY/logs/rerun_028/branch_decision.txt" \
  "$STUDY/logs/rerun_028/session_info_r.txt" \
  "$STUDY/logs/rerun_028/session_info_py.txt" \
  "$STUDY/logs/rerun_028/env_snapshot.txt" \
  "$STUDY/logs/rerun_028/rerun_summary.md" \
  "$SLIDES_ROOT/public/assets/receipts/"

# Consort rendered report
rsync -a \
  "$STUDY/reports/rendered/consort_report.html" \
  "$SLIDES_ROOT/public/assets/consort/"
if [ -d "$STUDY/reports/rendered/consort_report_files" ]; then
  rsync -a \
    "$STUDY/reports/rendered/consort_report_files/" \
    "$SLIDES_ROOT/public/assets/consort/consort_report_files/"
fi

echo "[sync-assets] done."
