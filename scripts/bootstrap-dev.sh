#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ALLOW_APT=true
DRY_RUN=false
APT_PACKAGES=(
  curl
  git
  git-lfs
  gnupg
  rsync
  xorriso
  squashfs-tools
  syslinux-utils
  isolinux
  genisoimage
)

log() { printf "[bootstrap] %s\n" "$*"; }
warn() { printf "[bootstrap][warn] %s\n" "$*"; }
error() { printf "[bootstrap][error] %s\n" "$*" >&2; exit 1; }

usage() {
  cat <<'USAGE'
Usage: scripts/bootstrap-dev.sh [options]

Prepare a local machine to build the AetherOS Mint-based ISO and contribute to the repository.

Options:
  --no-apt     Skip automatic apt-get installs (fail instead of installing missing packages)
  --dry-run    Show what would be installed without making changes
  --help       Show this help text
USAGE
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --no-apt)
        ALLOW_APT=false
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --help)
        usage
        exit 0
        ;;
      *)
        usage
        error "Unknown option: $1"
        ;;
    esac
  done
}

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || error "Missing required command: $cmd"
}

resolve_sudo() {
  if [[ $EUID -eq 0 ]]; then
    echo ""
    return
  fi

  if command -v sudo >/dev/null 2>&1; then
    echo "sudo -E"
  else
    error "This script needs root privileges for package installation; install sudo or re-run as root."
  fi
}

ensure_apt_available() {
  if ! command -v apt-get >/dev/null 2>&1; then
    error "apt-get is required for dependency installation. Use --no-apt to manage packages manually."
  fi
}

install_packages() {
  local sudo_cmd
  sudo_cmd=$(resolve_sudo)

  local missing=()
  for pkg in "${APT_PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done

  if [[ ${#missing[@]} -eq 0 ]]; then
    log "All ISO build dependencies already installed."
    return
  fi

  log "Missing packages: ${missing[*]}"

  if ! $ALLOW_APT; then
    error "Install the missing packages manually or re-run without --no-apt."
  fi

  if $DRY_RUN; then
    log "[dry-run] Would install: ${missing[*]}"
    return
  fi

  ensure_apt_available
  log "Updating apt cache..."
  ${sudo_cmd} apt-get update -y
  log "Installing build dependencies..."
  ${sudo_cmd} apt-get install -y "${missing[@]}"
}

setup_git_lfs() {
  if ! command -v git >/dev/null 2>&1; then
    error "git is required before configuring Git LFS."
  fi

  if ! command -v git-lfs >/dev/null 2>&1; then
    if $ALLOW_APT && ! $DRY_RUN; then
      log "Installing git-lfs..."
      local sudo_cmd
      sudo_cmd=$(resolve_sudo)
      ensure_apt_available
      ${sudo_cmd} apt-get install -y git-lfs
    else
      error "git-lfs is not available. Install it or run without --no-apt."
    fi
  fi

  if $DRY_RUN; then
    log "[dry-run] Would run: git lfs install --skip-repo"
    log "[dry-run] Would run: git lfs install (repo hooks)"
    return
  fi

  log "Configuring Git LFS globally..."
  git lfs install --skip-repo >/dev/null

  if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log "Ensuring Git LFS hooks are active for this repository..."
    git -C "$REPO_ROOT" lfs install >/dev/null
  fi

  if ! git lfs env >/dev/null 2>&1; then
    error "Git LFS environment check failed. Verify your Git configuration."
  fi

  if ! grep -q "artifacts/iso/**" "$REPO_ROOT/.gitattributes"; then
    warn "artifacts/iso/** not tracked in .gitattributes; large ISO files may bypass LFS."
  fi

  log "Git LFS is ready."
}

validate_environment() {
  log "Validating toolchain..."
  local required_cmds=(git git-lfs curl rsync xorriso mksquashfs isohybrid)
  for cmd in "${required_cmds[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
      log "Found $cmd"
    else
      warn "Missing $cmd. Install the related package before building ISOs."
    fi
  done

  if [[ ! -d "$REPO_ROOT/build/iso" ]]; then
    warn "Missing build/iso directory; ensure the repository is up to date."
  fi

  if [[ -d "$REPO_ROOT/artifacts/iso" ]] && [[ -n "$(ls -A "$REPO_ROOT/artifacts/iso" 2>/dev/null)" ]]; then
    log "Detected ISO artifacts directory; Git LFS should manage its contents."
  fi

  log "Environment validation finished."
}

main() {
  parse_args "$@"

  require_command "bash"

  log "Starting developer bootstrap for AetherOS..."
  install_packages
  setup_git_lfs
  validate_environment
  log "Bootstrap completed. You can begin ISO remaster work from $REPO_ROOT."
}

main "$@"
