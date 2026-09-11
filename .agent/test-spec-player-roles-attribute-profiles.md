# Player Roles and Attribute Profiles Test Specification

## Role coverage

- Every loaded player has three role scores for their position.
- Every loaded player has valid overall, attack, defense, and control ratings.
- A clinical finishing increase changes a forward's attacking profile and role
  ordering.

## Match coverage

- Higher otherwise-comparable XI attributes raise attack and defense profiles
  under the same seed.
- Existing deterministic replay and event/stat contracts remain unchanged.

## Runtime coverage

- Main scene registers default contexts for all 18 teams.
- Existing squad, transfer, save/load, league, and UI smoke tests remain green.
