# Architecture Review — Player and Tactical Match Effects

**Date:** 2026-09-11
**Reviewer:** Agent

## Verdict

Approved with conditions

## Blockers

None.

## Conditions

1. The match engine must keep a context-free fallback so unmanaged teams do not
   require synthetic player records at runtime.
2. Every modifier must be a named constant or an explicitly documented lookup;
   no untraceable overall score may be introduced.
3. Result profile fields should remain inspectable so later balance work can be
   evaluated from deterministic fixtures rather than only final scores.
4. Current effects must be labeled as synthetic game-design rules. They are not
   ratings derived from official or licensed scouting data.
5. The league must copy context dictionaries at the boundary, preventing a UI
   container from mutating the active simulation unexpectedly.

## Notes

The context dictionary is intentionally a narrow seam for this prototype. A
future match-event model can replace its internal profile calculation while
preserving the `simulate(home, away, seed, home_context, away_context)` call
contract and deterministic test fixtures.
