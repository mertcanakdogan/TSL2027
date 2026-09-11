# Windows Export Readiness Test Specification

## Static checks

- `export_presets.cfg` defines a runnable `Windows Desktop` preset.
- `build/` and local Godot binaries remain ignored.
- The verifier fails clearly when Godot, the preset, or the output artifact is
  missing.

## Export checks

- `tools/verify_windows_export.ps1 -GodotPath <godot.exe>` produces the
  configured Windows executable.
- A non-zero export exit code or timeout fails the command and preserves the
  temporary log paths for diagnosis.

## Runtime smoke checks

- The exported executable starts with the embedded project data.
- `--headless --quit-after 3` returns exit code 0 within the configured
  timeout.
- A timeout terminates only the verifier-owned process and fails the check.

## Boundary

This verifies a local Windows artifact and a deterministic startup path. It is
not evidence that the binary has been tested on an independent clean machine.
