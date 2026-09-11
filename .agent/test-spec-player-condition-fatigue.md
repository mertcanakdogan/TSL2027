# Player Condition and Fatigue Test Specification

## Squad state

- New players start at condition 100.
- Starting XI loses 8 condition per played match.
- Bench recovers 5 and unused roster players recover 8, capped at 100.
- Returned player records expose condition without mutating source data.

## Match state

- Condition is part of the copied starting-XI context.
- Lower condition reduces attack and defense profiles under the same seed.

## Save compatibility

- Schema 4 saves persist condition values.
- Schema 3 saves with no condition field migrate with condition 100.
- Existing validation and rollback behavior remains intact.
