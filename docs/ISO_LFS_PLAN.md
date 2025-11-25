# Linux ISO Distribution via Git LFS

This plan covers how to ship the AetherOS installer ISO in this repository without bloating the Git history.

## Goals
- Keep the repo lightweight while sharing multi-gigabyte installer images.
- Provide a reproducible process for preparing and publishing ISOs.
- Make it obvious how to verify that the ISO is stored as an LFS pointer (not embedded in Git history).

## Directory Layout
- `artifacts/iso/`: location for release candidate and final ISO images.
- `artifacts/checksums/`: checksums generated for published ISOs.
- `build/`: scripts or packer configurations that produce the ISO (future work).

## LFS Tracking Rules
Tracking is configured in `.gitattributes`:
- `*.iso` is handled by Git LFS.
- Anything under `artifacts/iso/` is also tracked by LFS.

## Upload Workflow
1. **Install and initialize LFS**
   ```bash
   git lfs install
   ```

2. **Track the ISO path (already tracked globally via `.gitattributes`)**
   ```bash
   git lfs track "artifacts/iso/*.iso"
   ```
   > Note: Running this locally is idempotent and regenerates the same rule.

3. **Add the ISO and checksum**
   ```bash
   mkdir -p artifacts/iso artifacts/checksums
   cp /path/to/aetheros.iso artifacts/iso/aetheros-<version>.iso
   sha256sum artifacts/iso/aetheros-<version>.iso > artifacts/checksums/aetheros-<version>.sha256
   git add artifacts/iso/aetheros-<version>.iso artifacts/checksums/aetheros-<version>.sha256
   ```

4. **Verify LFS pointer before commit**
   ```bash
   git lfs status
   git diff --cached --stat
   git show --stat --cached | head -n 20  # should show an LFS pointer (~130 bytes)
   ```

5. **Commit and push**
   ```bash
   git commit -m "Add AetherOS ISO <version>"
   git push origin main
   ```

6. **Publish a GitHub release (recommended)**
   - Create a tag matching the ISO version (e.g., `v0.1.0-alpha`).
   - Draft a release referencing the ISO artifact path.

## Maintenance and Cleanup
- **Prune local LFS cache** periodically: `git lfs prune`.
- **Enforce LFS rules in CI** (future): add a check to reject commits that embed raw ISOs.
- **Mirror artifacts** to a CDN or cloud bucket if GitHub bandwidth becomes an issue.

## Verification Checklist
- [ ] `git lfs status` shows the ISO in the LFS tracked set.
- [ ] `git show` displays the pointer (not the raw binary content).
- [ ] SHA256 checksum file exists alongside the ISO.
- [ ] Release tag matches the ISO filename.
