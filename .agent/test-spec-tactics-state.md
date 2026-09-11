# Test Specification — Tactical State and Taktikler Screen

## Acceptance tests

1. `test_defaults_are_explicit`
   - New state is `4-4-2`, balanced, zonal, and all numeric values are 50.
2. `test_valid_categorical_updates`
   - A supported formation, mentality, and marking approach can be selected.
3. `test_invalid_categorical_updates_do_not_mutate_state`
   - Unsupported values return false and preserve the previous snapshot.
4. `test_numeric_parameters_accept_bounds`
   - 0 and 100 are accepted for every numeric parameter.
5. `test_numeric_parameters_reject_out_of_range_values`
   - Values below 0 or above 100 are rejected without changing the value.
6. `test_snapshot_is_a_plain_serializable_dictionary`
   - Snapshot keys and values can be consumed without exposing mutable internals.
7. `test_main_scene_smoke`
   - The main scene creates `TacticsView`, switches to it, returns to the
     dashboard, and still advances one match week.

## Red phase expectation

The state test initially fails because `TacticsState` does not exist. The
implementation is complete when the Godot test exits with code 0 and the
existing Python/data, squad, and main-scene checks remain green.
