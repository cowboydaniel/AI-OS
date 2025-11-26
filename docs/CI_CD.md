# CI/CD Workflows

This repository uses GitHub Actions to validate packages, enforce Git LFS
policies, and run ISO remaster smoke tests. The workflows are tuned for the
Mint-based remaster strategy and avoid embedding binaries in Git history.

## Workflows

### CI and Release Checks (`.github/workflows/ci.yml`)
- **Lint scripts and build packages**
  - Installs ShellCheck, rsync, and dpkg tooling on Ubuntu runners.
  - Lints all `*.sh` files.
  - Builds the `.deb` packages with `./packages/scripts/build-debs.sh` and
    uploads them as the `aetheros-debs` artifact.
- **Enforce Git LFS rules**
  - Runs `./scripts/ci/check-lfs.sh` to fail the build if files over 10 MiB are
    not tracked by LFS or if paths under `artifacts/iso/` bypass the LFS filter.
- **ISO smoke test**
  - Installs `xorriso`, `isolinux`, and `syslinux-utils`.
  - Executes `./build/iso/scripts/smoke-test.sh --workdir build/iso/.ci-smoke`
    to build a tiny base ISO, remaster it with repository assets, and generate
    checksums.
  - Publishes the remastered ISO and checksum manifest as the
    `aetheros-iso-smoke` artifact.

### Build and Publish AetherOS ISO (`.github/workflows/download-mint-iso.yml`)
- Scheduled weekly and on pushes to `main`.
- Downloads the Linux Mint Cinnamon ISO, remasters it with AetherOS assets using
  `build/iso/scripts/remaster.sh`, and regenerates the ISO.
- Produces a checksum manifest via `build/iso/scripts/generate_checksums.sh`.
- Publishes the rebuilt ISO and checksum file as GitHub release assets (no
  binaries are committed to git history).

## Running checks locally

- **Shell linting:** `shellcheck $(git ls-files "*.sh")`
- **Package build:** `./packages/scripts/build-debs.sh`
- **LFS enforcement:** `./scripts/ci/check-lfs.sh`
- **ISO smoke test:** `./build/iso/scripts/smoke-test.sh --workdir build/iso/.ci-smoke`

Ensure `xorriso`, `isolinux`, `syslinux-utils`, `rsync`, and `dpkg-deb` are
available before running the smoke test locally.
