# Architecture Review — Tactical State and Taktikler Screen

**Date:** 2026-09-11
**Reviewer:** Agent

## Verdict

Approved with conditions

## Blockers

None.

## Conditions

1. `TacticsState` must remain separate from `SquadState`; a formation choice
   must not silently rewrite the XI until formation legality and role rules are
   specified and tested.
2. Numeric controls must have one documented 0–100 contract. Invalid values
   must not be silently accepted by the core state.
3. The screen may expose tactical intent now, but match-engine effects need
   deterministic scenario tests before they are presented as gameplay behavior.
4. A future save system should serialize `get_snapshot()` together with a data
   pack/schema version and validate it when restoring.

## Notes

The model is deliberately small: categorical choices are enumerated and the
continuous controls share a bounded scale. This keeps the next integration
step auditable and avoids burying gameplay design in UI callbacks.
