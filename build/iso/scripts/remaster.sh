#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: remaster.sh --iso <path-to-mint-iso> [--workdir <dir>] [--output <iso>] [--volume <label>]
                    [--preseed <file>] [--kickstart <file>] [--branding-dir <dir>]

Extracts a Linux Mint ISO, injects AetherOS assets (preseed, kickstart, branding hooks),
and rebuilds a hybrid ISO ready for writing to USB media.
USAGE
}

require_cmd() {
  for cmd in "$@"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "Missing required command: $cmd" >&2
      exit 1
    fi
  done
}

find_isohybrid_mbr() {
  for candidate in /usr/lib/ISOLINUX/isohdpfx.bin /usr/lib/syslinux/isohdpfx.bin; do
    if [[ -f $candidate ]]; then
      echo "$candidate"
      return 0
    fi
  done
  echo "Unable to find isohybrid MBR binary (isohdpfx.bin). Install syslinux/isohybrid." >&2
  exit 1
}

append_kernel_params() {
  local file="$1"
  local matcher="$2"
  local addition="$3"
  [[ -f "$file" ]] || return 0
  if grep -q "$addition" "$file"; then
    return 0
  fi
  sed -i "/^${matcher}/s|$| ${addition}|" "$file"
}

ISO=""
WORKDIR="build/iso/work"
OUTPUT="artifacts/iso/aetheros-remaster.iso"
VOLUME="AETHEROS"
PRESEED="build/iso/assets/preseed.cfg"
KICKSTART="build/iso/assets/kickstart.ks"
BRANDING_DIR="build/iso/assets/branding-hooks"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --iso) ISO="$2"; shift 2 ;;
    --workdir) WORKDIR="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    --volume) VOLUME="$2"; shift 2 ;;
    --preseed) PRESEED="$2"; shift 2 ;;
    --kickstart) KICKSTART="$2"; shift 2 ;;
    --branding-dir) BRANDING_DIR="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$ISO" ]]; then
  echo "--iso is required" >&2
  usage
  exit 1
fi

require_cmd xorriso rsync sed
MBR_BIN=$(find_isohybrid_mbr)

ISO_ABS=$(realpath "$ISO")
WORKDIR=$(realpath "$WORKDIR")
OUTPUT=$(realpath "$OUTPUT")
PRESEED=$(realpath "$PRESEED")
KICKSTART=$(realpath "$KICKSTART")
BRANDING_DIR=$(realpath "$BRANDING_DIR")

STAGING="$WORKDIR/staging"
rm -rf "$STAGING"
mkdir -p "$STAGING"

echo "[1/4] Extracting ISO $ISO_ABS"
xorriso -osirrox on -indev "$ISO_ABS" -extract / "$STAGING"
chmod -R u+rw "$STAGING"

mkdir -p "$STAGING/aetheros"
rsync -a "$BRANDING_DIR" "$STAGING/aetheros/"
install -m 0644 "$PRESEED" "$STAGING/aetheros/preseed.cfg"
install -m 0644 "$KICKSTART" "$STAGING/aetheros/kickstart.ks"

APPEND_STRING="file=/cdrom/aetheros/preseed.cfg auto=true priority=critical"
append_kernel_params "$STAGING/isolinux/txt.cfg" "append" "$APPEND_STRING"
append_kernel_params "$STAGING/boot/grub/grub.cfg" "linux" "$APPEND_STRING"

if [[ ! -f "$STAGING/isolinux/isolinux.bin" ]]; then
  echo "isolinux/isolinux.bin missing from extracted ISO; unable to build bootable hybrid image." >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"
echo "[2/4] Building hybrid ISO image"
xorriso -as mkisofs \
  -r -V "$VOLUME" -o "$OUTPUT" \
  -J -l -cache-inodes \
  -isohybrid-mbr "$MBR_BIN" \
  -partition_offset 16 \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
  -no-emul-boot -isohybrid-gpt-basdat \
  "$STAGING"

if command -v isohybrid >/dev/null 2>&1; then
  echo "[3/4] Ensuring hybrid boot compatibility"
  isohybrid --uefi "$OUTPUT"
else
  echo "isohybrid not available; relying on xorriso embedded hybrid configuration." >&2
fi

echo "[4/4] Done. Remastered ISO written to $OUTPUT"
