# Transfer ve Ekonomi Sınırı

2026-09-11 itibarıyla transfer pazarı, oyuncu veri paketinden yönetilen takım
dışındaki oyuncular için deterministik sentetik teklifler üretir. İmza işleminin
tek giriş noktası `TransferMarketState`tir; başarılı işlem `SquadState`,
`EconomyState` ve market geçmişini birlikte günceller.

### Current boundary

Bütçe, maaş bütçesi, haftalık gelir, oyuncu ücretleri ve transfer bedelleri
`game_rules.json`/sentetik hesap kurallarıdır; gerçek finansal veri değildir.
`CompetitionRules`, sezon kimliği, transfer penceresi, kadro üst sınırı ve
bench limitini runtime için normalize eder. Satış, taksit ve pazarlık bu
dilimin dışındadır.

`SquadState.add_player()` bench doluysa yeni transferi `unselected` olarak
korur. `promote_to_bench()` seçilen bir bench oyuncusunu reserves'e taşıyarak
grup boyutunu sabit tutar; sonrasında mevcut `swap_players()` API'si pozisyon
uygunsa oyuncuyu ilk 11'e alır.

Save schema 5, dinamik roster, ekonomi/market snapshot'ları ve sezon kural
alanlarını taşır. Schema 3 kondisyon alanını ekleyerek, schema 4 ise sezon
alanlarını ekleyerek schema 5'e migrate edilir.
Eski save sürümleri sessizce yok sayılmaz; desteklenen sürümler kontrollü
migration'dan geçer.
