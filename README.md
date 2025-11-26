# AetherOS

The AI-Native Operating System.

AetherOS is a Linux Mint Cinnamon remaster that treats the AI as the primary desktop. The AI Desktop Shell replaces launchers and menus with a conversational, command-aware interface that can translate natural-language requests into safe system actions.

## Repository standards
- Keep generated ISOs in `artifacts/iso/`; Git LFS handles storage. Store checksums in `artifacts/checksums/` for verification.
- Document build, packaging, and security decisions alongside the scripts that implement them to preserve reproducibility.
- Favor scripts and configs over binary assets. Large artifacts should be distributed via releases or LFS, never committed directly.
- Use focused branches and commits and include validation notes in pull requests. See `CONTRIBUTING.md` for the full guidelines.

## Directory structure
- `ai-core/` – Command translation logic, model runners, and sandboxing controls.
- `artifacts/` – LFS-tracked ISOs and checksums for releases.
- `build/` – Remaster tooling and ISO assembly steps.
- `docs/` – Build plans, toolchain requirements, and LFS guidance.
- `packages/` – Packaging manifests and build helpers.
- `.github/` – Issue templates and label catalog for roadmap tracking.
- `scripts/` – Developer utilities and automation entrypoints.
- `services/` – Systemd units and supporting daemon configs.
- `ui/` – AI Desktop Shell frontend assets and build tooling.

## Toolchain requirements
The remaster workflow expects a Mint-aligned environment with ISO tooling, Git LFS, and standard shell utilities. Review `docs/TOOLCHAIN.md` for version guidance and installation suggestions before running build scripts.

## Experience goals
- **AI-native command interface:** A persistent, cinematic terminal wallpaper accepts shell commands or natural language and executes through the AI Core.
- **OS-level integration:** Access to launchers, services, permissions, packages, filesystem operations, and hardware metrics is mediated safely by the AI.
- **Futuristic styling:** Dark, high-contrast visuals with subtle CRT-inspired effects keep the shell readable while conveying a sci-fi tone.

## Architecture snapshot
- **AI Core:** Local command translation layer with sandboxed execution and optional external model fallback.
- **System Shell Layer:** Graphical/terminal hybrid providing the AI Desktop Shell, persistent sessions, and wallpaper integration.
- **Background Services:** Secure relays for permissions, application orchestration, and telemetry.

## Installation and onboarding
Download the latest remastered ISO from the release page, verify the checksum/signature with the published release key, and flash it to a USB drive. Follow the guided installer, then run `scripts/bootstrap-dev.sh` on first boot to provision developer tooling and validate services. Additional release notes and platform-specific validation guidance live in `docs/RELEASE_READINESS.md`.

## Release and support cadence
- **Security updates:** monthly patch windows with emergency fixes for critical issues.
- **Feature updates:** quarterly feature drops aligned to roadmap phases.
- **LTS maintenance:** 12-month support window per major ISO with backported critical fixes.
- **Communication:** release notes and known issues posted alongside each tagged ISO; support threads pinned for Q&A.

## Contributing
AetherOS is in active development. Review `CONTRIBUTING.md`, pick issues from the roadmap, and propose changes using the provided issue templates.

## License
To be determined—final decision pending.

## Additional documents
- `docs/BUILD_PLAN.md` – High-level roadmap for build, packaging, services, and UI layers.
- `docs/ISO_LFS_PLAN.md` – How to handle installer ISOs with Git LFS and release artifacts.
- `docs/TOOLCHAIN.md` – Required tools and recommended versions for remastering and development.
- `docs/CI_CD.md` – Overview of CI/CD workflows, LFS enforcement, and smoke tests.
- `docs/RELEASE_READINESS.md` – Release notes, installer validation matrix, and signing/mirror guidance.
- `ROADMAP.md` – Phase-by-phase checklist for delivering the OS.
