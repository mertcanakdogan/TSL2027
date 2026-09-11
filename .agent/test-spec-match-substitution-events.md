# Test Specification — Match Substitution Events

## Acceptance tests

### MatchEngine

- Result contains `home_substitutions` and `away_substitutions` counts.
- Contexts with a non-empty bench produce three substitution events per side.
- Every substitution minute is 46–90 inclusive.
- Every substitution has `player_out` and `player_in`, and the names differ.
- Replaying the same seed/context gives an identical result.
- Missing bench data produces zero substitution events and keeps the current
  goal/card event contract intact.

### Main scene

- Every default league context carries seven bench players.
- The managed context keeps its bench after tactics/weekly sync.
- The full-season smoke path still finishes and shows the existing final summary
  without treating substitutions as cards.

## Verification commands

```powershell
& $godot --headless --path . --script res://tests/match_engine_test.gd --quit-after 2
& $godot --headless --path . --script res://tests/main_scene_smoke_test.gd --quit-after 3
.\tools\verify_project.ps1 -GodotPath $godot -SkipWindowsRelease
```

## Red/green expectation

The new assertions must fail before bench propagation and event generation are
implemented, then pass with no change to save schema or external dependencies.
