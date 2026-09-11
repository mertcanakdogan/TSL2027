---
type: decision
topic: Use one dynamic managed-team identity for new career state
date: 2026-09-11
tags: [godot, team-selection, career, state-management, save-load]
---

## Summary

`main.gd` now owns `managed_team_id` and `managed_team_name` as the single
runtime identity. Team Seç only previews choices; the explicit Yeni Kariyeri
Başlat action rebuilds week-one league, squad, tactics, context, and views.

## Decision / Finding

- All 18 loaded teams are selectable.
- The selected roster is copied from `DataPack` into a fresh `SquadState`.
- Dashboard, Kadro, Taktikler, Fikstür, match context, and save/load use the
  selected ID rather than display text or a fixed Kocaelispor constant.
- Opening Team Seç does not reset progress; only the start action does.
- Existing saves for a different managed team remain rejected.

## Boundary

Every selected team currently starts from the same deterministic week-one
season rules. Budgets, venues, staff, club difficulty, and team-specific
objectives are intentionally later contracts.

## References

- `scripts/main.gd`
- `scripts/ui/team_selection_view.gd`
- `tests/main_scene_smoke_test.gd`
- `.agent/reviews/architecture-review-team-selection.md`
