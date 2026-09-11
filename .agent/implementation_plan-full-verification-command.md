# Full Verification Command Implementation Plan

## Objective

Provide one reproducible command that runs the project's automated checks and,
by default, the Windows release packaging chain.

## Scope

- Run all Godot headless tests and editor parse/import check.
- Run Python data validation and contract tests.
- Run Windows export, portable package, and fresh-directory package smoke,
  with an opt-out for non-Windows environments.
- Document the command and its release boundary.

## Out of scope

- Independent host testing, installer compilation, and code signing.

## Acceptance evidence

1. `tools/verify_project.ps1` exits 0 on the current configured host.
2. A failing sub-check stops the command with the specific failing stage.
3. Generated build/dist artifacts remain ignored.
