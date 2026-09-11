# Portable Windows Release Test Specification

## Packaging

- Missing executable, README, LICENSE, or data-policy document fails clearly.
- Archive contains the executable and required attribution/policy files.
- `dist/` remains ignored by Git.

## Clean-directory verification

- Archive extracts without relying on the repository's project directory.
- Required files are present after extraction.
- Extracted executable starts with embedded game data and exits 0 in runtime
  smoke mode.
- A timeout terminates only the verifier-owned process.

## Boundary

This is a fresh-directory test on the current Windows host. It is not an
independent clean-machine, installer, or code-signing test.
