# Player Condition and Fatigue Boundary

- SquadState owns mutable `condition` values keyed by player ID.
- A played week deducts 8 from starters; bench and unused players recover with
  caps at 100.
- Starting-XI records carry copied condition values into MatchEngine.
- Save schema 5 persists condition and season-rule fields; schema 3 migrates missing condition to 100, and schema 4 migrates missing league season fields.
- This is deterministic availability pressure, not a complete medical or
  training simulation.
