# Quickstart: TUI Design and UX Improvements

## Verify UX Consistency
- Launch TUI: `swift run swiftly tui`
- Navigate menu → list → detail → back; verify header/body/status layout and visible hints update per screen.
- Open install/update/remove inputs; try valid and invalid identifiers; confirm inline validation without losing focus.
- Trigger an error (use mock/fixture) and check error view shows log path and retry/cancel hints.

## Terminal Size & Density
- Set terminal to 80 columns; ensure list renders compact spacing and focused row stays visible with identifier/channel/status intact.
- With ≥20 toolchains (fixtures), confirm focus markers and row alignment remain readable.

## Tests
- Run headless suite: `swift test --filter TUITests`
- Focused UX checks (examples):
  - `swift test --filter ListingViewTests`
  - `swift test --filter PerformanceTests/testProgressCadenceStaysUnderFiveSeconds`
  - `swift test --filter ErrorViewTests`

## Notes
- Document any missing SwifTeaUI components encountered; do not implement custom hacks—record the gap for upstream.
