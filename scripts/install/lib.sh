#!/usr/bin/env bash
# lib.sh - Shared helper library for macOS install scripts (scripts/install/*.sh)
#
# BASH 3.2 COMPATIBILITY CONSTRAINTS (macOS ships bash 3.2 by default):
#   - No `mapfile` / `readarray` (use while-read loops)
#   - No `${var,,}` / `${var^^}` (use tr '[:upper:]' '[:lower:]')
#   - No `declare -n` nameref
#   - No associative arrays (`declare -A`) at top level — use parallel plain arrays
#   - No `wait -n`
#   - Use `[[ ... ]]` freely; avoid bash-5-only features
#
# HARD INVARIANTS:
#   - Scripts NEVER read, parse, or scrape any .md file at runtime.
#     All install actions are hard-coded in bash. See install-mcp-servers.sh
#     for the rationale (Lean MCP resurrection guard).
#   - Every install action MUST be guarded by a presence check (idempotency).
#   - Every script MUST support --dry-run, --check, --help, --yes.
#
# --check CONTRACT (co-designed with future /doctor command):
#   When invoked with --check, a script:
#     - Runs presence checks for every tool it would install.
#     - Prints one line per tool: "[ok] <name>" or "[missing] <name>".
#     - Exits 0 if everything is present, 1 if anything is missing.
#     - Performs NO side effects.
#
# EXIT CODES:
#   0 = success (or all checks passed in --check mode)
#   1 = missing tools detected in --check mode
#   2 = user cancelled
#   3 = prerequisite failure (e.g., wrong OS, missing git)
#   4 = install failure
#
# USAGE (from a group script):
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   # shellcheck source=lib.sh
#   . "$SCRIPT_DIR/lib.sh"
#   parse_common_flags "$@"
#   ...

# Guard against double-sourcing.
if [ -n "${_INSTALL_LIB_SOURCED:-}" ]; then
  return 0 2>/dev/null || true
fi
_INSTALL_LIB_SOURCED=1

# Homebrew speedup: never auto-update on every `brew install`.
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1

# ----- platform detection ---------------------------------------------------
# DETECTED_OS is set once at source time. Valid value: macos
DETECTED_OS=""

detect_os() {
  local kernel
  kernel="$(uname -s)"
  if [ "$kernel" = "Darwin" ]; then
    DETECTED_OS="macos"
  else
    DETECTED_OS="unsupported"
  fi
}

# Run detection at source time (after double-source guard).
detect_os

# ----- headless detection ---------------------------------------------------

is_headless() {
  # Returns 0 if no interactive tty is available and FORCE_INTERACTIVE is not set.
  if [ -n "${FORCE_INTERACTIVE:-}" ]; then
    return 1
  fi
  ! tty -s 2>/dev/null
}

# Flag state (populated by parse_common_flags).
DRY_RUN=0
ASSUME_YES=0
CHECK_MODE=0
ONLY_GROUPS=""
PRESET=""
SHOW_HELP=0

# Summary accumulators (used by master wizard).
GROUPS_OK=""
GROUPS_SKIPPED=""
GROUPS_FAILED=""

# Deferred hints: pkg-cask installs skipped due to no-tty append here.
# Each entry is a TAB-separated pair: "command<TAB>description"
# Scripts call print_deferred_hints at the end of main() to surface them.
DEFERRED_HINTS=""

# ----- logging helpers ---------------------------------------------------
# All logging goes to stderr so command substitution callers aren't polluted.

log_info() {
  printf '[info] %s\n' "$*" >&2
}

log_warn() {
  printf '[warn] %s\n' "$*" >&2
}

log_error() {
  printf '[error] %s\n' "$*" >&2
}

log_ok() {
  printf '[ok] %s\n' "$*" >&2
}

log_dry() {
  printf '[dry-run] %s\n' "$*" >&2
}

print_section() {
  printf '\n' >&2
  printf '===== %s =====\n' "$*" >&2
}

# ----- prompts -----------------------------------------------------------

# prompt_yn "Question" [default_y|default_n]
# Returns 0 for yes, 1 for no.
# Honors $ASSUME_YES.
prompt_yn() {
  local question="$1"
  local default="${2:-default_y}"
  local suffix="[Y/n]"
  if [ "$default" = "default_n" ]; then
    suffix="[y/N]"
  fi
  if [ "$ASSUME_YES" = "1" ]; then
    # Respect default_n even in --yes mode: these are opt-in extras (e.g. MacTeX
    # 5 GB, epi bundle) where silently accepting would cause surprising behaviour.
    if [ "$default" = "default_n" ]; then
      log_info "$question $suffix (auto-no — default is N; use interactive mode to opt in)"
      return 1
    fi
    log_info "$question $suffix (auto-yes)"
    return 0
  fi
  local reply=""
  # Prompt on stderr; read from terminal.
  printf '%s %s ' "$question" "$suffix" >&2
  if ! read -r reply </dev/tty 2>/dev/null; then
    # No tty — fall back to stdin.
    read -r reply || reply=""
  fi
  reply="$(printf '%s' "$reply" | tr '[:upper:]' '[:lower:]')"
  if [ -z "$reply" ]; then
    [ "$default" = "default_n" ] && return 1 || return 0
  fi
  case "$reply" in
    y|yes) return 0 ;;
    *)     return 1 ;;
  esac
}

# prompt_accept_skip_cancel "Group name" "Description"
# Prints to stderr. Sets global PROMPT_ASC_RESULT to one of: accept, skip, cancel.
# Honors $ASSUME_YES (auto-accept).
PROMPT_ASC_RESULT=""
prompt_accept_skip_cancel() {
  local name="$1"
  local desc="$2"
  printf '\n' >&2
  printf '----- %s -----\n' "$name" >&2
  printf '%s\n' "$desc" >&2
  if [ "$ASSUME_YES" = "1" ]; then
    PROMPT_ASC_RESULT="accept"
    log_info "auto-accept ($name)"
    return 0
  fi
  local reply=""
  printf '[a]ccept / [s]kip / [c]ancel wizard? [A/s/c] ' >&2
  if ! read -r reply </dev/tty 2>/dev/null; then
    read -r reply || reply=""
  fi
  reply="$(printf '%s' "$reply" | tr '[:upper:]' '[:lower:]')"
  case "$reply" in
    ""|a|accept) PROMPT_ASC_RESULT="accept" ;;
    s|skip)      PROMPT_ASC_RESULT="skip" ;;
    c|cancel|q)  PROMPT_ASC_RESULT="cancel" ;;
    *)           PROMPT_ASC_RESULT="skip" ;;
  esac
}

# ----- presence checks ---------------------------------------------------

check_command() {
  # check_command <name> -> 0 if on PATH, 1 otherwise
  command -v "$1" >/dev/null 2>&1
}

check_brew_formula() {
  # check_brew_formula <name>
  if ! check_command brew; then return 1; fi
  brew list --formula "$1" >/dev/null 2>&1
}

check_brew_cask() {
  # check_brew_cask <name>
  if ! check_command brew; then return 1; fi
  brew list --cask "$1" >/dev/null 2>&1
}

check_app_bundle() {
  # check_app_bundle "AppName.app"
  [ -d "/Applications/$1" ] || [ -d "$HOME/Applications/$1" ]
}

r_package_installed() {
  # r_package_installed <pkg>
  if ! check_command Rscript; then return 1; fi
  Rscript -e "if (!requireNamespace('$1', quietly=TRUE)) quit(status=1)" \
    >/dev/null 2>&1
}

uv_tool_installed() {
  # uv_tool_installed <tool>
  if ! check_command uv; then return 1; fi
  uv tool list 2>/dev/null | grep -q "^$1\b" \
    || uv tool list 2>/dev/null | grep -qi "^$1 "
}

claude_mcp_has() {
  # claude_mcp_has <server-name>
  if ! check_command claude; then return 1; fi
  claude mcp list 2>/dev/null | grep -q "^$1" \
    || claude mcp list 2>/dev/null | grep -qi "^$1 "
}

# ----- platform abstraction ----------------------------------------------

assert_supported_os() {
  if [ "$DETECTED_OS" = "macos" ]; then
    return 0
  fi
  log_error "Unsupported platform: $(uname -s). This wizard supports macOS only."
  exit 3
}

# require_pkg_manager: ensure Homebrew is available.
# In dry-run mode, warn and continue.
require_pkg_manager() {
  require_brew
}

# ----- brew package helpers -------------------------------------------------

# pkg_install <brew-formula>
# Thin wrapper around brew_install_formula for backward compatibility.
pkg_install() {
  brew_install_formula "$1"
}

# check_pkg_installed <brew-formula>
# Check if a Homebrew formula is installed.
check_pkg_installed() {
  check_brew_formula "$1"
}

# ----- interactive_step ---------------------------------------------------
# interactive_step "description" "manual_command" "verify_command" "why_needed"
#
# Idempotent: runs verify_command first; returns 0 if already satisfied.
# Interactive: prints instructions, waits for user, verifies, retries up to 3.
# Headless: defers to DEFERRED_HINTS.
interactive_step() {
  local description="$1"
  local manual_command="$2"
  local verify_command="$3"
  local why_needed="${4:-}"

  # Already satisfied?
  if eval "$verify_command" >/dev/null 2>&1; then
    log_ok "$description (already satisfied)"
    return 0
  fi

  if [ "$DRY_RUN" = "1" ]; then
    log_dry "interactive_step: $manual_command"
    return 0
  fi

  # Headless: defer.
  if is_headless; then
    log_warn "$description requires interactive setup; deferring."
    defer_hint "$manual_command" "$description${why_needed:+ — $why_needed}"
    return 0
  fi

  # Interactive: instruct, wait, verify, retry.
  local attempt=0
  local max_attempts=3
  while [ "$attempt" -lt "$max_attempts" ]; do
    attempt=$((attempt + 1))
    printf '\n' >&2
    log_info "Manual step required: $description"
    log_info "Run this command in a terminal:"
    printf '  %s\n' "$manual_command" >&2
    [ -n "$why_needed" ] && log_info "Why: $why_needed"
    printf 'Press Enter when done (or type "skip" to skip)... ' >&2
    local reply=""
    if ! read -r reply </dev/tty 2>/dev/null; then
      read -r reply || reply="skip"
    fi
    reply="$(printf '%s' "$reply" | tr '[:upper:]' '[:lower:]')"
    if [ "$reply" = "skip" ] || [ "$reply" = "s" ]; then
      log_info "skipped: $description"
      return 0
    fi
    if eval "$verify_command" >/dev/null 2>&1; then
      log_ok "$description (verified)"
      return 0
    fi
    if [ "$attempt" -lt "$max_attempts" ]; then
      log_warn "verification failed; attempt $attempt/$max_attempts"
    fi
  done
  log_warn "$description: verification failed after $max_attempts attempts; deferring"
  defer_hint "$manual_command" "$description${why_needed:+ — $why_needed}"
  return 0
}

# defer_hint "command" "description"
# Standalone helper extracted from brew_install_pkg_cask for reuse.
defer_hint() {
  local cmd="$1"
  local desc="${2:-}"
  if [ -n "$DEFERRED_HINTS" ]; then
    DEFERRED_HINTS="${DEFERRED_HINTS}
${cmd}	${desc}"
  else
    DEFERRED_HINTS="${cmd}	${desc}"
  fi
}

# sudo_install <formula> [why_needed]
# On macOS, sudo installs are rare; fall through to brew_install_formula.
sudo_install() {
  local formula="$1"
  brew_install_formula "$formula"
}

# ----- runners -----------------------------------------------------------

# run_or_dry <command...>
# In dry-run mode, prints the command. Otherwise executes it.
# Returns the command's exit status.
run_or_dry() {
  if [ "$DRY_RUN" = "1" ]; then
    log_dry "$*"
    return 0
  fi
  "$@"
}

# brew_install_formula <formula>
brew_install_formula() {
  local f="$1"
  if check_brew_formula "$f"; then
    log_ok "brew formula already installed: $f"
    return 0
  fi
  run_or_dry brew install "$f"
}

# brew_install_cask <cask>
brew_install_cask() {
  local c="$1"
  if check_brew_cask "$c"; then
    log_ok "brew cask already installed: $c"
    return 0
  fi
  run_or_dry brew install --cask "$c"
}

# brew_install_pkg_cask <cask> <manual-command> <description>
# Like brew_install_cask but for .pkg-based casks that require sudo.
# Detects non-interactive environments (no tty + no cached sudo) and records a
# deferred hint instead of failing, so the wizard can continue cleanly.
# Call print_deferred_hints at the end of main() to surface skipped installs.
brew_install_pkg_cask() {
  local c="$1"
  local cmd="${2:-brew install --cask $c}"
  local desc="${3:-}"
  if check_brew_cask "$c"; then
    log_ok "brew cask already installed: $c"
    return 0
  fi
  if [ "$DRY_RUN" = "1" ]; then
    log_dry "brew install --cask $c"
    return 0
  fi
  # pkg-based casks invoke /usr/sbin/installer via sudo.  That requires either
  # cached sudo credentials or a controlling tty.  Detect both; if neither is
  # available, record a deferred hint and skip rather than failing hard.
  if ! sudo -n true 2>/dev/null && ! tty -s 2>/dev/null; then
    log_warn "$c requires sudo for its .pkg installer and no tty was detected."
    log_warn "Skipping — see manual step printed at the end of this script."
    if [ -n "$DEFERRED_HINTS" ]; then
      DEFERRED_HINTS="${DEFERRED_HINTS}
${cmd}	${desc}"
    else
      DEFERRED_HINTS="${cmd}	${desc}"
    fi
    return 0
  fi
  brew install --cask "$c"
}

# print_deferred_hints
# Prints a "finish manually" section for any installs that were skipped
# because no interactive tty was available or sudo was needed.
# Call at end of main().
print_deferred_hints() {
  [ -z "$DEFERRED_HINTS" ] && return 0
  printf '\n' >&2
  printf '===== Manual steps required =====\n' >&2
  printf 'The following tools require manual installation. Open a terminal\n' >&2
  printf 'and run these commands:\n' >&2
  printf '\n' >&2
  local line cmd desc
  printf '%s\n' "$DEFERRED_HINTS" | while IFS="	" read -r cmd desc; do
    [ -z "$cmd" ] && continue
    printf '  %s\n' "$cmd" >&2
    [ -n "$desc" ] && printf '    -> %s\n' "$desc" >&2
  done
  printf '\n' >&2
}

# ----- flag parsing ------------------------------------------------------

print_common_help_footer() {
  cat >&2 <<'EOF'

Common flags:
  --dry-run         Print actions without executing.
  --yes, -y         Assume yes for all prompts (non-interactive).
  --check           Run presence checks only; exit 0 if all present, 1 otherwise.
  --only <groups>   Comma-separated groups (master wizard only): base,shell-tools,python,r,typesetting,mcp-servers
  --preset <name>   One of: minimal, epi-demo, writing, everything (master wizard only)
  --help, -h        Show this help.
EOF
}

parse_common_flags() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --dry-run)  DRY_RUN=1 ;;
      --yes|-y)   ASSUME_YES=1 ;;
      --check)    CHECK_MODE=1 ;;
      --only)
        shift
        ONLY_GROUPS="${1:-}"
        ;;
      --only=*)   ONLY_GROUPS="${1#--only=}" ;;
      --preset)
        shift
        PRESET="${1:-}"
        ;;
      --preset=*) PRESET="${1#--preset=}" ;;
      --help|-h)  SHOW_HELP=1 ;;
      --)         shift; break ;;
      *)
        log_warn "unknown flag: $1 (ignored)"
        ;;
    esac
    shift || true
  done
}

# ----- preset expansion (master wizard) ----------------------------------

# preset_groups <name> -> prints space-separated group list to stdout
preset_groups() {
  case "$1" in
    minimal)    printf 'base shell-tools' ;;
    epi-demo)   printf 'base shell-tools python r typesetting' ;;
    writing)    printf 'base shell-tools typesetting' ;;
    everything) printf 'base shell-tools python r typesetting mcp-servers' ;;
    *)          return 1 ;;
  esac
}

# ----- exit trap ---------------------------------------------------------

on_exit() {
  local rc=$?
  if [ -n "$GROUPS_OK$GROUPS_SKIPPED$GROUPS_FAILED" ]; then
    printf '\n' >&2
    printf '===== Summary =====\n' >&2
    [ -n "$GROUPS_OK" ]      && printf 'OK:      %s\n' "$GROUPS_OK" >&2
    [ -n "$GROUPS_SKIPPED" ] && printf 'SKIPPED: %s\n' "$GROUPS_SKIPPED" >&2
    [ -n "$GROUPS_FAILED" ]  && printf 'FAILED:  %s\n' "$GROUPS_FAILED" >&2
  fi
  if [ "$rc" -ne 0 ] && [ "$rc" -ne 2 ]; then
    printf '[exit %d]\n' "$rc" >&2
  fi
  exit "$rc"
}

# ----- macOS gate --------------------------------------------------------

# DEPRECATED: use assert_supported_os instead. Kept for backward compatibility.
assert_macos() {
  assert_supported_os
}

assert_git_or_hint() {
  if ! check_command git; then
    log_error "git is not installed — run 'xcode-select --install' first"
    log_error "see docs/general/installation.md for step-by-step instructions"
    exit 3
  fi
}

# require_brew: in normal mode, fail hard if brew is missing. In dry-run mode,
# warn and continue so the wizard can still preview every group's actions.
require_brew() {
  if check_command brew; then
    return 0
  fi
  if [ "$DRY_RUN" = "1" ]; then
    log_warn "Homebrew not installed — dry-run continues, but real install would require it"
    return 0
  fi
  log_error "Homebrew is required; run install-base.sh first"
  exit 3
}
