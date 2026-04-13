#!/usr/bin/env bash
# install-shell-tools.sh - Shell utilities used by .claude/ agents
#
# Tools installed:
#   - jq           (JSON processor -- hooks, status-sync, context queries)
#   - gh           (GitHub CLI -- /merge PR creation)
#   - make         (GNU make -- optional upgrade on macOS; standard on Linux)
#   - fontconfig   (fc-list, used by typesetting font checks)
#
# Flags: --dry-run --yes --check --help
# Idempotent: every install guarded by presence check.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

print_help() {
  cat >&2 <<'EOF'
install-shell-tools.sh - Shell utilities (jq, gh, make, fontconfig)

Installs via platform package manager:
  - jq          (JSON processor)
  - gh          (GitHub CLI)
  - make        (GNU make -- optional on macOS, standard on Linux)
  - fontconfig  (fc-list; used by typesetting font checks)
EOF
  print_common_help_footer
}

do_jq() { pkg_install jq; }

do_gh() {
  if check_command gh; then
    log_ok "gh already installed"
    return 0
  fi
  case "$DETECTED_OS" in
    macos)
      brew_install_formula gh
      ;;
    debian)
      # gh requires the GitHub apt repository on Debian.
      if [ "$DRY_RUN" = "1" ]; then
        log_dry "Install GitHub CLI via: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
        return 0
      fi
      # Try direct apt install first (works on newer Ubuntu/Debian with gh in repos).
      if sudo apt-get install -y gh 2>/dev/null; then
        return 0
      fi
      # Fall back to official GitHub repository setup.
      interactive_step "Install GitHub CLI (gh)" \
        "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && echo 'deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main' | sudo tee /etc/apt/sources.list.d/github-cli.list && sudo apt-get update && sudo apt-get install -y gh" \
        "check_command gh" \
        "GitHub CLI is used by the /merge command for PR creation"
      ;;
    arch)
      pkg_install gh
      ;;
    *)
      interactive_step "Install GitHub CLI (gh)" \
        "See https://github.com/cli/cli#installation" \
        "check_command gh" \
        "GitHub CLI is used by the /merge command"
      ;;
  esac
}

do_make() {
  case "$DETECTED_OS" in
    macos)
      if check_command gmake || check_brew_formula make; then
        log_ok "gnu make already installed"
        return 0
      fi
      if prompt_yn "Install GNU make via Homebrew (as 'gmake')?" default_n; then
        brew_install_formula make
      else
        log_info "skipping GNU make (system make from Xcode CLT remains)"
      fi
      ;;
    *)
      # On Linux, make comes with build tools (build-essential / base-devel).
      if check_command make; then
        log_ok "make already installed"
      else
        pkg_install make
      fi
      ;;
  esac
}

do_fontconfig() { pkg_install fontconfig; }

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
