# Implementation Plan — Versioned Save and Load

**Date:** 2026-09-11
**Scope:** Persist the playable season, lineup, and tactics state safely

## Goal

Make the current offline session recoverable through one versioned JSON save
file. Validate the schema and active data-pack version before mutating runtime
state, and expose a clear failure for missing, corrupt, or incompatible saves.

## Components

1. `scripts/core/league_state.gd`
   - Exposes and validates a deep-copied league snapshot.
2. `scripts/core/squad_state.gd`
   - Exposes and validates starter/bench ID selections against the loaded
     immutable roster.
3. `scripts/core/save_game.gd`
   - Builds, writes, reads, validates, and restores a versioned payload.
   - Uses atomic validation before applying league, squad, or tactics changes.
4. `scripts/main.gd`
   - Adds Kaydet/Yükle actions using `user://tsl2027_save.json`.
5. `tests/save_game_test.gd`
   - Covers round-trip restoration, schema mismatch, and corrupt JSON.
6. Documentation
   - Records save schema and updates the release gate.

## Payload boundary

```text
save_schema_version + data_schema_version
  -> managed_team_id
  -> LeagueState snapshot
  -> SquadState IDs
  -> TacticsState snapshot
```

The save stores IDs and state, not a second copy of player source records.

## Explicit non-goals

- No multi-slot UI yet.
- No migration from a previous public save schema; version mismatch fails
  clearly until a migration exists.
- No provider payloads, API keys, logos, or photos.

## Acceptance criteria

- A saved week, played fixture results, starter/bench IDs, and tactics restore
  into the same initialized data pack.
- Missing/corrupt/wrong-schema files fail without partial runtime mutation.
- Save output is valid JSON and contains explicit save/data schema versions.
- Main UI exposes save/load actions and refreshes all views after load.
