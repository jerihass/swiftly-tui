# Quickstart: TUI Interface for Core Functions

## Prerequisites
- Swift 6 toolchain available on macOS or Linux (align with project toolchain).
- SwifTeaUI dependency available via package manager (branch `main`).
- Existing swiftly workspace checked out on branch `001-tui-core-interaction`.

## Run the TUI (after implementation)
```bash
# From repo root
swift run swiftly tui
```
- Use arrow keys/Tab/Enter shortcuts; confirm destructive operations when prompted.
- Ensure terminal window is at least 80x24 for full layout.

## Basic flows to verify
- List toolchains and view details (active/installed/available).
- Switch active toolchain and confirm success message.
- Install available toolchain and observe progress plus final summary.
- Trigger an offline scenario (disable network) and verify retry/cancel handling.

## Tests
```bash
# Unit + integration across TUI flows
swift test --filter SwiftlyTests
```
- Run on macOS and Linux to confirm platform parity.

## Logs & Troubleshooting
- Errors appear in stderr; summaries and prompts in stdout.
- If layout appears truncated, resize terminal or increase rows/columns before re-launching.
