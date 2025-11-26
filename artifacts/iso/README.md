# ISO artifacts

This directory stores generated installer images and related checksums. ISOs and
other large binaries should be added via Git LFS—even when organized into
versioned subdirectories for different spins—while documentation like this
README remains standard text so it stays accessible when LFS objects are
unavailable. Use the checksum files to verify downloaded images before use.

Do not commit binary payloads directly to the repository. Publish built images
as release assets or other external downloads, and keep only the associated
checksums or signatures under Git LFS.

Upstream installer images (for example, the official Linux Mint ISOs) should
never be added to git because they are multi‑gigabyte binaries that will fail
normal pushes. Download them into `artifacts/iso/vendor/` (kept out of git via
`.gitignore`) or another local-only cache directory, then reference their
checksums in your build scripts when producing the remastered images. The
`download-mint-iso` GitHub Actions workflow follows this rule: it only pulls an
upstream ISO long enough to record its SHA256 checksum, extract its contents
for inspection, package those extracted files into a compressed artifact, and
publish the checksum alongside that archive. The downloaded image and
extraction workspace are deleted at the end of the workflow so nothing binary
is ever committed or pushed to git.
