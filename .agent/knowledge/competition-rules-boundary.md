---
type: decision
topic: Runtime competition rule source
date: 2026-09-11
tags: [rules, data-pack, season, squad, save]
---

## Summary
`CompetitionRules` normalizes `game_rules.json` once during `DataPack` loading. League, squad, transfer-window, UI, and save validation consume the normalized season contract instead of duplicating the current season's constants.

## Context
The prototype had the season length, roster limit, bench size, and transfer window split between JSON, `main.gd`, `LeagueState`, and `SquadState`. That made an alternate season or test league able to pass data validation while still running a hardcoded 34-week or 7-player bench flow.

## Decision / Finding
`CompetitionRules` validates team count, two-leg fixture shape, week count, matchday squad size, substitutions, roster/bench limits, eligibility limits, and transfer-window bounds. `DataPack` also rejects mismatched schema/season metadata and mismatched team counts. `LeagueState` stores `season_label`, `season_weeks`, and `season_rounds` in its snapshot; `SaveGame` schema 5 persists them and migrates supported schema 3/4 payloads.

`SquadState` receives the normalized roster and bench limits. A full bench leaves a new signing in `unselected`; `promote_to_bench()` replaces an explicitly selected bench player while preserving group sizes, after which the existing formation-aware starter/bench swap path can promote the player to the XI.

## Rationale
A small normalized value object keeps the existing state ownership boundaries and avoids a large service layer. Optional defaults preserve direct unit-test callers, while loaded production data must pass the complete rule contract. Reserve promotion is explicit rather than silently evicting a bench player, so the user controls lineup availability.

## Consequences
New rule packs must keep the two-leg fixture invariant until fixture generation supports other formats. Any rule field added to `game_rules.json` should be parsed by `CompetitionRules` before runtime consumers use it. Save schema changes require a migration path and a semantic validation test. The next hardening step is property validation for fixture uniqueness and cross-state weekly transactions.

## References
- `scripts/core/competition_rules.gd`
- `scripts/core/data_pack.gd`
- `scripts/core/league_state.gd`
- `scripts/core/squad_state.gd`
- `scripts/core/save_game.gd`
- `tests/competition_rules_test.gd`
- `tests/squad_state_test.gd`
