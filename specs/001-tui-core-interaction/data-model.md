# Data Model: TUI Interface for Core Functions

## Entities

### TUI Session
- **Fields**: sessionId, currentView (list/detail/progress/error), selectedToolchainId, lastOutcomeId, isResizing (bool)
- **Relationships**: References current Toolchain Summary and Operation Outcome.
- **Validation**: currentView must be a known view; selectedToolchainId must exist in loaded toolchains when set.

### Toolchain Summary
- **Fields**: id, name, version, channel (release|snapshot), status (active|installed|available|in-progress), location, size, lastOperationResult
- **Relationships**: Listed within TUI Session state; referenced by operations.
- **Validation**: channel matches known values; status transitions follow operation outcomes.

### Operation Outcome
- **Fields**: outcomeId, action (list|switch|install|uninstall|update), targetToolchainId, startedAt, completedAt, status (success|failed|cancelled), message, retryOptions (retry|cancel), progress (0-100, optional)
- **Relationships**: Linked to Toolchain Summary (target); stored in Session to render summaries.
- **Validation**: completedAt >= startedAt when present; status reflects action result; retryOptions non-empty on failure.

## State Transitions
- Toolchain Summary status: available → in-progress → installed/active OR failed (revert to prior status).
- Operation Outcome lifecycle: pending → in-progress → success|failed|cancelled.
- Session view transitions: list → detail → confirm → progress → summary; errors redirect to error view with retry/cancel.
