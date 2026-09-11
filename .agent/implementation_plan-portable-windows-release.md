# Portable Windows Release Implementation Plan

## Objective

Produce a repeatable portable ZIP from the verified Windows executable and
validate that the package runs from a fresh extraction directory.

## Scope

- Package `TSL2027.exe`, `README.md`, `LICENSE`, and `docs/DATA_AND_LICENSING.md`.
- Keep generated `dist/` output ignored.
- Verify archive completeness and runtime startup from a unique temporary
  extraction directory.
- Record the clean-directory boundary separately from independent-machine and
  code-signing acceptance.

## Out of scope

- MSI/NSIS installer, signing certificate, auto-update, or GitHub Release
  publication.

## Acceptance evidence

1. Package script produces a ZIP and SHA256 digest.
2. Release verifier extracts the ZIP to a clean temporary directory and the
  packaged executable exits 0 in headless smoke mode.
3. Build/package artifacts remain outside tracked source files.
