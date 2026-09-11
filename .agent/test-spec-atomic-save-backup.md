# Atomic Save and Backup Test Specification

## Write path

- Save is written through a temporary file and commits successfully.
- A second save creates `user://...json.bak`.
- The primary save remains valid after a successful commit.

## Recovery path

- Corrupt primary JSON loads from the backup and reports `backup` as source.
- Valid primary JSON reports `primary` as source.
- Invalid schema and formation payloads are rejected without state mutation.
- Missing save still fails with an error.

## Regression coverage

- Existing squad, tactics, match, league, economy, transfer, role, and main
  scene tests remain green.
