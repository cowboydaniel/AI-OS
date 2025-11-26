#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: remaster.sh --iso <path-to-mint-iso> [--workdir <dir>] [--output <iso>] [--volume <label>]
                    [--preseed <file>] [--kickstart <file>] [--branding-dir <dir>]
                    [--installer <file>] [--ui-src <dir>] [--services-src <dir>]
                    [--ai-core-src <dir>] [--config-src <dir>]

Extracts a Linux Mint ISO, injects AetherOS assets (preseed, kickstart, branding hooks,
AI shell, services, and installer), and rebuilds a hybrid ISO ready for writing to USB media.
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

assert_path_exists() {
  local label="$1"
  local path="$2"
  if [[ ! -e "$path" ]]; then
    echo "${label} not found: ${path}" >&2
    exit 1
  fi
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

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(realpath "$SCRIPT_DIR/../..")

ISO=""
WORKDIR="$REPO_ROOT/build/iso/work"
OUTPUT="$REPO_ROOT/artifacts/iso/aetheros-remaster.iso"
VOLUME="AETHEROS"
PRESEED="$SCRIPT_DIR/../assets/preseed.cfg"
KICKSTART="$SCRIPT_DIR/../assets/kickstart.ks"
BRANDING_DIR="$SCRIPT_DIR/../assets/branding-hooks"
INSTALLER="$SCRIPT_DIR/../assets/install-aetheros.sh"
UI_SRC="$REPO_ROOT/ui"
SERVICES_SRC="$REPO_ROOT/services"
AI_CORE_SRC="$REPO_ROOT/ai-core"
CONFIG_SRC="$REPO_ROOT/ai-core/config"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --iso) ISO="$2"; shift 2 ;;
    --workdir) WORKDIR="$2"; shift 2 ;;
    --output) OUTPUT="$2"; shift 2 ;;
    --volume) VOLUME="$2"; shift 2 ;;
    --preseed) PRESEED="$2"; shift 2 ;;
    --kickstart) KICKSTART="$2"; shift 2 ;;
    --branding-dir) BRANDING_DIR="$2"; shift 2 ;;
    --installer) INSTALLER="$2"; shift 2 ;;
    --ui-src) UI_SRC="$2"; shift 2 ;;
    --services-src) SERVICES_SRC="$2"; shift 2 ;;
    --ai-core-src) AI_CORE_SRC="$2"; shift 2 ;;
    --config-src) CONFIG_SRC="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$ISO" ]]; then
  echo "--iso is required" >&2
  usage
  exit 1
fi

require_cmd xorriso rsync sed realpath
MBR_BIN=$(find_isohybrid_mbr)

ISO_ABS=$(realpath "$ISO")
WORKDIR=$(realpath "$WORKDIR")
OUTPUT=$(realpath "$OUTPUT")
PRESEED=$(realpath "$PRESEED")
KICKSTART=$(realpath "$KICKSTART")
BRANDING_DIR=$(realpath "$BRANDING_DIR")
INSTALLER=$(realpath "$INSTALLER")
UI_SRC=$(realpath "$UI_SRC")
SERVICES_SRC=$(realpath "$SERVICES_SRC")
AI_CORE_SRC=$(realpath "$AI_CORE_SRC")
CONFIG_SRC=$(realpath "$CONFIG_SRC")

assert_path_exists "Mint ISO" "$ISO_ABS"
assert_path_exists "Preseed file" "$PRESEED"
assert_path_exists "Kickstart file" "$KICKSTART"
assert_path_exists "Branding directory" "$BRANDING_DIR"
assert_path_exists "Installer" "$INSTALLER"
assert_path_exists "UI source" "$UI_SRC"
assert_path_exists "Services source" "$SERVICES_SRC"
assert_path_exists "AI Core source" "$AI_CORE_SRC"
assert_path_exists "Config source" "$CONFIG_SRC"

STAGING="$WORKDIR/staging"
rm -rf "$STAGING"
mkdir -p "$STAGING"

echo "[1/5] Extracting ISO $ISO_ABS"
xorriso -osirrox on -indev "$ISO_ABS" -extract / "$STAGING"
chmod -R u+rw "$STAGING"

mkdir -p "$STAGING/aetheros"
rsync -a "$BRANDING_DIR" "$STAGING/aetheros/"
install -m 0644 "$PRESEED" "$STAGING/aetheros/preseed.cfg"
install -m 0644 "$KICKSTART" "$STAGING/aetheros/kickstart.ks"
install -m 0755 "$INSTALLER" "$STAGING/aetheros/install-aetheros.sh"

PAYLOAD_ROOT="$STAGING/aetheros/payload"
mkdir -p "$PAYLOAD_ROOT"
echo "[2/5] Staging AI shell, services, and configuration payload"
rsync -a "$UI_SRC/" "$PAYLOAD_ROOT/ui/"
rsync -a "$SERVICES_SRC/bin/" "$PAYLOAD_ROOT/services/bin/"
rsync -a "$SERVICES_SRC/systemd/" "$PAYLOAD_ROOT/services/systemd/"
rsync -a "$AI_CORE_SRC/ai_core/" "$PAYLOAD_ROOT/ai-core/ai_core/"
rsync -a "$CONFIG_SRC/" "$PAYLOAD_ROOT/config/"
find "$PAYLOAD_ROOT/services/bin" -type f -exec chmod 0755 {} +

APPEND_STRING="file=/cdrom/aetheros/preseed.cfg auto=true priority=critical"
append_kernel_params "$STAGING/isolinux/txt.cfg" "append" "$APPEND_STRING"
append_kernel_params "$STAGING/boot/grub/grub.cfg" "linux" "$APPEND_STRING"

if [[ ! -f "$STAGING/isolinux/isolinux.bin" ]]; then
  echo "isolinux/isolinux.bin missing from extracted ISO; unable to build bootable hybrid image." >&2
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT")"
echo "[3/5] Building hybrid ISO image"
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
  echo "[4/5] Ensuring hybrid boot compatibility"
  isohybrid --uefi "$OUTPUT"
else
  echo "isohybrid not available; relying on xorriso embedded hybrid configuration." >&2
fi

echo "[5/5] Done. Remastered ISO written to $OUTPUT"
