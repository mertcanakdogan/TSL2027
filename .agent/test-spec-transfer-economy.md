# Test Sözleşmesi — Transfer, Ekonomi ve Sözleşmeler

## Data contract

- `economy_rules_are_explicit`: Başlangıç bütçesi, gelir, maaş bütçesi ve
  transfer penceresi değerleri kurallarda bulunur.
- `generator_keeps_economy_rules_deterministic`: Sentetik veri generator'ı
  economy bölümünü tekrar üretimde byte-for-byte korur.

## EconomyState

- `initializes_deterministic_budget_and_contracts`: Aynı takım/kadro aynı
  bütçe, maaş ve sözleşme kaydını üretir.
- `advance_week_settles_revenue_and_wages_once`: Aynı hafta ikinci kez
  tahsilat yapmaz.
- `register_transfer_rejects_budget_overrun_without_mutation`: Bakiye veya
  maaş bütçesi yetmezse ekonomi state'i değişmez.
- `snapshot_round_trip_restores_contracts`: Snapshot round-trip tüm ekonomi
  alanlarını korur.

## TransferMarketState

- `market_excludes_managed_team_and_is_deterministic`: Teklifler yönetilen
  takım oyuncularını içermez ve tekrar üretilebilir.
- `sign_player_is_atomic_across_market_economy_and_squad`: Başarılı imza üç
  state'i günceller; hata durumunda üçü de önceki hali korur.
- `signed_player_is_removed_from_market`: Aynı oyuncu ikinci kez imzalanamaz.

## Save/UI smoke

- Save/load dinamik roster, economy ve market snapshot'ını korur.
- Transfer ekranındaki imza akışı gerçek yönetilen takıma oyuncu ekler.
- Haftayı oynatmak ekonomi bakiyesini günceller.

## Doğrulama komutları

Godot headless unit/integration/smoke testleri, editor parse, veri paketi
validator'ı ve Python data-contract testleri birlikte çalıştırılır.
