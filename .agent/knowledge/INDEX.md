# Project Knowledge Base

| Date | Type | Topic | Summary |
|------|------|-------|---------|
| 2026-09-11 | decision | [Deterministic synthetic data pack](./phase1-data-pack.md) | The first squad/data slice uses generated, license-safe JSON and a runtime loader instead of a live provider. |
| 2026-09-11 | decision | [Lineup state boundary](./squad-state-boundary.md) | Mutable starter/bench selection stays in SquadState and never mutates the immutable DataPack records. |
| 2026-09-11 | decision | [Tactics state boundary](./tactics-state-boundary.md) | Tactical intent is validated in a separate TacticsState; UI controls do not claim match-engine effects before scenario tests exist. |
