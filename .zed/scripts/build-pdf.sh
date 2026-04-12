#!/usr/bin/env bash
# Build PDF from the current file based on extension.
#   .typ  -> typst compile
#   .md   -> Slidev export (silent, with desktop notifications)
# On success: desktop notification only (no terminal).
# On failure: desktop notification + open error log in $EDITOR / xdg-open.
set -euo pipefail

file="$1"
ext="${file##*.}"
log="/tmp/build-pdf-$(date +%s).log"

case "$ext" in
  typ)
    notify-send "Typst" "Compiling…" -i dialog-information
    if typst compile "$file" >"$log" 2>&1; then
      rm -f "$log"
    else
      notify-send "Typst" "Compile failed. See error log." -i dialog-error -u critical
      xdg-open "$log"
      exit 1
    fi
    ;;
  md)
    output_dir="$(dirname "$file")"
    notify-send "Slidev Export" "Building PDF…" -i dialog-information
    if npx @slidev/cli export "$file" --output "$output_dir/slides" >"$log" 2>&1; then
      rm -f "$log"
    else
      notify-send "Slidev Export" "Export failed. See error log." -i dialog-error -u critical
      xdg-open "$log"
      exit 1
    fi
    ;;
  *)
    notify-send "Build PDF" "Unsupported file type: .$ext" -i dialog-error
    exit 1
    ;;
esac
