# TSL2027

Trendyol Süper Lig 2026/27 sezonu için geliştirilen offline futbol menajerlik oyunu.

## Proje durumu

İlk teknik dikey dilim hazır:

- 18 takımlı çift devreli fikstür üretimi
- 34 haftalık lig akışı
- Deterministik maç simülasyonu
- Puan durumu ve temel maç merkezi
- Godot 4 + GDScript başlangıç arayüzü
- 18 takım için 324 oyuncudan oluşan sentetik veri paketi
- Sezon kurallarını ayrı JSON paketi olarak yükleme
- Runtime `CompetitionRules` modeliyle sezon, kadro, bench ve transfer penceresi kuralları tek kaynaktan okunur
- Veri paketi generator'ı ve Python doğrulama testleri
- Çalışan Kadro ekranı, 4-4-2 ilk 11 ve yedek oyuncu değişimi
- Transfer edilen oyuncuyu reserves durumundan yedek kulübesine ve uyumlu ilk 11 pozisyonuna taşıma akışı
- Çalışan Taktikler ekranı: diziliş, zihniyet, markaj ve 0-100 taktik yoğunlukları
- Yönetilen ilk 11 ve taktik state'inin deterministik maç profili/xG modeline etkisi
- Çalışan Fikstür ve Lig Tablosu ekranları; haftalık simülasyonla yenilenir
- Sürümlü JSON save/load: sezon, fikstür sonuçları, kadro ve taktik state'i
- 18 takımdan seçim yaparak yeni kariyer başlatma akışı
- Formasyon pozisyon uygunluğu, taslak taktik seçimi ve açık ilk 11 uygulaması
- Sentetik transfer pazarı, kulüp bütçesi, haftalık maaş tahsilatı ve sözleşme save/load akışı
- Deterministik maç olayları ve şut/isabetli şut/korner/faul/kart/xG istatistikleri
- Yedek kulübesinden türetilen deterministik oyuncu değişikliği olayları ve maç raporu gösterimi
- Pozisyona göre üç alternatif rol uygunluğu ve oyuncu profillerinin maç profiline etkisi
- Sezon bitiminde şampiyon ve üç küme düşen takımı gösteren türetilmiş özet
- Araştırma, veri politikası ve geliştirme yol haritası

Bu sürüm gerçek oyuncu verisi, kulüp logosu veya oyuncu fotoğrafı içermez. Takım güçleri ve oyuncu attribute'ları yalnızca maç motoru ile menajerlik ekranlarını geliştirmek için hazırlanmış sentetik prototip varsayımlarıdır.

## Çalıştırma

1. Godot 4.x stable sürümünü yükle.
2. Godot Project Manager üzerinden bu klasördeki `project.godot` dosyasını içe aktar.
3. Projeyi çalıştır.

Ana ekran açıldığında "Haftayı Oynat" butonu o haftadaki 9 maçı simüle eder ve puan durumunu günceller.

Windows için yerel export ve paketlenmiş uygulama smoke testi:

```powershell
.\tools\verify_windows_export.ps1 -GodotPath "C:\path\to\Godot_v4.7.2-stable_win64.exe"
```

Komut `build/TSL2027.exe` üretir, ardından export edilen uygulamayı headless
modda başlatıp temiz biçimde kapanabildiğini doğrular. `build/` ve geçici loglar
Git'e eklenmez. Temiz bir bilgisayar, imza ve installer testi bu yerel kontrolden
ayrı bir yayın kapısıdır.

Portable Windows paketini oluşturmak ve temiz bir klasörden doğrulamak için:

```powershell
.\tools\package_windows_release.ps1
.\tools\verify_windows_release.ps1
```

Paket `dist/TSL2027-windows-x64.zip` altında oluşur ve executable ile birlikte
README, MIT lisansı ve veri politikasını taşır.

Tüm yerel doğrulamayı tek komutla çalıştırmak için:

```powershell
.\tools\verify_project.ps1 -GodotPath "C:\path\to\Godot_v4.7.2-stable_win64.exe"
```

Windows export şablonları olmayan ortamlar için `-SkipWindowsRelease` kullanılabilir.

Kayıt sistemi `user://tsl2027_save.json` için geçici yazma ve `.bak` yedeği
kullanır; bozuk ana JSON bulunduğunda geçerli yedeğe dönmeyi dener.
İlk 11 oyuncuları her oynanan haftadan sonra kondisyon kaybeder; yedek ve
kullanılmayan oyuncuların kondisyonu deterministik olarak toparlanır.

Veri paketi kontrolü için:

```powershell
python tools/generate_synthetic_data.py
python tools/validate_data_pack.py
python tools/test_data_pack.py
godot --headless --path . --script res://tests/competition_rules_test.gd
godot --headless --path . --script res://tests/squad_state_test.gd
godot --headless --path . --script res://tests/tactics_state_test.gd
godot --headless --path . --script res://tests/match_engine_test.gd
godot --headless --path . --script res://tests/league_views_test.gd
godot --headless --path . --script res://tests/economy_state_test.gd
godot --headless --path . --script res://tests/transfer_market_test.gd
godot --headless --path . --script res://tests/player_role_rules_test.gd
godot --headless --path . --script res://tests/save_game_test.gd
godot --headless --path . --script res://tests/main_scene_smoke_test.gd
```

## Teknik karar

İlk teknoloji seçimi Godot 4 ve GDScript'tir.

Bu oyun öncelikle:

- tablo, kadro, fikstür ve transfer ekranlarından,
- veri ağırlıklı menülerden,
- deterministik ve test edilebilir bir simülasyon çekirdeğinden

oluşacağı için ilk aşamada ağır 3D motor veya düşük seviyeli C++ kodu gerekmiyor. Veri hazırlama ve doğrulama için gerektiğinde Python yardımcı araçları kullanılabilir; oyun runtime'ı Godot içinde kalır.

## Klasörler

- `data/`: Örnek ve ileride dönüştürülmüş oyun verileri
- `docs/`: Araştırma, lisans politikası ve yol haritası
- `scenes/`: Godot sahneleri
- `scripts/core/`: Veri paketi, fikstür, lig, taktik, ekonomi, transfer ve maç simülasyonu
- `scripts/`: Godot arayüz kodu
- `tools/`: Harici veri doğrulama araçları

## Lisans ve veri politikası

Bu repodaki özgün kaynak kodu MIT License kapsamındadır.

MIT License, üçüncü taraf futbol verilerine, kulüp logolarına, fotoğraflara veya veri sağlayıcılarının ham API çıktısına otomatik kullanım hakkı vermez. Ayrıntılı politika için [DATA_AND_LICENSING.md](docs/DATA_AND_LICENSING.md) dosyasına bak.

## Belgeler

- [Araştırma ve teknik kararlar](docs/RESEARCH_AND_DECISIONS.md)
- [Veri ve lisans politikası](docs/DATA_AND_LICENSING.md)
- [Yol haritası](docs/ROADMAP.md)
- [Canlıya alma hazırlık kapıları](docs/RELEASE_READINESS.md)
- [Release doğrulama kanıtı](docs/RELEASE_EVIDENCE.md)
- [Örnek veri notları](data/README.md)
- [Değişiklik günlüğü](CHANGELOG.md)
