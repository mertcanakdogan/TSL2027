# Implementation Plan — Team Selection and New Career Flow

**Date:** 2026-09-11
**Scope:** Replace the fixed Kocaelispor identity with a selectable managed team

## Goal

Let the player choose any team in the loaded 18-team data pack and start a new
deterministic 2026/27 career. All managed-team views and the save contract must
follow the selected team.

## Components

1. `scripts/ui/team_selection_view.gd`
   - Lists loaded teams and emits an explicit new-career action.
2. `scripts/main.gd`
   - Stores `managed_team_id`/name instead of a fixed runtime identity.
   - Reinitializes league, squad, tactics, contexts, and views for the selected
     team.
   - Routes Team Seç navigation and keeps save/load team-aware.
3. Existing squad/tactics/fixture views
   - Receive the selected team name and no longer hardcode Kocaelispor.
4. Tests and documentation
   - Smoke test selects a different team, verifies its 18-player squad and
     fixture list, and confirms a new season starts at week one.

## Explicit behavior

- Changing team is an explicit “Yeni kariyer başlat” action and resets the
  current unsaved season.
- Existing save files for another team are rejected by the save contract.
- The data pack remains immutable; the selected team's roster is copied into
  `SquadState`.

## Acceptance criteria

- All 18 loaded teams appear in the selector.
- Selecting a team rebuilds the managed squad, fixtures, context, and views.
- No runtime screen title or save path assumes Kocaelispor.
- New career starts at week 1 with zero played matches.
- Existing squad, tactics, match, fixture, standings, save, and Python tests
  remain green.
