# Architecture Review: Full Verification Command

## Decision

Use a PowerShell orchestrator that invokes existing focused verifiers rather
than duplicating their logic. The project test suite remains explicit and the
Windows chain is optional only for environments without export support.

## Review notes

- Failure locality: each child process is checked immediately and identifies
  the failed test or stage.
- Reuse: export/package logic stays in the existing scripts.
- Portability: `-SkipWindowsRelease` keeps data/core checks usable elsewhere;
  the normal Windows path remains the default on the target platform.
- Release honesty: this command does not claim independent-machine or signing
  validation.
