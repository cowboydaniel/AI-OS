#!/usr/bin/env bash
set -euo pipefail

PAYLOAD_ROOT="/aetheros/payload"
INSTALL_PREFIX="/opt/aetheros"
CONFIG_DIR="/etc/aetheros"
SYSTEMD_DIR="/etc/systemd/system"
SERVICE_USER="aetheros"
SERVICE_GROUP="aetheros"

log() {
  echo "[install] $*"
}

require_dir() {
  local path="$1"
  if [[ ! -d "$path" ]]; then
    echo "Expected directory missing: $path" >&2
    exit 1
  fi
}

copy_tree() {
  local src="$1"
  local dest="$2"
  require_dir "$src"
  mkdir -p "$dest"
  cp -a "$src/." "$dest/"
}

if [[ $(id -u) -ne 0 ]]; then
  echo "install-aetheros.sh must run as root inside the target system." >&2
  exit 1
fi

require_dir "$PAYLOAD_ROOT"

if ! getent group "$SERVICE_GROUP" >/dev/null; then
  log "Creating system group $SERVICE_GROUP"
  groupadd --system "$SERVICE_GROUP"
fi

if ! id -u "$SERVICE_USER" >/dev/null 2>&1; then
  log "Creating system user $SERVICE_USER"
  useradd --system --gid "$SERVICE_GROUP" --home "$INSTALL_PREFIX" --shell /usr/sbin/nologin "$SERVICE_USER"
fi

log "Copying AI Core, UI, and service payload"
mkdir -p "$INSTALL_PREFIX" "$CONFIG_DIR"
copy_tree "$PAYLOAD_ROOT/ai-core" "$INSTALL_PREFIX/ai-core"
copy_tree "$PAYLOAD_ROOT/ui" "$INSTALL_PREFIX/ui"
copy_tree "$PAYLOAD_ROOT/services/bin" "$INSTALL_PREFIX/services/bin"
copy_tree "$PAYLOAD_ROOT/services/systemd" "$SYSTEMD_DIR"
copy_tree "$PAYLOAD_ROOT/config" "$CONFIG_DIR"

find "$INSTALL_PREFIX/services/bin" -type f -exec chmod 0755 {} +
find "$SYSTEMD_DIR" -maxdepth 1 -type f -name "aetheros-*" -exec chmod 0644 {} +

DEFAULT_CONFIG="$CONFIG_DIR/defaults.yaml"
TARGET_CONFIG="$CONFIG_DIR/ai-core.yaml"
if [[ -f "$DEFAULT_CONFIG" && ! -f "$TARGET_CONFIG" ]]; then
  cp "$DEFAULT_CONFIG" "$TARGET_CONFIG"
fi

mkdir -p /var/lib/aetheros/telemetry /var/log/aetheros /usr/share/applications /usr/share/aetheros
touch /var/lib/aetheros/telemetry/events.log
chown -R "$SERVICE_USER":"$SERVICE_GROUP" /var/lib/aetheros /var/log/aetheros "$INSTALL_PREFIX"

cat > /usr/share/applications/aetheros-shell.desktop <<'DESKTOP'
[Desktop Entry]
Name=AetherOS Shell
Comment=Launch the Mint-inspired AetherOS AI desktop shell
Exec=xdg-open /opt/aetheros/ui/index.html
Terminal=false
Type=Application
Categories=Utility;
Icon=preferences-system
StartupNotify=true
DESKTOP

if command -v systemctl >/dev/null 2>&1; then
  log "Enabling systemd units for AI Core, telemetry, and health checks"
  systemctl enable aetheros-ai-core.service aetheros-telemetry.service aetheros-healthcheck.timer >/dev/null 2>&1 || \
    echo "systemctl enable failed; ensure units are enabled after first boot." >&2
else
  echo "systemctl not available; enable aetheros services manually after install." >&2
fi

log "AetherOS payload installation complete"
