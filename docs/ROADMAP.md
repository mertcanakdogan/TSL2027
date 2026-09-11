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

## Faz 1: Veri sözleşmesi

- Team, Player, Staff, Venue ve CompetitionRules şemalarının yazılması
- JSON şema doğrulaması
- Sentetik 18 takım için oyuncu kadrolarının üretilmesi
- Kulüp ekonomisi için temel alanların eklenmesi
- Kaynak, tarih ve versiyon metadata yapısı

## Faz 2: Menajerlik çekirdeği

- Takım seçme
- Kadro listesi
- İlk 11 ve yedek kulübesi
- Pozisyon uygunluğu
- Formasyon ve rol seçimi
- Antrenman planı
- Moral, form ve kondisyon
- Sakatlık ve cezalar

## Faz 3: Maç motoru

- Oyuncu özelliklerinin simülasyona dahil edilmesi
- Taktik eşleşmeleri
- Yorgunluk ve fikstür yoğunluğu
- Oyuncu değişiklikleri
- Kart ve sakatlık olayları
- Maç özeti ve temel istatistik ekranı
- Tekrar üretilebilir test senaryoları

## Faz 4: Transfer ve kulüp yönetimi

- Transfer listesi
- Sözleşme
- Maaş bütçesi
- Bonservis
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
- Save migration
- Mod desteği
- Veri paketleri
- Lisans ve credits ekranı
- Performans profili
- Kullanıcı testleri

## Tasarım kuralı

Her yeni özellik önce simülasyon çekirdeğinde test edilebilir hale getirilecek, daha sonra arayüze bağlanacak. Arayüzde görünen ama oyun sonucunu etkilemeyen sahte seçenekler eklenmeyecek.
