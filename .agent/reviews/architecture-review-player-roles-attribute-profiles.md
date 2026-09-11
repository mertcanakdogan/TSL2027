# Architecture Review: Player Roles and Attribute Profiles

## Decision

Keep role definitions and profile attribute groups in a pure `PlayerRoleRules`
core module. MatchEngine consumes copied player records and aggregates the
profiles; it does not mutate DataPack records or own role definitions.

## Review notes

- Explainability: each role/profile is an equal-weight arithmetic mean of a
  documented attribute list; no hidden learned or arbitrary per-team weights.
- Compatibility: missing role-specific fields fall back to the player's
  overall attribute mean, preserving support for minimal test contexts.
- Coverage: LeagueState receives default contexts from the main orchestrator,
  while an explicitly managed context still replaces only that team's entry.
- UI: SquadView only displays derived role information and remains read-only
  with respect to player state.
