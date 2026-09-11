# Atomic Save and Backup Boundary

- `SaveGame` writes to `<save>.tmp`, then commits to the primary path.
- The prior primary is retained as `<save>.bak` before a replacement.
- A malformed or missing primary can fall back to a valid backup.
- Schema and semantic validation still run on the selected payload before any
  runtime state is mutated.
- Save paths remain restricted to `user://`.
