#!/usr/bin/env bash
# install-typesetting.sh - LaTeX, Typst, Pandoc, markitdown, fonts
#
# Mirrors docs/toolchain/typesetting.md:
#   - LaTeX (BasicTeX default, MacTeX on opt-in)
#   - Typst
#   - Pandoc
#   - markitdown (via uv tool install)
#   - Fonts (font-latin-modern, font-latin-modern-math, font-computer-modern,
#            font-noto-sans, font-noto-serif, font-noto-sans-mono)
#
# Note: .claude/settings.json 'Bash(typst *)' allowlist is a separate concern
# and is NOT managed by this script.
#
# Flags: --dry-run --yes --check --help
# Idempotent: every install guarded by presence check.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

print_help() {
  cat >&2 <<'EOF'
install-typesetting.sh - LaTeX, Typst, Pandoc, markitdown, fonts

Optional sub-groups (each prompted):
  - BasicTeX (default) or MacTeX (opt-in) + tlmgr extras
  - Typst
  - Pandoc
  - markitdown (uv tool install)
  - Fonts: latin modern, computer modern, noto family
EOF
  print_common_help_footer
}

do_latex() {
  if check_command pdflatex && check_command latexmk; then
    log_ok "LaTeX (pdflatex + latexmk) already installed"
    return 0
  fi
  if ! prompt_yn "Install a LaTeX distribution?"; then
    log_info "skipping LaTeX"
    return 0
  fi
  local choice="basic"
  # default_n: MacTeX is 5 GB — only opt in explicitly; --yes stays with BasicTeX
  if prompt_yn "Install full MacTeX (~5 GB) instead of BasicTeX (~100 MB)?" default_n; then
    choice="full"
  fi
  if [ "$choice" = "full" ]; then
    brew_install_pkg_cask mactex \
      "brew install --cask mactex" \
      "Full LaTeX distribution (~5 GB): compile .tex documents to PDF with pdflatex/xelatex/lualatex"
  else
    brew_install_pkg_cask basictex \
      "brew install --cask basictex && sudo tlmgr update --self && sudo tlmgr install latexmk collection-fontsrecommended collection-latexextra biber" \
      "Minimal LaTeX (~100 MB): compile .tex documents to PDF; required by the /convert and typesetting workflows"
    if check_command tlmgr || [ -x /Library/TeX/texbin/tlmgr ]; then
      log_info "BasicTeX installed. Running tlmgr to add latexmk and common packages..."
      if [ "$DRY_RUN" = "0" ]; then
        export PATH="/Library/TeX/texbin:$PATH"
        sudo tlmgr update --self || true
        sudo tlmgr install latexmk collection-fontsrecommended collection-latexextra biber || true
      else
        log_dry "sudo tlmgr update --self && sudo tlmgr install latexmk collection-fontsrecommended collection-latexextra biber"
      fi
    else
      log_warn "BasicTeX installed. Open a new terminal (PATH update) then run:"
      log_warn "  sudo tlmgr update --self"
      log_warn "  sudo tlmgr install latexmk collection-fontsrecommended collection-latexextra biber"
    fi
  fi
}

do_typst() {
  if check_command typst; then
    log_ok "typst already installed: $(typst --version 2>&1)"
    return 0
  fi
  if ! prompt_yn "Install Typst?"; then return 0; fi
  brew_install_formula typst
}

do_pandoc() {
  if check_command pandoc; then
    log_ok "pandoc already installed"
    return 0
  fi
  if ! prompt_yn "Install Pandoc?"; then return 0; fi
  brew_install_formula pandoc
}

check_markitdown() {
  # markitdown can live in several places depending on how it was installed:
  #   uv tool install -> ~/.local/bin/markitdown (may not be in non-interactive PATH)
  #   pip3 install    -> ~/Library/Python/X.Y/bin/markitdown
  # Fall back to checking the Python library and uv tool list.
  check_command markitdown && return 0
  [ -x "$HOME/.local/bin/markitdown" ] && return 0
  if check_command uv && uv tool list 2>/dev/null | grep -q "^markitdown"; then
    return 0
  fi
  check_command python3 && python3 -c "import markitdown" >/dev/null 2>&1 && return 0
  return 1
}

do_markitdown() {
  if check_markitdown; then
    log_ok "markitdown already installed"
    return 0
  fi
  if ! check_command uv; then
    log_warn "uv missing; run install-python.sh first to get markitdown via uv tool install"
    return 0
  fi
  if ! prompt_yn "Install markitdown (uv tool install markitdown)?"; then return 0; fi
  run_or_dry uv tool install markitdown
}

FONT_CASKS="font-latin-modern font-latin-modern-math font-computer-modern font-noto-sans font-noto-serif font-noto-sans-mono"

do_fonts() {
  if ! prompt_yn "Install typesetting fonts (Latin Modern, Computer Modern, Noto)?"; then
    log_info "skipping fonts"
    return 0
  fi
  local cask
  for cask in $FONT_CASKS; do
    if check_brew_cask "$cask"; then
      log_ok "font cask already installed: $cask"
    else
      run_or_dry brew install --cask "$cask" || \
        log_warn "font cask $cask not found — try 'brew search font-<name>'"
    fi
  done
}

run_check_mode() {
  local missing=0
  check_command pdflatex   && log_ok "pdflatex"   || { log_warn "[missing] pdflatex"; missing=1; }
  check_command latexmk    && log_ok "latexmk"    || { log_warn "[missing] latexmk"; missing=1; }
  check_command typst      && log_ok "typst"      || { log_warn "[missing] typst"; missing=1; }
  check_command pandoc     && log_ok "pandoc"     || { log_warn "[missing] pandoc"; missing=1; }
  check_markitdown && log_ok "markitdown" || { log_warn "[missing] markitdown"; missing=1; }
  if check_command fc-list && fc-list 2>/dev/null | grep -qi "latin modern math"; then
    log_ok "font:latin-modern-math"
  else
    log_warn "[missing] font:latin-modern-math"
    missing=1
  fi
  return "$missing"
}

main() {
  parse_common_flags "$@"
  if [ "$SHOW_HELP" = "1" ]; then print_help; exit 0; fi
  assert_macos
  print_section "install-typesetting: LaTeX, Typst, Pandoc, markitdown, fonts"

  if [ "$CHECK_MODE" = "1" ]; then
    run_check_mode
    exit $?
  fi

  require_brew

  do_latex
  do_typst
  do_pandoc
  do_markitdown
  do_fonts

  print_deferred_hints
  log_info "install-typesetting finished."
}

main "$@"
