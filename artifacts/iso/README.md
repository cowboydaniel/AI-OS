# ISO artifacts

This directory stores generated installer images and related checksums. ISOs and
other large binaries should be added via Git LFS, but keep documentation like
this README as standard text so it remains accessible even when LFS objects are
unavailable. Use the checksum files to verify downloaded images before use.

Do not commit binary payloads directly to the repository. Publish built images
as release assets or other external downloads, and keep only the associated
checksums or signatures under Git LFS.
