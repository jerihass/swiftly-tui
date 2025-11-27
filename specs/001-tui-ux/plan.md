# Implementation Plan: TUI Design and UX Improvements

**Branch**: `001-tui-ux` | **Date**: 2025-11-25 | **Spec**: specs/001-tui-ux/spec.md
**Input**: Feature specification from `/specs/001-tui-ux/spec.md`

## Summary

Unify TUI layouts (header/body/status with always-visible keyboard hints), strengthen focus cues, and make lists responsive at 80-col terminals while documenting UX patterns for future flows. Approach: apply SwifTeaUI components (Table, StatusBar, VStack/HStack, Text) with density rules and shared hint sets; add UX guide doc and tests for accessibility cues, layout consistency, and progress/error hinting.

## Technical Context

**Language/Version**: Swift 6  
**Primary Dependencies**: SwifTeaUI (main branch), swift-argument-parser, XCTest  
**Storage**: N/A (UI/UX only)  
**Testing**: XCTest (headless TUI scene tests + layout/UX validation)  
**Target Platform**: macOS & Linux terminals (80+ cols; supports smaller with compact density)  
**Project Type**: Single CLI project (`Sources/Swiftly/TUI/*`, `Tests/TUITests/*`)  
**Performance Goals**: Lists readable at 80 cols; keyboard journeys <60s; progress hint cadence ≤5s between updates  
**Constraints**: ASCII-safe layouts; avoid new deps; document any missing SwifTeaUI components for upstream; keep platform parity  
**Scale/Scope**: Existing TUI screens (menu, list/detail, install/update/remove, error/result); add UX guide doc and tests

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Tests-first: Each planned task includes failing tests before implementation (unit + CLI/integration) with macOS and Linux coverage.
- Composable modules: CLI commands stay thin; domain services and IO adapters are separated and injected.
- Clean architecture boundaries: Domain rules remain pure/deterministic; IO (filesystem, network, process) is wrapped behind protocols/adapters and injected.
- Platform parity & safety: Plans account for safe filesystem/process actions, checksum/signature validation, and recovery paths.
- CLI contract stability: Any flag/command changes note compatibility expectations and migration guidance.
- Release readiness: Expected version bump level and rollback/migration steps are identified when behavior changes.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
Sources/
└── Swiftly/
    └── TUI/
        ├── Components/    # shared styling/accessibility helpers
        ├── Views/         # SwifTeaUI scenes (list/detail/install/update/remove/error)
        ├── Controllers/   # TUI orchestration + recovery
        ├── Adapters/      # Core interaction + output/log adapters
        └── Models/        # View models

Tests/
└── TUITests/
    ├── Contract/         # action mapping/contract tests
    ├── Fixtures/         # deterministic toolchain fixtures
    ├── Support/          # harness utilities
    └── *.swift           # flow/layout/UX tests

specs/001-tui-ux/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/
```

**Structure Decision**: Single CLI project with TUI modules under `Sources/Swiftly/TUI` and headless UI tests under `Tests/TUITests`; docs under `specs/001-tui-ux`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
