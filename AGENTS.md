# Repository Agent Guidance

## AetherOS build strategy
- Use a **Mint-based remaster with scripted ISO rebuilds**. AetherOS is anchored on Linux Mint Cinnamon; rebuild Mint ISOs with your package set and defaults instead of creating a new distro architecture.
- Keep the repository focused on **scripts, configs, and package specs** rather than storing large binaries. Generated ISOs belong in `artifacts/iso/` and should be tracked with **Git LFS** alongside checksums/signatures.
- Iterate in layers: start with the ISO build skeleton and developer bootstrap scripts, then add AI shell/service stubs and packaging before full ISO production.

## Contributor expectations
- Prefer documenting large artifacts (ISOs/images) as external release assets, not regular git objects.
- When updating build plans or docs, reflect the Mint remaster approach and LFS-based artifact handling.
- Binary files are **not supported** in this repository; never attempt to add a binary file to git history.
