#!/usr/bin/env bash
# install-base.sh - Base developer environment (cross-platform)
#
# Installs everything in docs/general/installation.md:
#   macOS:  Xcode Command Line Tools, Homebrew, Node.js, Zed (cask),
#           Claude Code CLI (cask), SuperDoc + openpyxl MCP servers
#   Debian: build-essential, Node.js (apt), Zed (interactive), Claude Code
#           CLI (npm), SuperDoc + openpyxl MCP servers
#   Arch:   base-devel, Node.js (pacman), Zed (AUR/interactive), Claude Code
#           CLI (npm), SuperDoc + openpyxl MCP servers
#
# Flags: --dry-run --yes --check --help
#
# Idempotent: every action is guarded by a presence check.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

print_help() {
  cat >&2 <<'EOF'
install-base.sh - Install base developer tools

Installs (platform-dependent):
  - Build tools (Xcode CLT on macOS, build-essential on Debian, base-devel on Arch)
  - Package manager bootstrap (Homebrew on macOS; apt/pacman already present on Linux)
  - Node.js
  - Zed editor
  - Claude Code CLI
  - SuperDoc MCP server (claude mcp add, user scope)
  - openpyxl MCP server (claude mcp add, user scope)
EOF
  print_common_help_footer
}

# ----- macOS-specific helpers -----------------------------------------------

check_xcode_clt() {
  xcode-select -p >/dev/null 2>&1 && check_command git
}

install_xcode_clt() {
  if check_xcode_clt; then
    log_ok "Xcode Command Line Tools already installed"
    return 0
  fi
  log_warn "Xcode Command Line Tools missing — a GUI dialog will appear."
  log_warn "Click 'Install' in the dialog and wait for it to complete."
  if [ "$DRY_RUN" = "1" ]; then
    log_dry "xcode-select --install"
    return 0
  fi
  xcode-select --install 2>/dev/null || true
  if [ "$ASSUME_YES" = "0" ]; then
    printf 'Press Enter once the Xcode CLT install dialog has completed... ' >&2
    if ! read -r _ </dev/tty 2>/dev/null; then read -r _ || true; fi
  fi
  if ! check_xcode_clt; then
    log_error "Xcode CLT still not detected; see docs/general/installation.md"
    return 4
  fi
}

install_homebrew() {
  if check_command brew; then
    log_ok "Homebrew already installed"
    return 0
  fi
  log_info "installing Homebrew via its official bootstrap script"
  if [ "$DRY_RUN" = "1" ]; then
    log_dry '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    return 0
  fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if ! check_command brew; then
    # Common post-install PATH additions for Apple Silicon / Intel.
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
  if ! check_command brew; then
    log_error "brew not found after install — restart your terminal and re-run"
    return 4
  fi
}

# ----- cross-platform install functions -------------------------------------

install_build_tools() {
  case "$DETECTED_OS" in
    macos)
      install_xcode_clt
      ;;
    debian)
      if check_command gcc && check_command make; then
        log_ok "build tools already installed (gcc + make found)"
        return 0
      fi
      sudo_install build-essential "Compilers and build tools required for native packages"
      ;;
    arch)
      if check_command gcc && check_command make; then
        log_ok "build tools already installed (gcc + make found)"
        return 0
      fi
      sudo_install build-essential "Compilers and build tools required for native packages"
      ;;
    *)
      log_warn "build tools: install gcc, make, and development headers manually"
      ;;
  esac
}

install_pkg_manager() {
  case "$DETECTED_OS" in
    macos)
      install_homebrew
      ;;
    *)
      # On Linux, the package manager is already present.
      log_ok "package manager available ($DETECTED_OS)"
      ;;
  esac
}

install_node() {
  if check_command node; then
    log_ok "node already installed: $(node --version)"
    return 0
  fi
  case "$DETECTED_OS" in
    macos)
      brew_install_formula node
      ;;
    debian)
      pkg_install nodejs
      pkg_install npm
      ;;
    arch)
      pkg_install nodejs
      pkg_install npm
      ;;
    *)
      log_warn "install Node.js manually for your platform"
      ;;
  esac
}

install_zed() {
  case "$DETECTED_OS" in
    macos)
      if check_app_bundle "Zed.app" || check_brew_cask zed; then
        log_ok "Zed already installed"
        return 0
      fi
      brew_install_cask zed
      ;;
    debian)
      if check_command zed; then
        log_ok "Zed already installed"
        return 0
      fi
      interactive_step "Install Zed editor" \
        "curl -f https://zed.dev/install.sh | sh" \
        "check_command zed" \
        "Zed is the primary editor for this configuration"
      ;;
    arch)
      if check_command zed; then
        log_ok "Zed already installed"
        return 0
      fi
      # Try AUR helper first, fall back to interactive instructions.
      if check_command yay; then
        if [ "$DRY_RUN" = "1" ]; then
          log_dry "yay -S --noconfirm zed-editor"
        else
          yay -S --noconfirm zed-editor || true
        fi
      elif check_command paru; then
        if [ "$DRY_RUN" = "1" ]; then
          log_dry "paru -S --noconfirm zed-editor"
        else
          paru -S --noconfirm zed-editor || true
        fi
      else
        interactive_step "Install Zed editor" \
          "curl -f https://zed.dev/install.sh | sh" \
          "check_command zed" \
          "Zed is the primary editor; install via AUR (zed-editor) or the official installer"
      fi
      ;;
    *)
      interactive_step "Install Zed editor" \
        "curl -f https://zed.dev/install.sh | sh" \
        "check_command zed" \
        "Zed is the primary editor for this configuration"
      ;;
  esac
}

install_claude_cli() {
  if check_command claude; then
    log_ok "claude CLI already installed"
    return 0
  fi
  case "$DETECTED_OS" in
    macos)
      brew_install_cask claude-code
      ;;
    *)
      # On Linux, install via npm.
      if ! check_command npm; then
        log_warn "npm not found; cannot install Claude Code CLI. Install Node.js first."
        return 0
      fi
      if [ "$DRY_RUN" = "1" ]; then
        log_dry "npm install -g @anthropic-ai/claude-code"
        return 0
      fi
      npm install -g @anthropic-ai/claude-code || \
        interactive_step "Install Claude Code CLI" \
          "sudo npm install -g @anthropic-ai/claude-code" \
          "check_command claude" \
          "Claude Code CLI is required for MCP server registration and agent operation"
      ;;
  esac
}

install_mcp_superdoc() {
  if ! check_command claude; then
    log_warn "claude CLI not installed yet; skipping superdoc MCP"
    return 0
  fi
  if claude_mcp_has superdoc; then
    log_ok "superdoc MCP already registered"
    return 0
  fi
  run_or_dry claude mcp add --scope user superdoc -- npx @superdoc-dev/mcp
}

install_mcp_openpyxl() {
  if ! check_command claude; then
    log_warn "claude CLI not installed yet; skipping openpyxl MCP"
    return 0
  fi
  if claude_mcp_has openpyxl; then
    log_ok "openpyxl MCP already registered"
    return 0
  fi
  run_or_dry claude mcp add --scope user openpyxl -- npx @jonemo/openpyxl-mcp
}

run_check_mode() {
  local missing=0
  case "$DETECTED_OS" in
    macos)
      check_xcode_clt && log_ok "xcode-clt" || { log_warn "[missing] xcode-clt"; missing=1; }
      check_command brew && log_ok "brew" || { log_warn "[missing] brew"; missing=1; }
      ;;
    *)
      check_command gcc && log_ok "build-tools" || { log_warn "[missing] build-tools (gcc)"; missing=1; }
      ;;
  esac
  check_command node   && log_ok "node"   || { log_warn "[missing] node"; missing=1; }
  check_command zed    && log_ok "zed"    || { check_app_bundle "Zed.app" && log_ok "zed" || { log_warn "[missing] zed"; missing=1; }; }
  check_command claude && log_ok "claude" || { log_warn "[missing] claude"; missing=1; }
  claude_mcp_has superdoc && log_ok "mcp:superdoc" || { log_warn "[missing] mcp:superdoc"; missing=1; }
  claude_mcp_has openpyxl && log_ok "mcp:openpyxl" || { log_warn "[missing] mcp:openpyxl"; missing=1; }
  return "$missing"
}

main() {
  parse_common_flags "$@"
  if [ "$SHOW_HELP" = "1" ]; then print_help; exit 0; fi
  assert_supported_os
  print_section "install-base: base developer environment ($DETECTED_OS)"

  if [ "$CHECK_MODE" = "1" ]; then
    run_check_mode
    exit $?
  fi

  install_build_tools
  install_pkg_manager
  install_node
  install_zed
  install_claude_cli
  install_mcp_superdoc
  install_mcp_openpyxl

  log_info "install-base finished. Run 'claude' in your terminal to authenticate."
}

main "$@"
