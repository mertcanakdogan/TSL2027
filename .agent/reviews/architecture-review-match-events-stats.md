# Architecture Review — Maç Olayları ve İstatistikleri

**Date:** 2026-09-11
**Reviewer:** Agent

## Verdict

Approved

## 🔴 Blockers

Yok.

## 🟡 Warnings

### 1. Olaylar özet modelidir

Olay üretimi tam aksiyon simülasyonu değildir. Bu, mevcut deterministic
prototipin kapsamıyla uyumludur; UI bunu maç raporu olarak sunmalı, gerçek
yayın verisi iddiası taşımamalıdır.

### 2. Fixture snapshot alanları büyür

Yeni alanlar mevcut fixture result sözleşmesine eklenir ancak JSON snapshot
mekanizması zaten derin kopya kullandığı için yeni migration gerektirmez.

## 🔵 Notes

Olay üretiminin MatchEngine'de kalması, seed/rng sahipliğini tek yerde tutar ve
LeagueState'i yalnızca fixture/standings orkestratörü olarak bırakır.

## Summary

Plan mevcut motorun basitliğini korurken maç sonucunu kullanıcı için anlamlı
hale getiriyor. Üretim ve doğrulama dış I/O kullanmıyor; skor, istatistik ve
olay tutarlılığı testlerle güvenceye alınıyor.
