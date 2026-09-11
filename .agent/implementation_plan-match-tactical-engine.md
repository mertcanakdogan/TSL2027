# Implementation Plan — Player and Tactical Match Effects

**Date:** 2026-09-11
**Scope:** Connect managed XI and TacticsState to the deterministic match engine

## Goal

Make player selection and the Taktikler screen affect simulated match outputs
through a small, explicit formula. Keep the current team-strength model as the
fallback for unmanaged teams and preserve deterministic seeded simulation.

## Components

1. `scripts/core/match_engine.gd`
   - Accepts optional home/away context dictionaries.
   - Blends the selected XI's average attribute value with the team's synthetic
     strength using a named constant.
   - Applies explicit mentality and slider modifiers to attack, defense, and
     control profiles.
   - Returns profile values for auditability in match results.
2. `scripts/core/league_state.gd`
   - Stores optional per-team contexts separately from immutable team records.
   - Lets the managed team context be refreshed before a week is played.
3. `scripts/main.gd`
   - Synchronizes the current starter IDs/records and tactical snapshot before
     league simulation.
4. `tests/match_engine_test.gd`
   - Covers deterministic replay, player-context effects, tactic effects, and
     fallback behavior.
5. Documentation
   - Records the formula boundary and its synthetic-prototype status.

## Data flow

```text
SquadState first XI + TacticsState snapshot
                    -> managed team context
                    -> LeagueState
                    -> MatchEngine profile
                    -> seeded xG / score / possession result
```

## Explicit formula boundary

- `lineup_strength = mean(all numeric attributes in selected XI)`.
- `effective_base = team_strength + (lineup_strength - team_strength) * 0.35`.
- Mentality, marking, and sliders use named constants in `MatchEngine`; no
  hidden overall-rating field is introduced.
- The formula is a game-design prototype, not a claim about real player quality.

## Explicit non-goals

- No permanent in-match lineup mutation, injuries, or eligibility simulation yet;
  report-level card and substitution events are separate slices.
- No real player data or provider calls.
- No position-compatibility optimizer; the existing baseline lineup remains the
  source of selected XI until formation legality is implemented.

## Acceptance criteria

- Old calls without contexts still produce the same deterministic model shape.
- A stronger selected XI increases its team attack/defense profile relative to
  an otherwise equal team.
- A more attacking context increases attack output while reducing its defensive
  profile according to documented constants.
- Same seed plus same inputs returns an identical result dictionary.
- League simulation continues to advance weekly and only managed context is
  refreshed from mutable session state.
