# Developer Bootstrap

The `scripts/bootstrap-dev.sh` helper prepares a Mint-based workstation or development container to build the AetherOS remastered ISO. It installs required tooling, configures Git LFS, and validates that the repository layout is ready for ISO work.

## Prerequisites
- A Debian, Ubuntu, or Linux Mint environment with `apt-get` available.
- Ability to elevate privileges for package installation (root or `sudo`).
- Network access to install packages and Git LFS.

## Usage
Run the bootstrap script from the repository root:

```bash
./scripts/bootstrap-dev.sh
```

### Options
- `--no-apt` — fail if packages are missing instead of installing them automatically.
- `--dry-run` — show what would be installed or configured without making changes.
- `--help` — display usage information.

### What the script does
1. Installs ISO build dependencies (`git`, `git-lfs`, `curl`, `xorriso`, `squashfs-tools`, `syslinux-utils`, `isolinux`, `genisoimage`, and related helpers).
2. Configures Git LFS globally and for the current repository, matching the `.gitattributes` rules for ISO artifacts.
3. Verifies the presence of critical commands (e.g., `mksquashfs`, `isohybrid`) and checks that key directories such as `build/iso` exist.

## Troubleshooting
- **Missing sudo**: Run the script as root or install `sudo` so package installation can proceed.
- **apt unavailable**: Use `--no-apt` to see missing packages and install them manually on your platform.
- **Git LFS hook issues**: Re-run `git lfs install` inside the repository if LFS hooks were disabled; ensure `.gitattributes` still tracks `artifacts/iso/**` and `*.iso`.
- **Package mirrors blocked**: When running in constrained environments, use `--dry-run` to list requirements and install packages from an accessible mirror or offline cache.

## Next steps
After the bootstrap completes, follow the ISO remaster steps in `build/iso/` and continue with the Mint-based ISO tooling documented in `docs/TOOLCHAIN.md`.
