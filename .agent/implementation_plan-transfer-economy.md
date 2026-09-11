# Implementasyon Planı — Transfer, Ekonomi ve Sözleşmeler

## Amaç

Transfer menüsünü gerçek bir state akışına bağlamak: sentetik transfer
teklifleri gösterilecek, kulüp bütçesi ve haftalık maaş bütçesi kontrol edilecek,
imzalanan oyuncu kadroya eklenecek ve sözleşme/ekonomi durumu save/load ile
korunacak.

## Kapsam

1. `game_rules.json` içine dağıtılabilir prototip ekonomi kuralları eklemek ve
   generator/validator/DataPack sözleşmesini güncellemek.
2. `EconomyState` ile bakiye, haftalık gelir, maaş bütçesi, sözleşmeler ve hafta
   sonu tahsilatını yönetmek.
3. `TransferMarketState` ile yönetilen takım dışındaki sentetik oyunculardan
   deterministik teklif kataloğu üretmek ve imza işlemini atomik yürütmek.
4. `SquadState`'in transfer edilmiş oyuncuları eklemesini ve save snapshot'ında
   dinamik kadroyu taşımasını sağlamak.
5. `TransferView` ve ana menü bağlantısıyla gerçek satın alma akışı eklemek.
6. Save schema'yı 3'e çıkarıp ekonomi, market ve dinamik kadro state'lerini
   birlikte doğrulamak.

## Veri akışı

`TransferView` imza isteği -> `main.gd` -> `TransferMarketState` ->
`EconomyState` ve `SquadState` -> ekran/context/save yenilemesi.

Hafta oynatıldıktan sonra `EconomyState.advance_week()` bir kez çağrılır;
market teklifleri deterministik kalır, yalnızca imzalanan teklif katalogdan
çıkarılır.

## Sınırlar

- Tüm para, ücret, değer ve sözleşme süreleri sentetik oyun dengesi değeridir;
  gerçek piyasa değeri değildir.
- Transfer penceresi şimdilik ekonomi kuralı olarak saklanır ve ilk dikey
  dilimde haftalık pencere kilidi uygulanır; gelecekte sezon takvimine bağlanır.
- Satış, taksit, menajer komisyonu ve çok yıllı pazarlık bu dilimin dışındadır.
- Gerçek oyuncu/veri sağlayıcısı veya API kullanılmaz.

## Kabul ölçütleri

- Veri paketi economy kurallarını deterministik üretir ve doğrular.
- Başlangıç bütçesi/maaş sözleşmeleri takım gücünden aynı şekilde üretilir.
- Yetersiz bakiye veya maaş bütçesi imzayı reddeder ve hiçbir state değişmez.
- Başarılı imza oyuncuyu kadroya, sözleşmeyi ekonomiye ve işlemi market
  geçmişine ekler.
- Haftayı oynatmak gelir ve maaş tahsilatını bir kez uygular.
- Save/load dinamik kadro, ekonomi sözleşmeleri ve market tekliflerini korur.
- Transfer ekranı başarısız işlemi görünür hata, başarılı işlemi görünür
  onayla gösterir.
