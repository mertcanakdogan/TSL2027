# Current Task

## What We're Building

TSL2027: Godot 4 + GDScript ile geliştirilen, Trendyol Süper Lig 2026/27 temalı offline futbol menajerlik oyunu.

## Status

Done — Kadro/ilk 11 slice tamamlandı; feature branch commit ve PR akışı için hazır.

## Last Session Summary

2026-09-11 — Veri paketi üzerine `SquadState`, gerçek Kadro ekranı, deterministik 4-4-2 ilk 11, yedek kulübesi ve iki oyunculu starter/bench değişimi eklendi. Godot state testi, main-scene smoke testi, Godot headless parse/çalıştırma ve Python 9/9 veri testleri geçti.

## Next Steps

1. Taktik veri sözleşmesini yaz: formation, mentality, tempo, press intensity ve defensive line.
2. Formation/role legality testlerini ekle; mevcut 4-4-2 baseline'ını tactics state'e taşı.
3. Oyuncu seçimi ve taktik değerlerini maç motoruna bağlamadan önce deterministik eşleşme senaryoları oluştur.

## Blockers

- Yok. Godot 4.7.2 bu makinede headless doğrulama için kurulu.
- Gerçek oyuncu/veri sağlayıcısı entegrasyonu lisans ve dağıtım modeli netleşene kadar kapsam dışı.
