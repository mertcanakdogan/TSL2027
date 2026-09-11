# Implementasyon Planı — Maç Olayları ve İstatistikleri

## Amaç

Skor sonucunu, aynı seed ile tekrar üretilebilen temel maç olayları ve
istatistikleriyle zenginleştirmek. Sonuç sözleşmesi geriye dönük skor/xG
alanlarını koruyacak; yeni alanlar maç merkezi ve fikstür ekranında
görünecek.

## Kapsam

1. `MatchEngine` içinde seed'li gol, kart ve olay dakikaları üretmek.
2. Şut, isabetli şut, korner, faul, sarı kart, xG ve topa sahip olma
   istatistiklerini tek `match_stats` sözleşmesinde döndürmek.
3. Olayları ev sahibi/deplasman takım kimliği ve sentetik oyuncu aktörüyle
   ilişkilendirmek; gerçek oyuncu verisi uydurmamak.
4. `LeagueState` snapshot'ının fixture result içinde yeni alanları doğal olarak
   korumasını sağlamak.
5. Maç merkezi ve fikstür satırında yönetilen maçın istatistik özeti/olay
   sayısını görünür kılmak.
6. Aynı seed/context replay, sınır ve olay-skora tutarlılık testleri eklemek.

## Veri akışı

`MatchEngine.simulate()` -> fixture `result` -> `LeagueState` snapshot ->
`FixtureView` ve ana maç merkezi.

## Sınırlar

- Bu dilim tam 90 dakikalık fiziksel simülasyon değildir; olay dakikaları
  deterministik özet üretimidir.
- xG/istatistikler sentetik oyun modeli değerleridir, gerçek maç verisi değildir.
- Oyuncu aktörü yalnızca mevcut context'teki ilk 11 kaydından seçilir; context
  yoksa olay takım seviyesinde kalır.

## Kabul ölçütleri

- Aynı seed ve context aynı skor, olay listesi ve istatistikleri üretir.
- Olay listesinde gol sayısı skorla eşleşir.
- Şut/isabetli şut, kart ve korner değerleri geçerli sınırlar içindedir.
- Topa sahip olma toplamı 100'dür; xG pozitif ve bounded kalır.
- Yönetilen maçın fikstür satırı skor, xG ve olay sayısını gösterir.
