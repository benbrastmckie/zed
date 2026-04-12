#!/usr/bin/env bash
# Live preview for the current file in the browser.
#   .typ  -> tinymist preview (live reload web server)
#   .md   -> slidev dev server
set -euo pipefail

# Cross-platform notification
notify() {
  case "$(uname -s)" in
    Darwin) osascript -e "display notification \"$1\" with title \"Preview\"" ;;
    *)      notify-send "Preview" "$1" -t 2000 ;;
  esac
}

file="$1"
ext="${file##*.}"

case "$ext" in
  typ)
    notify "Starting typst preview…"
    exec tinymist preview --open "$file"
    ;;
  md)
    dir="$(dirname "$file")"
    notify "Starting slidev dev server…"
    cd "$dir"
    exec pnpm dev
    ;;
  *)
    echo "Unsupported file type: .$ext" >&2
    exit 1
    ;;
esac
