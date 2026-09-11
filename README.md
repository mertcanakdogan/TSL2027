# TSL2027

Trendyol Süper Lig 2026/27 sezonu için geliştirilen offline futbol menajerlik oyunu.

## Proje durumu

İlk teknik dikey dilim hazır:

- 18 takımlı çift devreli fikstür üretimi
- 34 haftalık lig akışı
- Deterministik maç simülasyonu
- Puan durumu ve temel maç merkezi
- Godot 4 + GDScript başlangıç arayüzü
- Sentetik örnek takım verisi
- Araştırma, veri politikası ve geliştirme yol haritası

Bu sürüm gerçek oyuncu verisi, kulüp logosu veya oyuncu fotoğrafı içermez. Takım güçleri yalnızca maç motorunu göstermek için hazırlanmış prototip varsayımlarıdır.

## Çalıştırma

1. Godot 4.x stable sürümünü yükle.
2. Godot Project Manager üzerinden bu klasördeki \`project.godot\` dosyasını içe aktar.
3. Projeyi çalıştır.

Ana ekran açıldığında "Haftayı Oynat" butonu o haftadaki 9 maçı simüle eder ve puan durumunu günceller.

## Teknik karar

İlk teknoloji seçimi Godot 4 ve GDScript'tir.

Bu oyun öncelikle:

- tablo, kadro, fikstür ve transfer ekranlarından,
- veri ağırlıklı menülerden,
- deterministik ve test edilebilir bir simülasyon çekirdeğinden

oluşacağı için ilk aşamada ağır 3D motor veya düşük seviyeli C++ kodu gerekmiyor. Veri hazırlama ve doğrulama için gerektiğinde Python yardımcı araçları kullanılabilir; oyun runtime'ı Godot içinde kalır.

## Klasörler

- \`data/\`: Örnek ve ileride dönüştürülmüş oyun verileri
- \`docs/\`: Araştırma, lisans politikası ve yol haritası
- \`scenes/\`: Godot sahneleri
- \`scripts/core/\`: Fikstür, lig ve maç simülasyonu
- \`scripts/\`: Godot arayüz kodu
- \`tools/\`: Harici veri doğrulama araçları

## Lisans ve veri politikası

Bu repodaki özgün kaynak kodu MIT License kapsamındadır.

MIT License, üçüncü taraf futbol verilerine, kulüp logolarına, fotoğraflara veya veri sağlayıcılarının ham API çıktısına otomatik kullanım hakkı vermez. Ayrıntılı politika için [DATA_AND_LICENSING.md](docs/DATA_AND_LICENSING.md) dosyasına bak.

## Belgeler

- [Araştırma ve teknik kararlar](docs/RESEARCH_AND_DECISIONS.md)
- [Veri ve lisans politikası](docs/DATA_AND_LICENSING.md)
- [Yol haritası](docs/ROADMAP.md)
- [Örnek veri notları](data/README.md)
