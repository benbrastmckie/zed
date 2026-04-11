#!/usr/bin/env bash
# 06_consort_qmd_render.sh -- render CONSORT report via quarto.
# Part of task 28 Branch B. Writes to examples/epi-study/reports/rendered/.

set -euo pipefail

STUDY_ROOT="/home/benjamin/.config/zed/examples/epi-study"
QMD="$STUDY_ROOT/reports/consort_report.qmd"
OUT_DIR="$STUDY_ROOT/reports/rendered"

mkdir -p "$OUT_DIR"

if ! command -v quarto >/dev/null 2>&1; then
  echo "quarto not available; skipping render" >&2
  exit 2
fi

cd "$STUDY_ROOT"
quarto render "$QMD" --to html --output-dir "$OUT_DIR"
echo "Rendered: $OUT_DIR/$(basename "${QMD%.qmd}.html")"
