---
type: decision
topic: Keep fixture and standings views read-only over LeagueState
date: 2026-09-11
tags: [godot, fixtures, standings, ui, league-state]
---

## Summary

Fikstür and Lig Tablosu read from the same `LeagueState` that advances the
season. The views do not calculate matches or keep their own standings.

## Decision / Finding

- `LeagueState.get_fixtures_for_team()` returns deep-copied fixture records.
- `FixtureView` renders all 34 managed-team matches and shows planned/played
  status plus managed-team score.
- `StandingsView` renders the full table from `LeagueState.get_table()`.
- Both views refresh after `play_next_week()`.

## Boundary

Transfer remains separate. No fake transfer action is hidden behind this
slice; economy, contracts, eligibility, and persistence need their own state
contract.

## References

- `scripts/core/league_state.gd`
- `scripts/ui/fixture_view.gd`
- `scripts/ui/standings_view.gd`
- `tests/league_views_test.gd`
- `tests/main_scene_smoke_test.gd`
