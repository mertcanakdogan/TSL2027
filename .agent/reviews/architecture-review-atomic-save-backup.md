# Architecture Review: Atomic Save and Backup

## Decision

Keep save durability inside `SaveGame`, using user-scoped `.tmp` and `.bak`
paths. Validation continues to happen before state restore, and the main scene
only reports the load source.

## Review notes

- Safety: the public API still accepts only `user://` paths.
- Recovery: the prior save is retained before a new commit; failed commit moves
  attempt to restore it.
- Compatibility: save schema remains 3; no migration is silently introduced.
- Observability: a backup load is visible in the result label and exposed as a
  stable `last_load_source` value for tests.
