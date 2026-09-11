# Veri klasörü

Bu klasör şu an yalnızca prototip verisi içerir.

## teams.json

- 2026-2027 sezonunda fikstürde görünen 18 takımın prototip kimliklerini içerir.
- `strength` alanı resmi oyuncu veya takım rating'i değildir.
- Güç değerleri yalnızca maç motorunun çalıştığını göstermek için sentetik olarak atanmıştır.
- Logo, forma, fotoğraf, oyuncu profili veya ham sağlayıcı API çıktısı içermez.

## İlerideki veri akışı

1. Kaynağın kullanım şartları ve dağıtım hakkı kontrol edilir.
2. Ham veri `data/raw/` altında tutulur ve repoya gönderilmez.
3. Dönüştürme aracı ham veriyi oyunun iç şemasına çevirir.
4. Oyuncu rating'leri kaynak rating'lerinin kopyası olarak değil, açıklanabilir bir modelle üretilir.
5. Her veri paketi kaynak, tarih, sürüm ve lisans bilgisiyle işaretlenir.
