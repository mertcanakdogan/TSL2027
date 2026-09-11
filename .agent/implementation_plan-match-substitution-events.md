# Implementation Plan — Match Substitution Events

## Goal

Carry the existing bench snapshot into each team match context and expose
deterministic synthetic substitution events in match results and the dashboard
event text.

## Scope

1. Add `bench` to default and managed team contexts.
2. Generate up to three substitution events per team when a bench is present.
3. Include incoming/outgoing player names and bounded minutes in each event.
4. Add substitution counts to `match_stats`.
5. Format substitution events distinctly in `main.gd`.
6. Add engine and main-scene regression coverage.

## Data flow

`SquadState.get_bench()` → copied team context → `MatchEngine.simulate()` →
`events` and `match_stats` → dashboard/fixture summaries.

## Explicit non-goals

- No permanent in-match lineup mutation; the result is a report event only.
- No injury, suspension, red-card, or eligibility system in this slice.
- No claim that the synthetic three-event cap represents final competition
  regulations.
- No save schema change because the event output is already part of played
  fixture results.

## Acceptance criteria

- Contexts created by the main scene contain the seven-player bench snapshot.
- A context with a bench produces exactly three substitution events per team,
  each between minutes 46 and 90, with distinct incoming/outgoing names.
- A context without a bench preserves current behavior and produces no
  substitutions.
- Same seed and contexts reproduce the same substitution events.
- Dashboard formats substitutions as `Oyuncu değişikliği: out → in` rather than
  incorrectly labeling them as yellow cards.
