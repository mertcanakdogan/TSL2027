# Current Task

## What We're Building

TSL2027: Godot 4 + GDScript ile geliştirilen, Trendyol Süper Lig 2026/27 temalı offline futbol menajerlik oyunu.

## Status

Done — Kadro/ilk 11, Taktikler state/UI ve yönetilen takımın ilk bağlamlı maç profili slice'ları tamamlandı; testleri yeşil, feature branch/PR doğrulaması bekliyor.

## Last Session Summary

2026-09-11 — Veri paketi üzerine `SquadState`, gerçek Kadro ekranı, deterministik 4-4-2 ilk 11, yedek kulübesi ve iki oyunculu starter/bench değişimi eklendi. Ardından `TacticsState`/Taktikler ekranı ve yönetilen takım bağlamının MatchEngine profil/xG etkisi eklendi.

## Next Steps

1. Formasyon/rol uygunluğunu `SquadState` ile bağlayan test sözleşmesini yaz.
2. Fikstür ve lig tablosu ekranlarını placeholder olmaktan çıkar.
3. Save/load çekirdeğini, veri paketi sürümü ve migration kontrolüyle ekle.

## Blockers

- Yok. Godot 4.7.2 bu makinede headless doğrulama için kurulu.
- Gerçek oyuncu/veri sağlayıcısı entegrasyonu lisans ve dağıtım modeli netleşene kadar kapsam dışı.
