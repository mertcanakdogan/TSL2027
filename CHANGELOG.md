# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- Functional Kadro screen with a deterministic 4-4-2 starting XI and bench swap flow.
- Functional Taktikler screen with validated formation, mentality, marking, and bounded intensity controls.
- Managed XI and tactical context now influence deterministic attack, defense, control, xG, and possession profiles.
- Headless match-engine tests cover deterministic replay, player-context effects, and tactical directionality.
- Read-only Fikstür and Lig Tablosu screens now render from LeagueState and refresh after weekly simulation.
- Versioned JSON save/load now restores the season, fixture results, lineup IDs, and tactics with schema checks.
- Team Seç now starts a fresh week-one career for any of the 18 loaded prototype teams.
- Formation application now rebuilds the managed XI against centralized GK/DF/MF/FW requirements.
- Save payloads now persist active lineup formation and reject mismatched squad/tactics formations.
- Transfer screen now shows deterministic synthetic offers and performs budget-checked signings.
- Economy state now tracks balance, weekly revenue, wage budget, contracts, and weekly settlement.
- Match results now include deterministic goal/card events and bounded shot, corner, foul, card, possession, and xG statistics.
- Credits / Veri ekranı artık MIT kaynak kodu kapsamını ve sentetik veri sınırını oyun içinde görünür kılıyor.
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
- Main dashboard exposes Kaydet/Yükle actions under `user://tsl2027_save.json`.
- Managed-team identity is now dynamic across dashboard, squad, tactics, fixtures, context sync, and save/load validation.
- Formation changes are staged in the Taktikler screen and only mutate lineup/tactics/context after explicit application.
- Save schema version is now 2 because active lineup formation is part of the persisted state.
- Save schema version is now 3 because dynamic roster, economy, and transfer-market state are persisted.
- Transfer signing is atomic across market, economy, and SquadState; the transfer window closes after week 8.
- Match center and fixture rows now expose the managed match's synthetic stats and event summary.
