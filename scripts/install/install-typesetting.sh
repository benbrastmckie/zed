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
  if prompt_yn "Install full MacTeX (~5 GB) instead of BasicTeX (~100 MB)?" default_n; then
    choice="full"
  fi
  if [ "$choice" = "full" ]; then
    brew_install_cask mactex
  else
    brew_install_cask basictex
    log_warn "BasicTeX installed. Open a new terminal so PATH picks up /Library/TeX/texbin."
    log_warn "Then install extras with: sudo tlmgr update --self && sudo tlmgr install latexmk collection-fontsrecommended collection-latexextra biber"
    if [ "$DRY_RUN" = "0" ] && check_command tlmgr && prompt_yn "Run 'sudo tlmgr update/install' now (requires sudo password)?" default_n; then
      sudo tlmgr update --self || true
      sudo tlmgr install latexmk collection-fontsrecommended collection-latexextra biber || true
    else
      log_dry "sudo tlmgr update --self && sudo tlmgr install latexmk collection-fontsrecommended collection-latexextra biber"
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

do_markitdown() {
  if check_command markitdown; then
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
  check_command markitdown && log_ok "markitdown" || { log_warn "[missing] markitdown"; missing=1; }
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

  log_info "install-typesetting finished."
}

main "$@"
