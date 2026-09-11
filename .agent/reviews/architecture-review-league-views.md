# Architecture Review — Fixture and Standings Views

**Date:** 2026-09-11
**Reviewer:** Agent

## Verdict

Approved with conditions

## Blockers

None.

## Conditions

1. Views must read from `LeagueState`; they must not recalculate results or
   maintain a second fixture/table model.
2. `get_fixtures_for_team()` must return deep copies at the UI boundary.
3. Refresh must be idempotent and safe before/after a week is played.
4. Transfer remains separate until money, contracts, eligibility, and save
   semantics have an explicit state contract.

## Notes

These views are deliberately read-only. That makes them useful release-slice
screens without introducing a second source of truth or hiding unfinished
transfer mechanics behind a fake button.
