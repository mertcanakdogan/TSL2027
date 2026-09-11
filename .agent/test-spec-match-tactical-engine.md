# Test Specification — Player and Tactical Match Effects

## Acceptance tests

1. `test_same_seed_and_context_replay_identically`
   - Two simulations with the same teams, contexts, and seed return equal
     dictionaries.
2. `test_without_context_uses_team_strength_fallback`
   - Missing contexts use team strength and still return bounded xG and
     possession values.
3. `test_selected_xi_changes_profile`
   - A high-attribute XI gives a higher effective profile than a low-attribute
     XI for equal team records.
4. `test_tactics_change_attack_and_defense_profiles`
   - Attacking/pressing context changes the named profile fields in the
     documented direction.
5. `test_context_effect_reaches_xg`
   - With the same seed and opponent, the stronger/tactically supported context
     produces greater xG than the weaker context.
6. `test_league_accepts_and_refreshes_team_context`
   - A managed team context can be registered and replaced without changing
     team records or fixture identity.

## Red phase expectation

The match test initially fails because the context-aware API and profile fields
do not exist. Completion requires all new tests plus the existing Python and
Godot state/smoke tests to pass.
