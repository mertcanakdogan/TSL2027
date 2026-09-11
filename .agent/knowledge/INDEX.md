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
| 2026-09-11 | decision | [Credits and data policy boundary](./credits-data-policy-boundary.md) | Read-only in-game attribution separates MIT source-code scope from synthetic and future real-data content. |
| 2026-09-11 | decision | [Atomic save and backup boundary](./atomic-save-backup-boundary.md) | SaveGame commits through a temporary file and retains a backup for malformed-primary recovery. |
| 2026-09-11 | decision | [Player condition and fatigue boundary](./player-condition-fatigue-boundary.md) | SquadState owns bounded deterministic condition; SaveGame schema 5 persists condition and season-rule fields. |
| 2026-09-11 | decision | [Full verification command boundary](./full-verification-command-boundary.md) | One PowerShell entry point runs the 10-test core suite and Windows release smoke chain with quoted presets and artifact/log checks. |
| 2026-09-11 | evidence | [Release evidence](../../docs/RELEASE_EVIDENCE.md) | Latest local test, export, package hash, and external release boundary are recorded. |
| 2026-09-11 | decision | [Season end summary boundary](./season-end-summary-boundary.md) | Final champion and three relegation rows are derived after the configured season length. |
| 2026-09-11 | decision | [Match substitution events boundary](./match-substitution-events-boundary.md) | Copied bench snapshots produce bounded deterministic report events without mutating lineup state. |
| 2026-09-11 | decision | [Runtime competition rule source](./competition-rules-boundary.md) | `CompetitionRules` normalizes season and squad limits; reserve promotion and save schema 5 preserve the runtime contract. |
