#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage: $0 --chroot <path> [--packages <dir>]
  --chroot   Path to the extracted root filesystem from the remastered ISO (required)
  --packages Directory containing built .deb files (default: packages/dist)

The script bind-mounts /dev, /proc, and /sys into the chroot, copies the
AetherOS .deb packages into /tmp/aetheros-packages inside the chroot, and
runs dpkg -i followed by apt-get -f install to validate installation.
USAGE
}

CHROOT=""
PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/dist"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --chroot)
      CHROOT="$2"
      shift 2
      ;;
    --packages)
      PACKAGE_DIR="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${CHROOT}" ]]; then
  echo "--chroot is required." >&2
  usage
  exit 1
fi

if [[ $(id -u) -ne 0 ]]; then
  echo "Run this script as root so mounts and chroot operations succeed." >&2
  exit 1
fi

if [[ ! -d "${CHROOT}" ]]; then
  echo "Chroot path ${CHROOT} does not exist." >&2
  exit 1
fi

if [[ ! -d "${PACKAGE_DIR}" ]]; then
  echo "Package directory ${PACKAGE_DIR} does not exist." >&2
  exit 1
fi

if ! compgen -G "${PACKAGE_DIR}/*.deb" >/dev/null; then
  echo "No .deb files found in ${PACKAGE_DIR}. Build packages before validating." >&2
  exit 1
fi

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required tool: $1" >&2
    exit 1
  fi
}

require_tool chroot
require_tool mount
require_tool umount

cleanup_mounts=()
cleanup() {
  for target in "${cleanup_mounts[@]}"; do
    if mountpoint -q "${target}"; then
      umount "${target}" || true
    fi
  done
}
trap cleanup EXIT

bind_mount() {
  local source="$1"
  local target="$2"
  mkdir -p "${target}"
  mount --bind "${source}" "${target}"
  cleanup_mounts+=("${target}")
}

bind_mount /dev "${CHROOT}/dev"
bind_mount /proc "${CHROOT}/proc"
bind_mount /sys "${CHROOT}/sys"

TEMP_DIR="${CHROOT}/tmp/aetheros-packages"
rm -rf "${TEMP_DIR}"
mkdir -p "${TEMP_DIR}"
cp "${PACKAGE_DIR}"/*.deb "${TEMP_DIR}/"

chroot "${CHROOT}" dpkg -i /tmp/aetheros-packages/*.deb || true
chroot "${CHROOT}" apt-get -f install -y

chroot "${CHROOT}" dpkg -l | grep "aetheros" || true

echo "Package validation inside ${CHROOT} completed."
