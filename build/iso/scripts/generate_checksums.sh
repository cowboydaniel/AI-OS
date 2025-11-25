#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: generate_checksums.sh --iso <file> [--manifest <path>] [--gpg-key <id>]

Generates SHA-256 and SHA-512 manifests for a remastered ISO. When a GPG key ID
is provided, the manifest is detached-signed for distribution.
USAGE
}

ISO=""
MANIFEST="artifacts/iso/aetheros-remaster.SHA256SUMS"
GPG_KEY=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --iso) ISO="$2"; shift 2 ;;
    --manifest) MANIFEST="$2"; shift 2 ;;
    --gpg-key) GPG_KEY="$2"; shift 2 ;;
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

mkdir -p "$(dirname "$MANIFEST")"

{
  echo "# Checksums for $(basename "$ISO") generated $(date --iso-8601=seconds)"
  sha256sum "$ISO"
  sha512sum "$ISO"
} > "$MANIFEST"

echo "Wrote checksums to $MANIFEST"

if [[ -n "$GPG_KEY" ]]; then
  if ! command -v gpg >/dev/null 2>&1; then
    echo "gpg not available; skipping signature." >&2
    exit 0
  fi
  gpg --batch --yes --local-user "$GPG_KEY" --detach-sign "$MANIFEST"
  echo "Generated detached signature ${MANIFEST}.sig using key $GPG_KEY"
fi
