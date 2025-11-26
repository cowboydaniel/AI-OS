# ISO artifacts

This directory stores generated installer images and related checksums. ISOs and
other large binaries should be added via Git LFS—even when organized into
versioned subdirectories for different spins—while documentation like this
README remains standard text so it stays accessible when LFS objects are
unavailable. Use the checksum files to verify downloaded images before use.

Do not commit binary payloads directly to the repository. Publish built images
as release assets or other external downloads, and keep only the associated
checksums or signatures under Git LFS.
