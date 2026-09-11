# Season End Summary Boundary

- `LeagueState.get_season_summary()` is the single read-only source for the
  prototype's final champion and relegation rows.
- The method returns an empty dictionary through week 34 and derives the
  champion plus the last three table rows after the season (`current_week > 34`).
- `main.gd` formats the returned rows in the final match-center report; it does
  not calculate standings or mutate league state.
- This is a synthetic 18-team prototype rule, not a claim about final real-world
  2026/27 competition regulations.
