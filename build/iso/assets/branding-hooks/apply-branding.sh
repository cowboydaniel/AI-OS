#!/usr/bin/env bash
set -euo pipefail

# This script is meant to run inside the target rootfs (e.g., via preseed late_command)
# and applies lightweight AetherOS branding to a Mint-based installation.

if [[ $(id -u) -ne 0 ]]; then
  echo "apply-branding.sh must run as root to write system branding files." >&2
  exit 1
fi

BRAND_DIR="/usr/share/aetheros/branding"

write_wallpaper() {
  local target="$1"
  # 640x360 teal wallpaper encoded as PNG (no external binary asset required).
  base64 --decode >"$target" <<'WALLPAPER'
iVBORw0KGgoAAAANSUhEUgAAAoAAAAFoCAIAAABIUN0GAAAFk0lEQVR4nO3VQQ0AIBDAsLOCXQSgFxfsQZMK2G+zzgYAHpu8AAA+ZMAAEDBgAAgYMAAEDBgAAgYMAAEDBoCAAQNAwIABIGDAABAwYAAIGDAABAwYAAIGDAABAwaAgAEDQMCAASBgwAAQMGAACBgwAAQMGAACBgwAAQMGgIABA0DAgAEgYMAAEDBgAAgYMAAEDBgAAgYMAAEDBoCAAQNAwIABIGDAABAwYAAIGDAABAwYAAIGDAABAwaAgAEDQMCAASBgwAAQMGAACBgwAAQMGAACBgwAAQMGgIABA0DAgAEgYMAAEDBgAAgYMAAEDBgAAgYMAAEDBoCAAQNAwIABIGDAABAwYAAIGDAABAwYAAIGDAABAwaAgAEDQMCAASBgwAAQMGAACBgwAAQMGAACBgwAAQMGgIABA0DAgAEgYMAAEDBgAAgYMAAEDBgAAgYMAAEDBoCAAQNAwIABIGDAABAwYAAIGDAABAwYAAIGDAABAwaAgAEDQMCAASBgwAAQMGAACBgwAAQMGAACBgwAAQMGgIABA0DAgAEgYMAAEDBgAAgYMAAEDBgAAgYMAAEDBoCAAQNAwIABIGDAABAwYAAIGDAABAwYAAIGDAABAwaAgAEDQMCAASBgwAAQMGAACBgwAAQMGAACBgwAAQMGgIABA0DAgAEgYMAAEDBgAAgYMAAEDBgAAgYMAAEDBoCAAQNAwIABIGDAABAwYAAIGDAABAwYAAIGDAABAwaAgAEDQMCAASBgwAAQMGAACBgwAAQMGAACBgwAAQMGgIABA0DAgAEgYMAAEDBgAAgYMAAEDBgAAgYMAAEDBoCAAQNAwIABIGDAABAwYAAIGDAABAwYAAIGDAABAwaAgAEDQMCAASBgwAAQMGAACBgwAAQMGAACBgwAAQMGgIABA0DAgAEgYMAAEDBgAAgYMAAEDBgAAgYMAAEDBoCAAQNAwIABIGDAABAwYAAIGDAABAwYAAIGDAABAwaAgAEDQMCAASBgwAAQMGAACBgwAAQMGAACBgwAAQMGgIABA0DAgAEgYMAAEDBgAAgYMAAEDBgAAgYMAAEDBoCAAQNAwIABIGDAABAwYAAIGDAABAwYAAIGDAABAwaAgAEDQMCAASBgwAAQMGAACBgwAAQMGAACBgwAAQMGgMAFboTGGbiF7ukAAAAASUVORK5CYII=
WALLPAPER
}

mkdir -p "$BRAND_DIR"
write_wallpaper "$BRAND_DIR/wallpaper.png"

cat > /usr/share/glib-2.0/schemas/99_aetheros_branding.gschema.override <<'BRANDCFG'
[org.cinnamon.desktop.background]
picture-uri='file:///usr/share/aetheros/branding/wallpaper.png'
picture-options='zoom'
BRANDCFG

if command -v glib-compile-schemas >/dev/null 2>&1; then
  glib-compile-schemas /usr/share/glib-2.0/schemas
else
  echo "glib-compile-schemas not found; Cinnamon may not read branding overrides until compiled." >&2
fi

mkdir -p /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/50-aetheros-branding.conf <<'LIGHTDM'
[Seat:*]
greeter-setup-script=/usr/share/aetheros/branding/set-greeter-branding.sh
LIGHTDM

cat > "$BRAND_DIR/set-greeter-branding.sh" <<'GREETER'
#!/usr/bin/env bash
set -euo pipefail
if [[ -f /etc/lightdm/slick-greeter.conf ]]; then
  if ! grep -q '^background=' /etc/lightdm/slick-greeter.conf; then
    sed -i '/^\[Greeter\]/abackground=/usr/share/aetheros/branding/wallpaper.png' /etc/lightdm/slick-greeter.conf
  else
    sed -i 's#^background=.*#background=/usr/share/aetheros/branding/wallpaper.png#' /etc/lightdm/slick-greeter.conf
  fi
else
  cat > /etc/lightdm/slick-greeter.conf <<'GREETERCONF'
[Greeter]
background=/usr/share/aetheros/branding/wallpaper.png
GREETERCONF
fi
GREETER
chmod +x "$BRAND_DIR/set-greeter-branding.sh"

# Seed wallpaper for new users; existing profiles can opt-in manually.
skel_dir=/etc/skel/.config/aetheros
mkdir -p "$skel_dir"
cat > "$skel_dir/background.conf" <<'SKEL'
[org/cinnamon/desktop/background]
picture-uri='file:///usr/share/aetheros/branding/wallpaper.png'
picture-options='zoom'
SKEL

# Provide a small marker for support scripts.
echo "AetherOS branding applied on $(date --iso-8601=seconds)" > "$BRAND_DIR/version.txt"
