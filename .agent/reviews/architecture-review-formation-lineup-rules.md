# Architecture Review — Formasyon ve İlk 11 Uygunluğu

**Date:** 2026-09-11
**Reviewer:** Agent

## Verdict

Approved with conditions

## 🔴 Blockers

Yok.

## 🟡 Warnings

### 1. Alt oyuncu rolleri henüz veri sözleşmesinde yok

`players.json` yalnızca dört pozisyon grubu ve genel rol değerleri taşıyor. Bu
iş, gerçek bir oyuncunun “kanat bek” veya “regista” uygunluğunu uydurmayacak;
uygunluk kontrolü yalnızca mevcut pozisyon gruplarıyla sınırlı tutulacak.

**Action:** Bu sınır plan ve knowledge kaydında açıkça tutulacak.

### 2. Save formatı genişliyor

Aktif formasyon payload'a eklendiği için save schema sürümü artırılmalı. Eski
kayıtlar sessizce okunmamalı; kullanıcıya sürüm uyumsuzluğu hatası verilmesi
mevcut SaveGame davranışıyla uyumludur.

**Action:** `SAVE_SCHEMA_VERSION` 2 yapılacak ve testte formasyon uyumsuzluğu
reddedilecek.

## 🔵 Notes

### 1. Kural kataloğu merkezi tutuluyor

Formasyon pozisyon ihtiyaçları `SquadState`, `TacticsState` ve UI içine ayrı
ayrı yazılmayacak. Bu, ileride yeni formasyon eklenirken sessiz divergansı
önler.

## Summary

Plan küçük, yerel ve test edilebilir bir state değişikliğidir. UI taslak seçim
ile gerçek uygulamayı ayırdığı için hatalı veya eksik kadroda mevcut kariyer
durumu korunur. Alt rol uygunluğu bilinçli olarak sonraki veri sözleşmesine
bırakıldı.
