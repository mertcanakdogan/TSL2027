# Canlıya Alma Hazırlık Kapıları

Bu proje yayınlanabilir bir offline prototip olarak paketlenmeden önce aşağıdaki
kapılardan geçmelidir. Sentetik veriyle çalışan bir build teknik olarak
dağıtılabilir; gerçek oyuncu, logo, fotoğraf veya üçüncü taraf veri kullanımı
ise ayrıca lisans ve kaynak doğrulaması gerektirir.

## Mevcut durum

- [x] Godot 4 projesi açılıyor ve ana sahne yükleniyor.
- [x] 18 takım, 34 hafta, 306 maç ve sentetik veri paketi doğrulanıyor.
- [x] Kadro state'i ve starter/bench değişimi headless testlerle doğrulanıyor.
- [x] Taktikler state'i ve ekranı doğrulanıyor; değerler henüz maç motoruna
  bağlanmış kabul edilmiyor.
- [ ] Takım seçimi ve yeni oyun akışı.
- [ ] Formasyon/rol uygunluğu ve oyuncu attribute'larının maç motoruna etkisi.
- [ ] Taktik etkileri, maç olayları ve maç istatistikleri için deterministik
  senaryolar.
- [ ] Save/load, veri paketi sürümü ve bozuk kayıt kurtarma davranışı.
- [ ] Fikstür, lig tablosu ve transfer ekranlarının placeholder olmaktan çıkması.
- [ ] Windows export, temiz makinede açılış ve temel kullanıcı akışı smoke testi.
- [ ] Credits, lisans sınırları, sentetik veri bildirimi ve kullanıcıya görünür
  veri politikası.

## Yayın koşulu

Yukarıdaki teknik kapılar tamamlanmadan “canlıya hazır” denmez. Her kapı için
çalışan test, komut çıktısı veya elle doğrulanmış build kanıtı tutulur. Gerçek
veri kullanılacaksa kaynak, çekim tarihi, dönüşüm sürümü ve kullanım hakkı
ayrıca kayıt altına alınır; ücretsiz ve özel kullanım sınırı aşılırsa veri
entegrasyonu durdurulur.
