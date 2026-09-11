# Transfer ve Ekonomi Sınırı

2026-09-11 itibarıyla transfer pazarı, oyuncu veri paketinden yönetilen takım
dışındaki oyuncular için deterministik sentetik teklifler üretir. İmza işleminin
tek giriş noktası `TransferMarketState`tir; başarılı işlem `SquadState`,
`EconomyState` ve market geçmişini birlikte günceller.

Bütçe, maaş bütçesi, haftalık gelir, oyuncu ücretleri ve transfer bedelleri
`game_rules.json`/sentetik hesap kurallarıdır; gerçek finansal veri değildir.
Satış, taksit ve pazarlık bu dilimin dışındadır.

Save schema 3, dinamik roster kayıtları ile ekonomi/market snapshot'larını taşır.
Eski save sürümleri sessizce dönüştürülmez.
