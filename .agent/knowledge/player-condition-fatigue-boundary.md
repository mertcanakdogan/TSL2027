# Player Condition and Fatigue Boundary

- SquadState owns mutable `condition` values keyed by player ID.
- A played week deducts 8 from starters; bench and unused players recover with
  caps at 100.
- Starting-XI records carry copied condition values into MatchEngine.
- Save schema 4 persists condition; schema 3 migrates missing values to 100.
- This is deterministic availability pressure, not a complete medical or
  training simulation.
