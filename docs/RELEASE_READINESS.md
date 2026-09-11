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
- [ ] Takım seçimi ve yeni oyun akışı.
- [ ] Formasyon/rol uygunluğu ve tüm lig takımlarında oyuncu attribute etkisi.
- [ ] Taktik etkileri, maç olayları ve maç istatistikleri için deterministik
  senaryolar.
- [x] Sürümlü save/load ve bozuk/veri paketi uyumsuz kayıt reddi.
- [x] Fikstür ve lig tablosu ekranlarının placeholder olmaktan çıkarılması.
- [ ] Transfer ekranının ekonomi ve sözleşme state'iyle gerçek hale gelmesi.
- [ ] Windows export, temiz makinede açılış ve temel kullanıcı akışı smoke testi.
- [ ] Credits, lisans sınırları, sentetik veri bildirimi ve kullanıcıya görünür
  veri politikası.

## Yayın koşulu

Yukarıdaki teknik kapılar tamamlanmadan “canlıya hazır” denmez. Her kapı için
çalışan test, komut çıktısı veya elle doğrulanmış build kanıtı tutulur. Gerçek
veri kullanılacaksa kaynak, çekim tarihi, dönüşüm sürümü ve kullanım hakkı
ayrıca kayıt altına alınır; ücretsiz ve özel kullanım sınırı aşılırsa veri
entegrasyonu durdurulur.
