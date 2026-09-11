# Implementasyon Planı — Formasyon ve İlk 11 Uygunluğu

## Amaç

Taktik ekranındaki formasyon seçimini kadro state'iyle bağlamak. Seçilen
formasyonun pozisyon ihtiyaçları mevcut kadroda yoksa oyun bunu reddedecek;
uygunsa teknik direktör açık bir butonla ilk 11'i o formasyona uygulayacak.

## Kapsam

1. `FormationRules` ile desteklenen formasyonların pozisyon ihtiyaçlarını tek
   bir katalogda tutmak.
2. `SquadState` içinde aktif formasyonu, kadro yeterliliğini, ilk 11 pozisyon
   dağılımını ve açık formasyon uygulamasını yönetmek.
3. Starter/bench değişiminin aktif formasyonun pozisyon sayısını bozmasını
   engellemek.
4. Taktikler ekranında formasyonu önce taslak olarak seçmek; “Dizilişi Kadroya
   Uygula” ile ana state'e geçirmek.
5. Save payload'una aktif formasyonu eklemek ve yeni state sözleşmesi için save
   şemasını sürümlemek.
6. Unit, save ve ana ekran smoke testlerini güncellemek.

## Veri akışı

`TacticsView` taslak seçim -> `main.gd` -> `SquadState.can/apply_formation()`
-> başarılıysa `TacticsState.set_formation()` -> `LeagueState` takım context
senkronizasyonu.

`SquadState` kadro pozisyonlarının tek kaynağıdır. `FormationRules` yalnızca
kuralları tanımlar; UI veya maç motoru kendi formasyon sayılarını kopyalamaz.

## Bilinçli sınır

Oyuncu veri paketi şu anda GK/DF/MF/FW ve genel Goalkeeper/Defender/
Midfielder/Forward rolleri taşıyor. Kanat bek, oyun kurucu veya presçi gibi
alt roller bu işin kapsamına alınmıyor; bunlar ayrı bir veri sözleşmesiyle
eklenebilir.

## Kabul ölçütleri

- Desteklenen beş formasyonun pozisyon ihtiyaçları katalogdan okunur.
- Yeterli kadro olmadan formasyon uygulaması state'i değiştirmez.
- Uygulanan formasyon ilk 11'de tam 11 oyuncu ve doğru pozisyon dağılımı üretir.
- Geçersiz starter/bench değişimi atomik olarak reddedilir.
- Taktikler ekranında seçim, uygulama butonuna basılana kadar mevcut state'i
  değiştirmez.
- Save/load aktif formasyon ve taktik formasyonunu birlikte korur; uyumsuz
  payload reddedilir.
