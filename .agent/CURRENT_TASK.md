# Current Task

## What We're Building

TSL2027: Godot 4 + GDScript ile geliştirilen, Trendyol Süper Lig 2026/27 temalı offline futbol menajerlik oyunu.

## Status

Done — Phase 1 data-contract alt dilimi tamamlandı ve PR #3 ile `main`e merge edildi.

## Last Session Summary

2026-09-11 — Boş yerel klasöre `mertcanakdogan/TSL2027` klonlandı. Deterministik sentetik veri üreticisi, 324 oyunculuk veri paketi, sezon kuralları, Python validator/testleri ve Godot `DataPack` loader eklendi. README, veri politikası, roadmap, changelog ve knowledge base güncellendi. Python 9/9 test, validator, Godot headless editor parse ve headless scene çalıştırması geçti. PR #3 merge commit: `5ab74c9`.

## Next Steps

1. `DataPack.get_team_squad()` kullanan gerçek Kadro ekranı ve seçilebilir ilk 11/yedek state'i ekle.
2. Formasyon, mentality, tempo, press intensity ve defensive line alanlarını taktik veri sözleşmesi olarak tanımla; önce çekirdek testlerini yaz.
3. Oyuncu seçimi ve taktik değerlerini maç motoruna bağlamadan önce deterministik eşleşme senaryoları oluştur.

## Blockers

- Yok. Godot 4.7.2 bu makinede headless doğrulama için kurulu.
- Gerçek oyuncu/veri sağlayıcısı entegrasyonu lisans ve dağıtım modeli netleşene kadar kapsam dışı.
