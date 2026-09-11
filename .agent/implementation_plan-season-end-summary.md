# Implementation Plan — Season End Summary

## Goal

When the 34-week league finishes, expose a small deterministic summary from
`LeagueState` and render it in the dashboard match center. Before the season
finishes, the summary must remain unavailable so an in-progress career cannot
show final standings prematurely.

## Scope

1. Add `LeagueState.get_season_summary()`.
2. Return the current table's first row as champion and last three rows as
   relegated teams only when `current_week > 34`.
3. Append readable champion/relegation lines to the final weekly dashboard
   report.
4. Cover the pre-finish and post-finish boundaries in the existing league
   headless test.
5. Update README, changelog, current task, and knowledge index.

## Data flow

`LeagueState.current_week` → `get_season_summary()` → dashboard's existing
`result_label`. `LeagueState.get_table()` remains the single source of truth;
the UI does not calculate or reorder final standings.

## Explicit non-goals

- No new save schema: `current_week` and standings already persist.
- No promotion/relegation into another season yet.
- No new external data or network dependency.
- No claim that the real 2026/27 TFF final rules are implemented beyond the
  existing synthetic 18-team prototype.

## Acceptance criteria

- In weeks 1–34, summary is an empty dictionary.
- After week 34, summary contains exactly one champion row and three relegated
  rows derived from `get_table()`.
- Dashboard output names the champion and all three relegated teams when the
  final week is played.
- Existing tests and the full local verification command remain green.
