# Windows Export Boundary

- `export_presets.cfg` is the source of truth for the Windows Desktop preset.
- `build/` is generated output and must stay ignored.
- `tools/verify_windows_export.ps1` performs two checks: export and packaged
  runtime startup.
- A successful local smoke test does not prove clean-machine compatibility,
  code signing, installer behavior, or third-party content licensing.
