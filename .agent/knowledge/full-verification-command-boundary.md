# Full Verification Command Boundary

- `tools/verify_project.ps1` is the top-level local verification entry point.
- It runs 9 Godot tests, editor parse/import, Python data checks, and by
  default the Windows export/package/fresh-directory smoke chain.
- `-SkipWindowsRelease` is for environments without Windows export templates.
- Independent machine, installer, and code-signing acceptance remain outside
  this command.
