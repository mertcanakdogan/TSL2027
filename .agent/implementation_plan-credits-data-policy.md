# Credits and Data Policy Implementation Plan

## Objective

Expose the project's code license and current synthetic-data boundary inside
the game so a packaged build communicates its content status without relying
on repository documentation.

## Scope

- Add a read-only Credits & Veri Politikası view.
- Add it to the main navigation.
- Show MIT source-code scope, synthetic-data status, real-data release checks,
  and project/engine attribution.
- Add a main-scene smoke assertion for view creation, navigation, and the
  visible policy text.

## Out of scope

- Importing real player data, logos, photos, or provider API responses.
- Legal approval or replacing the repository's license files.

## Acceptance evidence

1. The Credits view is created by the main scene and hidden by default.
2. Navigation shows the view and displays MIT plus synthetic-data language.
3. Existing state, save/load, transfer, and weekly simulation tests remain
   green.
