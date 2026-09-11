# Test Sözleşmesi — Formasyon ve İlk 11 Uygunluğu

## Unit — SquadState

- `formation_requirements_cover_supported_formations`: Beş formasyonun her biri
  11 oyuncu ve 1 GK gerektirir.
- `apply_formation_rebuilds_starting_xi_with_required_positions`: 4-3-3 ve
  5-3-2 uygulandığında ilk 11 pozisyon sayıları katalogla eşleşir.
- `apply_formation_rejects_insufficient_roster_without_mutation`: Eksik FW/DF
  kadrosunda uygulama başarısız olur ve önceki starter/bench korunur.
- `swap_players_rejects_change_that_breaks_active_formation`: Starter/bench
  değişimi aktif formasyonun pozisyon dağılımını bozarsa reddedilir.

## Integration — SaveGame

- `save_round_trip_restores_active_formation`: Aktif 4-3-3 formasyonu save/load
  sonrasında hem SquadState hem TacticsState içinde korunur.
- `load_rejects_mismatched_squad_and_tactics_formations`: İki state'in
  formasyonları farklıysa kayıt mevcut oyunu değiştirmeden reddedilir.

## UI smoke

- Formasyon seçimi uygulama butonuna basılana kadar state'i değiştirmez.
- Uygulama sonrası TacticsState, SquadState ve LeagueState context aynı
  formasyonu taşır.

## Doğrulama komutları

Godot 4.7.2 headless testleri, editor parse kontrolü, veri paketi doğrulaması
ve Python veri paketi testleri birlikte çalıştırılır.
