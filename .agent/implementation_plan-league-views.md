# Implementation Plan — Fixture and Standings Views

**Date:** 2026-09-11
**Scope:** Replace Fikstür and Lig Tablosu placeholders with live LeagueState views

## Goal

Expose the existing 34-week fixture and standings state through navigable views
that refresh after a simulated week. Keep the dashboard summary and the full
views on the same `LeagueState` source of truth.

## Components

1. `scripts/core/league_state.gd`
   - Exposes copied fixtures for one team without allowing UI mutation.
2. `scripts/ui/fixture_view.gd`
   - Lists all 34 managed-team fixtures with week, venue, opponent, and status.
3. `scripts/ui/standings_view.gd`
   - Renders the full current table from `get_table()`.
4. `scripts/main.gd`
   - Wires Fikstür and Lig Tablosu navigation and refreshes both views after a
     week is played.
5. `tests/main_scene_smoke_test.gd`
   - Verifies screen switching and that a played fixture/table refreshes.
6. Documentation
   - Removes these two screens from the placeholder/release-blocker list and
     records the read-only boundary.

## Explicit non-goals

- No new competition rules or fixture generation algorithm.
- No UI-side standings calculation.
- No transfer behavior; Transfer remains a separate economy/market slice.

## Acceptance criteria

- Fikstür opens a real 34-row managed-team fixture list.
- Lig Tablosu opens a real full table from the same league state.
- Playing a week changes the relevant fixture from planned to played and
  updates table rows without reconstructing the season.
- Returned fixtures are deep copies so UI operations cannot mutate the source.
- Dashboard, Kadro, Taktikler, and weekly simulation remain functional.
