# Test Specification — Versioned Save and Load

## Acceptance tests

1. `test_round_trip_restores_runtime_state`
   - Save after playing a week and changing lineup/tactics, mutate runtime,
     then load and restore the saved week, IDs, tactics, and fixture results.
2. `test_payload_contains_explicit_versions`
   - Save payload contains save schema and data-pack schema versions.
3. `test_wrong_data_schema_is_rejected_atomically`
   - A schema mismatch returns false and leaves current week and tactics intact.
4. `test_corrupt_json_is_rejected`
   - Malformed JSON returns false with a useful error message.
5. `test_missing_file_is_rejected`
   - Missing path returns false without changing runtime state.
6. `test_main_save_load_actions_are_wired`
   - Main scene exposes save/load buttons and refreshes after a successful load.

## Red phase expectation

The test initially fails because snapshots, `SaveGame`, and UI actions do not
exist. Completion requires all existing Python and Godot tests to remain green.
