# Implementation Plan — Squad Screen and Lineup State

**Date:** 2026-09-11
**Scope:** Functional Kadro screen with deterministic first XI/bench selection

## Goal

Turn the existing placeholder `Kadro` menu item into a real, testable squad-management slice without yet changing match simulation or introducing tactical effects.

## Components

1. `scripts/core/squad_state.gd`
   - Owns the selected team's roster copy, starting XI, and bench IDs.
   - Uses an explicit neutral 4-4-2 baseline: 1 GK, 4 DF, 4 MF, 2 FW.
   - Supports a two-player starter/bench swap.
   - Rejects unknown IDs, duplicate roster IDs, same-group swaps, and invalid roster ownership.
2. `tests/squad_state_test.gd`
   - Runs as a Godot headless script with no external framework.
   - Covers initialization, position counts, invalid input, and swap behavior.
3. `scripts/main.gd`
   - Builds a Kadro view from `DataPack.get_team_squad(USER_TEAM_ID)`.
   - Shows current first XI and bench groups.
   - Allows the user to select two players in sequence to swap them.
   - Keeps dashboard and placeholder screens separate through visibility state.
4. Documentation
   - Updates README, roadmap, changelog, current task, and the squad-state knowledge entry.

## Data flow

```text
DataPack.get_team_squad(kocaelispor)
              -> SquadState.initialize()
              -> starting_xi / bench IDs
              -> Kadro view
              -> two-player swap
```

## Explicit non-goals

- No overall-rating optimization or hidden weighting.
- No tactical effects, match-engine changes, transfers, or saves.
- No write-back into `players.json`; source data remains immutable.
- No claim that the 4-4-2 baseline reflects a real club lineup.

## Acceptance criteria

- A valid 18-player prototype roster initializes to 11 starters and 7 bench players.
- The default starting XI contains exactly 1 GK, 4 DF, 4 MF, and 2 FW.
- Every roster player is in exactly one group for the current 18-player prototype.
- Invalid roster ownership, duplicate IDs, unknown players, and same-group swaps are rejected without corrupting state.
- Swapping one starter and one bench player changes both groups deterministically.
- Clicking `Kadro` shows the real Kocaelispor prototype roster and the current group labels.
- Existing dashboard and weekly match simulation continue to work.
