# TSL2027 yol haritası

## Tamamlanan

### Faz 0: Teknik temel

- Godot 4 proje dosyası
- GDScript runtime
- Örnek 18 takım verisi
- 34 haftalık çift devreli fikstür üreticisi
- Seed kullanan maç motoru
- Puan durumu
- İlk dashboard arayüzü
- Veri ve lisans politikası

### Faz 1: Veri sözleşmesi — ilk alt dilim tamamlandı

- Deterministik sentetik `Player` veri paketi
- Pozisyona göre attribute kümeleri ve takım-kadro referansları
- `CompetitionRules` JSON paketi
- Python validator ve 9 otomatik veri sözleşmesi testi
- Godot runtime için `DataPack` yükleyicisi
- Kaynak tipi, sezon ve şema sürümü metadata alanları
- Çalışan Kadro ekranı
- Deterministik 4-4-2 ilk 11 ve yedek kulübesi state'i
- İki oyuncuya sırayla basarak starter/bench değişimi
- Açık değer sözleşmesine sahip Taktikler ekranı
- Diziliş, zihniyet, markaj ve 0–100 taktik yoğunluklarının oturum state'i
- Yönetilen ilk 11 ve taktik state'inin deterministik maç profili/xG modeline bağlanması
- Sentetik ekonomi, haftalık maaş tahsilatı, sözleşme ve bonservis state'i
- Deterministik transfer pazarı ve yönetilen kadroya oyuncu imzası

## Faz 1: Veri sözleşmesi — sıradaki işler

- `Staff` ve `Venue` şemalarının yazılması
- Satış/kiralık/pazarlık kapsamını genişleten kulüp ekonomisi kuralları
- A takım kayıt kurallarını gerçek kadro akışına bağlayan doğrulama
- Lisanslı veri import'u için kaynak, çekim tarihi ve dönüştürme sürümü alanlarının genişletilmesi

## Faz 2: Menajerlik çekirdeği

- Takım seçme
- Takım seçimini tüm lig takımlarına açma
- Pozisyon uygunluğu, formasyon doğrulama ve üç alternatif rol skoru tamamlandı
- Antrenman planı
- Moral, form ve kondisyon
- Sakatlık ve cezalar

## Faz 3: Maç motoru

- Yönetilen takımın seçili ilk 11 attribute ortalamasının maç profiline dahil edilmesi (ilk prototip)
- Taktik state değerlerinin deterministik hücum, savunma ve kontrol profillerine bağlanması (ilk prototip)
- Deterministik temel maç olayları ve maç istatistikleri ilk rapor katmanı
- Oyuncu özelliklerinin tüm lig takımlarının varsayılan ilk 11 profillerine genişletilmesi
- Taktik eşleşmeleri ve pozisyon/rol uygunluğu
- Temel kondisyon/yorgunluk ve fikstür haftası etkisi
- Oyuncu değişiklikleri
- Kart ve sakatlık olayları
- Daha geniş maç özeti ve temel istatistik ekranı; ilk sentetik rapor katmanı tamamlandı
- Tekrar üretilebilir test senaryoları

## Faz 4: Transfer ve kulüp yönetimi

- Transfer listesi, sentetik imza akışı, sözleşme, maaş bütçesi ve bonservis ilk dilimi tamamlandı
- Kiralık transfer
- Yönetim hedefleri
- Taraftar memnuniyeti
- Sponsorluk ve gelirler

## Faz 5: Lig ekosistemi

- Türkiye Kupası
- Avrupa kupaları
- Alt ligden yükselme ve düşme
- Genç takım
- Scout ağı
- Haber ve olay sistemi
- Yapay zekâ menajer kararları

## Faz 6: Dağıtım

- Windows export
- Save migration (schema 3 -> 4)
- Mod desteği
- Veri paketleri
- Lisans ve credits ekranı
- Performans profili
- Kullanıcı testleri

## Tasarım kuralı

Her yeni özellik önce simülasyon çekirdeğinde test edilebilir hale getirilecek, daha sonra arayüze bağlanacak. Arayüzde görünen ama oyun sonucunu etkilemeyen sahte seçenekler eklenmeyecek.
