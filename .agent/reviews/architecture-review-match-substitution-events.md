# Architecture Review — Match Substitution Events

**Date:** 2026-09-11
**Reviewer:** Agent

## Verdict

Approved with conditions.

## Findings

### 🔴 Blockers

None.

### 🟡 Warnings

1. Match results are immutable reports in the current slice. Do not mutate
   `SquadState` or a lineup from inside `MatchEngine`; a future in-match state
   model can own that behavior.
2. Three substitutions per side are a synthetic reporting cap for this
   prototype, not a statement of applicable 2026/27 regulations.

### 🔵 Notes

1. Bench propagation is a copied dictionary field and creates no circular
   dependency: `main.gd` assembles context, `MatchEngine` consumes it.
2. The existing event sorter keeps the result deterministic; random minutes are
   generated only from the seeded RNG already used by the engine.
3. Missing bench arrays must remain a supported fallback for direct engine
   callers and older serialized contexts.

## Boundary checks

- **Ownership:** SquadState owns roster membership; MatchEngine owns generated
  match report events.
- **Persistence:** no schema migration required.
- **Failure modes:** malformed/empty bench data yields zero substitutions;
  player names fall back to IDs.
- **Security/dependencies:** no external input, secrets, or network calls.

## Condition to proceed

Add engine assertions before implementation, preserve the no-bench fallback, and
run the full verification command before merge.
