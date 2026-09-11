# Season End Summary Boundary

- `LeagueState.get_season_summary()` is the single read-only source for the
  prototype's final champion and relegation rows.
- The method returns an empty dictionary through `season_weeks` and derives the
  champion plus the last three table rows after the configured season
  (`current_week > season_weeks`); it is not hardcoded to 34.
- `main.gd` formats the returned rows in the final match-center report; it does
  not calculate standings or mutate league state.
- This is a synthetic 18-team prototype rule, not a claim about final real-world
  2026/27 competition regulations.
