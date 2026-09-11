# Current Task

## What We're Building

TSL2027: Godot 4 + GDScript ile geliştirilen, Trendyol Süper Lig 2026/27 temalı offline futbol menajerlik oyunu.

## Status

In progress — Takım seçimi/yeni kariyer, Kadro/ilk 11, formasyon uygunluğu, Taktikler state/UI, transfer/ekonomi/sözleşme, deterministik temel maç olayları/istatistikleri, yönetilen takımın ilk bağlamlı maç profili, Fikstür/Lig Tablosu ve sürümlü save/load slice'ları tamamlandı; geniş maç simülasyonu ve dağıtım kapıları devam ediyor.

## Last Session Summary

2026-09-11 — Veri paketi üzerine takım seçimi/yeni kariyer akışı, `SquadState`, merkezi formasyon kuralları, formasyonla uyumlu ilk 11 uygulaması, transfer/ekonomi/sözleşme state'leri, deterministik maç olayları/istatistikleri, gerçek Kadro ve Transfer ekranları, yedek kulübesi ve iki oyunculu starter/bench değişimi eklendi. Ardından `TacticsState`/Taktikler ekranı, yönetilen takım bağlamının MatchEngine profil/xG etkisi, LeagueState kaynaklı Fikstür/Lig Tablosu ekranları ve sürümlü save/load eklendi.

## Next Steps

1. Maç olayları/istatistikleri ve tüm lig oyuncu attribute etkilerini genişlet.
2. Windows export ve temiz kurulum smoke testini oluştur.
3. Credits, lisans sınırları ve sentetik veri bildirimini kullanıcı arayüzünde görünür kıl.

## Blockers

- Yok. Godot 4.7.2 bu makinede headless doğrulama için kurulu.
- Gerçek oyuncu/veri sağlayıcısı entegrasyonu lisans ve dağıtım modeli netleşene kadar kapsam dışı.
