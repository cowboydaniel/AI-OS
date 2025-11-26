# Packaging Strategy

AetherOS packages are delivered as `.deb` archives to integrate cleanly with
Mint-based systems and the remaster flow documented in `build/iso/`. Flatpak
is kept as a future distribution option for isolated UI delivery, but the core
shell and services ship as Debian packages so they can install systemd units
and share configuration with the base OS.

## Directory Layout

- `deb/` – Package manifests and payload files grouped by package name.
  - `ai-shell/` – Desktop entry, launcher, and web assets for the shell.
  - `ai-core/` – AI core code, systemd units, and default configuration.
- `scripts/` – Helper scripts for building and validating packages.
- `dist/` – Output directory for generated `.deb` files (created on demand).
- `.build/` – Temporary staging area used during package assembly.

## Build Conventions

- Keep package versions in the `DEBIAN/control` files; the build script reads
  them and names output artifacts accordingly.
- Do not commit generated `.deb` files—only manifests and helper scripts live
  in Git. Artifacts belong under `artifacts/` or release storage managed by LFS.
- File ownership defaults to the current user during `dpkg-deb` creation; the
  remaster process reassigns ownership to root when constructing the ISO.

### Building Packages

1. Ensure `dpkg-deb` and `rsync` are available on your build host.
2. Run the build helper from the repository root:
   ```bash
   ./packages/scripts/build-debs.sh
   ```
3. Find generated packages in `packages/dist/`:
   - `aetheros-ai-shell_<version>_all.deb`
   - `aetheros-ai-core_<version>_all.deb`

### Package Contents

- **aetheros-ai-shell**
  - Installs UI assets to `/opt/aetheros/ui`.
  - Provides `/usr/bin/aetheros-shell-launcher` and a desktop entry for Cinnamon.
- **aetheros-ai-core**
  - Installs the Python `ai_core` modules under `/opt/aetheros/ai-core`.
  - Ships service entrypoints in `/usr/lib/aetheros/bin` and systemd units in
    `/lib/systemd/system`.
  - Drops default configuration at `/etc/aetheros/ai-core/config.yaml`.

### Validating Inside the Remastered ISO

After running `build/iso/scripts/remaster.sh` to extract and rebuild the Mint
image, validate that packages install cleanly inside the remastered rootfs:

```bash
sudo ./packages/scripts/validate-in-iso.sh --chroot /path/to/remaster/chroot
```

The script bind-mounts `/dev`, `/proc`, and `/sys`, copies `.deb` files from
`packages/dist/`, installs them with `dpkg -i`, and resolves dependencies via
`apt-get -f install` inside the chroot. Review the output list of installed
packages to confirm the shell and core are present.
