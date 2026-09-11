# Player Roles and Attribute Profiles Boundary

- `PlayerRoleRules` is the single source of truth for position role lists and
  profile attribute groups.
- Role/profile values are synthetic prototype calculations, not official
  ratings or claims about real players.
- `MatchEngine` aggregates copied starting-XI records into team profiles.
- Main scene registers a default starting-XI context for each league team;
  managed team state can override its own context before each week.
