# Araştırma ve teknik kararlar

## Kısa sonuç

İlk teknik omurga:

- Oyun motoru: Godot 4.x stable
- Runtime dili: GDScript
- Veri hazırlama: gerektiğinde Python yardımcı araçları
- İlk veri formatı: JSON
- Kalıcı kayıt: Godot FileAccess ve JSON
- İlk simülasyon: deterministik seed kullanan olay dışı maç modeli
- İlk veri paketi: sentetik örnek veri
- Gerçek veri: lisans ve dağıtım hakkı doğrulanınca ayrı bir veri paketi

Bu seçim, oyunun asıl zorluğunun grafik değil; veri modeli, kural motoru, taktik etkileşimleri, ekonomi ve uzun sezon simülasyonu olması nedeniyle yapıldı.

## 1. Ürün sınırı

Hedef, Windows üzerinde offline oynanan, Süper Lig kariyeri üzerine kurulu bir futbol menajerlik oyunu.

İlk sürümde öncelik sırası:

1. Takım seçme ve sezon başlatma
2. Kadro ve taktik ekranı
3. Fikstür ve haftayı oynatma
4. Maç özeti ve puan durumu
5. Transfer ve sözleşme sistemi
6. Oyuncu gelişimi, sakatlık ve moral
7. Kulüp bütçesi, yönetim ve hedefler
8. Türkiye Kupası ve Avrupa takvim yoğunluğu

İlk prototipte 3D maç görüntüsü hedeflenmiyor. Maçın eğlencesi, kararların sonuçlarını anlaşılır ve tutarlı biçimde göstermesinden gelecek.

## 2. Teknoloji seçimi

### Godot + GDScript

Önerilen ana seçim budur.

Godot resmi olarak GDScript, C# ve C++ seçeneklerini destekliyor. GDScript motorla bütünleşik ve prototip ile MVP geliştirmede hızlı. Godot dokümantasyonu, çoğu script işinde GDScript, C# veya C++ arasındaki performans farkının belirleyici olmayabileceğini; asıl ağır işlemlerin motorun C++ tarafında çalıştığını belirtiyor.

Bu projede 34 haftalık lig simülasyonu, birkaç yüz oyuncunun günlük veya haftalık güncellenmesi ve menü arayüzü GDScript için makul bir yük. İlk sürümde erken optimizasyon yapıp C++ eklemek gereksiz karmaşıklık yaratır.

Godot'un kendi lisansı MIT'tir. Oyun içeriğinin lisansını geliştirici ayrıca belirleyebilir. Godot motoru dağıtılan oyuna dahil edildiğinde motor lisans bildirimleri dokümantasyonda veya credits ekranında korunmalıdır.

### C# neden ilk tercih değil

Godot'ta C# kullanmak mümkündür ve daha büyük kod tabanlarında güçlü tip sistemi avantaj sağlar. Ancak .NET sürümünü kullanmak, ayrı IDE akışı ve Godot ile C# arasındaki entegrasyon ayrıntılarını yönetmek gerekir. Bu proje için ilk dikey dilimde kazanımı maliyetinden düşük.

Kod tabanı büyür, veri sözleşmeleri karmaşıklaşır veya simülasyon profilinde gerçek darboğaz görülürse domain çekirdeği C#'a taşınabilir. Arayüz ve veri modelinin Godot'tan bağımsız tutulması bu geçişi mümkün bırakır.

### Python neden runtime dili değil

Python, veri temizleme, kaynak dönüştürme, rating hesaplama ve test araçları için kullanılabilir. Ancak oyunun Windows üzerinde tek paket halinde dağıtılan runtime'ını Python üzerine kurmak ilk sürümde gereksiz paketleme ve UI yükü oluşturur. Bu nedenle Python yardımcı araç, Godot runtime olarak konumlandırıldı.

## 3. Veri kaynağı stratejisi

### TFF

TFF, 2026-2027 Süper Lig statüsü ve resmi fikstür için birincil referanstır. Statüye göre sezon 18 takımla, çift devreli lig usulüyle ve 34 hafta üzerinden oynanıyor. Aynı statüde 5 oyuncu değişikliği ve kadro uygunluk kuralları da tanımlanıyor.

TFF sayfası gerçek sezon yapısını doğrulamak için kullanılmalı. Ancak resmi bir sayfada yayınlanıyor olması, verinin ham biçimde oyuna gömülüp yeniden dağıtılabileceği anlamına gelmez. Kaynak gösterimi ile yeniden dağıtım hakkı ayrı konulardır.

### API-Football

API-Football resmi coverage sayfasında çok sayıda lig için fikstür, oyuncu, kadro, olay ve istatistik kapsamı sunuyor. Dokümantasyonunda fixture, line-up ve oyuncu istatistikleri için endpoint'ler bulunuyor. Şartları, verinin doğrudan yeniden satılmasını yasaklarken uygulama ve fantasy game gibi farklı projeler geliştirmeye izin verdiğini belirtiyor.

Bu servis, lisans koşulları dağıtılacak oyunun veri politikasına uyduğu doğrulanırsa canlı veya güncel veri sağlayıcısı adayıdır. API anahtarı hiçbir zaman client uygulamasına gömülmemeli; veri üretim aşamasında kullanılmalıdır.

### Sportmonks

Sportmonks, Süper Lig için oyuncu ve maç istatistikleri, xG, şut, pas, topa sahip olma, ikili mücadele ve kart gibi alanlar sunuyor. Resmi Süper Lig sayfasında erişimin ücretli planlarda bulunduğu ve başlangıç planının güncel olarak aylık 29 EUR seviyesinden başladığı görülüyor. Bu fiyat ve kapsam satın alma öncesinde yeniden doğrulanmalıdır.

Sportmonks dokümantasyonu, oyuncu istatistiklerinin event-derived ve on-ball alanlarla sınırlı olduğunu; GPS veya sprint gibi tracking verilerinin bulunmadığını belirtiyor. Bu nedenle hız, patlayıcılık ve dayanıklılık gibi özellikler yalnızca maç istatistiklerinden doğrudan çıkarılmamalı.

### StatsBomb Open Data

StatsBomb'ın açık veri reposu, seçilmiş lig ve sezonlar için araştırma amaçlı event verisi sunuyor. Kullanım koşulları veriyle yapılan analizlerde StatsBomb kaynağının belirtilmesini istiyor. Açık veri, TSL 2026-2027 kadrosunu otomatik olarak sağlamaz; maç simülasyonu ve event modelini test etmek için metodoloji kaynağı olarak değerlidir.

### Son karar

Veri sağlayıcı kodu doğrudan oyuna bağlanmayacak. Aşağıdaki soyutlama kurulacak:

- \`FootballDataProvider\`: dış kaynaktan veri alma arayüzü
- \`RawDataImporter\`: ham cevabı iç şemaya dönüştürür
- \`DataValidator\`: zorunlu alanları, tekrarları ve tarihleri kontrol eder
- \`GameDataPack\`: oyunun kullanacağı sürümlenmiş veri paketi

Bu sayede sağlayıcı değişirse maç motoru ve arayüz değişmek zorunda kalmaz.

## 4. Oyuncu özellikleri nasıl belirlenecek

Başlangıçta tek bir overall değerine dayalı sistem kurulmayacak. Oyuncunun rolüne göre anlamlı özellikler tutulacak.

### Kaleci

- Reflexes
- Handling
- One-on-one
- Aerial control
- Positioning
- Distribution
- Decisions

### Defans

- Positioning
- Marking
- Tackling
- Interceptions
- Aerial
- Pace
- Strength
- Passing

### Orta saha

- Passing
- Vision
- Decisions
- Ball control
- Press resistance
- Stamina
- Work rate
- Tackling
- Long shots

### Hücum

- Finishing
- Composure
- Off-ball movement
- Dribbling
- Acceleration
- Strength
- Aerial
- Decision making

Her oyuncuda ayrıca şunlar bulunacak:

- Current ability
- Potential
- Preferred foot
- Position familiarity
- Consistency
- Big-match tendency
- Injury proneness
- Morale
- Match sharpness
- Age and development curve

### Rating üretim ilkesi

Gerçek istatistikten attribute üretirken küçük örneklem problemi kontrol edilecek. Bir oyuncu 250 dakika oynamışsa, 2 gol veya 1 asist bütün rating'i belirlemeyecek.

İlk model:

1. Pozisyona göre relevant istatistikleri seç.
2. Dakika ve sample size ile güven ağırlığı hesapla.
3. Lig ortalamasına doğru shrinkage uygula.
4. Oyuncunun yaşı, rolü ve pozisyon uyumunu ekle.
5. Sonucu 1-99 aralığına dönüştür.
6. Rating yanında belirsizlik değeri de sakla.

Bu model, EA FC veya Football Manager rating'lerini kopyalamaz. Güç değerleri ve attribute'lar projeye ait hesaplamalar olur.

## 5. Taktik modeli

Taktik ekranı yalnızca formasyon seçtiren bir menü olmayacak. Takımın davranışını etkileyen bir parametre seti olacak:

- Formation
- Mentality
- Width
- Tempo
- Defensive line
- Press intensity
- Build-up risk
- Directness
- Transition speed
- Marking approach
- Set-piece focus
- Role instructions

Maç motoru her pası simüle etmek yerine 5 veya 10 dakikalık olay pencereleriyle çalışacak. Her pencerede:

1. Takımların rating ve formu hesaplanır.
2. Taktiklerin birbirine karşı etkisi hesaplanır.
3. Topa sahip olma ve bölgesel üstünlük üretilir.
4. Hücum aksiyonu, şut kalitesi veya top kaybı seçilir.
5. xG, gol, kart, sakatlık, değişiklik ve moral etkisi yazılır.
6. Maç sonunda özet istatistikler oluşturulur.

Taktiklerin etkisi tamamen doğrusal olmayacak. Örneğin yüksek pres, zayıf rakibe karşı top kazanımı üretirken güçlü ve teknik rakibe karşı arkasında alan bırakabilir. Aynı taktik yorgunluk seviyesi ve fikstür yoğunluğu ile farklı sonuç vermeli.

## 6. İlk maç motoru

İlk dikey dilimde daha küçük ve denetlenebilir bir model kullanıldı:

- Takım gücü
- İç saha avantajı
- Rastgele varyans
- xG benzeri beklenen gol değeri
- Poisson benzeri gol üretimi
- Topa sahip olma tahmini
- Seed ile tekrarlanabilir sonuç

Bu model nihai simülasyon değildir. Avantajı, aynı seed ile aynı haftanın tekrar üretilebilmesi ve hataların test edilebilmesidir. Daha sonra takım taktiği, oyuncu seçimi, yorgunluk, moral, sakatlık ve form eklenecek.

## 7. Gerçek sezon kuralları

TFF'nin 2026-2027 Süper Lig statüsüne göre:

- Lig 18 takımdan oluşur.
- Çift devreli lig usulü oynanır.
- Toplam 34 hafta vardır.
- Son üç takım TFF 1. Lig'e düşer.
- Müsabakalarda 5 oyuncu değişikliği yapılabilir.
- A Takım Listesi en fazla 28 futbolcudan oluşur.
- A Takım Listesine en fazla 14 yabancı futbolcu yazılabilir.
- 14 yabancı yazılırsa en az 4'ünün 1 Ocak 2003 veya daha sonra doğmuş olması gerekir.
- A Takım Listesinde en az 14 milli takım uygunluğu bulunan futbolcu bulunmalıdır.
- Bu 14 futbolcudan en az 4'ünün 1 Ocak 2003 veya daha sonra doğmuş olması gerekir.
- A Takım Listesinde en fazla 3 kaleci, en az 2 uygun kaleci bulunabilir.
- Müsabaka isim listesi en fazla 21 futbolcudan oluşur.
- 2026-2027 transfer ve tescil dönemleri 22 Haziran 2026 - 4 Eylül 2026 ve 1 Ocak 2027 - 5 Şubat 2027 olarak ilan edilmiştir.

Bu kurallar kod içine sabit dağılmayacak. \`CompetitionRules\` benzeri bir yapı içinde sezon sürümüyle tutulacak.

## Kaynaklar

1. [Godot scripting languages](https://docs.godotengine.org/en/stable/getting_started/step_by_step/scripting_languages.html)
2. [Godot license](https://godotengine.org/license/)
3. [Godot runtime file loading and saving](https://docs.godotengine.org/en/stable/tutorials/io/runtime_file_loading_and_saving.html)
4. [Godot deterministic random number generation](https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html)
5. [TFF 2026-2027 Süper Lig Müsabakaları Statüsü](https://www.tff.org/Resources/TFF/Documents/STATULER/2026-2027/2026-2027-sezonu-super-lig-musabakalari-statusu.pdf)
6. [TFF 2026-2027 fikstürü](https://www.tff.org/Default.aspx?macId=283608&pageId=198)
7. [TFF 2026-2027 transfer ve tescil dönemleri](https://www.tff.org/default.aspx?ftxtID=50633&pageID=687)
8. [API-Football coverage](https://www.api-football.com/coverage)
9. [API-Football documentation](https://www.api-football.com/documentation-v3)
10. [API-Football terms](https://www.api-football.com/terms)
11. [Sportmonks Süper Lig API](https://www.sportmonks.com/football-api/super-lig-api/)
12. [Sportmonks player statistics](https://docs.sportmonks.com/v3/tutorials-and-guides/tutorials/statistics/players-statistics)
13. [StatsBomb Open Data](https://github.com/hudl/open-data)
