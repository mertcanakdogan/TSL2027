# Implementation Plan — Tactical State and Taktikler Screen

**Date:** 2026-09-11
**Scope:** Explicit match-plan state and a functional Taktikler screen

## Goal

Replace the Taktikler placeholder with a small, testable state model. The first
version records the manager's intended match plan without pretending that the
current match engine already applies every tactical variable.

## Components

1. `scripts/core/tactics_state.gd`
   - Owns formation, mentality, marking approach, and bounded 0–100 sliders.
   - Exposes explicit allowed values and a serializable snapshot.
   - Rejects invalid values without partially changing the current plan.
2. `tests/tactics_state_test.gd`
   - Covers defaults, valid updates, invalid updates, bounds, and snapshots.
3. `scripts/ui/tactics_view.gd`
   - Shows formation and categorical choices with `OptionButton` controls.
   - Shows width, tempo, defensive line, pressing, build-up risk, directness,
     transition speed, and set-piece focus as bounded sliders.
4. `scripts/main.gd`
   - Creates the tactical state after the data pack and squad are valid.
   - Switches between dashboard, Kadro, and Taktikler without placeholder text.
5. Documentation
   - Records that the first tactical state is ready for later match-engine
     integration; no tactical effect is claimed before scenario tests exist.

## Data flow

```text
TacticsState defaults
       -> Taktikler controls
       -> validated state snapshot
       -> future match-engine tactical modifiers
```

## Explicit non-goals

- No hidden overall-rating weights.
- No claim that the match engine already simulates every slider.
- No automatic formation-to-XI optimizer yet.
- No persistence yet; save/load is a separate release gate.

## Acceptance criteria

- A new state starts as `4-4-2`, balanced, zonal, with all numeric controls at
  50.
- Allowed categorical values can be changed and invalid values are rejected.
- Numeric tactical values accept 0–100 and reject values outside the range.
- Rejected changes leave the previous state unchanged.
- The Taktikler menu opens a real screen and does not show the placeholder.
- Dashboard, Kadro, and weekly simulation remain functional.
