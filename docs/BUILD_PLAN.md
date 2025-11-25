# AetherOS Build Plan

This document outlines an initial roadmap for building the AetherOS distribution and developer experience.

## Objectives
- Produce a reproducible Linux Mint Cinnamon-based ISO with the AI Desktop Shell preinstalled.
- Keep developer onboarding simple with scripted setup.
- Separate system layers (base OS, AI core, UI shell) to allow modular iteration.

## Proposed Repository Layout
- `build/` – Packer/ISO build configs, preseed/kickstart files, and scripts for remastering the installer.
- `packages/` – Deb or Flatpak packaging for the AI Desktop Shell and supporting services.
- `services/` – Systemd units and service definitions for the AI core, telemetry, and background daemons.
- `ui/` – Desktop shell assets (CSS/JS), wallpaper terminal, and frontend components.
- `ai-core/` – Command translation layer, local model runner hooks, and executor sandboxing.
- `scripts/` – Developer utilities (bootstrap, lint, packaging helpers).
- `artifacts/` – Generated ISOs and checksums (Git LFS tracked).

## Bootstrapping Tasks
1. **Environment setup script**
   - `scripts/bootstrap-dev.sh` to install build essentials, Git LFS, and ISO tooling (e.g., `xorriso`, `squashfs-tools`).
2. **ISO remaster skeleton**
   - Add `build/iso/` with placeholders for preseed/kickstart, post-install scripts, and branding assets.
3. **AI Desktop Shell stub**
   - Create a minimal UI mock (static HTML/CSS/JS) inside `ui/` to prototype the terminal wallpaper.
4. **Service definitions**
   - Draft systemd unit templates under `services/` for AI core, background tasks, and telemetry.
5. **Packaging strategy**
   - Decide between native `.deb` packages or Flatpaks for the shell and AI core; document in `packages/README.md`.
6. **CI hooks (future)**
   - Add lint/build pipelines that validate packaging manifests and enforce LFS rules for large binaries.

## ISO Build Flow (high level)
1. Fetch a Linux Mint Cinnamon base ISO.
2. Unpack the ISO and chroot into the filesystem.
3. Install AetherOS packages (AI shell, services, assets).
4. Apply branding and default settings (wallpaper, Cinnamon config, autostart entries).
5. Repack the ISO with updated boot menu and checksums.
6. Store the resulting ISO in `artifacts/iso/` (tracked by LFS) and generate a checksum in `artifacts/checksums/`.

## Open Questions
- Preferred inference runtime for local models (ONNX Runtime, GGML, CUDA-capable options?).
- Voice input pipeline dependencies (PipeWire, VAD model choice).
- Default security posture for command execution (policy-based allow/deny, sandboxing level).

This plan should evolve as we implement the directories and scripts above. Each section can be split into tracked issues for focused contributions.
