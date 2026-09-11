# Full Verification Command Boundary

- `tools/verify_project.ps1` is the top-level local verification entry point.
- It runs 10 Godot tests, editor parse/import, Python data checks, and by
  default the Windows export/package/fresh-directory smoke chain.
- `-SkipWindowsRelease` is for environments without Windows export templates.
- Independent machine, installer, and code-signing acceptance remain outside
  this command.
- Windows PowerShell `Start-Process` must receive the `"Windows Desktop"`
  preset as one quoted argument. On this Godot build `ExitCode` can be empty
  after a completed GUI/console-wrapper process, so the verifier combines
  logged `ERROR` checks with artifact existence and runtime completion.
