# Architecture Review — Versioned Save and Load

**Date:** 2026-09-11
**Reviewer:** Agent

## Verdict

Approved with conditions

## Blockers

None.

## Conditions

1. Saves must reference the active data-pack/schema version and must not embed
   provider payloads or duplicate immutable player records.
2. Validate the full payload before applying any sub-state; a corrupt save may
   not leave a half-restored season.
3. Starter/bench IDs must be checked against the current roster and duplicate
   IDs rejected.
4. There is no migration contract yet, so an unsupported version must fail
   clearly rather than guessing.
5. Writes use an explicit `user://` path; no repository data is overwritten.

## Notes

The first release needs one reliable slot more than a broad save UI. The payload
is intentionally plain JSON so it remains inspectable, testable, and migratable
later without coupling persistence to scene nodes.
