# Test Specification — Season End Summary

## Acceptance tests

### LeagueState boundary

- `get_season_summary()` returns `{}` while `current_week == 34`.
- `get_season_summary()` returns a champion after `current_week == 35`.
- The champion is the first row from `get_table()`.
- Exactly three relegated rows are returned.
- Relegated rows are the last three rows from `get_table()`.

### Regression

- Existing fixture query, weekly simulation, event retention, and standings
  behavior remain unchanged.
- No save schema migration is needed because the summary is derived state.

## Verification commands

```powershell
& $godot --headless --path . --script res://tests/league_views_test.gd --quit-after 2
& $godot --headless --path . --script res://tests/main_scene_smoke_test.gd --quit-after 3
.\tools\verify_project.ps1 -GodotPath $godot -SkipWindowsRelease
```

## Red/green expectation

The new assertions must fail before `LeagueState.get_season_summary()` exists,
then pass with the smallest implementation and no unrelated behavior changes.
