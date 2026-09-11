---
type: decision
topic: Keep lineup state separate from immutable data-pack records
date: 2026-09-11
tags: [godot, squad, lineup, state-management]
---

## Summary

The Kadro slice keeps the source player records in `DataPack` and stores the mutable first XI/bench selection in a separate `SquadState` object. The initial selection is an explicit synthetic 4-4-2 baseline, not a hidden rating optimizer.

## Context

The first data-pack slice added 18 synthetic players per team, but the menu still had no playable squad decision. We needed a state boundary that could support swaps without changing `players.json` or prematurely coupling lineup decisions to the match engine.

## Decision / Finding

- `SquadState` owns only a deep-copied roster plus player IDs in `starting_ids`
  and `bench_ids`; runtime roster and bench limits come from `CompetitionRules`.
- Initialization requires valid team ownership, unique IDs, valid positions, and enough players for 1 GK, 4 DF, 4 MF, and 2 FW.
- The current prototype uses the roster's deterministic order for the explicit 4-4-2 baseline.
- A swap is allowed only between one starter and one bench player; it preserves group sizes.
- A full bench leaves a new signing unselected. `promote_to_bench()` explicitly
  displaces a selected bench player, after which the normal formation-aware
  swap path can promote the signing to the XI.

## Rationale

Writing selection state back into the data pack would turn immutable source data into session state and make saves/imports harder later. A hidden overall-rating sort would also add arbitrary weighting before the tactics and simulation contracts exist.

The rejected alternative was to let the UI mutate player dictionaries directly. That would make later save validation and provider imports fragile.

The source records stay immutable and the session owns group membership,
condition, formation, and save state. Formation legality is validated for
starter/bench swaps; role and selection policy remain deterministic rather than
rating-optimized.

## References

- `scripts/core/squad_state.gd`
- `scripts/ui/squad_view.gd`
- `tests/squad_state_test.gd`
- `tests/main_scene_smoke_test.gd`
- `.agent/reviews/architecture-review-squad-state.md`
