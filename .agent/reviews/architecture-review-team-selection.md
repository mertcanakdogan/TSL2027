# Architecture Review — Team Selection and New Career Flow

**Date:** 2026-09-11
**Reviewer:** Agent

## Verdict

Approved with conditions

## Blockers

None.

## Conditions

1. `managed_team_id` must be the single runtime identity source; no view may
   infer it from display text.
2. Team changes must be explicit and reset all season state together. Opening
   the selector cannot silently discard progress.
3. Save/load must validate the selected team against the active squad and data
   pack, preserving cross-team rejection.
4. The data pack remains immutable and all selected-team state is copied into
   session objects.

## Notes

The first version intentionally starts every selected team at the same week-one
season state. Club-specific budgets, staff, venues, and difficulty modifiers
belong to later data contracts.
