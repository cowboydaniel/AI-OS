# Build Directory

This directory houses tooling for generating AetherOS installer media. The `iso/` subdirectory contains a working Mint remaster scaffold with:

- `assets/` containing preseed and kickstart automation files plus post-install branding hooks.
- `scripts/remaster.sh` to unpack a Mint ISO, inject AetherOS assets, and rebuild a hybrid image.
- `scripts/generate_checksums.sh` to produce checksum manifests and optional GPG signatures for the remastered output.

Keep the files here reproducible and scriptable; large binaries belong under `artifacts/iso/` and must be tracked with Git LFS as described in the repository standards.
