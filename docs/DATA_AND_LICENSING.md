# Veri ve lisans politikası

## Temel ayrım

Bu repo iki farklı şeyi içerir:

1. Projeye ait özgün kaynak kodu ve tasarım kararları.
2. Futbol dünyasına veya üçüncü taraf sağlayıcılara ait olabilecek isim, fikstür, istatistik, logo ve medya verileri.

Kök dizindeki MIT License özgün kaynak kodu için verilmiştir. Bu lisans, üçüncü taraf veri sağlayıcılarının kullanım şartlarını ortadan kaldırmaz.

## Repoya girmemesi gerekenler

Aşağıdaki içerikler lisans durumu yazılı olarak doğrulanmadan commit edilmeyecek:

- Kulüp logoları ve forma görselleri
- Oyuncu fotoğrafları
- Üçüncü taraf sitelerden toplu olarak kopyalanmış oyuncu profilleri
- Sağlayıcı API'sinin ham JSON cevapları
- API anahtarları, tokenlar ve kişisel hesap bilgileri
- EA FC, Football Manager veya başka bir oyunun rating tabloları
- Kaynağın yeniden dağıtıma izin vermediği ticari veri paketleri

## Veri katmanları

### Kaynak verisi

Ham veri yalnızca yerel veya özel depolama alanında tutulur. \`data/raw/\` ve \`data/private/\` Git tarafından yok sayılır.

### Dönüştürülmüş oyun verisi

Dönüştürülmüş veri yalnızca şu bilgilerle birlikte dağıtılabilir:

- Kaynak sağlayıcı
- Kaynak URL
- Veri çekim tarihi
- Sezon
- Dönüştürme sürümü
- Kullanım ve dağıtım koşulu
- Değiştirilmiş alanların açıklaması

### Sentetik prototip verisi

Bu repodaki \`data/teams.json\` dosyasında takım isimleri sezon yapısını göstermek için, \`strength\` değerleri ise yalnızca prototip simülasyonu için kullanılır. Bu değerler resmi rating değildir.

## Sağlayıcı politikası

API-Football, verinin doğrudan yeniden satılmasını yasaklıyor ancak uygulama ve fantasy game gibi farklı projeler geliştirmeye izin verdiğini belirtiyor. Bu ifade, ham verinin oyunun içine gömülüp sınırsız dağıtılabileceği şeklinde yorumlanmayacak; gerçek dağıtım modeli ayrıca kontrol edilecek.

Sportmonks, Süper Lig ve oyuncu istatistikleri sunan ücretli bir seçenektir. Abonelik sahibi olmak, her tür ham veriyi oyunun yanında dağıtma hakkının otomatik olarak alındığı anlamına gelmez.

TFF, resmi fikstür ve lig statüsü için birincil referanstır. TFF sayfasından bilgi doğrulamak ile sayfanın içeriğini toplu biçimde yeniden dağıtmak aynı şey değildir.

StatsBomb Open Data kullanılırsa kaynak ve istenen atıf şartları korunur.

## Dağıtım stratejisi

İlk açık kaynak sürüm:

- Kod içerir.
- Sentetik test verisi içerir.
- Gerçek oyuncu fotoğrafı ve logo içermez.
- API tokenı gerektirmez.
- Harici sağlayıcı verisini runtime'da çekmez.

Gerçek veriyle oynanabilir paket için iki güvenli seçenek var:

1. Lisanslı veri paketi oluşturup oyundan ayrı dağıtmak.
2. Kullanıcının kendi lisanslı veri kaynağından build-time import yapmasını sağlamak.

Dağıtılacak sürümden önce fikri mülkiyet ve veri sözleşmeleri konusunda ayrıca uzman görüşü alınmalıdır. Bu belge hukuki görüş değildir.
