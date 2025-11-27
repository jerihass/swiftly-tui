# Implementation Plan: SwifTeaUI-Driven TUI Flows

**Branch**: `001-swifteaui-tui` | **Date**: 2025-11-24 | **Spec**: specs/001-swifteaui-tui/spec.md
**Input**: Feature specification from `/specs/001-swifteaui-tui/spec.md`

## Summary

Build a component-driven SwifTeaUI experience for swiftly’s TUI that covers listing, detail view, switching, install/update/remove flows, and actionable error recovery. Use SwifTeaUI scenes (lists/tables, detail panes, progress/error components) instead of manual prints, keeping CLI contracts stable and testable on macOS and Linux.

## Technical Context
**Language/Version**: Swift 6 (SwiftPM package)  
**Primary Dependencies**: SwifTeaUI (branch `main`), swift-argument-parser, existing SwiftlyCore services for toolchain ops  
**Storage**: Local filesystem for toolchain installs; no new persistence  
**Testing**: XCTest with headless SwifTeaUI scenes; CLI-style integration tests on macOS and Linux  
**Target Platform**: macOS + Linux terminal environments  
**Project Type**: CLI with TUI front-end  
**Performance Goals**: Menu-to-action feedback <1s; progress updates at least every 5s during long operations  
**Constraints**: No destructive actions without confirmation; operations must be recoverable and leave active toolchain consistent; outputs split stdout/stderr per constitution  
**Scale/Scope**: Tens of toolchains listed; single-user interactive session; long-running installs/updates up to minutes

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Tests-first: Plan includes scene-level unit tests and CLI-style integration for macOS/Linux before implementation; add fixtures for list/switch/install/update/remove and error/recovery.
- Composable modules: TUI scenes/adapters remain thin; reuse SwiftlyCore operations via injected adapters; no domain logic inside command parsing.
- Clean boundaries: IO (filesystem/network/process) stays inside adapters; scenes are pure render/action mapping; side effects explicit.
- Platform parity & safety: Avoid platform-specific shortcuts; confirmations for destructive actions; ensure interrupted operations recover with retry/cancel.
- Release integrity: No breaking CLI flags; TUI outputs documented; note migration that TUI is now component-driven but command surface unchanged.

## Project Structure
### Documentation (this feature)

```text
specs/001-swifteaui-tui/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/
```

### Source Code (repository root)

```text
Sources/Swiftly/
├── Core/                 # existing domain/services (reuse)
├── TUI/
│   ├── Adapters/
│   ├── Components/
│   ├── Controllers/
│   ├── Views/
│   └── TUIApplication.swift
└── CLI/
    └── Commands/         # TUICommand entry stays thin

Tests/
├── TUITests/             # scene + flow tests
└── SwiftlyTests/         # existing core tests
```

**Structure Decision**: Single SwiftPM package with TUI scenes under `Sources/Swiftly/TUI` and TUI-specific tests under `Tests/TUITests`; no new modules added.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
