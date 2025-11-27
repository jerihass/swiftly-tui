# Data Model: TUI Design and UX Improvements

## Entities

### TUI Screen Pattern
- Fields: name (menu/list/detail/install/update/remove/error), header text, body layout, status bar hint set.
- Rules: All screens must render header/body/status; hints remain visible; focus state persists across navigation.

### Keyboard Hint Set
- Fields: screen name, navigation keys (arrows/j/k/number jump), action keys (enter/space/s/b/r/c/q/0), exit keys.
- Rules: Hints must match actual bindings; updates require tests.

### Layout Density Rule
- Fields: terminal width threshold, row spacing, column choices.
- Rules: At 80 cols with ≥20 rows, use compact spacing while preserving identifier/channel/status visibility and focus markers.
