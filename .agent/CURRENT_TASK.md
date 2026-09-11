# Current Task

## What We're Building

TSL2027: Godot 4 + GDScript ile geliştirilen, Trendyol Süper Lig 2026/27 temalı offline futbol menajerlik oyunu.

## Status

Done — Kadro/ilk 11 ve Taktikler state/UI slice'ları tamamlandı; testleri yeşil, feature branch/PR doğrulaması bekliyor.

## Last Session Summary

2026-09-11 — Veri paketi üzerine `SquadState`, gerçek Kadro ekranı, deterministik 4-4-2 ilk 11, yedek kulübesi ve iki oyunculu starter/bench değişimi eklendi. Ardından `TacticsState` ve gerçek Taktikler ekranı eklendi; diziliş, zihniyet, markaj ve 0–100 değerleri doğrulanıyor.

## Next Steps

1. Formasyon/rol uygunluğu ve taktiklerin `SquadState` ile ilişkisi için test sözleşmesi yaz.
2. Oyuncu özellikleri ve taktik state'i maç motoruna bağlayan deterministik eşleşme senaryoları oluştur.
3. Save/load çekirdeğini, veri paketi sürümü ve migration kontrolüyle ekle.

## Blockers

- Yok. Godot 4.7.2 bu makinede headless doğrulama için kurulu.
- Gerçek oyuncu/veri sağlayıcısı entegrasyonu lisans ve dağıtım modeli netleşene kadar kapsam dışı.
