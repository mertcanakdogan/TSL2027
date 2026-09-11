# Current Task

## What We're Building

TSL2027: Godot 4 + GDScript ile geliştirilen, Trendyol Süper Lig 2026/27 temalı offline futbol menajerlik oyunu.

## Status
- In progress — takım seçimi/yeni kariyer, kadro/ilk 11, formasyon/alternatif rol uygunluğu, taktik state/UI ve deterministik taktik senaryoları, transfer/ekonomi/sözleşme, tüm lig varsayılan ilk 11 attribute profilleri, deterministik maç olayları/istatistikleri, seeded oyuncu değişikliği raporu, Credits/veri politikası, kondisyon/yorgunluk, dayanıklı save/load, fikstür/puan durumu, sezon özeti, Windows export/portable paket ve tek komutlu doğrulama mevcut.
- Bu dilimde `CompetitionRules` runtime sözleşmesi, data-pack metadata doğrulaması, dinamik sezon/limit propagasyonu, reserves → bench → starter kadro akışı ve Save schema 5 migration eklendi.

## Last Session Summary

2026-09-11 — Rule-driven season contract and reserve promotion slice implemented. `DataPack` now normalizes `game_rules.json`; League/Squad/UI/Save consume the normalized values. Signed players can be explicitly promoted from a full bench's reserves, and schema 3/4 saves migrate to schema 5. Windows export/package verification was hardened for quoted presets, empty PowerShell exit-code fields, and transient cleanup locks.

## Verification

- `verify_project.ps1` passed with 10 Godot tests, editor parse/import, Python validator/tests, Windows export, portable ZIP, and fresh-directory runtime smoke.
- Latest artifact: `build/TSL2027.exe` 109485104 bytes; ZIP SHA256 `8C875573CB9CBFAC7A595E9CBF24DF0A43218E42E1177076531FEAE8C0ECCC85`.

## Next Steps

1. Haftalık çoklu state ilerlemesini aggregate transaction ve semantic cross-state validation ile sertleştir.
2. Maç event output'unu kalıcı kart/sakatlık/ceza etkilerine ve daha geniş rapora taşı.
3. Temiz makine/installer/code-signing kapılarını tamamla.

## Blockers

- Yok. Godot 4.7.2 bu makinede headless doğrulama için kurulu.
- Gerçek oyuncu/veri sağlayıcısı entegrasyonu lisans ve dağıtım modeli netleşene kadar kapsam dışı.
