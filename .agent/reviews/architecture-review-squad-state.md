# Architecture Review — Squad Screen and Lineup State

**Date:** 2026-09-11
**Reviewer:** Agent

## Verdict

Approved with conditions

## 🔴 Blockers

None.

## 🟡 Warnings

### 1. The default 4-4-2 is a prototype baseline

It is not evidence of a real club lineup and must stay explicit in code and UI documentation. Later formation selection should replace the baseline through a tactics contract, not by adding hidden heuristics here.

### 2. Current lineup state is session-only

The selection is intentionally not persisted yet. A future save system must serialize IDs and validate them against the active data-pack version before restoring them.

### 3. UI selection must not mutate source data

The view may reorder/group player IDs, but `players.json` and the `DataPack` source records must remain immutable. `SquadState` should keep a deep copy or IDs only.

## 🔵 Notes

### 1. Keep swap rules small

Two-player starter/bench swaps are sufficient for this slice. Position legality and tactical roles can be introduced with the tactics feature once the rules are explicit.

### 2. Headless Godot testing is appropriate

The state is a pure `RefCounted` object, so a small `SceneTree` test script gives deterministic coverage without adding a test framework dependency.

## Summary

The separation between immutable `DataPack` records and mutable match-preparation state is the smallest design that makes the Kadro screen real without coupling it to the match engine. The main conditions are explicit 4-4-2 labeling, no source mutation, and a documented boundary around session-only state.
