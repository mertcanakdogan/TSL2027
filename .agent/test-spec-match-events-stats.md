# Test Sözleşmesi — Maç Olayları ve İstatistikleri

## MatchEngine

- `same_seed_replays_events_and_stats`: Aynı seed/context bütün yeni alanları
  byte/eşitlik seviyesinde tekrar üretir.
- `goal_events_match_score`: Olay tipindeki gol sayısı ev/deplasman skoruna
  eşittir.
- `match_stats_are_bounded_and_coherent`: Şut, isabetli şut, korner, faul,
  kart ve topa sahip olma sınırları korunur.
- `stronger_context_directionality_remains`: Mevcut daha güçlü ilk 11 ve
  taktik yönlülük profili xG/attack sonuçlarını bozmadan korur.

## League/UI

- Fixture result snapshot yeni `events`/`match_stats` alanlarını kaybetmez.
- Fikstür satırı oynanmış maçta skorun yanında xG ve olay sayısını gösterir.
- Ana maç merkezi yönetilen maç için istatistik özeti ve olay özeti gösterir.

## Doğrulama komutları

Godot headless testleri, editor parse, veri paketi validator/test suite ve main
scene smoke testi birlikte çalıştırılır.
