#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: smoke-test.sh [--workdir <dir>] [--keep-workdir]

Creates a tiny base ISO with bootloader stubs, runs the remaster pipeline
against it, and produces checksum metadata. Intended for CI to verify that
remaster tooling and dependencies are intact.
USAGE
}

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
WORKDIR="$REPO_ROOT/build/iso/.ci-smoke"
KEEP_WORKDIR=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --workdir)
      WORKDIR="$2"
      shift 2
      ;;
    --keep-workdir)
      KEEP_WORKDIR=1
      shift 1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

require_cmd() {
  for cmd in "$@"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "Missing required command: $cmd" >&2
      exit 1
    fi
  done
}

find_isolinux_bin() {
  for candidate in /usr/lib/ISOLINUX/isolinux.bin /usr/lib/syslinux/isolinux.bin; do
    if [[ -f "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done
  echo "Unable to locate isolinux.bin. Install the 'isolinux' package." >&2
  exit 1
}

prepare_workspace() {
  if [[ -d "$WORKDIR" && $KEEP_WORKDIR -eq 0 ]]; then
    rm -rf "$WORKDIR"
  fi
  mkdir -p "$WORKDIR/base" "$WORKDIR/work" "$WORKDIR/output"
}

create_base_iso() {
  local base_tree="$WORKDIR/base/tree"
  local base_iso="$WORKDIR/base/base.iso"
  local isolinux_bin

  isolinux_bin=$(find_isolinux_bin)
  rm -rf "$base_tree"
  mkdir -p "$base_tree/isolinux" "$base_tree/boot/grub" "$base_tree/casper"

  cp "$isolinux_bin" "$base_tree/isolinux/isolinux.bin"
  dd if=/dev/zero of="$base_tree/boot/grub/efi.img" bs=1 count=1024 >/dev/null 2>&1

  cat > "$base_tree/isolinux/txt.cfg" <<'CFG'
default live
label live
  kernel /casper/vmlinuz
  append initrd=/casper/initrd quiet splash ---
CFG

  echo "placeholder kernel" > "$base_tree/casper/vmlinuz"
  echo "placeholder initrd" > "$base_tree/casper/initrd"
  cat > "$base_tree/boot/grub/grub.cfg" <<'GRUB'
set default="0"
set timeout=5
menuentry "Live" {
    linux /casper/vmlinuz quiet splash ---
    initrd /casper/initrd
}
GRUB

  xorriso -as mkisofs -o "$base_iso" -r -J -V "AETHEROS-SMOKE" "$base_tree" >&2
  echo "$base_iso"
}

run_remaster() {
  local base_iso="$1"
  local remastered="$WORKDIR/output/aetheros-smoke.iso"

  "$REPO_ROOT/build/iso/scripts/remaster.sh" \
    --iso "$base_iso" \
    --workdir "$WORKDIR/work" \
    --output "$remastered" \
    --volume "AETHEROS-CI"
}

generate_checksums() {
  local remastered_iso="$1"
  "$REPO_ROOT/build/iso/scripts/generate_checksums.sh" \
    --iso "$remastered_iso" \
    --manifest "$WORKDIR/output/$(basename "$remastered_iso").SHA256SUMS"
}

main() {
  require_cmd xorriso sed dd
  prepare_workspace

  echo "[smoke] Building base ISO..."
  local base_iso
  base_iso=$(create_base_iso)

  echo "[smoke] Running remaster against base ISO..."
  run_remaster "$base_iso"
  local remastered_iso="$WORKDIR/output/aetheros-smoke.iso"

  echo "[smoke] Generating checksums..."
  generate_checksums "$remastered_iso"

  echo "[smoke] Complete. Output located in $WORKDIR/output"
}

main "$@"
