# Project Knowledge Base

| Date | Type | Topic | Summary |
|------|------|-------|---------|
| 2026-09-11 | decision | [Deterministic synthetic data pack](./phase1-data-pack.md) | The first squad/data slice uses generated, license-safe JSON and a runtime loader instead of a live provider. |
| 2026-09-11 | decision | [Lineup state boundary](./squad-state-boundary.md) | Mutable starter/bench selection stays in SquadState and never mutates the immutable DataPack records. |
| 2026-09-11 | decision | [Tactics state boundary](./tactics-state-boundary.md) | Tactical intent is validated in a separate TacticsState; the managed context now reaches the profile engine while event effects remain future work. |
| 2026-09-11 | decision | [Match context boundary](./match-context-boundary.md) | Managed XI and tactical snapshots enter MatchEngine through copied optional contexts with deterministic, inspectable profile modifiers. |
| 2026-09-11 | decision | [League views boundary](./league-views-boundary.md) | Fixture and standings screens remain read-only views over copied fixtures and LeagueState table data. |
| 2026-09-11 | decision | [Save game boundary](./save-game-boundary.md) | Versioned JSON stores runtime IDs/state under user storage and validates before any restore mutation. |
| 2026-09-11 | decision | [Team selection boundary](./team-selection-boundary.md) | One dynamic managed-team ID drives explicit new-career resets and all managed views. |
| 2026-09-11 | decision | [Formation and lineup boundary](./formation-lineup-boundary.md) | Centralized formation counts drive explicit lineup application and a save invariant. |
| 2026-09-11 | decision | [Transfer and economy boundary](./transfer-economy-boundary.md) | Deterministic synthetic offers update squad, economy, contracts, and market atomically. |
| 2026-09-11 | decision | [Match events boundary](./match-events-boundary.md) | Seeded score events and bounded match stats flow from MatchEngine into fixture/UI summaries. |
