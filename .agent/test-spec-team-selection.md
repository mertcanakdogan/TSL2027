# Test Specification — Team Selection and New Career Flow

## Acceptance tests

1. `test_selector_lists_all_loaded_teams`
   - The Team Seç view contains all 18 data-pack teams.
2. `test_selecting_team_reinitializes_managed_state`
   - Choosing Fenerbahçe (or another loaded team) produces its 18-player
     roster, 34 fixtures, week one, and zero played matches.
3. `test_views_follow_selected_team`
   - Kadro and Fikstür use the selected team ID/name after restart.
4. `test_new_career_is_explicit`
   - State is not reset merely by opening the selector; reset occurs only when
     the new-career action is triggered.

## Red phase expectation

The main-scene smoke test initially fails because runtime identity and views are
fixed to Kocaelispor. Completion requires all existing tests plus this new
selection path to pass.
