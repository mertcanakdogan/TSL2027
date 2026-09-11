# Test Specification — Squad Screen and Lineup State

## Acceptance tests

1. `test_valid_roster_initializes_with_expected_group_sizes`
   - An 18-player roster initializes to 11 starters and 7 bench players.
2. `test_default_starting_xi_uses_explicit_4_4_2_position_counts`
   - The default XI contains exactly 1 GK, 4 DF, 4 MF, and 2 FW.
3. `test_each_current_roster_player_belongs_to_exactly_one_group`
   - No player is duplicated or omitted between the starting XI and bench.
4. `test_initialize_rejects_duplicate_player_ids`
   - Duplicate IDs fail initialization and leave an error message.
5. `test_swap_rejects_unknown_or_same_group_players`
   - Invalid swaps return false and do not alter group membership.
6. `test_swap_moves_one_starter_and_one_bench_player`
   - A valid swap removes the starter from XI, promotes the bench player, and preserves group sizes.
7. `test_main_scene_smoke`
   - The main scene creates `SquadView`, switches between dashboard and Kadro, and still advances one match week.

## Red phase expectation

The Godot test script initially fails because `SquadState` does not exist. The implementation is complete when the Godot test exits with code 0 and the existing Python/data and main-scene checks remain green.
