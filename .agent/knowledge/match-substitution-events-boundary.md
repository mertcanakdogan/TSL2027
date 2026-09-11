# Match Substitution Events Boundary

- `SquadState` remains the owner of roster and bench membership; `main.gd`
  passes copied `starting_xi` and `bench` snapshots into the match context.
- `MatchEngine` generates up to three deterministic synthetic substitution
  report events per side between minutes 46 and 90 when a bench is available.
- Substitution events are report data only in this slice. They do not mutate
  the lineup, condition, eligibility, or save state.
- Missing/empty bench context remains a supported fallback and produces zero
  substitutions, preserving direct engine callers and older contexts.
