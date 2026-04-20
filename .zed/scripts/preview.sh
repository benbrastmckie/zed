#!/usr/bin/env bash
# Live preview for the current file in the browser.
#   .typ  -> tinymist preview (live reload web server)
#   .md   -> slidev dev server
set -euo pipefail

file="$1"
ext="${file##*.}"

case "$ext" in
  typ)
    exec tinymist preview --open "$file"
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
