# Architecture Review — Transfer, Ekonomi ve Sözleşmeler

**Date:** 2026-09-11
**Reviewer:** Agent

## Verdict

Approved with conditions

## 🔴 Blockers

Yok. Akış tamamen local/offline ve yeni dış bağımlılık eklemiyor.

## 🟡 Warnings

### 1. Dinamik kadro save payload'u büyür

Transfer sonrası kadronun temiz kuruluma yüklenebilmesi için snapshot oyuncu
kayıtlarını da taşıyacak. Bu, 28 oyuncu sınırında küçük ve öngörülebilir bir
payload'tur; binary format veya veritabanı bu aşamada gereksizdir.

**Action:** Snapshot'ta roster kayıtları doğrulanacak; maksimum kadro kuralı
state katmanında korunacak.

### 2. Ekonomi değerleri resmi finans verisi değildir

Başlangıç bütçesi, ücret ve maaş hesapları sentetik proje kararlarıdır.

**Action:** `game_rules.json`, README ve release readiness bu sınırı görünür
tutacak; gerçek kulüp finansmanı iddia edilmeyecek.

### 3. Save schema kırılacak

Ekonomi/market/dinamik roster alanları mevcut payload sözleşmesini değiştirir.

**Action:** Schema 3'e yükseltilecek; eski kayıtlar sessizce migrate edilmeyecek
ve mevcut kullanıcıya açık uyumsuzluk hatası gösterilecek.

## 🔵 Notes

İmza işleminin tek bir orchestrator üzerinden yürütülmesi market, ekonomi ve
kadro arasında kısmi başarı riskini azaltır. `TransferMarketState` UI'dan
bağımsız kaldığı için deterministik test kolaydır.

## Summary

Bu dilim transferi oyun döngüsüne bağlayan en küçük anlamlı state setidir.
Satış/pazarlık/çoklu sezon ekonomisi bilinçli olarak sonraya bırakılmıştır;
ama satın alma, bütçe, kontrat, hafta tahsilatı ve persistence uçtan uca
çalışır durumda olacaktır.
