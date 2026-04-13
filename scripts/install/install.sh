#!/usr/bin/env bash
# install.sh - Master installer wizard for .config/zed/ (cross-platform)
#
# Dispatches per-group installers in topological order:
#   base -> shell-tools -> python -> r -> typesetting -> mcp-servers
#
# Supported platforms: macOS, Debian/Ubuntu, Arch/Manjaro.
# NixOS is detected and exits with guidance (use configuration.nix instead).
#
# Each group runs in a subprocess (failure isolation): a failing group does
# not abort the wizard; it's recorded in GROUPS_FAILED and the summary prints
# a list at the end.
#
# Interactive mode prompts accept/skip/cancel per group. Presets and --only
# run non-interactively.
#
# Flags:
#   --dry-run            Print actions without executing (passed through).
#   --yes, -y            Auto-accept every prompt (passed through).
#   --check              Run each group's --check and print a consolidated report.
#   --only <groups>      Comma-separated group list (e.g., --only base,python,r).
#   --preset <name>      minimal | epi-demo | writing | everything
#   --help, -h           Show this help.
#
# Hard invariant: this script never reads any markdown file at runtime.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

# Topological order. The wizard never deviates from this in interactive mode.
ALL_GROUPS="base shell-tools python r typesetting mcp-servers"

print_help() {
  cat >&2 <<'EOF'
install.sh - Zed + Claude Code toolchain installer

Supported platforms: macOS, Debian/Ubuntu, Arch/Manjaro
NixOS: detected and exits with guidance (use configuration.nix/home.nix)

Usage:
  bash scripts/install/install.sh              # interactive wizard
  bash scripts/install/install.sh --dry-run    # preview every action
  bash scripts/install/install.sh --check      # health report only
  bash scripts/install/install.sh --preset epi-demo --dry-run
  bash scripts/install/install.sh --only base,python --yes

Groups (run in topological order):
  base          Build tools, package manager, Node.js, Zed, Claude Code CLI, SuperDoc+openpyxl MCP
  shell-tools   jq, gh, make (optional), fontconfig
  python        python, uv, ruff (+ optional uv tools, filetypes packages)
  r             R, languageserver/lintr/styler (+ optional renv, Quarto, epi bundle)
  typesetting   LaTeX, Typst, Pandoc, markitdown, fonts
  mcp-servers   rmcp, markitdown-mcp, mcp-pandoc (+ obsidian-memory pointer)

Presets:
  minimal       base + shell-tools
  epi-demo      base + shell-tools + python + r + typesetting
  writing       base + shell-tools + typesetting
  everything    all six groups
EOF
  print_common_help_footer
  cat >&2 <<'EOF'

Exit codes:
  0 = success
  1 = --check found missing tools
  2 = user cancelled
  3 = prerequisite failure (unsupported OS, missing git)
  4 = install failure in one or more groups (see FAILED in summary)

The wizard NEVER reads any .md file at runtime. See install-mcp-servers.sh
for the Lean MCP resurrection guard rationale.
EOF
}

describe_group() {
  case "$1" in
    base)
      printf '%s\n' "Build tools, package manager, Node.js, Zed, Claude Code CLI, SuperDoc + openpyxl MCP servers. This is the foundation -- run it first on any new machine."
      ;;
    shell-tools)
      printf '%s\n' "Shell utilities used by .claude/ hooks and commands: jq (JSON), gh (GitHub CLI), fontconfig (font checks), optional GNU make."
      ;;
    python)
      printf '%s\n' "Python 3 + uv + ruff for the editor experience, plus optional uv tools (pytest/mypy/ipython) and filetypes packages (pandas, python-pptx, markitdown, pymupdf, pdfannots)."
      ;;
    r)
      printf '%s\n' "R + languageserver/lintr/styler for the Zed editor experience, plus optional renv, Quarto, and the epidemiology R package bundle."
      ;;
    typesetting)
      printf '%s\n' "LaTeX, Typst, Pandoc, markitdown, and the Latin Modern / Computer Modern / Noto font family."
      ;;
    mcp-servers)
      printf '%s\n' "Extension MCP servers registered via 'claude mcp add --scope user': rmcp (epidemiology R modeling), markitdown-mcp, mcp-pandoc. obsidian-memory is a pointer-only (manual setup)."
      ;;
    *)
      printf 'Unknown group: %s\n' "$1"
      ;;
  esac
}

# Resolve which groups to run based on --preset, --only, or default (all).
resolve_groups() {
  if [ -n "$PRESET" ]; then
    if ! preset_groups "$PRESET" >/dev/null 2>&1; then
      log_error "unknown preset: $PRESET (valid: minimal, epi-demo, writing, everything)"
      exit 3
    fi
    preset_groups "$PRESET"
    return 0
  fi
  if [ -n "$ONLY_GROUPS" ]; then
    # Translate commas to spaces.
    printf '%s' "$ONLY_GROUPS" | tr ',' ' '
    return 0
  fi
  printf '%s' "$ALL_GROUPS"
}

append_group() {
  # append_group VAR group
  local var="$1"
  local g="$2"
  local cur
  eval "cur=\${$var}"
  if [ -z "$cur" ]; then
    eval "$var=\"\$g\""
  else
    eval "$var=\"\$cur \$g\""
  fi
}

# Build the argument vector we pass through to child scripts.
# Strips master-only flags (--preset, --only), keeps the rest.
build_child_args() {
  CHILD_ARGS=""
  if [ "$DRY_RUN" = "1" ];    then CHILD_ARGS="$CHILD_ARGS --dry-run"; fi
  if [ "$ASSUME_YES" = "1" ]; then CHILD_ARGS="$CHILD_ARGS --yes"; fi
}

dispatch_group() {
  local g="$1"
  local script="$SCRIPT_DIR/install-$g.sh"
  if [ ! -f "$script" ]; then
    log_error "missing group script: $script"
    append_group GROUPS_FAILED "$g"
    return 0
  fi
  build_child_args
  # Subprocess isolation: run in a child bash, don't let set -e abort wizard.
  # shellcheck disable=SC2086
  if bash "$script" $CHILD_ARGS; then
    append_group GROUPS_OK "$g"
  else
    log_error "group '$g' exited non-zero -- continuing wizard"
    append_group GROUPS_FAILED "$g"
  fi
}

run_check_mode() {
  print_section "install.sh --check  (consolidated health report)"
  build_child_args
  local groups g script any_missing=0
  groups="$(resolve_groups)"
  for g in $groups; do
    script="$SCRIPT_DIR/install-$g.sh"
    if [ ! -f "$script" ]; then
      log_warn "[missing-script] $g"
      any_missing=1
      continue
    fi
    printf '\n' >&2
    printf -- '--- %s ---\n' "$g" >&2
    if bash "$script" --check; then
      :
    else
      any_missing=1
    fi
  done
  if [ "$any_missing" -eq 0 ]; then
    print_section "health: OK"
    return 0
  fi
  print_section "health: some tools missing (see above)"
  return 1
}

interactive_wizard() {
  local groups="$1"
  local g
  for g in $groups; do
    prompt_accept_skip_cancel "$g" "$(describe_group "$g")"
    case "$PROMPT_ASC_RESULT" in
      accept)
        dispatch_group "$g"
        ;;
      skip)
        append_group GROUPS_SKIPPED "$g"
        log_info "skipped: $g"
        ;;
      cancel)
        log_warn "wizard cancelled by user at group: $g"
        exit 2
        ;;
    esac
  done
}

main() {
  parse_common_flags "$@"
  if [ "$SHOW_HELP" = "1" ]; then print_help; exit 0; fi

  # Honor trap after flag parsing so --help doesn't print an empty summary.
  trap on_exit EXIT INT TERM

  assert_supported_os

  # NixOS early exit (assert_supported_os handles nixos with exit 3,
  # but this provides additional context if reached).
  if [ "$DETECTED_OS" = "nixos" ]; then
    log_error "NixOS detected. This imperative wizard is not designed for NixOS."
    log_error "Add packages to your configuration.nix or home.nix, or use the"
    log_error "companion flake.nix when available."
    exit 0
  fi

  # linux-unknown warning (assert_supported_os already warned but didn't exit).
  if [ "$DETECTED_OS" = "linux-unknown" ]; then
    log_warn "Unrecognized Linux distribution. The wizard will attempt to continue"
    log_warn "but some package install commands may fail. Supported: macOS, Debian/Ubuntu, Arch/Manjaro."
  fi

  if [ "$CHECK_MODE" = "1" ]; then
    run_check_mode
    exit $?
  fi

  # git presence hint (wizard is usually run after git clone, so this is a
  # defensive assert).
  if ! check_command git; then
    log_warn "git is not installed. The wizard will install it (via build tools)."
    log_warn "If you have not cloned this repo with git yet, follow docs/general/installation.md."
  fi

  print_section "Zed + Claude Code toolchain wizard ($DETECTED_OS)"
  log_info "This wizard walks through 6 groups of installs. For each group you can"
  log_info "accept (a), skip (s), or cancel the wizard (c)."
  log_info "Use --preset epi-demo / --preset minimal / --dry-run to run non-interactively."

  local groups
  groups="$(resolve_groups)"
  log_info "groups to process: $groups"

  if [ -n "$PRESET" ] || [ -n "$ONLY_GROUPS" ]; then
    # Non-interactive path -- dispatch unconditionally, honoring ASSUME_YES.
    local g
    for g in $groups; do
      dispatch_group "$g"
    done
  else
    interactive_wizard "$groups"
  fi

  # on_exit will print the final summary.
  if [ -n "$GROUPS_FAILED" ]; then
    exit 4
  fi
  exit 0
}

main "$@"
