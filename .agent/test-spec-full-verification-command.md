# Full Verification Command Test Specification

- All 9 Godot test scripts execute and return exit 0.
- Godot editor headless parse/import check returns exit 0.
- Python validator and 9 Python tests return exit 0.
- Default Windows mode runs export, packaging, and fresh-directory smoke.
- `-SkipWindowsRelease` runs the project checks without requiring export
  templates.
- Missing Godot executable fails before mutating project output.
