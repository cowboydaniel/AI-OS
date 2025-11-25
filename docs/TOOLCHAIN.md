# Initial Toolchain Requirements

AetherOS builds on a Linux Mint Cinnamon remaster workflow. Install these tools before working on ISO builds, packaging, or developer scripts.

## Base OS and Shell
- Linux Mint 21.x (Cinnamon) or Ubuntu 22.04+ for parity with the target base image.
- Bash 5.x with `coreutils`, `curl`, and `tar`.

## Git and LFS
- `git` 2.34+ for worktree and sparse checkout support.
- `git-lfs` 3.3+ initialized via `git lfs install` to handle artifacts in `artifacts/iso/`.

## ISO Remastering Essentials
- `xorriso` and `isohybrid`/`syslinux-utils` for ISO unpack/repack.
- `squashfs-tools` for filesystem extraction and recompression.
- `rsync` for copying staged filesystem trees.
- `chroot` helpers (`debootstrap`/`systemd-nspawn`) for entering the remaster environment.

## Packaging and Build Helpers
- `python3` 3.10+ with `pip` for lightweight automation and validation scripts.
- `make` and `gcc` for compiling helper tools when required.

## Verification Tools
- `sha256sum` for checksum generation under `artifacts/checksums/`.
- `gpg` for signing release artifacts when keys are available.

Keep versions pinned in future build scripts and document any additional dependencies per directory README.
