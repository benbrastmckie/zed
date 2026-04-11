#!/usr/bin/env bash
# Silent Slidev PDF export with desktop notifications.
# On success: notify only. On failure: write errors to a log file and notify with path.
set -euo pipefail

file="$1"
output_dir="$(dirname "$file")"
log="/tmp/slidev-export-$(date +%s).log"

notify-send "Slidev Export" "Building PDF…" -i dialog-information

if npx @slidev/cli export "$file" --output "$output_dir/slides" >"$log" 2>&1; then
    rm -f "$log"
    notify-send "Slidev Export" "PDF exported: $output_dir/slides.pdf" -i dialog-information
else
    notify-send "Slidev Export" "Export failed. Errors in:\n$log" -i dialog-error -u critical
    exit 1
fi
