# Implementation Plan — Phase 1 Data Contract

**Date:** 2026-09-11
**Scope:** Synthetic player data contract and runtime data-pack loading

## Goal

Give the prototype a reproducible, license-safe source of player and competition data so later squad, tactics, and match-simulation work can consume structured inputs instead of team-level strength only.

## Components

1. `tools/generate_synthetic_data.py`
   - Reads the existing `data/teams.json`.
   - Deterministically generates one synthetic 18-player squad per team.
   - Writes `data/players.json` and `data/game_rules.json`.
   - Does not call the network or use real player identities.
2. `tools/validate_data_pack.py`
   - Validates metadata, team/player referential integrity, position coverage, attribute ranges, and competition rules.
   - Provides a command-line check suitable for CI later.
3. `scripts/core/data_pack.gd`
   - Loads the versioned JSON files for the Godot runtime.
   - Indexes players by team and reports load errors without mutating source data.
4. Existing dashboard integration
   - Uses `DataPack` as the source of teams instead of reading only `teams.json`.
   - Displays the loaded synthetic-player count as factual runtime state.
5. Documentation
   - Documents the schema, generation command, and the fact that attributes are synthetic prototypes.

## Data flow

```text
data/teams.json -> generate_synthetic_data.py -> data/players.json
                                      └-------> data/game_rules.json

players.json + teams.json + game_rules.json -> DataPack -> LeagueState/UI
```

## Explicit non-goals

- No web/API provider integration.
- No real player names, ratings, photos, badges, or provider payloads.
- No tactical effect or transfer logic in this slice.
- No overall rating derived from arbitrary hidden weights.

## Acceptance criteria

- The generator produces byte-stable JSON for the same repository inputs.
- Every team has exactly 18 synthetic players: 2 GK, 6 DF, 6 MF, 4 FW.
- Every player references an existing team and has a complete position-specific attribute set with values from 1 to 99.
- Competition rules are explicit and parseable, including 18 teams, 34 weeks, 21 matchday players, and 5 substitutions.
- The validator exits successfully for the checked-in data pack and reports useful failures for malformed data.
- The Godot data loader can expose teams, rules, and players-by-team with no network dependency.
- README, data documentation, roadmap, and session handoff describe the new source of truth.
