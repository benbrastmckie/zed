#!/usr/bin/env bash
# Live preview for the current file in the browser/viewer.
#   .typ  -> typst compile + open PDF (use typst watch for live reload)
#   .md   -> slidev dev server
set -euo pipefail

file="$1"
ext="${file##*.}"

case "$ext" in
  typ)
    # Compile and open the PDF; use typst watch in a terminal for live reload
    pdf="${file%.typ}.pdf"
    typst compile "$file" && open "$pdf"
    ;;
  md)
    dir="$(dirname "$file")"
    cd "$dir"
    exec pnpm dev
    ;;
  *)
    echo "Unsupported file type: .$ext" >&2
    exit 1
    ;;
esac
