# Credits and Data Policy Test Specification

## Main-scene smoke coverage

- Main scene creates a `CreditsView`.
- Credits view is hidden on dashboard startup.
- `_show_credits` makes Credits view visible and hides dashboard nodes.
- Source text contains `MIT`; policy text contains `sentetik`.
- Returning to dashboard hides Credits view and restores dashboard nodes.

## Regression coverage

- All existing Godot state/view/save tests still pass.
- Data-pack validation and Python contract tests still pass.
- Editor parse and Windows export verifier still pass.
