# Contributing to AetherOS

AetherOS builds on a Linux Mint Cinnamon remaster. The repository focuses on reproducible scripts, configs, and package metadata—not binary artifacts. Follow these standards to keep history clean and releases verifiable.

## Ground Rules
- **Prefer scripts over images:** Generated ISOs belong in `artifacts/iso/` and are tracked by Git LFS. Publish checksums/signatures alongside them instead of embedding binaries elsewhere in the repo.
- **Stay Mint-aligned:** Target Linux Mint Cinnamon as the base; document deviations explicitly.
- **Document decisions:** Add rationale to new scripts and configs so the remaster process stays repeatable.
- **Security first:** Describe privilege boundaries and sandboxing choices for any service or command executor changes.

## Workflow
- Create feature branches named `feature/<slug>` or `fix/<slug>`.
- Keep commits focused; prefer small, reviewable changes.
- Reference roadmap phases or issues in commit messages when possible (e.g., `Phase 2: add ISO repack script`).
- Run relevant lint/check scripts before opening a PR and note results in the PR description.

## Git LFS Requirements
- Ensure Git LFS is installed locally: `git lfs install`.
- ISOs and other large binaries must live under `artifacts/iso/` and will be captured by the `.gitattributes` rules.
- Verify that new ISO commits are stored as LFS pointers (`git lfs status` and `git show --stat`). Do not commit binaries outside the LFS paths.

## Code and Script Style
- Use POSIX shell with `set -euo pipefail` for bash scripts; include inline comments for external dependencies.
- Prefer Markdown for docs and keep sections short with actionable steps.
- Avoid committing editor/OS-specific files; respect `.gitignore` if added later.

## Pull Requests
- Describe the change, why it is needed, and how it was validated.
- Update documentation when behavior, interfaces, or build steps change.
- Include screenshots when altering UI assets.

## Support and Questions
Open a discussion or issue if you are unsure about Mint remaster details, LFS usage, or service security posture. Clear questions prevent churn and keep the roadmap moving.
