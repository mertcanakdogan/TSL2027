---
type: decision
topic: Deterministic synthetic data pack for the first manager-game slice
date: 2026-09-11
tags: [godot, data-contract, synthetic-data, testing]
---

## Summary

The first post-prototype slice uses a deterministic, repository-safe JSON data pack for synthetic players and competition rules. The Godot runtime consumes the pack through a small loader; it does not call a football-data provider.

## Context

The existing vertical slice only had 18 teams and a team-level strength value. The next roadmap step needs player, squad, and rule inputs, but real player records, provider payloads, badges, and ratings have separate distribution and licensing concerns.

## Decision / Finding

- `data/teams.json` remains the team identity source.
- `tools/generate_synthetic_data.py` deterministically derives `data/players.json` and `data/game_rules.json`.
- Each prototype squad has a fixed position distribution of 2 GK, 6 DF, 6 MF, and 4 FW.
- Player attributes are position-specific 1–99 prototype values, not official ratings or copied provider data.
- `tools/validate_data_pack.py` is the source-independent structural gate.
- Godot loads the three JSON payloads with `scripts/core/data_pack.gd` and reports errors explicitly.

## Rationale

This keeps the client offline, avoids embedding API keys or unlicensed raw data, and gives future tactics and match code a stable contract. A provider importer can be added later without changing the runtime schema.

The rejected alternative was to connect API-Football or Sportmonks directly to the game. That would couple runtime behavior to network availability and provider terms before the game's data model has been tested.

## Consequences

Regenerate checked-in synthetic JSON only through the deterministic tool. Do not describe the values as scouting truth. Any composite rating or tactical weighting must be introduced later with isolated tests and explicit formulas.

## References

- `.agent/implementation_plan.md`
- `.agent/reviews/architecture-review-phase1-data-contract.md`
- `docs/DATA_AND_LICENSING.md`
- `docs/RESEARCH_AND_DECISIONS.md`
