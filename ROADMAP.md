# AetherOS Roadmap

## Phase 1: Project Setup
- [x] Define repository standards and contributor guidelines
- [x] Initialize base directory structure
- [x] Configure Git LFS for ISO artifacts
- [x] Establish issue templates and labels
- [x] Document initial toolchain requirements

## Phase 2: ISO Remaster Skeleton
- [x] Create `build/iso/` scaffolding for Mint remaster
- [x] Add placeholder preseed/kickstart assets
- [x] Draft post-install branding hooks
- [x] Script unpack/repack flow for Mint ISO
- [x] Add checksum/signature generation stubs

## Phase 3: Developer Bootstrap
- [x] Implement `scripts/bootstrap-dev.sh`
- [x] Automate installation of ISO build dependencies
- [x] Automate Git LFS setup and validation
- [x] Add environment validation checks
- [x] Document bootstrap usage and troubleshooting

## Phase 4: AI Desktop Shell Stub
- [x] Create UI skeleton (HTML/CSS/JS)
- [x] Implement wallpaper terminal mock
- [x] Wire minimal navigation/layout
- [x] Add basic styling aligned with Mint look
- [x] Document UI build/test steps

## Phase 5: AI Core Foundations
- [x] Define command translation interfaces
- [x] Add local model runner hooks/stubs
- [x] Outline executor sandboxing approach
- [x] Provide configuration defaults
- [x] Document telemetry and logging expectations

## Phase 6: Service Layer
- [x] Draft systemd unit templates for AI core
- [x] Add background task/telemetry service definitions
- [x] Define service health checks
- [x] Wire service logs/metrics collection
- [x] Document deployment/service management

## Phase 7: Packaging Strategy
- [x] Decide between `.deb` or Flatpak for shell/core
- [x] Create `packages/README.md` with conventions
- [x] Provide sample packaging manifests
- [x] Add packaging build scripts
- [x] Validate packages inside remastered ISO

## Phase 8: ISO Build Automation
- [x] Finalize remaster scripts for Mint Cinnamon
- [x] Integrate AI shell and services into image
- [x] Apply branding (wallpaper, Cinnamon defaults)
- [x] Automate checksum/signature publishing
- [x] Store ISOs in `artifacts/iso/` via Git LFS pointers

## Phase 9: CI/CD Integration
- [x] Add lint/build pipelines for packages and scripts
- [x] Enforce LFS rules for large binaries
- [x] Automate ISO smoke tests in CI
- [x] Publish build artifacts to release storage
- [x] Document CI/CD workflows for contributors

## Phase 10: Release Readiness
- [x] Finalize documentation and release notes
- [x] Define support/update cadence
- [x] Validate installer on target platforms
- [x] Prepare signing keys and distribution mirrors
- [x] Announce availability and onboarding instructions
