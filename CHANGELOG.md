# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- Functional Kadro screen with a deterministic 4-4-2 starting XI and bench swap flow.
- Headless Godot tests for squad state and main-scene screen switching.
- Deterministic synthetic player data for all 18 prototype teams.
- Versioned competition rules data pack for the 2026-2027 prototype season.
- Python generator, validator, and nine data-contract tests.
- Godot `DataPack` loader with explicit load-error state.

### Changed

- The dashboard now loads its team source through the runtime data pack and shows the loaded synthetic-player count.
