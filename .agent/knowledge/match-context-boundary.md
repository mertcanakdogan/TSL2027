---
type: decision
topic: Pass managed lineup and tactics into the deterministic match engine
date: 2026-09-11
tags: [godot, match-engine, tactics, simulation, deterministic]
---

## Summary

`LeagueState` keeps optional per-team contexts separate from immutable team
records. Before a managed week is played, the current `SquadState` first XI and
`TacticsState` snapshot are copied into the context consumed by `MatchEngine`.

## Current formula

- The selected XI's mean numeric attribute value is blended with team strength
  using the named `LINEUP_STRENGTH_BLEND` constant (`0.35`).
- Mentality and bounded tactical controls modify attack, defense, and control
  profiles with named constants in `match_engine.gd`.
- Home advantage is explicit and results expose the derived profiles, xG, and
  possession for deterministic inspection.
- Teams without a context continue through the team-strength fallback.

## Boundary

This is a synthetic game-design model, not a real-player rating claim. It does
not yet model fatigue, events, cards, injuries, substitutions, roles, or
formation legality. Context dictionaries are deep-copied at the league
boundary so UI changes cannot mutate a result already being simulated.

## References

- `scripts/core/match_engine.gd`
- `scripts/core/league_state.gd`
- `scripts/main.gd`
- `tests/match_engine_test.gd`
- `.agent/reviews/architecture-review-match-tactical-engine.md`
