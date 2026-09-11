---
type: decision
topic: Keep tactical intent explicit and separate from lineup state
date: 2026-09-11
tags: [godot, tactics, match-engine, state-management]
---

## Summary

The Taktikler slice stores the manager's match plan in a dedicated
`TacticsState`. The state validates categorical choices and keeps every
continuous control on a documented 0–100 scale.

## Decision / Finding

- Supported formations are currently `4-4-2`, `4-3-3`, `4-2-3-1`, `3-5-2`, and
  `5-3-2`.
- Mentality and marking approach use explicit enumerations.
- Width, tempo, defensive line, pressing, build-up risk, directness, transition
  speed, and set-piece focus are bounded integers from 0 through 100.
- Invalid updates return false and preserve the previous state.
- `get_snapshot()` returns plain scalar values for future save/load and
  match-engine contracts.

## Boundary

The current screen records tactical intent and the managed team's first context
passes the snapshot into the deterministic profile/xG engine. Formation
selection still does not silently rewrite the first XI. Formation legality,
role suitability, and event-level tactical effects remain later slices with
their own tests.

## References

- `scripts/core/tactics_state.gd`
- `scripts/ui/tactics_view.gd`
- `tests/tactics_state_test.gd`
- `.agent/reviews/architecture-review-tactics-state.md`
