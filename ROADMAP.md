# AetherOS Roadmap

## Phase 1: Project Setup
- [x] Define repository standards and contributor guidelines
- [x] Initialize base directory structure
- [x] Configure Git LFS for ISO artifacts
- [x] Establish issue templates and labels
- [x] Document initial toolchain requirements

## Phase 2: ISO Remaster Skeleton
- [ ] Create `build/iso/` scaffolding for Mint remaster
- [ ] Add placeholder preseed/kickstart assets
- [ ] Draft post-install branding hooks
- [ ] Script unpack/repack flow for Mint ISO
- [ ] Add checksum/signature generation stubs

## Phase 3: Developer Bootstrap
- [ ] Implement `scripts/bootstrap-dev.sh`
- [ ] Automate installation of ISO build dependencies
- [ ] Automate Git LFS setup and validation
- [ ] Add environment validation checks
- [ ] Document bootstrap usage and troubleshooting

## Phase 4: AI Desktop Shell Stub
- [ ] Create UI skeleton (HTML/CSS/JS)
- [ ] Implement wallpaper terminal mock
- [ ] Wire minimal navigation/layout
- [ ] Add basic styling aligned with Mint look
- [ ] Document UI build/test steps

## Phase 5: AI Core Foundations
- [ ] Define command translation interfaces
- [ ] Add local model runner hooks/stubs
- [ ] Outline executor sandboxing approach
- [ ] Provide configuration defaults
- [ ] Document telemetry and logging expectations

## Phase 6: Service Layer
- [ ] Draft systemd unit templates for AI core
- [ ] Add background task/telemetry service definitions
- [ ] Define service health checks
- [ ] Wire service logs/metrics collection
- [ ] Document deployment/service management

## Phase 7: Packaging Strategy
- [ ] Decide between `.deb` or Flatpak for shell/core
- [ ] Create `packages/README.md` with conventions
- [ ] Provide sample packaging manifests
- [ ] Add packaging build scripts
- [ ] Validate packages inside remastered ISO

## Phase 8: ISO Build Automation
- [ ] Finalize remaster scripts for Mint Cinnamon
- [ ] Integrate AI shell and services into image
- [ ] Apply branding (wallpaper, Cinnamon defaults)
- [ ] Automate checksum/signature publishing
- [ ] Store ISOs in `artifacts/iso/` via Git LFS pointers

## Phase 9: CI/CD Integration
- [ ] Add lint/build pipelines for packages and scripts
- [ ] Enforce LFS rules for large binaries
- [ ] Automate ISO smoke tests in CI
- [ ] Publish build artifacts to release storage
- [ ] Document CI/CD workflows for contributors

## Phase 10: Release Readiness
- [ ] Finalize documentation and release notes
- [ ] Define support/update cadence
- [ ] Validate installer on target platforms
- [ ] Prepare signing keys and distribution mirrors
- [ ] Announce availability and onboarding instructions
