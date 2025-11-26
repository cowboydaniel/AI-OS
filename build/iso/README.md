# ISO Remaster Skeleton

This directory holds the assets and scripts required to remaster a Linux Mint ISO with AetherOS defaults.

## Contents
- `assets/preseed.cfg` – Debian/Ubuntu-style preseed used during non-interactive installs.
- `assets/kickstart.ks` – Kickstart variant for casper/oem-config flows.
- `assets/branding-hooks/` – Post-install hooks that generate a teal wallpaper and apply branding.
- `assets/install-aetheros.sh` – Installer run during late_command/%post to lay down the AI shell, services, and defaults.
- `scripts/remaster.sh` – Extracts a Mint ISO, injects assets, and rebuilds a hybrid ISO.
- `scripts/generate_checksums.sh` – Generates SHA-256/SHA-512 manifests and optional GPG signatures for ISO outputs.
- `scripts/publish_release.sh` – Copies an ISO into `artifacts/iso/`, produces checksum/signature metadata, and reminds contributors about Git LFS.

## Usage
1. Download a Linux Mint Cinnamon ISO and note its path.
2. Remaster it with bundled assets and the AI payload (UI, services, configs):
   ```bash
   ./build/iso/scripts/remaster.sh --iso ~/Downloads/linuxmint.iso --output artifacts/iso/aetheros-remaster.iso
   ```
   The remaster step stages the desktop shell (from `ui/`), service binaries and units (from `services/`), and AI Core package
   files (from `ai-core/`) under `/cdrom/aetheros`. During install, `install-aetheros.sh` provisions `/opt/aetheros`, copies
   systemd units to `/etc/systemd/system/`, seeds `/etc/aetheros/ai-core.yaml`, and enables AI Core + telemetry services.
3. Generate and publish release metadata for the rebuilt image:
   ```bash
   ./build/iso/scripts/publish_release.sh --iso artifacts/iso/aetheros-remaster.iso --gpg-key YOURKEYID
   ```
   The publish script writes checksum manifests, optional detached signatures, and a machine-readable metadata JSON file next
   to the ISO. It defaults to `artifacts/iso/`, which is already tracked by Git LFS.

The remaster script places assets under `/cdrom/aetheros/` inside the ISO, updates boot parameters to use the preseed
file automatically, applies branding during the late install stage, and seeds Cinnamon defaults for the AetherOS user.
