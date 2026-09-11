# Current Task

## What We're Building

TSL2027: Godot 4 + GDScript ile geliştirilen, Trendyol Süper Lig 2026/27 temalı offline futbol menajerlik oyunu.

## Status

In progress — Takım seçimi/yeni kariyer, Kadro/ilk 11, formasyon/alternatif rol uygunluğu, Taktikler state/UI, transfer/ekonomi/sözleşme, tüm lig varsayılan ilk 11 attribute profilleri, deterministik temel maç olayları/istatistikleri, Credits/veri politikası, Fikstür/Lig Tablosu, sürümlü save/load ve yerel Windows export doğrulaması tamamlandı; temiz makine/installer ve daha geniş simülasyon kapıları devam ediyor.

## Last Session Summary

2026-09-11 — Veri paketi üzerine takım seçimi/yeni kariyer akışı, `SquadState`, merkezi formasyon kuralları, formasyonla uyumlu ilk 11 uygulaması, transfer/ekonomi/sözleşme state'leri, deterministik maç olayları/istatistikleri, gerçek Kadro ve Transfer ekranları, yedek kulübesi ve iki oyunculu starter/bench değişimi eklendi. Ardından `TacticsState`/Taktikler ekranı, yönetilen takım bağlamının MatchEngine profil/xG etkisi, LeagueState kaynaklı Fikstür/Lig Tablosu ekranları ve sürümlü save/load eklendi.

## Next Steps

1. Maç olay pencereleri, kondisyon/yorgunluk ve oyuncu değişikliklerini tasarla.
2. Temiz makine/installer smoke testini oluştur ve yayın artefaktını belgeleyerek paketle.
3. Alt oyuncu rolleri ve tüm lig oyuncu attribute etkileri için simülasyon kapsamını genişlet.

## Blockers

- Yok. Godot 4.7.2 bu makinede headless doğrulama için kurulu.
- Gerçek oyuncu/veri sağlayıcısı entegrasyonu lisans ve dağıtım modeli netleşene kadar kapsam dışı.
