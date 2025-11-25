# Research: TUI Interface for Core Functions

## SwifTeaUI usage (branch main)
- **Decision**: Use SwifTeaUI (main branch) for all TUI rendering, navigation, and input handling.
- **Rationale**: Aligns with user direction; provides composable SwiftUI-like primitives for terminal UIs; minimizes custom rendering risk.
- **Alternatives considered**: Swift curses wrappers (more low-level, higher maintenance); raw ANSI rendering (too error-prone for accessibility and resizing); text-based menus via argument-parser (insufficient for guided flows).

## Progress and async operations
- **Decision**: Present progress states from core services as streaming updates; map long-running installs/updates to progress components with explicit success/failure summaries.
- **Rationale**: Keeps TUI responsive while core operations run; matches requirements for actionable feedback and recoverability.
- **Alternatives considered**: Blocking screens until completion (hurts UX, no recovery); silent background threads (risk of missing errors).

## Keyboard navigation and layout resilience
- **Decision**: Enforce keyboard-only navigation (arrows/Tab/Enter/shortcuts) with readable layout at 80x24 and graceful handling of terminal resize events.
- **Rationale**: Meets accessibility, platform parity, and constitution constraints; ensures usability in standard shells/CI.
- **Alternatives considered**: Mouse support (optional, not required); fixed-size layouts (would fail on small terminals).

## Error handling and confirmations
- **Decision**: Provide confirmations for destructive actions (uninstall, switching when operation in progress) and offer retry/cancel on any failure with clear messages.
- **Rationale**: Aligns with platform safety and release integrity principles; avoids partial/unrecoverable states.
- **Alternatives considered**: Implicit actions without confirmation (violates safety); one-shot failure without retry (hurts usability).

## SwifTeaUI gaps (to capture during implementation)
- None identified yet; add items here if new widgets or adapters are needed.
