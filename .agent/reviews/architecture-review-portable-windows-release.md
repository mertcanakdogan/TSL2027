# Architecture Review: Portable Windows Release

## Decision

Use a portable ZIP as the first distribution shape. The package contains the
self-contained embedded-PCK executable and the minimum attribution/data-policy
documents needed by a recipient.

## Review notes

- Reproducibility: scripts use explicit inputs and emit an SHA256 digest.
- Isolation: staging and extraction happen in unique temporary directories;
  generated `dist/` output is ignored.
- Verification: the packaged executable is launched from the extraction path,
  so success does not depend on the repository checkout.
- Honest boundary: no claim is made about other Windows machines, installer
  behavior, or signing until those are separately tested.
