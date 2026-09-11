# Architecture Review: Windows Export Readiness

## Decision

Use Godot's versioned `export_presets.cfg` plus a small PowerShell verifier.
Keep export output in ignored `build/` and keep temporary logs outside the
repository.

## Review notes

- Reproducibility: the preset and verification script are committed; the
  engine/template installation remains an environment prerequisite.
- Safety: the script uses explicit project/output paths, timeouts, and only
  terminates processes it started.
- Scope: no signing or installer complexity is introduced before the game
  content and licensing gates are complete.
- Release honesty: local export success is recorded separately from clean
  machine compatibility.

## Risks accepted

- Windows Defender or first-run import can make the export slower; the script
  exposes a bounded timeout and log paths.
- Code signing and distribution metadata are still release work.
