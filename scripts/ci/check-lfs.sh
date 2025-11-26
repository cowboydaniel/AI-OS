#!/usr/bin/env bash
set -euo pipefail

THRESHOLD_BYTES=${THRESHOLD_BYTES:-10485760}
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

errors=()

# Verify large files are tracked by Git LFS
while IFS= read -r -d '' file; do
  size=$(stat -c%s "$file")
  if (( size > THRESHOLD_BYTES )); then
    attr=$(git check-attr filter -- "$file" | awk -F': ' '{print $3}')
    if [[ "$attr" != "lfs" ]]; then
      human_size=$(numfmt --to=iec --format="%.1f" "$size")
      errors+=("$file (size: $human_size, missing LFS filter)")
    fi
  fi
done < <(git ls-files -z)

# Enforce LFS for installer outputs in artifacts/iso/ (but allow docs)
while IFS= read -r -d '' iso_path; do
  case "$iso_path" in
    artifacts/iso/*.iso|artifacts/iso/*.sha256|artifacts/iso/*.sig)
      attr=$(git check-attr filter -- "$iso_path" | awk -F': ' '{print $3}')
      if [[ "$attr" != "lfs" ]]; then
        errors+=("$iso_path should be tracked by Git LFS via .gitattributes")
      fi
      ;;
  esac
done < <(git ls-files -z "artifacts/iso/**" 2>/dev/null)

if (( ${#errors[@]} > 0 )); then
  echo "Git LFS enforcement failed for the following files:" >&2
  printf ' - %s\n' "${errors[@]}" >&2
  echo "Set the filter to LFS or reduce the file size below $THRESHOLD_BYTES bytes." >&2
  exit 1
fi

echo "Git LFS checks passed: large files are using LFS and artifacts/iso/* is guarded."
