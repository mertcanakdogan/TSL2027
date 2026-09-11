# Windows Export Readiness Implementation Plan

## Objective

Make the Godot project reproducibly exportable as a Windows executable and
verify that the packaged application can start and exit cleanly in headless
smoke mode.

## Scope

- Add a versioned `Windows Desktop` export preset.
- Keep generated binaries under ignored `build/` output.
- Add a PowerShell verifier that exports, enforces a timeout, and runs the
  exported executable with `--headless --quit-after 3`.
- Document the distinction between local artifact verification and a clean
  machine acceptance test.

## Out of scope

- Code signing, installer creation, auto-update, crash reporting, or release
  hosting.
- Claiming clean-machine compatibility from a single developer workstation.

## Acceptance evidence

1. Godot export exits with code 0 and produces `build/TSL2027.exe`.
2. The packaged executable exits with code 0 in runtime smoke mode.
3. The verifier is documented and does not add the binary to Git.
