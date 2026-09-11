# Test Specification — Phase 1 Data Contract

## Acceptance tests

1. `test_checked_in_data_pack_is_valid`
   - The repository data pack passes every structural and referential validation.
2. `test_generation_is_deterministic`
   - Running the generator twice from the same team input produces identical JSON bytes.
3. `test_every_team_has_required_position_counts`
   - Each of the 18 teams has exactly 2 goalkeepers, 6 defenders, 6 midfielders, and 4 forwards.
4. `test_player_attributes_are_position_specific_and_bounded`
   - Required attributes exist for each position and every value is an integer in the 1–99 range.
5. `test_rules_are_explicit`
   - The competition rules expose the expected 18-team, 34-week, 21-player matchday, and 5-substitution values.
6. `test_validator_rejects_unknown_team_reference`
   - A player referencing a missing team produces a validation failure.
7. `test_validator_rejects_duplicate_player_id`
   - Duplicate player IDs produce a validation failure.
8. `test_validator_rejects_out_of_range_attribute`
   - An attribute below 1 or above 99 produces a validation failure.

## Red phase expectation

The tests initially fail because the data-pack validator, generator, and generated files do not exist yet. The implementation is complete only when all tests pass and the standalone validator exits with code 0.
