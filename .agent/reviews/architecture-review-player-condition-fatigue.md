# Architecture Review: Player Condition and Fatigue

## Decision

Keep condition in `SquadState` because it is mutable managed-roster state;
`MatchEngine` only consumes copied records. Weekly orchestration remains in
the main scene after LeagueState produces results.

## Review notes

- Determinism: fixed condition costs/recovery and a bounded 0-100 domain.
- Compatibility: save schema increments to 4 and explicitly migrates schema 3
  records that have no condition map.
- Safety: condition validation happens before restore and unknown player IDs are
  rejected.
- Scope: the prototype avoids inventing training/injury mechanics before a
  broader match-event model exists.
