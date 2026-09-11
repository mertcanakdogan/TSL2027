# Portable Windows Release Boundary

- `tools/package_windows_release.ps1` creates the ignored
  `dist/TSL2027-windows-x64.zip` package.
- `tools/verify_windows_release.ps1` checks archive completeness and starts the
  executable from a fresh temporary extraction directory.
- The package ships the executable plus README, MIT LICENSE, and data-policy
  documentation.
- Independent-machine compatibility, installer behavior, and code signing are
  still external release gates.
