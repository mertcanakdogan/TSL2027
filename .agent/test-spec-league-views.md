# Test Specification — Fixture and Standings Views

## Acceptance tests

1. `test_fixture_query_returns_only_managed_team_matches`
   - The helper returns exactly 34 fixtures, each containing the managed team.
2. `test_fixture_query_is_isolated_from_league_state`
   - Mutating a returned fixture does not mutate the stored fixture.
3. `test_main_scene_creates_and_switches_league_views`
   - Fikstür and Lig Tablosu are real visible screens, not placeholders.
4. `test_playing_week_refreshes_league_views`
   - After one week, a managed fixture is played and the table has one match
     for every team.

## Red phase expectation

The main-scene test initially fails because the views and fixture query do not
exist. Completion requires the Python/data tests plus all existing Godot state,
match, and main-scene smoke tests to remain green.
