#!/usr/bin/env bash
# install-shell-tools.sh - Shell utilities used by .claude/ agents
#
# Tools installed:
#   - jq           (JSON processor -- hooks, status-sync, context queries)
#   - gh           (GitHub CLI -- /merge PR creation)
#   - make         (GNU make -- optional upgrade on macOS; standard on Linux)
#   - fontconfig   (fc-list, used by typesetting font checks)
#
# Flags: --dry-run --check --help
# Idempotent: every install guarded by presence check.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

print_help() {
  cat >&2 <<'EOF'
install-shell-tools.sh - Shell utilities (jq, gh, make, fontconfig)

Installs via Homebrew:
  - jq          (JSON processor)
  - gh          (GitHub CLI)
  - make        (GNU make -- optional upgrade)
  - fontconfig  (fc-list; used by typesetting font checks)
EOF
  print_common_help_footer
}

do_jq() { brew_install_formula jq; }

do_gh() {
  if check_command gh; then
    log_ok "gh already installed"
    return 0
  fi
  brew_install_formula gh
}

do_make() {
  if check_command gmake || check_brew_formula make; then
    log_ok "gnu make already installed"
    return 0
  fi
  if prompt_yn "Install GNU make via Homebrew (as 'gmake')?" default_n; then
    brew_install_formula make
  else
    log_info "skipping GNU make (system make from Xcode CLT remains)"
  fi
}

do_fontconfig() { brew_install_formula fontconfig; }

run_check_mode() {
  local missing=0
  check_command jq      && log_ok "jq"         || { log_warn "[missing] jq"; missing=1; }
  check_command gh      && log_ok "gh"         || { log_warn "[missing] gh"; missing=1; }
  check_command fc-list && log_ok "fontconfig" || { log_warn "[missing] fontconfig"; missing=1; }
  check_command make    && log_ok "make"       || { log_warn "[missing] make"; missing=1; }
  return "$missing"
}

main() {
  parse_common_flags "$@"
  if [ "$SHOW_HELP" = "1" ]; then print_help; exit 0; fi
  assert_supported_os
  print_section "install-shell-tools: jq, gh, make, fontconfig ($DETECTED_OS)"

  if [ "$CHECK_MODE" = "1" ]; then
    run_check_mode
    exit $?
  fi

  require_pkg_manager

  do_jq
  do_gh
  do_make
  do_fontconfig

  log_info "install-shell-tools finished."
}

main "$@"
