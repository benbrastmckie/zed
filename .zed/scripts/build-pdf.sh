#!/usr/bin/env bash
# Build PDF from the current file based on extension.
#   .typ  -> typst compile
#   .md   -> Slidev export (silent, with desktop notifications)
# On success: desktop notification only (no terminal).
# On failure: desktop notification + open error log.
set -euo pipefail

file="$1"
ext="${file##*.}"
log="/tmp/build-pdf-$(date +%s).log"

notify() {
  osascript -e "display notification \"$2\" with title \"$1\""
}

case "$ext" in
  typ)
    notify "Typst" "Compiling…"
    pdf="${file%.typ}.pdf"
    if typst compile "$file" >"$log" 2>&1; then
      rm -f "$log"
      open "$pdf"
      notify "Typst" "Build succeeded"
    else
      notify "Typst" "Compile failed. See error log."
      open "$log"
      exit 1
    fi
    ;;
  md)
    output_dir="$(dirname "$file")"
    notify "Slidev Export" "Building PDF…"
    if npx @slidev/cli export "$file" --output "$output_dir/slides" >"$log" 2>&1; then
      rm -f "$log"
      notify "Slidev Export" "Export succeeded"
    else
      notify "Slidev Export" "Export failed. See error log."
      open "$log"
      exit 1
    fi
    ;;
  *)
    notify "Build PDF" "Unsupported file type: .$ext"
    exit 1
    ;;
esac
