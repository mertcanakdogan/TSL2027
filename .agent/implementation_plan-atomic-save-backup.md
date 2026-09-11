# Atomic Save and Backup Implementation Plan

## Objective

Prevent a partially written save from replacing the last usable career and
recover automatically from a malformed primary save when a backup exists.

## Scope

- Write JSON to a temporary user-storage file.
- Move the previous save to a `.bak` backup before committing the new file.
- Restore the old file if the commit move fails.
- Fall back to the backup when the primary JSON cannot be parsed.
- Expose whether the primary or backup was loaded in the UI and tests.

## Out of scope

- Cloud saves, multiple named save slots, schema migration, or conflict
  resolution across machines.

## Acceptance evidence

1. Normal save/load remains compatible with save schema 3.
2. A second save produces a backup and a corrupt primary recovers from it.
3. Invalid schema/formation payloads still fail without mutating state.
