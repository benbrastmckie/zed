#!/usr/bin/env bash
# Open a preview for the current file based on extension.
#   .typ  -> open compiled PDF with xdg-open
#   .md   -> launch Slidev dev server with --open
set -euo pipefail

file="$1"
ext="${file##*.}"

case "$ext" in
  typ)
    pdf="${file%.typ}.pdf"
    if [[ ! -f "$pdf" ]]; then
      typst compile "$file"
    fi
    xdg-open "$pdf"
    ;;
  md)
    exec npx @slidev/cli --open "$file"
    ;;
  *)
    notify-send "Preview" "Unsupported file type: .$ext" -i dialog-error
    exit 1
    ;;
esac
