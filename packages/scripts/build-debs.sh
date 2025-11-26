#!/usr/bin/env bash
set -euo pipefail

PACKAGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "${PACKAGE_ROOT}/.." && pwd)"
DIST_DIR="${PACKAGE_ROOT}/dist"
WORK_DIR="${PACKAGE_ROOT}/.build"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required tool: $1" >&2
    exit 1
  fi
}

read_control_field() {
  local field="$1"
  local file="$2"
  awk -F": " -v key="${field}" '$1 == key { print $2 }' "${file}" | head -n1
}

stage_metadata() {
  local package="$1"
  local stage_dir="$2"
  local metadata_dir="${PACKAGE_ROOT}/deb/${package}/DEBIAN"

  mkdir -p "${stage_dir}/DEBIAN"
  cp "${metadata_dir}/control" "${stage_dir}/DEBIAN/control"
  if [[ -f "${metadata_dir}/postinst" ]]; then
    cp "${metadata_dir}/postinst" "${stage_dir}/DEBIAN/postinst"
    chmod 755 "${stage_dir}/DEBIAN/postinst"
  fi
}

build_package() {
  local stage_dir="$1"
  local package_name="$2"
  local control_file="${stage_dir}/DEBIAN/control"
  local version arch output

  version=$(read_control_field "Version" "${control_file}")
  arch=$(read_control_field "Architecture" "${control_file}")
  output="${DIST_DIR}/${package_name}_${version}_${arch}.deb"

  dpkg-deb --build "${stage_dir}" "${output}"
  echo "Created ${output}"
}

stage_shell() {
  local stage_dir="${WORK_DIR}/aetheros-ai-shell"
  rm -rf "${stage_dir}"
  mkdir -p "${stage_dir}/opt/aetheros/ui"

  stage_metadata "ai-shell" "${stage_dir}"
  rsync -a "${PACKAGE_ROOT}/deb/ai-shell/files/" "${stage_dir}/"
  rsync -a "${REPO_ROOT}/ui/" "${stage_dir}/opt/aetheros/ui/"

  find "${stage_dir}/usr/bin" -type f -exec chmod 755 {} +
}

stage_core() {
  local stage_dir="${WORK_DIR}/aetheros-ai-core"
  rm -rf "${stage_dir}"
  mkdir -p \
    "${stage_dir}/opt/aetheros/ai-core" \
    "${stage_dir}/usr/lib/aetheros/bin" \
    "${stage_dir}/lib/systemd/system"

  stage_metadata "ai-core" "${stage_dir}"
  rsync -a "${PACKAGE_ROOT}/deb/ai-core/files/" "${stage_dir}/"
  rsync -a "${REPO_ROOT}/ai-core/" "${stage_dir}/opt/aetheros/ai-core/"
  rsync -a "${REPO_ROOT}/services/bin/" "${stage_dir}/usr/lib/aetheros/bin/"
  rsync -a "${REPO_ROOT}/services/systemd/" "${stage_dir}/lib/systemd/system/"

  find "${stage_dir}/usr/lib/aetheros/bin" -type f -exec chmod 755 {} +
}

main() {
  require_tool dpkg-deb
  require_tool rsync

  mkdir -p "${DIST_DIR}" "${WORK_DIR}"

  stage_shell
  stage_core

  build_package "${WORK_DIR}/aetheros-ai-shell" "aetheros-ai-shell"
  build_package "${WORK_DIR}/aetheros-ai-core" "aetheros-ai-core"
}

main "$@"
