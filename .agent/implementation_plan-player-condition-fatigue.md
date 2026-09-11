# Player Condition and Fatigue Implementation Plan

## Objective

Make weekly lineup decisions matter by tracking managed-player condition,
applying deterministic post-match fatigue/recovery, and feeding readiness into
match profiles.

## Scope

- Add 0-100 condition state to SquadState.
- Deduct condition from starters after a played week and recover bench/unused
  players deterministically.
- Expose condition in Kadro and managed match contexts.
- Apply a documented low-condition penalty in MatchEngine.
- Persist condition and migrate schema 3 saves with a full-fit default.

## Out of scope

- Training plans, injuries, suspensions, travel, multiple matches in a week,
  or player-specific recovery traits.

## Acceptance evidence

1. Starter condition changes 100 -> 92 after a match while bench recovery is
   capped at 100.
2. Same-seed fresh vs fatigued XIs produce different attack/defense profiles.
3. Save schema 4 persists condition and schema 3 migrates without data loss.
