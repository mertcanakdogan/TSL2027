# Architecture Review: Credits and Data Policy

## Decision

Implement Credits as a read-only UI view owned by the main scene, with no
runtime dependency on data providers or mutable career state.

## Review notes

- Separation: attribution and policy copy live in one view; gameplay state
  remains unchanged.
- Release safety: the view explicitly says that MIT covers project code only
  and that the current build uses synthetic data.
- Testability: the main-scene smoke test can inspect visibility and stable
  policy labels without simulating input events.
- Maintainability: the view follows the existing VBox/Panel UI pattern and is
  kept independent from the dashboard refresh cycle.
