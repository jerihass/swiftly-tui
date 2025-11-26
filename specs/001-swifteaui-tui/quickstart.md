# Quickstart: SwifTeaUI-Driven TUI Flows

## Prerequisites
- Swift 6 toolchain
- SwiftPM dependencies (SwifTeaUI on branch `main`, swift-argument-parser)
- macOS or Linux terminal

## Run Tests (TDD-first)
- Scene/unit focus: `swift test --filter TUITests`
- Full suite (headless mode): `swift test`
- Targeted flow examples:
  - Listing: `swift test --filter ListingViewTests`
  - Switching: `swift test --filter CoreActionsFlowTests`
  - Error handling: `swift test --filter ErrorRecoveryTests`

## Verify User Story 1 (Navigate and Switch)
1) Start the TUI: `swift run swiftly tui`
2) From the menu, press `1` to load toolchains (or numbers to jump directly).
3) Move focus with `j/k` or arrow keys; `Enter`/`Space` opens detail; `b` returns to list.
4) In detail, press `s` to switch; wait for success result and confirm status bar shows result.
5) Press `1` to refresh list; active toolchain should now be marked active.
6) Exit with `0` or `q`.

## Run the TUI
- Standard: `swift run swiftly tui`
- With verbose logging: `swift run swiftly tui --verbose`
- To exercise headless scenarios in CI, provide deterministic fixtures/stubs via adapters (e.g., mock toolchain list, injected failures) and assert outputs.

## Notes
- Destructive operations (remove) require confirmation; switching is disallowed or prompts when target is active.
- Progress should update at least every 5 seconds for install/update/remove flows.
- If SwifTeaUI lacks a needed component, document the gap (per FR-009) and use a minimal fallback layout while keeping flows usable.
