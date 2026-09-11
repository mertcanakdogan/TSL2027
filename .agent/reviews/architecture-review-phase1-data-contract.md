# Architecture Review — Phase 1 Data Contract

**Date:** 2026-09-11
**Reviewer:** Agent

## Verdict

Approved with conditions

## 🔴 Blockers

None.

## 🟡 Warnings

### 1. Generated data must remain reproducible

The checked-in JSON is a runtime artifact, so it can drift from its generator. The generator must use stable inputs and no current-time or random values; the validator and documentation must expose the regeneration command.

### 2. Synthetic attributes must not be presented as scouting truth

The prototype has no licensed player-stat source. Every generated payload and UI label must identify the values as synthetic and must not call them official ratings.

### 3. Runtime loading must fail clearly

Godot currently falls back to an empty team list when JSON loading fails. The new loader should return an explicit error and keep the UI from silently presenting a valid-looking but empty season.

## 🔵 Notes

### 1. Keep provider integration outside runtime

The current repository policy correctly keeps API keys, raw provider payloads, and network calls out of the client. Future importers can target the same versioned schema.

### 2. Delay tactical and overall-rating models

Position-specific attributes are enough for the data contract. Tactic effects and any composite scoring should be added only with isolated tests and an explicit formula later.

## Summary

The smallest coherent next step is a deterministic synthetic data pack plus a runtime loader, not a provider integration or a full manager model. The architecture is simple, testable in Python without Godot, and leaves a stable seam for later tactics and match simulation work. Proceed after adding the required validation and documentation safeguards.
