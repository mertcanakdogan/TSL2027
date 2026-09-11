---
type: decision
topic: Persist only versioned runtime state under user storage
date: 2026-09-11
tags: [godot, save-load, persistence, migration, data-pack]
---

## Summary

`SaveGame` writes one inspectable JSON file to `user://tsl2027_save.json`. The
payload stores save schema 5, active data schema, normalized season metadata,
managed team, league/squad/tactics/economy/transfer snapshots, and condition.

## Decision / Finding

- Player source records remain in the checked-in data pack; saves store IDs and
  runtime state only.
- Payload validation happens before league, squad, or tactics state is applied.
- Missing, corrupt, unsupported save schema, and data-pack mismatch fail with an
  error message and do not mutate the current session.
- Schema 3 payloads receive default condition values; schema 4 payloads receive
  normalized league season fields before validation under schema 5.

## References

- `scripts/core/save_game.gd`
- `scripts/core/league_state.gd`
- `scripts/core/squad_state.gd`
- `scripts/main.gd`
- `tests/save_game_test.gd`
- `.agent/reviews/architecture-review-save-game.md`
