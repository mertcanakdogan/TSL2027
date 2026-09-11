# Veri klasörü

Bu klasör şu an yalnızca prototip verisi içerir.

## teams.json

- 2026-2027 sezonunda fikstürde görünen 18 takımın prototip kimliklerini içerir.
- `strength` alanı resmi oyuncu veya takım rating'i değildir.
- Güç değerleri yalnızca maç motorunun çalıştığını göstermek için sentetik olarak atanmıştır.
- Logo, forma, fotoğraf, oyuncu profili veya ham sağlayıcı API çıktısı içermez.

## players.json

- `tools/generate_synthetic_data.py` tarafından `teams.json` içinden deterministik olarak üretilir.
- 18 takımın her biri için 18 sentetik oyuncu içerir: 2 GK, 6 DF, 6 MF ve 4 FW.
- Attribute'lar pozisyona göre ayrılır ve 1–99 aralığında prototip değerlerdir.
- İsimler, kimlikler ve attribute'lar gerçek oyuncu kaydı veya resmi rating değildir.

## game_rules.json

- Lig takım sayısı, hafta sayısı, maç günü kadro sınırı, bench boyutu ve oyuncu değişikliği gibi kuralları runtime'dan ayırır.
- `CompetitionRules`, `DataPack` yüklenirken bu JSON sözleşmesini doğrular ve League/Squad/Save katmanlarına normalize eder.
- `squad` bölümü A takım kadro üst sınırını, bench boyutunu ve oyuncu uygunluk sınırlarını taşır; `economy` bölümü başlangıç bütçesi, haftalık gelir/maaş bütçesi ve transfer penceresini tanımlar.
- Ekonomi değerleri resmi kulüp finansmanı veya gerçek piyasa değeri değildir; yalnızca sentetik oyun dengesi kurallarıdır.
- Kural alanları ileride farklı sezon sürümlerinin aynı runtime tarafından yüklenebilmesi için JSON'da tutulur.

## Üretim ve doğrulama

```powershell
python tools/generate_synthetic_data.py
python tools/validate_data_pack.py
python tools/test_data_pack.py
```

Generator ağ kullanmaz ve aynı `teams.json` ile aynı çıktıyı üretir. Gerçek sağlayıcı verisi `data/raw/` veya `data/private/` altında tutulacak; bu dosyaların yerine geçirilmemelidir.

## İlerideki veri akışı

1. Kaynağın kullanım şartları ve dağıtım hakkı kontrol edilir.
2. Ham veri `data/raw/` altında tutulur ve repoya gönderilmez.
3. Dönüştürme aracı ham veriyi oyunun iç şemasına çevirir.
4. Oyuncu rating'leri kaynak rating'lerinin kopyası olarak değil, açıklanabilir bir modelle üretilir.
5. Her veri paketi kaynak, tarih, sürüm ve lisans bilgisiyle işaretlenir.
