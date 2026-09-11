# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- Functional Kadro screen with a deterministic 4-4-2 starting XI and bench swap flow.
- Functional Taktikler screen with validated formation, mentality, marking, and bounded intensity controls.
- Managed XI and tactical context now influence deterministic attack, defense, control, xG, and possession profiles.
- Headless match-engine tests cover deterministic replay, player-context effects, and tactical directionality.
- Read-only Fikstür and Lig Tablosu screens now render from LeagueState and refresh after weekly simulation.
- Headless Godot tests for squad state and main-scene screen switching.
- Deterministic synthetic player data for all 18 prototype teams.
- Versioned competition rules data pack for the 2026-2027 prototype season.
- Python generator, validator, and nine data-contract tests.
- Godot `DataPack` loader with explicit load-error state.

### Changed

- The dashboard now loads its team source through the runtime data pack and shows the loaded synthetic-player count.
- Main-screen navigation now distinguishes dashboard, Kadro, and Taktikler views instead of treating Taktikler as a placeholder.
- LeagueState refreshes the managed team's copied match context before each simulated week.
- LeagueState exposes deep-copied managed-team fixtures for UI consumption.
