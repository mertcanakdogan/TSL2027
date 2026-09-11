# Canlıya Alma Hazırlık Kapıları

Bu proje yayınlanabilir bir offline prototip olarak paketlenmeden önce aşağıdaki
kapılardan geçmelidir. Sentetik veriyle çalışan bir build teknik olarak
dağıtılabilir; gerçek oyuncu, logo, fotoğraf veya üçüncü taraf veri kullanımı
ise ayrıca lisans ve kaynak doğrulaması gerektirir.

## Mevcut durum

- [x] Godot 4 projesi açılıyor ve ana sahne yükleniyor.
- [x] 18 takım, 34 hafta, 306 maç ve sentetik veri paketi doğrulanıyor.
- [x] Kadro state'i ve starter/bench değişimi headless testlerle doğrulanıyor.
- [x] Taktikler state'i ve ekranı doğrulanıyor.
- [x] Yönetilen ilk 11 ve taktik state'i deterministik maç profiline/xG'ye
  bağlanıyor; sentetik prototip formülü test ediliyor.
- [x] 18 takımdan seçim yapma ve açık “Yeni Kariyeri Başlat” akışı.
- [x] Beş formasyon için GK/DF/MF/FW pozisyon uygunluğu ve açık ilk 11 uygulaması.
- [x] Alt oyuncu rolü uygunluğu ve tüm lig takımlarında oyuncu attribute etkisi.
- [x] Taktik etkileri, maç olayları ve maç istatistikleri için deterministik
  senaryolar.
- [x] Sürümlü save/load, aktif formasyonun saklanması, uyumsuz kayıt reddi ve
  temporary-write/backup recovery.
- [x] Haftalık managed-player kondisyon düşüşü, bench recovery, maç profili
  etkisi ve schema 3 -> 4 migration.
- [x] Fikstür ve lig tablosu ekranlarının placeholder olmaktan çıkarılması.
- [x] Transfer ekranının sentetik ekonomi, maaş bütçesi, sözleşme ve imza state'iyle gerçek hale gelmesi.
- [x] Deterministik temel maç olayları, skorla tutarlı gol olayları ve maç istatistikleri.
- [x] Windows Desktop export ve paketlenmiş executable'ın yerel headless
  açılış/kapanış smoke testi.
- [x] Portable Windows ZIP paketi ve taze geçici klasörden paket runtime smoke
  testi.
- [ ] Temiz makinede açılış, temel kullanıcı akışı, installer ve code-signing
  testi.
- [x] Credits, lisans sınırları, sentetik veri bildirimi ve kullanıcıya görünür
  veri politikası.

## Yayın koşulu

Yukarıdaki teknik kapılar tamamlanmadan “canlıya hazır” denmez. Her kapı için
çalışan test, komut çıktısı veya elle doğrulanmış build kanıtı tutulur. Gerçek
veri kullanılacaksa kaynak, çekim tarihi, dönüşüm sürümü ve kullanım hakkı
ayrıca kayıt altına alınır; ücretsiz ve özel kullanım sınırı aşılırsa veri
entegrasyonu durdurulur.
