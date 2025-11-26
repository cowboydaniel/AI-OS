#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(realpath "$SCRIPT_DIR/../..")
GENERATOR="$SCRIPT_DIR/generate_checksums.sh"

usage() {
  cat <<'USAGE'
Usage: publish_release.sh --iso <file> [--dest <dir>] [--gpg-key <id>] [--skip-copy]

Copies a built ISO into artifacts/iso (or a chosen destination), generates
checksums, optionally signs them with GPG, and emits metadata ready for release.
USAGE
}

ISO=""
DEST="$REPO_ROOT/artifacts/iso"
GPG_KEY=""
COPY_ISO=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --iso) ISO="$2"; shift 2 ;;
    --dest) DEST="$2"; shift 2 ;;
    --gpg-key) GPG_KEY="$2"; shift 2 ;;
    --skip-copy) COPY_ISO=0; shift 1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$ISO" ]]; then
  echo "--iso is required" >&2
  usage
  exit 1
fi

if [[ ! -f "$ISO" ]]; then
  echo "ISO not found: $ISO" >&2
  exit 1
fi

ISO_ABS=$(realpath "$ISO")
mkdir -p "$DEST"
DEST=$(realpath "$DEST")

if [[ ! -x "$GENERATOR" ]]; then
  echo "Checksum generator not found at $GENERATOR" >&2
  exit 1
fi

ISO_TARGET="$ISO_ABS"
if [[ $COPY_ISO -eq 1 ]]; then
  ISO_TARGET="$DEST/$(basename "$ISO_ABS")"
  cp -a "$ISO_ABS" "$ISO_TARGET"
fi

ISO_NAME=$(basename "$ISO_TARGET")
MANIFEST="$DEST/${ISO_NAME}.SHA256SUMS"

"$GENERATOR" --iso "$ISO_TARGET" --manifest "$MANIFEST" ${GPG_KEY:+--gpg-key "$GPG_KEY"}

SHA256=$(awk 'NR==2 {print $1}' "$MANIFEST")
SHA512=$(awk 'NR==3 {print $1}' "$MANIFEST")
SIG_PATH=""
if [[ -f "${MANIFEST}.sig" ]]; then
  SIG_PATH=$(basename "${MANIFEST}.sig")
fi

SIGNATURE_FIELD="null"
if [[ -n "$SIG_PATH" ]]; then
  SIGNATURE_FIELD="\"$SIG_PATH\""
fi

cat > "$DEST/${ISO_NAME}.metadata.json" <<METADATA
{
  "iso": "$ISO_NAME",
  "size_bytes": $(stat -c%s "$ISO_TARGET"),
  "sha256": "$SHA256",
  "sha512": "$SHA512",
  "checksum_manifest": "$(basename "$MANIFEST")",
  "signature": $SIGNATURE_FIELD,
  "generated_at": "$(date --iso-8601=seconds)"
}
METADATA

echo "Release metadata written to $DEST/${ISO_NAME}.metadata.json"

if command -v git >/dev/null 2>&1; then
  REPO_TOP=$(git -C "$REPO_ROOT" rev-parse --show-toplevel 2>/dev/null || true)
  if [[ -n "$REPO_TOP" && "$ISO_TARGET" == "$REPO_TOP"/* ]]; then
    REL_PATH=$(realpath --relative-to="$REPO_TOP" "$ISO_TARGET")
    FILTER_ATTR=$(cd "$REPO_TOP" && git check-attr filter -- "$REL_PATH" | awk -F': ' '{print $2}')
    if [[ "$FILTER_ATTR" != "lfs" ]]; then
      echo "Warning: $REL_PATH is not tracked by Git LFS. Ensure large binaries stay out of standard git history." >&2
    fi
  fi
fi

