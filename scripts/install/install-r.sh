#!/usr/bin/env bash
# install-r.sh - R toolchain (cross-platform)
#
# Core:       R, languageserver, lintr, styler
# renv:       install.packages("renv")
# Quarto:     brew cask (macOS), .deb download (Debian), AUR (Arch)
# Epi bundle: broader list of R packages for the epidemiology extension
#
# On Linux, configures Posit Package Manager (PPM) binary repository
# to avoid lengthy source compilation of R packages.
#
# All install.packages() calls force the cloud CRAN mirror to skip interactive
# mirror-selection prompts.
#
# Flags: --dry-run --yes --check --help
# Idempotent: every install guarded by presence check.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

CRAN_REPO="https://cloud.r-project.org"

# PPM (Posit Package Manager) binary repository for Linux.
# Set by configure_ppm() if available.
PPM_CONFIGURED=0

print_help() {
  cat >&2 <<'EOF'
install-r.sh - R toolchain

Installs:
  Core:
    - R (platform package manager)
    - languageserver, lintr, styler (install.packages via Rscript)
  Optional sub-groups (prompted):
    - renv    (project-local package manager)
    - Quarto  (cask on macOS, download on Linux)
    - Epi bundle (broader R packages for the epidemiology extension)

On Linux, configures Posit Package Manager (PPM) for binary R packages
to avoid slow source compilation.
EOF
  print_common_help_footer
}

# configure_ppm: set up Posit Package Manager binary repo on Linux.
# This provides pre-compiled R package binaries, avoiding source compilation.
configure_ppm() {
  if [ "$DETECTED_OS" = "macos" ]; then
    # macOS CRAN already provides binaries.
    return 0
  fi
  if [ "$PPM_CONFIGURED" = "1" ]; then
    return 0
  fi
  if ! check_command Rscript; then
    return 0
  fi

  # Detect distro codename for PPM URL.
  local codename=""
  if [ -f /etc/os-release ]; then
    codename="$(. /etc/os-release && printf '%s' "${VERSION_CODENAME:-}")"
  fi

  if [ -z "$codename" ]; then
    log_warn "could not detect distro codename; skipping PPM configuration"
    log_warn "R packages will be compiled from source (this can be slow)"
    return 0
  fi

  local ppm_url="https://packagemanager.posit.co/cran/__linux__/${codename}/latest"

  log_info "configuring Posit Package Manager (PPM) for binary R packages"
  log_info "PPM URL: $ppm_url"

  if [ "$DRY_RUN" = "1" ]; then
    log_dry "Rscript -e \"options(repos = c(PPM = '$ppm_url', CRAN = '$CRAN_REPO'))\""
    PPM_CONFIGURED=1
    return 0
  fi

  # Write PPM config to ~/.Rprofile (append if not already present).
  local rprofile="$HOME/.Rprofile"
  if [ -f "$rprofile" ] && grep -q "packagemanager.posit.co" "$rprofile" 2>/dev/null; then
    log_ok "PPM already configured in ~/.Rprofile"
    PPM_CONFIGURED=1
    return 0
  fi

  {
    printf '\n# Posit Package Manager (PPM) for binary R packages on Linux\n'
    printf 'local({\n'
    printf '  r <- getOption("repos")\n'
    printf '  r["PPM"] <- "%s"\n' "$ppm_url"
    printf '  r["CRAN"] <- "%s"\n' "$CRAN_REPO"
    printf '  options(repos = r)\n'
    printf '  options(HTTPUserAgent = sprintf("R/%%s R (%%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))\n'
    printf '})\n'
  } >> "$rprofile"

  log_ok "PPM configured in ~/.Rprofile"
  PPM_CONFIGURED=1
}

r_install_pkg() {
  # r_install_pkg <package>
  local pkg="$1"
  if r_package_installed "$pkg"; then
    log_ok "R package already installed: $pkg"
    return 0
  fi
  if [ "$DRY_RUN" = "1" ]; then
    log_dry "Rscript -e \"install.packages('$pkg', repos='$CRAN_REPO')\""
    return 0
  fi
  # On Linux, use timeout to prevent hanging on source compilation.
  if [ "$DETECTED_OS" != "macos" ] && check_command timeout; then
    log_info "installing R package: $pkg (timeout 600s)"
    timeout 600 Rscript -e "install.packages('$pkg', repos='$CRAN_REPO')" || {
      log_warn "R package '$pkg' install timed out or failed"
      return 1
    }
  else
    Rscript -e "install.packages('$pkg', repos='$CRAN_REPO')"
  fi
}

cleanup_r_locks() {
  # Remove stale 00LOCK-* directories left by previously interrupted installs.
  # R refuses to install into a locked directory, producing cryptic errors.
  if ! check_command Rscript; then return 0; fi
  local lib_dir
  lib_dir="$(Rscript --vanilla -e 'cat(.libPaths()[1])' 2>/dev/null || true)"
  [ -z "$lib_dir" ] && return 0
  local lock found=0
  for lock in "$lib_dir"/00LOCK-*; do
    [ -d "$lock" ] || continue
    log_warn "removing stale R package lock: $lock"
    rm -rf "$lock" && found=1 || log_warn "could not remove $lock (try: sudo rm -rf $lock)"
  done
  [ "$found" = "1" ] && log_info "stale locks cleared"
  return 0
}

do_core() {
  # Install R
  if ! check_command R; then
    case "$DETECTED_OS" in
      macos)
        brew_install_formula r
        ;;
      debian)
        pkg_install r
        pkg_install r-dev
        ;;
      arch)
        pkg_install r
        ;;
      *)
        log_warn "install R manually for your platform"
        ;;
    esac
  else
    log_ok "R already installed: $(R --version 2>&1 | head -1)"
  fi
  if ! check_command Rscript; then
    log_warn "Rscript missing after R install; aborting R package installs"
    return 0
  fi

  # Configure PPM for binary packages on Linux.
  configure_ppm

  cleanup_r_locks
  r_install_pkg languageserver
  r_install_pkg lintr
  r_install_pkg styler
}

do_renv() {
  if ! check_command Rscript; then return 0; fi
  if ! prompt_yn "Install renv (R project-local package manager)?"; then
    log_info "skipping renv"
    return 0
  fi
  r_install_pkg renv
}

do_quarto() {
  if check_command quarto; then
    log_ok "quarto already installed: $(quarto --version 2>&1)"
    return 0
  fi
  if ! prompt_yn "Install Quarto?"; then
    log_info "skipping Quarto"
    return 0
  fi
  case "$DETECTED_OS" in
    macos)
      brew_install_pkg_cask quarto \
        "brew install --cask quarto" \
        "Quarto: render .qmd/.Rmd notebooks to HTML/PDF/Word; required by the epidemiology (/epi) and reporting workflows"
      ;;
    debian)
      interactive_step "Install Quarto" \
        "Download and install from https://quarto.org/docs/get-started/ (or: wget https://github.com/quarto-dev/quarto-cli/releases/latest -O quarto.deb && sudo dpkg -i quarto.deb)" \
        "check_command quarto" \
        "Quarto renders .qmd/.Rmd notebooks to HTML/PDF/Word"
      ;;
    arch)
      # Try AUR helper first.
      if check_command yay; then
        run_or_dry yay -S --noconfirm quarto-cli-bin
      elif check_command paru; then
        run_or_dry paru -S --noconfirm quarto-cli-bin
      else
        interactive_step "Install Quarto" \
          "Install quarto-cli-bin from AUR or download from https://quarto.org/docs/get-started/" \
          "check_command quarto" \
          "Quarto renders .qmd/.Rmd notebooks to HTML/PDF/Word"
      fi
      ;;
    *)
      interactive_step "Install Quarto" \
        "Download from https://quarto.org/docs/get-started/" \
        "check_command quarto" \
        "Quarto renders .qmd/.Rmd notebooks to HTML/PDF/Word"
      ;;
  esac
}

# Epi bundle: survival, Bayesian, causal inference, missing data, plotting.
EPI_PKGS="survival survminer broom broom.mixed emmeans sandwich lmtest
  marginaleffects tidyverse data.table lubridate janitor here
  gtsummary ggeffects mice missRanger naniar
  epitools epiR Epi
  brms rstanarm tidybayes posterior bayesplot
  targets tarchetypes quarto knitr rmarkdown"

do_epi_bundle() {
  if ! check_command Rscript; then return 0; fi

  # Headless warning for Linux without PPM.
  if is_headless && [ "$DETECTED_OS" != "macos" ] && [ "$PPM_CONFIGURED" = "0" ]; then
    log_warn "Epi bundle installation on Linux without PPM may take 30+ minutes"
    log_warn "(source compilation required). Consider configuring PPM first."
    defer_hint "bash scripts/install/install-r.sh" \
      "Re-run R installer interactively to configure PPM and install epi bundle"
    return 0
  fi

  if ! prompt_yn "Install epidemiology R package bundle (~30 packages, may be slow)?" default_n; then
    log_info "skipping epi bundle"
    return 0
  fi

  # Count packages for progress logging.
  local total=0 count=0
  local pkg
  for pkg in $EPI_PKGS; do
    total=$((total + 1))
  done

  for pkg in $EPI_PKGS; do
    count=$((count + 1))
    log_info "Installing $count/$total: $pkg"
    r_install_pkg "$pkg" || log_warn "failed to install $pkg; continuing with remaining packages"
  done
}

run_check_mode() {
  local missing=0
  check_command R       && log_ok "R"       || { log_warn "[missing] R"; missing=1; }
  check_command Rscript && log_ok "Rscript" || { log_warn "[missing] Rscript"; missing=1; }
  r_package_installed languageserver && log_ok "languageserver" \
    || { log_warn "[missing] languageserver"; missing=1; }
  r_package_installed lintr  && log_ok "lintr"  || { log_warn "[missing] lintr"; missing=1; }
  r_package_installed styler && log_ok "styler" || { log_warn "[missing] styler"; missing=1; }
  r_package_installed renv   && log_ok "renv"   || log_warn "[optional-missing] renv"
  check_command quarto       && log_ok "quarto" || log_warn "[optional-missing] quarto"
  return "$missing"
}

main() {
  parse_common_flags "$@"
  if [ "$SHOW_HELP" = "1" ]; then print_help; exit 0; fi
  assert_supported_os
  print_section "install-r: R + languageserver/lintr/styler + optional extras ($DETECTED_OS)"

  if [ "$CHECK_MODE" = "1" ]; then
    run_check_mode
    exit $?
  fi

  require_pkg_manager

  do_core
  do_renv
  do_quarto
  do_epi_bundle

  print_deferred_hints
  log_info "install-r finished."
}

main "$@"
