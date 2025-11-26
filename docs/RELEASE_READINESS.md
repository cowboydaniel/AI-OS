# Release Readiness

This document captures the release notes and the operational checklist needed to publish the first public AetherOS image.

## Release notes
- **Mint-based remaster**: Linux Mint Cinnamon base with AetherOS defaults, wallpapers, and pre-configured package repos.
- **AI desktop shell**: Wallpaper terminal mock, navigation scaffold, and Mint-aligned styling for the initial UX surface.
- **AI core services**: Command translation interface, local model runner hooks, sandboxing approach, and telemetry defaults wired into systemd units.
- **Packaging**: Deb-centric packaging examples with build scripts and LFS-friendly artifact handling under `artifacts/iso/` and `artifacts/checksums/`.
- **Build and CI**: ISO rebuild pipeline, checksum/signature generation, and CI enforcement for lint/build, LFS rules, and ISO smoke tests.

## Support and update cadence
- **Security updates**: Monthly patch window (first full week of each month) with out-of-band patches for critical CVEs.
- **Feature updates**: Quarterly feature drops aligned to roadmap phases; minor UX fixes may be piggybacked on security windows when safe.
- **LTS maintenance**: Each major ISO is supported for 12 months with backports of critical fixes.
- **Communication**: Changelogs posted with each release; support status tracked in the repo issues board with `support-cycle` labels.

## Installer validation matrix
Run the installer validation checklist for each target and record the ISO build ID, checksum, and tester.

| Target platform | Status | Notes |
| --- | --- | --- |
| Bare metal (Mint-compatible hardware) | ✅ | Use secure boot off for first pass; confirm proprietary driver handling and post-install reboot. |
| VMware Workstation/ESXi | ✅ | Verify open-vm-tools presence and clipboard integration after install. |
| VirtualBox | ✅ | Confirm guest additions workflow and display scaling; test shared folders. |
| KVM/QEMU (virt-manager) | ✅ | Validate UEFI boot, spice/vdagent integration, and cloud-init datasource fallback. |

Validation steps:
1. Rebuild ISO via `build/iso/rebuild.sh` (or pipeline equivalent) and note the resulting filename in `artifacts/iso/`.
2. Verify checksum/signature using the current release key (see **Signing and mirrors**).
3. Perform guided install, then rerun `scripts/bootstrap-dev.sh` to confirm post-install developer bootstrap succeeds.
4. Capture logs: installer syslog, dmesg on first boot, and service health (`systemctl status aether-*`).
5. File validation results in the release issue template with screenshots where applicable.

## Signing keys and distribution mirrors
- **Key generation**: Create a dedicated release signing key (no personal keys) with `gpg --quick-gen-key "AetherOS Release <releases@aetheros.local>" rsa3072 cert 1y`.
- **Storage**: Export the armored public key to `artifacts/keys/aetheros-release.pub` (track with Git LFS) and publish it alongside checksums.
- **Usage**: Sign ISOs and checksums with `gpg --detach-sign --armor <file>`; verify with `gpg --verify` before publishing.
- **Rotation**: Rotate keys annually or upon compromise; maintain a `KEYS.md` changelog in `artifacts/keys/` documenting fingerprints and validity.
- **Mirrors**: Host primary downloads at `artifacts/iso/` via the release page; mirror to an object store/CDN with the same directory layout (`iso/`, `checksums/`, `signatures/`, `keys/`). Include checksum and key URLs in announcements.

## Announcement and onboarding
- Publish a release post summarizing the **Release notes**, installer validation matrix, and where to download the ISO/checksums/signatures.
- Share onboarding instructions linking to `docs/BOOTSTRAP.md` and `docs/BUILD_PLAN.md` for developers, and include minimal user steps (flash ISO, install, run `scripts/bootstrap-dev.sh`).
- Add the release to the repo `README.md` under a "Downloads" or "Latest Release" section with mirror and key links.
- Open a pinned discussion for Q&A and track known issues with a `known-issues` label; update support cadence as fixes land.
