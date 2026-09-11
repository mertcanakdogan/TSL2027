# Changelog

All notable changes to this project will be documented in this file.

## 2026-09-11

- Added a normalized `CompetitionRules` runtime contract sourced from `data/game_rules.json`, including season length, round count, squad limits, substitutions, and eligibility rules.
- `DataPack` now validates rule metadata against the loaded schema and team/player counts before the game starts.
- League, squad, UI, and save/load flows now consume dynamic season and squad limits instead of duplicating the default constants.
- Full benches now expose an explicit reserves-to-bench promotion path for newly signed players; bench limits and roster limits persist in save payloads.
- Save schema 5 now migrates schema 3/4 payloads while retaining season metadata, squad limits, condition state, and active formation.
- Added `competition_rules_test.gd`; expanded squad, league, save, and main-scene smoke coverage. The local verifier now runs 10 Godot tests.
- Windows export/package verification now passes the desktop preset as one argument, tolerates empty PowerShell wrapper exit-code fields when logs/artifacts/runtime are clean, and retries transient extraction cleanup locks.
- Export/package evidence and the current SHA256 are recorded in `docs/RELEASE_EVIDENCE.md`.
- Added a data-pack README entry describing the runtime rule normalization and bench limit.
- Added the final release hardening decision and verification boundary to the agent knowledge base.

## [Unreleased]

### Added

- Functional Kadro screen with a deterministic 4-4-2 starting XI and bench swap flow.
- Functional Taktikler screen with validated formation, mentality, marking, and bounded intensity controls.
- Managed XI and tactical context now influence deterministic attack, defense, control, xG, and possession profiles.
- Headless match-engine tests cover deterministic replay, player-context effects, and tactical directionality.
- Read-only Fikstür and Lig Tablosu screens now render from LeagueState and refresh after weekly simulation.
- Versioned JSON save/load now restores the season, fixture results, lineup IDs, and tactics with schema checks.
- Team Seç now starts a fresh week-one career for any of the 18 loaded prototype teams.
- Formation application now rebuilds the managed XI against centralized GK/DF/MF/FW requirements.
- Save payloads now persist active lineup formation and reject mismatched squad/tactics formations.
- Transfer screen now shows deterministic synthetic offers and performs budget-checked signings.
- Economy state now tracks balance, weekly revenue, wage budget, contracts, and weekly settlement.
- Match results now include deterministic goal/card events and bounded shot, corner, foul, card, possession, and xG statistics.
- Maç context'lerine yedek kulübesi aktarımı, seeded oyuncu değişikliği olayları ve substitution istatistik sayaçları eklendi.
- Credits / Veri ekranı artık MIT kaynak kodu kapsamını ve sentetik veri sınırını oyun içinde görünür kılıyor.
- Her oyuncu için pozisyona göre üç alternatif rol skoru ve attack/defense/control profil puanları eklendi; ligdeki varsayılan ilk 11 bağlamları artık maç motoruna aktarılıyor.
- 34. hafta sonrasında şampiyon ve üç küme düşen takımı gösteren sezon sonu özeti eklendi.
- Portable Windows ZIP paketleme ve taze klasörden paket runtime smoke doğrulaması eklendi.
- SaveGame artık geçici dosya commit'i, `.bak` yedeği ve bozuk ana kayıttan geri dönüş raporlaması kullanıyor.
- Haftalık ilk 11 kondisyon düşüşü, bench recovery, düşük kondisyon maç cezası ve ilk schema 3 -> 4 migration eklendi; güncel migration zinciri schema 5'e ilerler.
- Tüm yerel test/export/package kontrollerini çalıştıran `verify_project.ps1` eklendi.
- Son yerel release kanıtı, artifact hash'i ve public dağıtım sınırı `docs/RELEASE_EVIDENCE.md` içine kaydedildi.
- Headless Godot tests for squad state and main-scene screen switching.
- Deterministic synthetic player data for all 18 prototype teams.
- Versioned competition rules data pack for the 2026-2027 prototype season.
- Python generator, validator, and nine data-contract tests.
- Godot `DataPack` loader with explicit load-error state.

### Changed

- The dashboard now loads its team source through the runtime data pack and shows the loaded synthetic-player count.
- Main-screen navigation now distinguishes dashboard, Kadro, and Taktikler views instead of treating Taktikler as a placeholder.
- LeagueState refreshes the managed team's copied match context before each simulated week.
- LeagueState exposes deep-copied managed-team fixtures for UI consumption.
- Main dashboard exposes Kaydet/Yükle actions under `user://tsl2027_save.json`.
- Managed-team identity is now dynamic across dashboard, squad, tactics, fixtures, context sync, and save/load validation.
- Formation changes are staged in the Taktikler screen and only mutate lineup/tactics/context after explicit application.
- Save schema version is now 2 because active lineup formation is part of the persisted state.
- Save schema version is now 3 because dynamic roster, economy, and transfer-market state are persisted.
- Transfer signing is atomic across market, economy, and SquadState; the transfer window closes after week 8.
- Match center and fixture rows now expose the managed match's synthetic stats and event summary.
