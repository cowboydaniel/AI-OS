# ISO Remaster Skeleton

This directory holds the assets and scripts required to remaster a Linux Mint ISO with AetherOS defaults.

## Contents
- `assets/preseed.cfg` – Debian/Ubuntu-style preseed used during non-interactive installs.
- `assets/kickstart.ks` – Kickstart variant for casper/oem-config flows.
- `assets/branding-hooks/` – Post-install hooks that generate a teal wallpaper and apply branding.
- `scripts/remaster.sh` – Extracts a Mint ISO, injects assets, and rebuilds a hybrid ISO.
- `scripts/generate_checksums.sh` – Generates SHA-256/SHA-512 manifests and optional GPG signatures for ISO outputs.

## Usage
1. Download a Linux Mint Cinnamon ISO and note its path.
2. Remaster it with bundled assets:
   ```bash
   ./build/iso/scripts/remaster.sh --iso ~/Downloads/linuxmint.iso --output artifacts/iso/aetheros-remaster.iso
   ```
3. Generate release metadata for the rebuilt image:
   ```bash
   ./build/iso/scripts/generate_checksums.sh --iso artifacts/iso/aetheros-remaster.iso --gpg-key YOURKEYID
   ```

The remaster script places assets under `/cdrom/aetheros/` inside the ISO, updates boot parameters to use the preseed
file automatically, and applies branding during the late install stage.
