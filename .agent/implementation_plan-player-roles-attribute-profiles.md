# Player Roles and Attribute Profiles Implementation Plan

## Objective

Turn the existing position-only synthetic player data into deterministic
secondary-role scores and positional match profiles, and make those profiles
available to every league team's default XI.

## Scope

- Add three transparent secondary roles for GK, DF, MF, and FW.
- Calculate role fit and overall/attack/defense/control profiles from the
  existing attribute fields.
- Use the profiles in MatchEngine and expose the best role in Kadro.
- Register default XI contexts for all 18 teams while preserving managed-team
  overrides.
- Add data-pack, profile, match, and main-scene regression coverage.

## Out of scope

- Real-player ratings, learned weights, injuries, or event-window simulation;
  report-level substitutions do not alter this role/profile boundary.

## Acceptance evidence

1. All 324 prototype players have three role scores and four valid profiles.
2. Changing relevant attributes changes the appropriate profile and match
   profile with the same seed.
3. All 18 league teams supply a default XI context to LeagueState.
